# PATLPP assembler functions

pc = 0

def INITCODE():
	pc = 0
	print '''
module microcodesrc
(
	input		wire	[8:0]		addr,
	output	reg	[66:0]	code
);

always @(addr)
begin
	case (addr)

		// code: {	         <jmp,rst>
		//				         |      <in_rdy,out_rdy,aeof,asof>
		//				         |      |        <predmode>
		//				         |      |        |     <pred: fcs,eof,sof,equ,dst,src>
		//				         |      |        |     |          <High Byte Reg En>
		//				         |      |        |     |          |     <Output Byte Select>
		//				         |      |        |     |          |     |     <Outport_reg_en, Inport_eg_en>
		//				         |      |        |     |          |     |     |      <Data Mux Select>
		//				         |      |        |     |          |     |     |      |     <Op 0 Select>
		//				         |      |        |     |          |     |     |      |     |     <Op 1 Select>
		//				         |      |        |     |          |     |     |      |     |     |     <Register Address>
		//				         |      |        |     |          |     |     |      |     |     |     |       <Register Write Enables>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     <FCS Add, FCS Clear>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      <sr1ie,sr2ie,sr1oe,sr2oe>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      |        <Flag Register>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      |        |     <Compare Mode>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      |        |     |     <ALU Op>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      |        |     |     |     <Byte Constant>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      |        |     |     |     |       <Word Constant> }'''

def ENDCODE():
	print '''
	default: code <= 0;
	endcase
	
end
endmodule'''

def IN(dest, cond=None, flags=None):
	global pc
	"Input data from a port into the processor"
	if flags == None:
		flagss = "None"
	elif not isinstance(flags, list):
		flagss = str(flags)
	else:
		flagss = "[" + ", ".join(map(str, flags)) + "]"
	inst = Instruction("IN(" + str(dest) + ", Cond=" + str(cond) + ", Flags=" + flagss + ")")
	# Source Processing
	inst.data_mux_s = 3
	inst.input_rdy = True
	# Predicate Mode Processing
	if (cond == None):
		inst.pred_mode = 0
	elif (isinstance(cond, WHEN)):
		inst.pred_mode = 0
	elif (isinstance(cond, UNTIL)):
		inst.pred_mode = 1
	elif (isinstance(cond, IF)):
		inst.pred_mode = 2
	# Predicates
	inst.pred_src = True
	inst.processCond(cond)
	inst.processFlags(flags)
	# Destination Processing
	if isinstance(dest, R):
		inst.reg_addr = dest.address
		inst.reg_wen = 0
		if dest.low: inst.reg_wen += 1
		if dest.high: inst.reg_wen += 2
	elif isinstance(dest, SR):
		if dest.sr_num == 1: inst.sr1_in_en = True
		elif dest.sr_num == 2: inst.sr2_in_en = True
	elif isinstance(dest, HBR):
		inst.highbyte_reg_en = True
	elif isinstance(dest, OPR):
		inst.outport_reg_en = True
	else:
		print("Bad Destination")
		return 0;
	print inst
	pc += 1
	
def OUT(source, cond=None, flags=None):
	global pc
	if flags == None:
		flagss = "None"
	elif not isinstance(flags, list):
		flagss = str(flags)
	else:
		flagss = "[" + ", ".join(map(str, flags)) + "]"
	inst = Instruction("OUT(" + str(source) + ", Cond=" + str(cond) + ", Flags=" + flagss + ")")
	# Destination Processing
	inst.output_byte_s = 0
	inst.output_rdy = True
	# Predicate Mode Processing
	if (cond == None):
		inst.pred_mode = 0
	elif (isinstance(cond, WHEN)):
		inst.pred_mode = 0
	elif (isinstance(cond, UNTIL)):
		inst.pred_mode = 1
	elif (isinstance(cond, IF)):
		inst.pred_mode = 2
	# Predicates
	inst.pred_dst = True
	inst.processCond(cond)
	inst.processFlags(flags)
	# Source Processing
	if isinstance(source, C):
		inst.data_mux_s = 0
		inst.const_word = source.value
	elif isinstance(source, CS):
		inst.data_mux_s = 1
		if source.high_byte_s:
			inst.output_byte_s = 1
	elif isinstance(source, R):
		inst.data_mux_s = 2
		inst.reg_addr = source.address
		if source.high_byte_s:
			inst.output_byte_s = 1
	elif isinstance(source, SR):
		inst.data_mux_s = 4
		if source.sr_num == 1:
			inst.sr1_out_en = True
		if source.sr_num == 2:
			inst.sr2_out_en = True
	print inst
	pc += 1
	
