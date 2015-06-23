Hi,

I was looking for a quick implementation of RC4 and I couldn't find one, so I wrote one based on the wikipedia example.

It's quite easy to use:

1) First, issue rst
2) Load the password byte-by-byte into the password_input port. The lenght of the password is KEY_SIZE
3) Issue 768 clocks to perform key expansion
4) Wait 1536 clocks while the module discards the first weak bytes of the stream as per RFC 4345.
5) Now you should start receiving the pseudo-random stream via the output bus, one byte every clock. The output_ready signal signals when a valid byte is present at the output K.
To encrypt or decrypt using RC4 you simply xor your data with the output stream.

WARNING: The 256-byte register that this implementation uses is very costly in FPGA resources and will result in >2000 slices used in some synthetizers.

The testbench and makefile work using icarus verilog and you can peer into rc4_tb.v to see an example implementation. 

After installing icarus verilog in your path, just issue:

make

and then

./rc4.vvp

And you should see the output of the simulation.

Any question or suggestion send an email to aortega@alu.itba.edu.ar, cc: alfred@groundworkstech.com

Cheers,

Alfredo


PS: This is licensed LGPL, not public domain or BSD, so you should, put a copy of the license in your software and stuff. Yes, I'm talking to you jhunjhun, you too have to do it.

