--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- Title       : RAM                                                          --
-- Design      : MDCT                                                         --
-- Author      : Michal Krepa                                                 --                                                             --                                                           --
--                                                                            --
--------------------------------------------------------------------------------
--
-- File        : RAM.VHD
-- Created     : Sat Mar 5 7:37 2006
--
--------------------------------------------------------------------------------
--
--  Description : RAM memory simulation model
--
--------------------------------------------------------------------------------

-- 5:3 row select
-- 2:0 col select

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  
library WORK;
  use WORK.MDCT_PKG.all;
  
entity RAM is   
  port (      
        d                 : in  STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
        waddr             : in  STD_LOGIC_VECTOR(RAMADRR_W-1 downto 0);
        raddr             : in  STD_LOGIC_VECTOR(RAMADRR_W-1 downto 0);
        we                : in  STD_LOGIC;
        clk               : in  STD_LOGIC;
        
        q                 : out STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0)
  );
end RAM;   

architecture RTL of RAM is
  type mem_type is array ((2**RAMADRR_W)-1 downto 0) of 
                              STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
  signal mem                    : mem_type;
  signal read_addr              : STD_LOGIC_VECTOR(RAMADRR_W-1 downto 0);
  
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