--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--
-- Title       : MDCT_TB
-- Design      : MDCT Core
-- Author      : Michal Krepa
--
--------------------------------------------------------------------------------
--
-- File        : MDCT_TB.VHD
-- Created     : Sat Mar 5 2006
--
--------------------------------------------------------------------------------
--
--  Description : Testbench top-level
--
--------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
library WORK;
  use WORK.MDCT_PKG.all;

entity TB_MDCT is
end TB_MDCT;

--**************************************************************************--

architecture TB of TB_MDCT is

------------------------------
-- MDCT
------------------------------
component MDCT	 
	port(	  
		clk          : in STD_LOGIC;  
		rst          : in std_logic;
    dcti         : in std_logic_vector(IP_W-1 downto 0);
    idv          : in STD_LOGIC;

    odv          : out STD_LOGIC;
		dcto         : out std_logic_vector(COE_W-1 downto 0);
      -- debug
    odv1         : out STD_LOGIC;
    dcto1        : out std_logic_vector(OP_W-1 downto 0) 
		);
end component;

------------------------------
-- Clock generator
------------------------------
component CLKGEN
  port (   
        clk               : out STD_LOGIC
       );
end component;

------------------------------
-- Input image generator
------------------------------
component INPIMAGE
  port (   
        clk               : in STD_LOGIC;
        odv1              : in STD_LOGIC;
        dcto1             : in STD_LOGIC_VECTOR(OP_W-1 downto 0);
        odv               : in STD_LOGIC;
        dcto              : in STD_LOGIC_VECTOR(COE_W-1 downto 0);
        
        rst               : out STD_LOGIC;
        imageo            : out STD_LOGIC_VECTOR(IP_W-1 downto 0);
        dv                : out STD_LOGIC;
        testend           : out BOOLEAN
       );
end component;

signal clk_s               : STD_LOGIC;   
signal clk_gen_s           : STD_LOGIC;  
signal gate_clk_s          : STD_LOGIC;    
signal rst_s               : STD_LOGIC;     
signal dcti_s              : STD_LOGIC_VECTOR(IP_W-1 downto 0); 
signal idv_s               : STD_LOGIC;

signal odv_s               : STD_LOGIC;
signal dcto_s              : STD_LOGIC_VECTOR(COE_W-1 downto 0);
signal odv1_s              : STD_LOGIC;
signal dcto1_s             : STD_LOGIC_VECTOR(OP_W-1 downto 0);
signal testend_s           : BOOLEAN;

------------------------------
-- architecture begin
------------------------------       
begin
------------------------------
-- MDCT port map
------------------------------
U_MDCT : MDCT
  port map(	  
		  clk          => clk_s,         
		  rst          => rst_s,      
      dcti         => dcti_s,   
      idv          => idv_s,  
   
      odv          => odv_s,
      dcto         => dcto_s,
      odv1         => odv1_s,
      dcto1        => dcto1_s
		);


------------------------------
-- CLKGEN map
------------------------------
U_CLKGEN : CLKGEN
  port map (   
        clk        => clk_gen_s       
       );
    


------------------------------
-- Input image generator
------------------------------
U_INPIMAGE : INPIMAGE
  port map (   
        clk       => clk_s,        
        odv1      => odv1_s,
        dcto1     => dcto1_s,
        odv       => odv_s,
        dcto      => dcto_s,                
        
        rst       => rst_s,        
        imageo    => dcti_s,        
        dv        => idv_s,
        testend   => testend_s        
       );

gate_clk_s <= '0' when testend_s = false else '1';

clk_s <= clk_gen_s and (not gate_clk_s);

end TB;
-----------------------------------

------------------------------
-- configuration begin
------------------------------
configuration CONF_MDCT of TB_MDCT is
  for TB
  
    for U_MDCT : MDCT
      use entity WORK.MDCT(RTL);
    end for;
    
    for U_INPIMAGE : INPIMAGE
      use entity WORK.INPIMAGE(SIM);
    end for;
    
    for U_CLKGEN : CLKGEN
      use entity WORK.CLKGEN(SIM);
    end for;
    
  end for;
end CONF_MDCT;

configuration CONF_MDCT_TIMING of TB_MDCT is
  for TB
  
    for U_MDCT : MDCT
      use entity WORK.MDCT(STRUCTURE);
    end for;
    
    for U_INPIMAGE : INPIMAGE
      use entity WORK.INPIMAGE(SIM);
    end for;
    
    for U_CLKGEN : CLKGEN
      use entity WORK.CLKGEN(SIM);
    end for;
    
  end for;
end CONF_MDCT_TIMING;
--**************************************************************************--
