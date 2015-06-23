library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.cpu_pack.ALL;

entity opcode_fetch is
	Port(	CLK_I  : in  std_logic;
			T2     : in  std_logic;
			CLR    : in  std_logic;
			CE     : in  std_logic;
			PC_OP  : in  std_logic_vector( 2 downto 0);
			JDATA  : in  std_logic_vector(15 downto 0);
			RR     : in  std_logic_vector(15 downto 0);
			RDATA  : in  std_logic_vector( 7 downto 0);

			PC     : out std_logic_vector(15 downto 0)
		);
end opcode_fetch;

architecture Behavioral of opcode_fetch is

	signal	LPC  : std_logic_vector(15 downto 0);
	signal	LRET : std_logic_vector( 7 downto 0);

begin

	PC <= LPC;

	process(CLK_I, CLR)
	begin
		if (CLR = '1') then
			LPC     <= X"0000";
		elsif ((rising_edge(CLK_I) and T2 = '1') and CE = '1' ) then
			case PC_OP is
				when PC_NEXT =>		LPC  <= LPC + 1;		-- next address
				when PC_JMP  =>		LPC  <= JDATA;			-- jump address
				when PC_RETL =>		LRET <= RDATA;			-- return address L
									LPC  <= LPC + 1;
				when PC_RETH =>		LPC  <= RDATA & LRET;	-- return address H
				when PC_JPRR =>		LPC  <= RR;
				when PC_WAIT =>

				when others  =>		LPC  <= X"0008";		-- interrupt
			end case;
		end if;
	end process;
	
end Behavioral;
