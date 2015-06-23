#!/usr/bin/env python

from chips.api.api import *
import sys


my_chip = Chip("interconnect")
wire = Wire(my_chip)
Component("test_suite/producer.c")(my_chip, inputs={}, outputs={"z":wire})
Component("test_suite/consumer.c")(my_chip, inputs={"a":wire}, outputs={})
my_chip.generate_verilog()
my_chip.generate_testbench(100000)
my_chip.compile_iverilog(True)

my_chip = Chip("interconnect")
wire = Wire(my_chip)
Component("test_suite/slow_producer.c")(my_chip, inputs={}, outputs={"z":wire})
Component("test_suite/consumer.c")(my_chip, inputs={"a":wire}, outputs={})
my_chip.generate_verilog()
my_chip.generate_testbench(100000)
my_chip.compile_iverilog(True)

my_chip = Chip("interconnect")
wire = Wire(my_chip)
Component("test_suite/producer.c")(my_chip, inputs={}, outputs={"z":wire})
Component("test_suite/slow_consumer.c")(my_chip, inputs={"a":wire}, outputs={})
my_chip.generate_verilog()
my_chip.generate_testbench(100000)
my_chip.compile_iverilog(True)

my_chip = Chip("interconnect")
wire = Wire(my_chip)
Component("test_suite/slow_producer.c")(my_chip, inputs={}, outputs={"z":wire})
Component("test_suite/slow_consumer.c")(my_chip, inputs={"a":wire}, outputs={})
my_chip.generate_verilog()
my_chip.generate_testbench(100000)
my_chip.compile_iverilog(True)

os.remove("producer.v")
os.remove("consumer.v")
os.remove("interconnect_tb")
os.remove("interconnect.v")
os.remove("interconnect_tb.v")
