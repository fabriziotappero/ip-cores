from aistruct import GFile, BitPoker, AIStruct
import StringIO
import sys

class Elf32Header(AIStruct):
	EI_MAGIC = [0x7f, ord('E'), ord('L'), ord('F')]
	EI_CLASS_32 = 1
	EI_CLASS_64 = 2
	EI_DATA_LSB = 1
	EI_DATA_MSB = 2
	EI_TYPE_NONE = 0
	EI_TYPE_REL = 1
	EI_TYPE_EXEC = 2
	EI_TYPE_DYN = 3
	EI_TYPE_CORE = 4
	EI_TYPE_NUM = 5
	EI_TYPE_LOPROC = 0xff00
	EI_TYPE_HIPROC = 0xffff
	MACHINE_NONE = 0
	MACHINE_SPARC = 2
	MACHINE_386 = 3
	MACHINE_MIPS = 8
	MACHINE_MIPS_RS4_BE = 10
	MACHINE_SPARC32PLUS = 18
	MACHINE_ARM = 40
	MACHINE_FAKE_ALPHA = 41
	MACHINE_SPARCV9 = 43
	MACHINE_IA_64 = 50
	MACHINE_ALPHA = 0x9026
	VERSION_NONE = 0
	VERSION_CURRENT = 1

	def __init__(self):
		AIStruct.__init__(self, AIStruct.SIZE32)
		self.setup(
			('UINT8', 'ei_magic', {'times': 4}),
			('UINT8', 'ei_class', {'names' : { 1: "ELF32", 2: "ELF64" }} ),
			('UINT8', 'ei_data', {'names' : { 1 : "2's complement, little endian", 2: "2's complement, big endian" }}),
			('UINT8', 'ei_version', {'names' : { 1 : "1 (current)" }}),
			('UINT8', 'ei_osabi', { 'names' : { 0 : "UNIX - System V", 1 : "HP-UX Operating System", 255 : "Standalone application"}}),
			('UINT8', 'ei_abiversion'),
			('UINT8', 'ei_padding', {'times': 7}),
			('UINT16', 'e_type', { 'names' : { 2 : "EXEC (Executable file)" }} ),
			('UINT16', 'e_machine', { 'names' : { 3 : "Intel 80836" } }),
			('UINT32', 'e_version', {'format': "0x%x" }),
			('UINT32', 'e_entry', {'format': "0x%x" }),
			('UINT32', 'e_phoff', { 'format' : "%d (bytes into file)" }),
			('UINT32', 'e_shoff', { 'format' : "%d (bytes into file)" }),
			('UINT32', 'e_flags', {'format': "0x%x" }),
			('UINT16', 'e_ehsize', { 'format' : "%d (bytes)" } ),
			('UINT16', 'e_phentsize', { 'format' : "%d (bytes)" } ),
			('UINT16', 'e_phnum'),
			('UINT16', 'e_shentsize', { 'format' : "%d (bytes)" } ),
			('UINT16', 'e_shnum'),
			('UINT16', 'e_shstrndx')
		)
 	
	def __str__(self):
		f = StringIO.StringIO()
		f.write("ELF Header:\n")
		for name, attr in [("Class", "ei_class"),
				   ("Data", "ei_data"),
				   ("Version", "ei_version"),
				   ("OS/ABI", "ei_osabi"),
				   ("ABI Version", "ei_abiversion"),
				   ("Type", "e_type"),
				   ("Machine", "e_machine"),
				   ("Version", "e_version"),
				   ("Entry point address", "e_entry"),
				   ("Start of program headers", "e_phoff"),
				   ("Start of section headers", "e_shoff"),
				   ("Flags", "e_flags"),
				   ("Size of this header", "e_ehsize"),
				   ("Size of program headers", "e_phentsize"),
				   ("Number of program headers", "e_phnum"),
				   ("Size of section headers", "e_shentsize"),
				   ("Number of section headers", "e_shnum"),
				   ("Section header string table index", "e_shstrndx"),
				   ]:
			f.write("  %-35s%s\n" % ("%s:" % name, getattr(self.ai, attr)))
		return f.getvalue()

