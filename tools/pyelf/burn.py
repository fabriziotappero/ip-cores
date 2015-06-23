from aistruct import AIStruct
import elf, sys
from optparse import OptionParser


class AfterBurner(AIStruct):
	def __init__(self, *args, **kwargs):
		AIStruct.__init__(self, AIStruct.SIZE32)
		self.setup(
			('UINT32', 'addr')
		)

        def __str__(self):
            return "0x%x" % self.ai.addr.get()


def arch_perms(rwx):
    # ia32 doesn't support read-noexec
    if rwx & (1 << 2):
        rwx |= 1
    return rwx

def align_up(value, align):
    mod = value % align
    if mod != 0:
        value += (align - mod)
    return value

def gen_pheaders(elf):
    old_rwx = 0
    old_offset = 0
    old_addr = 0
    old_bits = 0
    old_size = 0
    new_addr = 0
    new_offset = 0
    new_size = 0
    for section in [section for section in elf.sheaders if section.allocable()]:
        # Test - can we add this section to the current program header?
        new = 0
        rwx = arch_perms(section.get_perms())
        addr = section.ai.sh_addr.get()
        offset = section.ai.sh_offset.get()
        al = section.ai.sh_addralign.get()
        size = section.ai.sh_size.get()
        
        if old_rwx != rwx:
            new = 1
        if addr != align_up(old_size + old_addr, al):
            new = 2
        if offset != align_up(old_size + old_offset, al):
            new = 3

        if new != 0:
            #print hex(new_offset), hex(new_addr), hex(new_size)
            new_size = size
            new_addr = addr
            new_offset = offset
        else:
            new_size = (addr + size) - new_addr

        old_rwx = rwx
        old_size = size
        old_bits = 0
        old_offset = offset
        old_addr = addr
        #print section.ai.sh_name, section.ai.sh_addr, section.ai.sh_offset, section.ai.sh_size, section.ai.sh_flags, rwx
    print hex(new_offset), hex(new_addr), hex(new_size)

def main():
    wedge = elf.ElfFile.from_file(sys.argv[1])
    guest = elf.ElfFile.from_file(sys.argv[2])
    print wedge.pheaders
    for section in wedge.sheaders:
        print section.name
        section.name += ".linux"
        print section.name
    #del wedge.pheaders[:]
    #print wedge.pheaders
    wedge.write_file("foobar")
    gen_pheaders(wedge)

if __name__ == "__main__":
    main()
