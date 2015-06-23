#!/usr/bin/env python
"""A C to Verilog compiler"""

__author__ = "Jon Dawson"
__copyright__ = "Copyright (C) 2013, Jonathan P Dawson"
__version__ = "0.1"

import fpu

def unique(l):

    """In the absence of set in older python implementations, make list values unique"""

    return dict(zip(l, l)).keys()

def log2(frames):

    """Integer only algorithm to calculate the number of bits needed to store a number"""

    bits = 1
    power = 2
    while power < frames:
        bits += 1
        power *= 2
    return bits

def to_gray(i):

    """Convert integer to gray code"""

    return (i >> 1) ^ i

def sign_extend(value, bytes_):
    bits = bytes_*8
    mask = (1<<bits)-1
    mask = ~mask
    if value & 1<<(bits-1):
        return value | mask
    else:
        return value


def floating_point_enables(frames):
    enable_adder = False
    enable_multiplier = False
    enable_divider = False
    enable_int_to_float = False
    enable_float_to_int = False
    for frame in frames:
        for i in frame:
            if i["op"] == "+" and "type" in i and i["type"] == "float":
                enable_adder = True
            if i["op"] == "-" and "type" in i and i["type"] == "float":
                enable_adder = True
            if i["op"] == "*" and "type" in i and i["type"] == "float":
                enable_multiplier = True
            if i["op"] == "/" and "type" in i and i["type"] == "float":
                enable_divider = True
            if i["op"] == "int_to_float":
                enable_int_to_float = True
            if i["op"] == "float_to_int":
                enable_float_to_int = True
    return (
        enable_adder, 
        enable_multiplier, 
        enable_divider, 
        enable_int_to_float, 
        enable_float_to_int)


