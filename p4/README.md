## Bakery Simulation - README

This code simulates a bakery with employees, ingredients, and customers. 

### Functionality

* Customers arrive and place orders for a random number of sandwiches (between 1 and 10).
* Employees take orders, wait for ingredients if necessary, and prepare sandwiches.
* A separate thread restocks ingredients when they run low.
* The program outputs information about customer orders, employee actions, and overall throughput after simulating a set duration.

### Running the Simulation

1. Compile the code:

   ```bash
   g++ bakery.cpp -o bakery
   or
   g++ bakery.cpp -o bakery -lpthread
   ```

2. Run the simulation with the following arguments:

   - `<numEmployees>`: Number of employees in the bakery.
   - `<containerCapacity>`: Maximum capacity of each ingredient container.
   - `<refillRate>`: Number of units added to an ingredient container per refill.
   - `<numCustomers>`: Total number of customers to be served.
   - `<prepTime>`: Preparation time (in microseconds) per sandwich.

   ```bash
   ./bakery 2 10 5 20 100000
   ```

   This example runs the simulation with 2 employees, 10 units per ingredient container, a refill rate of 5 units, 20 customers, and a preparation time of 0.1 seconds per sandwich.

### Code Breakdown

The code consists of three main classes:

* **Container:** Represents an ingredient container with a capacity, refill rate, and methods to take ingredients, refill, and close.
* **Bakery:** Manages the overall simulation by creating threads for employees, restocking, customer generation, and order processing. It also includes container objects, queues for orders, and synchronization primitives.
* **Main Function:** Parses command-line arguments, creates a Bakery object, runs the simulation, and prints relevant statistics.

### Additional Notes

* The code uses various synchronization primitives (`std::mutex`, `std::condition_variable`, `std::queue`) to ensure thread safety and manage access to shared resources.
* Error handling is not included in this version. 
* You can modify the parameters and code to explore different scenarios and optimize the bakery's performance.
