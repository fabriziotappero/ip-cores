===============================
Reference Manual
===============================

Download
========

You can download the 
`source <https://github.com/dawsonjon/Chips-2.0/archive/master.zip>`_ 
from the
`Git Hub <https://github.com/dawsonjon/Chips-2.0>`_ 
homepage. Alternatively clone the project using git::

    ~$ git clone https://github.com/dawsonjon/Chips-2.0.git


Install
=======

1. First `install Python <http://python.org/download>`_. You need *Python* 2.6 or later, but not *Python* 3.
2. In the Linux console, or the Windows command line (you will need
      administrator privileges)::

        ~$ cd Chips-2.0
        ~$ python setup.py install

Icarus Verilog
==============

This example uses the `Icarus Verilog <http://iverilog.icarus.com/>`_
simulator, you will need this installed in your command path to follow this
tutorial.

C Components
============

This section of the manual describes the subset of the C language that is available in *Chips*.

Types
-----

The following types are available in chips:

        + `char`
        + `int`
        + `long`
        + `unsigned char`
        + `unsigned int`
        + `unsigned long`
        + `float`

A `char` is at least 8 bits wide.  An `int` is at least 16 bits wide.  A `long`
is at least 32 bits wide.

The `float` type is implemented as an IEEE 754 single precision floating point
number.

At present, `long long`, `float` and `double` have not been implemented, but I
plan to add support for these types in a later release.

single dimensional arrays, `char[]`, `int[]` and `long[]` are supported, but
multidimensional arrays are not yet supported.

`struct` s are supported, you can define arrays of `struct` s, and `struct` s
may contain arrays.

`struct` s cannot yet be passed to a function or returned from a function.

Arrays may be passed (by reference) to functions.

Pointers are not supported, and neither is dynamic memory allocation. This is a
deliberate decision with low memory FPGAs in mind, and probably won't be
supported in future releases.

Functions
---------

Functions are supported. They may be nested, but may not be recursive. Only a
fixed number of arguments is supported, optional arguments are not permitted.

Control Structures
------------------

The following control structures are supported:

+ if/else statements
+ while loop
+ for loop
+ break/continue statements
+ switch/case statements

Operators
---------

The following operators are supported, in order of preference:

+ `()`
+ `~` `-` `!` `sizeof` (unary operators)
+ `*` `/` `%`
+ `+` `-`
+ `<<` `>>`
+ `<` `>` `<=` `>=`
+ `==` `!=`
+ `&`
+ '^`
+ `|`
+ `&&`
+ `||`
+ \`? : `


Stream I/O
----------

The language has been extended to allow components to communicate by sending
data through streams.

Stream I/O is achieved by calling built-in functions with special names.
Functions that start with the name `input` or `output` are interpreted as "read
from input", or "write to output".

.. code-block:: c

    int temp;
    temp = input_spam(); //reads from an input called spam
    temp = input_eggs(); //reads from an input called eggs
    output_fish(temp);   //writes to an output called fish

Reading or writing from inputs and outputs causes program execution to block
until data is available. If you don't want to commit yourself to reading and
input and blocking execution, you can check if data is ready.

.. code-block:: c

    int temp;
    if(ready_spam()){
       temp = input_spam();
    }

There is no equivalent function to check if an output is ready to receive data,
this could cause deadlocks if both the sending and receiving end were waiting
for one another. 

Timed Waits
-----------

Timed waits can be achieved using the built-in `wait-clocks` function. The
wait_clocks function accepts a single argument, the numbers of clock cycles to
wait.

.. code-block:: c
    
    wait_clocks(100); //wait for 1 us with 100MHz clock


Debug and Test
--------------

The built in `report` function displays the value of an expression in the
simulation console. This will have no effect in a synthesised design.

.. code-block:: c

    int temp = 4;
    report(temp); //prints 4 to console
    report(10); //prints 10 to the console


The built in function assert causes a simulation error if it is passed a zero
value. The assert function has no effect in a synthesised design.

.. code-block:: c

    int temp = 5;
    assert(temp); //does not cause an error
    int temp = 0;
    assert(temp); //will cause a simulation error
    assert(2+2==5); //will cause a simulation error

In simulation, you can write values to a file using the built-in `file_write`
function. The first argument is the value to write, and the second argument is
the file to write to. The file will be overwritten when the simulation starts,
and subsequent calls will append a new vale to the end of the file. Each value
will appear in decimal format on a separate line. A file write has no effect in
a synthesised design.

.. code-block:: c

    file_write(1, "simulation_log.txt");
    file_write(2, "simulation_log.txt");
    file_write(3, "simulation_log.txt");
    file_write(4, "simulation_log.txt");

You can also read values from a file during simulation. A simulation error will
occur if there are no more value in the file.

.. code-block:: c

    assert(file_read("simulation_log.txt") == 1);
    assert(file_read("simulation_log.txt") == 2);
    assert(file_read("simulation_log.txt") == 3);
    assert(file_read("simulation_log.txt") == 4);


C Preprocessor
--------------

