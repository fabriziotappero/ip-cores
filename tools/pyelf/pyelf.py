import mmap
import os

class ELF:
    EI_MAGIC = "\x7fELF"
    
    def __init__(self, name):
        f = file(name, "rb")
        size = os.stat(name).st_size
        
        self.data = mmap.mmap(f.fileno(), size, mmap.MAP_PRIVATE, mmap.PROT_READ)

        if self.magic != self.EI_MAGIC:
            raise "Not an elf"

    def get_magic(self):
        return self.data[:4]
    magic = property(get_magic)

    def get_class(self):
        return self.data[4]
    elf_class = property(get_class)



"Test suite"

x = ELF("a.out")

# Check can load an elf
success = 1
try:
    x = ELF("a.out")
except:
    success = 0
assert success

# CHeck can't load not and elf
success = 0
try:
    x = ELF("pyelf.py")
except:
    success = 1

assert success
