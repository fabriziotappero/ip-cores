#!/usr/bin/env python
"""Generate Verilog Implementation of Instructions

The area optimized implementation uses a CPU like architecture.
+ Instructions are implemented in block RAM.
+ Registers are implemented in dual port RAM.
+ Only one instruction can be executed at a time.
+ The CPU uses a pipeline architecture, and will take 2 clocks to execute a taken branch.
+ A minimal instruction set is determined at compile time, and only those instructions are implemented.

"""

__author__ = "Jon Dawson"
__copyright__ = "Copyright (C) 2013, Jonathan P Dawson"
__version__ = "0.1"

import fpu

def unique(l):

    """In the absence of set in older python implementations, make list values unique"""

    return dict(zip(l, l)).keys()

def log2(instructions):

    """Integer only algorithm to calculate the number of bits needed to store a number"""

    bits = 1
    power = 2
    while power < instructions:
        bits += 1
        power *= 2
    return bits

def print_verilog_literal(size, value):

    """Print a verilog literal with expicilt size"""

    if(value >= 0):
        return "%s'd%s"%(size, value)
    else:
        return "-%s'd%s"%(size, abs(value))

def remove_register_hazards(instructions):

    """search through instructions, and remove register hazards"""

    wait_2_for = None
    wait_1_for = None
    new_instructions = []
    for instruction in instructions:
        wait = 0
        if "src" in instruction:
            if instruction["src"] == wait_1_for:
                wait = max(wait, 1)
            if instruction["src"] == wait_2_for:
                wait = max(wait, 2)
        if "srcb" in instruction:
            if instruction["srcb"] == wait_1_for:
                wait = max(wait, 1)
            if instruction["srcb"] == wait_2_for:
                wait = max(wait, 2)
        for i in range(wait):
            new_instructions.append({"op":"nop"})
        new_instructions.append(instruction)

        if instruction["op"] != "label":
            wait_1_for = wait_2_for
            if "dest" in instruction:
                wait_2_for = instruction["dest"]
            else:
                wait_2_for = None
    return new_instructions

def generate_instruction_set(instructions):

    """Calculate the required instruction set"""

    instruction_set = []
    instruction_memory = []
    for instruction in instructions:
        opcode = {}
        encoded_instruction = {}
        encoded_instruction["dest"] = 0
        encoded_instruction["src"] = 0
        encoded_instruction["srcb"] = 0
        encoded_instruction["literal"] = 0
        encoded_instruction["float"] = True
        opcode["op"] = instruction["op"]
        opcode["right"] = False
        opcode["unsigned"] = False
        opcode["literal"] = False
        opcode["float"] = False

        if "signed" in instruction:
            opcode["unsigned"] = not instruction["signed"]

        if "element_size" in instruction:
            opcode["element_size"] = instruction["element_size"]

        if "file_name" in instruction:
            opcode["file_name"] = instruction["file_name"]

        if "file" in instruction:
            opcode["file"] = instruction["file"]

        if "line" in instruction:
            opcode["line"] = instruction["line"]

        if "input" in instruction:
            opcode["input"] = instruction["input"]

        if "output" in instruction:
            opcode["output"] = instruction["output"]

        if "dest" in instruction:
            encoded_instruction["dest"] = instruction["dest"]

        if "src" in instruction:
            encoded_instruction["src"] = instruction["src"]

        if "srcb" in instruction:
            encoded_instruction["srcb"] = instruction["srcb"]

        if "left" in instruction:
            opcode["literal"] = True
            encoded_instruction["literal"] = instruction["left"]

        if "right" in instruction:
            opcode["literal"] = True
            opcode["right"] = True
            encoded_instruction["literal"] = instruction["right"]

        if "type" in instruction:
            if instruction["type"] == "float":
                opcode["float"] = True
                encoded_instruction["float"] = True

        if "literal" in instruction:
            opcode["literal"] = True
            encoded_instruction["literal"] = instruction["literal"]

        if "label" in instruction:
            opcode["literal"] = True
            encoded_instruction["literal"] = instruction["label"]

        if opcode not in instruction_set:
            instruction_set.append(opcode)

        for op, test_opcode in enumerate(instruction_set):
            if test_opcode == opcode:
                encoded_instruction["op"] = op
                encoded_instruction["comment"] = repr(instruction)
                instruction_memory.append(encoded_instruction)
                break

    return instruction_set, instruction_memory

