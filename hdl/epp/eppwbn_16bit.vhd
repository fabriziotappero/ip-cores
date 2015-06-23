----------------------------------------------------------------------------------------------------
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: eppwbn_16 bit.vhd
--| Version: 0.01
--| Tested in: Actel APA300
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   EPP - Wishbone bridge. 
--|   The top module for 16 bit wisbone data bus.
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.01  | dic-2008 | First release
----------------------------------------------------------------------------------------------------
--| Copyright ® 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.

--| Wishbone Rev. B.3 compatible
----------------------------------------------------------------------------------------------------



-- Bloque completo 16 bit

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.eppwbn_pkg.all;

entity eppwbn_16bit is
port(
	-- Externo
  nStrobe:      in std_logic;                       --  HostClk/nWrite 
	Data:         inout std_logic_vector (7 downto 0);--   AD8..1 (Data1..Data8)
	nAck:         out std_logic;                      --  PtrClk/PeriphClk/Intr
	busy:         out std_logic;                      --  PtrBusy/PeriphAck/nWait
	PError:       out std_logic;                      --  AckData/nAckReverse
	Sel:          out std_logic;                      --  XFlag (Select)
	nAutoFd:      in std_logic;                       --  HostBusy/HostAck/nDStrb
	PeriphLogicH: out std_logic;                      --  (Periph Logic High)
  nInit:        in std_logic;                       --  nReverseRequest
	nFault:       out std_logic;                      --  nDataAvail/nPeriphRequest
	nSelectIn:    in std_logic;                       --  1284 Active/nAStrb
	
                
	--  Interno
	RST_I: in std_logic;  
	CLK_I: in std_logic;  
	DAT_I: in std_logic_vector (15 downto 0);
	DAT_O: out std_logic_vector (15 downto 0);
	ADR_O: out std_logic_vector (7 downto 0);
	CYC_O: out std_logic;  
	STB_O: out std_logic;  
	ACK_I: in std_logic ;
	WE_O: out std_logic
  
  -- TEMPORAL monitores
  --epp_mode_monitor: out std_logic_vector(1 downto 0)
  
	);
end eppwbn_16bit;
	


architecture structural of eppwbn_16bit is
  -- Señales
	signal s_DAT_I: std_logic_vector (7 downto 0);
  signal s_DAT_O: std_logic_vector (7 downto 0);
  signal s_ADR_O: std_logic_vector (7 downto 0);
  signal s_CYC_O: std_logic;  
  signal s_STB_O: std_logic;  
  signal s_ACK_I: std_logic;
  signal s_WE_O:  std_logic;
begin
	
  
  U_EPPWBN8: eppwbn 
  port map(    
    -- TEMPORAL
    --epp_mode_monitor => epp_mode_monitor,
  
  
    -- To EPP interface
    nStrobe => nStrobe,                                                
    Data => Data,
    nAck => nAck,
    busy => busy,
    PError => PError,
    Sel => Sel,
    nAutoFd => nAutoFd,
    PeriphLogicH => PeriphLogicH,
    nInit => nInit,
    nFault => nFault,
    nSelectIn => nSelectIn,
   
    -- Common signals
    RST_I => RST_I,
    CLK_I => CLK_I,
    
    -- Master EPP to slave width exteneder
    DAT_I => s_DAT_I,
    DAT_O => s_DAT_O,
    ADR_O => s_ADR_O,
    CYC_O => s_CYC_O,
    STB_O => s_STB_O,
    ACK_I => s_ACK_I,
    WE_O =>  s_WE_O
  );
   
  U_EPPWBN_8TO16: eppwbn_width_extension
  generic map(
    TIME_OUT_VALUE => 1023,
    TIME_OUT_WIDTH => 10
  )
  port map(
    -- Master EPP to slave width exteneder
    DAT_I_sl => s_DAT_O,
    DAT_O_sl => s_DAT_I,
    ADR_I_sl => s_ADR_O,
    CYC_I_sl => s_CYC_O,
    STB_I_sl => s_STB_O,
    ACK_O_sl => s_ACK_I,
    WE_I_sl  => s_WE_O,
                
    -- Master width exteneder to TOP
    DAT_I_ma => DAT_I,
    DAT_O_ma => DAT_O,
    ADR_O_ma => ADR_O,
    CYC_O_ma => CYC_O,
    STB_O_ma => STB_O,
    ACK_I_ma => ACK_I,
    WE_O_ma  => WE_O,
    
    -- Common signals
    RST_I => RST_I,
    CLK_I => CLK_I
  );
 
  
end architecture;