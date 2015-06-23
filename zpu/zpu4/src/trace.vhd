-- ZPU
--
-- Copyright 2004-2008 oharboe - Øyvind Harboe - oyvind.harboe@zylin.com
-- 
-- The FreeBSD license
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimer in the documentation and/or other materials
--    provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE ZPU PROJECT ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation
-- are those of the authors and should not be interpreted as representing
-- official policies, either expressed or implied, of the ZPU Project.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

library work;
use work.zpu_config.all;
use work.zpupkg.all;
use work.txt_util.all;
 
 
entity trace is
  generic (
           log_file:       string  := "trace.txt"
          );
  port(
       	clk         : in std_logic;
       	begin_inst  : in std_logic;
       	pc          : in std_logic_vector(maxAddrBitIncIO downto 0);
		opcode		: in std_logic_vector(7 downto 0);
		sp			: in std_logic_vector(maxAddrBitIncIO downto 2);
		memA		: in std_logic_vector(wordSize-1 downto 0);
		memB		: in std_logic_vector(wordSize-1 downto 0);
		busy  : in std_logic;
		intSp		: in std_logic_vector(stack_bits-1 downto 0)
		);
end trace;
   
   
architecture behave of trace is
  
  
file 		l_file		: TEXT open write_mode is log_file;


begin


-- write data and control information to a file

receive_data: process

variable l: line;
variable t	: std_logic_vector(wordSize-1 downto 0);
variable t2	: std_logic_vector(maxAddrBitIncIO downto 0);
variable counter : unsigned(63 downto 0);
   
   
   
begin                                       

	t:= (others => '0');
	t2:= (others => '0');

counter := (others => '0');
   -- print header for the logfile
   print(l_file, "#pc,opcode,sp,top_of_stack ");
   print(l_file, "#----------");
   print(l_file, " ");

	wait until clk = '1';
	wait until clk = '0'; 

   while true loop

		counter := counter + 1;
		if begin_inst = '1' then
			t(maxAddrBitIncIO downto 2):=sp;
			t2:=pc;
     		print(l_file, "0x" & hstr(t2) & " 0x" & hstr(opcode) & " 0x" & hstr(t) & " 0x" & hstr(memA) & " 0x" & hstr(memB) & " 0x" & hstr(intSp) & " 0x" & hstr(std_logic_vector(counter)));
		end if;
		
     	wait until clk = '0';
    
   end loop;

 end process receive_data;



end behave;
 