def generate_CHIP(input_file,
                  name,
                  frames,
                  output_file,
                  registers,
                  memory_size_2,
                  memory_size_4,
                  initialize_memory,
                  memory_content_2,
                  memory_content_4,
                  no_tb_mode=False):

    """A big ugly function to crunch through all the instructions and generate the CHIP equivilent"""

    #calculate the values of jump locations
    location = 0
    labels = {}
    new_frames = []
    for frame in frames:
        if frame[0]["op"] == "label":
            labels[frame[0]["label"]] = location
        else:
            new_frames.append(frame)
            location += 1
    frames = new_frames

    #substitue real values for labeled jump locations
    for frame in frames:
        for instruction in frame:
            if "label" in instruction:
                instruction["label"]=labels[instruction["label"]]

    #list all inputs and outputs used in the program
    inputs = unique([i["input"] for frame in frames for i in frame if "input" in i])
    outputs = unique([i["output"] for frame in frames for i in frame if "output" in i])
    input_files = unique([i["file_name"] for frame in frames for i in frame if "file_read" == i["op"]])
    output_files = unique([i["file_name"] for frame in frames for i in frame if "file_write" == i["op"]])
    testbench = not inputs and not outputs and not no_tb_mode
    enable_adder, enable_multiplier, enable_divider, enable_int_to_float, enable_float_to_int = floating_point_enables(frames)

    #Do not generate a port in testbench mode
    inports = [
      ("input_" + i, 16) for i in inputs
    ] + [
      ("input_" + i + "_stb", 1) for i in inputs
    ] + [
      ("output_" + i + "_ack", 1) for i in outputs
    ]

    outports = [
      ("output_" + i, 16) for i in outputs
    ] + [
      ("output_" + i + "_stb", 1) for i in outputs
    ] + [
      ("input_" + i + "_ack", 1) for i in inputs
    ]

    #create list of signals
    signals = [
      ("timer", 16),
      ("program_counter", log2(len(frames))),
      ("address_2", 16),
      ("data_out_2", 16),
      ("data_in_2", 16),
      ("write_enable_2", 1),
      ("address_4", 16),
      ("data_out_4", 32),
      ("data_in_4", 32),
      ("write_enable_4", 1),
    ] + [
      ("register_%s"%(register), definition[1]*8) for register, definition in registers.iteritems()
    ] + [
      ("s_output_" + i + "_stb", 16) for i in outputs
    ] + [
      ("s_output_" + i, 16) for i in outputs
    ] + [
      ("s_input_" + i + "_ack", 16) for i in inputs
    ]

    if testbench:
        signals.append(("clk", 1))
        signals.append(("rst", 1))
    else:
        inports.append(("clk", 1))
        inports.append(("rst", 1))

    if enable_adder:
        output_file.write(fpu.adder)
    if enable_divider:
        output_file.write(fpu.divider)
    if enable_multiplier:
        output_file.write(fpu.multiplier)
    if enable_int_to_float:
        output_file.write(fpu.int_to_float)
    if enable_float_to_int:
        output_file.write(fpu.float_to_int)

    #output the code in verilog
    output_file.write("//name : %s\n"%name)
    output_file.write("//tag : c components\n")
    for i in inputs:
        output_file.write("//input : input_%s:16\n"%i)
    for i in outputs:
        output_file.write("//output : output_%s:16\n"%i)
    output_file.write("//source_file : %s\n"%input_file)
    output_file.write("///%s\n"%"".join(["=" for i in name]))
    output_file.write("///\n")
    output_file.write("///*Created by C2CHIP*\n\n")


    output_file.write("// Register Allocation\n")
    output_file.write("// ===================\n")
    output_file.write("//   %s   %s   %s  \n"%("Register".center(20), "Name".center(20), "Size".center(20)))
    for register, definition in registers.iteritems():
        register_name, size = definition
        output_file.write("//   %s   %s   %s  \n"%(str(register).center(20), register_name.center(20), str(size).center(20)))

    output_file.write("  \n`timescale 1ns/1ps\n")
    output_file.write("module %s"%name)

    all_ports = [name for name, size in inports + outports]
    if all_ports:
        output_file.write("(")
        output_file.write(",".join(all_ports))
        output_file.write(");\n")
    else:
        output_file.write(";\n")

    output_file.write("  integer file_count;\n")

    if enable_adder:
        generate_adder_signals(output_file)
    if enable_multiplier:
        generate_multiplier_signals(output_file)
    if enable_divider:
        generate_divider_signals(output_file)
    if enable_int_to_float:
        generate_int_to_float_signals(output_file)
    if enable_float_to_int:
        generate_float_to_int_signals(output_file)
    output_file.write("  real fp_value;\n")

    if enable_adder or enable_multiplier or enable_divider or enable_int_to_float or enable_float_to_int:
        output_file.write("  parameter wait_go = 3'd0,\n")
        output_file.write("            write_a = 3'd1,\n")
        output_file.write("            write_b = 3'd2,\n")
        output_file.write("            read_z  = 3'd3,\n")
        output_file.write("         wait_next  = 3'd4;\n")

    input_files = dict(zip(input_files, ["input_file_%s"%i for i, j in enumerate(input_files)]))
    for i in input_files.values():
        output_file.write("  integer %s;\n"%i)

    output_files = dict(zip(output_files, ["output_file_%s"%i for i, j in enumerate(output_files)]))
    for i in output_files.values():
        output_file.write("  integer %s;\n"%i)

    def write_declaration(object_type, name, size, value=None):
        if size == 1:
            output_file.write(object_type)
            output_file.write(name)
            if value is not None:
                output_file.write("= %s'd%s"%(size,value))
            output_file.write(";\n")
        else:
            output_file.write(object_type)
            output_file.write("[%i:0]"%(size-1))
            output_file.write(" ")
            output_file.write(name)
            if value is not None:
                output_file.write("= %s'd%s"%(size,value))
            output_file.write(";\n")

    for name, size in inports:
        write_declaration("  input     ", name, size)

    for name, size in outports:
        write_declaration("  output    ", name, size)

    for name, size in signals:
        write_declaration("  reg       ", name, size)

    memory_size_2 = int(memory_size_2)
    memory_size_4 = int(memory_size_4)
    if memory_size_2:
        output_file.write("  reg [15:0] memory_2 [%i:0];\n"%(memory_size_2-1))
    if memory_size_4:
        output_file.write("  reg [31:0] memory_4 [%i:0];\n"%(memory_size_4-1))

    #generate clock and reset in testbench mode
    if testbench:

        output_file.write("\n  //////////////////////////////////////////////////////////////////////////////\n")
        output_file.write("  // CLOCK AND RESET GENERATION                                                 \n")
        output_file.write("  //                                                                            \n")
        output_file.write("  // This file was generated in test bench mode. In this mode, the verilog      \n")
        output_file.write("  // output file can be executed directly within a verilog simulator.           \n")
        output_file.write("  // In test bench mode, a simulated clock and reset signal are generated within\n")
        output_file.write("  // the output file.                                                           \n")
        output_file.write("  // Verilog files generated in testbecnch mode are not suitable for synthesis, \n")
        output_file.write("  // or for instantiation within a larger design.\n")

        output_file.write("  \n  initial\n")
        output_file.write("  begin\n")
        output_file.write("    rst <= 1'b1;\n")
        output_file.write("    #50 rst <= 1'b0;\n")
        output_file.write("  end\n\n")

        output_file.write("  \n  initial\n")
        output_file.write("  begin\n")
        output_file.write("    clk <= 1'b0;\n")
        output_file.write("    while (1) begin\n")
        output_file.write("      #5 clk <= ~clk;\n")
        output_file.write("    end\n")
        output_file.write("  end\n\n")

    #Instance Floating Point Arithmetic
    if enable_adder or enable_multiplier or enable_divider or enable_int_to_float or enable_float_to_int:

        output_file.write("\n  //////////////////////////////////////////////////////////////////////////////\n")
        output_file.write("  // Floating Point Arithmetic                                                  \n")
        output_file.write("  //                                                                            \n")
        output_file.write("  // Generate IEEE 754 single precision divider, adder and multiplier           \n")
        output_file.write("  //                                                                            \n")

        if enable_divider:
            connect_divider(output_file)
        if enable_multiplier:
            connect_multiplier(output_file)
        if enable_adder:
            connect_adder(output_file)
        if enable_int_to_float:
            connect_int_to_float(output_file)
        if enable_float_to_int:
            connect_float_to_int(output_file)

    #Generate a state machine to execute the instructions
    binary_operators = ["+", "-", "*", "/", "|", "&", "^", "<<", ">>", "<",">", ">=",
      "<=", "==", "!="]


    if initialize_memory and (memory_content_2 or memory_content_4):

        output_file.write("\n  //////////////////////////////////////////////////////////////////////////////\n")
        output_file.write("  // MEMORY INITIALIZATION                                                      \n")
        output_file.write("  //                                                                            \n")
        output_file.write("  // In order to reduce program size, array contents have been stored into      \n")
        output_file.write("  // memory at initialization. In an FPGA, this will result in the memory being \n")
        output_file.write("  // initialized when the FPGA configures.                                      \n")
        output_file.write("  // Memory will not be re-initialized at reset.                                \n")
        output_file.write("  // Dissable this behaviour using the no_initialize_memory switch              \n")

        output_file.write("  \n  initial\n")
        output_file.write("  begin\n")
        for location, content in memory_content_2.iteritems():
            output_file.write("    memory_2[%s] = %s;\n"%(location, content))
        for location, content in memory_content_4.iteritems():
            output_file.write("    memory_4[%s] = %s;\n"%(location, content))
        output_file.write("  end\n\n")

    if input_files or output_files:

        output_file.write("\n  //////////////////////////////////////////////////////////////////////////////\n")
        output_file.write("  // OPEN FILES                                                                 \n")
        output_file.write("  //                                                                            \n")
        output_file.write("  // Open all files used at the start of the process                            \n")

        output_file.write("  \n  initial\n")
        output_file.write("  begin\n")
        for file_name, file_ in input_files.iteritems():
            output_file.write("    %s = $fopenr(\"%s\");\n"%(file_, file_name))
        for file_name, file_ in output_files.iteritems():
            output_file.write("    %s = $fopen(\"%s\");\n"%(file_, file_name))
        output_file.write("  end\n\n")

    output_file.write("\n  //////////////////////////////////////////////////////////////////////////////\n")
    output_file.write("  // FSM IMPLEMENTAION OF C PROCESS                                             \n")
    output_file.write("  //                                                                            \n")
    output_file.write("  // This section of the file contains a Finite State Machine (FSM) implementing\n")
    output_file.write("  // the C process. In general execution is sequential, but the compiler will   \n")
    output_file.write("  // attempt to execute instructions in parallel if the instruction dependencies\n")
    output_file.write("  // allow. Further concurrency can be achieved by executing multiple C         \n")
    output_file.write("  // processes concurrently within the device.                                  \n")

    output_file.write("  \n  always @(posedge clk)\n")
    output_file.write("  begin\n\n")

    if memory_size_2:
        output_file.write("    //implement memory for 2 byte x n arrays\n")
        output_file.write("    if (write_enable_2 == 1'b1) begin\n")
        output_file.write("      memory_2[address_2] <= data_in_2;\n")
        output_file.write("    end\n")
        output_file.write("    data_out_2 <= memory_2[address_2];\n")
        output_file.write("    write_enable_2 <= 1'b0;\n\n")

    if memory_size_4:
        output_file.write("    //implement memory for 4 byte x n arrays\n")
        output_file.write("    if (write_enable_4 == 1'b1) begin\n")
        output_file.write("      memory_4[address_4] <= data_in_4;\n")
        output_file.write("    end\n")
        output_file.write("    data_out_4 <= memory_4[address_4];\n")
        output_file.write("    write_enable_4 <= 1'b0;\n\n")

    output_file.write("    //implement timer\n")
    output_file.write("    timer <= 16'h0000;\n\n")
    output_file.write("    case(program_counter)\n\n")

    #A frame is executed in each state
    for location, frame in enumerate(frames):
        output_file.write("      16'd%s:\n"%to_gray(location))
        output_file.write("      begin\n")
        output_file.write("        program_counter <= 16'd%s;\n"%to_gray(location+1))
        for instruction in frame:

            if instruction["op"] == "literal":
                output_file.write(
                  "        register_%s <= %s;\n"%(
                  instruction["dest"],
                  instruction["literal"]))

            elif instruction["op"] == "move":
                output_file.write(
                  "        register_%s <= register_%s;\n"%(
                  instruction["dest"],
                  instruction["src"]))

            elif instruction["op"] in ["~"]:
                output_file.write(
                  "        register_%s <= ~register_%s;\n"%(
                  instruction["dest"],
                  instruction["src"]))

            elif instruction["op"] in ["int_to_float"]:
                output_file.write("        int_to <= register_%s;\n"%(instruction["src"]))
                output_file.write("        register_%s <= to_float;\n"%(instruction["dest"]))
                output_file.write("        program_counter <= %s;\n"%to_gray(location))
                output_file.write("        int_to_float_go <= 1;\n")
                output_file.write("        if (int_to_float_done) begin\n")
                output_file.write("          int_to_float_go <= 0;\n")
                output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                output_file.write("        end\n")

            elif instruction["op"] in ["float_to_int"]:
                output_file.write("        float_to <= register_%s;\n"%(instruction["src"]))
                output_file.write("        register_%s <= to_int;\n"%(instruction["dest"]))
                output_file.write("        program_counter <= %s;\n"%to_gray(location))
                output_file.write("        float_to_int_go <= 1;\n")
                output_file.write("        if (float_to_int_done) begin\n")
                output_file.write("          float_to_int_go <= 0;\n")
                output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                output_file.write("        end\n")

            elif instruction["op"] in binary_operators and "left" in instruction:
                if ("type" in instruction and 
                    instruction["type"] == "float" and 
                    instruction["op"] in ["+", "-", "*", "/"]):

                    if instruction["op"] == "+":
                        output_file.write("        adder_a <= %s;\n"%(instruction["left"]))
                        output_file.write("        adder_b <= register_%s;\n"%(instruction["src"]))
                        output_file.write("        register_%s <= adder_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        adder_go <= 1;\n")
                        output_file.write("        if (adder_done) begin\n")
                        output_file.write("          adder_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")
                    if instruction["op"] == "-":
                        output_file.write("        adder_a <= %s;\n"%(instruction["left"]))
                        output_file.write("        adder_b <= {~register_%s[31], register_%s[30:0]};\n"%(
                            instruction["src"],
                            instruction["src"]))
                        output_file.write("        register_%s <= adder_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        adder_go <= 1;\n")
                        output_file.write( "       if (adder_done) begin\n")
                        output_file.write("          adder_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")
                    elif instruction["op"] == "*":
                        output_file.write("        multiplier_a <= %s;\n"%(instruction["left"]))
                        output_file.write("        multiplier_b <= register_%s;\n"%(instruction["src"]))
                        output_file.write("        register_%s <= multiplier_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        multiplier_go <= 1;\n")
                        output_file.write( "       if (multiplier_done) begin\n")
                        output_file.write("          multiplier_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")
                    elif instruction["op"] == "/":
                        output_file.write("        divider_a <= %s;\n"%(instruction["left"]))
                        output_file.write("        divider_b <= register_%s;\n"%(instruction["src"]))
                        output_file.write("        register_%s <= divider_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        divider_go <= 1;\n")
                        output_file.write("        if (divider_done) begin\n")
                        output_file.write("          divider_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")
                elif not instruction["signed"]:
                    output_file.write(
                      "        register_%s <= %s %s $unsigned(register_%s);\n"%(
                      instruction["dest"],
                      instruction["left"],
                      instruction["op"],
                      instruction["src"]))
                else:
                    #Verilog uses >>> as an arithmetic right shift
                    if instruction["op"] == ">>":
                        instruction["op"] = ">>>"
                    output_file.write(
                      "        register_%s <= %s %s $signed(register_%s);\n"%(
                      instruction["dest"],
                      sign_extend(instruction["left"], instruction["size"]),
                      instruction["op"],
                      instruction["src"]))

            elif instruction["op"] in binary_operators and "right" in instruction:
                if ("type" in instruction and 
                    instruction["type"] == "float" and 
                    instruction["op"] in ["+", "-", "*", "/"]):

                    if instruction["op"] == "+":
                        output_file.write("        adder_b <= %s;\n"%(instruction["right"]))
                        output_file.write("        adder_a <= register_%s;\n"%(instruction["src"]))
                        output_file.write("        register_%s <= adder_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        adder_go <= 1;\n")
                        output_file.write("        if (adder_done) begin\n")
                        output_file.write("          adder_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")
                    if instruction["op"] == "-":
                        output_file.write("        adder_b <= %s;\n"%(
                            instruction["right"] ^ 0x80000000))
                        output_file.write("        adder_a <= register_%s;\n"%(
                            instruction["src"]))
                        output_file.write("        register_%s <= adder_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        adder_go <= 1;\n")
                        output_file.write("        if (adder_done) begin\n")
                        output_file.write("          adder_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")
                    elif instruction["op"] == "*":
                        output_file.write("        multiplier_b <= %s;\n"%(instruction["right"]))
                        output_file.write("        multiplier_a <= register_%s;\n"%(instruction["src"]))
                        output_file.write("        register_%s <= multiplier_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        multiplier_go <= 1;\n")
                        output_file.write("        if (multiplier_done) begin\n")
                        output_file.write("          multiplier_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")
                    elif instruction["op"] == "/":
                        output_file.write("        divider_b <= %s;\n"%(instruction["right"]))
                        output_file.write("        divider_a <= register_%s;\n"%(instruction["src"]))
                        output_file.write("        register_%s <= divider_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        divider_go <= 1;\n")
                        output_file.write("        if (divider_done) begin\n")
                        output_file.write("          divider_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")

                elif not instruction["signed"]:
                    output_file.write(
                      "        register_%s <= $unsigned(register_%s) %s %s;\n"%(
                      instruction["dest"],
                      instruction["src"],
                      instruction["op"],
                      instruction["right"]))
                else:
                    #Verilog uses >>> as an arithmetic right shift
                    if instruction["op"] == ">>":
                        instruction["op"] = ">>>"
                    output_file.write(
                      "        register_%s <= $signed(register_%s) %s %s;\n"%(
                      instruction["dest"],
                      instruction["src"],
                      instruction["op"],
                      sign_extend(instruction["right"], instruction["size"])))

            elif instruction["op"] in binary_operators:
                if ("type" in instruction and 
                    instruction["type"] == "float" and 
                    instruction["op"] in ["+", "-", "*", "/"]):

                    if instruction["op"] == "+":
                        output_file.write("        adder_a <= register_%s;\n"%(instruction["src"]))
                        output_file.write("        adder_b <= register_%s;\n"%(instruction["srcb"]))
                        output_file.write("        register_%s <= adder_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        adder_go <= 1;\n")
                        output_file.write("        if (adder_done) begin\n")
                        output_file.write("          adder_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")
                    if instruction["op"] == "-":
                        output_file.write("        adder_a <= register_%s;\n"%(instruction["src"]))
                        output_file.write("        adder_b <= {~register_%s[31], register_%s[30:0]};\n"%(
                            instruction["srcb"],
                            instruction["srcb"]))
                        output_file.write("        register_%s <= adder_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        adder_go <= 1;\n")
                        output_file.write("        if (adder_done) begin\n")
                        output_file.write("          adder_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")
                    elif instruction["op"] == "*":
                        output_file.write("        multiplier_a <= register_%s;\n"%(instruction["src"]))
                        output_file.write("        multiplier_b <= register_%s;\n"%(instruction["srcb"]))
                        output_file.write("        register_%s <= multiplier_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        multiplier_go <= 1;\n")
                        output_file.write("        if (multiplier_done) begin\n")
                        output_file.write("          multiplier_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")
                    elif instruction["op"] == "/":
                        output_file.write("        divider_a <= register_%s;\n"%(instruction["src"]))
                        output_file.write("        divider_b <= register_%s;\n"%(instruction["srcb"]))
                        output_file.write("        register_%s <= divider_z;\n"%(instruction["dest"]))
                        output_file.write("        program_counter <= %s;\n"%to_gray(location))
                        output_file.write("        divider_go <= 1;\n")
                        output_file.write("        if (divider_done) begin\n")
                        output_file.write("          divider_go <= 0;\n")
                        output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                        output_file.write("        end\n")

                elif not instruction["signed"]:
                    output_file.write(
                      "        register_%s <= $unsigned(register_%s) %s $unsigned(register_%s);\n"%(
                      instruction["dest"],
                      instruction["src"],
                      instruction["op"],
                      instruction["srcb"]))
                else:
                    #Verilog uses >>> as an arithmetic right shift
                    if instruction["op"] == ">>":
                        instruction["op"] = ">>>"
                    output_file.write(
                      "        register_%s <= $signed(register_%s) %s $signed(register_%s);\n"%(
                      instruction["dest"],
                      instruction["src"],
                      instruction["op"],
                      instruction["srcb"]))

            elif instruction["op"] == "jmp_if_false":
                output_file.write("        if (register_%s == 0)\n"%(instruction["src"]));
                output_file.write("          program_counter <= %s;\n"%to_gray(instruction["label"]&0xffff))

            elif instruction["op"] == "jmp_if_true":
                output_file.write("        if (register_%s != 0)\n"%(instruction["src"]));
                output_file.write("          program_counter <= 16'd%s;\n"%to_gray(instruction["label"]&0xffff))

            elif instruction["op"] == "jmp_and_link":
                output_file.write("        program_counter <= 16'd%s;\n"%to_gray(instruction["label"]&0xffff))
                output_file.write("        register_%s <= 16'd%s;\n"%(
                  instruction["dest"], to_gray((location+1)&0xffff)))

            elif instruction["op"] == "jmp_to_reg":
                output_file.write(
                  "        program_counter <= register_%s;\n"%instruction["src"])

            elif instruction["op"] == "goto":
                output_file.write("        program_counter <= 16'd%s;\n"%(to_gray(instruction["label"]&0xffff)))

            elif instruction["op"] == "file_read":
                output_file.write("        file_count = $fscanf(%s, \"%%d\\n\", register_%s);\n"%(
                  input_files[instruction["file_name"]], instruction["dest"]))

            elif instruction["op"] == "file_write":
                if instruction["type"] == "float":
                    output_file.write('        fp_value = (register_%s[31]?-1.0:1.0) *\n'%instruction["src"])
                    output_file.write('            (2.0 ** (register_%s[30:23]-127.0)) *\n'%instruction["src"])
                    output_file.write('            ({1\'d1, register_%s[22:0]} / (2.0**23));\n'%instruction["src"])

                    output_file.write('        $fdisplay(%s, fp_value);\n'%(
                      output_files[instruction["file_name"]]))
                else:
                    output_file.write("        $fdisplay(%s, \"%%d\", register_%s);\n"%(
                      output_files[instruction["file_name"]], instruction["src"]))

            elif instruction["op"] == "read":
                output_file.write("        register_%s <= input_%s;\n"%(
                  instruction["dest"], instruction["input"]))
                output_file.write("        program_counter <= %s;\n"%to_gray(location))
                output_file.write("        s_input_%s_ack <= 1'b1;\n"%instruction["input"])
                output_file.write( "       if (s_input_%s_ack == 1'b1 && input_%s_stb == 1'b1) begin\n"%(
                  instruction["input"],
                  instruction["input"]
                ))
                output_file.write("          s_input_%s_ack <= 1'b0;\n"%instruction["input"])
                output_file.write("          program_counter <= 16'd%s;\n"%to_gray(location+1))
                output_file.write("        end\n")

            elif instruction["op"] == "ready":
                output_file.write("        register_%s <= 0;\n"%instruction["dest"])
                output_file.write("        register_%s[0] <= input_%s_stb;\n"%(
                  instruction["dest"], instruction["input"]))

            elif instruction["op"] == "write":
                output_file.write("        s_output_%s <= register_%s;\n"%(
                  instruction["output"], instruction["src"]))
                output_file.write("        program_counter <= %s;\n"%to_gray(location))
                output_file.write("        s_output_%s_stb <= 1'b1;\n"%instruction["output"])
                output_file.write(
                  "        if (s_output_%s_stb == 1'b1 && output_%s_ack == 1'b1) begin\n"%(
                  instruction["output"],
                  instruction["output"]
                ))
                output_file.write("          s_output_%s_stb <= 1'b0;\n"%instruction["output"])
                output_file.write("          program_counter <= %s;\n"%to_gray(location+1))
                output_file.write("        end\n")

            elif instruction["op"] == "memory_read_request":
                output_file.write(
                  "        address_%s <= register_%s;\n"%(
                      instruction["element_size"],
                      instruction["src"]))

            elif instruction["op"] == "memory_read_wait":
                pass

            elif instruction["op"] == "memory_read":
                output_file.write(
                  "        register_%s <= data_out_%s;\n"%(
                      instruction["dest"],
                      instruction["element_size"]))

            elif instruction["op"] == "memory_write":
                output_file.write("        address_%s <= register_%s;\n"%(
                    instruction["element_size"],
                    instruction["src"]))
                output_file.write("        data_in_%s <= register_%s;\n"%(
                    instruction["element_size"],
                    instruction["srcb"]))
                output_file.write("        write_enable_%s <= 1'b1;\n"%(
                    instruction["element_size"]))

            elif instruction["op"] == "memory_write_literal":
                output_file.write("        address_%s <= 16'd%s;\n"%(
                    instruction["element_size"],
                    instruction["address"]))
                output_file.write("        data_in_%s <= %s;\n"%(
                    instruction["element_size"],
                    instruction["value"]))
                output_file.write("        write_enable_%s <= 1'b1;\n"%(
                    instruction["element_size"]))

            elif instruction["op"] == "assert":
                output_file.write( "        if (register_%s == 0) begin\n"%instruction["src"])
                output_file.write( "          $display(\"Assertion failed at line: %s in file: %s\");\n"%(
                  instruction["line"],
                  instruction["file"]))
                output_file.write( "          $finish_and_return(1);\n")
                output_file.write( "        end\n")

            elif instruction["op"] == "wait_clocks":
                output_file.write("        if (timer < register_%s) begin\n"%instruction["src"])
                output_file.write("          program_counter <= program_counter;\n")
                output_file.write("          timer <= timer+1;\n")
                output_file.write("        end\n")

            elif instruction["op"] == "report":
                if instruction["type"] == "float":
                    output_file.write('          fp_value = (register_%s[31]?-1.0:1.0) *\n'%instruction["src"])
                    output_file.write('              (2.0 ** (register_%s[30:23]-127.0)) *\n'%instruction["src"])
                    output_file.write('              ({1\'d1, register_%s[22:0]} / (2.0**23));\n'%instruction["src"])

                    output_file.write('          $display ("%%f (report at line: %s in file: %s)", fp_value);\n'%(
                      instruction["line"],
                      instruction["file"]))
                elif not instruction["signed"]:
                    output_file.write(
                      '        $display ("%%d (report at line: %s in file: %s)", $unsigned(register_%s));\n'%(
                      instruction["line"],
                      instruction["file"],
                      instruction["src"]))
                else:
                    output_file.write(
                      '        $display ("%%d (report at line: %s in file: %s)", $signed(register_%s));\n'%(
                      instruction["line"],
                      instruction["file"],
                      instruction["src"]))

            elif instruction["op"] == "stop":
                #If we are in testbench mode stop the simulation
                #If we are part of a larger design, other C programs may still be running
                for file_ in input_files.values():
                    output_file.write("        $fclose(%s);\n"%file_)
                for file_ in output_files.values():
                    output_file.write("        $fclose(%s);\n"%file_)
                if testbench:
                    output_file.write('        $finish;\n')
                output_file.write("        program_counter <= program_counter;\n")
        output_file.write("      end\n\n")

    output_file.write("    endcase\n")

    #Reset program counter and control signals
    output_file.write("    if (rst == 1'b1) begin\n")
    output_file.write("      program_counter <= 0;\n")
    for i in inputs:
        output_file.write("      s_input_%s_ack <= 0;\n"%(i))
    for i in outputs:
        output_file.write("      s_output_%s_stb <= 0;\n"%(i))
    output_file.write("    end\n")
    output_file.write("  end\n")
    for i in inputs:
        output_file.write("  assign input_%s_ack = s_input_%s_ack;\n"%(i, i))
    for i in outputs:
        output_file.write("  assign output_%s_stb = s_output_%s_stb;\n"%(i, i))
        output_file.write("  assign output_%s = s_output_%s;\n"%(i, i))
    output_file.write("\nendmodule\n")

    return inputs, outputs

