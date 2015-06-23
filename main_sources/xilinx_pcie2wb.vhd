----------------------------------------------------------------------------------
-- Company:
-- Engineer: Istvan Nagy, buenos@freemail.hu
-- 
-- Create Date:    05/30/2010
-- Modify date:    08/10/2012
-- Design Name:    pcie_mini
-- Module Name:    xilinx_pcie2wb - Behavioral 
-- Version:        1.2
-- Project Name: 
-- Target Devices: Xilinx Series-5/6/7 FPGAs
-- Tool versions: ISE-DS 12.1
-- Description: 
--  PCI-express endpoint block, transaction layer logic and back-end logic. The main 
--  purpose of this file is to make a useable back-end interface and handle flow control
--  for the xilinx auto-generated PCIe endpoint IP.
--  The PCIe endpoint implements one 256MByte memory BAR (Base Address Register).
--  This 256MBytes size is set up in the core config, and also hardcoded in this 
--  file (search for: "256MBytes").
--  This 1 BAR is implemented as a Wishbone master interface with byte addressing,
--  where address [x:2] shows DWORD address, while sel[3:0] decodes the 2 LSBs.
--  ADDRESSES ARE BYTE ADDRESSES. 
--  The lower address bits are usually zero, so the slave (MCB) has to select bytes based 
--  on the byte select signals: sel[3:0]. The output address of the core contails the 2 
--  LSBs as well. The core was only tested with 32-bit accesses, byte-wide might work or not.
--  The TLP logic is capable of handling up to 1k bytes (256 DWORDs) payload data in a 
--  single PCIe transaction, and can handle only one request at a time. If a new request 
--  is arriving while processing the previous one (e.g. getting the data from a wishbone 
--  read), then the state machine will not process it immediately, or it will hang. So 
--  the user software has to wait for the previous read completion before issueing a new 
--  request. The multiple DWORDs are handled separately by the WB statemachine.
--  Performance: WishBone bus: 62.5MHz, 32bit, 2clk/access -> 125MBytes/sec. The maximum 
--  data throughput can be achieved when using the maximum data payload (block).
--  The core uses INTA wirtual wire to signal interrupts.
--  
-- x1 PCIe, legacy endpoint, uses a 100MHz ref clock. The generated core had to
-- be edited manually to support 100MHz, as per Xilinx AR#33761.
--
-- Dependencies: The CoreGenerator's configured PCIe core is included.
--  If we generate a new pcie endpoint, then copy the new files from the source
--  directory into the project's directory, and copy the generic section of the "pcie" 
--  from the file: xilinx_pcie_1_1_ep_s6.vhd, into this file.
-- Synthesis: Set the "FSM Encoding Algorithm" to "user".
--
-- Revision: 
-- Revision 1.0 - File Created by Istvan Nagy
-- Revision 1.1 - some fixes by Istvan Nagy
-- Revision 1.2 - interrupt fix by Stephen Battazzo
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;



entity xilinx_pcie2wb is
    Port ( --FPGA PINS(EXTERNAL):
			 pci_exp_txp             : out std_logic;
			 pci_exp_txn             : out std_logic;
			 pci_exp_rxp             : in  std_logic;
			 pci_exp_rxn             : in  std_logic;	 
			 sys_clk_n                 : in  std_logic;
			 sys_clk_p                 : in  std_logic;
			 sys_reset_n             : in  std_logic;			 
			 --ON CHIP PORTS:
			 --DATA BUS for BAR0 (wishbone):
			 pcie_bar0_wb_data_o : out std_logic_vector(31 downto 0); 
			 pcie_bar0_wb_data_i : in std_logic_vector(31 downto 0);
			 pcie_bar0_wb_addr_o : out std_logic_vector(27 downto 0);
			 pcie_bar0_wb_cyc_o : out std_logic;
			 pcie_bar0_wb_stb_o : out std_logic;
			 pcie_bar0_wb_wr_o : out std_logic;
			 pcie_bar0_wb_ack_i : in std_logic;
			 pcie_bar0_wb_clk_o : out std_logic; --62.5MHz		
			 pcie_bar0_wb_sel_o : out std_logic_vector(3 downto 0);			 		 		 
			 --OTHER:
			 pcie_irq : in std_logic;
			 pcie_resetout  : out std_logic --active high
			);
end xilinx_pcie2wb;




