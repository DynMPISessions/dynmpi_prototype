/*
 * This library is used in the python-profiling.py example.
 * See python-profiling.py for more details.
 */
unsigned long long compute_fibonacci(const unsigned long long n) {
    switch(n) {
        case 0: return 0;
        case 1: return 1;
        default:
            return compute_fibonacci(n-1) + compute_fibonacci(n-2);
    }
}
