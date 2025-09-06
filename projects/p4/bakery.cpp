#include <iostream>
#include <thread>
#include <vector>
#include <queue>
#include <mutex>
#include <semaphore.h>
#include <condition_variable>
#include <random>
#include <unistd.h>
#include <chrono>
#include <iomanip>

class Container {
public:
    Container(int capacity, int refillRate) : capacity(capacity), refillRate(refillRate), amount(capacity) {
        sem_init(&sem, 0, 0);
    }

    void take(int n) {
        std::unique_lock<std::mutex> lock(mtx);
        while (amount < n) {
            std::cout << "Waiting for refill, needed: " << n << ", available: " << amount << std::endl;
            cv.wait(lock, [&] { return amount >= n; });
        }
        amount -= n;
        std::cout << "Took " << n << " units, remaining: " << amount << std::endl;
    }

    void refill() {
        while (isOpen) {
            std::this_thread::sleep_for(std::chrono::seconds(1));
            {
                std::lock_guard<std::mutex> lock(mtx);
                amount = std::min(capacity, amount + refillRate);
                std::cout << "Refilled to " << amount << std::endl;
            }
            cv.notify_all();
        }
    }

    void close() {
        isOpen = false;
        cv.notify_all();
    }

private:
    int capacity;
    int refillRate;
    int amount;
    std::mutex mtx;
    std::condition_variable cv;
    sem_t sem;
    bool isOpen = true;
};

class Bakery {
public:

    Bakery(int numEmployees, int containerCapacity, int refillRate, int numCustomers, int prepTime)
        : numEmployees(numEmployees), numCustomers(numCustomers), prepTime(prepTime),
        cheese(containerCapacity, refillRate), lettuce(containerCapacity, refillRate),
        cucumber(containerCapacity, refillRate), bun(containerCapacity, refillRate),
        doneCustomers(0), done(false) {
        orderProcessor = std::thread(&Bakery::processOrders, this);
        for (int i = 0; i < numEmployees; ++i) {
            employees.push_back(std::thread(&Bakery::employeeTask, this, i + 1));
        }
        restocker = std::thread(&Bakery::restockTask, this);
        customerGenerator = std::thread(&Bakery::generateCustomers, this);
    }


    std::vector<std::thread>& getEmployees() {
        return employees;
    }


    ~Bakery() {
        setDone();

        for (auto& employee : employees) {
            if (employee.joinable()) {
                employee.join();
            }
        }

        cheese.close();
        lettuce.close();
        cucumber.close();
        bun.close();

        if (orderProcessor.joinable()) {
            orderProcessor.join();
        }
        if (restocker.joinable()) {
            restocker.join();
        }
        if (customerGenerator.joinable()) {
            customerGenerator.join();
        }
    }



    void prepareSandwiches(int employeeId, int customerId, int sandwiches) {
        cheese.take(sandwiches);
        lettuce.take(sandwiches);
        cucumber.take(sandwiches);
        bun.take(sandwiches);
        std::cout << "Employee " << employeeId << " is making " << sandwiches << " sandwiches for customer " << customerId << ", this will take " << prepTime * sandwiches << " microseconds." << std::endl;
        usleep(prepTime * sandwiches);
        std::cout << "Employee " << employeeId << " has finished preparing " << sandwiches << " sandwiches for customer " << customerId << "." << std::endl;
    }

    void restockTask() {
        std::thread cheeseRestocker(&Container::refill, &cheese);
        std::thread lettuceRestocker(&Container::refill, &lettuce);
        std::thread cucumberRestocker(&Container::refill, &cucumber);
        std::thread bunRestocker(&Container::refill, &bun);
        cheeseRestocker.detach();
        lettuceRestocker.detach();
        cucumberRestocker.detach();
        bunRestocker.detach();
    }


private:
    int numEmployees;
    int numCustomers;
    int prepTime;
    std::vector<std::thread> employees;
    std::thread restocker;
    std::thread customerGenerator;
    std::thread orderProcessor;
    Container cheese, lettuce, cucumber, bun;
    std::queue<int> customerQueue;
    std::queue<std::pair<int, int>> customerOrderQueue;
    std::mutex queueMtx;
    std::mutex orderMtx;
    std::condition_variable cv;
    int doneCustomers;
    bool done;

    void setDone() {
        {
            std::lock_guard<std::mutex> lock(queueMtx);
            done = true;
        }
        cv.notify_all();
    }


    std::queue<std::pair<int, int>> orderQueue;


    void generateCustomers() {
        for (int i = 0; i < numCustomers; ++i) {
            int sandwiches = rand() % 10 + 1;
            {
                std::lock_guard<std::mutex> lock(queueMtx);
                orderQueue.push({i + 1, sandwiches});
                std::cout << "Customer " << i + 1 << " ordered " << sandwiches << " sandwiches" << std::endl;
            }
            cv.notify_one();
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
        setDone();
    }

    void processOrders() {
        int customerId = 1;
        while (true) {
            std::pair<int, int> order;
            {
                std::unique_lock<std::mutex> lock(queueMtx);
                cv.wait(lock, [&] { return !orderQueue.empty() || done; });
                if (done && orderQueue.empty()) break;
                order = orderQueue.front();
                orderQueue.pop();
                customerId++;
            }
            std::cout << "Processing order for customer " << order.first << "." << std::endl;
            cv.notify_all();
        }
    }

    void employeeTask(int id) {
        while (true) {
            std::pair<int, int> order;
            {
                std::unique_lock<std::mutex> lock(queueMtx);
                cv.wait(lock, [&] { return !orderQueue.empty() || done; });
                if (done && orderQueue.empty()) break;
                order = orderQueue.front();
                orderQueue.pop();
                std::cout << "Employee " << id << " has taken the order of customer " << order.first <<" (" << order.second << " sandwiches)." << std::endl;
            }
            prepareSandwiches(id, order.first, order.second);
            doneCustomers++;
        }
    }

};


int main(int argc, char* argv[]) {
    if (argc != 6) {
        std::cerr << "Usage: ./bakery_simulation <numEmployees> <containerCapacity> <refillRate> <numCustomers> <prepTime>" << std::endl;
        return 1;
    }

    int numEmployees = std::stoi(argv[1]);
    int containerCapacity = std::stoi(argv[2]);
    int refillRate = std::stoi(argv[3]);
    int numCustomers = std::stoi(argv[4]);
    int prepTime = std::stoi(argv[5]);

    auto start = std::chrono::steady_clock::now();

    Bakery bakery(numEmployees, containerCapacity, refillRate, numCustomers, prepTime);

    for (auto& employee : bakery.getEmployees()) {
        if (employee.joinable()) {
            employee.join();
        }
    }

    auto end = std::chrono::steady_clock::now();

    std::chrono::duration<double> elapsed = end - start;
    std::cout << "Elapsed time: " << std::fixed << std::setprecision(2) << elapsed.count() << " seconds" << std::endl;

    double throughput = numCustomers / elapsed.count();
    std::cout << "Throughput: " << std::fixed << std::setprecision(2) << throughput << " sandwiches/second" << std::endl;

    std::cout << "End of program" << std::endl;
    return 0;
}
