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

void fibonacciSum(size_t size) {
    int* ptr = new int[size];
    if (ptr == nullptr) {
        cerr << "Memory allocation failed!\n";
        return;
    }

    for (size_t i = 0; i < size; ++i) {
        ptr[i] = fibonacci(i % 40);
    }

    long long sum = 0;
    for (size_t i = 0; i < size; ++i) {
        sum += ptr[i];
    }

    cout << "Fibonacci Sum = " << sum << endl;

    delete[] ptr;
}

int main() {

    const size_t size = 100000000;

    fibonacciSum(size);

    this_thread::sleep_for(chrono::seconds(10));

    return 0;
}



