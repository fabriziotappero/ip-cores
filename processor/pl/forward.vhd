library ieee;
use ieee.std_logic_1164.all;
library work;
use work.leval2_package.all;


entity Forward is
	port (
		AluIn2Src : in std_logic;
		Branch :  in std_logic;
		IDEXR1 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		IDEXR2 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		EXMEMR1 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		EXMEMR2 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		M2WBR1 : in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		M2WBR2 :in std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
		FwdMux1Sel : out std_logic_vector(2 downto 0);
		FwdMux2Sel : out std_logic_vector(2 downto 0)
	);
end entity;

architecture behav of Forward is
begin
	forwarding : process (AluIn2Src,Branch,IDEXR1,IDEXR2,EXMEMR1,EXMEMR2,M2WBR1,M2WBR2)
	begin
        -- Branch won't use result anyway.
		if Branch = '1' then
			FwdMux1Sel <= FWD_BRANCH;
        elsif AluIn2Src = '1' then
            FwdMux2Sel <= FWD_2_IMMEDIATE;
		end if;

         -- Output 1 select
        if EXMEMR1 = IDEXR1 then
            FwdMux1Sel <= FWD_1_EXMEM_ALURES;
        elsif M2WBR2 = IDEXR1 then
            FwdMux1Sel <= FWD_1_M2WB_MEMWRITEDATA;
        elsif M2WBR1 = IDEXR1 then
            FwdMux1Sel <= FWD_1_M2WB_ALURES;
        end if;

        -- Output 2 select
        if M2WBR1 = IDEXR2 then
            FwdMux2Sel <= FWD_2_M2WB_ALURES;
        elsif M2WBR2 = IDEXR2 then
            FwdMux2Sel <= FWD_2_M2WB_MEMWRITEDATA;
        elsif EXMEMR1 = IDEXR2 then
            FwdMux2Sel <= FWD_2_EXMEM_ALURES;
        end if;

	end process;
end architecture;
