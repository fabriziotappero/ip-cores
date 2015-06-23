--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- Title       : RAMZ                                                         --
-- Design      : MDCT                                                         --
-- Author      : Michal Krepa                                                 --                                                             --                                                           --
--                                                                            --
--------------------------------------------------------------------------------
--
-- File        : RAMZ.VHD
-- Created     : Sat Mar 5 7:37 2006
--
--------------------------------------------------------------------------------
--
--  Description : RAM memory simulation model
--
--------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  
entity RAMSIM is  
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
end RAMSIM;   

architecture RTL of RAMSIM is
  type mem_type is array ((2**RAMADDR_W)-1 downto 0) of 
                              STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
  
  signal read_addr              : STD_LOGIC_VECTOR(RAMADDR_W-1 downto 0);
  
begin       
  
  
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
  process (clk) 
    variable mem                    : mem_type;
  begin  
    if clk = '1' and clk'event then
      if we = '1'  then
        mem(TO_INTEGER(UNSIGNED(waddr))) := d;
      end if;
      q <= mem(TO_INTEGER(UNSIGNED(raddr)));    
    end if;
  end process;
    
end RTL;