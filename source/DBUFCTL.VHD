--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--
-- Title       : DBUFCTL
-- Design      : MDCT Core
-- Author      : Michal Krepa
--
--------------------------------------------------------------------------------
--
-- File        : DBUFCTL.VHD
-- Created     : Thu Mar 30 22:19 2006
--
--------------------------------------------------------------------------------
--
--  Description : Double buffer memory controller
--
--------------------------------------------------------------------------------
library IEEE;
  use IEEE.STD_LOGIC_1164.all;

library WORK;
  use WORK.MDCT_PKG.all;

entity DBUFCTL is	
	port(	  
		clk          : in STD_LOGIC;  
		rst          : in STD_LOGIC;
    wmemsel      : in STD_LOGIC;
    rmemsel      : in STD_LOGIC;
    datareadyack : in STD_LOGIC;
      
    memswitchwr  : out STD_LOGIC;
    memswitchrd  : out STD_LOGIC;
    dataready    : out STD_LOGIC      
		);
end DBUFCTL;

architecture RTL of DBUFCTL is
 
  signal memswitchwr_reg : STD_LOGIC;
  signal memswitchrd_reg : STD_LOGIC;
  
begin

  memswitchwr  <= memswitchwr_reg;
  memswitchrd  <= memswitchrd_reg;
  
  memswitchrd_reg <= rmemsel;

  MEM_SWITCH : process(clk,rst)
  begin
    if rst = '1' then   
      memswitchwr_reg <= '0'; -- initially mem 1 is selected
      dataready       <= '0';
    elsif clk = '1' and clk'event then
      memswitchwr_reg <= wmemsel;
      
      if wmemsel /= memswitchwr_reg then
        dataready <= '1';
      end if;
      
      if datareadyack = '1' then
        dataready <= '0';
      end if;
    end if;
  end process;
  
end RTL;
--------------------------------------------------------------------------------