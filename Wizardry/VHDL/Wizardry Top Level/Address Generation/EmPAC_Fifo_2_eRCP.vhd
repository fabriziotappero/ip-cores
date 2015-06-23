----------------------------------------------------------------------------------
--
--  This file is a part of Technica Corporation Wizardry Project
--
--  Copyright (C) 2004-2009, Technica Corporation  
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Module Name: EmPAC_to_eRCP - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Wrapper for a Xilinx FIFO primitive.
-- Revision: 1.0
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

entity EmPAC_to_eRCP is
    Port ( reset : in  STD_LOGIC;
			  push_clock : in  STD_LOGIC;
			  pop_clock : in  STD_LOGIC;
           push : in  STD_LOGIC;
			  pop : in  STD_LOGIC;
           fifo_data_in : in std_logic_vector(31 downto 0);
			  fifo_data_out : out std_logic_vector(31 downto 0);
--			  rdcount : out std_logic_vector(11 downto 0);
--			  wrcount : out std_logic_vector(11 downto 0);
--			  almost_empty : out  std_logic;
--			  almost_full : out std_logic;
           empty : out  STD_LOGIC
--			  ;
--			  full : out  STD_LOGIC
			  ); 
end EmPAC_to_eRCP;

architecture Behavioral of EmPAC_to_eRCP is

--signal almostfull,almostempty : std_logic;
signal unconnected_4bit : std_logic_vector(3 downto 0);-- := X"00000000";
--signal rdcount : std_logic_vector(11 downto 0);
--signal wrcount : std_logic_vector(11 downto 0);
signal wrerr : std_logic;
signal rderr : std_logic;
signal reset_int : std_logic;
signal rst_r : std_logic;
signal almost_empty,almost_full,full : std_logic;
signal rdcount,wrcount :  std_logic_vector(11 downto 0);

begin 

--FIFO16_inst : FIFO16
--   generic map (
--      ALMOST_FULL_OFFSET => X"080",  -- Sets almost full threshold
--      ALMOST_EMPTY_OFFSET => X"080", -- Sets the almost empty threshold
--      DATA_WIDTH => 36, -- Sets data width to 4, 9, 18, or 36
--      FIRST_WORD_FALL_THROUGH => FALSE) -- Sets the FIFO FWFT to TRUE or FALSE
--   port map (
--      ALMOSTEMPTY => ALMOSTEMPTY,   -- 1-bit almost empty output flag
--      ALMOSTFULL => ALMOSTFULL,     -- 1-bit almost full output flag
--      DO => DO,                     -- 32-bit data output
--      DOP => DOP,                   -- 4-bit parity data output
--      EMPTY => EMPTY,               -- 1-bit empty output flag
--      FULL => FULL,                 -- 1-bit full output flag
--      RDCOUNT => RDCOUNT,           -- 12-bit read count output
--      RDERR => RDERR,               -- 1-bit read error output
--      WRCOUNT => WRCOUNT,           -- 12-bit write count output
--      WRERR => WRERR,               -- 1-bit write error
--      DI => DI,                     -- 32-bit data input
--      DIP => DIP,                   -- 4-bit partity input
--      RDCLK => RDCLK,               -- 1-bit read clock input
--      RDEN => RDEN,                 -- 1-bit read enable input
--      RST => RST,                   -- 1-bit reset input
--      WRCLK => WRCLK,               -- 1-bit write clock input
--      WREN => WREN                  -- 1-bit write enable input
--   );

process(push_clock)
  begin
    if(push_clock'event and push_clock = '1') then
      rst_r <= reset;
    end if;
  end process;

FIFO_1 : FIFO16
   generic map (
      ALMOST_FULL_OFFSET => X"00F",  -- Sets almost full threshold
      ALMOST_EMPTY_OFFSET => X"007", -- Sets the almost empty threshold
      DATA_WIDTH => 36, -- Sets data width to 4, 9, 18, or 36
      FIRST_WORD_FALL_THROUGH => FALSE) --Sets the FIFO FWFT to TRUE or FALSE
   port map (
      ALMOSTEMPTY => ALMOST_EMPTY, -- 1-bit almost empty output flag
      ALMOSTFULL => ALMOST_FULL,   -- 1-bit almost full output flag
      DO => fifo_data_out,--DO,      -- 4-bit data output
      DOP => unconnected_4bit,--unconnected (31 downto 28), -- 4-bit Unused parity data output. Unconnected is a signal of 32 bits
      EMPTY => EMPTY,             -- 1-bit empty output flag
      FULL => FULL,               -- 1-bit full output flag
      RDCOUNT => RDCOUNT,         -- 12-bit read count output
      RDERR => open,--RDERR,             -- 1-bit read error output
      WRCOUNT => WRCOUNT,         -- 12-bit write count output
      WRERR => open,--WRERR,             -- 1-bit write error
      DI => fifo_data_in,         -- 32-bit data input
      DIP => X"0",       			 -- 4-bit Unused parity inputs tied to ground
      RDCLK => pop_clock,         -- 1-bit read clock input
      RDEN => pop,--RDEN,         -- 1-bit read enable input
      RST => rst_r, --'0',--reset,                 -- 1-bit reset input
      WRCLK => push_clock,        -- 1-bit write clock input
      WREN => push   			    -- 1-bit write enable input
   );

end Behavioral;
