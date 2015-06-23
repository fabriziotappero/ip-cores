-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;

--! @brief Package containing constants and utility functions relating to status and control registers.
package pp_csr is

	--! Type used for specifying control and status register addresses.
	subtype csr_address is std_logic_vector(11 downto 0);

	--! Type used for exception cause values.
	subtype csr_exception_cause is std_logic_vector(4 downto 0);

	function to_std_logic_vector(input : in csr_exception_cause) return std_logic_vector;

	--! Control/status register write mode:
	type csr_write_mode is (
			CSR_WRITE_NONE, CSR_WRITE_SET, CSR_WRITE_CLEAR, CSR_WRITE_REPLACE
		);

	-- Exception cause values:
	constant CSR_CAUSE_INSTR_MISALIGN : csr_exception_cause := b"00000";
	constant CSR_CAUSE_INSTR_FETCH    : csr_exception_cause := b"00001";
	constant CSR_CAUSE_INVALID_INSTR  : csr_exception_cause := b"00010";
	constant CSR_CAUSE_SYSCALL        : csr_exception_cause := b"00110";
	constant CSR_CAUSE_BREAKPOINT     : csr_exception_cause := b"00111";
	constant CSR_CAUSE_LOAD_MISALIGN  : csr_exception_cause := b"01000";
	constant CSR_CAUSE_STORE_MISALIGN : csr_exception_cause := b"01001";
	constant CSR_CAUSE_LOAD_ERROR     : csr_exception_cause := b"01010";
	constant CSR_CAUSE_STORE_ERROR    : csr_exception_cause := b"01011";
	constant CSR_CAUSE_FROMHOST       : csr_exception_cause := b"11110";
	constant CSR_CAUSE_NONE           : csr_exception_cause := b"11111";

	constant CSR_CAUSE_IRQ_BASE       : csr_exception_cause := b"10000";

	-- Control register IDs, specified in the immediate of csr* instructions:
	constant CSR_STATUS   : csr_address := x"50a";
	constant CSR_HARTID   : csr_address := x"50b";
	constant CSR_SUP0     : csr_address := x"500";
	constant CSR_SUP1     : csr_address := x"501";
	constant CSR_BADVADDR : csr_address := x"503";
	constant CSR_TOHOST   : csr_address := x"51e";
	constant CSR_FROMHOST : csr_address := x"51f";
	constant CSR_CYCLE    : csr_address := x"c00";
	constant CSR_CYCLEH   : csr_address := x"c80";
	constant CSR_TIME     : csr_address := x"c01";
	constant CSR_TIMEH    : csr_address := x"c81";
	constant CSR_INSTRET  : csr_address := x"c02";
	constant CSR_INSTRETH : csr_address := x"c82";
	constant CSR_EPC      : csr_address := x"502";
	constant CSR_EVEC     : csr_address := x"508";
	constant CSR_CAUSE    : csr_address := x"509";

	-- Values used as control register IDs in SRET, SCALL and SBREAK:
	constant CSR_EPC_SRET   : csr_address := x"800";

	-- Status register bit indices:
	constant CSR_SR_S   : natural := 0;
	constant CSR_SR_PS  : natural := 1;
	constant CSR_SR_EI  : natural := 2;
	constant CSR_SR_PEI : natural := 3;

	-- Status register in Potato:
	-- * Bit 0, S: Supervisor mode, always 1
	-- * Bit 1, PS: Previous supervisor mode bit, always 1
	-- * Bit 2, EI: Enable interrupts bit
	-- * Bit 3, PEI: Previous enable interrupts bit
	-- * Bits 23 downto 16, IM: Interrupt mask
	-- * Bits 31 downto 24, PIM: Previous interrupt mask

	-- Status register record:
	type csr_status_register is
		record
			ei, pei : std_logic;
			im, pim : std_logic_vector(7 downto 0);
		end record;

	-- Exception context; this record contains all state that is stored
	-- when an exception is taken.
	type csr_exception_context is
		record
			status   : csr_status_register;
			cause    : csr_exception_cause;
			badvaddr : std_logic_vector(31 downto 0);
		end record;

	-- Reset value of the status register:
	constant CSR_SR_DEFAULT : csr_status_register := (ei => '0', pei => '0', im => x"00", pim => x"00");

	-- Converts a status register record into an std_logic_vector:
	function to_std_logic_vector(input : in csr_status_register)
		return std_logic_vector;

	-- Converts an std_logic_vector into a status register record:
	function to_csr_status_register(input : in std_logic_vector(31 downto 0))
		return csr_status_register;

	--! Checks if a control register is writeable.
	function csr_is_writeable(csr : in csr_address) return boolean;	

end package pp_csr;

package body pp_csr is

	function to_std_logic_vector(input : in csr_exception_cause)
		return std_logic_vector is
	begin
		return (31 downto 5 => '0') & input;
	end function to_std_logic_vector;

	function to_std_logic_vector(input : in csr_status_register)
		return std_logic_vector is
	begin
		return input.pim & input.im & (15 downto 4 => '0') & input.pei & input.ei & '1' & '1';
	end function to_std_logic_vector;

	function to_csr_status_register(input : in std_logic_vector(31 downto 0))
		return csr_status_register
	is
		variable retval : csr_status_register;
	begin
		retval.ei  := input(CSR_SR_EI);
		retval.pei := input(CSR_SR_PEI);
		retval.im  := input(23 downto 16);
		retval.pim := input(31 downto 24);
		return retval;
	end function to_csr_status_register;

	function csr_is_writeable(csr : in csr_address) return boolean is
	begin
		case csr is
			when CSR_FROMHOST | CSR_CYCLE | CSR_CYCLEH | CSR_HARTID
					| CSR_TIME | CSR_TIMEH | CSR_INSTRET | CSR_INSTRETH
					| CSR_CAUSE | CSR_BADVADDR =>
				return false; 
			when others =>
				return true;
		end case;
	end function csr_is_writeable;

end package body pp_csr;
