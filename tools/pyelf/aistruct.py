import mmap
import struct
import os

class GFile(object):
	def __init__(self, filename, size):
		handle = open(filename, 'rb+')
		self.mapping = mmap.mmap(handle.fileno(), size)
	
	def set_byte_ordering(self, ordering):
		self.byte_ordering = ordering
	
	def get_byte_ordering(self):
		return self.byte_ordering
	
	def create_new(filename, size):
		assert size < 10240 # This is only for testing, really
		handle = open(filename, 'wb')
		handle.write('\0' * size)
		handle.close()
		return GFile(filename, size)
	create_new = staticmethod(create_new)

	def existing(filename):
		assert os.path.exists(filename)
		size = os.path.getsize(filename)
		return GFile(filename, size)
	existing = staticmethod(existing)

class BitPoker(object):
	""" """
	SIZE_MAP = {1: 'B',
		2: 'H',
		4: 'I',
		8: 'Q'}
	def set_mmapfile(self, mmapfile, offset_bytes = 0):
		self.mmapfile = mmapfile
		self.master_offset_bytes = offset_bytes
	
	def set_byte_ordering(self, byte_ordering):
		self.byte_ordering = byte_ordering
		self.struct_byte_ordering = {'lsb': '<', 'msb': '>'}[byte_ordering]
	
	def get_byte_ordering(self):
		return self.byte_ordering
	
	def read_value(self, numbytes, offset_bytes):
		# Seek to the right spot using absolute (whence=0) positioning
		self.mmapfile.seek(offset_bytes + self.master_offset_bytes, 0)
		data = self.mmapfile.read(numbytes)
		return struct.unpack('%s%s' % (self.struct_byte_ordering,
				self.SIZE_MAP[numbytes]), data)
	
	def write_value_sized(self, value, numbytes, offset_bytes):
		data = struct.pack('%s%s' % (self.struct_byte_ordering,
				self.SIZE_MAP[numbytes]), value)
		self.mmapfile.seek(offset_bytes + self.master_offset_bytes, 0)
		self.mmapfile.write(data)

	def read_value_sized(self, numbytes, offset_bytes):
		self.mmapfile.seek(offset_bytes + self.master_offset_bytes, 0)
		raw_data = self.mmapfile.read(numbytes)
		data = struct.unpack('%s%s' % (self.struct_byte_ordering,
				self.SIZE_MAP[numbytes]), raw_data)
		return data[0]
	
	def read_c_string(self, offset_bytes):
		self.mmapfile.seek(offset_bytes + self.master_offset_bytes.get(), 0)
		result = ''
		c = self.mmapfile.read_byte()
		while c != '\0':
			result += c
			c = self.mmapfile.read_byte()
		return result
		
	def new_with_gfile(gfile, offset):
		poker = BitPoker()
		poker.set_mmapfile(gfile.mapping, offset)
		poker.set_byte_ordering(gfile.get_byte_ordering())
		return poker
	new_with_gfile = staticmethod(new_with_gfile)

	def new_with_poker(origpoker, offset):
		poker = BitPoker()
		poker.set_mmapfile(origpoker.mmapfile, origpoker.master_offset_bytes + offset)
		poker.set_byte_ordering(origpoker.get_byte_ordering())
		return poker
	new_with_poker = staticmethod(new_with_poker)