def BYP(cond=None, flags=None):
	global pc
	if flags == None:
		flagss = "None"
	elif not isinstance(flags, list):
		flagss = str(flags)
	else:
		flagss = "[" + ", ".join(map(str, flags)) + "]"
	inst = Instruction("BYP(Cond=" + str(cond) + ", Flags=" + flagss + ")")
	inst.output_rdy = True
	inst.input_rdy = True
	inst.data_mux_s = 3
	# Predicate Mode Processing
	if (cond == None):
		inst.pred_mode = 0
	elif (isinstance(cond, WHEN)):
		inst.pred_mode = 0
	elif (isinstance(cond, UNTIL)):
		inst.pred_mode = 1
	elif (isinstance(cond, IF)):
		inst.pred_mode = 2
	inst.pred_src = True
	inst.pred_dst = True
	# Predicates
	inst.processCond(cond)
	inst.processFlags(flags)
	print inst
	pc += 1
	
def CSA(source):
	global pc
	inst = Instruction("CSA(" + str(source) + ")") # + ", Cond=" + str(cond) + ", Flags=" + str((flags.count > 0)) + ")")
	inst.fcs_add = True
	if isinstance(source, C):
		inst.data_mux_s = 0
		inst.const_word = source.value
	elif isinstance(source, CS):
		inst.data_mux_s = 1
		if source.high_byte_s:
			inst.output_byte_s = 1
	elif isinstance(source, R):
		inst.data_mux_s = 2
		inst.reg_addr = source.address
	elif isinstance(source, P):
		inst.data_mux_s = 3
		inst.input_rdy = True
		inst.pred_mode = 0
		inst.pred_src = True
		if isinstance(source.address, int):
			inst.const_byte = dest.address
			inst.pa_s = 0
		elif isinstance(source.address, R):
			inst.pa_s = 1
			inst.reg_addr = source.address.address
		else:
			print "Bad Source"
			return 0
	elif isinstance(source, SR):
		inst.data_mux_s = 4
		if source.sr_num == 1:
			inst.sr1_out_en = True
		if source.sr_num == 2:
			inst.sr2_out_en = True
	print inst
	pc += 1
	
def CSC():
	global pc
	inst = Instruction("CSC()")
	inst.fcs_clr = True
	print inst
	pc += 1
	
def JMP(loc, cond=None, flags=None):
	global pc
	if flags == None:
		flagss = "None"
	elif not isinstance(flags, list):
		flagss = str(flags)
	else:
		flagss = "[" + ", ".join(map(str, flags)) + "]"
	inst = Instruction("JMP(" + str(loc) + ", Cond=" + str(cond) + ", Flags=" + flagss + ")")
	if not isinstance(loc, int):
		if loc not in globals().keys():
			print("Bad Location")
			print "Loc: ", loc, ", globals().items(): ", globals().items()
			return 0
		loc = globals[loc]
	inst.const_byte = loc
	inst.jump = True
	# Predicate Mode Processing
	if (cond == None):
		inst.pred_mode = 0
	elif (isinstance(cond, WHEN)):
		inst.pred_mode = 0
	elif (isinstance(cond, UNTIL)):
		inst.pred_mode = 1
	elif (isinstance(cond, IF)):
		inst.pred_mode = 2
	# Predicates
	inst.processCond(cond)
	inst.processFlags(flags)
	print inst
	pc += 1
	
def RST(cond=None, flags=None):
	global pc
	if flags == None:
		flagss = "None"
	elif not isinstance(flags, list):
		flagss = str(flags)
	else:
		flagss = "[" + ", ".join(map(str, flags)) + "]"
	inst = Instruction("RST(Cond=" + str(cond) + ", Flags=" + flagss + ")")
	inst.reset = True
	if (cond == None):
		inst.pred_mode = 0
	elif (isinstance(cond, WHEN)):
		inst.pred_mode = 0
	elif (isinstance(cond, UNTIL)):
		inst.pred_mode = 1
	elif (isinstance(cond, IF)):
		inst.pred_mode = 2
	# Predicates
	inst.processCond(cond)
	inst.processFlags(flags)
	print inst
	pc += 1
	