The C preprocessor currently has only limited capabilities, and currently only
the `#include` feature is supported.

Built in Libraries
==================

The C standard library is not supported. The intention is to provide a build-in
library with some basic utilities appropriate for FPGA design. At present
`print.h` is the only library provided.

print.h
-------

The `print_string` function prints a null terminated string to standard output.

.. code-block:: c

    void print_string(char string[])

The `print_decimal` function prints a number in decimal to standard output.

.. code-block:: c

    void print_decimal(int value)

The `print_hex` function prints a number in hexadecimal format to standard output.

.. code-block:: c

    void print_hex(int value)

To provide most flexibility, the definition of standard_output is left to the
user, it could be a serial port, an LCD display, or perhaps a telnet session.
To define standard output, a function `stdout_put_char` function must be
defined before including print.h.

.. code-block:: c

    void stdout_put_char(char value){
        output_rs232_tx(value);
    }

    #include <print.h>

    print_string("Hello World!\n"); //Hello World
    print_decimal(12345); //12345
    print_hex(127); //0x7f

c2verilog
---------

For simple designs with only one C component, the simplest way to generate Verilog is by using the c2verilog utility.
The utility accepts C files as input, and generates Verilog files as output.

::

    ~$ c2verilog input_file.c

You may automatically compile the output using Icarus Verilog by adding the
`iverilog` option. You may also run the Icarus Verilog simulation using the
`run` option.

::

    ~$ c2verilog iverilog run input_file.c

You can also influence the way the Verilog is generated. By default, a low area
solution is implemented. If you can specify a design optimised for speed using
the `speed` option.

Python API
==========

The C language provides the ability to define components. The Python API
provides the ability to build systems from C components.

To use the Python API, you must import it.

.. code-block:: python

    from chips.api.api import *

Chip
----

Once you have imported the Python API, you can define a chip. A chip is a
canvas to which you can add inputs outputs, components and wires. When you
create a chips all you need to give it is a name.

.. code-block:: python

    mychip = Chip("mychip")

Wire
----

You can create `Input`, `Output` and `Wires` objects. A `Wire` is a point to point connection, a stream, that connects an output from one component to the input of another. A `Wire` can only have one source of data, and one data sink. When you create a `Wire`, you must tell it which `Chip` it belongs to:

.. code-block:: python

    wire_a = Wire(mychip)
    wire_b = Wire(mychip)

Input
-----

An `Input` takes data from outside the `Chip`, and feeds it into the input of a
`Component`. When you create an `Input`, you need to specify the `Chip` it
belongs to, and the name it will be given.

.. code-block:: python

    input_a = Input(mychip, "A")
    input_b = Input(mychip, "B")
    input_c = Input(mychip, "C")
    input_d = Input(mychip, "D")

Output
------

An `Output` takes data from a `Component` output, and sends it outside the
`Chip`. When you create an `Output` you must tell it which `Chip` it belongs
to, and the name it will be given.

Component
---------

From Python, you can import a C component by specifying the file where it is
defined. When you import a C component it will be compiled.

The C file adder.c defines a two input adder.

.. code-block:: python

    //adder.c

    void adder(){
        while(1){
            output_z(input_a() + input_b());
        }
    }

.. code-block:: python

    adder = Component("source/adder.c")

Instances
---------

You can make many instances of a component by "calling" the component. Each
time you make an instance, you must specify the `Chip` it belongs to, and
connect up the inputs and outputs of the `Component`.

.. code-block:: python
  
    adder(mychip,
        inputs = {"a" : input_a, "b" : input_b},
        outputs = {"z" : wire_a})

    adder(mychip,
        inputs = {"a" : input_c, "b" : input_d},
        outputs = {"z" : wire_b})

    adder(mychip,
        inputs = {"a" : wire_a, "b" : wire_b},
        outputs = {"z" : output_z})

A diagrammatic representation of the `Chip` is shown below.

::

           +-------+       +-------+
           | adder |       | adder |
    A =====>       >=======>       >=====> Z
    B =====>       |       |       |
           +-------+       |       |
                           |       |
           +-------+       |       |
           | adder |       |       |
    C =====>       >=======>       |
    D =====>       |       |       |
           +-------+       +-------+

Code Generation
---------------

You can generate synthesisable Verilog code for your chip
using the `generate_verilog` method.

.. code-block:: python

    mychip.generate_verilog()

You can also generate a matching testbench using the `generate_testbench`
method. You can also specify the simulation run time in clock cycles.

.. code-block:: python
 
    mychip.generate_testbench(1000) #1000 clocks

To compile the design in Icarus Verilog, use the `compile_iverilog` method. You
can also run the code directly if you pass `True` to the `compile_iverilog`
function.
  
.. code-block:: python

    mychip.compile_iverilog(True)


Physical Interface
==================

`Input`, `Output` and `Wire` objects within a chip are implemented using a
synchronous interconnect bus. The details of the interconnect bus are described
here. This section will be of most use to developers who want to integrate a
*Chips* design into a larger design, or to generate an HDL wrapper to support a
*Chips* design in new hardware.