class AIStruct(object):
	SIZE32 = 32
	SIZE64 = 64

	class AIElement(object):
		_natural_size = None
		def __init__(self, word_size_in_bits, offset, names, format):
			self.offset = offset #offset into memory-mapped file.
			self.set_target_word_size(word_size_in_bits)
			self.value = 0
			self.names = names
			self.format = format

		def set_target_word_size(self, target_word_size):
			self.target_word_size = target_word_size

		def get_size_bits(self):
			return self._natural_size

		def set_args(self):
			pass

		def set(self, value):
			if type(value) is str and len(value) == 1:
				value = ord(value)
			self.value = value

		def get(self):
			return self.value

		def write(self, bitpoker):
			bitpoker.write_value_sized(self.value, self.get_size_bits() / 8,
					self.offset)

		def read(self, bitpoker):
			self.value = bitpoker.read_value_sized(self.get_size_bits() / 8, self.offset)

		def __cmp__(self, value):
			return cmp(self.value, value)

		def __add__(self, other):
			if  isinstance(other, AIStruct.AIElement):
				return self.value + other.value
			else:
				return self.value + other

		def __mul__(self, other):
			if  isinstance(other, AIStruct.AIElement):
				return self.value * other.value
			else:
				return self.value * other

			
		def __str__(self):
			if self.format:
				if type(self.format) == type(""):
					return self.format % self.value
				else:
					return self.format(self.value)
			if self.names:
				return self.names.get(self.value, str(self.value))
			else:
				return str(self.value)

	class WORD(AIElement):
		def get_size_bits(self):
			return self.target_word_size

	class INT8(AIElement):
		_natural_size = 8
	UINT8 = INT8
	
	class INT16(AIElement):
		_natural_size = 16
	UINT16 = INT16
	
	class INT32(AIElement):
		_natural_size = 32
	UINT32 = INT32
	
	class INT64(AIElement):
		_natural_size = 64
	UINT64 = INT64
	
	class BITFIELD(AIElement):
		class AttributeBasedProperty(object):
			def __init__(self, bitfield_inst):
				self.bitfield_inst = bitfield_inst

			def get_length_and_offset_for_key(self, key):
				offset = 0
				length = 0
				for name, sizes_dict in self.bitfield_inst.components:
					if name == key:
						length = sizes_dict[self.bitfield_inst.target_word_size]
						break
					offset += sizes_dict[self.bitfield_inst.target_word_size]
				if length == 0:
					raise AttributeError(key)
				return length, offset

			def __getitem__(self, key):
				length, offset = self.get_length_and_offset_for_key(key)
				# We have the position of the desired key in value.
				# Retrieve it by right-shifting by "offset" and
				# then masking away anything > length.
				result = self.bitfield_inst.value >> offset
				result &= ( (1<<length) - 1)
				if self.bitfield_inst.post_get is not None:
					return self.bitfield_inst.post_get(key, result)
				else:
					return result

			def __setitem__(self, key, new_value):
				if self.bitfield_inst.pre_set is not None:
					new_value = self.bitfield_inst.pre_set(key, new_value)
				length, offset = self.get_length_and_offset_for_key(key)
				assert new_value < (1 << length)
				# Generate the result in three stages
				# ... insert the new value:
				result = new_value << offset
				# ... | the stuff above the value:
				result |= ( self.bitfield_inst.value >> (offset + length) << (offset + length) )
				# ... | the stuff below the value.
				result |= ( self.bitfield_inst.value & ( (1 << offset) - 1 ) )
				self.bitfield_inst.value = result

		def __init__(self, *args, **kwargs):
			super(AIStruct.BITFIELD, self).__init__(*args, **kwargs)
			self.components = []
			self.attribute_based_property = AIStruct.BITFIELD.AttributeBasedProperty(self)

		def set_args(self, components=None, post_get=None, pre_set=None):
			if components is not None:
				self.components = components
			self.post_get = post_get
			self.pre_set = pre_set

		def get_size_bits(self):
			size_bits = 0
			for comp_name, comp_sizes in self.components:
				size_bits += comp_sizes[self.target_word_size]
			return size_bits

		def get(self):
			return self.attribute_based_property

		def set(self, value):
			raise AttributeError("set() shouldn't be called here!")

	def __init__(self, word_size_in_bits):
		self.word_size_in_bits = word_size_in_bits
		self.thestruct = []
	
	def _setup_attributes(self, allprops):
		# So Python sucks and you can only set properties on class objects,
		# not class instance objects. Hence this crud...
		class AI(object):
			pass
		for key in allprops:
			setattr(AI, key, allprops[key])
		self.ai = AI()

	def _setup_one(self, etypename, ename, args, offset, names, format):
		elementclass = getattr(self, etypename)
		elementinst = elementclass(self.word_size_in_bits, offset, names, format)
		elementinst.set_args(**args)
		self.thestruct.append(elementinst)
		def get_item(obj):
			return elementinst
		def set_item(obj, value):
			return elementinst.set(value)
		newprop = {'%s' % (ename): property(get_item, set_item)}
		return (elementinst.get_size_bits() / 8, newprop)

	def _setup_multiprop(self, ename, times):
		def mp_get(obj):
			return [getattr(self.ai, '%s_%s' % (ename, counter)) for counter in range(1, times+1)]
		def mp_set(obj, value):
			for num, item in enumerate(value):
				setattr(self.ai, '%s_%s' % (ename, num + 1), item)
		return {'%s' % (ename): property(mp_get, mp_set)}
	
	def setup(self, *elements):
		offset = 0 
		allprops = {}
		for element in elements:
			etypename, ename = element[:2]
			args = {}
			if len(element) == 3:
				args = element[2]
			times = args.get('times', None)
			names = args.get('names', None)
			format = args.get('format', None)
			if names is not None:
				del args['names']
			if format is not None:
				del args['format']
			if times is not None:
				del args['times']
				for time in range(times):
					size, propdict = self._setup_one(etypename, '%s_%s' % (ename, time + 1), args, offset, names, format)
					offset += size
					allprops.update(propdict)
				allprops.update(self._setup_multiprop(ename, times))
			else:
				size, propdict = self._setup_one(etypename, ename, args, offset, names, format)
				offset += size
				allprops.update(propdict)
			

		self._setup_attributes(allprops)

	def struct_size(self):
		size = 0
		for element in self.thestruct:
			size += element.get_size_bits()
		return size / 8
	
	def set_poker(self, poker):
		self.poker = poker

	def write(self):
		for element in self.thestruct:
			element.write(self.poker)
	
	def read_from_poker(self, poker):
		self.set_poker(poker)
		for element in self.thestruct:
			element.read(self.poker)
		
	def write_new(self, filename):
		"""convenience function to create a new file and store the KCP in it. """
		newfile = GFile.create_new(filename, self.struct_size())
		poker = BitPoker('lsb') #FIXME
		poker.set_mmapfile(newfile.mapping, offset_bytes = 0)
		self.set_poker(poker)
		self.write()