def ADD(op0, op1, dest, cond=None, flags=None):
	global pc
	if flags == None:
		flagss = "None"
	elif not isinstance(flags, list):
		flagss = str(flags)
	else:
		flagss = "[" + ", ".join(map(str, flags)) + "]"
	inst = Instruction("ADD(" + str(op0) + ", " + str(op1) + ", " + str(dest) + ", Cond=" + str(cond) + "Flags=" + flagss + ")")
	inst.alu_op = 0
	inst.data_mux_s = 5
	# Source 0 Processing
	if isinstance(op0, C):
		inst.op0_mux_s = 0
		inst.const_word = op0.value
	elif isinstance(op0, P):
		inst.op0_mux_s = 1
		inst.const_byte = op0.address
	elif isinstance(op0, FR):
		inst.op0_mux_s = 2
	elif isinstance(op0, R):
		inst.op0_mux_s = 3
		inst.reg_addr = op0.address
	# Source 1 Processing
	if isinstance(op1, C):
		inst.op1_mux_s = 0
		inst.const_word = op1.value
	elif isinstance(op1, R):
		inst.op1_mux_s = 1
		inst.reg_addr = op1.address
	# Destination Processing
	if isinstance(dest, R):
		inst.reg_addr = dest.address
		inst.reg_wen = 0
		if dest.low: inst.reg_wen += 1
		if dest.high: inst.reg_wen += 2
	elif isinstance(dest, SR):
		if dest.sr_num == 1: inst.sr1_in_en = True
		elif dest.sr_num == 2: inst.sr2_in_en = True
	else:
		print("Bad Destination")
		return 0;
	# Predicates
	inst.processCond(cond)
	inst.processFlags(flags)
	print inst
	pc += 1
	
def SUB(op0, op1, dest, cond=None, flags=None):
	global pc
	if flags == None:
		flagss = "None"
	elif not isinstance(flags, list):
		flagss = str(flags)
	else:
		flagss = "[" + ", ".join(map(str, flags)) + "]"
	inst = Instruction("SUB(" + str(op0) + ", " + str(op1) + ", " + str(dest) + ", Cond=" + str(cond) + "Flags=" + flagss + ")")
	inst.alu_op = 1
	inst.data_mux_s = 5
	# Source 0 Processing
	if isinstance(op0, C):
		inst.op0_mux_s = 0
		inst.const_word = op0.value
	elif isinstance(op0, P):
		inst.op0_mux_s = 1
		inst.const_byte = op0.address
	elif isinstance(op0, FR):
		inst.op0_mux_s = 2
	elif isinstance(op0, R):
		inst.op0_mux_s = 3
		inst.reg_addr = op0.address
	# Source 1 Processing
	if isinstance(op1, C):
		inst.op1_mux_s = 0
		inst.const_word = op1.value
	elif isinstance(op1, R):
		inst.op1_mux_s = 1
		inst.reg_addr = op1.address
	# Destination Processing
	if isinstance(dest, R):
		inst.reg_addr = dest.address
		inst.reg_wen = 0
		if dest.low: inst.reg_wen += 1
		if dest.high: inst.reg_wen += 2
	elif isinstance(dest, SR):
		if dest.sr_num == 1: inst.sr1_in_en = True
		elif dest.sr_num == 2: inst.sr2_in_en = True
	else:
		print("Bad Destination")
		return 0;
	# Predicates
	inst.processCond(cond)
	inst.processFlags(flags)
	print inst
	pc += 1
	
def MOV(source, dest, cond=None, flags=None):
	global pc
	if flags == None:
		flagss = "None"
	elif not isinstance(flags, list):
		flagss = str(flags)
	else:
		flagss = "[" + ", ".join(map(str, flags)) + "]"
	inst = Instruction("MOV(" + str(source) + "," + str(dest) + ", Cond=" + str(cond) + ", Flags=" + flagss + ")")
	# Source Processing
	if isinstance(source, C):
		inst.data_mux_s = 0
		inst.const_word = source.value
	elif isinstance(source, CS):
		inst.data_mux_s = 1
	elif isinstance(source, R):
		inst.data_mux_s = 2
		inst.reg_addr = source.address
	elif isinstance(source, SR):
		inst.data_mux_s = 4
		if source.sr_num == 1:
			inst.sr1_out_en = True
		if source.sr_num == 2:
			inst.sr2_out_en = True
	elif isinstance(source, FR):
		inst.data_mux_s = 6
	# Destination Processing
	if isinstance(dest, R):
		inst.reg_addr = dest.address
		inst.reg_wen = 0
		if dest.low: inst.reg_wen += 1
		if dest.high: inst.reg_wen += 2
	elif isinstance(dest, SR):
		if dest.sr_num == 1: inst.sr1_in_en = True
		elif dest.sr_num == 2: inst.sr2_in_en = True
	elif isinstance(dest, OPR):
		inst.outport_reg_en = True
	elif isinstance(dest, IPR):
		inst.inport_reg_en = True
	else:
		print("Bad Destination")
		return 0;
	# Predicates
	inst.processCond(cond)
	inst.processFlags(flags)
	print inst
	pc += 1

