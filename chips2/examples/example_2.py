#!/usr/bin/env python

import subprocess
import atexit
from math import pi

try:
    from matplotlib import pyplot
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
    run_c("taylor.c")
    x = [float(i) for i in open("x")]
    sin_x = [float(i) for i in open("sin_x")]
    cos_x = [float(i) for i in open("cos_x")]
    pyplot.xticks(
        [-2.0*pi, -pi, 0, pi,  2.0*pi],
        [r'$-2\pi$', r"$-\pi$", r'$0$', r'$\pi$', r'$2\pi$'])
    pyplot.plot(x, sin_x, label="sin(x)")
    pyplot.plot(x, cos_x, label="cos(x)")
    pyplot.ylim(-1.1, 1.1)
    pyplot.xlim(-2.2 * pi, 2.2 * pi)
    pyplot.title("Trig Functions")
    pyplot.xlabel("x (radians)")
    pyplot.legend(loc="upper left")
    pyplot.savefig("../docs/source/examples/images/example_2.png")
    pyplot.show()

def indent(lines):
    return "\n    ".join(lines.splitlines())

def generate_docs():

    documentation = """

Approximating Sine and Cosine functions using Taylor Series
-----------------------------------------------------------

In this example, we calculate an approximation of the cosine functions using
the `Taylor series <http://en.wikipedia.org/wiki/Taylor_series>`_:

.. math::

    \\cos (x) = \\sum_{n=0}^{\\infty} \\frac{(-1)^n}{(2n)!} x^{2n}


The following example uses the Taylor Series approximation to generate the Sine
and Cosine functions. Successive terms of the taylor series are calculated
until successive approximations agree to within a small degree. A Sine
function is also synthesised using the identity :math:`sin(x) \\equiv cos(x-\\pi/2)`

.. code-block:: c

    %s

A simple test calculates Sine and Cosine for the range :math:`-2\\pi <= x <= 2\\pi`.

.. image:: images/example_2.png

"""%indent(open("taylor.c").read())

    document = open("../docs/source/examples/example_2.rst", "w").write(documentation)

test()
generate_docs()
