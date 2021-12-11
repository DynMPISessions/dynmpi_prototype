#!/usr/bin/python
'''
This Python script demonstrates MAP's Python profiling capabilities.
To run the demo, from the examples directory, run:
     $ make -f python-profiling.makefile
     $ ../bin/map --start python python-profiling.py --index 30
'''
import os
import ctypes
import argparse

example_dir = os.path.dirname(os.path.realpath(__file__))
fibonacciLib = ctypes.CDLL(os.path.join(example_dir, 'libfibonacci.so'))

fibonacciLib.compute_fibonacci.argtypes = [ctypes.c_ulonglong]
fibonacciLib.compute_fibonacci.restype = ctypes.c_ulonglong
def fibonacci_c(index):
    return fibonacciLib.compute_fibonacci(index)

def fibonacci_python(index):
    return index if index in [0, 1] else fibonacci_python(index-1) + fibonacci_python(index-2)

def main():
    parser = argparse.ArgumentParser(description='Compute a Fibonacci number.')
    parser.add_argument("--index", dest="index", help="index in the Fibonacci sequence", type=int, default=20)
    options = parser.parse_args()
    print("The Fibonacci number at index %s is:\n%s (computed in C)\n%s (computed in Python)" % (options.index,
          fibonacci_c(options.index),
          fibonacci_python(options.index)))

if __name__ == "__main__":
    main()