class Elf64Header(Elf32Header):
	# Inherit from Elf32Header to get the constants.
	def __init__(self):
		AIStruct.__init__(self, AIStruct.SIZE64)
		self.setup(
			('UINT8', 'ei_magic', {'times': 4}),
			('UINT8', 'ei_class'),
			('UINT8', 'ei_data'),
			('UINT8', 'ei_version'),
			('UINT8', 'ei_padding', {'times': 9}),
			('UINT16', 'e_type'),
			('UINT16', 'e_machine'),
			('UINT32', 'e_version'),
			('UINT64', 'e_entry'),
			('UINT64', 'e_phoff'),
			('UINT64', 'e_shoff'),
			('UINT32', 'e_flags'),
			('UINT16', 'e_ehsize'),
			('UINT16', 'e_phentsize'),
			('UINT16', 'e_phnum'),
			('UINT16', 'e_shentsize'),
			('UINT16', 'e_shnum'),
			('UINT16', 'e_shstrndx')
		)

class Elf32SectionHeader(AIStruct):
	SHF_WRITE = 1 << 0
	SHF_ALLOC = 1 << 1
	SHF_EXECINSTR = 1 << 2

	def __init__(self, *args, **kwargs):
		AIStruct.__init__(self, AIStruct.SIZE32)
		self.elffile = kwargs["elffile"]
		self.index = kwargs["index"]

		def format_flags(x):
			if x == (self.SHF_WRITE | self.SHF_ALLOC):
				return "WA"
			if x == (self.SHF_EXECINSTR | self.SHF_ALLOC):
				return "AX"
			if x == self.SHF_WRITE:
				return "W"
			if x == self.SHF_ALLOC:
				return "A"
			if x == self.SHF_EXECINSTR:
				return "X"
			return "%x" % x

		self.mutated = 0
		self._name = None

		self.setup(
			('UINT32', 'sh_name', {"format" : self.elffile.get_name}),
			('UINT32', 'sh_type', {"names" : {0:"NULL", 1:"PROGBITS", 2:"SYMTAB", 3:"STRTAB", 8:"NOBITS"}}),
			('UINT32', 'sh_flags', {"format": format_flags}),
			('UINT32', 'sh_addr', {"format" : "%08x"}),
			('UINT32', 'sh_offset', {"format" : "%06x"}),
			('UINT32', 'sh_size', {"format" : "%06x"}),
			('UINT32', 'sh_link'),
			('UINT32', 'sh_info', {"format" : "%3d"}),
			('UINT32', 'sh_addralign', {"format" : "%2d"}),
			('UINT32', 'sh_entsize', {"format" : "%02x"}),
		)

	def get_name(self):
		if not self._name:
			self._name = self.elffile.get_name(self.ai.sh_name)
		return self._name

	def set_name(self, value):
		self._name = value
	name = property(get_name, set_name)

	def get_sym_name(self, value):
		strtab =  ElfFileStringTable \
			 (self.elffile.gfile, self.elffile.sheaders[self.ai.sh_link.get()])
		return strtab.read(value)
		

	def allocable(self):
		return self.ai.sh_flags.get() & self.SHF_ALLOC

	def writable(self):
		return self.ai.sh_flags.get() & self.SHF_WRITE

	def executable(self):
		return self.ai.sh_flags.get() & self.SHF_EXECINSTR

	def get_perms(self):
		# Only call on allocatable
		assert self.allocable()
		rwx = (1 << 2);
		if self.writable():
			rwx |= (1 << 1)
		if self.executable():
			rwx |= 1
		return rwx

	def container(self, cls):
		size = cls(section = self).struct_size()
		return ElfFileContainer(self.elffile.gfile, AIStruct.SIZE32, self.ai.sh_offset.get(),
			       size, self.ai.sh_size.get() / size,
			       cls, section=self)


