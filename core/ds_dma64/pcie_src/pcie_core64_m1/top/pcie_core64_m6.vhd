-------------------------------------------------------------------------------
--
-- Title       : pcie_core64_m6
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems 
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description :  Контроллер шины PCI Express 	
--				  Модификация 6 - для подключения к Spartan-6
--
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;

use work.core64_type_pkg.all;

package	pcie_core64_m6_pkg is

--! контроллер PCI-Express 
component pcie_core64_m6 is
	generic (
		is_simulation	: integer:=0	--! 0 - синтез, 1 - моделирование 
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 0 downto 0 );
		txn				: out std_logic_vector( 0 downto 0 );
		
		rxp				: in  std_logic_vector( 0 downto 0 );
		rxn				: in  std_logic_vector( 0 downto 0 );
		
		mgt125			: in  std_logic; -- тактовая частота 125 MHz от PCI_Express
		
		perst			: in  std_logic;	-- 0 - сброс						   
		
		px				: out std_logic_vector( 7 downto 0 );	--! контрольные точки 
		
		pcie_lstatus	: out std_logic_vector( 15 downto 0 ); -- регистр LSTATUS
		pcie_link_up	: out std_logic;	-- 0 - завершена инициализация PCI-Express
		
		
		---- Локальная шина ----			  
		clk_out			: out std_logic;	--! тактовая частота 250 MHz		  
		reset_out		: out std_logic;	--! 0 - сброс
		dcm_rstp		: out std_logic;	--! 1 - сброс DCM 266 МГц

		---- BAR0 - блоки управления ----
		bp_host_data	: out std_logic_vector( 31 downto 0 );	--! шина данных - выход 
		bp_data			: in  std_logic_vector( 31 downto 0 );  --! шина данных - вход
		bp_adr			: out std_logic_vector( 19 downto 0 );	--! адрес регистра 
		bp_we			: out std_logic_vector( 3 downto 0 ); 	--! 1 - запись в регистры 
		bp_rd			: out std_logic_vector( 3 downto 0 );   --! 1 - чтение из регистров блока 
		bp_sel			: out std_logic_vector( 1 downto 0 );	--! номер блока для чтения 
		bp_reg_we		: out std_logic;			--! 1 - запись в регистр по адресам   0x100000 - 0x1FFFFF 
		bp_reg_rd		: out std_logic; 			--! 1 - чтение из регистра по адресам 0x100000 - 0x1FFFFF 
		bp_irq			: in  std_logic;			--! 1 - запрос прерывания 

		---- BAR1 ----	
		aclk			: in std_logic;				--! тактовая частота локальной шины - 266 МГц
		aclk_lock		: in std_logic;				--! 1 - захват частоты
		pb_master		: out type_pb_master;		--! запрос 
		pb_slave		: in  type_pb_slave			--! ответ  
		
				
		
	);
end component;

end package;



library ieee;
use ieee.std_logic_1164.all;		

use work.core64_type_pkg.all;
use work.core64_rx_engine_m4_pkg.all;
use work.core64_tx_engine_m4_pkg.all;	
use work.core64_reg_access_pkg.all;
use work.core64_pb_disp_pkg.all;   
use work.block_pe_fifo_ext_pkg.all;		
use work.core64_interrupt_pkg.all;

--! контроллер PCI-Express 
entity pcie_core64_m6 is
	generic (
		is_simulation	: integer:=0	--! 0 - синтез, 1 - моделирование 
	);		  
	
	port (
	
		---- PCI-Express ----
		txp				: out std_logic_vector( 0 downto 0 );
		txn				: out std_logic_vector( 0 downto 0 );
		
		rxp				: in  std_logic_vector( 0 downto 0 );
		rxn				: in  std_logic_vector( 0 downto 0 );
		
		mgt125			: in  std_logic; -- тактовая частота 125 MHz от PCI_Express
		
		perst			: in  std_logic;	-- 0 - сброс						   
		
		px				: out std_logic_vector( 7 downto 0 );	--! контрольные точки 
		
		pcie_lstatus	: out std_logic_vector( 15 downto 0 ); -- регистр LSTATUS
		pcie_link_up	: out std_logic;	-- 0 - завершена инициализация PCI-Express
		
		
		---- Локальная шина ----			  
		clk_out			: out std_logic;	--! тактовая частота 250 MHz		  
		reset_out		: out std_logic;	--! 0 - сброс
		dcm_rstp		: out std_logic;	--! 1 - сброс DCM 266 МГц

		---- BAR0 - блоки управления ----
		bp_host_data	: out std_logic_vector( 31 downto 0 );	--! шина данных - выход 
		bp_data			: in  std_logic_vector( 31 downto 0 );  --! шина данных - вход
		bp_adr			: out std_logic_vector( 19 downto 0 );	--! адрес регистра 
		bp_we			: out std_logic_vector( 3 downto 0 ); 	--! 1 - запись в регистры 
		bp_rd			: out std_logic_vector( 3 downto 0 );   --! 1 - чтение из регистров блока 
		bp_sel			: out std_logic_vector( 1 downto 0 );	--! номер блока для чтения 
		bp_reg_we		: out std_logic;			--! 1 - запись в регистр по адресам   0x100000 - 0x1FFFFF 
		bp_reg_rd		: out std_logic; 			--! 1 - чтение из регистра по адресам 0x100000 - 0x1FFFFF 
		bp_irq			: in  std_logic;			--! 1 - запрос прерывания 

		---- BAR1 ----	
		aclk			: in std_logic;				--! тактовая частота локальной шины - 266 МГц
		aclk_lock		: in std_logic;				--! 1 - захват частоты
		pb_master		: out type_pb_master;		--! запрос 
		pb_slave		: in  type_pb_slave			--! ответ  
		
		
	);
