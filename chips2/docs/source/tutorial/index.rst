Tutorial
========

Create and Test a C component 
-----------------------------

Why not start with a simple example. With your favourite text editor, create a
file count.c and add the following::
        
        void count(){
                for(i=1; i<=10; i++){
                        report(i);
                }
        }

You can convert C components into Verilog components using the C2Verilog
compiler. The *iverilog* option causes the generated Verilog component to be
compiled using Icarus Verilog. The *run* option causes simulation to be run::

        ~$ c2verilog iverilog run test.c
        1
        2
        3
        4
        5
        6
        7
        8
        9
        10

When a design is reset, execution starts with the last function defined in
the C file. This need not be called *main*. The name of the last function
will be used as the name for the generated Verilog component. The C program will
appear to execute in sequence, although the compiler may execute instructions
concurrently if it does not affect the outcome of the program. This will allow
your component to take advantage of the inherent parallelism present in a hardware
design.

The *report* function is a *built-in* function which is helpful for debug, it
will print the value of a variable on the console during simulations, when you
synthesise the design it will be ignored.

This component doesn't have any inputs or outputs, so it isn't going to be very
useful in a real design. You can add inputs and outputs to a components using
function calls with special names. Functions that start with the name *input_*
or *output_* are interpreted as inputs, or outputs respectively.

::

        int temp;
        temp = input_spam(); //reads from an input called spam
        temp = input_eggs(); //reads from an input called eggs
        output_fish(temp);   //writes to an output called fish


Reading or writing from inputs and outputs causes program execution to block
until data is available. This synchronises data transfers with other components
executing in the same device, this method of passing data between concurrent
processes is much simpler than the mutex/lock/semaphore mechanisms used in
multithreaded applications.

If you don't want to commit yourself to reading and input and blocking
execution, you can check if data is ready::

        int temp;
        if(ready_spam()){
                temp = input_spam();
        }

There is no equivalent function to check if an output is ready to receive data,
this could cause deadlocks if both the sending and receiving end were waiting
for one another.

We can now construct some basic hardware components quite simply. Here's a counter for instance::

        void counter(){
                while(1){
                        for(i=1; i<=10; i++){
                                output_out(i);
                        }
                }
        }

We can generate an adder like this::

        void added(){
                while(1){
                        output_z(input_a()+input_b());
                }
        }

Or a divider like this (yes, you can synthesise division)::

        void divider(){
                while(1){
                        output_z(input_a()/input_b());
                }
        }

We can split a stream of data into two identical data streams using a tee function::

        void tee(){
                int temp;
                while(1){
                        temp = input_a();
                        output_y(temp);
                        output_z(temp);
                }
        }

If we want to merge two streams of data, we could interlace them::

        void interlace(){
                int temp;
                while(1){
                        temp = input_a();
                        output_z(temp);
                        temp = input_b();
                        output_z(temp);
                }
        }

or we could prioritise one stream over the other::

        void arbiter(){
                int temp;
                while(1){
                        if( ready_a() ){
                                temp = input_a();
                                output_z(temp);
                        } else if( ready_b() ){
                                temp = input_b();
                                output_z(temp);
                        }
                }
        }

