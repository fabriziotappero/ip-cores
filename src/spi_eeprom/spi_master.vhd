------------------------------------------------------------------
-- Universal dongle board source code
-- 
-- Copyright (C) 2008 Artec Design <jyrit@artecdesign.ee>
-- 
-- This source code is free hardware; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
-- 
-- This source code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-- 
-- 
-- The complete text of the GNU Lesser General Public License can be found in 
-- the file 'lesser.txt'.


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity spi_if is
  port (
    clk       : in  std_logic;
    reset_n   : in  std_logic;
	--------------------------
	-- EEPROM signals
	ee_do	   : out std_logic;
	ee_di      : in  std_logic;
	ee_hold_n  : out std_logic;
	ee_cs_n    : out std_logic;
	ee_clk     : out std_logic;
	ee_wrp_n   : out std_logic;	--write protect signal active low
	-- Mem bus
    mem_addr  : in std_logic_vector(23 downto 0);
    mem_do    : out std_logic_vector(15 downto 0);
    mem_di    : in  std_logic_vector(15 downto 0);
     
    mem_wr    : in  std_logic;  --write not read signal
    mem_val   : in  std_logic;
    mem_ack   : out std_logic	
	
    ); 
end spi_if;

		
architecture RTL of spi_if is
  type state_type is (RESETs,SPI_CYCLEs,WAITs);
  signal CS : state_type;  

  signal spi_cnt    : std_logic_vector(4 downto 0);
  signal spi_shiftr : std_logic_vector(0 to 23);
  signal spi_wren_done : std_logic;

  
  constant SPI_READ    : std_logic_vector(0 to 2):="011";
  constant SPI_WRITE   : std_logic_vector(0 to 2):="010";
  constant SPI_SET_WEN : std_logic_vector(0 to 2):="110";
  constant SPI_CLR_WEN : std_logic_vector(0 to 2):="100";


begin


ee_do <= spi_shiftr(0);
  
SPI_SM: process (clk, reset_n)
begin  -- process READ
	if reset_n='0' then
		ee_cs_n <='1';
		CS <= RESETs;
		ee_clk <='0';
		ee_wrp_n <='1';  --active low write protect
		ee_hold_n <='1';
		spi_wren_done <='0';
		spi_cnt <=(others=>'0');
    elsif clk'event and clk = '1' then    -- rising clock edge

		case CS is
			when RESETs =>	
				 mem_ack <='0';
				 ee_cs_n <= (not mem_val);                 --chipselect 4 spi
				 fl_we_n <= (not (mem_val and mem_wr));  --write enable 4 flash
				 if spi_wren_done ='0' then
					spi_cnt <= "01111";  --only 8 bit command needs to be sent
					spi_shiftr(0 to 3) <="0000";
					spi_shiftr(4) <= '0';
					spi_shiftr(5 to 7) <= SPI_SET_WEN;
					CS <= SPI_CYCLEs;					
				 elsif mem_val='1' and mem_wr = '0' then --READ
					spi_cnt <=(others=>'0');
					spi_shiftr(0 to 3) <="0000";
					spi_shiftr(4) <= mem_addr(8);
					spi_shiftr(5 to 7) <= SPI_READ;
					spi_shiftr(8 to 15) <= mem_addr(7 downto 0);
					CS <= SPI_CYCLEs;
				 elsif mem_val='1' and mem_wr = '1' then --WRITE
					spi_cnt <=(others=>'0');
					spi_shiftr(0 to 3) <="0000";
					spi_shiftr(4) <= mem_addr(8);
					spi_shiftr(5 to 7) <= SPI_WRITE;
					spi_shiftr(8 to 15) <= mem_addr(7 downto 0);
					spi_shiftr(16 to 23) <= mem_di(7 downto 0);					
					CS <= SPI_CYCLEs;
				 end if;   --elsif mem_cmd
			when SPI_CYCLEs =>
				if spi_cnt < 24 then
					ee_clk <= not ee_clk;
				elsif
					mem_do <= x"00"&spi_shiftr(16 to 23); --this may be done always as this is don't care to all but read
					ee_clk <= '0';
					if spi_wren_done ='0' then
						spi_wren_done <='1';
						CS <= RESETs;
					else
						mem_ack <='1';
						CS <= WAITs;
					end if;
				end if;
				
				if ee_clk='1' then
					spi_shiftr <= spi_shiftr(1 to 23)&ee_di;
					spi_cnt <= spi_cnt + 1;
				end if;
			when WAITs =>	
				if 	mem_val='0' then -- wait untill val is removed
					mem_ack <='0';
					CS <= RESETs;
				end if;						
				
	  	end case;	
 
  end if;                               --system
end process SPI_SM;
  



end RTL;