end pcie_core64_m6;


architecture pcie_core64_m6 of pcie_core64_m6 is


component cl_s6pcie_m2 is
  generic (
    TL_TX_RAM_RADDR_LATENCY           : integer    := 0;
    TL_TX_RAM_RDATA_LATENCY           : integer    := 2;
    TL_RX_RAM_RADDR_LATENCY           : integer    := 0;
    TL_RX_RAM_RDATA_LATENCY           : integer    := 2;
    TL_RX_RAM_WRITE_LATENCY           : integer    := 0;
    VC0_TX_LASTPACKET                 : integer    := 28;
    VC0_RX_RAM_LIMIT                  : bit_vector := x"7FF";
    VC0_TOTAL_CREDITS_PH              : integer    := 32;
    VC0_TOTAL_CREDITS_PD              : integer    := 211;
    VC0_TOTAL_CREDITS_NPH             : integer    := 8;
    VC0_TOTAL_CREDITS_CH              : integer    := 40;
    VC0_TOTAL_CREDITS_CD              : integer    := 211;
    VC0_CPL_INFINITE                  : boolean    := TRUE;
    BAR0                              : bit_vector := x"FFE00000";
    BAR1                              : bit_vector := x"FFE00000";
    BAR2                              : bit_vector := x"00000000";
    BAR3                              : bit_vector := x"00000000";
    BAR4                              : bit_vector := x"00000000";
    BAR5                              : bit_vector := x"00000000";
    EXPANSION_ROM                     : bit_vector := "0000000000000000000000";
    DISABLE_BAR_FILTERING             : boolean    := FALSE;
    DISABLE_ID_CHECK                  : boolean    := FALSE;
    TL_TFC_DISABLE                    : boolean    := FALSE;
    TL_TX_CHECKS_DISABLE              : boolean    := FALSE;
    USR_CFG                           : boolean    := FALSE;
    USR_EXT_CFG                       : boolean    := FALSE;
    DEV_CAP_MAX_PAYLOAD_SUPPORTED     : integer    := 1;
    CLASS_CODE                        : bit_vector := x"FFFFFF";
    CARDBUS_CIS_POINTER               : bit_vector := x"00000000";
    PCIE_CAP_CAPABILITY_VERSION       : bit_vector := x"1";
    PCIE_CAP_DEVICE_PORT_TYPE         : bit_vector := x"0";
    PCIE_CAP_SLOT_IMPLEMENTED         : boolean    := FALSE;
    PCIE_CAP_INT_MSG_NUM              : bit_vector := "00000";
    DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT : integer    := 0;
    DEV_CAP_EXT_TAG_SUPPORTED         : boolean    := FALSE;
    DEV_CAP_ENDPOINT_L0S_LATENCY      : integer    := 7;
    DEV_CAP_ENDPOINT_L1_LATENCY       : integer    := 7;
    SLOT_CAP_ATT_BUTTON_PRESENT       : boolean    := FALSE;
    SLOT_CAP_ATT_INDICATOR_PRESENT    : boolean    := FALSE;
    SLOT_CAP_POWER_INDICATOR_PRESENT  : boolean    := FALSE;
    DEV_CAP_ROLE_BASED_ERROR          : boolean    := TRUE;
    LINK_CAP_ASPM_SUPPORT             : integer    := 1;
    LINK_CAP_L0S_EXIT_LATENCY         : integer    := 7;
    LINK_CAP_L1_EXIT_LATENCY          : integer    := 7;
    LL_ACK_TIMEOUT                    : bit_vector := x"0000";
    LL_ACK_TIMEOUT_EN                 : boolean    := FALSE;
    LL_REPLAY_TIMEOUT                 : bit_vector := x"0000";
    LL_REPLAY_TIMEOUT_EN              : boolean    := FALSE;
    MSI_CAP_MULTIMSGCAP               : integer    := 0;
    MSI_CAP_MULTIMSG_EXTENSION        : integer    := 0;
    LINK_STATUS_SLOT_CLOCK_CONFIG     : boolean    := TRUE;
    PLM_AUTO_CONFIG                   : boolean    := FALSE;
    FAST_TRAIN                        : boolean    := FALSE;
    ENABLE_RX_TD_ECRC_TRIM            : boolean    := TRUE;
    DISABLE_SCRAMBLING                : boolean    := FALSE;
    PM_CAP_VERSION                    : integer    := 3;
    PM_CAP_PME_CLOCK                  : boolean    := FALSE;
    PM_CAP_DSI                        : boolean    := FALSE;
    PM_CAP_AUXCURRENT                 : integer    := 0;
    PM_CAP_D1SUPPORT                  : boolean    := TRUE;
    PM_CAP_D2SUPPORT                  : boolean    := TRUE;
    PM_CAP_PMESUPPORT                 : bit_vector := x"0F";
    PM_DATA0                          : bit_vector := x"00";
    PM_DATA_SCALE0                    : bit_vector := x"0";
    PM_DATA1                          : bit_vector := x"00";
    PM_DATA_SCALE1                    : bit_vector := x"0";
    PM_DATA2                          : bit_vector := x"00";
    PM_DATA_SCALE2                    : bit_vector := x"0";
    PM_DATA3                          : bit_vector := x"00";
    PM_DATA_SCALE3                    : bit_vector := x"0";
    PM_DATA4                          : bit_vector := x"00";
    PM_DATA_SCALE4                    : bit_vector := x"0";
    PM_DATA5                          : bit_vector := x"00";
    PM_DATA_SCALE5                    : bit_vector := x"0";
    PM_DATA6                          : bit_vector := x"00";
    PM_DATA_SCALE6                    : bit_vector := x"0";
    PM_DATA7                          : bit_vector := x"00";
    PM_DATA_SCALE7                    : bit_vector := x"0";
    PCIE_GENERIC                      : bit_vector := "000010101111";
    GTP_SEL                           : integer    := 0;
    CFG_VEN_ID                        : std_logic_vector(15 downto 0) := x"4953";
    CFG_DEV_ID                        : std_logic_vector(15 downto 0) := x"5507";
    CFG_REV_ID                        : std_logic_vector(7 downto 0)  := x"10";
    CFG_SUBSYS_VEN_ID                 : std_logic_vector(15 downto 0) := x"4953";
    CFG_SUBSYS_ID                     : std_logic_vector(15 downto 0) := x"0008";
    REF_CLK_FREQ                      : integer    := 1
  );
  port (
    -- PCI Express Fabric Interface
    pci_exp_txp             : out std_logic;
    pci_exp_txn             : out std_logic;
    pci_exp_rxp             : in  std_logic;
    pci_exp_rxn             : in  std_logic;

    -- Transaction (TRN) Interface
    trn_lnk_up_n            : out std_logic;

    -- Tx
    trn_td                  : in  std_logic_vector(31 downto 0);
    trn_tsof_n              : in  std_logic;
    trn_teof_n              : in  std_logic;
    trn_tsrc_rdy_n          : in  std_logic;
    trn_tdst_rdy_n          : out std_logic;
    trn_terr_drop_n         : out std_logic;
    trn_tsrc_dsc_n          : in  std_logic;
    trn_terrfwd_n           : in  std_logic;
    trn_tbuf_av             : out std_logic_vector(5 downto 0);
    trn_tstr_n              : in  std_logic;
    trn_tcfg_req_n          : out std_logic;
    trn_tcfg_gnt_n          : in  std_logic;

    -- Rx
    trn_rd                  : out std_logic_vector(31 downto 0);
    trn_rsof_n              : out std_logic;
    trn_reof_n              : out std_logic;
    trn_rsrc_rdy_n          : out std_logic;
    trn_rsrc_dsc_n          : out std_logic;
    trn_rdst_rdy_n          : in  std_logic;
    trn_rerrfwd_n           : out std_logic;
    trn_rnp_ok_n            : in  std_logic;
    trn_rbar_hit_n          : out std_logic_vector(6 downto 0);
    trn_fc_sel              : in  std_logic_vector(2 downto 0);
    trn_fc_nph              : out std_logic_vector(7 downto 0);
    trn_fc_npd              : out std_logic_vector(11 downto 0);
    trn_fc_ph               : out std_logic_vector(7 downto 0);
    trn_fc_pd               : out std_logic_vector(11 downto 0);
    trn_fc_cplh             : out std_logic_vector(7 downto 0);
    trn_fc_cpld             : out std_logic_vector(11 downto 0);

    -- Host (CFG) Interface
    cfg_do                  : out std_logic_vector(31 downto 0);
    cfg_rd_wr_done_n        : out std_logic;
    cfg_dwaddr              : in  std_logic_vector(9 downto 0);
    cfg_rd_en_n             : in  std_logic;
    cfg_err_ur_n            : in  std_logic;
    cfg_err_cor_n           : in  std_logic;
    cfg_err_ecrc_n          : in  std_logic;
    cfg_err_cpl_timeout_n   : in  std_logic;
    cfg_err_cpl_abort_n     : in  std_logic;
    cfg_err_posted_n        : in  std_logic;
    cfg_err_locked_n        : in  std_logic;
    cfg_err_tlp_cpl_header  : in  std_logic_vector(47 downto 0);
    cfg_err_cpl_rdy_n       : out std_logic;
    cfg_interrupt_n         : in  std_logic;
    cfg_interrupt_rdy_n     : out std_logic;
    cfg_interrupt_assert_n  : in  std_logic;
    cfg_interrupt_do        : out std_logic_vector(7 downto 0);
    cfg_interrupt_di        : in  std_logic_vector(7 downto 0);
    cfg_interrupt_mmenable  : out std_logic_vector(2 downto 0);
    cfg_interrupt_msienable : out std_logic;
    cfg_turnoff_ok_n        : in  std_logic;
    cfg_to_turnoff_n        : out std_logic;
    cfg_pm_wake_n           : in  std_logic;
    cfg_pcie_link_state_n   : out std_logic_vector(2 downto 0);
    cfg_trn_pending_n       : in  std_logic;
    cfg_dsn                 : in  std_logic_vector(63 downto 0);
    cfg_bus_number          : out std_logic_vector(7 downto 0);
    cfg_device_number       : out std_logic_vector(4 downto 0);
    cfg_function_number     : out std_logic_vector(2 downto 0);
    cfg_status              : out std_logic_vector(15 downto 0);
    cfg_command             : out std_logic_vector(15 downto 0);
    cfg_dstatus             : out std_logic_vector(15 downto 0);
    cfg_dcommand            : out std_logic_vector(15 downto 0);
    cfg_lstatus             : out std_logic_vector(15 downto 0);
    cfg_lcommand            : out std_logic_vector(15 downto 0);

    -- System Interface
    sys_clk                 : in  std_logic;
    sys_reset_n             : in  std_logic;
    trn_clk                 : out std_logic;
    trn_reset_n             : out std_logic;
    received_hot_reset      : out std_logic
  );
