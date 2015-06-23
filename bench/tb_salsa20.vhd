--
-- Copyright 2012 iQUBE research
--
-- This file is part of Salsa20IpCore.
--
-- Salsa20IpCore is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Salsa20IpCore is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with Salsa20IpCore.  If not, see <http://www.gnu.org/licenses/>.
--
-- contact: Rúa Fonte das Abelleiras s/n, Campus Universitario de Vigo, 36310, Vigo (Spain)
-- e-mail: lukasz.dzianach@iqube.es, info@iqube.es
-- 

LIBRARY ieee  ; 
LIBRARY std  ; 
library modelsim_lib;

USE ieee.numeric_std.all  ; 
USE ieee.std_logic_1164.all  ; 
USE ieee.std_logic_textio.all  ; 
USE ieee.std_logic_unsigned.all  ; 
USE std.textio.all  ; 
use ieee.std_logic_arith.all;
use modelsim_lib.util.all;

ENTITY \tb_salsaa.vhd\  IS 
  generic (
      log_file_name : string := "log.txt"
    );
END ; 
 
ARCHITECTURE \tb_salsaa.vhd_arch\   OF \tb_salsaa.vhd\   IS
  SIGNAL data_req   :  std_logic  ; 
  SIGNAL key   :  std_logic_vector (255 downto 0)  ; 
  SIGNAL data   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL start   :  std_logic  ; 
  SIGNAL clk   :  std_logic  ; 
  SIGNAL data_valid   :  std_logic  ; 
  SIGNAL nonce   :  std_logic_vector (63 downto 0)  ; 
  SIGNAL reset   :  std_logic  ; 
  COMPONENT salsaa  
    PORT ( 
      data_req  : in std_logic ; 
      key  : in std_logic_vector (255 downto 0) ; 
      data  : out std_logic_vector (31 downto 0) ; 
      start  : in std_logic ; 
      clk  : in std_logic ; 
      data_valid  : out std_logic ; 
      nonce  : in std_logic_vector (63 downto 0) ; 
      reset  : in std_logic ); 
  END COMPONENT ; 
  file log_file : TEXT open write_mode is log_file_name;
  variable l : string;

BEGIN


  DUT  : salsaa  
    PORT MAP ( 
      data_req   => data_req  ,
      key   => key  ,
      data   => data  ,
      start   => start  ,
      clk   => clk  ,
      data_valid   => data_valid  ,
      nonce   => nonce  ,
      reset   => reset   ) ; 

key  <= x"201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a090807060504030201"  ;
nonce  <= x"0000000000000000"  ;


-- "Clock Pattern" : dutyCycle = 50
-- Start Time = 0 ps, End Time = 1 us, Period = 6666 ps
  Process
	Begin
	 clk  <= '0'  ;
	wait for 3333 ps ;
-- 3333 ps, single loop till start period.
	for Z in 1 to 3000
	loop
	    clk  <= '1'  ;
	   wait for 3333 ps ;
	    clk  <= '0'  ;
	   wait for 3333 ps ;
-- 996567 ps, repeat pattern in loop.
	end  loop;
	 clk  <= '1'  ;
	wait for 3333 ps ;
	 clk  <= '0'  ;
	wait for 100 ps ;
-- dumped values till 1 us
	wait;
 End Process;

 -- "Constant Pattern"
-- Start Time = 0 ps, End Time = 1 us, Period = 0 ps
  Process
	Begin
	 reset  <= '0'  ;
	wait for 15879 ps ;
	 reset  <= '1'  ;
	wait for 17864 ps ;
	 reset  <= '0'  ;
	wait for 4000000 ps ;
-- dumped values till 1 us
	wait;
 End Process;


-- "Constant Pattern"
-- Start Time = 0 ps, End Time = 1 us, Period = 0 ps
  Process
	Begin
	 start  <= '0'  ;
	wait for 33330 ps ;
	 start  <= '1'  ;
	wait for 33330 ps +3333 ps ;
	 start  <= '0'  ;
	wait for 33330 ps+6666 ps;
-- dumped values till 1 us
	wait;
 End Process;

-- "Constant Pattern"
-- Start Time = 0 ps, End Time = 1 us, Period = 0 ps
  Process
	Begin
	 data_req  <= '0'  ;
	wait for 589941 ps ;
	 data_req  <= '1'  ;
	wait for 6666 ps ;
	 data_req  <= '0'  ;
	wait for 6666 ps ;
	for Z in 1 to 300
	loop
			data_req  <= '1'  ;
		wait for 6666 ps ;
		 data_req  <= '0'  ;
		wait for 6666 ps ;
	end  loop;	
	 data_req  <= '1'  ;
	wait for 6666 ps ;
	 data_req  <= '0'  ;
	wait for 4000000 ps ;
-- dumped values till 1 us
	wait;
 End Process;

-- results to file 
process
begin


for Z in 1 to 3000 loop
	wait until clk = '1';
	if data_valid = '1' then
		write(l,hstr(data));
		writeline(log_file,l);
	end if;
	wait until clk = '0';
end loop;


end process;


END;
