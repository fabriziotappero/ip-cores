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
        da                : in  STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
        db                : in  STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
        waddra            : in  STD_LOGIC_VECTOR(RAMADRR_W-1 downto 0);
        waddrb            : in  STD_LOGIC_VECTOR(RAMADRR_W-1 downto 0);
        raddr             : in  STD_LOGIC_VECTOR(RAMADRR_W-1 downto 0);
        wea               : in  STD_LOGIC;
        web               : in  STD_LOGIC;
        clk               : in  STD_LOGIC;
        
        q                 : out STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0)
  );
end RAM;   

architecture RTL of RAM is

  component ram_xil
	port (
	addra: IN std_logic_VECTOR(5 downto 0);
	addrb: IN std_logic_VECTOR(5 downto 0);
	clka: IN std_logic;
	clkb: IN std_logic;
	dina: IN std_logic_VECTOR(9 downto 0);
	dinb: IN std_logic_VECTOR(9 downto 0);
	douta: OUT std_logic_VECTOR(9 downto 0);
	wea: IN std_logic;
	web: IN std_logic);
  end component;

begin       
  U1 : ram_xil
		port map (
			addra => waddra,
			addrb => waddrb,
			clka => clk,
			clkb => clk,
			dina => da,
			dinb => db,
			douta => q,
			wea => wea,
			web => web);
  
    
end RTL;