end component;


--signal     sys_clk_c : std_logic;

--signal     sys_reset_n_c : std_logic;
signal     trn_clk_c : std_logic;
signal     trn_reset_n_c : std_logic;
signal     trn_lnk_up_n_c : std_logic;
signal     cfg_trn_pending_n_c : std_logic;
signal     trn_tsof_n_c : std_logic;
signal     trn_teof_n_c : std_logic;
signal     trn_tsrc_rdy_n_c : std_logic;
signal     trn_tdst_rdy_n_c : std_logic;
signal     trn_tsrc_dsc_n_c : std_logic;
signal     trn_terrfwd_n_c : std_logic;
signal     trn_tdst_dsc_n_c : std_logic;
signal     trn_td_c : std_logic_vector((64 - 1) downto 0);
signal     trn_trem_n_c : std_logic_vector(7 downto 0);
signal     trn_tbuf_av_c : std_logic_vector(( 4 -1 )  downto 0);
signal     trn_rsof_n_c : std_logic;
signal     trn_reof_n_c : std_logic;
signal     trn_rsrc_rdy_n_c : std_logic;
signal     trn_rsrc_dsc_n_c : std_logic;
signal     trn_rdst_rdy_n_c : std_logic;
signal     trn_rerrfwd_n_c : std_logic;
signal     trn_rnp_ok_n_c : std_logic;

