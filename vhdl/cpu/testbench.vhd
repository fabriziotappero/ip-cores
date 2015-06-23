-- VHDL Test Bench for jc2_top design functional and timing simulation

LIBRARY  IEEE;
USE IEEE.std_logic_1164.all;

use work.types.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE testbench_arch OF testbench IS
	COMPONENT first
	  port (
		 clk_in : in STD_LOGIC; 
		 reset_in : in STD_LOGIC; 
		 exten : out STD_LOGIC; 
		 extwe : out STD_LOGIC; 
		 extdata : inout STD_LOGIC_VECTOR ( 7 downto 0 ); 
		 extaddr : out STD_LOGIC_VECTOR ( 7 downto 0 ) 
	  );
	END COMPONENT;


	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL reset : STD_LOGIC := '0';
	signal exten : STD_LOGIC := '0'; 
	signal extwe : STD_LOGIC := '0'; 
	signal extdata : STD_LOGIC_VECTOR ( 7 downto 0 ) := (others => '0'); 
	signal extaddr : STD_LOGIC_VECTOR ( 7 downto 0 ) := (others => '0');

BEGIN
	UUT : first
	PORT MAP (
		clk_in => clk,
--		pc => pc,
		reset_in => reset,
--		instr => instr
		extaddr => extaddr,
		extdata => extdata,
		exten => exten,
		extwe => extwe
	);
	
	reset <= '1' after 310 ns;
	clk   <= not clk after 50 ns;

END testbench_arch;

CONFIGURATION jc2_top_cfg OF testbench IS
	FOR testbench_arch
	END FOR;
END jc2_top_cfg;
