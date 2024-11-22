#include <stdint.h>
#include<stdio.h>

uint64_t fibonacci(uint64_t number) {
    if (number == 0) return 0;
    if (number == 1) return 1;
    return fibonacci(number - 1) + fibonacci(number - 2);
}

int main() {
    printf("Showing from fibonacci (recursive) from 0 to 42");

    uint64_t result = 0;

    for(int number = 0; number < 43; number++) {
        printf("fibonacci(%d) => ", number);
        result = fibonacci(number);
        printf("%lu\n", result);
    }
    return 0;
}