signal     trn_rd_c : std_logic_vector((64 - 1) downto 0);
signal     trn_rrem_n_c : std_logic_vector(7 downto 0);
signal     trn_rbar_hit_n_c : std_logic_vector(6 downto 0);
signal     trn_rfc_nph_av_c : std_logic_vector(7 downto 0);
signal     trn_rfc_npd_av_c : std_logic_vector(11 downto 0);
signal     trn_rfc_ph_av_c : std_logic_vector(7 downto 0);
signal     trn_rfc_pd_av_c : std_logic_vector(11 downto 0);
signal     trn_rcpl_streaming_n_c      : std_logic;

signal     cfg_do_c : std_logic_vector(31 downto 0);
signal     cfg_di_c : std_logic_vector(31 downto 0);
signal     cfg_dwaddr_c : std_logic_vector(9 downto 0) ;
signal     cfg_byte_en_n_c : std_logic_vector(3 downto 0);
signal     cfg_err_tlp_cpl_header_c : std_logic_vector(47 downto 0);
signal     cfg_wr_en_n_c : std_logic;
signal     cfg_rd_en_n_c : std_logic;
signal     cfg_rd_wr_done_n_c : std_logic;
signal     cfg_err_cor_n_c : std_logic;
signal     cfg_err_ur_n_c : std_logic;
signal     cfg_err_ecrc_n_c : std_logic;
signal     cfg_err_cpl_timeout_n_c : std_logic;
signal     cfg_err_cpl_abort_n_c : std_logic;
signal     cfg_err_cpl_unexpect_n_c : std_logic;
signal     cfg_err_posted_n_c : std_logic;

