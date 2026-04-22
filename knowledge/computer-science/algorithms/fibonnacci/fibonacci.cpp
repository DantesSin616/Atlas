#include <vector>
#include <iostream>

using std::vector;
using std::cout;
using std::cin;

int naive_fibonacci_recursive(int n){
    if(n <= 1){
        return n;
    } else {
        return naive_fibonacci_recursive(n - 1) + naive_fibonacci_recursive(n - 2); // Possible Big-O(n^2)
    }
}

int efficient_fibonacci(int n){

	return 0;
}
