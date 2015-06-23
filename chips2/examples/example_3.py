#!/usr/bin/env python

import subprocess
import atexit
from math import pi

children = []
def cleanup():
    for child in children:
        print "Terminating child process"
        child.terminate()
atexit.register(cleanup)

def run_c(file_name):
    process = subprocess.Popen(["../c2verilog", "iverilog", "run", str(file_name)])
    children.append(process)
    process.wait()
    children.remove(process)

def test():
    run_c("sort.c")

def indent(lines):
    return "\n    ".join(lines.splitlines())

def generate_docs():

    documentation = """

Implement Quicksort
-------------------

This example sorts an array of data using the 
`Quick Sort algorithm <http://en.wikipedia.org/wiki/Quicksort>`_

The quick-sort algorithm is a recurrsive algorithm, but *Chips* does not
support recursive functions. Since the level of recursion is bounded, it is
possible to implement the function using an explicitly created stack.

.. code-block:: c

    %s

The algorithm is tested using an array containing out of order values. The program correctly sorts the array::

         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         0 (report at line: 122 in file: sort.c)
         1 (report at line: 122 in file: sort.c)
         2 (report at line: 122 in file: sort.c)
         3 (report at line: 122 in file: sort.c)
         4 (report at line: 122 in file: sort.c)
         5 (report at line: 122 in file: sort.c)
         6 (report at line: 122 in file: sort.c)
         7 (report at line: 122 in file: sort.c)
         8 (report at line: 122 in file: sort.c)
         9 (report at line: 122 in file: sort.c)
        10 (report at line: 122 in file: sort.c)
        11 (report at line: 122 in file: sort.c)
        12 (report at line: 122 in file: sort.c)
        13 (report at line: 122 in file: sort.c)
        14 (report at line: 122 in file: sort.c)
        15 (report at line: 122 in file: sort.c)
        16 (report at line: 122 in file: sort.c)

"""%indent(open("sort.c").read())

    document = open("../docs/source/examples/example_3.rst", "w").write(documentation)

test()
generate_docs()
