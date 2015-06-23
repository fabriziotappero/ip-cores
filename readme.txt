Mango DSP Ltd. Copyright (C) 2006
Creator: Nachum Kanovsky

VHDL CPU Simulator

This is a work in progress, so please be patient.

Thanks go to Mango DSP Ltd. for allowing the release of this software to the open source community.

Description:
Perform the operations of a real CPU in a simulation environment.

Tested under:
Modelsim 6.1PE

Feature set:
Configuration of clock, and reset, and read latency.
Wait for time period
Wait for signal value (good for interrupts)
Declare local and global variables (bit, vector8, or string)
Nested while loops with separate variable space in each nesting
Nested if conditionals (no new variable space)
Unlimited number of threads
Print variables to a file (line by line)
Write a value or variable to an address
Read a value from an address and place in variable
Read using a DMA and writing values to a file

Thread control:
Each thread runs until it hits a wait or the end of the file. If no wait is hit, then it will continue to run and choke the system. There is no DMA write provided as the software supports only 0 latency writes such that consecutive writes in a while loop perform the DMA. See ctc.txt lines 24 - 36 for an example of this. All commands other than wait, read and write take 0 time. Only wait or wait_interruptX cause the thread switching.

Usage:
The provided design_top_tb.vhd uses the cpu_sim.vhd, package.vhd, and the accompanying text files to show some accesses. the file access_2us.txt shows a simple read occuring every 2 microseconds. The other text files are some examples of real world use, but they won't work as they are. They need to be modified for your design needs.

What can you do to help:
Any suggestions / patches should be sent to me at nachumk@opencores.org. If anyone wants to join the project, let me know.
