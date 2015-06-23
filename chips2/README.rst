Chips
=====

Introduction
------------

*Chips* makes FPGA design quicker and easier. *Chips* isn't an HDL like VHDL or
Verilog, its a different way of doing things. In *Chips*, you design components
using a simple subset of the C programming language. There's a Python API to
connect C components together using fast data streams to form complex, parallel
systems all in a single chip. You don't need to worry about clocks, resets,
or timing. You don't need to follow special templates to make your code
synthesisable. All that's done for you!

Test
----

::

        $ cd test_suite
        $ test_c2verilog

Install
-------

::

        $ sudo python setup install

Documentation
-------------

::

        $ cd docs
        $ make html

To Prepare a Source Distribution
--------------------------------

::

        $ python setup sdist

Distribution is contained in ./dist

To Create a Windows Distribution
--------------------------------

::

        $ python setup bdist_wininst
