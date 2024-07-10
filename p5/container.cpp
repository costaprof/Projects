#include <iostream>
#include <chrono>
#include <thread>

using namespace std;



int fibonacci(int n) {

    if (n <= 1) {
        return n;
    } else {
        return fibonacci(n - 1) + fibonacci(n - 2);
    }

}

int main() {

    const int n = 70;
    const int size = 1000000;

    cout << "Calculating Fibonacci number for n = " << n << "..." << endl;

    int result = fibonacci(n);

    cout << "Fibonacci(" << n << ") = " << result << endl;


    int* ptr = new int[size];

    if (ptr == nullptr) {

        std::cerr << "Memory allocation failed!\n";

    }

    for(int i=0; i<size; i++){

        ptr[i]=i;
    }

    std::this_thread::sleep_for(std::chrono::seconds(10));


    return 0;
}