def connect_float_to_int(output_file):
    output_file.write("  \n  float_to_int float_to_int_1(\n")
    output_file.write("    .clk(clk),\n")
    output_file.write("    .rst(rst),\n")
    output_file.write("    .input_a(float_to),\n")
    output_file.write("    .input_a_stb(float_to_stb),\n")
    output_file.write("    .input_a_ack(float_to_ack),\n")
    output_file.write("    .output_z(to_int),\n")
    output_file.write("    .output_z_stb(to_int_stb),\n")
    output_file.write("    .output_z_ack(to_int_ack)\n")
    output_file.write("  );\n\n")
    output_file.write("  \n  always @(posedge clk)\n")
    output_file.write("  begin\n\n")
    output_file.write("    float_to_int_done <= 0;\n")
    output_file.write("    case(float_to_int_state)\n\n")
    output_file.write("      wait_go:\n")
    output_file.write("      begin\n")
    output_file.write("        if (float_to_int_go) begin\n")
    output_file.write("          float_to_int_state <= write_a;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      write_a:\n")
    output_file.write("      begin\n")
    output_file.write("        float_to_stb <= 1;\n")
    output_file.write("        if (float_to_stb && float_to_ack) begin\n")
    output_file.write("          float_to_stb <= 0;\n")
    output_file.write("          float_to_int_state <= read_z;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      read_z:\n")
    output_file.write("      begin\n")
    output_file.write("        to_int_ack <= 1;\n")
    output_file.write("        if (to_int_stb && to_int_ack) begin\n")
    output_file.write("          to_int_ack <= 0;\n")
    output_file.write("          float_to_int_state <= wait_next;\n")
    output_file.write("          float_to_int_done <= 1;\n")
    output_file.write("        end\n")
    output_file.write("      end\n")
    output_file.write("      wait_next:\n")
    output_file.write("      begin\n")
    output_file.write("        if (!float_to_int_go) begin\n")
    output_file.write("          float_to_int_state <= wait_go;\n")
    output_file.write("        end\n")
    output_file.write("      end\n")
    output_file.write("    endcase\n")
    output_file.write("    if (rst) begin\n")
    output_file.write("      float_to_int_state <= wait_go;\n")
    output_file.write("      float_to_stb <= 0;\n")
    output_file.write("      to_int_ack <= 0;\n")
    output_file.write("    end\n")
    output_file.write("  end\n\n")

