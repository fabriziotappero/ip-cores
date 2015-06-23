 -------------------------------------------------------------------
-- Entity        : fas_insert
-- Description   : Inserts FAS word pattern in serial data
-- Input         : indata : serial in data
--               : clk : clock 2.048 MHz
--		     : reset : Reset
-- Output 	     : outdata out data with FAS word
--   		     : rd output which indicates data load              
------------------------------------------------------------
                 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_unsigned.all;
 
entity fas_insert is
 port(indata:in std_logic;
      TICLK: in std_logic;
 	   reset:in std_logic;
 	   tx_bitcnt:in std_logic_vector(11 downto 0);
 	   outdata:out std_logic
 	  );
end fas_insert;

architecture behave of fas_insert is
type statetype is (fas,nfas,channel); -- S0= zero time slot (FAS word) generation
                       -- S1= reading data channels
signal state: statetype;

begin
--------process for generating FAS word and reading channel data----------
stateproc:process(TICLK,reset)
variable reg: std_logic_vector(7 downto 0);
variable outInt:std_logic;
begin
if reset='1' then
   state<=fas;
  
	
elsif (TICLK'event and TICLK='1') then --- rising edge 

  case state is
       when fas =>
                     reg:="11011000"; -- FAS word X0011011
                		if (tx_bitcnt(7 downto 0)="00000111") then
	                    state<=channel;
		              end if;   
      	           outInt:=reg(conv_integer(tx_bitcnt(2 downto 0)));
  
       when channel =>
                  outInt:=indata;
                  if tx_bitcnt(8 downto 0)="011111111" then
						  state<=nfas;
						elsif tx_bitcnt(8 downto 0)="111111111" then
                    state<=fas;
						end if;
                    
       when nfas =>
		            reg:="00000010";-- NFAS word bit2 should be '1'
                	if (tx_bitcnt(7 downto 0)="00000111") then
	                   state<=channel;
		             end if;   
      	           outInt:=reg(conv_integer(tx_bitcnt(2 downto 0)));
              
     end case;

	outdata<=outInt;
 end if;
 end process;
 
-- clk_out<=intclk;
end behave;
