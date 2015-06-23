-------------------------------------------------------------------------------
--	LEVAL	TYPES
-------------------------------------------------------------------------------
--	Package	defines	types	for	the	LevaL	CPU.
-------------------------------------------------------------------------------
--	Created:	28th	of	August	2008	[lykkebo]
-------------------------------------------------------------------------------
library	ieee;
use	ieee.std_logic_1164.all,	ieee.numeric_std.all;

package	leval_package	is
	--	CLEANING	UP	--
	constant	WORD_SIZE				:	integer	:=	32;		--	Size	of	general	word
	constant	ADDR_SIZE				:	integer	:=	26;		--	Address	bus	size
	constant	SCRATCH_SIZE			:	integer	:=	1024;	--	Number	of	registers	in	scratch	memory
	constant	SCRATCH_ADDR_SIZE		:	integer	:=	10;		--	Bus	size	for	register	address
	constant	STATUS_REG_SIZE		:	integer	:=	8;		--	size	of	stat.	reg
	--	microcode
	constant	MC_ADDR_SIZE			:	integer	:=	13;		--	Microcode	memory	address	bus	size
	constant	MC_INSTR_SIZE			:	integer	:=	48;		--	Microcode	instruction	size
	constant	OPCODE_SIZE				:	integer	:=	6;
	constant	TYPE_SIZE		:	integer		:=	5;
	constant	REG1_S					:	integer	:=	39;
	constant	REG1_E					:	integer	:=	29;
	constant	REG2_S					:	integer	:=	28;
	constant	REG2_E					:	integer	:=	18;
	constant	REG3_S					:	integer	:=	17;
	constant	REG3_E					:	integer	:=	7;
	--	nR:	47	46	45	44	43	42	41	40	39	38	37	36	35	34	33	32	31	30	29	28	27	26	25	24	23	22	21	20	19	18	17	16	15	14	13	12	11	10	09	08	07	06	05	04	03	02	01	00
	--	1R:	OP	OP	OP	OP	OP	OP	DE	BP	R1	R1	R1	R1	R1	R1	R1	R1	R1	R1	R1	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM
	--	2R:	OP	OP	OP	OP	OP	OP	DE	BP	R1	R1	R1	R1	R1	R1	R1	R1	R1	R1	R1	R2	R2	R2	R2	R2	R2	R2	R2	R2	R2	R2	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM	IM
	--	Branch	instructions
	--	0R:	OP	OP	OP	OP	OP	OP	DE	BP	--	--	--	--	--	--	--	--	--	--	--	MK	MK	MK	MK	MK	MK	MK MK FG	FG	FG	FG	FG	FG	FG FG AD	AD	AD	AD	AD	AD	AD	AD	AD	AD	AD	AD	AD
	--	1R:	OP	OP	OP	OP	OP	OP	DE	BP	R1	R1	R1	R1	R1	R1	R1	R1	R1	R1	R1	MK MK	MK	MK	MK	MK	MK	MK	FG	FG	FG	FG	FG	FG	FG FG AD	AD	AD	AD	AD	AD	AD	AD	AD	AD	AD	AD	AD

	-- Status flags
	constant ZERO				: integer := 3;
	constant TYP				: integer := 4;
	constant OVERFLOW			: integer := 0;
	constant NEG				: integer := 2;
	constant IO					: integer := 5;

	--	ALU	operations
	constant	ALU_PASS			:	std_logic_vector(5 downto 0)	:=	"000000";
	constant	ALU_ADD			:	std_logic_vector(5 downto 0)	:=	"000001";
	constant ALU_GET_TYPE	:	std_logic_vector(5 downto 0)	:= "000010";
	constant ALU_SET_TYPE	:	std_logic_vector(5 downto 0)	:= "000011";	
	constant ALU_SET_DATUM	:	std_logic_vector(5 downto 0)	:= "000100";
	constant ALU_GET_DATUM	:	std_logic_vector(5 downto 0) := "000101";
	constant ALU_SET_GC		:	std_logic_vector(5 downto 0)	:= "001110";
	constant ALU_GET_GC		:	std_logic_vector(5 downto 0)	:= "000110";
	constant ALU_SUB			:	std_logic_vector(5 downto 0) := "000111";
	constant ALU_CMP_TYPE	:	std_logic_vector(5 downto 0) := "001000";
	constant	ALU_AND			:	std_logic_vector(5 downto 0)	:=	"001001";
	constant	ALU_OR			:	std_logic_vector(5 downto 0)	:=	"001010";
	constant	ALU_XOR			:	std_logic_vector(5 downto 0)	:=	"001011";
	constant	ALU_MUL			:	std_logic_vector(5 downto 0)	:=	"001100";
	constant	ALU_DIV			:	std_logic_vector(5 downto 0)	:=	"001101";
	constant ALU_MOD			:  std_logic_vector(5 downto 0) :=  "001111";
	constant ALU_SL			: std_logic_Vector(5 downto 0) :=   "010000";
	constant ALU_SR			: std_logic_Vector(5 downto 0) :=   "010001";
	constant ALU_SETLED		: std_logic_Vector(5 downto 0) :=   "010010";
		
	--	opcodes
	-- compare operations
	constant ALU_CMP_DATUM		: std_logic_vector(5 downto 0) := "010111";
	constant ALU_CMP_GC 			: std_logic_vector(5 downto 0) := "011111";
	constant ALU_CMP 				: std_logic_vector(5 downto 0) := "100000";
	constant ALU_CMP_TYPE_IMM 	: std_logic_vector(5 downto 0) := "010010";
	constant ALU_CMP_DATUM_IMM : std_logic_vector(5 downto 0) := "010011";
	constant ALU_CMP_GC_IMM 	: std_logic_vector(5 downto 0) := "010100";
	-- set operation
	constant	ALU_CPY			:	std_logic_vector(5 downto 0)	:=	"010101";
	
	
  -- system operations
	constant	NOP			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "000000";
	constant	HALT			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "000001";
	--	integer	instructions
	constant	ADD			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "000010"; 
	constant	SUBB			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "000011";
	constant	MUL			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "000100";
	constant	DIV			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "000101";
	constant	MODULO		:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "001011";
	constant	SHIFT_L		:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "001010";
	constant	SHIFT_R		:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "001100";
	--	logical	instructions
	constant	LAND			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "000110";
	constant	LOR			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "000111";
	constant	LXOR			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "001000";
	--	memory	instructions
	constant	LOAD			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "010000";
	constant	STORE			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "010001";
	--	branch	instructions
	constant	BIDX			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "010110";
	--	data	manipulation
	constant	GET_TYPE		:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "100000";
	constant	SET_TYPE		:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "100001";
	constant	SET_DATUM	:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "100011";
	constant	GET_GC		:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "100101";
	constant	SET_GC		:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "100110";
	constant	CPY			:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "101000";
	constant	SET_TYPE_IMM :	std_logic_vector(OPCODE_SIZE-1 downto 0) := "100010";
	constant	SET_DATUM_IMM:	std_logic_vector(OPCODE_SIZE-1 downto 0) := "100100";
	constant	SET_GC_IMM	: std_logic_vector(OPCODE_SIZE-1 downto 0)	:=	"100111";
	--	compare	functions
	constant	CMP_TYPE		:	std_logic_vector(OPCODE_SIZE-1 downto 0)	:=	"101001";
	constant	CMP_TYPE_IMM:	std_logic_vector(OPCODE_SIZE-1 downto 0)	:=	"101010";
	constant	CMP_DATUM	:	std_logic_vector(OPCODE_SIZE-1 downto 0)	:=	"101011";
	constant	CMP_DATUM_IMM:	std_logic_vector(OPCODE_SIZE-1 downto 0)	:=	"101100";
	constant	CMP_GC		:	std_logic_vector(OPCODE_SIZE-1 downto 0)	:=	"101101";
	constant	CMP_GC_IMM	:	std_logic_vector(OPCODE_SIZE-1 downto 0)	:=	"101110";
	constant	CMP			:	std_logic_vector(OPCODE_SIZE-1 downto 0)	:=	"101111";
	constant	SETLED		:	std_logic_vector(OPCODE_SIZE-1 downto 0)	:=	"111111";
	-- status masks
	constant SM_INT : std_logic_vector(STATUS_REG_SIZE-1 downto 0) := "11110110";
	constant SM_LOG : std_logic_vector(STATUS_REG_SIZE-1 downto 0) := "11000110";
	constant SM_FPO : std_logic_vector(STATUS_REG_SIZE-1 downto 0) := "11111110";
	constant SM_SYS : std_logic_vector(STATUS_REG_SIZE-1 downto 0) := "00000000";
  constant SM_MEM : std_logic_vector(STATUS_REG_SIZE-1 downto 0) := "00000110";
	constant SM_BR  : std_logic_vector(STATUS_REG_SIZE-1 downto 0) := "00000000";
	constant SM_SGO : std_logic_vector(STATUS_REG_SIZE-1 downto 0) := "00000000"; -- set get operations