def LAB(label):
	return
	
def MAN(inst):
	global pc
	print inst
	pc += 1
	
class AEOF:
	def __str__(self): return "<AEOF>"
	
class ASOF:
	def __str__(self): return "<ASOF>"
	
class EOF:
	def __str__(self): return "<EOF>"
	
class SOF:
	def __str__(self): return "<SOF>"

class EQU:
	op0 = None
	op1 = None
	bytewide = False
	
	def __init__(self, op0, op1, bytewide=False):
		self.op0 = op0
		self.op1 = op1
		self.bytewide = bytewide
		
	def __str__(self): return "<" + str(self.op0) + "==" + str(self.op1) + ", Bytewide: " + str(self.bytewide) + ">"

class NEQ:
	op0 = None
	op1 = None
	bytewide = False
	
	def __init__(self, op0, op1, bytewide=False):
		self.op0 = op0
		self.op1 = op1
		self.bytewide = bytewide
	
	def __str__(self): return "<" + str(self.op0) + "!=" + str(self.op1) + ", Bytewide: " + str(self.bytewide) + ">"

class DST:
	def __str__(self): return "DST"

class SRC:
	def __str__(self): return "SRC"

class FCS:
	def __str__(self): return "FCS"
	
class IF:
	preds = None
	
	def __init__(self, preds=None):
		self.preds = preds
	
	def __str__(self):
		if self.preds == None:
			preds = "None"
		elif not isinstance(self.preds, list):
			preds = str(self.preds)
		else:
			preds = ", ".join(map(str, self.preds))
		return "<IF: pred=[" + preds + "]>"
		
class WHEN:
	preds = None
	
	def __init__(self, preds=None):
		self.preds = preds
	
	def __str__(self):
		if self.preds == None:
			preds = "None"
		elif not isinstance(self.preds, list):
			preds = str(self.preds)
		else:
			preds = ", ".join(map(str, self.preds))
		return "<WHEN: pred=[" + preds + "]>"

class UNTIL:
	preds = None
	
	def __init__(self, preds=None):
		self.preds = preds
	
	def __str__(self):
		if self.preds == None:
			preds = "None"
		elif not isinstance(self.preds, list):
			preds = str(self.preds)
		else:
			preds = ", ".join(map(str, self.preds))
		return "<UNTIL: pred=[" + preds + "]>"
	
class P:
		
	def __str__(self):
		return "<Port>"

class R:
	address = 0
	high = True
	low = True
	high_byte_s = False
	
	def __init__(self, addr, high=True, low=True, hbs=False):
		self.address = addr
		self.high = high
		self.low = low
		self.high_byte_s = hbs
		
	def __str__(self):
		return "<Register: address=%d, high=%s, low=%s, high_byte_s=%s>" % (self.address, self.high, self.low, self.high_byte_s)
		
class C:
	value = 0
	
	def __init__(self, value):
		self.value = value
		
	def __str__(self):
		return "<Constant: value=%d>" % self.value

class SR:
	sr_num = 1
	
	def __init__(self, sr_num):
		self.sr_num = sr_num
	
	def __str__(self):
		return "<Shif Register: sr_num=%d>" % self.sr_num
	
class CS:
	high_byte_s = False
	
	def __init__(self, hbs=False):
		self.high_byte_s = hbs
		
	def __str__(self):
		return "<Checksum: high_byte_s=%s>" % (self.high_byte_s)
		
class FR:
	
	def __str__(self):
		return "<Flag Register>"
		
class HBR:
	
	def __str__(self):
		return "<High Byte Register>"

class OPR:

	def __str__(self):
		return "<Output Port Register>"

class IPR:

	def __str__(self):
		return "<Input Port Register>"