def connect_int_to_float(output_file):
    output_file.write("  \n  int_to_float int_to_float_1(\n")
    output_file.write("    .clk(clk),\n")
    output_file.write("    .rst(rst),\n")
    output_file.write("    .input_a(int_to),\n")
    output_file.write("    .input_a_stb(int_to_stb),\n")
    output_file.write("    .input_a_ack(int_to_ack),\n")
    output_file.write("    .output_z(to_float),\n")
    output_file.write("    .output_z_stb(to_float_stb),\n")
    output_file.write("    .output_z_ack(to_float_ack)\n")
    output_file.write("  );\n\n")
    output_file.write("  \n  always @(posedge clk)\n")
    output_file.write("  begin\n\n")
    output_file.write("    int_to_float_done <= 0;\n")
    output_file.write("    case(int_to_float_state)\n\n")
    output_file.write("      wait_go:\n")
    output_file.write("      begin\n")
    output_file.write("        if (int_to_float_go) begin\n")
    output_file.write("          int_to_float_state <= write_a;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      write_a:\n")
    output_file.write("      begin\n")
    output_file.write("        int_to_stb <= 1;\n")
    output_file.write("        if (int_to_stb && int_to_ack) begin\n")
    output_file.write("          int_to_stb <= 0;\n")
    output_file.write("          int_to_float_state <= read_z;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      read_z:\n")
    output_file.write("      begin\n")
    output_file.write("        to_float_ack <= 1;\n")
    output_file.write("        if (to_float_stb && to_float_ack) begin\n")
    output_file.write("          to_float_ack <= 0;\n")
    output_file.write("          int_to_float_state <= wait_next;\n")
    output_file.write("          int_to_float_done <= 1;\n")
    output_file.write("        end\n")
    output_file.write("      end\n")
    output_file.write("      wait_next:\n")
    output_file.write("      begin\n")
    output_file.write("        if (!int_to_float_go) begin\n")
    output_file.write("          int_to_float_state <= wait_go;\n")
    output_file.write("        end\n")
    output_file.write("      end\n")
    output_file.write("    endcase\n")
    output_file.write("    if (rst) begin\n")
    output_file.write("      int_to_float_state <= wait_go;\n")
    output_file.write("      int_to_stb <= 0;\n")
    output_file.write("      to_float_ack <= 0;\n")
    output_file.write("    end\n")
    output_file.write("  end\n\n")

