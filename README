Open Source Documented Verilog UART
Published under the terms of the MIT licence. See LICENCE for licensing information.

== Purpose ==

This module was created as a result of my own need for a UART (serial line I/O) component and frustration at the difficulty of integrating the existing available components in to my own project. All the open source UART modules I found were either difficult to interface with, usually due to being more clever than I wanted them to be and had poor documentation for their interfaces. They were also generally written in VHDL, which since I've never written VHDL made it a little difficult to read to work out the interfacing issues for myself. The frustration of finding such a simple component so hard to use prompted the decision to create my own, and document it for beginners like myself.

I hope that this module will be documented to a better standard than most I've come across. Please send me email at tim@goddard.net.nz if you have trouble understanding it. Improvements are also welcome.

== What would I use this for? ==

A UART is a useful component for controlling asynchronous (without a separate clock line) serial buses. It can be used via a level converter to talk to the RS232 serial port of a computer. This is not, however, the only application. It could also be used as a local chip bus, or with differential signalling to connect to peripherals over quite long distances.

== I/O Standards, Compatability ==

This follows standard UART signalling methods with the following properties:

* Expects to send and receive data as 8 data bits, no parity bits.
* Default baud rate is 9600 with a 50MHz clock. This is configurable.
* Samples values roughly in the middle of each bit (may drift slightly).
* Sends and receives least significant bit first.
* Expects to receive at least 1 stop bit. Will not check for more, but won't fail either.
* Transmits 2 stop bits.

== Usage ==

The UART component can be included in your application like this:

 uart MyInstanceName (clk, rst, rx, tx, transmit, tx_byte, received, rx_byte, is_receiving, is_transmitting, recv_error);

These are the lines and what they each need to be connected to:

* "clk" is the master clock for this component.
  By default this will run at 9600 baud with a clock of 50MHz, but this can be altered as described in the "Adjusting Clock Rate / Baud Rate" section below.

* "rst" is a synchronous reset line (resets if high when the rising edge of clk arrives).
  Raising this high for one cycle of clk will interrupt any transmissions in progress and set it back to an idle state. Doing this unneccessarily is not recommended - the receive component could become confused if reset halfway through a transmission. This can be unconnected if you don't need to reset the component.

* "rx" is the serial line which the component will receive data on.
  This would usually be connected to an outside pin.

* "tx" is the serial line which the component will transmit data on.
  This would usually be connected to an outside pin.

* The input flag "transmit" is a signal you use to indicate that the UART should start a transmission.
  If the transmit line is idle and this is raised for one clock cycle, the component will copy the content of the tx_byte input and start transmitting it. If raised while the line is busy, this signal will be ignored. The is_transmitting output mentioned later can be used to test this and avoid missing a byte.

* The input "tx_byte" is an 8-bit bus containing the byte to be transmitted when "transmit" is raised high.
  When "transmit" is low, this may change without interrupting the transfer.

* "received" is an output flag which is raised high for one cycle of clk when a byte is received.

* The output "rx_data" is set to the value of the byte which has just been received when "received" is raised.
  It is recommended that this be used immediately in the cycle when "raised" is high or saved in to a register for future use. While this is likely to remain accurate until the start of the next incoming byte arrives, this should not be relied on.

* The output "is_receiving" indicates that we are currently receiving data on the rx line.
  This could be used for example to provide an early warning that a byte may be about to be received. When this signal is true, it will not become false again until either "received" or "recv_error" has been asserted. If you don't need early warning, this can safely be left disconnected.

* The output "is_transmitting" indicates that we are currently sending data on the tx line.
  This is often important to track, because we can only send one byte at once. If we need to send another byte and this is high, the code outside will have to wait until this goes low before it can begin. This can be ignored if you know that you will never try to transmit while another transmission is in progress, for example when transmissions happen at fixed intervals longer than the time it takes to transmit a packet (11 bit periods - just under 1.2ms at 9600 baud) .

* recv_error is an output indicating that a malformed or incomplete byte was received.
  If you simply wish to ignore bad incoming bytes, you can safely leave this signal disconnected.

With "rst", "is_receiving" and "recv_error" disconnected, the invocation would look like:

 uart MyInstanceName (clk, , rx, tx, transmit, tx_byte, received, rx_byte, , is_transmitting, );

== Adjusting Clock Rate / Baud Rate ==

The clock rate and baud rate can be altered by changing the CLOCK_DIVIDE parameter passed in to the uart module. This value is calculated by taking the clock frequency in Hz (for example, 50MHz is 50,000,000 Hz), dividing it by the baud rate times 4 (for example 9600)

CLOCK_DIVIDE = Frequency(clk) / (4 * Baud)

In the example given, the resulting constant is 50000000 / (4 * 9600) = 1302 . This is the value that the module has by default. To create a UART running at a different rate, insert the CLOCK_DIVIDE value in to the initialisation like:

uart #(.CLOCK_DIVIDE( 1302 )) MyInstanceName (clk, ...);

