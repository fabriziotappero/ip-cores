#!/bin/sh
iverilog tb.v ../rtl/verilog/*.v -I ../rtl/verilog -o p6809.out
vvp p6809.out