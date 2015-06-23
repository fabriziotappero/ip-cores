--! @file
--! @brief Baud generator http://www.fpga4fun.com/SerialInterface.html
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

--! Use CPU Definitions package
use work.pkgDefinitions.all;

entity baud_generator is
    Port ( rst : in STD_LOGIC;														--! Reset Input
			  clk : in  STD_LOGIC;														--! Clock input
           cycle_wait : in  STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);	--! Number of cycles to wait for baud generation
			  baud_oversample : out std_logic;										--! Oversample(8x) version of baud (Used on serial_receiver)
           baud : out  STD_LOGIC);													--! Baud generation output (Used on serial_transmitter)
end baud_generator;

--! @brief Baud generator http://www.fpga4fun.com/SerialInterface.html
--! @details Implement block that will generate the desired baud (115200, 9600, etc...) from main clock (50Mhz)
architecture Behavioral of baud_generator is
signal genTick : std_logic;
signal genTickOverSample : std_logic;
begin
	process (rst, clk, cycle_wait)
	variable wait_clk_cycles : STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
	variable half_cycle : STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
	begin
		if rst = '1' then
			wait_clk_cycles := (others => '0');
			half_cycle := '0' & cycle_wait(cycle_wait'high downto 1);
			genTick <= '0';
		elsif rising_edge(clk) then
			-- Just decremented the cycle_wait by one because genTick would be updated on the next cycle
			-- and we really want to bring genTick <= '1' when (wait_clk_cycles = cycle_wait)
			if wait_clk_cycles = (cycle_wait - conv_std_logic_vector(1, nBitsLarge)) then				
				genTick <= '1';				
				wait_clk_cycles := (others => '0');				
			else				
				wait_clk_cycles := wait_clk_cycles + conv_std_logic_vector(1, nBitsLarge); 
				-- If we're at half of the cycle
				if wait_clk_cycles = half_cycle then
					genTick <= '0'; 
				end if;				
			end if;
			
			-- Avoid creation of transparent latch (By default the VHDL will create an register for vectors that are assigned only in one
			-- ocasion of a (if, case) instruction
			half_cycle := '0' & cycle_wait(cycle_wait'high downto 1);			
		end if;
	end process;
	
	baud <= genTick;	
	baud_oversample <= genTickOverSample;
	
	-- Process to generate the overclocked (8x) sample
	process (rst, clk, cycle_wait)
	variable wait_clk_cycles : STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
	variable half_cycle : STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);
	variable cycle_wait_oversample : STD_LOGIC_VECTOR ((nBitsLarge-1) downto 0);	
	begin
		if rst = '1' then
			wait_clk_cycles := (others => '0');			
			
			-- Divide cycle_wait by 8
			--cycle_wait_oversample := '0' & cycle_wait(cycle_wait'high downto 1);			
			--cycle_wait_oversample := '0' & cycle_wait_oversample(cycle_wait_oversample'high downto 1);
			--cycle_wait_oversample := '0' & cycle_wait_oversample(cycle_wait_oversample'high downto 1);
			cycle_wait_oversample := "000" & cycle_wait(cycle_wait'high downto 3);	-- Shift right by 3			
			
			
			-- Half of cycle_wait_oversample
			half_cycle := '0' & cycle_wait_oversample(cycle_wait_oversample'high downto 1); -- Shift right by 1
			genTickOverSample <= '0';
		elsif rising_edge(clk) then
			-- Just decremented the cycle_wait by one because genTick would be updated on the next cycle
			-- and we really want to bring genTick <= '1' when (wait_clk_cycles = cycle_wait)
			if wait_clk_cycles = (cycle_wait_oversample - conv_std_logic_vector(1, nBitsLarge)) then				
				genTickOverSample <= '1';				
				wait_clk_cycles := (others => '0');				
			else				
				wait_clk_cycles := wait_clk_cycles + conv_std_logic_vector(1, nBitsLarge); 
				-- If we're at half of the cycle
				if wait_clk_cycles = half_cycle then
					genTickOverSample <= '0';
				end if;				
			end if;	

			-- Avoid creation of transparent latch (By default the VHDL will create an register for vectors that are assigned only in one
			-- ocasion of a (if, case) instruction
			cycle_wait_oversample := "000" & cycle_wait(cycle_wait'high downto 3);			
			half_cycle := '0' & cycle_wait_oversample(cycle_wait_oversample'high downto 1);
		end if;
	end process;

end Behavioral;

