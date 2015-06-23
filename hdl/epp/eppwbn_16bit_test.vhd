-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: eppwbn_test.vhd
--| Version: 0.60
--| Tested in: Actel APA300
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   EPP - Wishbone bridge. 
--|   This file is only for test purposes
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.10   | jan-2008 | First release
--|   0.50   | jun-2009 | Testing signals
--|   0.60   | jun-2009 | Testing instance for the dual port memory
----------------------------------------------------------------------------------------------------
--| Copyright ® 2008, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.eppwbn_pkg.all;



entity eppwbn_16bit_test is
  generic(
    -- Memoria hecha con registros puede causar módulos demasiado grandes.
    -- Limitar el tamaño reduciéndo el tamaño del bus de direcciones
    ADD_WIDTH: integer := 4 -- máximo: 8
    );
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
    rst:        in std_logic;   -- ATENCIÓN: entrada rst activo por bajo en instancia
    
    -- al clock
    clk:        in std_logic;
    
    
    
    -- monitores
    display_cat:      out std_logic;
    data_monitor:     out std_logic_vector (3 downto 0);
    select_nibble:    in std_logic; -- Select data nibble. High: high nibble, low: ...
    epp_mode_monitor: out std_logic_vector (1 downto 0);
    nSelectIn_monitor:out std_logic;
    nAutoFd_monitor:  out std_logic;
    nStrobe_monitor:  out std_logic
    
    
		
	);
end eppwbn_16bit_test;

architecture eppwbn_test_arch0 of eppwbn_16bit_test is
  
  signal DAT_I_master:  std_logic_vector (15 downto 0);
  signal DAT_O_master:  std_logic_vector (15 downto 0);
  signal ADR_O_master:  std_logic_vector (7 downto 0);
  signal CYC_O_master:  std_logic;  
  signal STB_O_master:  std_logic;  
  signal ACK_I_master:  std_logic;
  signal WE_O_master:   std_logic;
  signal clk_pll:       std_logic;
  
  signal gnd:           std_logic;
  signal s_not_rst:       std_logic;
  signal s_not_epp_mode: std_logic_vector (1 downto 0);
  signal s_to_mem_ADR_I_a: std_logic_vector(13 downto 0);
  
begin 
  
  gnd <= '0';
  s_not_rst <= not(rst);
  data_monitor <= Data(7 downto 4) when select_nibble = '1' else
                  Data(3 downto 0);
  display_cat <= '0';
  epp_mode_monitor <= not(s_not_epp_mode);
  
  
  nSelectIn_monitor <= nSelectIn;
  nAutoFd_monitor <= nAutoFd;
  nStrobe_monitor <= nStrobe;
  
  

  
--   SL_MEM1: eppwbn_16bit_test_wb_side 
--   generic map(
--     ADD_WIDTH   => ADD_WIDTH ,
--     WIDTH      => 16
--     )
--   port map(
--       RST_I => s_not_rst,
--       CLK_I => clk_pll,
--       DAT_I => DAT_O_master,
--       DAT_O => DAT_I_master,
--       ADR_I => ADR_O_master(ADD_WIDTH - 1 downto 0),
--       CYC_I => CYC_O_master,
--       STB_I => STB_O_master,
--       ACK_O => ACK_I_master,
--       WE_I  => WE_O_master
--     );


  s_to_mem_ADR_I_a <= (13 downto 8 => '0') & ADR_O_master;
  
  SL_MEM2: dual_port_memory_wb port map(
    -- Puerto A 
    RST_I_a => s_not_rst,
    CLK_I_a => clk_pll,
    DAT_I_a => DAT_O_master,
    DAT_O_a => DAT_I_master,
    ADR_I_a => s_to_mem_ADR_I_a,
    CYC_I_a => CYC_O_master,
    STB_I_a => STB_O_master,
    ACK_O_a => ACK_I_master,
    WE_I_a  => WE_O_master,
    
    
    -- Puerto B 
    RST_I_b => s_not_rst,
    CLK_I_b => '0',
    DAT_I_b => (others => '0'),
    
    ADR_I_b => (others => '0'),
    CYC_I_b => '0',
    STB_I_b => '0',
    
    WE_I_b  => '0'
  );
  
  

  MA_EPP: eppwbn_16bit port map(
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
      RST_I => s_not_rst,
      CLK_I => clk_pll,
      DAT_I => DAT_I_master,
      DAT_O => DAT_O_master,
      ADR_O => ADR_O_master,
      CYC_O => CYC_O_master,
      STB_O => STB_O_master,
      ACK_I => ACK_I_master,
      WE_O  => WE_O_master
      
      -- MONITORES
      -- TEMPORAL
      --epp_mode_monitor => s_not_epp_mode
    );
  

  
  PLL_0: component A3PE_pll
  port map(
    POWERDOWN       =>  '0',
    CLKA            =>  clk,
    LOCK            =>  open,
    --SDIN            =>  '0',
    --SCLK            =>  '0',
    --SSHIFT          =>  '0',
    --SUPDATE         =>  '0',
    --MODE            =>  '0',
    GLA             =>  clk_pll
    --SDOUT           =>  open
  );
  

  
end architecture eppwbn_test_arch0;