def connect_divider(output_file):
    output_file.write("  \n  divider divider_1(\n")
    output_file.write("    .clk(clk),\n")
    output_file.write("    .rst(rst),\n")
    output_file.write("    .input_a(divider_a),\n")
    output_file.write("    .input_a_stb(divider_a_stb),\n")
    output_file.write("    .input_a_ack(divider_a_ack),\n")
    output_file.write("    .input_b(divider_b),\n")
    output_file.write("    .input_b_stb(divider_b_stb),\n")
    output_file.write("    .input_b_ack(divider_b_ack),\n")
    output_file.write("    .output_z(divider_z),\n")
    output_file.write("    .output_z_stb(divider_z_stb),\n")
    output_file.write("    .output_z_ack(divider_z_ack)\n")
    output_file.write("  );\n\n")
    output_file.write("  \n  always @(posedge clk)\n")
    output_file.write("  begin\n\n")
    output_file.write("    divider_done <= 0;\n")
    output_file.write("    case(div_state)\n\n")
    output_file.write("      wait_go:\n")
    output_file.write("      begin\n")
    output_file.write("        if (divider_go) begin\n")
    output_file.write("          div_state <= write_a;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      write_a:\n")
    output_file.write("      begin\n")
    output_file.write("        divider_a_stb <= 1;\n")
    output_file.write("        if (divider_a_stb && divider_a_ack) begin\n")
    output_file.write("          divider_a_stb <= 0;\n")
    output_file.write("          div_state <= write_b;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      write_b:\n")
    output_file.write("      begin\n")
    output_file.write("        divider_b_stb <= 1;\n")
    output_file.write("        if (divider_b_stb && divider_b_ack) begin\n")
    output_file.write("          divider_b_stb <= 0;\n")
    output_file.write("          div_state <= read_z;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      read_z:\n")
    output_file.write("      begin\n")
    output_file.write("        divider_z_ack <= 1;\n")
    output_file.write("        if (divider_z_stb && divider_z_ack) begin\n")
    output_file.write("          divider_z_ack <= 0;\n")
    output_file.write("          div_state <= wait_next;\n")
    output_file.write("          divider_done <= 1;\n")
    output_file.write("        end\n")
    output_file.write("      end\n")
    output_file.write("      wait_next:\n")
    output_file.write("      begin\n")
    output_file.write("        if (!divider_go) begin\n")
    output_file.write("          div_state <= wait_go;\n")
    output_file.write("        end\n")
    output_file.write("      end\n")
    output_file.write("    endcase\n")
    output_file.write("    if (rst) begin\n")
    output_file.write("      div_state <= wait_go;\n")
    output_file.write("      divider_a_stb <= 0;\n")
    output_file.write("      divider_b_stb <= 0;\n")
    output_file.write("      divider_z_ack <= 0;\n")
    output_file.write("    end\n")
    output_file.write("  end\n\n")