::
 
  rst >-o-----------------------------+
  clk >-+-o-------------------------+ |
        | |                         | |
        | |   +-----------+         | |     +--------------+
        | |   | TX        |         | |     | RX           |
        | +--->           |         | +----->              |
        +----->           |         +------->              |
              |           |                 |              |
              |           | <bus_name>      |              |
              |       out >=================> in           |
              |           | <bus_name>_stb  |              |
              |       out >-----------------> in           |
              |           | <bus_name>_ack  |              |
              |       in  <-----------------< out          |
              |           |                 |              |
              +-----------+                 +--------------+
 
Global Signals
--------------
 
+------+-----------+------+-------------+
| Name | Direction | Type | Description |
+------+-----------+------+-------------+
| clk  |   input   | bit  |    Clock    |
+------+-----------+------+-------------+
| rst  |   input   | bit  |    Reset    |
+------+-----------+------+-------------+

 
Interconnect Signals
--------------------

+----------------+-----------+------+-----------------------------------------------------------+
|      Name      | Direction | Type |                        Description                        |
+----------------+-----------+------+-----------------------------------------------------------+
|   <bus_name>   |  TX to RX | bus  |                        Payload Data                       |
+----------------+-----------+------+-----------------------------------------------------------+
| <bus_name>_stb |  TX to RX | bit  | '1' indicates that payload data is valid and TX is ready. |
+----------------+-----------+------+-----------------------------------------------------------+
| <bus_name>_ack |  TX to RX | bit  |              '1' indicates that RX is ready.              |
+----------------+-----------+------+-----------------------------------------------------------+

 
Interconnect Bus Transaction
----------------------------
 
1. Both transmitter and receiver **shall** be synchronised to the 0 to 1 transition of `clk`.
#. If `rst` is set to 1, upon the 0 to 1 transition of `clk` the transmitter **shall** terminate any active bus transaction and set `<bus_name>_stb` to 0.
#. If `rst` is set to 1, upon the 0 to 1 transition of `clk` the receiver **shall** terminate any active bus transaction and set `<bus_name>_ack` to 0.
#. If `rst` is set to 0, normal operation **shall** commence.
#. The transmitter **may** insert wait states on the bus by setting `<bus_name>_stb` to 0.
#. The transmitter **shall** set `<bus_name>_stb` to 1 to signify that data is valid.
#. Once `<bus_name>_stb` has been set to 1, it **shall** remain at 1 until the transaction completes.
#. The transmitter **shall** ensure that `<bus_name>` contains valid data for the entire period that `<bus_name>_stb` is 1.
#. The transmitter **may** set `<bus_name>` to any value when `<bus_name>_stb` is 0.
#. The receiver **may** insert wait states on the bus by setting `<bus_name>_ack` to 0.
#. The receiver **shall** set `<bus_name>_ack` to 1 to signify that it is ready to receive data.
#. Once `<bus_name>_ack` has been set to 1, it **shall** remain at 1 until the transaction completes.
#. Whenever `<bus_name>_stb` is 1 and `<bus_name>_ack` are 1, a bus transaction **shall** complete on the following 0 to 1 transition of `clk`.
#. Both the transmitter and receiver **may** commence a new transaction without inserting any wait states.
#. The receiver **may** delay a transaction by inserting wait states until the transmitter indicates that data is available.
#. The transmitter **shall** not delay a transaction by inserting wait states until the receiver is ready to accept data. Deadlock would occur if both the transmitter and receiver delayed a transaction until the other was ready.
 
::
 
         rst             ______________________________________________________________
                           _   _   _   _   _   _   _   _   _   _   _   _   _   _   _  
         clk             _| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_|
                         _____ _______ ________________________________________________
        <bus_name>       _____X_VALID_X________________________________________________
                               _______
        <bus_name>_stb   _____|       |________________________________________________
                                   ___
        <bus_name>_ack   _________|   |________________________________________________
         
                               ^^^^ RX adds wait states
         
                                   ^^^^  Data transfers
         
         rst             ______________________________________________________________
                           _   _   _   _   _   _   _   _   _   _   _   _   _   _   _  
         clk             _| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_|
                         _____ _______ ________________________________________________
        <bus_name>       _____X_VALID_X________________________________________________
                                   ___
        <bus_name>_stb   _________|   |________________________________________________
                               _______
        <bus_name>_ack   _____|       |________________________________________________
         
         
                               ^^^^ TX adds wait states
         
                                   ^^^^  Data transfers


         rst             ______________________________________________________________
                           __    __    __    __    __    __    __    __    __    __   _
         clk             _|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |_| 
         
                         _______ ___________ _____ _____ ______________________________
        <bus_name>       _______X_D0________X_D1__X_D2__X______________________________
                                       _________________
        <bus_name>_stb   _____________|                 |______________________________
                                 _______________________
        <bus_name>_ack   _______|                       |______________________________
         
                                ^^^^ TX adds wait states
         
                                       ^^^^  Data transfers
         
                                            ^^^^ stb and ack needn't return to 0 between data words

..
 
 