class Elf64SectionHeader(AIStruct):
	def __init__(self, *args, **kwargs):
		AIStruct.__init__(self, AIStruct.SIZE64)
		self.setup(
			('UINT32', 'sh_name'),
			('UINT32', 'sh_type'),
			('UINT64', 'sh_flags'),
			('UINT64', 'sh_addr'),
			('UINT64', 'sh_offset'),
			('UINT64', 'sh_size'),
			('UINT32', 'sh_link'),
			('UINT32', 'sh_info'),
			('UINT64', 'sh_addralign'),
			('UINT64', 'sh_entsize'),
		)


class Elf32ProgramHeader(AIStruct):
	PT_NULL = 0
	PT_NULL = 0
	PT_LOAD = 1
	PT_DYNAMIC = 2
	PT_INTERP = 3
	PT_NOTE = 4
	PT_SHLIB = 5
	PT_PHDR = 6
	PT_NUM = 7
	PT_LOOS = 0x60000000
	PT_HIOS = 0x6fffffff
	PT_LOPROC = 0x70000000
	PT_HIPROC = 0x7fffffff

	PF_X = 1 << 0
	PF_W = 1 << 1
	PF_R = 1 << 2
	PF_MASKPROC = 0xf0000000L

	def __init__(self, *args, **kwargs):
		AIStruct.__init__(self, AIStruct.SIZE32)
		self.elffile = kwargs["elffile"]
		def format_flags(x):
			the_str = [' ', ' ', ' ']
			if (x & self.PF_X):
				the_str[2] = 'E'
			if (x & self.PF_W):
				the_str[1] = 'W'
			if (x & self.PF_R):
				the_str[0] = 'R'
			return "".join(the_str)
		
		self.setup(
			('UINT32', 'p_type', {"names" :
					      {0: "NULL",
					       1: "LOAD",
					       2 : "DYNAMIC",
					       3 : "INTERP",
					       4 : "NOTE",
					       1685382481 : "GNU_STACK",
					       1694766464 : "PAX_FLAGS",
					       }
					      }  ),
			('UINT32', 'p_offset', {"format": "0x%06x"}),
			('UINT32', 'p_vaddr', {"format": "0x%08x"}),
			('UINT32', 'p_paddr', {"format": "0x%08x"}),
			('UINT32', 'p_filesz', {"format": "0x%05x"}),
			('UINT32', 'p_memsz', {"format": "0x%05x"}),
			('UINT32', 'p_flags', {"format": format_flags}),
			('UINT32', 'p_align', {"format": "0x%x"}),
		)

class Elf64ProgramHeader(Elf32ProgramHeader):
	def __init__(self, *args, **kwargs):
		AIStruct.__init__(self, AIStruct.SIZE64)
		self.setup(
			('UINT32', 'p_type', {"names" : {0: "NULL", 1: "LOAD", 2 : "DYNAMIC", 3 : "INTERP", 4 : "NOTE"}}  ),
			('UINT32', 'p_flags'),
			('UINT64', 'p_offset'),
			('UINT64', 'p_vaddr'),
			('UINT64', 'p_paddr'),
			('UINT64', 'p_filesz'),
			('UINT64', 'p_memsz'),
			('UINT64', 'p_align'),
		)

class ElfFileException(Exception):
	pass

class ElfFileNotElfException(ElfFileException):
	pass

