__author__ = "Jon Dawson"
__copyright__ = "Copyright (C) 2012, Jonathan P Dawson"
__version__ = "0.1"

def cleanup_functions(instructions):

    """Remove functions that are not called"""


    #This is an iterative processr. Once a function is removed,
    #there may be more unused functions
    while 1:

        #find function calls
        live_functions = {}
        for instruction in instructions:
            if instruction["op"] == "jmp_and_link":
                if instruction["label"].startswith("function"):
                    live_functions[instruction["label"]] = None

        #remove instructions without function calls
        kept_instructions = []
        generate_on = True
        for instruction in instructions:
            if instruction["op"] == "label":
                if instruction["label"].startswith("function"):
                    if instruction["label"] in live_functions:
                        generate_on = True
                    else:
                        generate_on = False
            if generate_on:
                kept_instructions.append(instruction)

        if len(instructions) == len(kept_instructions):
            return kept_instructions
        instructions = kept_instructions

def reallocate_registers(instructions, registers):

    register_map = {}
    new_registers = {}
    n = 0
    for register, definition in registers.iteritems():
        register_map[register] = n
        new_registers[n] = definition
        n+=1

    for instruction in instructions:
        if "dest" in instruction:
            instruction["dest"] = register_map[instruction["dest"]]
        if "src" in instruction:
            instruction["src"] = register_map[instruction["src"]]
        if "srcb" in instruction:
            instruction["srcb"] = register_map[instruction["srcb"]]

    return instructions, new_registers

def cleanup_registers(instructions, registers):

    #find all the registers that are read from.
    used_registers = {}
    for instruction in instructions:
        if "src" in instruction:
            used_registers[instruction["src"]] = None
        if "srcb" in instruction:
            used_registers[instruction["srcb"]] = None

    #remove them from the list of allocated registers
    kept_registers = {}
    for register, description in registers.iteritems():
        if register in used_registers:
            kept_registers[register] = description

    #remove all instructions that read from unused registers
    kept_instructions = []
    for instruction in instructions:
        if "dest" in instruction:
            if instruction["dest"] in kept_registers:
                kept_instructions.append(instruction)
        else:
            kept_instructions.append(instruction)

    return reallocate_registers(kept_instructions, kept_registers)

def parallelise(instructions):

    def modifies_register(instruction):

        """Return the register modified by this instruction if any"""

        if "dest" in instruction:
            return instruction["dest"]
        return None

    def uses_registers(instruction):

        """Return the registers used by this instruction if any"""

        registers = []
        for field in ["src", "srcb"]:
            if field in instruction:
                registers.append(instruction[field])
        return registers

    def memory_clash(a, b):

        """do instructions result in a memory clash"""

        if a["op"] in ["memory_write", "memory_write_literal"]:
            return b["op"] in ["memory_write", "memory_write_literal", "memory_read", "memory_read_wait", "memory_read_request"]

        if b["op"] in ["memory_write", "memory_write_literal"]:
            return a["op"] in ["memory_write", "memory_write_literal", "memory_read", "memory_read_wait", "memory_read_request"]

        if a["op"] in ["memory_read", "memory_read_wait", "memory_read_request", "memory_write", "memory_write_literal"]:
            return b["op"] == a["op"]

        if b["op"] in ["memory_read", "memory_read_wait", "memory_read_request", "memory_write", "memory_write_literal"]:
            return b["op"] == a["op"]

    def is_part_of_read(a, b):

        """requests, waits and reads with the same sequence number must not be concurrent"""

        read_instructions = ["memory_read_request", "memory_read_wait", "memory_read"]
        if (a["op"] in read_instructions) and (b["op"] in read_instructions):
            return a["sequence"] == b["sequence"]
        return False

    def is_solitary(instruction):

        """Return True if an instruction cannot be executed in parallel with other instructions"""

        if "type" in instruction and instruction["type"] == "float":
            if instruction["op"] in ["+", "-", "/", "*"]:
                return True
        return instruction["op"] in ["read", "write", "ready", "label", "/", "%", "int_to_float", "float_to_int", "file_write", "file_read"]

    def is_jump(instruction):

        """Return True if an instruction contains a branch or jump"""

        return instruction["op"] in ["goto", "jmp_if_true", "jmp_if_false", "jmp_and_link",
                                     "jmp_to_reg"]

    def is_dependent(instruction, frame, preceding):

        """determine whether an instruction is dependent on the outcome of:
        - an instruction within the current frame
        - preceding instructions not within the frame """

        for i in frame + preceding:
            if modifies_register(i) is not None:
                if modifies_register(i) in uses_registers(instruction):
                    return True
                if modifies_register(i) == modifies_register(instruction):
                    return True
            if memory_clash(i, instruction):
                return True
            if is_part_of_read(i, instruction):
                return True
            if is_jump(i):
                return True
        for i in preceding:
            if modifies_register(instruction) is not None:
                if modifies_register(instruction) in uses_registers(i):
                    return True
            if memory_clash(i, instruction):
                return True
            if is_part_of_read(i, instruction):
                return True
        if is_jump(instruction) and preceding:
            return True
        return False

    def add_instructions(frame, instructions):

        """Add more instructions to the current frame if dependencies allow."""

        instructions_added = True
        while instructions_added:
            instructions_added = False
            for index, instruction in enumerate(instructions):
                if is_solitary(instruction):
                    return
                for i in frame:
                    if is_jump(i):
                        return
                    if is_solitary(i):
                        return
                if not is_dependent(instruction, frame, instructions[:index]):
                    frame.append(instructions.pop(index))
                    instructions_added = True
                    break

    frames = []
    while instructions:
        frame = [instructions.pop(0)]
        add_instructions(frame, instructions)
        frames.append(frame)

    return frames