signal     cfg_err_cpl_rdy_n_c : std_logic;  
signal     cfg_interrupt_n_c : std_logic;
signal     cfg_interrupt_rdy_n_c : std_logic;

signal     cfg_interrupt_assert_n_c : std_logic;
signal     cfg_interrupt_di_c : std_logic_vector(7 downto 0);
signal     cfg_interrupt_do_c : std_logic_vector(7 downto 0);
signal     cfg_interrupt_mmenable_c : std_logic_vector(2 downto 0);
signal     cfg_interrupt_msienable_c: std_logic;

signal     cfg_turnoff_ok_n_c : std_logic;
signal     cfg_to_turnoff_n_c : std_logic;
signal     cfg_pm_wake_n_c : std_logic;
signal     cfg_pcie_link_state_n_c : std_logic_vector(2 downto 0);
signal     cfg_bus_number_c : std_logic_vector(7 downto 0);
signal     cfg_device_number_c : std_logic_vector(4 downto 0);
signal     cfg_function_number_c : std_logic_vector(2 downto 0);
signal     cfg_status_c : std_logic_vector(15 downto 0);
signal     cfg_command_c : std_logic_vector(15 downto 0);
signal     cfg_dstatus_c : std_logic_vector(15 downto 0);
signal     cfg_dcommand_c : std_logic_vector(15 downto 0);
signal     cfg_lstatus_c : std_logic_vector(15 downto 0);
signal     cfg_lcommand_c : std_logic_vector(15 downto 0);
--signal     unsigned_fast_simulation: unsigned(0 downto 0);
signal     vector_fast_simulation: std_logic_vector(0 downto 0):=(0=>'1');

signal	refclkout				: std_logic;


signal clk					: std_logic;
signal rstp					: std_logic;
signal trn_rx				: type_trn_rx;			--! приём пакета
signal trn_rx_back			: type_trn_rx_back;		--! готовность к приёму пакета

signal reg_access			: type_reg_access;		--! запрос на доступ к регистрам 
		
signal rx_tx_engine			: type_rx_tx_engine;	--! обмен RX->TX 
signal tx_rx_engine			: type_tx_rx_engine;	--! обмен TX->RX 
		
signal rx_ext_fifo			: type_rx_ext_fifo;		--! обмен RX->EXT_FIFO 
signal tx_ext_fifo			: type_tx_ext_fifo;
signal	tx_ext_fifo_back	: type_tx_ext_fifo_back;
signal	reg_access_back		: type_reg_access_back;
signal	completer_id		: std_logic_vector( 15 downto 0 );

signal	trn_tx				: type_trn_tx;
signal	trn_tx_back			: type_trn_tx_back;

signal	reg_disp			: type_reg_disp;
signal	reg_disp_back		: type_reg_disp_back;

signal	reg_ext_fifo		: type_reg_ext_fifo;
signal	reg_ext_fifo_back	: type_reg_ext_fifo_back;

signal	ext_fifo_disp		: type_ext_fifo_disp;		--! запрос на доступ от узла EXT_FIFO 
signal	ext_fifo_disp_back	: type_ext_fifo_disp_back;	--! ответ на запрос

signal	pb_rstp				: std_logic;

signal	irq					: std_logic;

function  SET_FAST_TRAIN( is_simulation : integer ) return boolean is

variable	ret	: boolean;
begin			   
	
	if( is_simulation=0 ) then
		ret:=false;
	else
		ret:=true;
	end if;
	return ret;
		
end SET_FAST_TRAIN;

constant	PL_FAST_TRAIN	: boolean:= SET_FAST_TRAIN( is_simulation );

begin

gen_sim: if( is_simulation/=0 ) generate
	vector_fast_simulation <= (others=>'1');
end generate;

gen_syn: if( is_simulation=0 ) generate
	vector_fast_simulation <= (others=>'0');
end generate;
	
	
clk_out <= clk;
reset_out <= not pb_rstp after 1 ns when rising_edge( clk );

ep : cl_s6pcie_m2  
 generic map
  (
    FAST_TRAIN                        => PL_FAST_TRAIN
  )
 port map