class ElfFileContainer(object):
	def __init__(self, gfile, word_size, offset, entsize, number, cls, **kwargs):
		self.gfile = gfile
		self.word_size = word_size
		self.offset = offset
		self.entsize = entsize
		self.number = number
		self.cls = cls
		self.mutated = 0
		self.container = []
		self.kwargs = kwargs

	def mutate(self):
		print "Making it mutable"
		for each in self:
			self.container.append(each)
		self.mutated = 1

	def __delitem__(self, idx):
		if not self.mutated: self.mutate()
		self.container.__delitem__(idx)

	def __getitem__(self, idx):
		if type(idx) == type(""):
			# Act like a dictionary
			for each in self:
				if str(each.ai.sh_name) == idx:
					return each
			raise "badness"
		else:
			if self.mutated:
				print "mutated", idx, self.container
				return self.container[idx]
			else:
				num = idx
				assert num >= 0
				if num >= self.number:
					raise StopIteration()
				inst = self.cls(self.word_size, index=num, **self.kwargs)
				poker = BitPoker.new_with_gfile(self.gfile, self.offset + (self.entsize * num))
				inst.read_from_poker(poker)
				return inst

	def __len__(self):
		return self.number

class ElfFileProgramHeaderContainer(ElfFileContainer):
	def __str__(self):
		f = StringIO.StringIO()
		f.write("Program Headers:\n")
		format_str = "  %-15s%-9s%-11s%-11s%-8s%-8s%-4s%s\n"
		f.write(format_str % ("Type", "Offset", "VirtAddr",
				      "PhysAddr", "FileSiz", "MemSiz", "Flg", "Align"))
		for header in self:
			x = header.ai
			f.write(format_str % (x.p_type, x.p_offset, x.p_vaddr,
					      x.p_paddr, x.p_filesz, x.p_memsz, x.p_flags, x.p_align))
		return f.getvalue()

class ElfFileSectionHeaderContainer(ElfFileContainer):
	def __str__(self):
		f = StringIO.StringIO()
		f.write("There are %d section headers, starting at offset 0x%x:\n\n" % (len(self), self.kwargs["elffile"].header.ai.e_shoff.get()))
		f.write("Section Headers:\n")
		format_str = "  [%2s] %-17.17s %-15s %-8s %-6s %-6s %2s %3s %2s %-3s %-2s\n"
		f.write(format_str % ("Nr", "Name", "Type", "Addr", "Off", "Size",
				      "ES", "Flg", "Lk", "Inf", "Al"))
		for idx, header in enumerate(self):
			x = header.ai
			f.write(format_str % (idx, x.sh_name, x.sh_type, x.sh_addr,
					      x.sh_offset, x.sh_size, x.sh_entsize,
					      x.sh_flags, x.sh_link, x.sh_info,
					      x.sh_addralign))
		return f.getvalue()


class ElfFileStringTable(object):
	def __init__(self, gfile, section_header):
		file_offset = section_header.ai.sh_offset
		self.poker = BitPoker.new_with_gfile(gfile, file_offset)
	
	def read(self, offset):
		return self.poker.read_c_string(offset)


class Symbols(AIStruct):
    def __init__(self, *args, **kwargs):
        AIStruct.__init__(self, AIStruct.SIZE32)
        self.section = kwargs["section"]
        self.setup(
            ('UINT32', 'st_name', {"format" : self.section.get_sym_name}),
            ('UINT32', 'value'),
            ('UINT32', 'size'),
            ('UINT8', 'info'),
            ('UINT8', 'other'),
            ('UINT16', 'st_shndx')
            )

    def __str__(self):
        return "[%s] 0x%08x %5d %3d" % \
               (self.ai.st_name, self.ai.value.get(),
                self.ai.size.get(), self.ai.st_shndx.get())


class ElfFileSymbolTable(object):
	def __init__(self, gfile, section_header):
		self.header = section_header
		file_offset = section_header.ai.sh_offset
		self.poker = BitPoker.new_with_gfile(gfile, file_offset)
	
	def get_symbols(self, section_num = None):
		if section_num:
			return [ sym for sym in self.header.container(Symbols) if sym.ai.st_shndx.get() == section_num]
		else:
			return self.header.container(Symbols)

