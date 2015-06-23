--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- Title       : SUB_RAMZ                                                         --
-- Design      : EV_JPEG_ENC                                                         --
-- Author      : Michal Krepa                                                 --                                                             --                                                           --
--                                                                            --
--------------------------------------------------------------------------------
--
-- File        : SUB_RAMZ.VHD
-- Created     : 22/03/2009
--
--------------------------------------------------------------------------------
--
--  Description : RAM memory simulation model
--
--------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use IEEE.NUMERIC_STD.all;
use IEEE.std_logic_textio.all;

library std;
use std.textio.all;	
  
  
entity SUB_RAMZ_LUT is  
  generic 
    ( 
      RAMADDR_W     : INTEGER := 6;
      RAMDATA_W     : INTEGER := 12
    ); 
  port (      
        d                 : in  STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
        waddr             : in  STD_LOGIC_VECTOR(RAMADDR_W-1 downto 0);
        raddr             : in  STD_LOGIC_VECTOR(RAMADDR_W-1 downto 0);
        we                : in  STD_LOGIC;
        clk               : in  STD_LOGIC;
        
        q                 : out STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0)
  );
end SUB_RAMZ_LUT;   

architecture RTL of SUB_RAMZ_LUT is
  type mem_type is array ((2**RAMADDR_W)-1 downto 0) of 
                              STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
										
--type mem_type is array (( 1296*8)-1 downto 0) of --/*1296*8*/
  --                          STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
  
  impure function InitRamFromFile (RamFileName : in string) return mem_type is 
		FILE RamFile : text is in RamFileName; 
		variable RamFileLine : line; 
		variable RAM : mem_type; 
	begin 
		for I in 0 to (2**RAMADDR_W)-1 loop 
			readline (RamFile, RamFileLine); 
			--Write (RamFileLine, I * 8);
			hread(RamFileLine, RAM(I));
			
			
			--write(   (I * 8),RamFileLine );
			--read (RamFileLine, RAM(I), LEFT, 10); 
		end loop; 
		return RAM; 
	end function; 
							 
  signal mem                    : mem_type := InitRamFromFile("../design/BufFifo/counter_8.txt") ;
  signal read_addr              : STD_LOGIC_VECTOR(RAMADDR_W-1 downto 0);
  
  --attribute ram_style: string;
  --attribute ram_style of mem : signal is "distributed"; 
  
 
begin       
  
  -------------------------------------------------------------------------------
  q_sg:
  -------------------------------------------------------------------------------
  q <= mem(TO_INTEGER(UNSIGNED(read_addr)));    
  
  -------------------------------------------------------------------------------
  read_proc: -- register read address
  -------------------------------------------------------------------------------
  process (clk)
  begin 
    if clk = '1' and clk'event then        
      read_addr <= raddr;
    end if;  
  end process;
  
  -------------------------------------------------------------------------------
  write_proc: --write access
  -------------------------------------------------------------------------------
  process (clk) begin
    if clk = '1' and clk'event then
      if we = '1'  then
        mem(TO_INTEGER(UNSIGNED(waddr))) <= d;
      end if;
    end if;
  end process;
    
end RTL;