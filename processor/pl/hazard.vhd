library ieee;
use ieee.std_logic_1164.all;

library work;
use work.leval2_package.all;


entity Hazard is 
	port (
		IFIDopc : in std_logic_vector(INSTR_OPCODE_BITS - 1 downto 0);
		IFIDR1 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		IFIDR2 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		IDEXopc : in std_logic_vector(INSTR_OPCODE_BITS - 1 downto 0);
		IDEXR1 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		IDEXR2 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		EXMEMopc : in std_logic_vector(INSTR_OPCODE_BITS - 1 downto 0);
		EXMEMR1 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		EXMEMR2 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		Hazard : out std_logic
	);
end entity;

architecture mixed of Hazard is
begin
	hazard_detection : process (IDEXopc,IDEXR1,IDEXR2,EXMEMopc,EXMEMR1,EXMEMR2)
	begin
        if IDEXopc = LOAD and (IFIDR1 = IDEXR2 or IFIDR2 = IDEXR2) then
			Hazard <= '1';
        elsif EXMEMopc = LOAD and (IFIDR1 = EXMEMR2 or IFIDR2 = EXMEMR2) then
            Hazard <= '1';
		end if;
	end process;
end architecture;
		