class ElfFile(object):
	WORD_SIZE_MAP = {Elf32Header.EI_CLASS_32: Elf32Header.SIZE32,
			Elf32Header.EI_CLASS_64: Elf32Header.SIZE64}
	BYTE_ORDER_MAP = {Elf32Header.EI_DATA_LSB: 'lsb',
			Elf32Header.EI_DATA_MSB: 'msb'}
	HEADER_MAP = {Elf32Header.SIZE32: Elf32Header, Elf64Header.SIZE64: Elf64Header}
	PROGRAM_HEADER_MAP = {Elf32Header.SIZE32: Elf32ProgramHeader, Elf64Header.SIZE64: Elf64ProgramHeader}
	SECTION_HEADER_MAP = {Elf32Header.SIZE32: Elf32SectionHeader, Elf64Header.SIZE64: Elf64SectionHeader}
	""" Python representation of an Elf file. """
	def __init__(self, gfile, byte_ordering, word_size):
		self.gfile = gfile
		self.gfile.set_byte_ordering(byte_ordering)
		self.byte_order = byte_ordering
		self.word_size = word_size

		self.header = ElfFile.HEADER_MAP[self.word_size]()
		self.header.read_from_poker(BitPoker.new_with_gfile(self.gfile, 0))
		# Setup the parts of the file
		# ... program headers
		self.pheaders = ElfFileProgramHeaderContainer \
				(gfile, word_size, self.header.ai.e_phoff, self.header.ai.e_phentsize,
				self.header.ai.e_phnum.get(), ElfFile.PROGRAM_HEADER_MAP[word_size], elffile=self)
		# ... section headers
		self.sheaders = ElfFileSectionHeaderContainer \
				(gfile, word_size, self.header.ai.e_shoff, self.header.ai.e_shentsize,
				self.header.ai.e_shnum.get(), ElfFile.SECTION_HEADER_MAP[word_size], elffile=self)
		# ... string table
		if self.header.ai.e_shstrndx != 0:
			self.string_table = ElfFileStringTable \
				(self.gfile, self.sheaders[self.header.ai.e_shstrndx])
		
		# ... symbol table
		self.symtable = None
		for header in self.sheaders:
			if header.get_name() == ".symtab":
				self.symtable = ElfFileSymbolTable(self.gfile, header)
	
	def set_source(self, poker):
		self.source_poker = poker

	def get_name(self, idx):
		return self.string_table.read(idx)
	
	def print_info(self):
		print "* Information for ELF file:"
		print "* Header info:"
		self.header.print_info()


	def write_file(selfm, filename):
		# Write out head
		print "Wirintg out", filename

	def from_file(filename):
		gfile = GFile.existing(filename)
		poker = BitPoker()
		poker.set_mmapfile(gfile.mapping, 0) # Offset of 0 from start of file.
		poker.set_byte_ordering('lsb') # Use default because we don't (yet) know
		header = Elf32Header() # Once again, use a default size.
		header.read_from_poker(poker)
		# Examine the header for info we need.
		# Check the magic first. If we don't and the file is non-ELF, chances are
		# class & data won't match which will result in a confusing error message
		if header.ai.ei_magic != Elf32Header.EI_MAGIC:
			raise ElfFileNotElfException("Wanted magic %r, got %r" \
					% (Elf32Header.EI_MAGIC, header.ai.ei_magic))
		word_size = ElfFile.WORD_SIZE_MAP[header.ai.ei_class.get()]
		byte_order = ElfFile.BYTE_ORDER_MAP[header.ai.ei_data.get()]
		return ElfFile(gfile, byte_order, word_size)
	from_file = staticmethod(from_file)


def test():
	"Test suite"

	elf_file = ElfFile.from_file("a.out")

	# Check can load an elf
	success = 1
	try:
	    x = ElfFile.from_file("a.out")
	except:
	    success = 0
	assert success

	# CHeck can't load not and elf
	success = 0
	try:
	    x = ElfFile.from_file("pyelf.py")
	except:
	    success = 1

	assert success


def main():
	filename = sys.argv[1] # Consider this a usage message :)
	elf_file = ElfFile.from_file(filename)
	elf_file.print_info()

if __name__ == '__main__':
	if sys.argv[1] != "test":
		main()
	else:
		test()


