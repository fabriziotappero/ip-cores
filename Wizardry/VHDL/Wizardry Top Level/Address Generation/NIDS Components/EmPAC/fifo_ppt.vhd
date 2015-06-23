----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:46:53 03/07/2008 
-- Design Name: 
-- Module Name:    fifo_2_clock - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo_ppt is
    Port ( reset : in  STD_LOGIC;
			  push_clock : in  STD_LOGIC;
           push : in  STD_LOGIC;
           fifo_data_in : in std_logic_vector(24 downto 0);
			  full : out  STD_LOGIC;
			  pop_clock : in  STD_LOGIC;
           pop : in  STD_LOGIC;
			  fifo_data_out : out std_logic_vector(24 downto 0);
           empty : out  STD_LOGIC;
			  fifo_push_count : out std_logic_vector(11 downto 0)); 
end fifo_ppt;

architecture Behavioral of fifo_ppt is

--constant MAX_FIFO_SIZE : INTEGER := 16;
--
--signal clk_div_s : std_logic := '0';

signal almostfull,almostempty : std_logic;
signal unconnected : std_logic_vector(31 downto 0);-- := X"00000000";
signal rdcount : std_logic_vector(11 downto 0);
signal wrcount : std_logic_vector(11 downto 0);
signal wrerr : std_logic;
signal rderr : std_logic;
signal reset_int : std_logic;
signal dop : std_logic_vector(3 downto 0);
signal data_in : std_logic_Vector(31 downto 0);
signal reset_s : std_logic;
begin

fifo_data_out <= unconnected(24 downto 0);
data_in <= "0000000" & fifo_data_in;
--process(phy_clock)
--begin
--	if rising_edge(phy_clock) then
--		clk_div_s <= not clk_div_s;
--	end if;
--end process; 

process(push_clock,reset)
begin
if(reset = '1') then 
	reset_s <= '1';
elsif(push_clock'event and push_clock= '1') then
	reset_s <= '0'; 
end if;
end process;

--process(push_clock)
--  begin
--    if(push_clock'event and push_clock = '1') then
--      reset_s <= reset;
--    end if;
--  end process;

FIFO16_inst : FIFO16
   generic map (
      ALMOST_FULL_OFFSET => X"080",  -- Sets almost full threshold
      ALMOST_EMPTY_OFFSET => X"080", -- Sets the almost empty threshold
      DATA_WIDTH => 36, -- Sets data width to 4, 9, 18, or 36
      FIRST_WORD_FALL_THROUGH => FALSE) -- Sets the FIFO FWFT to TRUE or FALSE
   port map (
      ALMOSTEMPTY => ALMOSTEMPTY,   -- 1-bit almost empty output flag
      ALMOSTFULL => ALMOSTFULL,     -- 1-bit almost full output flag
      DO =>  unconnected,                    -- 32-bit data output
      DOP => DOP,                   -- 4-bit parity data output
      EMPTY => EMPTY,               -- 1-bit empty output flag
      FULL => FULL,                 -- 1-bit full output flag
      RDCOUNT => RDCOUNT,           -- 12-bit read count output
      RDERR => RDERR,               -- 1-bit read error output
      WRCOUNT => fifo_push_count,--WRCOUNT,           -- 12-bit write count output
      WRERR => WRERR,               -- 1-bit write error
      DI => data_in,                     -- 32-bit data input
      DIP => X"0",--DIP,                   -- 4-bit partity input
      RDCLK => pop_clock,               -- 1-bit read clock input
      RDEN => pop,                 -- 1-bit read enable input
      RST => reset_s, --reset,                   -- 1-bit reset input
      WRCLK => push_clock,               -- 1-bit write clock input
      WREN => push                  -- 1-bit write enable input
   );
--process(push_clock,reset)
--begin
--	if rising_edge(push_clock) then
--		if reset = '1' then
--			reset_int <= '1';
--		else
--			reset_int <= '0';
--		end if;
--	end if;
--end process;

end Behavioral;



--
--process(clk_div_s,reset)
--begin
--	if rising_edge(clk_div_s) then
--		reset_2 <= reset;
--	end if;
--end process;
--
--
--
--process(push,phy_clock,reset)
--begin
--	if rising_edge(phy_clock) then
--		if reset = '1' then
--			push_count <= 0;
--		elsif push = '1' then
--			push_count <= push_count + 1;
--		else
--			push_count <= push_count;
--		end if;
--	end if;
--end process;
--
--process(pop,clk_div_s,reset)
--begin
--	if rising_Edge(clk_div_s) then
--		if reset_2 = '1' then
--			pop_count <= 0;
--		elsif pop = '1' then
--			pop_count <= pop_count + 1;
--		else
--			pop_count <= pop_count;
--		end if;
--	end if;
--end process;
--
--full_s <= '1' when (push_count - pop_count) = MAX_FIFO_SIZE else '0';
--empty_s <= '1' when (push_count - pop_count) = 0;
--
--process(clk_div_s)
--begin
--	if rising_edge(clk_div_s) then
--		full <= full_s;
--	end if;
--end process;
