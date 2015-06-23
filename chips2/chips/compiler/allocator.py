__author__ = "Jon Dawson"
__copyright__ = "Copyright (C) 2012, Jonathan P Dawson"
__version__ = "0.1"

class Allocator:

    """Maintain a pool of registers, variables and arrays. Keep track of what they are used for."""

    def __init__(self, reuse):
        self.registers = []
        self.all_registers = {}
        self.memory_size_2 = 0
        self.memory_size_4 = 0
        self.reuse = reuse
        self.memory_content_2 = {}
        self.memory_content_4 = {}

    def new_array(self, size, contents, element_size):
        if element_size == 2:
            reg = self.memory_size_2
            self.memory_size_2 += int(size)
            if contents is not None:
                for location, value in enumerate(contents, reg):
                    self.memory_content_2[location] = value
            return reg
        elif element_size == 4:
            reg = self.memory_size_4
            self.memory_size_4 += int(size)
            if contents is not None:
                for location, value in enumerate(contents, reg):
                    self.memory_content_4[location] = value
            return reg

    def regsize(self, reg):
        return self.all_registers[reg][1]

    def new(self, size, name="temporary_register"):
        assert type(size) == int
        reg = 0
        while reg in self.registers or (reg in self.all_registers and self.regsize(reg) != size):
            reg += 1
        self.registers.append(reg)
        self.all_registers[reg] = (name, size)
        return reg

    def free(self, register):
        if register in self.registers and self.reuse:
            self.registers.remove(register)
