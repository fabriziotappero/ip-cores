#!/usr/bin/env python

import subprocess
import atexit
from math import pi

try:
    from matplotlib import pyplot
    from mpl_toolkits.mplot3d import Axes3D
except ImportError:
    print "You need matplotlib to run this script!"
    exit(0)

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
    run_c("rand.c")
    x = [float(i) for i in open("x")]
    y = [float(i) for i in open("y")]
    z = [float(i) for i in open("z")]

    fig = pyplot.figure()
    ax = fig.add_subplot(111, projection="3d")
    ax.scatter(x, y, z, c='b', marker='^')
    pyplot.title("Random Plot")
    pyplot.savefig("../docs/source/examples/images/example_4.png")
    pyplot.show()

def indent(lines):
    return "\n    ".join(lines.splitlines())

def generate_docs():

    documentation = """

Pseudo Random Number Generator
------------------------------

This example uses a 
`Linear Congruential Generator (LCG) <http://en.wikipedia.org/wiki/Linear_congruential_generator>`_ to generate Pseudo Random Numbers.

.. code-block:: c

    %s

.. image:: images/example_4.png

"""%indent(open("rand.c").read())

    document = open("../docs/source/examples/example_4.rst", "w").write(documentation)

test()
generate_docs()