def calculate_jumps(instructions):

    """change symbolic labels into numeric addresses"""

    #calculate the values of jump locations
    location = 0
    labels = {}
    new_instructions = []
    for instruction in instructions:
        if instruction["op"] == "label":
            labels[instruction["label"]] = location
        else:
            new_instructions.append(instruction)
            location += 1
    instructions = new_instructions

    #substitue real values for labeled jump locations
    for instruction in instructions:
        if "label" in instruction:
            instruction["label"]=labels[instruction["label"]]

    return instructions

def generate_declarations(instructions, no_tb_mode, register_bits, opcode_bits):

    """Generate verilog declarations"""

    #list all inputs and outputs used in the program
    inputs = unique([i["input"] for i in instructions if "input" in i])
    outputs = unique([i["output"] for i in instructions if "output" in i])
    input_files = unique([i["file_name"] for i in instructions if "file_read" == i["op"]])
    output_files = unique([i["file_name"] for i in instructions if "file_write" == i["op"]])
    testbench = not inputs and not outputs and not no_tb_mode

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
      ("timer_enable", 1),
      ("stage_0_enable", 1),
      ("stage_1_enable", 1),
      ("stage_2_enable", 1),
      ("program_counter", log2(len(instructions))),
      ("program_counter_0", log2(len(instructions))),
      ("instruction_0", 32 + register_bits*2 + opcode_bits),
      ("opcode_0", opcode_bits),
      ("dest_0", register_bits),
      ("src_0", register_bits),
      ("srcb_0", register_bits),
      ("literal_0", 32),
      ("program_counter_1", log2(len(instructions))),
      ("opcode_1", opcode_bits),
      ("dest_1", register_bits),
      ("register_1", 32),
      ("registerb_1", 32),
      ("literal_1", 32),
      ("dest_2", register_bits),
      ("result_2", 32),
      ("write_enable_2", 1),
      ("address_2", 16),
      ("data_out_2", 16),
      ("data_in_2", 16),
      ("memory_enable_2", 1),
      ("address_4", 16),
      ("data_out_4", 32),
      ("data_in_4", 32),
      ("memory_enable_4", 1),
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

    return inputs, outputs, input_files, output_files, testbench, inports, outports, signals

