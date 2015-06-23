--|-----------------------------------------------------------------------------
--| UNSL - Modular Oscilloscope
--|
--| File: eppwbn_test_wb_side.vhd
--| Version: 0.10
--| Targeted device: Actel A3PE1500 
--|-----------------------------------------------------------------------------
--| Description:
--|   EPP - Wishbone bridge. 
--|	  This file is only for test purposes
--|   It only stores data in regiters with wishbone interconect
--------------------------------------------------------------------------------
--| File history:
--|   0.10   | dic-2008 | First release
--------------------------------------------------------------------------------
--| Copyright ® 2008, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.eppwbn_pkg.all;
--use IEEE.STD_LOGIC_ARITH.ALL;


entity eppwbn_test_wb_side is
  port(
    RST_I:  in std_logic;  
    CLK_I:  in std_logic;  
    DAT_I:  in std_logic_vector (7 downto 0);
    DAT_O:  out std_logic_vector (7 downto 0);
    ADR_I:  in std_logic_vector (7 downto 0);
    CYC_I:  in std_logic;  
    STB_I:  in std_logic;  
    ACK_O:  out std_logic ;
    WE_I:   in std_logic
	);
end eppwbn_test_wb_side;

architecture eppwbn_test_wb_arch0 of eppwbn_test_wb_side is
  signal auto_ack: std_logic;
begin 
      
  MEM1: test_memory 
  generic map(
    DEFAULT_OUT => '0';
    ADD_WIDTH => 8;
    WIDTH  => 8
  port map (
    cs => auto_ack,
    clk => CLK_I,
    reset => RST_I,
    add => ADR_I,    
    Data_In => DAT_I,
    Data_Out => DAT_O,
    WR => WE_I
  );
  auto_ack <= CYC_I and STB_I;
  ACK_O <= auto_ack;
  
 
  
end architecture eppwbn_test_wb_arch0;