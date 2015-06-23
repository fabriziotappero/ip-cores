#!/bin/sh

#install veristruct on tanjobi
# run from top folder, and only on tanjobi!

sudo cp -r Verilog /sw/lib/perl5
sudo cp veristruct.pl /sw/bin/veristruct
sudo chmod 755 /sw/bin/veristruct