(

--
-- PCI Express Fabric Interface
--

  pci_exp_txp => txp(0),             -- O (7/3/0:0)
  pci_exp_txn => txn(0),             -- O (7/3/0:0)
  pci_exp_rxp => rxp(0),             -- O (7/3/0:0)
  pci_exp_rxn => rxn(0),             -- O (7/3/0:0)


--
-- System ( SYS ) Interface
--
  sys_clk => mgt125,                     -- I

  sys_reset_n => perst,                  -- I

--  refclkout => refclkout,                -- O

--
-- Transaction ( TRN ) Interface
--

  trn_clk => clk		,                 -- O
  trn_reset_n => trn_reset_n_c,           -- O
  trn_lnk_up_n => trn_lnk_up_n_c,         -- O

-- Tx Local-Link

  trn_td => trn_tx.trn_td( 31 downto 0 ),      -- I (63/31:0)
--  trn_trem_n => trn_tx.trn_trem_n,
  trn_tsof_n => trn_tx.trn_tsof_n,             -- I
  trn_teof_n => trn_tx.trn_teof_n,             -- I
  trn_tsrc_rdy_n => trn_tx.trn_tsrc_rdy_n,     -- I
  trn_tsrc_dsc_n => trn_tx.trn_tsrc_dsc_n,     -- I
  trn_terrfwd_n => trn_tx.trn_terrfwd_n,       -- I

  trn_tbuf_av => trn_tx_back.trn_tbuf_av,           -- O (4/3:0)
  trn_tdst_rdy_n => trn_tx_back.trn_tdst_rdy_n,     -- O
--  trn_tdst_dsc_n => trn_tx_back.trn_tdst_dsc_n,     -- O

	trn_tstr_n   => '1',		   
	trn_tcfg_gnt_n => '0',


-- Rx Local-Link

  trn_rd => trn_rx.trn_rd( 31 downto 0 ),      -- O (63/31:0)
--  trn_rrem_n => trn_rx.trn_rrem_n,
  trn_rsof_n => trn_rx.trn_rsof_n,             -- O
  trn_reof_n => trn_rx.trn_reof_n,             -- O
  trn_rsrc_rdy_n => trn_rx.trn_rsrc_rdy_n,     -- O
  trn_rsrc_dsc_n => trn_rx.trn_rsrc_dsc_n,     -- O
  trn_rdst_rdy_n => trn_rx_back.trn_rdst_rdy_n,     -- I
  trn_rerrfwd_n => trn_rx.trn_rerrfwd_n,       -- O
  trn_rnp_ok_n => trn_rx_back.trn_rnp_ok_n,         -- I
  trn_rbar_hit_n => trn_rx.trn_rbar_hit_n,     -- O (6:0)
--  trn_rfc_nph_av => trn_rx.trn_rfc_nph_av,     -- O (11:0)
--  trn_rfc_npd_av => trn_rx.trn_rfc_npd_av,     -- O (7:0)
--  trn_rfc_ph_av => trn_rx.trn_rfc_ph_av,       -- O (11:0)
--  trn_rfc_pd_av => trn_rx.trn_rfc_pd_av,       -- O (7:0)
--  trn_rcpl_streaming_n => trn_rx_back.trn_rcpl_streaming_n,

	trn_fc_sel => "000",
--
-- Host ( CFG ) Interface
--

  cfg_do => cfg_do_c,                                    -- O (31:0)
  cfg_rd_wr_done_n => cfg_rd_wr_done_n_c,                -- O
--  cfg_di => cfg_di_c,                                    -- I (31:0)
--  cfg_byte_en_n => cfg_byte_en_n_c,                      -- I (3:0)
  cfg_dwaddr => cfg_dwaddr_c,                            -- I (9:0)
--  cfg_wr_en_n => cfg_wr_en_n_c,                          -- I
  cfg_rd_en_n => cfg_rd_en_n_c,                          -- I
  cfg_err_cor_n => cfg_err_cor_n_c,                      -- I
  cfg_err_ur_n => cfg_err_ur_n_c,                        -- I
  cfg_err_ecrc_n => cfg_err_ecrc_n_c,                    -- I
  cfg_err_cpl_timeout_n => cfg_err_cpl_timeout_n_c,      -- I
  cfg_err_cpl_abort_n => cfg_err_cpl_abort_n_c,          -- I
--  cfg_err_cpl_unexpect_n => cfg_err_cpl_unexpect_n_c,    -- I
  cfg_err_posted_n => cfg_err_posted_n_c,                -- I
  cfg_err_cpl_rdy_n => cfg_err_cpl_rdy_n_c,              -- O
  cfg_err_locked_n => '1',                -- I
  cfg_err_tlp_cpl_header => cfg_err_tlp_cpl_header_c,    -- I (47:0)
  cfg_interrupt_n => cfg_interrupt_n_c,                  -- I
  cfg_interrupt_rdy_n => cfg_interrupt_rdy_n_c,          -- O

  cfg_interrupt_assert_n => cfg_interrupt_assert_n_c,    -- I
  cfg_interrupt_di       => cfg_interrupt_di_c,          -- I [7:0]
  cfg_interrupt_do       => cfg_interrupt_do_c,          -- O [7:0]
  cfg_interrupt_mmenable => cfg_interrupt_mmenable_c,    -- O [2:0]
  cfg_interrupt_msienable=> cfg_interrupt_msienable_c,   -- O
  cfg_to_turnoff_n => cfg_to_turnoff_n_c,                -- O
  cfg_pm_wake_n => cfg_pm_wake_n_c,                      -- I
  cfg_pcie_link_state_n => cfg_pcie_link_state_n_c,      -- O (2:0)
  cfg_trn_pending_n => cfg_trn_pending_n_c,              -- I
  cfg_bus_number => cfg_bus_number_c,                    -- O (7:0)
  cfg_device_number => cfg_device_number_c,              -- O (4:0)
  cfg_function_number => cfg_function_number_c,          -- O (2:0)
  cfg_status => cfg_status_c,                            -- O (15:0)
  cfg_command => cfg_command_c,                          -- O (15:0)
  cfg_dstatus => cfg_dstatus_c,                          -- O (15:0)
  cfg_dcommand => trn_tx_back.cfg_dcommand,              -- O (15:0)
  cfg_lstatus => cfg_lstatus_c,                          -- O (15:0)
  cfg_lcommand => cfg_lcommand_c,                        -- O (15:0)
  cfg_dsn => (others => '0'),
  
  cfg_turnoff_ok_n => '1'

-- fast_train_simulation_only => vector_fast_simulation(0)

);

