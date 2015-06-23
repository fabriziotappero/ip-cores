------------------------------------------------------------------
-- Universal dongle board source code
-- 
-- Copyright (C) 2006 Artec Design <jyrit@artecdesign.ee>
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

entity flash_if is
  port (
    clk       : in  std_logic;
    reset_n   : in  std_logic;
    --flash Bus
    fl_addr   : out std_logic_vector(23 downto 0);
    fl_ce_n      : out std_logic;       --chip select	(timing is very chip dependent)
    fl_oe_n      : out std_logic;       --output enable for flash (timing is very chip dependent)
    fl_we_n      : out std_logic;       --write enable (timing is very chip dependent)
    fl_data      : inout std_logic_vector(15 downto 0);
    fl_rp_n      : out std_logic;       --reset signal
    fl_byte_n      : out std_logic;       --hold in byte mode
    fl_sts       : in std_logic;        --status signal
    -- mem Bus
    mem_addr  : in std_logic_vector(23 downto 0);
    mem_do    : out std_logic_vector(15 downto 0);
    mem_di    : in  std_logic_vector(15 downto 0);
     
    mem_wr    : in  std_logic;  --write not read signal
    mem_val   : in  std_logic;
    mem_ack   : out std_logic
    ); 
end flash_if;

		
architecture RTL of flash_if is
 type state_type is (RESETs,FLREADs,FLWRITEs,WAITs);
  signal CS : state_type;  
  signal fl_cnt : std_logic_vector(3 downto 0);
  signal  fl_oe_nd      : std_logic;       --output enable for flash
begin

fl_rp_n <= reset_n;                     --make flash reset
fl_addr <= mem_addr(23 downto 0);
fl_byte_n <= '0';                       --all byte accesses


fl_oe_n<=fl_oe_nd;
fl_data <= mem_di when fl_oe_nd ='1' else
          (others =>'Z');


  
RD: process (clk, reset_n)
begin  -- process READ
  if reset_n='0' then
     fl_oe_nd <='1';
	 CS <= RESETs;
	 fl_cnt <= (others=>'0');
	 mem_do <= (others=>'0');
	 mem_ack <='0';
   elsif clk'event and clk = '1' then    -- rising clock edge
		case CS is
			when RESETs =>	
				 mem_ack <='0';
				 fl_ce_n <= (not mem_val);                 --chipselect 4 flash
				 fl_we_n <= (not (mem_val and mem_wr));  --write enable 4 flash
				 if mem_val='1' and mem_wr = '0' then --READ
					fl_oe_nd <='0';
					fl_cnt <= (others=>'0');
					CS <= FLREADs;
				 elsif mem_val='1' and mem_wr = '1' then --WRITE
					fl_oe_nd <='1';
					fl_cnt <= (others=>'0');
					CS <= FLWRITEs;
				 end if;   --elsif mem_cmd
			when FLREADs =>	
				fl_cnt <= fl_cnt + 1;
				if fl_cnt=x"3" then --3 cycles later
					mem_ack <='1';
					mem_do <= fl_data;	--registered is nicer
				elsif fl_cnt=x"4" then --4 cycles later
					mem_ack <='0';
					fl_oe_nd <='1';
					CS <= WAITs;
				end if;
			when FLWRITEs =>		
				fl_cnt <= fl_cnt + 1;
				if fl_cnt=x"3" then --3 cycles later
					mem_ack <='1';
				elsif fl_cnt=x"4" then --4 cycles later
					mem_ack <='0';
					CS <= WAITs;
				end if;	
			when WAITs =>
				if 	mem_val='0' then -- wait untill val is removed
					CS <= RESETs;
				end if;
	  	end case;	
 
  end if;                               --system
end process RD;
  



end RTL;