class Instruction:
	jump = False
	reset = False
	
	input_rdy = False
	output_rdy = False
	sof_out = False
	eof_out = False
	
	pred_mode = 0 # 0: when, 1: until, 2: if
	pred_fcs = False
	pred_eof = False
	pred_sof = False
	pred_cmp = False
	pred_dst = False
	pred_src = False
	
	highbyte_reg_en = False
	output_byte_s = 0
	
	outport_reg_en = 0
	inport_reg_en = 0
	
	data_mux_s = 0
	op0_mux_s = 0
	op1_mux_s = 0
	
	reg_addr = 0
	reg_wen = 0
	
	fcs_add = False
	fcs_clr = False
	
	sr1_in_en = False
	sr2_in_en = False
	sr1_out_en = False
	sr2_out_en = False
	
	flag_reg_en = False
	
	comp_mode = 0
	
	alu_op = 0
	
	const_byte = 0
	const_word = 0
	
	loc = ""
	
	def __init__(self, loc):
		self.loc = loc
	
	def __str__(self):
		ret = "\t\t%03d:\t\t\tcode <= {" % pc
		ret += "2'b%1d%1d, " % (self.jump, self.reset)
		ret += "4'b%1d%1d%1d%1d, " % (self.input_rdy, self.output_rdy, self.sof_out, self.eof_out)
		ret += "2'd%1d, " % self.pred_mode
		ret += "6'b%1d%1d%1d%1d%1d%1d, " % (self.pred_fcs, self.pred_eof, self.pred_sof, self.pred_cmp, self.pred_dst, self.pred_src)
		ret += "1'b%1d, " % self.highbyte_reg_en
		ret += "1'd%1d, " % self.output_byte_s
		ret += "2'b%1d%1d, " % (self.outport_reg_en, self.inport_reg_en)
		ret += "3'd%1d, " % self.data_mux_s
		ret += "2'd%1d, " % self.op0_mux_s
		ret += "1'd%1d, " % self.op1_mux_s
		ret += "4'd%02d, " % self.reg_addr
		ret += "2'd%1d, " % self.reg_wen
		ret += "2'b%1d%1d, " % (self.fcs_add, self.fcs_clr)
		ret += "4'b%1d%1d%1d%1d, " % (self.sr1_in_en, self.sr2_in_en, self.sr1_out_en, self.sr2_out_en)
		ret += "1'b%1d, " % self.flag_reg_en
		ret += "3'd%1d, " % self.comp_mode
		ret += "2'd%1d, " % self.alu_op
		ret += "9'd%03d, " % self.const_byte
		ret += "16'd%05d" % self.const_word
		ret += "}; // %s" % self.loc
		
		return ret
	
	def processCond(inst, cond):
		if (cond != None):
			if (cond.preds == None): preds = []
			elif not isinstance(cond.preds, list): preds = [cond.preds]
			else: preds = cond.preds
			for pred in preds:
				if (isinstance(pred, EOF)):
					inst.pred_eof = True
				elif (isinstance(pred, SOF)):
					inst.pred_sof = True
				elif (isinstance(pred, EQU)):
					inst.pred_cmp = True
					inst.alu_op = 1
					if (pred.bytewide):
						inst.comp_mode += 4
					if (isinstance(pred.op0,C)):
						inst.op0_mux_s = 0
						inst.const_word = pred.op0.value
					elif (isinstance(pred.op0,P)):
						inst.op0_mux_s = 1
					elif (isinstance(pred.op0,FR)):
						inst.op0_mux_s = 2
					elif (isinstance(pred.op0,R)):
						inst.op0_mux_s = 3
						inst.reg_addr = pred.op0.address
					if (isinstance(pred.op1,C)):
						inst.op1_mux_s = 0
						inst.const_word = pred.op1.value
					elif (isinstance(pred.op1,R)):
						inst.op1_mux_s = 1
						inst.reg_addr = pred.op1.address
				elif (isinstance(pred, NEQ)):
					inst.pred_cmp = True
					inst.alu_op = 1
					inst.comp_mode = 3
					if (pred.bytewide):
						inst.comp_mode += 4
					if (isinstance(pred.op0,C)):
						inst.op0_mux_s = 0
						inst.const_word = pred.op0.value
					elif (isinstance(pred.op0,P)):
						inst.op0_mux_s = 1
					elif (isinstance(pred.op0,FR)):
						inst.op0_mux_s = 2
					elif (isinstance(pred.op0,R)):
						inst.op0_mux_s = 3
						inst.reg_addr = pred.op0.address
					if (isinstance(pred.op1,C)):
						inst.op1_mux_s = 0
						inst.const_word = pred.op1.value
					elif (isinstance(pred.op1,R)):
						inst.op1_mux_s = 1
						inst.reg_addr = pred.op1.address
				elif (isinstance(pred, DST)):
					inst.pred_dst = True
				elif (isinstance(pred, SRC)):
					inst.pred_src = True
				elif (isinstance(pred, FCS)):
					inst.pred_fcs = True
	
	def processFlags(self, flags):
		if (flags != None and len(flags) > 0):
			for flag in flags:
				if (isinstance(flag, AEOF)):
					self.eof_out = True
				elif (isinstance(flag, ASOF)):
					self.sof_out = True