architecture Behavioral of xilinx_pcie2wb is

 


   -- Internal Signals ------------------------------------------------------------
	--SIGNAL dummy : std_logic_vector(15 downto 0);	--write data bus
	SIGNAL		cfg_do	:		std_logic_vector(31	downto	0);
	SIGNAL		cfg_rd_wr_done_n	:		std_logic;		
	SIGNAL		cfg_dwaddr	:		std_logic_vector(9	downto	0);
	SIGNAL		cfg_rd_en_n	:		std_logic;		
	SIGNAL		cfg_err_ur_n	:		std_logic;		
	SIGNAL		cfg_err_cor_n	:		std_logic;		
	SIGNAL		cfg_err_ecrc_n	:		std_logic;		
	SIGNAL		cfg_err_cpl_timeout_n	:		std_logic;		
	SIGNAL		cfg_err_cpl_abort_n	:		std_logic;		
	SIGNAL		cfg_err_posted_n	:		std_logic;		
	SIGNAL		cfg_err_locked_n	:		std_logic;		
	SIGNAL		cfg_err_tlp_cpl_header	:		std_logic_vector(47	downto	0);
	SIGNAL		cfg_err_cpl_rdy_n	:		std_logic;		
	SIGNAL		cfg_interrupt_n	:		std_logic;		
	SIGNAL		cfg_interrupt_rdy_n	:		std_logic;		
	SIGNAL		cfg_interrupt_assert_n	:		std_logic;		
	SIGNAL		cfg_interrupt_do	:		std_logic_vector(7	downto	0);
	SIGNAL		cfg_interrupt_di	:		std_logic_vector(7	downto	0);
	SIGNAL		cfg_interrupt_mmenable	:		std_logic_vector(2	downto	0);
	SIGNAL		cfg_interrupt_msienable	:		std_logic;		
	SIGNAL		cfg_turnoff_ok_n	:		std_logic;		
	SIGNAL		cfg_to_turnoff_n	:		std_logic;		
	SIGNAL		cfg_pm_wake_n	:		std_logic;		
	SIGNAL		cfg_pcie_link_state_n	:		std_logic_vector(2	downto	0);
	SIGNAL		cfg_trn_pending_n	:		std_logic;		
	SIGNAL		cfg_dsn	:		std_logic_vector(63	downto	0);
	SIGNAL		cfg_bus_number	:		std_logic_vector(7	downto	0);
	SIGNAL		cfg_device_number	:		std_logic_vector(4	downto	0);
	SIGNAL		cfg_function_number	:		std_logic_vector(2	downto	0);
	SIGNAL		cfg_status	:		std_logic_vector(15	downto	0);
	SIGNAL		cfg_command	:		std_logic_vector(15	downto	0);
	SIGNAL		cfg_dstatus	:		std_logic_vector(15	downto	0);
	SIGNAL		cfg_dcommand	:		std_logic_vector(15	downto	0);
	SIGNAL		cfg_lstatus	:		std_logic_vector(15	downto	0);
	SIGNAL		cfg_lcommand	:		std_logic_vector(15	downto	0);
    -- System Interface
	SIGNAL	    sys_clk                 :   std_logic;
	SIGNAL	    trn_clk                 :  std_logic;
	SIGNAL	    trn_reset_n             :  std_logic;
	SIGNAL	    received_hot_reset      :  std_logic;
    -- Transaction (TRN) Interface
	SIGNAL	    trn_lnk_up_n            :  std_logic;
	--	data interface Tx					
	SIGNAL   	trn_td	:		std_logic_vector(31	downto	0);	
	SIGNAL   	trn_tsof_n	:		std_logic;			
	SIGNAL   	trn_teof_n	:		std_logic;			
	SIGNAL   	trn_tsrc_rdy_n	:		std_logic;			
	SIGNAL   	trn_tdst_rdy_n	:		std_logic;			
	SIGNAL   	trn_terr_drop_n	:		std_logic;			
	SIGNAL   	trn_tsrc_dsc_n	:		std_logic;			
	SIGNAL   	trn_terrfwd_n	:		std_logic;			
	SIGNAL   	trn_tbuf_av	:		std_logic_vector(5	downto	0);	
	SIGNAL   	trn_tstr_n	:		std_logic;			
	SIGNAL   	trn_tcfg_req_n	:		std_logic;			
	SIGNAL   	trn_tcfg_gnt_n	:		std_logic;		
	--	data interface Rx					
	SIGNAL   	trn_rd	:		std_logic_vector(31	downto	0);	
	SIGNAL   	trn_rsof_n	:		std_logic;			
	SIGNAL   	trn_reof_n	:		std_logic;			
	SIGNAL   	trn_rsrc_rdy_n	:		std_logic;			
	SIGNAL   	trn_rsrc_dsc_n	:		std_logic;			
	SIGNAL   	trn_rdst_rdy_n	:		std_logic;			
	SIGNAL   	trn_rerrfwd_n	:		std_logic;			
	SIGNAL   	trn_rnp_ok_n	:		std_logic;			
	SIGNAL   	trn_rbar_hit_n	:		std_logic_vector(6	downto	0);	
	-- flow control
	SIGNAL   	trn_fc_sel	:		std_logic_vector(2	downto	0);	
	SIGNAL   	trn_fc_nph	:		std_logic_vector(7	downto	0);	
	SIGNAL   	trn_fc_npd	:		std_logic_vector(11	downto	0);	
	SIGNAL   	trn_fc_ph	:		std_logic_vector(7	downto	0);	
	SIGNAL   	trn_fc_pd	:		std_logic_vector(11	downto	0);	
	SIGNAL   	trn_fc_cplh	:		std_logic_vector(7	downto	0);	
	SIGNAL   	trn_fc_cpld	:		std_logic_vector(11	downto	0);	

	SIGNAL   start_read_wb0	:		std_logic;	
	SIGNAL   start_write_wb0	:		std_logic;	
	SIGNAL   wb_transaction_complete	:		std_logic;	
	SIGNAL   pcie_bar0_wb_data_i_latched	:		std_logic_vector(31	downto	0);	
	SIGNAL   pcie_bar0_wb_data_o_feed	:		std_logic_vector(31	downto	0);	
	SIGNAL   pcie_bar0_wb_addr_o_feed	:		std_logic_vector(27	downto	0);	
	SIGNAL   pcie_bar0_wb_sel_o_feed 	:		std_logic_vector(3	downto	0);	
	SIGNAL   start_read_wb1	:		std_logic;	
	SIGNAL   start_write_wb1	:		std_logic;	
	SIGNAL   rd_data_ready_wb1	:		std_logic;	

    SIGNAL   pcie_just_received_a_new_tlp      :  std_logic  ;
    SIGNAL   pcie_start_reading_rx_tlp      :  std_logic  ;
    SIGNAL   pcie_there_is_a_new_tlp_to_transmit      :  std_logic  ;
    SIGNAL   rxtlp_decodedaddress      :  std_logic_vector(31 downto 0);
    SIGNAL   tlp_payloadsize_dwords      :  std_logic_vector(7 downto 0);
    SIGNAL   rxtlp_firstdw_be      :  std_logic_vector(3 downto 0);
    SIGNAL   rxtlp_lastdw_be      :  std_logic_vector(3 downto 0);
    SIGNAL   rxtlp_requesterid      :  std_logic_vector(15 downto 0);
    SIGNAL   tlp_state      :  std_logic_vector(7 downto 0);
    SIGNAL   tlp_state_copy      :  std_logic_vector(7 downto 0);
    SIGNAL   rxtlp_data_0      :  std_logic_vector(31 downto 0);
    SIGNAL   rxtlp_data_1      :  std_logic_vector(31 downto 0);
    SIGNAL   rxtlp_data_2      :  std_logic_vector(31 downto 0);
    SIGNAL   rxtlp_data_3      :  std_logic_vector(31 downto 0);
    SIGNAL   rxtlp_data_4      :  std_logic_vector(31 downto 0);
    SIGNAL   rxtlp_data_5      :  std_logic_vector(31 downto 0);
    SIGNAL   rxtlp_data_6      :  std_logic_vector(31 downto 0);
    SIGNAL   rxtlp_data_7      :  std_logic_vector(31 downto 0);
    SIGNAL   txtlp_data_0      :  std_logic_vector(31 downto 0);
    SIGNAL   txtlp_data_1      :  std_logic_vector(31 downto 0);
    SIGNAL   txtlp_data_2      :  std_logic_vector(31 downto 0);
    SIGNAL   txtlp_data_3      :  std_logic_vector(31 downto 0);
    SIGNAL   txtlp_data_4      :  std_logic_vector(31 downto 0);
    SIGNAL   txtlp_data_5      :  std_logic_vector(31 downto 0);
    SIGNAL   txtlp_data_6      :  std_logic_vector(31 downto 0);
    SIGNAL   txtlp_data_7      :  std_logic_vector(31 downto 0);
    SIGNAL   pcie_tlp_tx_complete       :  std_logic; 
	 
	 --this signal added by StBa, AAC Microtec
	 SIGNAL  irq_prohibit    :   std_logic;
	 
	 SIGNAL  pcieirq_state    :  std_logic_vector(7 downto 0);
	 SIGNAL  txtrn_counter   :  std_logic_vector(7 downto 0);
	 SIGNAL  trn_rx_counter   :  std_logic_vector(7 downto 0);
	 SIGNAL cfg_completer_id  :  std_logic_vector(15 downto 0);
	 SIGNAL wb0_state :   std_logic_vector(7 downto 0);
	 SIGNAL epif_tx_state :   std_logic_vector(7 downto 0);
	 SIGNAL epif_rx_state :   std_logic_vector(7 downto 0);
	 SIGNAL bit10 :   std_logic_vector(1 downto 0);

  SIGNAL bram_rxtlp_we : std_logic_vector(0 downto 0);
  SIGNAL bram_rxtlp_writeaddress : std_logic_vector(31 downto 0);
  SIGNAL bram_rxtlp_writedata : std_logic_vector(31 downto 0);
  SIGNAL bram_rxtlp_readaddress : std_logic_vector(31 downto 0);
  SIGNAL bram_rxtlp_readdata : std_logic_vector(31 downto 0);
  SIGNAL bram_txtlp_we : std_logic_vector(0 downto 0);
  SIGNAL bram_txtlp_writeaddress : std_logic_vector(8 downto 0);
  SIGNAL bram_txtlp_writedata : std_logic_vector(31 downto 0);
  SIGNAL bram_txtlp_readaddress : std_logic_vector(31 downto 0);
  SIGNAL bram_txtlp_readdata : std_logic_vector(31 downto 0);
  
  SIGNAL tlp_datacount :   std_logic_vector(7 downto 0);
  --SIGNAL bram_rxtlp_firstdata_address : std_logic_vector(8 downto 0);
  SIGNAL rxtlp_header_dw1 : std_logic_vector(31 downto 0);
  SIGNAL rxtlp_header_dw2 : std_logic_vector(31 downto 0);
  SIGNAL rxtlp_header_dw3 : std_logic_vector(31 downto 0);
  SIGNAL rxtlp_header_dw4 : std_logic_vector(31 downto 0);
  SIGNAL flag1 :      std_logic; 
  SIGNAL rxdw1_23_0  : std_logic_vector(23 downto 0); 
  SIGNAL pcie_rxtlp_tag  : std_logic_vector(7 downto 0); 
  SIGNAL pciewb_localreset_n :      std_logic;
  SIGNAL cfg_interrupt_assert_n_1 :      std_logic;
  SIGNAL trn_tsrc_rdy_n_1 :      std_logic;
  SIGNAL trn_tsof_n1 :      std_logic;
  SIGNAL rcompl_bytecount_field  : std_logic_vector(9 downto 0);
  SIGNAL rxstm_readytoroll :      std_logic;
  SIGNAL tlpstm_isin_idle :      std_logic;
  
  
  
  
  
	-- COMPONENT DECLARATIONS (introducing the IPs) --------------------------------

  --this is the pcie endpoint core from coregenerator.
	--Core name: Xilinx Spartan-6 Integrated
	--Block for PCI Express
	--Version: 1.2
	--Release Date: September 16, 2009. ISE DS 11.4
  component pcie is
  generic (
    TL_TX_RAM_RADDR_LATENCY           : integer    := 0;
    TL_TX_RAM_RDATA_LATENCY           : integer    := 2;
    TL_RX_RAM_RADDR_LATENCY           : integer    := 0;
    TL_RX_RAM_RDATA_LATENCY           : integer    := 2;
    TL_RX_RAM_WRITE_LATENCY           : integer    := 0;
    VC0_TX_LASTPACKET                 : integer    := 14;
    VC0_RX_RAM_LIMIT                  : bit_vector := x"7FF";
    VC0_TOTAL_CREDITS_PH              : integer    := 32;
    VC0_TOTAL_CREDITS_PD              : integer    := 211;
    VC0_TOTAL_CREDITS_NPH             : integer    := 8;
    VC0_TOTAL_CREDITS_CH              : integer    := 40;
    VC0_TOTAL_CREDITS_CD              : integer    := 211;
    VC0_CPL_INFINITE                  : boolean    := TRUE;
    BAR0                              : bit_vector := x"F0000000";
    BAR1                              : bit_vector := x"00000000";
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
    DEV_CAP_MAX_PAYLOAD_SUPPORTED     : integer    := 2;
    CLASS_CODE                        : bit_vector := x"068000";
    CARDBUS_CIS_POINTER               : bit_vector := x"00000000";
    PCIE_CAP_CAPABILITY_VERSION       : bit_vector := x"1";
    PCIE_CAP_DEVICE_PORT_TYPE         : bit_vector := x"1";
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
    --LINK_CAP_L0S_EXIT_LATENCY         : integer    := 7;
    --LINK_CAP_L1_EXIT_LATENCY          : integer    := 7;
    LL_ACK_TIMEOUT                    : bit_vector := x"0000";
    LL_ACK_TIMEOUT_EN                 : boolean    := FALSE;
    --LL_REPLAY_TIMEOUT                 : bit_vector := x"0204";
	 LL_REPLAY_TIMEOUT                 : bit_vector := x"0000";
    LL_REPLAY_TIMEOUT_EN              : boolean    := FALSE;
    MSI_CAP_MULTIMSGCAP               : integer    := 0;
    MSI_CAP_MULTIMSG_EXTENSION        : integer    := 0;
    LINK_STATUS_SLOT_CLOCK_CONFIG     : boolean    := FALSE;
    PLM_AUTO_CONFIG                   : boolean    := FALSE;
    FAST_TRAIN                        : boolean    := FALSE;
    ENABLE_RX_TD_ECRC_TRIM            : boolean    := FALSE;
    DISABLE_SCRAMBLING                : boolean    := FALSE;
    PM_CAP_VERSION                    : integer    := 3;
    PM_CAP_PME_CLOCK                  : boolean    := FALSE;
    PM_CAP_DSI                        : boolean    := FALSE;
    PM_CAP_AUXCURRENT                 : integer    := 0;
    PM_CAP_D1SUPPORT                  : boolean    := TRUE;
    PM_CAP_D2SUPPORT                  : boolean    := TRUE;
    PM_CAP_PMESUPPORT                 : bit_vector := x"0F";
    PM_DATA0                          : bit_vector := x"04";
    PM_DATA_SCALE0                    : bit_vector := x"0";
    PM_DATA1                          : bit_vector := x"00";
    PM_DATA_SCALE1                    : bit_vector := x"0";
    PM_DATA2                          : bit_vector := x"00";
    PM_DATA_SCALE2                    : bit_vector := x"0";
    PM_DATA3                          : bit_vector := x"00";
    PM_DATA_SCALE3                    : bit_vector := x"0";
    PM_DATA4                          : bit_vector := x"04";
    PM_DATA_SCALE4                    : bit_vector := x"0";
    PM_DATA5                          : bit_vector := x"00";
    PM_DATA_SCALE5                    : bit_vector := x"0";
    PM_DATA6                          : bit_vector := x"00";
    PM_DATA_SCALE6                    : bit_vector := x"0";
    PM_DATA7                          : bit_vector := x"00";
    PM_DATA_SCALE7                    : bit_vector := x"0";
    PCIE_GENERIC                      : bit_vector := "000011101111";
    GTP_SEL                           : integer    := 0;
    CFG_VEN_ID                        : std_logic_vector(15 downto 0) := x"10EE";
    CFG_DEV_ID                        : std_logic_vector(15 downto 0) := x"BADD";
    CFG_REV_ID                        : std_logic_vector(7 downto 0)  := x"00";
    CFG_SUBSYS_VEN_ID                 : std_logic_vector(15 downto 0) := x"10EE";
    CFG_SUBSYS_ID                     : std_logic_vector(15 downto 0) := x"1234";
    REF_CLK_FREQ                      : integer    := 0
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
  end component pcie;

	COMPONENT blk_mem_gen_v4_1
	PORT(
		clka : IN std_logic;
		wea : IN std_logic_vector(0 to 0);
		addra : IN std_logic_vector(8 downto 0);
		dina : IN std_logic_vector(31 downto 0);
		clkb : IN std_logic;
		addrb : IN std_logic_vector(8 downto 0);          
		doutb : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;



---- ------- SYNTHESIS ATTRIBUTES: --------------------------------------------------
--attribute keep_hierarchy : string; 
--attribute keep_hierarchy of xilinx_pcie2wb: entity is "yes"; 
attribute keep : string;
attribute keep of cfg_dstatus : signal is "true";
attribute keep of tlp_state : signal is "true";


-- --------ARCHITECTURE BODY BEGINS -----------------------------------------------
begin


cfg_turnoff_ok_n <= '1';

	-- COMPONENT INSTALLATIONS (connecting the IPs to local signals) ---------------


	-- COMPONENT INSTALLATIONS (connecting the IPs to local signals) ---------------

  inst_pcie : pcie
  port map (
    pci_exp_txp             => pci_exp_txp,
    pci_exp_txn             => pci_exp_txn,
    pci_exp_rxp             => pci_exp_rxp,
    pci_exp_rxn             => pci_exp_rxn,
    trn_lnk_up_n            => trn_lnk_up_n,
    trn_td                  => trn_td,                   -- Bus [31 : 0]
    trn_tsof_n              => trn_tsof_n,
    trn_teof_n              => trn_teof_n,
    trn_tsrc_rdy_n          => trn_tsrc_rdy_n,
    trn_tdst_rdy_n          => trn_tdst_rdy_n,
    trn_terr_drop_n         => trn_terr_drop_n,
    trn_tsrc_dsc_n          => trn_tsrc_dsc_n,
    trn_terrfwd_n           => trn_terrfwd_n,
    trn_tbuf_av             => trn_tbuf_av,              -- Bus [31 : 0]
    trn_tstr_n              => trn_tstr_n,
    trn_tcfg_req_n          => trn_tcfg_req_n,
    trn_tcfg_gnt_n          => trn_tcfg_gnt_n,
    trn_rd                  => trn_rd,                   -- Bus [31 : 0]
    trn_rsof_n              => trn_rsof_n,
    trn_reof_n              => trn_reof_n,
    trn_rsrc_rdy_n          => trn_rsrc_rdy_n,
    trn_rsrc_dsc_n          => trn_rsrc_dsc_n,
    trn_rdst_rdy_n          => trn_rdst_rdy_n,
    trn_rerrfwd_n           => trn_rerrfwd_n,
    trn_rnp_ok_n            => trn_rnp_ok_n,
    trn_rbar_hit_n          => trn_rbar_hit_n,           -- Bus [31 : 0]
    trn_fc_sel              => trn_fc_sel,               -- Bus [31 : 0]
    trn_fc_nph              => trn_fc_nph,               -- Bus [31 : 0]
    trn_fc_npd              => trn_fc_npd,               -- Bus [31 : 0]
    trn_fc_ph               => trn_fc_ph,                -- Bus [31 : 0]
    trn_fc_pd               => trn_fc_pd,                -- Bus [31 : 0]
    trn_fc_cplh             => trn_fc_cplh,              -- Bus [31 : 0]
    trn_fc_cpld             => trn_fc_cpld,              -- Bus [31 : 0]
    cfg_do                  => cfg_do,                   -- Bus [31 : 0]
    cfg_rd_wr_done_n        => cfg_rd_wr_done_n,
    cfg_dwaddr              => cfg_dwaddr,               -- Bus [31 : 0]
    cfg_rd_en_n             => cfg_rd_en_n,
    cfg_err_ur_n            => cfg_err_ur_n,
    cfg_err_cor_n           => cfg_err_cor_n,
    cfg_err_ecrc_n          => cfg_err_ecrc_n,
    cfg_err_cpl_timeout_n   => cfg_err_cpl_timeout_n,
    cfg_err_cpl_abort_n     => cfg_err_cpl_abort_n,
    cfg_err_posted_n        => cfg_err_posted_n,
    cfg_err_locked_n        => cfg_err_locked_n,
    cfg_err_tlp_cpl_header  => cfg_err_tlp_cpl_header,   -- Bus [31 : 0]
    cfg_err_cpl_rdy_n       => cfg_err_cpl_rdy_n,
    cfg_interrupt_n         => cfg_interrupt_n,
    cfg_interrupt_rdy_n     => cfg_interrupt_rdy_n,
    cfg_interrupt_assert_n  => cfg_interrupt_assert_n,
    cfg_interrupt_do        => cfg_interrupt_do,         -- Bus [31 : 0]
    cfg_interrupt_di        => cfg_interrupt_di,         -- Bus [31 : 0]
    cfg_interrupt_mmenable  => cfg_interrupt_mmenable,   -- Bus [31 : 0]
    cfg_interrupt_msienable => cfg_interrupt_msienable,
    cfg_turnoff_ok_n        => cfg_turnoff_ok_n,
    cfg_to_turnoff_n        => cfg_to_turnoff_n,
    cfg_pm_wake_n           => cfg_pm_wake_n,
    cfg_pcie_link_state_n   => cfg_pcie_link_state_n,    -- Bus [31 : 0]
    cfg_trn_pending_n       => cfg_trn_pending_n,
    cfg_dsn                 => cfg_dsn,                  -- Bus [31 : 0]
    cfg_bus_number          => cfg_bus_number,           -- Bus [31 : 0]
    cfg_device_number       => cfg_device_number,        -- Bus [31 : 0]
    cfg_function_number     => cfg_function_number,      -- Bus [31 : 0]
    cfg_status              => cfg_status,               -- Bus [31 : 0]
    cfg_command             => cfg_command,              -- Bus [31 : 0]
    cfg_dstatus             => cfg_dstatus,              -- Bus [31 : 0]
    cfg_dcommand            => cfg_dcommand,             -- Bus [31 : 0]
    cfg_lstatus             => cfg_lstatus,              -- Bus [31 : 0]
    cfg_lcommand            => cfg_lcommand,             -- Bus [31 : 0]
    sys_clk                 => sys_clk,
    sys_reset_n             => sys_reset_n,
    trn_clk                 => trn_clk,
    trn_reset_n             => trn_reset_n,
    received_hot_reset      => received_hot_reset
  );

	--block ram for RX TLP:
	Inst_bram_rxtlp: blk_mem_gen_v4_1 PORT MAP(
		clka => trn_clk,
		wea => bram_rxtlp_we,
		addra => bram_rxtlp_writeaddress(8 downto 0),
		dina => bram_rxtlp_writedata,
		clkb => trn_clk,
		addrb => bram_rxtlp_readaddress(8 downto 0),
		doutb => bram_rxtlp_readdata
	);

	--block ram for TX TLP:
	Inst_bram_txtlp: blk_mem_gen_v4_1 PORT MAP(
		clka => trn_clk,
		wea => bram_txtlp_we,
		addra => bram_txtlp_writeaddress(8 downto 0),
		dina => bram_txtlp_writedata,
		clkb => trn_clk,
		addrb => bram_txtlp_readaddress(8 downto 0),
		doutb => bram_txtlp_readdata
	); 





	-- MAIN LOGIC: ---------------------------------------------------------------------------------------------
	
	
	
	--System Signals:--------------------------------
	
  --Clock Input Buffer for differential system clock
   IBUFDS_inst : IBUFDS
   generic map (
      DIFF_TERM => TRUE, -- Differential Termination 
      IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD => "DEFAULT")
   port map (
      O => sys_clk,  -- Buffer output
      I => sys_clk_p,  -- Diff_p buffer input (connect directly to top-level port)
      IB => sys_clk_n -- Diff_n buffer input (connect directly to top-level port)
   );

  --wishbone clock output:
  pcie_bar0_wb_clk_o <= trn_clk;
  --pcie_bar1_wb_clk_o <= trn_clk; 
  

  --use one of these for resetting logic in this file:
    pciewb_localreset_n <= sys_reset_n; --dont wait for the PCIE-EP to finish its init.
    --pciewb_localreset_n <= trn_reset_n;
	 --pciewb_localreset_n <= trn_reset_n and (not trn_lnk_up_n) and (not received_hot_reset);
  --reset to the core:
  --sys_reset_n comes from toplevel directly to the core. same name
  --reset output to other cores:
  pcie_resetout <= not pciewb_localreset_n; 
  
  --trn_lnk_up_n    --not used.
  

  --pcie ep ip config port: ----------------------------------------------------------
  
   --trn_fc_sel             <= "000";

  trn_rnp_ok_n           <= '0';
  --trn_terrfwd_n          <= '1';

  --trn_tcfg_gnt_n         <= '0';

  cfg_err_cor_n          <= '1';
  cfg_err_ur_n           <= '1';
  cfg_err_ecrc_n         <= '1';
  cfg_err_cpl_timeout_n  <= '1';
  cfg_err_cpl_abort_n    <= '1';
  cfg_err_posted_n       <= '0';
  cfg_err_locked_n       <= '1';
  cfg_pm_wake_n          <= '1';
  cfg_trn_pending_n      <= '1';

  --trn_tstr_n             <= '0'; 
  --cfg_interrupt_assert_n <= '1'; --used in a process at the bottom of this file
  --cfg_interrupt_n        <= '1';
  --cfg_interrupt_di       <= x"00"; --intA used

  cfg_err_tlp_cpl_header <= (OTHERS => '0');
  cfg_dwaddr             <= (OTHERS => '0');
  cfg_rd_en_n            <= '1';
  --serial number:
  cfg_dsn                <= (OTHERS => '0');

 -- AT THE BOTTOM OF THIS FILE:
 -- 	 --some fix values:
 --	 trn_tsrc_dsc_n <= '1'; --no errors on trn bus
 --	 trn_tstr_n <= '0'; --pipelining (0= link may begin before the entire packet has been written)
 --	 trn_tcfg_gnt_n <= '0'; --no tlp priorities
 --	 trn_terrfwd_n <= '1'; --no errors on trn
 --	 --nc: trn_tbuf_av, trn_terr_drop_n, trn_tcfg_req_n



  --use this in read completion packets:
  cfg_completer_id       <= cfg_bus_number & cfg_device_number & cfg_function_number;

  




	-- WISBONE BACK-end INTERFACE ----------------------------------------------------

    --main state machine: set states, capture inputs, set addr/data outputs
	 --minimum 2 clock cycles / transaction. writes are posted, reads have wait states.
    process (pciewb_localreset_n, trn_clk, wb0_state, start_read_wb0, start_write_wb0,
				pcie_bar0_wb_addr_o_feed, pcie_bar0_wb_data_o_feed, pcie_bar0_wb_sel_o_feed) 
    begin
    if (pciewb_localreset_n='0') then 
       wb0_state <= "00000000";
       wb_transaction_complete <= '0';
		 pcie_bar0_wb_addr_o <= "0000000000000000000000000000";
		 pcie_bar0_wb_sel_o <= "0000";
		 pcie_bar0_wb_data_o <= "00000000000000000000000000000000";		
		 wb_transaction_complete <='0';		 
    else
      if (trn_clk'event and trn_clk = '1') then
                case ( wb0_state ) is

                --********** IDLE STATE  **********
                when "00000000" =>   --state 0        
                    wb_transaction_complete <='0';
						  pcie_bar0_wb_sel_o <= pcie_bar0_wb_sel_o_feed;
						  pcie_bar0_wb_addr_o <= pcie_bar0_wb_addr_o_feed;
						  if (start_read_wb0 ='1') then --go to read
						    wb0_state <= "00000001";
						  elsif (start_write_wb0 ='1') then --go to write
						    wb0_state <= "00000010";
							 --no endian swap: pcie_bar0_wb_data_o <= pcie_bar0_wb_data_o_feed;
						    pcie_bar0_wb_data_o (7 downto 0) <= pcie_bar0_wb_data_o_feed(31 downto 24); --swap endianism
						    pcie_bar0_wb_data_o (15 downto 8) <= pcie_bar0_wb_data_o_feed(23 downto 16); --swap endianism
						    pcie_bar0_wb_data_o (23 downto 16) <= pcie_bar0_wb_data_o_feed(15 downto 8); --swap endianism
						    pcie_bar0_wb_data_o (31 downto 24) <= pcie_bar0_wb_data_o_feed(7 downto 0); --swap endianism								  
						  end if;

                --********** READ STATE ********** 
					 --set the outputs, 
					 --if ACK asserted, sample the data input
					 --The hold requirements are oversatisfyed by going back to idle, and by the fact that the slave uses the cyc/stb/wr strobes synchronously.
                when "00000001" =>   --state 1
                    if (pcie_bar0_wb_ack_i='1') then
						    --no endian swap: pcie_bar0_wb_data_i_latched <= pcie_bar0_wb_data_i; --sample the incoming data
						    pcie_bar0_wb_data_i_latched (7 downto 0) <= pcie_bar0_wb_data_i(31 downto 24); --swap endianism
						    pcie_bar0_wb_data_i_latched (15 downto 8) <= pcie_bar0_wb_data_i(23 downto 16); --swap endianism
						    pcie_bar0_wb_data_i_latched (23 downto 16) <= pcie_bar0_wb_data_i(15 downto 8); --swap endianism
						    pcie_bar0_wb_data_i_latched (31 downto 24) <= pcie_bar0_wb_data_i(7 downto 0); --swap endianism							
							 wb_transaction_complete <='1'; --signalling ready, but only for one clock cycle
							 wb0_state <= "00000000"; --go to state 0
						  else
						  	 wb_transaction_complete <='0';
						  end if;	   		  

                --********** WRITE STATE **********     
					 --if ACK asserted, go back to idle
					 --The hold requirements are oversatisfyed by waiting for ACK to remove write data					 
                when "00000010" =>   --state 2
                    if (pcie_bar0_wb_ack_i='1') then
							 wb0_state <= "00000000"; --go to state 0
							 wb_transaction_complete <='1';
						  else
						     wb_transaction_complete <='0';
						  end if;
						  
                when others => --error
                      wb0_state <= "00000000"; --go to state 0
                end case;     
       end if;        
    end if;
    end process;
    --sync control on wb-control signals:
    process (pciewb_localreset_n, wb0_state) 
    begin
    if (pciewb_localreset_n='0') then 
		pcie_bar0_wb_cyc_o  <= '0';
		pcie_bar0_wb_stb_o  <= '0';
		pcie_bar0_wb_wr_o  <= '0';
    else
      if (wb0_state = "00000000") then --idle
			pcie_bar0_wb_cyc_o  <= '0';
			pcie_bar0_wb_stb_o  <= '0';
			pcie_bar0_wb_wr_o  <= '0';
      elsif (wb0_state = "00000001") then --read 
			pcie_bar0_wb_cyc_o  <= '1';
			pcie_bar0_wb_stb_o  <= '1';
			pcie_bar0_wb_wr_o  <= '0';
      elsif (wb0_state = "00000010") then --write 
			pcie_bar0_wb_cyc_o  <= '1';
			pcie_bar0_wb_stb_o  <= '1';
			pcie_bar0_wb_wr_o  <= '1';
		else
			pcie_bar0_wb_cyc_o  <= '0';
			pcie_bar0_wb_stb_o  <= '0';
			pcie_bar0_wb_wr_o  <= '0';
		end if;
    end if;
    end process;








	-- INTERFACE TO THE PCIE-EP IP --------------------------------------------------------
	--trn_clk and trn_reset_n are the same as the pcie_resetout and pcie_bar0_wb_clk_o,
	--so it is not a clock domain crossing.


	-- TX: INTERFACE TO THE PCIE-EP: TRANSMIT TLP PACKETS:-----
	--Read completion is 3DW header. This core only transmits read completion or Unbsupported request packets.
    process (pciewb_localreset_n, trn_clk, epif_tx_state, bram_txtlp_readdata , bram_txtlp_readaddress,
				pcie_there_is_a_new_tlp_to_transmit, tlp_payloadsize_dwords, txtrn_counter) 
    begin
    if (pciewb_localreset_n='0') then 
      epif_tx_state <= "00000000";
      trn_tsrc_rdy_n_1 <='1';
		trn_tsof_n1 <= '1';
		trn_teof_n <= '1';
		trn_td <= (OTHERS => '0');
		pcie_tlp_tx_complete <= '0';
		txtrn_counter <= "00000001";
		bram_txtlp_readaddress <= (OTHERS => '0');
    else
      if (trn_clk'event and trn_clk = '1') then
                case ( epif_tx_state ) is

                --********** idle STATE  **********
                when "00000000" =>   --state 0        
                    --if there is a new TLP assembled and the EP is ready, 
						  --start the tx-trn bus transaction.
						  if (pcie_there_is_a_new_tlp_to_transmit='1') then
						    epif_tx_state <= "00000001"; --next state
						  end if;
                    trn_tsrc_rdy_n_1 <='1';
						  trn_tsof_n1 <= '1';
						  trn_teof_n <= '1';
						  trn_td <= (OTHERS => '0');
						  pcie_tlp_tx_complete <= '0';
						  txtrn_counter <= "00000001";
						  bram_txtlp_readaddress <= (OTHERS => '0');

                --********** ready-wait STATE  **********
                when "00000001" =>   --state 1        
                    --if there is a new TLP assembled and the EP is ready, 
						  --start the tx-trn bus transaction.
						  if (trn_tdst_rdy_n='0') then
						    epif_tx_state <= "00000010"; --next state
						  end if;
                    trn_tsrc_rdy_n_1 <='1';
						  trn_tsof_n1 <= '1';
						  trn_teof_n <= '1';
						  trn_td <= (OTHERS => '0');
						  pcie_tlp_tx_complete <= '0';
						  txtrn_counter <= "00000001";
						  bram_txtlp_readaddress <= (OTHERS => '0');
						  
                --********** transfer STATE **********     				 
                when "00000010" =>   --state 2
                    trn_tsrc_rdy_n_1 <='0';
						  trn_td <= bram_txtlp_readdata;
						  if (trn_tdst_rdy_n='0') then
						    txtrn_counter <= txtrn_counter +1;
							 bram_txtlp_readaddress <= bram_txtlp_readaddress +1;
						  end if;
						  if (txtrn_counter = "00000010") then
						    trn_tsof_n1 <= '0'; --start
						  else
						    trn_tsof_n1 <= '1';
						  end if;
						  --test number of dwords:
						  if (txtrn_counter = tlp_payloadsize_dwords +4) then -- "+3" is the header and "+1" is for the delay
						  --this is the last dword, next clk is next state
							 epif_tx_state <= "00000000"; --back to idle, since finished
						    trn_teof_n <= '0'; --end
						    pcie_tlp_tx_complete <= '1'; --assert for 1 clk
						  else
						    trn_teof_n <= '1'; --not end yet
						    pcie_tlp_tx_complete <= '0'; --not complete yet
						  end if;

                when others => --error
                    epif_tx_state <= "00000000"; --back to idle
                    trn_tsrc_rdy_n_1 <='1';
						  trn_tsof_n1 <= '1';
						  trn_teof_n <= '1';
						  trn_td <= (OTHERS => '0');
						  pcie_tlp_tx_complete <= '0';
						  txtrn_counter <= "00000001";
						  
                end case;     
       end if;        
    end if;
    end process;
	 
	--this (little delay) is to fix a hold time violation created inside the pcie-ep ip:
	trn_tsrc_rdy_n <= trn_tsrc_rdy_n_1 or (not pciewb_localreset_n);
	trn_tsof_n <= trn_tsof_n1 or (not pciewb_localreset_n);

 

	 --some fix values:
	 trn_tsrc_dsc_n <= '1'; --no errors on trn bus
	 trn_tstr_n <= '0'; --pipelining 
	 trn_tcfg_gnt_n <= '0'; --no tlp priorities 
	 trn_terrfwd_n <= '1'; --no errors on trn
	 --nc: trn_tbuf_av, trn_terr_drop_n, trn_tcfg_req_n





	-- RX: INTERFACE TO THE PCIE-EP: GET thereceived TLP PACKETS:- ----
    process (pciewb_localreset_n, trn_clk, epif_rx_state, tlp_state, trn_rx_counter, 
				bram_rxtlp_writeaddress, rxstm_readytoroll, trn_rsof_n, tlpstm_isin_idle, trn_rdst_rdy_n) 
    begin
    if (pciewb_localreset_n='0') then 
		 pcie_just_received_a_new_tlp <= '0'; 
		 epif_rx_state	<= "00000000"; 
		 trn_rdst_rdy_n <= '1';
		 trn_rx_counter <= (OTHERS => '0');
		 bram_rxtlp_we <= "0";
		 bram_rxtlp_writeaddress <= (OTHERS => '0');
		 bram_rxtlp_writedata  <= (OTHERS => '0');
		 rxstm_readytoroll <= '0';
    else
      if (trn_clk'event and trn_clk = '1') then

                case ( epif_rx_state ) is

                --********** idle STATE  **********
                when "00000000" =>   --state 0
						  pcie_just_received_a_new_tlp <= '0';
						  bram_rxtlp_writedata  <= trn_rd;
						  if (trn_rsrc_rdy_n='0' and trn_rsof_n='0' and tlpstm_isin_idle = '1' and trn_rdst_rdy_n='0') then 
						    trn_rx_counter <= trn_rx_counter +1;
							 bram_rxtlp_writeaddress <= bram_rxtlp_writeaddress +1;
							 epif_rx_state <= "00000001";
						  else
						    trn_rx_counter <= (OTHERS => '0');
							 bram_rxtlp_writeaddress  <= (OTHERS => '0');
						  end if;
						  --destination ready:
						  if (tlpstm_isin_idle = '1')then
							  trn_rdst_rdy_n <= '0';
						  else
							  trn_rdst_rdy_n <= '1';
						  end if;
						  --write into buffer:
						  if (trn_rsrc_rdy_n='0' and trn_rsof_n='0' and tlpstm_isin_idle = '1') then 
							 bram_rxtlp_we <= "1";
							 rxstm_readytoroll <= '1';
						  else
							 bram_rxtlp_we <= "0";
							 rxstm_readytoroll <= '0';
						  end if;

                --********** read STATE ********** 
                when "00000001" =>   --state 1
						  rxstm_readytoroll <= '0';
						  if (trn_reof_n ='0') then --last dw
						    epif_rx_state <= "00000010"; --for the next clk cycle
							 trn_rdst_rdy_n <= '1'; --ok, dont send more yet
						  end if;
						  if (trn_rsrc_rdy_n='0') then --only act if the EP was ready
							  trn_rx_counter <= trn_rx_counter +1;
							  bram_rxtlp_writeaddress <= bram_rxtlp_writeaddress +1;
							  bram_rxtlp_writedata  <= trn_rd;
						  end if;
						  --in an early stage of this transfer, the scheduler can already
						  --start working on the data, this way its pipelined, so the latency is lower.
						  if (trn_rx_counter = "00000010") then
						   pcie_just_received_a_new_tlp <= '1';--assert for one clk only
						  else
						   pcie_just_received_a_new_tlp <= '0';
						  end if;

                --********** finished filling up RX TLP STATE **********     				 
                when "00000010" =>   --state 2
						  epif_rx_state <= "00000000";
						  trn_rx_counter <= (OTHERS => '0');
						  
                when others => --error
                      epif_rx_state <= "00000000"; --go to state 0
                end case;     
       end if;        
    end if;
    end process;
	 
	 --fixed connections:
	 --trn_rnp_ok_ntrn_rnp_ok_n <= '0'; --ready to receive non-posted
	 --not connected: trn_rerrfwd_n, trn_rsrc_dsc_n, trn_rbar_hit_n





	-- flow control: INTERFACE TO THE PCIE-EP: - ----
	--not used. pcie-ep provides information about credit status.
	--unconnected: trn_fc_nph, trn_fc_npd, trn_fc_ph, trn_fc_pd, trn_fc_cplh, trn_fc_cpld
	trn_fc_sel <= "000";





	-- --- GLUE LOGIC BETWEEN THE PCIE CORE-IF AND THE WB INTERFACES -----------------------
	-- --- ALSO TLP PACKET PROCESSING.
	--Theory of operation:
	--RX: If we receive a TLP (pcie_just_received_a_new_tlp goes high for one clock cycle), 
	--then store it (pcie_received_tlp), decode it (to figure out if its read request, 
	--posted write or non-supported request), then assert a flag (start_write_wb0 or 
	--start_read_wb0)to initiate a wishbone cycle.
	--TX: At the completion of a wishbone read, the wishbone statemachine asserts the 
	--wb_transaction_complete flag, so we can assemble the TX TLP packet (pcie_to_transmit_tlp) 
	--and assert the flag named pcie_there_is_a_new_tlp_to_transmit. This packet will be 
	--a read completion packet on the PCIe link.
	--
	--This core can handle 1...8 DWORD accesses in one request (max 256bit payload ), 
	--and can handle only one request at a time. If a new request is arriving while
	--processing the previous one (e.g. getting the data from a wishbone read), then 
	--the state machine will not process it immediately, or it will hang. So the user 
	--software has to wait for the previous read completion before issueing a new request.
	--The multiple DWORDs are handled separately by the WB statemachine.
   --Performance: WishBone bus: 62.5MHz, 32bit, 3clk/access -> 83MBytes/sec
	--
	--TLP decoding: 
	--Header+Payload_data+TLP_DIGEST(ECRC). 
	--received Header:
	--First Dword: bit.30/29=format: 00=3DW-header+no_data, 01=4DW-header+no_data, 
	--10=3DW-header+data, 11=4DW-header+data. bit.28:24=type: 00000 or 00001 are memory 
	--read requests, 00000 or 00001 are memory write request if type=1x. read request 
	--completion is 01010 and type=10. bit.9:0 is payload size [DW]. 
	--Second Dword: bit.31:16 is requester ID. bit3:0 is first dword byte enable, bit.7:4 is 
	--byte enable for last dword data. intermediate dwords have all bytes enabled.
	--Third DWORD: address, where bit.1:0=00b. 4DW headers are for 64bit. 64bit adressing
	--uses 3rd-dword for addre63:32, 4th dword for addr31:0.
	--
	--The TLP variables in this core: BRAM memory used store TLP, up to 1-2kBytes
	--
	--Read completion is 3DW header and routed by completer-ID and requester-ID, not address.
	--The core has to store the requester ID and feed it back in the completion packet.
	--Completion status: 000=successful, 100=completer_abort, 001=unsupported request. byte
	--count is N.of bytes left. lower_address is the first enabled byte of data returned 
	--with the Completion.
	--
	--  Completion packet header:
	--DW1 >
	--7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
	--r FMT type----- r TC--- reserv- T E att r r lenght-------------
	--  x 0                           D P rib
	--DW2 >
	--7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
	--COMPLETER_ID------------------- statu B byte_count-------------
	--                                      CM
	--DW3 >
	--7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
	--REQUESTER_ID------------------- tag------------ r lower_address


	 --TLP-protocol statemachine:
    process (pciewb_localreset_n, trn_clk, tlp_state, 
				pcie_just_received_a_new_tlp, tlp_datacount,
				bram_rxtlp_readdata,  bram_txtlp_writeaddress, bram_rxtlp_readaddress,
				tlp_state_copy, rxtlp_decodedaddress, 
				rxtlp_header_dw1, rxtlp_header_dw2, rxtlp_header_dw3, rxtlp_header_dw4,
				bit10, rxtlp_firstdw_be, wb_transaction_complete, flag1, rxdw1_23_0, pcie_rxtlp_tag, 
				tlp_payloadsize_dwords, pcie_bar0_wb_data_i_latched, cfg_completer_id,
				rxtlp_requesterid) 
    begin
    if (pciewb_localreset_n='0') then 
		start_read_wb0 <= '0';
		start_write_wb0 <= '0';
		pcie_bar0_wb_data_o_feed	 <= (others => '0');
		pcie_bar0_wb_addr_o_feed <= (others => '0');
		pcie_bar0_wb_sel_o_feed  <= (others => '0');
		pcie_there_is_a_new_tlp_to_transmit  <= '0';
		rxtlp_decodedaddress<= (others => '0');
		tlp_payloadsize_dwords <= (others => '0');
		rxtlp_firstdw_be <= (others => '0');
		rxtlp_lastdw_be <= (others => '0');
		rxtlp_requesterid <= (others => '0');
		tlp_state <= (others => '0');
		tlp_state_copy  <= (others => '0');
		bram_txtlp_we <= "0";
		bram_txtlp_writeaddress    <= (others => '0');
		bram_txtlp_writedata     <= (others => '0');
		bram_rxtlp_readaddress   <= (others => '0');
		rxtlp_header_dw1   <= "01111111000000000000000000000000";
		rxtlp_header_dw2   <= (others => '0');
		rxtlp_header_dw3   <= (others => '0');
		rxtlp_header_dw4   <= (others => '0');
		flag1 <= '0';
		rxdw1_23_0 <= (others => '0'); 
		pcie_rxtlp_tag <= (others => '0');
		rcompl_bytecount_field  <= (others => '0');
		tlpstm_isin_idle <= '1';
    else
      if (trn_clk'event and trn_clk = '1') then
                case ( tlp_state ) is

                --********** IDLE STATE  **********
					 --also re-initialize signals...
                when "00000000" =>   --state 0        
                    if (pcie_just_received_a_new_tlp='1') then
						    tlp_state <= "00000001"; --to tlp decoding state
							 tlpstm_isin_idle <= '0';
						  else
						    tlpstm_isin_idle <= '1';
						  end if;
						  start_write_wb0 <= '0';
						  start_read_wb0 <= '0';
						  tlp_state_copy <= tlp_state;
							bram_txtlp_we <= "0";
							bram_txtlp_writeaddress   <= (others => '0');
							bram_txtlp_writedata     <= (others => '0');
							bram_rxtlp_readaddress    <= (others => '0');
							tlp_datacount <= "00000001";
							rxtlp_header_dw1   <= "01111111000000000000000000000000"; --this is to prevent false decode
							pcie_bar0_wb_data_o_feed	 <= (others => '0');
							pcie_bar0_wb_addr_o_feed <= (others => '0');
							pcie_bar0_wb_sel_o_feed  <= (others => '0');
							rxtlp_header_dw2   <= (others => '0');
							rxtlp_header_dw3   <= (others => '0');
							rxtlp_header_dw4   <= (others => '0');
							rxdw1_23_0 <= (others => '0'); 
							pcie_rxtlp_tag <= (others => '0'); 				
							pcie_there_is_a_new_tlp_to_transmit  <= '0';
							rxtlp_decodedaddress<= (others => '0');
							tlp_payloadsize_dwords <= (others => '0');
							rxtlp_firstdw_be <= (others => '0');
							rxtlp_lastdw_be <= (others => '0');
							rxtlp_requesterid <= (others => '0');
							rcompl_bytecount_field  <= (others => '0');

	
                --********** TLP ARRIVED STATE **********
					 --read TLP out of EP, decode and decide,
					 --latch address/sel/wr_data
					 --All the "IF"-statements use address+1, because the BRAM read side has data available 1clk late!!!
					 --Added an ectra clock delay, based on testing, since the data is one more CLK late.
                when "00000001" =>   --state 1
                    --latch the header:
						  bram_rxtlp_readaddress <= bram_rxtlp_readaddress +1;
						  if (bram_rxtlp_readaddress = "000000010") then
						    rxtlp_header_dw1 <= bram_rxtlp_readdata;
						  elsif (bram_rxtlp_readaddress = "000000011") then
						    rxtlp_header_dw2 <= bram_rxtlp_readdata;
						  elsif (bram_rxtlp_readaddress = "000000100") then
						    rxtlp_header_dw3 <= bram_rxtlp_readdata;
						  elsif (bram_rxtlp_readaddress = "000000101") then
						    rxtlp_header_dw4 <= bram_rxtlp_readdata;
						  end if;
						  --decode some parameters: 
						  tlp_payloadsize_dwords <= rxtlp_header_dw1(7 downto 0);
						  rxtlp_firstdw_be <= rxtlp_header_dw2(3 downto 0);
						  rxtlp_lastdw_be <= rxtlp_header_dw2(7 downto 4);
						  rxtlp_requesterid <= rxtlp_header_dw2(31 downto 16);
						  flag1 <= rxtlp_header_dw1(31);
						  rxdw1_23_0 <= rxtlp_header_dw1(23 downto 0); --various fields pcie_received_tlp (22 downto 0);
						  pcie_rxtlp_tag <= rxtlp_header_dw2(15 downto 8) ; --pcie_received_tlp (47 downto 40);--tag
						  --decide based on header:
						  if (rxtlp_header_dw1(30 downto 24)="0000000") then --32bit read
							 if (bram_rxtlp_readaddress = "000000100") then
								rxtlp_decodedaddress <= bram_rxtlp_readdata;
								bram_txtlp_writeaddress(8 downto 0) <= "000000011"; --point after the 3dw readcompl header
								tlp_state <= "00000011";
							 end if;
						  elsif (rxtlp_header_dw1(30 downto 24)="0100000") then --64bit read
							 if (bram_rxtlp_readaddress = "000000101") then
								rxtlp_decodedaddress <= bram_rxtlp_readdata;
								bram_txtlp_writeaddress(8 downto 0) <= "000000011"; --point after the 3dw readcompl header
								tlp_state <= "00000011";
							 end if;
						  elsif (rxtlp_header_dw1(30 downto 24)="1000000") then --32bit write
							 if (bram_rxtlp_readaddress = "000000100") then
								rxtlp_decodedaddress <= bram_rxtlp_readdata;
								tlp_state <= "00000010";
							 end if;
						  elsif (rxtlp_header_dw1(30 downto 24)="1100000") then --64bit write
							 if (bram_rxtlp_readaddress = "000000101") then
								rxtlp_decodedaddress <= bram_rxtlp_readdata;
								tlp_state <= "00000010";
							 end if;					 
						  elsif (rxtlp_header_dw1(30 downto 24)="1111111") then --just wait until this gets a real value
						    rxtlp_decodedaddress <= bram_rxtlp_readdata;
						  else --unsupported request
						    if (bram_rxtlp_readaddress = "000000100") then
							   tlp_state <= "00000101";
								bram_txtlp_writeaddress <= "111111111";
							 end if;
						  end if;


                --********** WRITE STATE **********
					 --initiate WB write(s) (1...N DWORD accesses)
                when "00000010" =>   --state 2
						pcie_bar0_wb_addr_o_feed(27 downto 2) <= rxtlp_decodedaddress(27 downto 2) + tlp_datacount -1; --256MBytes size is hardcoded here, by cutting 4-MSB off
						pcie_bar0_wb_addr_o_feed(1 downto 0) <= bit10(1 downto 0);
						pcie_bar0_wb_sel_o_feed  <= rxtlp_firstdw_be;
						pcie_bar0_wb_data_o_feed <= bram_rxtlp_readdata;
						tlp_state_copy <= tlp_state;
						if (tlp_state_copy = tlp_state) then 
						  start_write_wb0 <= '0';
						else --generate just one pulse, at the first clk cycle in this state
						  start_write_wb0 <= '1';
						end if;
						if (wb_transaction_complete='1') then --one DW transfer completed
							
							if (tlp_payloadsize_dwords = tlp_datacount) then --all data completed
							  tlp_state <= "00000000"; --to idle
							else
							  tlp_state <= "00010100"; --restart wb transaction with new data
							  bram_rxtlp_readaddress <= bram_rxtlp_readaddress +1;
							  tlp_datacount <= tlp_datacount +1;
							end if;
						end if;
                --* Write restart state *
                when "00010100" =>   --state 20
 						tlp_state <= "00000010";


                --********** READ STATE **********
					 --initiate WB read, then go to completion state
                when "00000011" =>   --state 3
						pcie_bar0_wb_addr_o_feed(27 downto 2) <= rxtlp_decodedaddress(27 downto 2) + tlp_datacount -1;
						pcie_bar0_wb_addr_o_feed(1 downto 0) <= bit10(1 downto 0);
						pcie_bar0_wb_sel_o_feed  <= rxtlp_firstdw_be;
						tlp_state_copy <= tlp_state;
						if (tlp_state_copy = tlp_state) then 
						  start_read_wb0 <= '0';
						else --generate just one pulse
						  start_read_wb0 <= '1';
						end if;
						if (wb_transaction_complete='1') then
							bram_txtlp_writedata <= pcie_bar0_wb_data_i_latched;
							bram_txtlp_we <= "1";
							if (tlp_payloadsize_dwords = tlp_datacount)then 
							  tlp_state <= "01111110"; --read completion
							  --bram_txtlp_writeaddress remains the same to capture data in next clock cycle
							else
							  tlp_state <= "00011110"; --one more wb read
							  bram_txtlp_writeaddress <= bram_txtlp_writeaddress +1;
							  tlp_datacount <= tlp_datacount +1;
							end if;
						else
						  bram_txtlp_we <= "0";
						end if;
                --* read restart STATE  *
                when "00011110" =>   --state 30
						tlp_state <= "00000011";
						bram_txtlp_we <= "0";
                --intermediate state before completion (to ensure data latch at address-4)
					 when "01111110" =>   --state 126
						tlp_state <= "00000100";
						bram_txtlp_writeaddress  <=  (OTHERS => '0');
						--pre-write header-DW1:
						bram_txtlp_writedata (31) <= flag1; --reserved
						bram_txtlp_writedata (30 downto 24) <= "1001010"; --type= rd completion
						bram_txtlp_writedata (23 downto 0) <= rxdw1_23_0; --various fields pcie_received_tlp (23 downto 0);
						--Calculate completion header's "rcompl_bytecount_field" from rxtlp_firstdw_be, rxtlp_lastdw_be, tlp_payloadsize_dwords
						if (rxtlp_lastdw_be="0000") then  --max 1DW
						  if (rxtlp_firstdw_be="1111") then --4bytes
						    rcompl_bytecount_field <= "0000000100";
						  elsif (rxtlp_firstdw_be="0111" or rxtlp_firstdw_be="1110") then
						    rcompl_bytecount_field <= "0000000011";
						  elsif (rxtlp_firstdw_be="0011" or rxtlp_firstdw_be="1100" or rxtlp_firstdw_be="0110") then
						    rcompl_bytecount_field <= "0000000010";
						  else
						    rcompl_bytecount_field <= "0000000001";
						  end if;
						else --more than 1DW: right now we dont support non-aligned multi-Dword accesses
						  rcompl_bytecount_field(9 downto 2) <= tlp_payloadsize_dwords;
						  rcompl_bytecount_field(1 downto 0) <= "00";
						end if;


                --********** READ COMPLETION STATE **********
					 --assemble the tx TLP and initiate the transmit
					 --buffer signals bram_txtlp_we, bram_txtlp_writeaddress, bram_txtlp_writedata
                when "00000100" =>   --state 4
                    tlp_state_copy <= tlp_state;
						  bram_txtlp_writeaddress <= bram_txtlp_writeaddress +1;
						  if (bram_txtlp_writeaddress="000000000") then --if address is 0: launch data for next lock/address(1): header-2.dw
							  bram_txtlp_writedata (31 downto 16) <= cfg_completer_id; --completer ID
							  bram_txtlp_writedata (15 downto 13) <= "000"; --status= succesful***
							  bram_txtlp_writedata (12) <= '0'; --reserved
							  bram_txtlp_writedata (11 downto 10) <= "00";
							  bram_txtlp_writedata (9 downto 0) <= rcompl_bytecount_field; --total bytes returned
							  bram_txtlp_we <= "1";
						  elsif (bram_txtlp_writeaddress="000000001") then --if address is 1: launch data for next lock/address(2): header-3.dw
							  bram_txtlp_writedata (31 downto 16) <= rxtlp_requesterid; --requester ID
							  bram_txtlp_writedata (15 downto 8) <= pcie_rxtlp_tag ; --pcie_received_tlp (47 downto 40);--tag
							  bram_txtlp_writedata (7) <= '0'; --reserved
							  bram_txtlp_writedata (6 downto 2) <= rxtlp_decodedaddress(6 downto 2); --lower address
							  bram_txtlp_writedata (1 downto 0) <= bit10(1 downto 0); 		  --lower address
						  else --data dwords, disable writes from next clock cycle
						    bram_txtlp_we <= "0";
						  end if;
						  --one pulse to start the ep-if statemachine, upon arriving to this state
							if (tlp_state_copy = tlp_state) then 
							  pcie_there_is_a_new_tlp_to_transmit  <= '0';
							else 
							  pcie_there_is_a_new_tlp_to_transmit  <= '1';
							end if;
							--back to idle when the ep-if tx is finished: (wait to avoid overwrite)
							if (pcie_tlp_tx_complete='1') then 
								tlp_state <= "00000000";
							end if;


                --********** UNSUPPORTED REQUEST STATE **********
					 --completion response with status=001
                when "00000101" =>   --state 5
                    tlp_state_copy <= tlp_state;
						  tlp_payloadsize_dwords <= "00000000";
						  bram_txtlp_writeaddress <= bram_txtlp_writeaddress +1;
						  --assembling the TLP packet:           )
						  if (bram_txtlp_writeaddress="111111111") then --header 1.dw
						    bram_txtlp_we <= "1";
							  bram_txtlp_writedata (31) <= flag1; --reserved
							  bram_txtlp_writedata (30 downto 24) <= "1001010"; --type= rd completion
							  bram_txtlp_writedata (23 downto 0) <= rxdw1_23_0; --various fields pcie_received_tlp (23 downto 0);
						  elsif (bram_txtlp_writeaddress="000000000") then --header 2.dw
						    bram_txtlp_we <= "1";
							  bram_txtlp_writedata (31 downto 16) <= cfg_completer_id; --completer ID
							  bram_txtlp_writedata (15 downto 13) <= "000"; --status= UNSUPPORTED REQUEST ***
							  bram_txtlp_writedata (12) <= '0'; --reserved
							  bram_txtlp_writedata (11 downto 0) <= "000000000000"; --remaining byte count
						  elsif (bram_txtlp_writeaddress="000000001") then --header 3.dw
						    bram_txtlp_we <= "1";
							  bram_txtlp_writedata (31 downto 16) <= rxtlp_requesterid; --requester ID
							  bram_txtlp_writedata (15 downto 8) <= pcie_rxtlp_tag ; --pcie_received_tlp (47 downto 40);--tag
							  bram_txtlp_writedata (7) <= '0'; --reserved
							  bram_txtlp_writedata (6 downto 2) <= rxtlp_decodedaddress(6 downto 2); --lower address
							  bram_txtlp_writedata (1 downto 0) <= bit10(1 downto 0); 		  --lower address
						  else --data dwords 
						    bram_txtlp_we <= "0";
						  end if;
							--one pulse to start the ep-if statemachine, upon arriving to this state
							if (tlp_state_copy = tlp_state) then 
							  pcie_there_is_a_new_tlp_to_transmit  <= '0';
							else 
							  pcie_there_is_a_new_tlp_to_transmit  <= '1';
							end if;
							--back to idle when finished:
							if (pcie_tlp_tx_complete='1') then 
								tlp_state <= "00000000";
							end if;
						  
                when others => --error
                      tlp_state <= "00000000"; --go to state 0
                end case;     
					 
       end if;        
    end if;
    end process; --end tlp statemachine




	--byte enable encoding to wb_address bit1:0
	--this does not swap the endian, since only the data is swapped in the pcie packets.
	 process ( pciewb_localreset_n, rxtlp_firstdw_be )
    begin
       if (pciewb_localreset_n = '0') then
           bit10(1 downto 0) <="00";
       else
         if (rxtlp_firstdw_be ="0001") then
			  bit10(1 downto 0) <= "00";
         elsif (rxtlp_firstdw_be ="0010") then
			  bit10(1 downto 0) <= "01";
         elsif (rxtlp_firstdw_be ="0100") then
			  bit10(1 downto 0) <= "10";
         elsif (rxtlp_firstdw_be ="1000") then
			  bit10(1 downto 0) <= "11";
         elsif (rxtlp_firstdw_be ="0011") then
			  bit10(1 downto 0) <= "00";
         elsif (rxtlp_firstdw_be ="1100") then
			  bit10(1 downto 0) <= "10";
         elsif (rxtlp_firstdw_be ="1111") then 
			  bit10(1 downto 0) <= "00";
			else --this should never happen
			  bit10(1 downto 0) <= "00";
			end if;
       end if;
    end process;
	 
	 
	 
	 

	-- INTERRUPTS: -------------------------------------------------------------------------
	--to assert an interrupt, use the cfg_interrupt_assert_n pin.
	--datasheet text:
	--As shown in Figure 6-30, the user application first asserts cfg_interrupt_n and
	--cfg_interrupt_assert_n to assert the interrupt. The user application should select a
	--specific interrupt (INTA, INTB, INTC, or INTD) using cfg_interrupt_di[7:0] as shown
	--in Table 6-19.
	-- The core then asserts cfg_interrupt_rdy_n to indicate the interrupt has been accepted.
	--On the following clock cycle, the user application deasserts cfg_interrupt_n and, if the
	--Interrupt Disable bit in the PCI Command register is set to 0, the core sends an assert
	--interrupt message (Assert_INTA, Assert_INTB, and so forth).
	-- After the user application has determined that the interrupt has been serviced, it
	--asserts cfg_interrupt_n while deasserting cfg_interrupt_assert_n to deassert the
	--interrupt. The appropriate interrupt must be indicated via cfg_interrupt_di[7:0].
	-- The core then asserts cfg_interrupt_rdy_n to indicate the interrupt deassertion has
	--been accepted. On the following clock cycle, the user application deasserts
	--cfg_interrupt_n and the core sends a deassert interrupt message (Deassert_INTA,
	--Deassert_INTB, and so forth).
	--cfg_interrupt_di[7:0] value Legacy Interrupt
	--00h INTA
	--01h INTB
	--02h INTC
	--03h INTD 

	cfg_interrupt_di    <= "00000000"; --intA used
	
	--prohibit IRQ assert when TLP state machine not idle.
	-- if an IRQ is asserted between a read request and completion, it causes an error in the endpoint block.
	-- added by StBa, AAC Microtec, 2012
	irq_prohibit <= not tlpstm_isin_idle; 
	
    process (pciewb_localreset_n, trn_clk, pcie_irq, pcieirq_state, 
				cfg_interrupt_rdy_n) 
    begin
    if (pciewb_localreset_n='0') then 
       pcieirq_state <= "00000000";	 
       cfg_interrupt_n <= '1';	
		 cfg_interrupt_assert_n_1 <= '1';	
    else
      if (trn_clk'event and trn_clk = '1') then
                case ( pcieirq_state ) is

                --********** idle STATE  **********
                when "00000000" =>   --state 0        
                    if (pcie_irq = '1' and irq_prohibit = '0') then
						    pcieirq_state <= "00000001";
							 cfg_interrupt_n <= '0'; --active
						  else
						    cfg_interrupt_n <= '1'; --inactive
						  end if;
						  cfg_interrupt_assert_n_1 <= '0'; --0=assert, 1=deassert

                --********** assert STATE ********** 
                when "00000001" =>   --state 1
						 if (cfg_interrupt_rdy_n ='0') then --ep accepted it
							 cfg_interrupt_n <= '1'; --deassert the request	
							 pcieirq_state <= "00000010";
						 else
							 cfg_interrupt_n <= '0';	--request INTA assertion
						 end if;

                --********** pcie_irq kept asserted STATE **********     				 
                when "00000010" =>   --state 2
                    if (pcie_irq = '0' and irq_prohibit='0') then --pcie_irq gets deasserted
						    pcieirq_state <= "00000011";
						  end if;
						 cfg_interrupt_n <= '1'; --inactive	
						 cfg_interrupt_assert_n_1 <= '1'; --0=assert, 1=deassert

                --********** DEassert STATE ********** 
                when "00000011" =>   --state 3
						 if (cfg_interrupt_rdy_n ='0') then --ep accepted it
							 cfg_interrupt_n <= '1'; --deassert the request	
							 pcieirq_state <= "00000000";
						 else
							 cfg_interrupt_n <= '0';	--request INTA DEassertion
						 end if;

						 when others => --error
                      pcieirq_state <= "00000000"; --go to state 0
                end case;     
       end if;        
    end if;
    end process;
	
	--this (little delay) is to fix a hold time violation created inside the pcie-ep ip:
	cfg_interrupt_assert_n <= cfg_interrupt_assert_n_1 or (not pciewb_localreset_n);






-- -------- END OF FILE -------------------------------------------------------------------------------------
end Behavioral;


