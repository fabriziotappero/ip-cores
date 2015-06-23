#!/usr/bin/env python

from chips.api.api import *
import sys


my_chip = Chip("interconnect")

wire = Wire(my_chip)
Component("producer.c")(my_chip, outputs={"z":wire})
Component("consumer.c")(my_chip, inputs={"a":wire})

my_chip.generate_verilog()
my_chip.generate_testbench()