def connect_multiplier(output_file):
    output_file.write("  \n  multiplier multiplier_1(\n")
    output_file.write("    .clk(clk),\n")
    output_file.write("    .rst(rst),\n")
    output_file.write("    .input_a(multiplier_a),\n")
    output_file.write("    .input_a_stb(multiplier_a_stb),\n")
    output_file.write("    .input_a_ack(multiplier_a_ack),\n")
    output_file.write("    .input_b(multiplier_b),\n")
    output_file.write("    .input_b_stb(multiplier_b_stb),\n")
    output_file.write("    .input_b_ack(multiplier_b_ack),\n")
    output_file.write("    .output_z(multiplier_z),\n")
    output_file.write("    .output_z_stb(multiplier_z_stb),\n")
    output_file.write("    .output_z_ack(multiplier_z_ack)\n")
    output_file.write("  );\n\n")
    output_file.write("  \n  always @(posedge clk)\n")
    output_file.write("  begin\n\n")
    output_file.write("    multiplier_done <= 0;\n")
    output_file.write("    case(mul_state)\n\n")
    output_file.write("      wait_go:\n")
    output_file.write("      begin\n")
    output_file.write("        if (multiplier_go) begin\n")
    output_file.write("          mul_state <= write_a;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      write_a:\n")
    output_file.write("      begin\n")
    output_file.write("        multiplier_a_stb <= 1;\n")
    output_file.write("        if (multiplier_a_stb && multiplier_a_ack) begin\n")
    output_file.write("          multiplier_a_stb <= 0;\n")
    output_file.write("          mul_state <= write_b;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      write_b:\n")
    output_file.write("      begin\n")
    output_file.write("        multiplier_b_stb <= 1;\n")
    output_file.write("        if (multiplier_b_stb && multiplier_b_ack) begin\n")
    output_file.write("          multiplier_b_stb <= 0;\n")
    output_file.write("          mul_state <= read_z;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      read_z:\n")
    output_file.write("      begin\n")
    output_file.write("        multiplier_z_ack <= 1;\n")
    output_file.write("        if (multiplier_z_stb && multiplier_z_ack) begin\n")
    output_file.write("          multiplier_z_ack <= 0;\n")
    output_file.write("          mul_state <= wait_next;\n")
    output_file.write("          multiplier_done <= 1;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      wait_next:\n")
    output_file.write("      begin\n")
    output_file.write("        if (!multiplier_go) begin\n")
    output_file.write("          mul_state <= wait_go;\n")
    output_file.write("        end\n")
    output_file.write("      end\n")
    output_file.write("    endcase\n\n")
    output_file.write("    if (rst) begin\n")
    output_file.write("      mul_state <= wait_go;\n")
    output_file.write("      multiplier_a_stb <= 0;\n")
    output_file.write("      multiplier_b_stb <= 0;\n")
    output_file.write("      multiplier_z_ack <= 0;\n")
    output_file.write("    end\n")
    output_file.write("  end\n\n")

