#!/usr/bin/env python3
'''
This Python script demonstrates DDT's Python debugging capabilities.
To run the demo, from the examples directory, run:
     $ make -f python-debugging.makefile
     $ ../bin/ddt python3 %allinea_python_debug% python-debugging.py

     * Press Play/Continue to run to the first line of the script.
     * Set a breakpoint on line 25 to inspect local variables in that function.
     * Use the add breakpoint dialog to set a breakpoint on the function name "library_function"
       to break in native code.
'''
import os
import ctypes

example_dir = os.path.dirname(os.path.realpath(__file__))
externalLib = ctypes.CDLL(os.path.join(example_dir, 'pythonlib.so'))

def call_out_to_a_library():
    # Some local variables to show in the DDT locals window
    localInt = 42
    localIntArray = [1, 2, 3, 4]
    localDictionary = {'a': 10, 'b': 11, 'c': 12}

    for x in localIntArray:
        print(externalLib.library_function(4, x))

call_out_to_a_library()