pcie_link_up <= trn_lnk_up_n_c;
pcie_lstatus <= cfg_lstatus_c;

rstp <=  not trn_reset_n_c  after 1 ns when rising_edge( clk );
dcm_rstp <= not trn_reset_n_c;

pb_rstp <= rstp or ( not aclk_lock ) after 1 ns when rising_edge( clk );

  trn_rnp_ok_n_c              <= '0';
  trn_rcpl_streaming_n_c      <= '1'; 
  trn_terrfwd_n_c             <= '1';

  cfg_err_cor_n_c             <= '1';
  cfg_err_ur_n_c              <= '1';
  cfg_err_ecrc_n_c            <= '1';
  cfg_err_cpl_timeout_n_c     <= '1';
  cfg_err_cpl_abort_n_c       <= '1';
  cfg_err_cpl_unexpect_n_c    <= '1';
  cfg_err_posted_n_c          <= '0';

  cfg_interrupt_di_c <= X"00";

  cfg_pm_wake_n_c             <= '1';
  cfg_trn_pending_n_c         <= '1';
  cfg_dwaddr_c                <= (others => '0');
  cfg_err_tlp_cpl_header_c    <= (others => '0');
  cfg_di_c                    <= (others => '0');
  cfg_byte_en_n_c             <= X"F"; -- 4-bit bus
  cfg_wr_en_n_c               <= '1';
  cfg_rd_en_n_c               <= '1';
--  cfg_completer_id_c          <= (cfg_bus_number &
--                                cfg_device_number &
--                                cfg_function_number);
--  cfg_bus_mstr_enable_c       <= cfg_command(2);



rx: core64_rx_engine_m4 
	port map(
	
		--- General ---
		rstp			=> rstp,			--! 1 - сброс 
		clk				=> clk,				--! тактовая частота ядра - 250 MHz 
		
		trn_rx			=> trn_rx,			--! приём пакета
		trn_rx_back		=> trn_rx_back,		--! готовность к приёму пакета
						                
		reg_access		=> reg_access,		--! запрос на доступ к регистрам 
						                
		rx_tx_engine	=> rx_tx_engine,	--! обмен RX->TX 
		tx_rx_engine	=> tx_rx_engine,	--! обмен TX->RX 
						                
		rx_ext_fifo		=> rx_ext_fifo		--! обмен RX->EXT_FIFO 
		
		
		
	);
	

