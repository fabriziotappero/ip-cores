--|-----------------------------------------------------------------------------
--| UNSL - Modular Oscilloscope
--|
--| File: eppwbn_test.vhd
--| Version: 0.10
--| Targeted device: Actel A3PE1500 
--|-----------------------------------------------------------------------------
--| Description:
--|   EPP - Wishbone bridge. 
--|	  This file is only for test purposes
--|   
--------------------------------------------------------------------------------
--| File history:
--|   0.10   | jan-2008 | First release
--------------------------------------------------------------------------------
--| Copyright ® 2008, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.eppwbn_pkg.all;



entity eppwbn_test is
  port(
    -- al puerto EPP
    nStrobe:    in std_logic;											-- Nomenclatura IEEE Std. 1284 
                                                -- HostClk/nWrite 
    Data:       inout std_logic_vector (7 downto 0); 	-- AD8..1 (Data1..Data8)
    nAck:       out std_logic; 												--  PtrClk/PeriphClk/Intr
    busy:       out std_logic; 												--  PtrBusy/PeriphAck/nWait
    PError:     out std_logic; 										--  AckData/nAckReverse
    Sel:        out std_logic; 										--  XFlag (Select)
    nAutoFd:    in std_logic; 										--  HostBusy/HostAck/nDStrb
    PeriphLogicH: out std_logic; 								--  (Periph Logic High)
    nInit:      in std_logic; 										--  nReverseRequest
    nFault:     out std_logic;										--  nDataAvail/nPeriphRequest
    nSelectIn:  in std_logic;										--  1284 Active/nAStrb
    
    -- a los switches
    rst:        in std_logic;
    
    -- al clock
    clk:        in std_logic
	
	-- a los leds
    --epp_mode: out std_logic_vector(1 downto 0);
	  --nAck_monitor:       out std_logic; 	
    --busy_monitor:       out std_logic; 	
    --PError_monitor:     out std_logic; 	
    --Sel_monitor:        out std_logic; 	
    --nFault_monitor:     out std_logic;
    -- nAutoFd_monitor:   out std_logic; 	
    -- nInit_monitor:      out std_logic; 
    -- nSelectIn_monitor:  out std_logic;
    -- nStrobe_monitor:    out std_logic			
    --PeriphLogicH_monitor: out std_logic; 
	);
end eppwbn_test;

architecture eppwbn_test_arch0 of eppwbn_test is
  
  signal DAT_I_master:  std_logic_vector (7 downto 0);
  signal DAT_O_master:  std_logic_vector (7 downto 0);
  signal ADR_O_master:  std_logic_vector (7 downto 0);
  signal CYC_O_master:  std_logic;  
  signal STB_O_master:  std_logic;  
  signal ACK_I_master:  std_logic;
  signal WE_O_master:   std_logic;
  signal clk_pll:   std_logic;
  
begin 

  SL_MEM1: eppwbn_test_wb_side 
  port map(
      RST_I => rst,
      CLK_I => clk_pll,
      DAT_I => DAT_O_master,
      DAT_O => DAT_I_master,
      ADR_I => ADR_O_master,
      CYC_I => CYC_O_master,
      STB_I => STB_O_master,
      ACK_O => ACK_I_master,
      WE_I  => WE_O_master
    );

    
  
  MA_EPP: eppwbn port map(
      -- Externo
      nStrobe   => nStrobe,                                            
      Data      => Data,
      nAck      => nAck,
      busy      => busy,
      PError    => PError,
      Sel       => Sel,
      nAutoFd   => nAutoFd,
      PeriphLogicH => PeriphLogicH,
      nInit     => nInit,
      nFault    => nFault,
      nSelectIn => nSelectIn,
      --  Interno
      RST_I => rst,
      CLK_I => clk_pll,
      DAT_I => DAT_I_master,
      DAT_O => DAT_O_master,
      ADR_O => ADR_O_master,
      CYC_O => CYC_O_master,
      STB_O => STB_O_master,
      ACK_I => ACK_I_master,
      WE_O  => WE_O_master
    );
  
  PLL_0: pll port map(
    GLB => clk_pll,
    CLK => clk
    );
  
end architecture eppwbn_test_arch0;