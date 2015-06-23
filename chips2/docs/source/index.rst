===================================
*Chips* - Hardware Design in Python
===================================

What is *Chips*?
================

*Chips* makes FPGA design quicker and easier. *Chips* isn't a Hardware
Description Language (HDL) like VHDL or Verilog, its a different way of doing
things. In *Chips*, you design components using a simple subset of the C
programming language. There's a Python API to connect C components together
using fast data streams to form complex, parallel systems all in a single chip.
You don't need to worry about clocks, resets, or timing. You don't need to
follow special templates to make your code synthesisable. All that's done for
you!

Features
======== 

Some of the key features include:

        - A fast and simple development environment

        - A free open source solution (MIT license)

        - Automatic generation of synthesisable Verilog

        - Optimise for speed or area

        - Use C and Python software tools to design hardware.


You can get the *Chips* from the `Git Hub <http://github.com/dawsonjon/Chips-2.0>`_
homepage. If you want to give it a try in some real hardware, take a look at
the `demo <http://github.com/dawsonjon/Chips-Demo>`_ for the Digilent Atlys
Demo card.

A Quick Taster
==============

.. code-block:: c

        lfsr.c:

        //4 bit linear feedback shift register

        void lfsr(){
            int new_bit = 0;
            int shift_register = 1;
            while(1){
         
                 //tap off bit 2 and 3 
                 new_bit=((shift_register >> 0) ^ (shift_register >> 1) ^ new_bit);
         
                 //implement shift register
                 shift_register=((new_bit & 1) << 3) | (shift_register >> 1);
         
                 //4 bit mask
                 shift_register &= 0xf;
         
                 //write to stream
                 report(shift_register);
             }
        }

::

        console:

        $ c2verilog iverilog run lfsr.c

        8
        12
        14
        7
        3
        1

Documentation
=============
.. toctree::
   :maxdepth: 2

   language_reference/index
   examples/index
   tutorial/index

Links
=====

- `SciPy`_ Scientific Tools for Python.

- `matplotlib`_ 2D plotting library for Python.

- `Python Imaging Library (PIL)`_ Python Imaging Library adds image processing
  capabilities to Python.

- `MyHDL`_ A Hardware description language based on Python.

.. _`SciPy`: http://scipy.org
.. _`matplotlib`: http://matplotlib.org
.. _`MyHDL`: http://www.myhdl.org
.. _`Python Imaging Library (PIL)`: http://www.pythonware.com/products/pil/


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