tx: core64_tx_engine_m4 
	port map(
	
		--- General ---
		rstp			=> rstp,			--! 1 - сброс 
		clk				=> clk,				--! тактовая частота ядра - 250 MHz 
		
		trn_tx			=> trn_tx,			--! передача пакета
		trn_tx_back		=> trn_tx_back,		--! готовность к передаче пакета
						                
		completer_id	=> completer_id,	--! идентификатор устройства 
						                
		reg_access_back	=> reg_access_back,	--! запрос на доступ к регистрам 
						                
		rx_tx_engine	=> rx_tx_engine,	--! обмен RX->TX 
		tx_rx_engine	=> tx_rx_engine,	--! обмен TX->RX 
						                
		tx_ext_fifo		=> tx_ext_fifo,		--! обмен TX->EXT_FIFO 
		tx_ext_fifo_back=> tx_ext_fifo_back --! обмен TX->EXT_FIFO 
			
	);
	
  completer_id     <= (cfg_bus_number_c &
                       cfg_device_number_c &
                       cfg_function_number_c );	
					   
					   
 reg: core64_reg_access 
	port map(
		--- General ---
		rstp				=> rstp,	--! 1 - сброс 
		clk					=> clk,		--! тактовая частота ядра - 250 MHz 
		
		--- RX_ENGINE ---- 
		reg_access			=> reg_access,	--! запрос на доступ к регистрам 
		
		--- TX_ENGINE ----
		reg_access_back		=> reg_access_back,	--! ответ на запрос 
		
		---- PB_DISP ----
		reg_disp			=> reg_disp,		--! запрос на доступ к регистрам из BAR1 
		reg_disp_back		=> reg_disp_back,	--! ответ на запрос 
		
		---- BLOCK EXT_FIFO ----
		reg_ext_fifo		=> reg_ext_fifo,		--! запрос на доступ к блокам управления EXT_FIFO 
		reg_ext_fifo_back	=> reg_ext_fifo_back,	--! ответ на запрос 
		
		---- BAR0 - блоки управления ----
		bp_host_data		=> bp_host_data,	--! шина данных - выход 
		bp_data				=> bp_data,			--! шина данных - вход
		bp_adr				=> bp_adr,			--! адрес регистра 
		bp_we				=> bp_we,			--! 1 - запись в регистры 
		bp_rd				=> bp_rd,			--! 1 - чтение из регистров блока 
		bp_sel				=> bp_sel,			--! номер блока для чтения 
		bp_reg_we			=> bp_reg_we,		--! 1 - запись в регистр по адресам   0x100000 - 0x1FFFFF 
		bp_reg_rd			=> bp_reg_rd,		--! 1 - чтение из регистра по адресам 0x100000 - 0x1FFFFF 
		bp_irq				=> bp_irq			--! 1 - запрос прерывания 
	);					   

	
 disp: core64_pb_disp 
	port map(
		--- General ---
		rstp				=> pb_rstp,		--! 1 - сброс 
		clk					=> clk,			--! тактовая частота ядра - 250 MHz 
		
		---- PB_DISP ----
		reg_disp			=> reg_disp,		--! запрос на доступ к регистрам из BAR1 
		reg_disp_back		=> reg_disp_back,	--! ответ на запрос 
		
		---- EXT_FIFO ----
		ext_fifo_disp		=> ext_fifo_disp,		--! запрос на доступ от узла EXT_FIFO 
		ext_fifo_disp_back	=> ext_fifo_disp_back,	--! ответ на запрос
		
		---- BAR1 ----	
		aclk				=> aclk,				--! тактовая частота локальной шины - 266 МГц
		pb_master			=> pb_master,			--! запрос 
		pb_slave			=> pb_slave				--! ответ  

	);	
	


fifo: block_pe_fifo_ext 
	generic map(
		is_dsp48			=> 0			-- 1 - использовать DSP48, 0 - не использовать DSP48
	)
	port map(
	
		---- Global ----	 
		rstp				 => pb_rstp,				 
		clk					 => clk,					 
		aclk				 => aclk,				 
							                      
		---- TX_ENGINE ----	 
		tx_ext_fifo			 => tx_ext_fifo,			 
		tx_ext_fifo_back	 => tx_ext_fifo_back,	 
							                      
		---- RX_ENGINE ----	 
		rx_ext_fifo			 => rx_ext_fifo,
							                      
		---- REG ----		 
		reg_ext_fifo		 => reg_ext_fifo,		 
		reg_ext_fifo_back	 => reg_ext_fifo_back, 
							 	                 
		---- DISP  ----		 
		ext_fifo_disp		 => ext_fifo_disp,
		ext_fifo_disp_back	 => ext_fifo_disp_back,
		
		irq					 => irq,				-- 1 - запрос прерывания
		
		test				=> px
	);
		
	
 

 int: core64_interrupt 
	port map(
	
		rstp					=> pb_rstp,					-- 1 - сброс
		clk						=> clk,						-- Тактовая частота ядра 250 МГц
		
		irq						=> irq,						-- 1 - запрос прерывания
		
		cfg_command10			=> cfg_command_c(10),		-- 1 - прерывания запрещены 
		cfg_interrupt			=> cfg_interrupt_n_c, 		-- 0 - изменение состояния прерывания
		cfg_interrupt_assert	=> cfg_interrupt_assert_n_c,-- 0 - формирование прерывания, 1 - сниятие прерывания 
		cfg_interrupt_rdy		=> cfg_interrupt_rdy_n_c	-- 0 - подтверждение изменения прерывания 
	
	);
	
--	cfg_interrupt_n_c <= '1';
--	cfg_interrupt_assert_n_c <= '1';
	
end pcie_core64_m6;