def floating_point_enables(instruction_set):
    enable_adder = False
    enable_multiplier = False
    enable_divider = False
    enable_int_to_float = False
    enable_float_to_int = False
    for i in instruction_set:
        if i["op"] == "+" and i["float"]:
            enable_adder = True
        if i["op"] == "-" and i["float"]:
            enable_adder = True
        if i["op"] == "*" and i["float"]:
            enable_multiplier = True
        if i["op"] == "/" and i["float"]:
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
                  instructions,
                  output_file,
                  registers,
                  memory_size_2,
                  memory_size_4,
                  initialize_memory,
                  memory_content_2,
                  memory_content_4,
                  no_tb_mode=False):

    """A big ugly function to crunch through all the instructions and generate the CHIP equivilent"""

    instructions = remove_register_hazards(instructions)
    instructions = calculate_jumps(instructions)
    instruction_set, instruction_memory = generate_instruction_set(instructions)
    register_bits = log2(len(registers));
    opcode_bits = log2(len(instruction_set));
    instruction_bits = 32 + register_bits*2 + opcode_bits
    declarations = generate_declarations(instructions, no_tb_mode, register_bits, opcode_bits)
    inputs, outputs, input_files, output_files, testbench, inports, outports, signals = declarations
    enable_adder, enable_multiplier, enable_divider, enable_int_to_float, enable_float_to_int = floating_point_enables(instruction_set)

    #output the code in verilog
    output_file.write("//////////////////////////////////////////////////////////////////////////////\n")
    output_file.write("//name : %s\n"%name)
    for i in inputs:
        output_file.write("//input : input_%s:16\n"%i)
    for i in outputs:
        output_file.write("//output : output_%s:16\n"%i)
    output_file.write("//source_file : %s\n"%input_file)
    output_file.write("///%s\n"%"".join(["=" for i in name]))
    output_file.write("///\n")
    output_file.write("///Created by C2CHIP\n\n")

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


    output_file.write("//////////////////////////////////////////////////////////////////////////////\n")
    output_file.write("// Register Allocation\n")
    output_file.write("// ===================\n")
    output_file.write("//   %s   %s   %s  \n"%("Register".center(20), "Name".center(20), "Size".center(20)))
    for register, definition in registers.iteritems():
        register_name, size = definition
        output_file.write("//   %s   %s   %s  \n"%(str(register).center(20), register_name.center(20), str(size).center(20)))


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
        output_file.write("  parameter wait_go = 2'd0,\n")
        output_file.write("            write_a = 2'd1,\n")
        output_file.write("            write_b = 2'd2,\n")
        output_file.write("            read_z  = 2'd3;\n")
    

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
        write_declaration("  input ", name, size)

    for name, size in outports:
        write_declaration("  output ", name, size)

    for name, size in signals:
        write_declaration("  reg ", name, size)

    memory_size_2 = int(memory_size_2)
    memory_size_4 = int(memory_size_4)
    if memory_size_2:
        output_file.write("  reg [15:0] memory_2 [%i:0];\n"%(memory_size_2-1))
    if memory_size_4:
        output_file.write("  reg [31:0] memory_4 [%i:0];\n"%(memory_size_4-1))

    output_file.write("  reg [%s:0] instructions [%i:0];\n"%(instruction_bits-1, len(instructions)-1))
    output_file.write("  reg [31:0] registers [%i:0];\n"%(len(registers)-1))


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


    output_file.write("\n  //////////////////////////////////////////////////////////////////////////////\n")
    output_file.write("  // INSTRUCTION INITIALIZATION                                                 \n")
    output_file.write("  //                                                                            \n")
    output_file.write("  // Initialise the contents of the instruction memory                          \n")
    output_file.write("  //\n")
    output_file.write("  // Intruction Set\n")
    output_file.write("  // ==============\n")
    for num, opcode in enumerate(instruction_set):
        output_file.write("  // %s %s\n"%(num, opcode))

    output_file.write("  // Intructions\n")
    output_file.write("  // ===========\n")
    output_file.write("  \n  initial\n")
    output_file.write("  begin\n")
    for location, instruction in enumerate(instruction_memory):
        output_file.write("    instructions[%s] = {%s, %s, %s, %s};//%s\n"%(
            location,
            print_verilog_literal(opcode_bits, instruction["op"]),
            print_verilog_literal(register_bits, instruction["dest"]),
            print_verilog_literal(register_bits, instruction["src"]),
            print_verilog_literal(32, instruction["srcb"] | instruction["literal"]),
            instruction["comment"]))
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
    output_file.write("  // CPU IMPLEMENTAION OF C PROCESS                                             \n")
    output_file.write("  //                                                                            \n")
    output_file.write("  // This section of the file contains a CPU implementing the C process.        \n")

    output_file.write("  \n  always @(posedge clk)\n")
    output_file.write("  begin\n\n")

    if memory_size_2:
        output_file.write("    //implement memory for 2 byte x n arrays\n")
        output_file.write("    if (memory_enable_2 == 1'b1) begin\n")
        output_file.write("      memory_2[address_2] <= data_in_2;\n")
        output_file.write("    end\n")
        output_file.write("    data_out_2 <= memory_2[address_2];\n")
        output_file.write("    memory_enable_2 <= 1'b0;\n\n")

    if memory_size_4:
        output_file.write("    //implement memory for 4 byte x n arrays\n")
        output_file.write("    if (memory_enable_4 == 1'b1) begin\n")
        output_file.write("      memory_4[address_4] <= data_in_4;\n")
        output_file.write("    end\n")
        output_file.write("    data_out_4 <= memory_4[address_4];\n")
        output_file.write("    memory_enable_4 <= 1'b0;\n\n")

    output_file.write("    write_enable_2 <= 0;\n")

    if enable_divider:
        output_file.write("    divider_go <= 0;\n")
    if enable_multiplier:
        output_file.write("    multiplier_go <= 0;\n")
    if enable_adder:
        output_file.write("    adder_go <= 0;\n")
    if enable_int_to_float:
        output_file.write("    int_to_float_go <= 0;\n")
    if enable_float_to_int:
        output_file.write("    float_to_int_go <= 0;\n")

    output_file.write("    //stage 0 instruction fetch\n")
    output_file.write("    if (stage_0_enable) begin\n")
    output_file.write("      stage_1_enable <= 1;\n")
    output_file.write("      instruction_0 <= instructions[program_counter];\n")
    output_file.write("      opcode_0 = instruction_0[%s:%s];\n"%(
        register_bits * 2 + opcode_bits + 31,
        register_bits * 2 + 32))
    output_file.write("      dest_0 = instruction_0[%s:%s];\n"%(
        register_bits * 2 + 31,
        register_bits + 32))
    output_file.write("      src_0 = instruction_0[%s:32];\n"%(
        register_bits + 31))
    output_file.write("      srcb_0 = instruction_0[%s:0];\n"%(register_bits-1))
    output_file.write("      literal_0 = instruction_0[31:0];\n")
    output_file.write("      if(write_enable_2) begin\n")
    output_file.write("        registers[dest_2] <= result_2;\n")
    output_file.write("      end\n")
    output_file.write("      program_counter_0 <= program_counter;\n")
    output_file.write("      program_counter <= program_counter + 1;\n")
    output_file.write("    end\n\n")

    output_file.write("    //stage 1 opcode fetch\n")
    output_file.write("    if (stage_1_enable) begin\n")
    output_file.write("      stage_2_enable <= 1;\n")
    output_file.write("      register_1 <= registers[src_0];\n")
    output_file.write("      registerb_1 <= registers[srcb_0];\n")
    output_file.write("      dest_1 <= dest_0;\n")
    output_file.write("      literal_1 <= literal_0;\n")
    output_file.write("      opcode_1 <= opcode_0;\n")
    output_file.write("      program_counter_1 <= program_counter_0;\n")
    output_file.write("    end\n\n")

    output_file.write("    //stage 2 opcode fetch\n")
    output_file.write("    if (stage_2_enable) begin\n")
    output_file.write("      dest_2 <= dest_1;\n")
    output_file.write("      case(opcode_1)\n\n")

    #A frame is executed in each state
    for opcode, instruction in enumerate(instruction_set):

        if instruction["op"] == "literal":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          result_2 <= literal_1;\n")
            output_file.write("          write_enable_2 <= 1;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "move":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          result_2 <= register_1;\n")
            output_file.write("          write_enable_2 <= 1;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "~":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          result_2 <= ~register_1;\n")
            output_file.write("          write_enable_2 <= 1;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "int_to_float":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          int_to <= register_1;\n")
            output_file.write("          int_to_float_go <= 1;\n")
            output_file.write("          stage_0_enable <= 0;\n")
            output_file.write("          stage_1_enable <= 0;\n")
            output_file.write("          stage_2_enable <= 0;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "float_to_int":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          float_to <= register_1;\n")
            output_file.write("          float_to_int_go <= 1;\n")
            output_file.write("          stage_0_enable <= 0;\n")
            output_file.write("          stage_1_enable <= 0;\n")
            output_file.write("          stage_2_enable <= 0;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] in binary_operators:
            if instruction["literal"]:
                if instruction["float"]:
                    output_file.write("        16'd%s:\n"%(opcode))
                    output_file.write("        begin\n")
                    if instruction["op"] == "/":
                        if instruction["right"]:
                            output_file.write("          divider_a <= register_1;\n")
                            output_file.write("          divider_b <= literal_1;\n")
                        else:
                            output_file.write("          divider_a <= literal_1;\n")
                            output_file.write("          divider_b <= register_1;\n")
                        output_file.write("          divider_go <= 1;\n")
                    elif instruction["op"] == "*":
                        if instruction["right"]:
                            output_file.write("          multiplier_a <= register_1;\n")
                            output_file.write("          multiplier_b <= literal_1;\n")
                        else:
                            output_file.write("          multiplier_a <= literal_1;\n")
                            output_file.write("          multiplier_b <= register_1;\n")
                        output_file.write("          multiplier_go <= 1;\n")
                    elif instruction["op"] == "+":
                        if instruction["right"]:
                            output_file.write("          adder_a <= register_1;\n")
                            output_file.write("          adder_b <= literal_1;\n")
                        else:
                            output_file.write("          adder_a <= literal_1;\n")
                            output_file.write("          adder_b <= register_1;\n")
                        output_file.write("          adder_go <= 1;\n")
                    elif instruction["op"] == "-":
                        if instruction["right"]:
                            output_file.write("          adder_a <= register_1;\n")
                            output_file.write("          adder_b <= {~literal_1[31], literal_1[30:0]};\n")
                        else:
                            output_file.write("          adder_a <= literal_1;\n")
                            output_file.write("          adder_b <= {~register_1[31], register_1[30:0]};\n")
                        output_file.write("          adder_go <= 1;\n")
                    output_file.write("          stage_0_enable <= 0;\n")
                    output_file.write("          stage_1_enable <= 0;\n")
                    output_file.write("          stage_2_enable <= 0;\n")
                    output_file.write("        end\n\n")
                elif instruction["unsigned"]:
                    output_file.write("        16'd%s:\n"%(opcode))
                    output_file.write("        begin\n")
                    if instruction["right"]:
                        output_file.write("          result_2 <= $unsigned(register_1) %s $unsigned(literal_1);\n"%(instruction["op"]))
                    else:
                        output_file.write("          result_2 <= $unsigned(literal_1) %s $unsigned(register_1);\n"%(instruction["op"]))
                    output_file.write("          write_enable_2 <= 1;\n")
                    output_file.write("        end\n\n")
                else:
                    if instruction["op"] == ">>":
                        instruction["op"] = ">>>"
                    output_file.write("        16'd%s:\n"%(opcode))
                    output_file.write("        begin\n")
                    if instruction["right"]:
                        output_file.write("          result_2 <= $signed(register_1) %s $signed(literal_1);\n"%(instruction["op"]))
                    else:
                        output_file.write("          result_2 <= $signed(literal_1) %s $signed(register_1);\n"%(instruction["op"]))
                    output_file.write("          write_enable_2 <= 1;\n")
                    output_file.write("        end\n\n")
            else:
                if instruction["float"]:
                    output_file.write("        16'd%s:\n"%(opcode))
                    output_file.write("        begin\n")
                    if instruction["op"] == "/":
                        output_file.write("          divider_a <= register_1;\n")
                        output_file.write("          divider_b <= registerb_1;\n")
                        output_file.write("          divider_go <= 1;\n")
                    elif instruction["op"] == "*":
                        output_file.write("          multiplier_a <= register_1;\n")
                        output_file.write("          multiplier_b <= registerb_1;\n")
                        output_file.write("          multiplier_go <= 1;\n")
                    elif instruction["op"] == "+":
                        output_file.write("          adder_a <= register_1;\n")
                        output_file.write("          adder_b <= registerb_1;\n")
                        output_file.write("          adder_go <= 1;\n")
                    elif instruction["op"] == "-":
                        output_file.write("          adder_a <= register_1;\n")
                        output_file.write("          adder_b <= {~registerb_1[31], registerb_1[30:0]};\n")
                        output_file.write("          adder_go <= 1;\n")
                    output_file.write("          stage_0_enable <= 0;\n")
                    output_file.write("          stage_1_enable <= 0;\n")
                    output_file.write("          stage_2_enable <= 0;\n")
                    output_file.write("        end\n\n")
                elif instruction["unsigned"]:
                    output_file.write("        16'd%s:\n"%(opcode))
                    output_file.write("        begin\n")
                    output_file.write("          result_2 <= $unsigned(register_1) %s $unsigned(registerb_1);\n"%(instruction["op"]))
                    output_file.write("          write_enable_2 <= 1;\n")
                    output_file.write("        end\n\n")
                else:
                    if instruction["op"] == ">>":
                        instruction["op"] = ">>>"
                    output_file.write("        16'd%s:\n"%(opcode))
                    output_file.write("        begin\n")
                    output_file.write("          result_2 <= $signed(register_1) %s $signed(registerb_1);\n"%(instruction["op"]))
                    output_file.write("          write_enable_2 <= 1;\n")
                    output_file.write("        end\n\n")

        elif instruction["op"] == "jmp_if_false":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          if (register_1 == 0) begin\n");
            output_file.write("            program_counter <= literal_1;\n")
            output_file.write("            stage_0_enable <= 1;\n")
            output_file.write("            stage_1_enable <= 0;\n")
            output_file.write("            stage_2_enable <= 0;\n")
            output_file.write("          end\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "jmp_if_true":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          if (register_1 != 0) begin\n");
            output_file.write("            program_counter <= literal_1;\n")
            output_file.write("            stage_0_enable <= 1;\n")
            output_file.write("            stage_1_enable <= 0;\n")
            output_file.write("            stage_2_enable <= 0;\n")
            output_file.write("          end\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "jmp_and_link":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          program_counter <= literal_1;\n")
            output_file.write("          result_2 <= program_counter_1 + 1;\n")
            output_file.write("          write_enable_2 <= 1;\n")
            output_file.write("          stage_0_enable <= 1;\n")
            output_file.write("          stage_1_enable <= 0;\n")
            output_file.write("          stage_2_enable <= 0;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "jmp_to_reg":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          program_counter <= register_1;\n")
            output_file.write("          stage_0_enable <= 1;\n")
            output_file.write("          stage_1_enable <= 0;\n")
            output_file.write("          stage_2_enable <= 0;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "goto":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          program_counter <= literal_1;\n")
            output_file.write("          stage_0_enable <= 1;\n")
            output_file.write("          stage_1_enable <= 0;\n")
            output_file.write("          stage_2_enable <= 0;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "file_read":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          file_count = $fscanf(%s, \"%%d\\n\", result_2);\n"%(
              input_files[instruction["file_name"]]))
            output_file.write("          write_enable_2 <= 1;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "file_write":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            if instruction["float"]:
                output_file.write('          fp_value = (register_1[31]?-1.0:1.0) *\n')
                output_file.write('              (2.0 ** (register_1[30:23]-127.0)) *\n')
                output_file.write('              ({1\'d1, register_1[22:0]} / (2.0**23));\n')
                output_file.write('          $fdisplay (%s, "%%f", fp_value);\n'%(
                  output_files[instruction["file_name"]]))
            else:
                output_file.write("          $fdisplay(%s, \"%%d\", register_1);\n"%(
                  output_files[instruction["file_name"]]))
            output_file.write("        end\n\n")

        elif instruction["op"] == "read":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          stage_0_enable <= 0;\n")
            output_file.write("          stage_1_enable <= 0;\n")
            output_file.write("          stage_2_enable <= 0;\n")
            output_file.write("          s_input_%s_ack <= 1'b1;\n"%instruction["input"])
            output_file.write("        end\n\n")

        elif instruction["op"] == "ready":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          result_2 <= 0;\n")
            output_file.write("          result_2[0] <= input_%s_stb;\n"%(
              instruction["input"]))
            output_file.write("          write_enable_2 <= 1;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "write":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          stage_0_enable <= 0;\n")
            output_file.write("          stage_1_enable <= 0;\n")
            output_file.write("          stage_2_enable <= 0;\n")
            output_file.write("          s_output_%s_stb <= 1'b1;\n"%instruction["output"])
            output_file.write("          s_output_%s <= register_1;\n"%instruction["output"])
            output_file.write("        end\n\n")

        elif instruction["op"] == "memory_read_request":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          address_%s <= register_1;\n"%(
              instruction["element_size"]))
            output_file.write("        end\n\n")

        elif instruction["op"] == "memory_read_wait":
            pass

        elif instruction["op"] == "memory_read":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          result_2 <= data_out_%s;\n"%(
              instruction["element_size"]))
            output_file.write("          write_enable_2 <= 1;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "memory_write":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          address_%s <= register_1;\n"%(
              instruction["element_size"]))
            output_file.write("          data_in_%s <= registerb_1;\n"%(
              instruction["element_size"]))
            output_file.write("          memory_enable_%s <= 1'b1;\n"%(
              instruction["element_size"]))
            output_file.write("        end\n\n")

        elif instruction["op"] == "assert":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          if (register_1 == 0) begin\n")
            output_file.write("            $display(\"Assertion failed at line: %s in file: %s\");\n"%(
              instruction["line"],
              instruction["file"]))
            output_file.write("            $finish_and_return(1);\n")
            output_file.write("          end\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "wait_clocks":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            output_file.write("          timer <= register_1;\n")
            output_file.write("          timer_enable <= 1;\n")
            output_file.write("          stage_0_enable <= 0;\n")
            output_file.write("          stage_1_enable <= 0;\n")
            output_file.write("          stage_2_enable <= 0;\n")
            output_file.write("        end\n\n")

        elif instruction["op"] == "report":
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            if instruction["float"]:
                
                output_file.write('          fp_value = (register_1[31]?-1.0:1.0) *\n')
                output_file.write('              (2.0 ** (register_1[30:23]-127.0)) *\n')
                output_file.write('              ({1\'d1, register_1[22:0]} / (2.0**23));\n')

                output_file.write('          $display ("%%f (report at line: %s in file: %s)", fp_value);\n'%(
                  instruction["line"],
                  instruction["file"]))

            elif instruction["unsigned"]:

                output_file.write('          $display ("%%d (report at line: %s in file: %s)", $unsigned(register_1));\n'%(
                  instruction["line"],
                  instruction["file"]))

            else:

                output_file.write('          $display ("%%d (report at line: %s in file: %s)", $signed(register_1));\n'%(
                  instruction["line"],
                  instruction["file"],))

            output_file.write("        end\n\n")

        elif instruction["op"] == "stop":
            #If we are in testbench mode stop the simulation
            #If we are part of a larger design, other C programs may still be running
            output_file.write("        16'd%s:\n"%(opcode))
            output_file.write("        begin\n")
            for file_ in input_files.values():
                output_file.write("          $fclose(%s);\n"%file_)
            for file_ in output_files.values():
                output_file.write("          $fclose(%s);\n"%file_)
            if testbench:
                output_file.write('          $finish;\n')
            output_file.write("          stage_0_enable <= 0;\n")
            output_file.write("          stage_1_enable <= 0;\n")
            output_file.write("          stage_2_enable <= 0;\n")
            output_file.write("        end\n\n")


    output_file.write("       endcase\n")
    output_file.write("    end\n")

    for instruction in instruction_set:

        if instruction["op"] == "read":
            output_file.write("    if (s_input_%s_ack == 1'b1 && input_%s_stb == 1'b1) begin\n"%(
              instruction["input"],
              instruction["input"]))
            output_file.write("       result_2 <= input_%s;\n"%(instruction["input"]))
            output_file.write("       write_enable_2 <= 1;\n")
            output_file.write("       s_input_%s_ack <= 1'b0;\n"%instruction["input"])
            output_file.write("       stage_0_enable <= 1;\n")
            output_file.write("       stage_1_enable <= 1;\n")
            output_file.write("       stage_2_enable <= 1;\n")
            output_file.write("     end\n\n")

        elif instruction["op"] == "write":
            output_file.write("     if (s_output_%s_stb == 1'b1 && output_%s_ack == 1'b1) begin\n"%(
              instruction["output"],
              instruction["output"]))
            output_file.write("       s_output_%s_stb <= 1'b0;\n"%instruction["output"])
            output_file.write("       stage_0_enable <= 1;\n")
            output_file.write("       stage_1_enable <= 1;\n")
            output_file.write("       stage_2_enable <= 1;\n")
            output_file.write("     end\n\n")

    output_file.write("    if (timer == 0) begin\n")
    output_file.write("      if (timer_enable) begin\n")
    output_file.write("         stage_0_enable <= 1;\n")
    output_file.write("         stage_1_enable <= 1;\n")
    output_file.write("         stage_2_enable <= 1;\n")
    output_file.write("         timer_enable <= 0;\n")
    output_file.write("      end\n")
    output_file.write("    end else begin\n")
    output_file.write("      timer <= timer - 1;\n")
    output_file.write("    end\n\n")


    if enable_adder:
        output_file.write("    if (adder_done) begin\n")
        output_file.write("      write_enable_2 <= 1;\n")
        output_file.write("      stage_0_enable <= 1;\n")
        output_file.write("      stage_1_enable <= 1;\n")
        output_file.write("      stage_2_enable <= 1;\n")
        output_file.write("    end\n\n")

    if enable_multiplier:
        output_file.write("    if (multiplier_done) begin\n")
        output_file.write("      write_enable_2 <= 1;\n")
        output_file.write("      stage_0_enable <= 1;\n")
        output_file.write("      stage_1_enable <= 1;\n")
        output_file.write("      stage_2_enable <= 1;\n")
        output_file.write("    end\n\n")

    if enable_divider:
        output_file.write("    if (divider_done) begin\n")
        output_file.write("      write_enable_2 <= 1;\n")
        output_file.write("      stage_0_enable <= 1;\n")
        output_file.write("      stage_1_enable <= 1;\n")
        output_file.write("      stage_2_enable <= 1;\n")
        output_file.write("    end\n\n")

    if enable_int_to_float:
        output_file.write("    if (int_to_float_done) begin\n")
        output_file.write("      write_enable_2 <= 1;\n")
        output_file.write("      stage_0_enable <= 1;\n")
        output_file.write("      stage_1_enable <= 1;\n")
        output_file.write("      stage_2_enable <= 1;\n")
        output_file.write("    end\n\n")

    if enable_float_to_int:
        output_file.write("    if (float_to_int_done) begin\n")
        output_file.write("      write_enable_2 <= 1;\n")
        output_file.write("      stage_0_enable <= 1;\n")
        output_file.write("      stage_1_enable <= 1;\n")
        output_file.write("      stage_2_enable <= 1;\n")
        output_file.write("    end\n\n")

    #Reset program counter and control signals
    output_file.write("    if (rst == 1'b1) begin\n")
    output_file.write("      stage_0_enable <= 1;\n")
    output_file.write("      stage_1_enable <= 0;\n")
    output_file.write("      stage_2_enable <= 0;\n")
    output_file.write("      timer <= 0;\n")
    output_file.write("      timer_enable <= 0;\n")
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
    output_file.write("          result_2 <= to_int;\n")
    output_file.write("          float_to_int_state <= wait_go;\n")
    output_file.write("          float_to_int_done <= 1;\n")
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
    output_file.write("          result_2 <= to_float;\n")
    output_file.write("          int_to_float_state <= wait_go;\n")
    output_file.write("          int_to_float_done <= 1;\n")
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
    output_file.write("          result_2 <= divider_z;\n")
    output_file.write("          div_state <= wait_go;\n")
    output_file.write("          divider_done <= 1;\n")
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
    output_file.write("          result_2 <= multiplier_z;\n")
    output_file.write("          mul_state <= wait_go;\n")
    output_file.write("          multiplier_done <= 1;\n")
    output_file.write("        end\n")
    output_file.write("      end\n\n")
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
    output_file.write("          result_2 <= adder_z;\n")
    output_file.write("          add_state <= wait_go;\n")
    output_file.write("          adder_done <= 1;\n")
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
    output_file.write("  reg [1:0] float_to_int_state;\n")
    output_file.write("  reg float_to_int_go;\n")
    output_file.write("  reg float_to_int_done;\n")

def generate_int_to_float_signals(output_file):
    output_file.write("  reg [31:0] int_to;\n")
    output_file.write("  reg int_to_stb;\n")
    output_file.write("  wire int_to_ack;\n")
    output_file.write("  wire [31:0] to_float;\n")
    output_file.write("  wire to_float_stb;\n")
    output_file.write("  reg to_float_ack;\n")
    output_file.write("  reg [1:0] int_to_float_state;\n")
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
    output_file.write("  reg [1:0] div_state;\n")
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
    output_file.write("  reg [1:0] mul_state;\n")
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
    output_file.write("  reg [1:0] add_state;\n")
    output_file.write("  reg adder_go;\n")
    output_file.write("  reg adder_done;\n")