--constant SM_CMP : std_logic_vector(STATUS_REG_SIZE-1 downto 0) := "11111110";
	
	-- data types
	constant DT_NONE     : std_logic_vector(TYPE_SIZE-1 downto 0) := "00000";
	constant DT_INT      : std_logic_vector(TYPE_SIZE-1 downto 0) := "00001";
	constant DT_FLOAT    : std_logic_vector(TYPE_SIZE-1 downto 0) := "00010";
	constant DT_CONS     : std_logic_vector(TYPE_SIZE-1 downto 0) := "00011";
	constant DT_SNOC     : std_logic_vector(TYPE_SIZE-1 downto 0) := "00100";
	constant DT_PTR      : std_logic_vector(TYPE_SIZE-1 downto 0) := "00101";
	constant DT_ARRAY    : std_logic_vector(TYPE_SIZE-1 downto 0) := "00110";
	constant DT_NIL      : std_logic_vector(TYPE_SIZE-1 downto 0) := "00111";
	constant DT_T        : std_logic_vector(TYPE_SIZE-1 downto 0) := "01000";
	constant DT_CHAR     : std_logic_vector(TYPE_SIZE-1 downto 0) := "01001";
	constant DT_SYMBOL   : std_logic_vector(TYPE_SIZE-1 downto 0) := "01010";
	constant DT_FUNCTION : std_logic_vector(TYPE_SIZE-1 downto 0) := "01011";
	
	
	constant	IMM_SIZE			:	integer	:=10;
	--	Constants	for	internal	typing
	constant	OBJECT_SIZE		:	integer		:=	32;
	constant	DATUM_SIZE		:	integer		:=	26;	
	constant	GC_SIZE			:	integer		:=	1;
	constant TYPE_START		:	integer		:= OBJECT_SIZE - TYPE_SIZE;
	constant GC_BIT			:	integer		:= 26;

	--	Typing	...	types,	uhrm.
	subtype	object	is	std_logic_vector(OBJECT_SIZE	-	1 downto 0);
	subtype	object_type	is	std_logic_vector(TYPE_SIZE	-	1 downto 0);
	subtype	object_datum	is	std_logic_vector(DATUM_SIZE	-	1 downto 0);
	subtype	object_gc	is	std_logic_vector(GC_SIZE	-	1 downto 0);

	--	Type	constants
	constant	TYPE_INT			:	object_type		:=	"00010";

	--	Garbage	collection	constants
	constant	GC_TRUE			:	object_gc		:=	"1";
	constant	GC_FALSE			:	object_gc		:=	"0";
	--	General	constants
	constant	GENERATE_TRACE	:	boolean		:=	false;
	constant	MC_ROM_SIZE		:	integer		:=	16384;	--	instruction	mem
	constant	SCRATCH_MEM_SIZE	:	integer		:=	1024;	--	size	of	scratch	


	--	Instruction	word	constants
	constant	IN_OP_SIZE		:	integer		:=	6;
	constant	FUNCT_SIZE		:	integer	:=6;	--	Size	of	function	word	for	ALU
	constant	BUS_SIZE			:	integer	:=	32;	
	constant	SCRATCH_DEPTH	:	integer		:=	10;

	--	Clock	freq	in	MHz
	constant	LEVAL_FREQ		:	std_logic_vector(7 downto 0)	:=	X"40";
		
	--constant MEMORY_LATENCY : integer := 52; --ms


	--	Types	relating	to	micro-code
	subtype	mc_inst	is	std_logic_vector(MC_INSTR_SIZE	-	1 downto 0);	--	instructions

	subtype	mc_addr	is	natural	range	0	to	MC_ROM_SIZE;
	type	mc_rom	is	array(mc_addr)	of	mc_inst;

	subtype	mc_opcode	is	std_logic_vector(IN_OP_SIZE	-	1 downto 0);--	size of opcode
	

	--	Types	relating	to	the	core
	subtype	scratch_addr	is	natural	range	0	to	SCRATCH_MEM_SIZE;
	
	type	scratch_mem	is	array(scratch_addr)	of	object;
	
	
	function sign_extend_18_26(bus_18 : std_logic_vector(17 downto 0))return std_logic_vector;
	function mask_flags_match(mask,flags : in std_logic_vector(7 downto 0)) return boolean;	
end package;
	
	package body leval_package is
	
	-- Utility
	function sign_extend_18_26(bus_18 : std_logic_vector(17 downto 0))
	return std_logic_vector is
		variable output : std_logic_vector(25 downto 0);
	begin
		output(17 downto 0) := bus_18(17 downto 0);
		output(25 downto 18) := (others => bus_18(17));
		return output;
	end function;

	function mask_flags_match(mask, flags : in std_logic_vector(7 downto 0)) return boolean is
	begin
		if (mask(0)  =  flags(0)) or
			(mask(1)  =  flags(1)) or
			(mask(2)  =  flags(2)) or
			(mask(3)  =  flags(3)) or
			(mask(4)  =  flags(4)) or
			(mask(5)  =  flags(5)) or
			(mask(6)  =  flags(6)) or
			(mask(7)  =  flags(7)) 
		then 
			return true;
		else 
			return false;
		end if;
	end function;
	
end leval_package;
