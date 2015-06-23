#!/usr/bin/env python
"""A C to Verilog compiler"""

__author__ = "Jon Dawson"
__copyright__ = "Copyright (C) 2013, Jonathan P Dawson"
__version__ = "0.1"

import sys
import os

from chips.compiler.parser import Parser
from chips.compiler.exceptions import C2CHIPError
from chips.compiler.optimizer import parallelise
from chips.compiler.optimizer import cleanup_functions
from chips.compiler.optimizer import cleanup_registers
from chips.compiler.tokens import Tokens
from chips.compiler.verilog_speed import generate_CHIP as generate_CHIP_speed
from chips.compiler.verilog_area import generate_CHIP as generate_CHIP_area

def comp(input_file, options=[]):

    reuse = "no_reuse" not in options
    initialize_memory = "no_initialize_memory" not in options

    try:
        if "speed" not in options:

            #Optimize for area
            parser = Parser(input_file, reuse, initialize_memory)
            process = parser.parse_process()
            name = process.main.name
            instructions = process.generate()
            instructions = cleanup_functions(instructions)
            instructions, registers = cleanup_registers(instructions, parser.allocator.all_registers)
            output_file = name + ".v"
            output_file = open(output_file, "w")
            inputs, outputs = generate_CHIP_area(
                    input_file,
                    name,
                    instructions,
                    output_file,
                    registers,
                    parser.allocator.memory_size_2,
                    parser.allocator.memory_size_4,
                    initialize_memory,
                    parser.allocator.memory_content_2,
                    parser.allocator.memory_content_4)
            output_file.close()

        else:

            #Optimize for speed
            parser = Parser(input_file, reuse, initialize_memory)
            process = parser.parse_process()
            name = process.main.name
            instructions = process.generate()
            instructions = cleanup_functions(instructions)
            instructions, registers = cleanup_registers(instructions, parser.allocator.all_registers)
            if "no_concurrent" in sys.argv:
                frames = [[i] for i in instructions]
            else:
                frames = parallelise(instructions)
            output_file = name + ".v"
            output_file = open(output_file, "w")
            inputs, outputs = generate_CHIP_speed(
                    input_file,
                    name,
                    frames,
                    output_file,
                    registers,
                    parser.allocator.memory_size_2,
                    parser.allocator.memory_size_4,
                    initialize_memory,
                    parser.allocator.memory_content_2,
                    parser.allocator.memory_content_4)
            output_file.close()

    except C2CHIPError as err:
        print "Error in file:", err.filename, "at line:", err.lineno
        print err.message
        sys.exit(-1)


    return name, inputs, outputs, ""