def connect_adder(output_file):
    output_file.write("  \n  adder adder_1(\n")
    output_file.write("    .clk(clk),\n")
    output_file.write("    .rst(rst),\n")
    output_file.write("    .input_a(adder_a),\n")
    output_file.write("    .input_a_stb(adder_a_stb),\n")
    output_file.write("    .input_a_ack(adder_a_ack),\n")
    output_file.write("    .input_b(adder_b),\n")
    output_file.write("    .input_b_stb(adder_b_stb),\n")
    output_file.write("    .input_b_ack(adder_b_ack),\n")
    output_file.write("    .output_z(adder_z),\n")
    output_file.write("    .output_z_stb(adder_z_stb),\n")
    output_file.write("    .output_z_ack(adder_z_ack)\n")
    output_file.write("  );\n\n")
    output_file.write("  \n  always @(posedge clk)\n")
    output_file.write("  begin\n\n")
    output_file.write("    adder_done <= 0;\n")
    output_file.write("    case(add_state)\n\n")
    output_file.write("      wait_go:\n")
    output_file.write("      begin\n")
    output_file.write("        if (adder_go) begin\n")
    output_file.write("          add_state <= write_a;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      write_a:\n")
    output_file.write("      begin\n")
    output_file.write("        adder_a_stb <= 1;\n")
    output_file.write("        if (adder_a_stb && adder_a_ack) begin\n")
    output_file.write("          adder_a_stb <= 0;\n")
    output_file.write("          add_state <= write_b;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      write_b:\n")
    output_file.write("      begin\n")
    output_file.write("        adder_b_stb <= 1;\n")
    output_file.write("        if (adder_b_stb && adder_b_ack) begin\n")
    output_file.write("          adder_b_stb <= 0;\n")
    output_file.write("          add_state <= read_z;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
    output_file.write("      read_z:\n")
    output_file.write("      begin\n")
    output_file.write("        adder_z_ack <= 1;\n")
    output_file.write("        if (adder_z_stb && adder_z_ack) begin\n")
    output_file.write("          adder_z_ack <= 0;\n")
    output_file.write("          add_state <= wait_next;\n")
    output_file.write("          adder_done <= 1;\n")
    output_file.write("        end\n")
    output_file.write("      end\n")
    output_file.write("      wait_next:\n")
    output_file.write("      begin\n")
    output_file.write("        if (!adder_go) begin\n")
    output_file.write("          add_state <= wait_go;\n")
    output_file.write("        end\n")
    output_file.write("      end\n")
    output_file.write("    endcase\n")
    output_file.write("    if (rst) begin\n")
    output_file.write("      add_state <= wait_go;\n")
    output_file.write("      adder_a_stb <= 0;\n")
    output_file.write("      adder_b_stb <= 0;\n")
    output_file.write("      adder_z_ack <= 0;\n")
    output_file.write("    end\n")
    output_file.write("  end\n\n")

def generate_float_to_int_signals(output_file):
    output_file.write("  reg [31:0] float_to;\n")
    output_file.write("  reg float_to_stb;\n")
    output_file.write("  wire float_to_ack;\n")
    output_file.write("  wire [31:0] to_int;\n")
    output_file.write("  wire to_int_stb;\n")
    output_file.write("  reg to_int_ack;\n")
    output_file.write("  reg [2:0] float_to_int_state;\n")
    output_file.write("  reg float_to_int_go;\n")
    output_file.write("  reg float_to_int_done;\n")

def generate_int_to_float_signals(output_file):
    output_file.write("  reg [31:0] int_to;\n")
    output_file.write("  reg int_to_stb;\n")
    output_file.write("  wire int_to_ack;\n")
    output_file.write("  wire [31:0] to_float;\n")
    output_file.write("  wire to_float_stb;\n")
    output_file.write("  reg to_float_ack;\n")
    output_file.write("  reg [2:0] int_to_float_state;\n")
    output_file.write("  reg int_to_float_go;\n")
    output_file.write("  reg int_to_float_done;\n")

def generate_divider_signals(output_file):
    output_file.write("  reg [31:0] divider_a;\n")
    output_file.write("  reg divider_a_stb;\n")
    output_file.write("  wire divider_a_ack;\n")
    output_file.write("  reg [31:0] divider_b;\n")
    output_file.write("  reg divider_b_stb;\n")
    output_file.write("  wire divider_b_ack;\n")
    output_file.write("  wire [31:0] divider_z;\n")
    output_file.write("  wire divider_z_stb;\n")
    output_file.write("  reg divider_z_ack;\n")
    output_file.write("  reg [2:0] div_state;\n")
    output_file.write("  reg divider_go;\n")
    output_file.write("  reg divider_done;\n")

def generate_multiplier_signals(output_file):
    output_file.write("  reg [31:0] multiplier_a;\n")
    output_file.write("  reg multiplier_a_stb;\n")
    output_file.write("  wire multiplier_a_ack;\n")
    output_file.write("  reg [31:0] multiplier_b;\n")
    output_file.write("  reg multiplier_b_stb;\n")
    output_file.write("  wire multiplier_b_ack;\n")
    output_file.write("  wire [31:0] multiplier_z;\n")
    output_file.write("  wire multiplier_z_stb;\n")
    output_file.write("  reg multiplier_z_ack;\n")
    output_file.write("  reg [2:0] mul_state;\n")
    output_file.write("  reg multiplier_go;\n")
    output_file.write("  reg multiplier_done;\n")

def generate_adder_signals(output_file):
    output_file.write("  reg [31:0] adder_a;\n")
    output_file.write("  reg adder_a_stb;\n")
    output_file.write("  wire adder_a_ack;\n")
    output_file.write("  reg [31:0] adder_b;\n")
    output_file.write("  reg adder_b_stb;\n")
    output_file.write("  wire adder_b_ack;\n")
    output_file.write("  wire [31:0] adder_z;\n")
    output_file.write("  wire adder_z_stb;\n")
    output_file.write("  reg adder_z_ack;\n")
    output_file.write("  reg [2:0] add_state;\n")
    output_file.write("  reg adder_go;\n")
    output_file.write("  reg adder_done;\n")
