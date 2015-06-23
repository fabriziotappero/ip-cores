-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: testbench_gen_host_32.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/MAC/vhdl/testbench_gen_host_32.vhd,v $
--
-- $Revision: #2 $
-- $Date: 2008/09/29 $
-- Check in by : $Author: sc-build $
-- Author      : SKNg/TTChong
--
-- Project     : Triple Speed Ethernet - 10/100/1000 MAC
--
-- Description : 
--
-- Testbench for 32-Bit Core
--
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2007 (c) Altera Corporation
-- All rights reserved
--
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;
use     std.textio.all;


use     work.altera_ethmodels_pack.all;

entity tb is

generic(
    -- Simulation Settings (Testbench)
    -- -------------------------------
        LOG_FILE                    : string(1 to 7) := "sim.log";


        ETH_MODE                    : integer := 1000 ; -- Ethernet Operation Mode
        HD_ENA                      : boolean := FALSE ; -- Enable Half Duplex Operation
        TB_RXFRAMES                 : integer := 0 ; -- number of frames to send in RX path - If set to 0, generator is diabled and loopbackmode is active
        TB_RXIPG                    : integer := 12 ; -- Inter Packet Gap used by RX generator
        TB_TXFRAMES                 : integer := 5 ; -- number of frames to send in TX path (set to 0 to disable)
        TB_PAUSECONTROL             : boolean := TRUE ; -- react on PAUSE Frames coming from MAC
        TB_LENSTART                 : integer := 100 ; -- length to start (incremented each new frame by TB_LENSTEP)
        TB_LENSTEP                  : integer := 1 ; -- steps the length should increase with each frame
        TB_LENMAX                   : integer := 1500 ; -- max. payload length for generation
        TB_ENA_PADDING              : boolean := TRUE ; -- enable padding of frames coming from RX PHY generator
        TB_ENA_VLAN                 : integer := 0 ; -- enable generation of a VLAN frame every x frames
        TB_STOPREAD                 : integer := 0 ; -- stop reading the RX fifo after x frames
        TB_HOLDREAD                 : integer := 1000 ; -- clock cycles to wait after stopread before continuing to read
        TB_TRIGGERXOFF              : integer := 0 ; -- when to trigger a pause frame using the xoff_gen command
        TB_TRIGGERXON               : integer := 0 ; -- when to trigger a pause frame using the xon_gen command
        TB_MACLENMAX                : integer := 1518 ; -- max. frame length configuration of MAC
        TB_MACPAUSEQ                : integer := 15 ; -- pause quanta configuration of MAC
        TB_MACIGNORE_PAUSE          : boolean := FALSE ; -- Ignore Pause Frames
        TB_MACFWD_PAUSE             : boolean := FALSE ; -- Forward Pause Frames
        TB_MACFWDCRC                : boolean := FALSE ; -- Forward CRC
        TB_MACINSERT_ADDR           : boolean := FALSE ; -- Insert MAC source address
        TB_MACRX_ERR_DISC           : integer := 1 ;  --MAC function discards erroneous frames received, only when rx_section_full register = 0
        TB_ADDR_SEL                 : integer := 0 ; -- Select MAC source address
        TB_MACPADEN                 : boolean := TRUE ; -- Enable Padding
        TB_MODPAUSEQ                : integer := 16 ; -- Pause Quanta
        TB_ENA_VAR_IPG              : boolean := FALSE ; -- Enable Variable IPG  
        RX_FIFO_SECTION_EMPTY       : integer := 0 ; -- Section Empty Threshold
        RX_FIFO_SECTION_FULL        : integer := 16 ; -- Section Full Threshold
        TX_FIFO_SECTION_EMPTY       : integer := 16 ; -- Section Empty Threshold
        TX_FIFO_SECTION_FULL        : integer := 16 ; -- Section Full Threshold
        RX_FIFO_AE                  : integer := 8 ; -- Almost Empty Threshold
        RX_FIFO_AF                  : integer := 8 ; -- Almost Full Threshold
        TX_FIFO_AE                  : integer := 8 ; -- Almost Empty Threshold
        TX_FIFO_AF                  : integer := 10 ; -- Almost Full Threshold
        RX_COL_FRM                  : integer := 0 ; -- Colision on Frame Number
        RX_COL_GEN                  : integer := 0 ; -- Colision on Nibble Number
        TX_COL_FRM                  : integer := 0 ; -- Colision on Frame Number
        TX_COL_GEN                  : integer := 0 ; -- Colision on Nibble Number
        TX_COL_NUM                  : integer := 0 ; -- Number of Concecutive Collisions
        TX_COL_DELAY                : integer := 0 ; -- Delay Between Concecutive Collisions
        TB_MDIO_ADDR0               : integer := 0 ; -- MDIO PHY 0 Address
        TB_MDIO_ADDR1               : integer := 1 ; -- MDIO PHY 1 Address
        TB_PROMIS_ENA               : boolean := true ; -- Enable Promiscuous Mode
        PERIOD_HASHCLK              : time := 15 ns;  -- 66MHz hash table programming
        TB_MDIO_SIMULATION          : boolean := FALSE ; -- Enable MDIO Simulation
        TB_ENA_AUTONEG              : boolean := FALSE ; -- Enable Autonegotiation
        TB_PCS_BYPASS               : boolean := FALSE ; -- Bypass PCS
        TB_IPG_LENGTH               : integer := 12 ; -- Enable Inverted Loopback
        LOC_HIGH                    : time := 4.0 ns ;
        LOC_LOW                     : time := 4.0 ns ; 
        TB_TX_FF_ERR                : boolean := FALSE ; -- Generate Frame with Errors on Tx FIFO
        ENA_MAGIC                   : boolean := FALSE ; -- Enable Sleep . Wake Up Simulation
        ENA_SLEEP_PIN               : boolean := FALSE ; -- Sleep Activated with magic_sleep_n Pin
        ENA_INVERT_LB               : boolean := FALSE  -- Enable Inverted Loopback

); -- end generic



type TARGET_TYPE is (GEN) ;

-- Simulation Configuration
-- ------------------------
   -- Multicast addresses 

constant MCAST_TABLEN : integer := 9;    -- number of MAC addresses in the table
type mctable is array(0 to MCAST_TABLEN-1) of std_logic_vector(47 downto 0); -- rx_err/rx_en/rx_d(7:0)
constant MCAST_ADDRESSLIST : mctable := (
  X"887654332211",      -- LSB=1 is Multicast address!
  X"886644352611",      -- LSB=1 is Multicast address!
  X"ABCDEF012313",   
  X"92456545ab15",   
  X"432680010217",   
  X"adb589215439",   
  X"ffeacfe3434B",   
  X"ffccddaa3123",   
  X"adb358415439");


-- Core Settings
-- WARNING: DO NOT MODIFY THESE PARAMETERS
-- ------------------
	constant ENABLE_MAGIC_DETECT	: INTEGER	:= 1;
	constant ENABLE_MDIO	: INTEGER	:= 1;
	constant ENABLE_SHIFT16	: INTEGER	:= 0;
	constant ENABLE_SUP_ADDR	: INTEGER	:= 0;
	constant CORE_VERSION	: STD_LOGIC_VECTOR	:= X"0800";
	constant CRC32GENDELAY	: INTEGER	:= 6;
	constant MDIO_CLK_DIV	: INTEGER	:= 40;
	constant ENA_HASH	: INTEGER	:= 0;
	constant USE_SYNC_RESET	: INTEGER	:= 0;
	constant STAT_CNT_ENA	: INTEGER	:= 1;
	constant ENABLE_HD_LOGIC	: INTEGER	:= 1;
	constant REDUCED_INTERFACE_ENA	: INTEGER	:= 1;
	constant CRC32S1L2_EXTERN	: INTEGER	:= 0;
	constant ENABLE_GMII_LOOPBACK	: INTEGER	:= 1;
	constant CRC32DWIDTH	: INTEGER	:= 8;
	constant CUST_VERSION	: INTEGER	:= 0;
	constant RESET_LEVEL	: INTEGER	:= 1;
	constant CRC32CHECK16BIT	: INTEGER	:= 0;
	constant ENABLE_MAC_FLOW_CTRL	: INTEGER	:= 1;
	constant ENABLE_MAC_TXADDR_SET	: INTEGER	:= 1;
	constant ENABLE_MAC_RX_VLAN	: INTEGER	:= 0;
	constant ENABLE_MAC_TX_VLAN	: INTEGER	:= 0;
	constant EG_FIFO	: INTEGER	:= 2048;
	constant EG_ADDR	: INTEGER	:= 11;
	constant ING_FIFO	: INTEGER	:= 2048;
	constant ENABLE_ENA	: INTEGER	:= 32;
	constant ING_ADDR	: INTEGER	:= 11;
	constant RAM_TYPE	: STRING	:= "AUTO";
	constant INSERT_TA	: INTEGER	:= 0;
	constant ENABLE_MACLITE	: INTEGER	:= 0;
	constant MACLITE_GIGE	: INTEGER	:= 0;

	constant MAX_CHANNELS	: INTEGER	:= 0;



end tb ;



architecture a of tb is


-- ------------------
-- ------------------
-- COMPONENTS
-- ------------------
-- ------------------

	 component esoc_port_mac
	port (
	  ff_tx_crc_fwd : in STD_LOGIC;
	  ff_tx_data : in STD_LOGIC_VECTOR(31 downto 0);
	  ff_tx_eop : in STD_LOGIC;
	  ff_tx_err : in STD_LOGIC;
	  ff_tx_mod : in STD_LOGIC_VECTOR(1 downto 0);
	  ff_tx_rdy : out STD_LOGIC;
	  ff_tx_sop : in STD_LOGIC;
	  ff_tx_wren : in STD_LOGIC;
	  ff_tx_clk : in STD_LOGIC;
	  ff_rx_data : out STD_LOGIC_VECTOR(31 downto 0);
	  ff_rx_dval : out STD_LOGIC;
	  ff_rx_eop : out STD_LOGIC;
	  ff_rx_mod : out STD_LOGIC_VECTOR(1 downto 0);
	  ff_rx_rdy : in STD_LOGIC;
	  ff_rx_sop : out STD_LOGIC;
	  rx_err : out STD_LOGIC_VECTOR(5 downto 0);
	  rx_err_stat : out STD_LOGIC_VECTOR(17 downto 0);
	  rx_frm_type : out STD_LOGIC_VECTOR(3 downto 0);
	  ff_rx_dsav : out STD_LOGIC;
	  ff_rx_clk : in STD_LOGIC;
	  address : in STD_LOGIC_VECTOR(7 downto 0);
	  readdata : out STD_LOGIC_VECTOR(31 downto 0);
	  read : in STD_LOGIC;
	  writedata : in STD_LOGIC_VECTOR(31 downto 0);
	  write : in STD_LOGIC;
	  waitrequest : out STD_LOGIC;
	  clk : in STD_LOGIC;
	  reset : in STD_LOGIC;
	  rgmii_in : in STD_LOGIC_VECTOR(3 downto 0);
	  rgmii_out : out STD_LOGIC_VECTOR(3 downto 0);
	  rx_control : in STD_LOGIC;
	  tx_control : out STD_LOGIC;
	  tx_clk : in STD_LOGIC;
	  rx_clk : in STD_LOGIC;
	  set_10 : in STD_LOGIC;
	  set_1000 : in STD_LOGIC;
	  ena_10 : out STD_LOGIC;
	  eth_mode : out STD_LOGIC;
	  ff_tx_septy : out STD_LOGIC;
	  tx_ff_uflow : out STD_LOGIC;
	  ff_rx_a_full : out STD_LOGIC;
	  ff_rx_a_empty : out STD_LOGIC;
	  ff_tx_a_full : out STD_LOGIC;
	  ff_tx_a_empty : out STD_LOGIC;
	  xon_gen : in STD_LOGIC;
	  xoff_gen : in STD_LOGIC;
	  magic_wakeup : out STD_LOGIC;
	  magic_sleep_n : in STD_LOGIC;
	  mdio_out : out STD_LOGIC;
	  mdio_oen : out STD_LOGIC;
	  mdio_in : in STD_LOGIC;
	  mdc : out STD_LOGIC
	);
	 end component ;


  
        component ethgenerator2
            generic (  
                    THOLD  : time := 1 ns);
            port (

                    reset           : in std_logic ;                        -- active high
                    rx_clk          : in std_logic ;
                    rxd             : out std_logic_vector(7 downto 0);
                    rx_dv           : out std_logic;
                    rx_er           : out std_logic;
                    sop             : out std_logic;                        -- pulse with first character
                    eop             : out std_logic;                        -- pulse with last  character
                    ethernet_speed  : in std_logic;
                    mii_mode        : in std_logic;                         -- 4-bit Nibbles (Fast Ethernet)
                    rgmii_mode      : in std_logic;                         -- 4-bit DDR (Reduced Gigabit)     
                    mac_reverse     : in std_logic;                         -- 1: dst/src are sent MSB first
                    dst             : in std_logic_vector(47 downto 0);     -- destination address
                    src             : in std_logic_vector(47 downto 0);     -- source address
                    prmble_len      : in integer range 0 to 15;             -- length of preamble
                    pquant          : in std_logic_vector(15 downto 0);     -- Pause Quanta value
                    vlan_ctl        : in std_logic_vector(15 downto 0);     -- VLAN control info
                    len             : in std_logic_vector(15 downto 0);     -- Length of payload
                    frmtype         : in std_logic_vector(15 downto 0);     -- if non-null: type field instead length
                    cntstart        : in integer range 0 to 255;            -- payload data counter start (first byte of payload)
                    cntstep         : in integer range 0 to 255;            -- payload counter step (2nd byte in paylaod)
                    ipg_len         : in integer range 0 to 32768;          -- inter packet gap (delay after CRC)         
                    payload_err     : in std_logic;                         -- generate payload pattern error (last payload byte is wrong)
                    prmbl_err       : in std_logic;
                    crc_err         : in std_logic;
                    vlan_en         : in std_logic;
                    stack_vlan      : in std_logic;
                    pause_gen       : in std_logic;
                    wrong_pause_op  : in std_logic ;                        -- Generate Pause Frame with Wrong Opcode       
                    wrong_pause_lgth: in std_logic ;                        -- Generate Pause Frame with Wrong Opcode       
                    pad_en          : in std_logic;
                    phy_err         : in std_logic;
                    end_err         : in std_logic;                         -- keep rx_dv high one cycle after end of frame                
                    magic           : in std_logic;     
                    data_only       : in std_logic;                         -- if set omits preamble, padding, CRC            
                    start           : in  std_logic;
                    done            : out std_logic );
        end component ; 

        
        component ethgenerator 
            generic (  
                    THOLD  : time) ;
            port (

                    reset           : in std_logic ;                        -- active high
                    rx_clk          : in std_logic ;
                    enable          : in std_logic ;
                    rxd             : out std_logic_vector(7 downto 0);
                    rx_dv           : out std_logic;
                    rx_er           : out std_logic;                
                    sop             : out std_logic;                        -- pulse with first character
                    eop             : out std_logic;                        -- pulse with last  character
                    mac_reverse     : in std_logic;                         -- 1: dst/src are sent MSB first
                    dst             : in std_logic_vector(47 downto 0);     -- destination address
                    src             : in std_logic_vector(47 downto 0);     -- source address     
                    prmble_len      : in integer range 0 to 15;             -- length of preamble
                    pquant          : in std_logic_vector(15 downto 0);     -- Pause Quanta value
                    vlan_ctl        : in std_logic_vector(15 downto 0);     -- VLAN control info
                    len             : in std_logic_vector(15 downto 0);     -- Length of payload
                    frmtype         : in std_logic_vector(15 downto 0);     -- if non-null: type field instead length      
                    cntstart        : in integer range 0 to 255;            -- payload data counter start (first byte of payload)
                    cntstep         : in integer range 0 to 255;            -- payload counter step (2nd byte in paylaod)
                    ipg_len         : in integer range 0 to 32768;          -- inter packet gap (delay after CRC)         
                    payload_err     : in std_logic;                         -- generate payload pattern error (last payload byte is wrong)
                    prmbl_err       : in std_logic;
                    crc_err         : in std_logic;
                    vlan_en         : in std_logic;
                    stack_vlan      : in std_logic;
                    pause_gen       : in std_logic;
                    wrong_pause_op  : in std_logic ;                        -- Generate Pause Frame with Wrong Opcode       
                    wrong_pause_lgth: in std_logic ;                        -- Generate Pause Frame with Wrong Opcode       
                    pad_en          : in std_logic;
                    phy_err         : in std_logic;
                    end_err         : in std_logic;                         -- keep rx_dv high one cycle after end of frame
                    magic           : in std_logic;     
                    data_only       : in std_logic;                         -- if set omits preamble, padding, CRC            
                    start           : in  std_logic;
                    done            : out std_logic );
        end component ;

        
        component ethgenerator32 
            generic (  
                    ENABLE_SHIFT16      : INTEGER := 0;
                    THOLD               : time;
                    ZERO_LATENCY        : INTEGER := 0);
            port (

                    reset           : in std_logic ;                        -- active high
                    clk             : in std_logic ;
                    enable          : in std_logic;
                    dout            : out std_logic_vector(31 downto 0);
                    dval            : out std_logic;
                    derror          : out std_logic;
                    sop             : out std_logic;                        -- pulse with first word
                    eop             : out std_logic;                        -- pulse with last word (tmod valid)
                    tmod            : out std_logic_vector(1 downto 0);     -- last word modulo
                    mac_reverse     : in std_logic;                         -- 1: dst/src are sent MSB first (non-standard)
                    dst             : in std_logic_vector(47 downto 0);     -- destination address
                    src             : in std_logic_vector(47 downto 0);     -- source address
                    prmble_len      : in integer range 0 to 15;             -- length of preamble
                    pquant          : in std_logic_vector(15 downto 0);     -- Pause Quanta value
                    vlan_ctl        : in std_logic_vector(15 downto 0);     -- VLAN control info
                    len             : in std_logic_vector(15 downto 0);     -- Length of payload
                    frmtype         : in std_logic_vector(15 downto 0);     -- if non-null: type field instead length      
                    cntstart        : in integer range 0 to 255;            -- payload data counter start (first byte of payload)
                    cntstep         : in integer range 0 to 255;            -- payload counter step (2nd byte in paylaod)
                    ipg_len         : in integer range 0 to 32768;
                    payload_err     : in std_logic;                         -- generate payload pattern error (last payload byte is wrong)
                    prmbl_err       : in std_logic;                         -- Send corrupt SFD in otherwise correct preamble
                    crc_err         : in std_logic;
                    vlan_en         : in std_logic;
                    stack_vlan      : in std_logic;
                    pause_gen       : in std_logic;
                    pad_en          : in std_logic;
                    phy_err         : in std_logic;                         -- Generate the well known ERROR control character
                    end_err         : in std_logic;                         -- Send corrupt TERMINATE character (wrong code)               
                    data_only       : in std_logic;                         -- if set omits preamble, padding, CRC
                    start           : in  std_logic;
                    done            : out std_logic );
        end component ;        


        
        component ethmonitor2 
            port (
                reset           : in std_logic ;
                tx_clk          : in std_logic ;
                txd             : in std_logic_vector(7 downto 0);
                tx_dv           : in std_logic;
                tx_er           : in std_logic;       
                tx_sop          : in std_logic;
                tx_eop          : in std_logic;                
                ethernet_speed  : in std_logic;
                mii_mode        : in std_logic;                         -- 4-bit Nibbles (Fast Ethernet)
                rgmii_mode      : in std_logic;                         -- 4-bit DDR (Reduced Gigabit)
                dst             : out std_logic_vector(47 downto 0);    -- destination address
                src             : out std_logic_vector(47 downto 0);    -- source address
                prmble_len      : out integer range 0 to 10000;         -- length of preamble
                pquant          : out std_logic_vector(15 downto 0);    -- Pause Quanta value
                vlan_ctl        : out std_logic_vector(15 downto 0);    -- VLAN control info
                len             : out std_logic_vector(15 downto 0);    -- Length of payload
                frmtype         : out std_logic_vector(15 downto 0);    -- if non-null: type field instead length
                payload         : out std_logic_vector(7 downto 0);
                payload_vld     : out std_logic;        
                is_vlan         : out std_logic;
                is_stack_vlan   : out std_logic;
                is_pause        : out std_logic;
                crc_err         : out std_logic;
                prmbl_err       : out std_logic;
                len_err         : out std_logic;
                payload_err     : out std_logic;
                frame_err       : out std_logic;
                pause_op_err    : out std_logic;
                pause_dst_err   : out std_logic;
                mac_err         : out std_logic;
                end_err         : out std_logic;
                jumbo_en        : in std_logic;
                data_only       : in std_logic;
                frm_rcvd        : out std_logic );
        end component ; 


        component ethmonitor 
         generic (  ENABLE_SHIFT16 : integer := 0  --0 for false, 1 for true
               );

         port (

                reset         : in std_logic ;     -- active high
                tx_clk        : in std_logic ;
                txd           : in std_logic_vector(7 downto 0);
                tx_dv         : in std_logic;
                tx_er         : in std_logic;
                tx_sop        : in std_logic;
                tx_eop        : in std_logic;                                                                     
                dst           : out std_logic_vector(47 downto 0); -- destination address
                src           : out std_logic_vector(47 downto 0); -- source address
                prmble_len    : out integer range 0 to 10000;         -- length of preamble
                pquant        : out std_logic_vector(15 downto 0); -- Pause Quanta value
                vlan_ctl      : out std_logic_vector(15 downto 0); -- VLAN control info
                len           : out std_logic_vector(15 downto 0); -- Length of payload
                frmtype       : out std_logic_vector(15 downto 0); -- if non-null: type field instead length
                payload       : out std_logic_vector(7 downto 0);
                payload_vld   : out std_logic;
                is_vlan       : out std_logic;
                is_stack_vlan : out std_logic;
                is_pause      : out std_logic;
                crc_err       : out std_logic;
                prmbl_err     : out std_logic;
                len_err       : out std_logic;
                payload_err   : out std_logic;
                frame_err     : out std_logic;
                pause_op_err  : out std_logic;
                pause_dst_err : out std_logic;
                mac_err       : out std_logic;
                end_err       : out std_logic;  -- dv stayed asserted after CRC       
                jumbo_en      : in std_logic;
                data_only     : in std_logic;            
                frm_rcvd      : out std_logic );

        end component ;

        
        component top_ethmonitor32 is 
         generic(
                 ENABLE_SHIFT16     : INTEGER := 0 );
         port (
                reset           : in std_logic ;                        -- active high
                clk             : in std_logic;
                din             : in std_logic_vector(31 downto 0);
                dval            : in std_logic;
                derror          : in std_logic;
                sop             : in std_logic;                         -- pulse with first word
                eop             : in std_logic;                         -- pulse with last word (tmod valid)
                tmod            : in std_logic_vector(1 downto 0);      -- last word modulo
                dst             : out std_logic_vector(47 downto 0);    -- destination address
                src             : out std_logic_vector(47 downto 0);    -- source address     
                prmble_len      : out integer range 0 to 10000;         -- length of preamble
                pquant          : out std_logic_vector(15 downto 0);    -- Pause Quanta value
                vlan_ctl        : out std_logic_vector(15 downto 0);    -- VLAN control info
                len             : out std_logic_vector(15 downto 0);    -- Length of payload
                frmtype         : out std_logic_vector(15 downto 0);    -- if non-null: type field instead length      
                payload         : out std_logic_vector(7 downto 0);
                payload_vld     : out std_logic;        
                is_vlan         : out std_logic;
                is_stack_vlan   : out std_logic;
                is_pause        : out std_logic;
                crc_err         : out std_logic;
                prmbl_err       : out std_logic;
                len_err         : out std_logic;
                payload_err     : out std_logic;
                frame_err       : out std_logic;
                pause_op_err    : out std_logic;
                pause_dst_err   : out std_logic;
                mac_err         : out std_logic;
                end_err         : out std_logic;       
                jumbo_en        : in std_logic;
                data_only       : in std_logic;
                frm_rcvd        : out std_logic );
        end component ;        
        

        component top_mdio_slave is port (

                reset           : in std_logic ;
                mdc             : in std_logic ;
                mdio            : inout std_logic ;
                dev_addr        : in std_logic_vector(4 downto 0) ;
                conf_done       : out std_logic) ;
        
        end component ;        




-- ------------------
-- ------------------
-- INTERCONNECTS
-- ------------------
-- ------------------

        
   -- Reset Signals
   -- -------------
   
        signal reset                    : std_logic ;


   -- Interface Control
   -- -----------------
   
        signal ether_mod                : std_logic ;                           -- Ethernet Mode
        signal ena_10                   : std_logic ;                           -- Enable 10Mbps Mode
        signal set_1000                 : std_logic ;                           -- Ethernet Mode Set
        signal set_10                   : std_logic ;                           -- Ethernet Mode Set
 
   -- FIFO and Magic Detection Status Signals
   -- ---------------------------------------
   
        signal magic_wakeup             : std_logic ;                           -- magic detection wakeup status
        signal ff_rx_a_full             : std_logic ;                           -- receive fifo almost full
        signal ff_rx_a_empty            : std_logic ;                           -- receive fifo almost empty
        signal ff_tx_a_full             : std_logic ;                           -- transmit fifo almost full
        signal ff_tx_a_empty            : std_logic ;                           -- transmit fifo almost empty


  --  RGMII Interface
  --  --------------
        signal rgmii_in                 : std_logic_vector(3 downto 0);
        signal rgmii_out                : std_logic_vector(3 downto 0);
        signal rx_control               : std_logic;
        signal tx_control               : std_logic;

  --  Atlantic II Interface
  --  --------------
        signal   rx_err                 : std_logic_vector(5 downto 0);
        signal   rx_err_stat            : std_logic_vector(17 downto 0);
        signal   rx_frm_type            : std_logic_vector(3 downto 0);

               
   -- MDIO Interface
   -- --------------
   
        signal mdc                      : std_logic;                            -- 2.5MHz Inteface
        signal mdio_in                  : std_logic;                            -- MDIO Input
        signal mdio_out                 : std_logic;                            -- MDIO Output
        signal mdio_oen                 : std_logic;                            -- MDIO Output Enable
        signal mdio                     : std_logic;                            -- MDIO
        signal phy_addr0                : std_logic_vector(4 downto 0) ;        -- PHY 0 Address
        signal phy_addr1                : std_logic_vector(4 downto 0) ;        -- PHY 1 Address
        signal mdio0_done               : std_logic ;                           -- Slave MDIO 0 Access Done
        signal mdio1_done               : std_logic ;                           -- Slave MDIO 1 Access Done
                
 
   -- Receive RGMII Interface
   -- ----------------------
   
        signal rgmii_rx_data            : std_logic_vector(3 downto 0) ;        -- GMII Receive data        
        signal rgmii_rx_ctnl            : std_logic ;                           -- GMII Receive frame enable
 
   -- Transmit RGMII Interface
   -- -----------------------

        signal rgmii_tx_data            : std_logic_vector(3 downto 0) ;         -- GMII Transmit data        
        signal rgmii_tx_ctnl            : std_logic ;                          -- GMII Transmit frame enable
  
   -- Receive GMII Interface
   -- ----------------------
     
        signal rx_clk                   : std_logic ;                           -- GMII Receive clock    
        signal rx_clk_tb                : std_logic ;   
        signal rx_clk_10                : std_logic ;
        signal rx_clk_100               : std_logic ;
        signal rx_clk_1000              : std_logic ;         
        signal gm_rx_data               : std_logic_vector(7 downto 0) ;        -- GMII Receive data        
        signal gm_rx_en                 : std_logic ;                           -- GMII Receive frame enable
        signal gm_rx_err                : std_logic ;                           -- GMII Receive frame error 
        
   -- Transmit GMII Interface
   -- -----------------------

        signal tx_clk                   : std_logic ;                           -- GMII Transmit clock       
        signal tx_clk_10                : std_logic ;
        signal tx_clk_100               : std_logic ;
        signal tx_clk_1000              : std_logic ;     
        signal ref_clk                  : std_logic;                            -- 125MHz Reference Clock         
        signal ref_clk_10               : std_logic;                            -- 125MHz Reference Clock   
        signal ref_clk_100              : std_logic;                            -- 125MHz Reference Clock 
        signal ref_clk_1000             : std_logic;                            -- 125MHz Reference Clock                     
        signal gm_tx_data               : std_logic_vector(7 downto 0) ;        -- GMII Transmit data        
        signal gm_tx_en                 : std_logic ;                           -- GMII Transmit frame enable
        signal gm_tx_err                : std_logic ;                           -- GMII Transmit frame error
        
   -- Receive MII Interface
   -- ---------------------
   
        signal m_rx_data                : std_logic_vector(3 downto 0) ;        -- MII Receive data        
        signal m_rx_en                  : std_logic ;                           -- MII Receive frame enable
        signal m_rx_err                 : std_logic ;                           -- MII Receive frame error 
        signal m_rx_crs                 : std_logic;                            -- MII Carrier Sense
        signal m_rx_crs_fd              : std_logic;                            -- MII Carrier Sense
        signal m_rx_col                 : std_logic;                            -- MII Collision 
        signal m_rx_col_fd              : std_logic;                            -- MII Collision 
            
   -- Transmit MII Interface
   -- ----------------------

        signal m_tx_data                : std_logic_vector(3 downto 0) ;        -- MII Transmit data        
        signal m_tx_data_tmp            : std_logic_vector(7 downto 0) ;        -- MII Transmit data        
        signal m_tx_en                  : std_logic ;                           -- MII Transmit frame enable
        signal m_tx_err                 : std_logic ;                           -- MII Transmit frame error
        
   -- Receive User Interface
   -- ---------------------     
   
        signal ff_rx_clk                : std_logic ;                           -- Transmit Local Clock
        signal ff_rx_data               : std_logic_vector(31 downto 0) ;       -- Data Out
        signal ff_rx_mod                : std_logic_vector(1 downto 0) ;        -- Data Modulo
        signal ff_rx_sop                : std_logic ;                           -- Start of Packet
        signal ff_rx_eop                : std_logic ;                           -- End of Packet
        signal ff_rx_err                : std_logic ;                           -- Errored Packet Indication (Parity, POS-PHY Errored or Oversized Packet)
        signal ff_rx_err_stat           : std_logic_vector(22 downto 0) ;   -- Errored Packet Status Word
        signal ff_rx_rdy                : std_logic ;                           -- PHY Application Ready
        signal ff_rx_dval               : std_logic ;                           -- Data Valid Strobe
        signal ff_rx_dsav               : std_logic ;                           -- Data Available
        signal ff_rx_ucast              : std_logic;                            -- Unicast Frame Indication
        signal ff_rx_bcast              : std_logic;                            -- Broadcast Frame Indication
        signal ff_rx_mcast              : std_logic;                            -- Multicast Frame Indication
        signal ff_rx_vlan               : std_logic;                            -- VLAN Frame Indication
        signal ff_rx_ucast_reg          : std_logic;                            -- Unicast Frame Indication
        signal ff_rx_bcast_reg          : std_logic;                            -- Broadcast Frame Indication
        signal ff_rx_mcast_reg          : std_logic;                            -- Multicast Frame Indication
        signal ff_rx_vlan_reg           : std_logic;                            -- VLAN Frame Indication
        signal ff_rx_ucast_reg2         : std_logic;                            -- Unicast Frame Indication
        signal ff_rx_bcast_reg2         : std_logic;                            -- Broadcast Frame Indication
        signal ff_rx_mcast_reg2         : std_logic;                            -- Multicast Frame Indication
        signal ff_rx_vlan_reg2          : std_logic;                            -- VLAN Frame Indication
        
   -- Transmit User Interface
   -- -----------------------   

        signal ff_tx_clk                : std_logic ;                           -- Transmit Local Clock 
        signal ff_tx_data               : std_logic_vector(31 downto 0) ;   -- Data Out
        signal ff_tx_mod                : std_logic_vector(1 downto 0) ;    -- Data Modulo
        signal ff_tx_sop                : std_logic ;                           -- Start of Packet
        signal ff_tx_eop                : std_logic ;                           -- End of Packet
        signal ff_tx_err                : std_logic ;                           -- Errored Packet
        signal ff_tx_wren               : std_logic ;                           -- Write Enable
        signal ff_tx_crc_fwd            : std_logic ;                           -- Forward Frame with CRC from Application
        signal ff_tx_rdy                : std_logic ;                           -- FIFO Ready           
        signal ff_tx_septy              : std_logic ;                           -- FIFO section empty
        signal tx_ff_uflow              : std_logic;                            -- TX FIFO underflow occured (Synchronous with tx_clk)        

   -- Multicast Address Resolution Hash Look up Table Interface
   -- ---------------------------------------------------------
   
        signal sim_stop                 : std_logic ;                           -- End of Simulation
    
   -- Ethernet MAC Configuration
   -- --------------------------
        
        signal xoff_gen                 : std_logic;                            -- Xoff Pause frame generate 
        signal xon_gen                  : std_logic;                            -- Xon Pause frame generate         
        signal mac_addr                 : std_logic_vector(47 downto 0);        -- Device Ethernet MAC address
        signal sup_mac_addr_0           : std_logic_vector(47 downto 0);        -- Supplemental Ethernet MAC address
        signal sup_mac_addr_1           : std_logic_vector(47 downto 0);        -- Supplemental Ethernet MAC address
        signal sup_mac_addr_2           : std_logic_vector(47 downto 0);        -- Supplemental Ethernet MAC address
        signal sup_mac_addr_3           : std_logic_vector(47 downto 0);        -- Supplemental Ethernet MAC address
        signal promis_en                : std_logic;                            -- Enable promiscuous mode: accept any frame
        signal frm_length_max           : std_logic_vector(13 downto 0);        -- Maximium Received Frame length          
        signal ethernet_mode            : std_logic;                            -- Ethernet Mode (1 for Gigabit)
                                                                
   -- Event Triggers
   -- --------------
   
        signal pause_rcv                : std_logic;                            -- Pause Frame Receive Indication
        signal frm_rcv                  : std_logic;                            -- Frame Receive Indication
        signal frm_tx                   : std_logic;                            -- Frame Transmit Indication
        signal frm_align_err            : std_logic;                            -- Received Frame Aligment Error Indication
        signal frm_type_err             : std_logic;                            -- Received Frame type Error Indication
        signal frm_length_err           : std_logic;                            -- Received Frame length Error Indication
        signal frm_crc_err              : std_logic;                            -- Received Frame CRC_32 Error Indication
    
   -- Ethernet Generator Config (GMII RX)
   -- -----------------------------------

        signal gm_rxgen_rx_d            : std_logic_vector(7 downto 0);         -- gmii receive data
        signal gm_rxgen_rx_en           : std_logic;                            -- gmii receive frame enable  
        signal gm_rxgen_rx_err          : std_logic;                            -- gmii receive frame error     
        signal m_rxgen_rx_d             : std_logic_vector(7 downto 0);         -- mii receive data
        signal m_rxgen_rx_en            : std_logic;                            -- mii receive frame enable  
        signal m_rxgen_rx_err           : std_logic;                            -- mii receive frame error                     
        signal gm_mac_reverse           : std_logic;                            -- 1: dst/src are sent MSB first
        signal gm_dst                   : std_logic_vector(47 downto 0);        -- destination address
        signal gm_src                   : std_logic_vector(47 downto 0);        -- source address     
        signal gm_prmble_len            : integer range 0 to 15;                -- length of preamble
        signal gm_pquant                : std_logic_vector(15 downto 0);        -- Pause Quanta value
        signal gm_vlan_ctl              : std_logic_vector(15 downto 0);        -- VLAN control info
        signal gm_len                   : std_logic_vector(15 downto 0);        -- Length of payload
        signal gm_frmtype               : std_logic_vector(15 downto 0);        -- if non-null: type field instead length      
        signal gm_cntstart              : integer range 0 to 255;               -- payload data counter start (first byte of payload)
        signal gm_cntstep               : integer range 0 to 255;               -- payload counter step (2nd byte in paylaod)
        signal gm_ipg_cnt               : integer range 0 to 32768;             -- inter-packet gap
        signal gm_payload_err           : std_logic;                            -- generate payload pattern error (last payload byte is wrong)
        signal gm_prmbl_err             : std_logic;
        signal gm_crc_err               : std_logic;
        signal gm_pause_gen             : std_logic;
        signal gm_vlan_en               : std_logic;
        signal gm_stack_vlan_en         : std_logic;
        signal gm_pad_en                : std_logic;
        signal gm_phy_err               : std_logic;
        signal gm_end_err               : std_logic;                            -- keep rx_dv high one cycle after end of frame
        signal gm_magic                 : std_logic;

   -- FIFO Generator Config (user app FIFO TX)
   -- ----------------------------------------
        
        signal ff_mac_reverse           : std_logic;                            -- 1: dst/src are sent MSB first
        signal ff_dst                   : std_logic_vector(47 downto 0);        -- destination address
        signal ff_src                   : std_logic_vector(47 downto 0);        -- source address     
        signal ff_prmble_len            : integer range 0 to 15;                -- length of preamble
        signal ff_pquant                : std_logic_vector(15 downto 0);        -- Pause Quanta value
        signal ff_vlan_ctl              : std_logic_vector(15 downto 0);        -- VLAN control info
        signal ff_len                   : std_logic_vector(15 downto 0);        -- Length of payload
        signal ff_frmtype               : std_logic_vector(15 downto 0);        -- if non-null: type field instead length      
        signal ff_cntstart              : integer range 0 to 255;               -- payload data counter start (first byte of payload)
        signal ff_cntstep               : integer range 0 to 255;               -- payload counter step (2nd byte in paylaod)
        signal ff_ipg_len               : integer range 0 to 32768;             -- inter packet gap (delay after CRC)         
        signal ff_payload_err           : std_logic;                            -- generate payload pattern error (last payload byte is wrong)
        signal ff_prmbl_err             : std_logic;
        signal ff_crc_err               : std_logic;
        signal ff_vlan_en               : std_logic;
        signal ff_stack_vlan_en         : std_logic;
        signal ff_pad_en                : std_logic;
        signal ff_phy_err               : std_logic;
        signal ff_end_err               : std_logic;                            -- keep rx_dv high one cycle after end of frame

   -- Register Interface
   -- ------------------
   
        signal reg_clk                  : std_logic ;                           -- 25MHz Host Interface Clock
        signal reg_rd                   : std_logic ;               -- Register Read Strobe
        signal reg_wr                   : std_logic ;               -- Register Write Strobe
        signal reg_addr                 : std_logic_vector(7 downto 0) ;        -- Register Address
        signal reg_data_in              : std_logic_vector(31 downto 0) ;   -- Write Data for Host Bus
        signal reg_data_out             : std_logic_vector(31 downto 0) ;   -- Read Data to Host Bus
        signal reg_busy                 : std_logic ;                           -- Interface Busy
        signal magic_sleep_n            : std_logic ;                           -- Enable Sleep Mode
        signal reg_wakeup               : std_logic ;                           -- Wake Up Request
    
   -- Ethernet TX Monitor
   -- -------------------

        signal  mgm_dst                 :  std_logic_vector(47 downto 0);       -- destination address
        signal  mgm_src                 :  std_logic_vector(47 downto 0);       -- source address
        signal  mgm_prmble_len          :  integer range 0 to 10000;            -- length of preamble
        signal  mgm_pquant              :  std_logic_vector(15 downto 0);       -- Pause Quanta value
        signal  mgm_vlan_ctl            :  std_logic_vector(15 downto 0);       -- VLAN control info
        signal  mgm_len                 :  std_logic_vector(15 downto 0);       -- Length of payload
        signal  mgm_frmtype             :  std_logic_vector(15 downto 0);       -- if non-null: type field instead length
        signal  mgm_payload             :  std_logic_vector(7 downto 0); 
        signal  mgm_payload_vld         :  std_logic;
        signal  mgm_is_vlan             :  std_logic;
        signal  mgm_is_stack_vlan       :  std_logic;
        signal  mgm_is_pause            :  std_logic;
        signal  mgm_crc_err             :  std_logic;
        signal  mgm_prmbl_err           :  std_logic;
        signal  mgm_pad_err             :  std_logic;
        signal  mgm_len_err             :  std_logic;
        signal  mgm_payload_err         :  std_logic;
        signal  mgm_frame_err           :  std_logic;
        signal  mgm_pause_op_err        :  std_logic;
        signal  mgm_pause_dst_err       :  std_logic;
        signal  mgm_mac_err             :  std_logic;
        signal  mgm_end_err             :  std_logic;
        signal  mgm_frm_rcvd            :  std_logic; 

   -- GMII Modintor
   -- -------------
           
        signal  gm_mgm_dst              :  std_logic_vector(47 downto 0);       -- destination address
        signal  gm_mgm_src              :  std_logic_vector(47 downto 0);       -- source address
        signal  gm_mgm_prmble_len       :  integer range 0 to 10000;            -- length of preamble
        signal  gm_mgm_pquant           :  std_logic_vector(15 downto 0);       -- Pause Quanta value
        signal  gm_mgm_vlan_ctl         :  std_logic_vector(15 downto 0);       -- VLAN control info
        signal  gm_mgm_len              :  std_logic_vector(15 downto 0);       -- Length of payload
        signal  gm_mgm_frmtype          :  std_logic_vector(15 downto 0);       -- if non-null: type field instead length
        signal  gm_mgm_payload          :  std_logic_vector(7 downto 0); 
        signal  gm_mgm_payload_vld      :  std_logic;
        signal  gm_mgm_is_vlan          :  std_logic;
        signal  gm_mgm_is_stack_vlan    :  std_logic;
        signal  gm_mgm_is_pause         :  std_logic;
        signal  gm_mgm_crc_err          :  std_logic;
        signal  gm_mgm_prmbl_err        :  std_logic;
        signal  gm_mgm_pad_err          :  std_logic;
        signal  gm_mgm_len_err          :  std_logic;
        signal  gm_mgm_payload_err      :  std_logic;
        signal  gm_mgm_frame_err        :  std_logic;
        signal  gm_mgm_pause_op_err     :  std_logic;
        signal  gm_mgm_pause_dst_err    :  std_logic;
        signal  gm_mgm_mac_err          :  std_logic;
        signal  gm_mgm_end_err          :  std_logic;
        signal  gm_mgm_frm_rcvd         :  std_logic;                           -- if '1' all signals/indicators are valid        

   -- MII Monitor
   -- -----------
           
        signal  m_mgm_dst               :  std_logic_vector(47 downto 0);       -- destination address
        signal  m_mgm_src               :  std_logic_vector(47 downto 0);       -- source address
        signal  m_mgm_prmble_len        :  integer range 0 to 10000;            -- length of preamble
        signal  m_mgm_pquant            :  std_logic_vector(15 downto 0);       -- Pause Quanta value
        signal  m_mgm_vlan_ctl          :  std_logic_vector(15 downto 0);       -- VLAN control info
        signal  m_mgm_len               :  std_logic_vector(15 downto 0);       -- Length of payload
        signal  m_mgm_frmtype           :  std_logic_vector(15 downto 0);       -- if non-null: type field instead length
        signal  m_mgm_payload           :  std_logic_vector(7 downto 0); 
        signal  m_mgm_payload_vld       :  std_logic;
        signal  m_mgm_is_vlan           :  std_logic;
        signal  m_mgm_is_stack_vlan     :  std_logic;
        signal  m_mgm_is_pause          :  std_logic;
        signal  m_mgm_crc_err           :  std_logic;
        signal  m_mgm_prmbl_err         :  std_logic;
        signal  m_mgm_pad_err           :  std_logic;
        signal  m_mgm_len_err           :  std_logic;
        signal  m_mgm_payload_err       :  std_logic;
        signal  m_mgm_frame_err         :  std_logic;
        signal  m_mgm_pause_op_err      :  std_logic;
        signal  m_mgm_pause_dst_err     :  std_logic;
        signal  m_mgm_mac_err           :  std_logic;
        signal  m_mgm_end_err           :  std_logic;
        signal  m_mgm_frm_rcvd          :  std_logic;                           -- if '1' all signals/indicators are valid         

   -- FIFO Monitor (Checking)
   -- ----------------------

        signal  mff_dst                 :  std_logic_vector(47 downto 0);       -- destination address
        signal  mff_dst_reg             :  std_logic_vector(47 downto 0);       -- destination address
        signal  mff_src                 :  std_logic_vector(47 downto 0);       -- source address
        signal  mff_prmble_len          :  integer range 0 to 10000;            -- length of preamble
        signal  mff_pquant              :  std_logic_vector(15 downto 0);       -- Pause Quanta value
        signal  mff_vlan_ctl            :  std_logic_vector(15 downto 0);       -- VLAN control info
        signal  mff_len                 :  std_logic_vector(15 downto 0);       -- Length of payload
        signal  mff_frmtype             :  std_logic_vector(15 downto 0);       -- if non-null: type field instead length
        signal  mff_payload             :  std_logic_vector(7 downto 0); 
        signal  mff_payload_vld         :  std_logic;
        signal  mff_is_vlan             :  std_logic;
        signal  mff_is_stack_vlan       :  std_logic;
        signal  mff_is_pause            :  std_logic;
        signal  mff_is_pause_reg        :  std_logic;
        signal  mff_crc_err             :  std_logic;
        signal  mff_prmbl_err           :  std_logic;
        signal  mff_pad_err             :  std_logic;
        signal  mff_len_err             :  std_logic;
        signal  mff_payload_err         :  std_logic;
        signal  mff_frame_err           :  std_logic;
        signal  mff_pause_op_err        :  std_logic;
        signal  mff_pause_dst_err       :  std_logic;
        signal  mff_mac_err             :  std_logic;
        signal  mff_end_err             :  std_logic;
        signal  mff_end_err_reg         :  std_logic;
        signal  mff_frm_rcvd            :  std_logic;                           -- if '1' all signals/indicators are valid
        signal  ff_frmlen               :  integer;                             -- length of frame as it is coming from the FIFO

   -- Simulation Command Signals
   -- --------------------------
   
        signal gm_start_ether_gen       : std_logic ;           -- Enable Frame Generation
        signal m_start_ether_gen        : std_logic ;           -- Enable Frame Generation
        signal gm_ether_gen_done        : std_logic ;           -- Ethernet Generation Completed
        signal gm_gm_ether_gen_done     : std_logic ;           -- Ethernet Generation Completed
        signal m_gm_ether_gen_done      : std_logic ;           -- Ethernet Generation Completed
        signal ff_start_ether_gen       : std_logic ;           -- Enable Frame Generation
        signal ff_ether_gen_done        : std_logic ;           -- Ethernet Generation Completed
        signal jumbo_enable             : std_logic ;           -- depending on TB_MACLENMAX            

    -- Simulation Control
    -- ------------------
    
        signal sim_start                : std_logic;            -- when to start simulation
        signal delay_cnt                : integer := 0;         -- wait before start and after done until stop    
        signal hash_cnt                 : integer;              -- Hash table programming counter 
        signal multicast_cnt            : integer;              -- counter during setting of a multicast address
        signal multicast_wrong          : boolean := false;              -- true if we currently use a multicast address not from the table    
        signal promis_en_dly            : std_logic;
        signal stop_rx_fifo_read        : std_logic;            -- FIFO read should be stopped now
        signal ff_rx_rdy_dly            : std_logic;            -- delayed rx_rdy for message generation
        signal rx_hold_cnt              : integer  ;            -- timer counting cycles during fifo read stop
        signal rx_fifo_cnt              : integer  ;            -- incremented with each frame read from the FIFO
        signal tx_pause_wait            : std_logic;            -- Pause frame received. TX should stop
        signal tx_pause_cnt             : integer  ;            -- timer counting pause delay
        
        signal force_xoff_pause_cnt     : integer  ;            -- when to trigger a Xoff frame generation
        signal force_xon_pause_cnt      : integer  ;            -- when to trigger a Xon frame generation

   -- TX PATH simulation
   -- ------------------
    
        signal txframe_cnt              : integer := 0;         -- number of frames transmitted/generated
        signal txsim_done               : std_logic;            -- 1 when everything has finished
        signal ff_tx_clk_gen_en         : std_logic;            -- clock enable for TX FIFO generator    
        signal ff_tx_wren_gen           : std_logic;            -- write enable FIFO interface

        signal rgm_tx_data              : std_logic_vector(7 downto 0);
        signal rgm_tx_en                : std_logic;
        signal rgm_tx_err               : std_logic;

   -- TX: Verification information
   -- ----------------------------
               
        signal tx_good_sent             : integer;              -- valid frames sent which should be counted as good on receive
        signal tx_good_rcvd             : integer;              -- should be same as good_sent at end of test        
        signal tx_pause_rcvd            : integer;
        signal tx_pause_err_rcvd        : integer;              -- erroneous PAUSE frames
        signal tx_align_err_rcvd        : integer;              -- should NEVER happen
        signal gm_txcnt                 : integer;        
        signal tx_vlan_sent             : integer;
        signal tx_stack_vlan_sent       : integer;
        signal tx_frm_all               : integer;
        signal tx_vlan_rcvd             : integer;              -- received by monitor
        signal tx_stack_vlan_rcvd       : integer;              -- received by monitor
        signal tx_vlan_wrong_type_sent  : integer;    
        signal tx_phy_err_rcvd          : integer;              -- GMII tx error signal detected
        signal tx_crc_err_rcvd          : integer;            
        signal tx_payload_err_sent      : integer;
        signal tx_payload_err_rcvd      : integer;
        
        signal tx_wrong_src_rcvd        : integer;              -- Wrong MAC SOURCE address received by monitor
        
   -- RX PATH simulation
   -- ------------------
        signal rxframe_cnt              : integer := 0;                         -- number of frames transmitted/generated
        signal rxsim_done               : std_logic;                            -- 1 when everything has finished
        signal last_err_stat            : std_logic_vector(3 downto 0);         -- latest FIFO error bits
        signal ff_last_length           : std_logic_vector(15 downto 0);        -- length part of ff_rx_err_stat
        signal gm_sop                   : std_logic;                            -- sop from GMII generator
        signal gm_gm_sop                : std_logic;                            -- sop from GMII generator
        signal m_gm_sop                 : std_logic;                            -- sop from MII generator
        signal gm_sop_dly               : std_logic;                            -- delayed by 1
        signal gm_sop_dly2              : std_logic;                            -- delayed by 1
        signal gm_eop                   : std_logic;                            -- eop from GMII generator
        signal gm_gm_eop                : std_logic;                            -- eop from GMII generator
        signal m_gm_eop                 : std_logic;                            -- eop from MII generator
        signal gm_eop_dly               : std_logic;                            -- dito delayed by 1 clk 
    
   -- RX: Determine when to expect the RX to act 
   -- ------------------------------------------
   
        signal expect1                  : std_logic;                            -- set after start of generator
        signal expect2                  : std_logic;                            -- set when we expect something, cleared if done
        
   -- RX: Verification information
   -- ------------------------
        
        signal rx_is_good_frame         : boolean;                              -- true if valid frame (payload error is still a valid frame)
        signal rx_is_good_addr          : boolean;                              -- true if valid mac address is given        
        signal rx_good_sent             : integer := -1;                        -- valid frames sent which should be counted as good on receive
        signal rx_good_rcvd             : integer := -1;                        -- should be same as good_sent at end of test        
        signal rx_pause_sent            : integer := -1;
        signal rx_pause_rcvd            : integer := -1;    
        signal rx_align_err_sent        : integer := -1;
        signal rx_align_err_rcvd        : integer := -1;
        signal rx_crc_err_sent          : integer := -1;
        signal rx_crc_err_rcvd          : integer := -1;        
        signal rx_gmii_err_sent         : integer := -1;
        signal rx_gmii_err_rcvd         : integer := -1;
        signal rx_length_err_rcvd       : integer := -1;
        signal rx_length_mismatch_rcvd  : integer := -1;        
        signal rx_vlan_sent             : integer := -1;
        signal rx_vlan_rcvd             : integer := -1;
        signal rx_stack_vlan_sent       : integer := -1;
        signal rx_stack_vlan_rcvd       : integer := -1;
        signal rx_vlan_wrong_type_sent  : integer := -1;    
        signal rx_discard_sent          : integer := -1;                        -- frame sent that should have been discarded
        signal rx_non_discard_rcvd      : integer := -1;                        -- frames discarded on receive
        signal rx_discard_rcvd          : integer := -1;                        -- frame_cnt - non_discard_rcvd    
        signal rx_wrong_status_sent     : integer := -1;                        -- sent frame that will be pushed into FIFO but with error status
        signal rx_wrong_status_rcvd     : integer := -1;        
        signal rx_payload_err_sent      : integer := -1;
        signal rx_payload_err_rcvd      : integer := -1;
        signal mff_rxcnt                : integer := -1;                
        signal rx_wrong_mac_sent        : integer := -1;
        signal rx_wrong_mac_rcvd        : integer := -1;        
        signal rx_broadcast_sent        : integer := -1;
        signal rx_broadcast_rcvd        : integer := -1;        
        signal rx_multicast_sent_total  : integer := -1;
        signal rx_multicast_sent        : integer := -1;
        signal rx_multicast_rcvd        : integer := -1;
        signal rx_multicast_denied      : integer := -1;
        signal rx_unexpected            : integer := -1;
        signal rx_fifo_overflow_rcvd    : integer := -1;        
        signal rx_col_sent              : integer := -1 ;
        signal tx_col_sent              : integer := -1 ;
        signal tx_pause_sent            : integer := -1;            
        signal rx_col_rcvd              : integer := -1 ;        
        
   -- Control State Machine
   -- ---------------------
   
        type stm_typ is (IDLE, READ_VER, WR_SCRATCH, RD_SCRATCH, WRITE_MDIO0, READ_MDIO0, WRITE_MDIO1, READ_MDIO1, 
                         MAC_CONFIG, WR_MAC1, WR_MAC2, WR_RX_AE, WR_RX_AF, WR_TX_AE, WR_TX_AF, 
                         WR_RX_SE, WR_RX_SF, WR_TX_SE, WR_TX_SF, WR_IPG_LEN,
                         LUT_PROG, LUT_PROG_INC,WR_FRM_LENGTH, WR_PAUSE_QUANTA, WR_MDIO_ADDR0, WR_MDIO_ADDR1,
                         SIM, END_SIM_WAIT, WR_SUP_MAC0_0, WR_SUP_MAC0_1, WR_SUP_MAC1_0, WR_SUP_MAC1_1,
                         WR_SUP_MAC2_0, WR_SUP_MAC2_1, WR_SUP_MAC3_0, WR_SUP_MAC3_1,
                         RD_FRM_TX, RD_FRM_RX, RD_CRC_ERR, RD_ALIGN_ERR, RD_TX_OCTETS, RD_RX_OCTETS, RD_PAUSE_RX, 
                         RD_PAUSE_TX, RX_UNICAST, RX_MLTCAST, RX_BRDCAST,
                         TX_FRM_DISCARD, TX_UNICAST, TX_MLTCAST, TX_BRDCAST, RX_FRM_ERR, TX_FRM_ERR,
                         RX_FRM_DROP, RX_UNDERSZ_FRM, RX_OVERSZ_FRM, RX_64_FRM, RX_65_127_FRM, RX_128_255_FRM,
                         RX_256_511_FRM, RX_512_1023_FRM, RX_1024_1518_FRM, RX_1519_X_FRM, RX_JABBER, RX_FRAGMENT,
                         SW_RESET, RD_SW_RESET, WR_ENA_MAGIC, NODE_SLEEP1, GEN_MAGIC, NODE_SLEEP2, NODE_ON,
                         END_SIM1, END_SIM) ;
        signal state                    : stm_typ ;
        signal nextstate                : stm_typ ;
        signal sim_cnt_end              : integer ;
        signal re_read_ena              : boolean := FALSE ;
        
   -- Hash Table Program Control
   -- --------------------------
   
        signal lut_prog_cnt             : integer range 0 to 64 := 0 ; 
        
   -- Half Duplex Colision Control
   -- ----------------------------
   
        signal rx_nib_cnt               : integer ;                             -- Nibble Counter
        signal tx_nib_cnt               : integer ;                             -- Nibble Counter
        signal tx_col_reg               : std_logic;                            -- Packet Transmitted with Col                
        signal tx_col_reg_fd            : std_logic;                            -- Packet Transmitted with Col                
        signal tx_col_reg_hd            : std_logic;                            -- Packet Transmitted with Col                
              


   -- register write/read test
   -- ----------------------------
        signal readback_scratch         : std_logic_vector(31 downto 0) ;
        signal readback_MDIO0_addr0     : std_logic_vector(15 downto 0) ;
        signal readback_MDIO1_addr0     : std_logic_vector(15 downto 0) ;
        
        signal register_test            : integer;

    -- derived speed
    -- ----------------------------
        signal ETH_SPEED                : integer;


begin

   -- global settings
   -- ---------------
        jumbo_enable    <= '1' when (TB_MACLENMAX >1522) else '0';   -- enable monitors for long frames
        
   -- Reset Control and start simulation
   -- -------------
   
   
    --  Ethernet speed selection & validation
    process (reg_clk)
            variable ln             : line;        
    begin
        
    if (reg_clk='0' and reg_clk'event) then
       if (state=READ_VER and reg_busy='0')then
        if (ENABLE_MACLITE = 0) then
            ETH_SPEED <= ETH_MODE;
            
            writeline(output, ln) ;
            write(ln, string'(" ")) ;
            writeline(output, ln) ;
            write(ln, string'(" - ---------------------------------------------------------------------------------------- -")) ;
            writeline(output, ln) ;
            write(ln, string'(" -- Testbench for 32-Bit Core 10/100/1000 MAC -- ")) ;
            writeline(output, ln) ;
            write(ln, string'(" -- (c) ALTERA CORPORATION 2007 --")) ;
            writeline(output, ln) ;
            write(ln, string'(" - ---------------------------------------------------------------------------------------- -")) ;
            writeline(output, ln) ;
            write(ln, string'(" ")) ;
            writeline(output, ln); 
        
        else
            if (MACLITE_GIGE = 1) then
                ETH_SPEED <= 1000;
                writeline(output, ln) ;
                write(ln, string'(" ")) ;
                writeline(output, ln) ;
                write(ln, string'(" - ---------------------------------------------------------------------------------------- -")) ;
                writeline(output, ln) ;
                write(ln, string'(" -- Testbench for 32-Bit Core 1000 SMALL MAC -- ")) ;
                writeline(output, ln) ;
                write(ln, string'(" -- (c) ALTERA CORPORATION 2007 --")) ;
                writeline(output, ln) ;
                write(ln, string'(" - ---------------------------------------------------------------------------------------- -")) ;
                write(ln, string'(" ")) ;
                writeline(output, ln); 
                
                write(ln, string'("WARNING: 10/100 Operation is not supported. Allowable values for 'ETH_MODE' parameter is '1000' only.  Reseting  to \'1000\'"));
                writeline(output, ln); 
            else
                ETH_SPEED <= 100;
                writeline(output, ln) ;
                write(ln, string'(" ")) ;
                writeline(output, ln) ;
                write(ln, string'(" - ---------------------------------------------------------------------------------------- -")) ;
                writeline(output, ln) ;
                write(ln, string'(" -- Testbench for 32-Bit Core 10/100 SMALL MAC -- ")) ;
                writeline(output, ln) ;
                write(ln, string'(" -- (c) ALTERA CORPORATION 2007 --")) ;
                writeline(output, ln) ;
                write(ln, string'(" - ---------------------------------------------------------------------------------------- -")) ;
                writeline(output, ln) ;
                write(ln, string'(" ")) ;
                writeline(output, ln); 
                
                write(ln, string'("WARNING: 1000 Operation is not supported. Allowable values for 'ETH_MODE' parameter is '100' or '10' only.  Reseting  to '100'"));
                writeline(output, ln); 
            end if  ;
        end if;
        end if;

   end if;
    end process ;     
   
   
        reset       <= '0', '1' after 50 ns, '0' after 2000 ns ;           
        sim_start   <= '0', '1' after 3000 ns;   
   
   -- Clocks
   -- ------
   
        ethernet_mode <= '1' when ETH_SPEED=1000 else '0';
        tx_clk <= tx_clk_10 when ETH_SPEED=10 else tx_clk_100 when ETH_SPEED=100 else tx_clk_1000;
        rx_clk_tb <= rx_clk_10 when ETH_SPEED=10 else rx_clk_100 when ETH_SPEED=100 else rx_clk_1000;        
        rx_clk <= TRANSPORT rx_clk_tb after 2 ns;
        ref_clk <= ref_clk_10 when ETH_SPEED=10 else ref_clk_100 when ETH_SPEED=100 else ref_clk_1000;          
        
           
        --E1000_GEN: if (ETH_SPEED=1000) generate
        --begin
        
                --ethernet_mode <= '1' ;
   
                CLK_NOLOOP: if( TB_RXFRAMES/=0) generate        -- RX extra test, generate own clock
                 
                        process
                        begin
        
                                rx_clk_1000 <= '0' ;
                                wait for 4 ns ;
                                rx_clk_1000 <= '1' ;
                                wait for 4 ns ; 
                
                        end process ;     
        
                end generate;
        
                CLK_LOOPBACK: if( TB_RXFRAMES=0) generate      -- RX Loopback, use TX Clock
            
                        rx_clk_1000 <= tx_clk_1000;
            
                end generate;    
                
                process
                begin
        
                        tx_clk_1000  <= '1' ;
                        ref_clk_1000 <= '1' ;
                        wait for 4 ns ;
                        tx_clk_1000  <= '0' ;
                        ref_clk_1000 <= '0' ;
                        wait for 4 ns ; 
                
                end process ; 
                
        --end generate ;
        
        --E100_GEN: if (ETH_SPEED=100) generate
        --begin
        
                --ethernet_mode <= '0' ;
   
                CLK_NOLOOP_100: if( TB_RXFRAMES/=0) generate        -- RX extra test, generate own clock
                 
                        process
                        begin
        
                                rx_clk_100 <= '0' ;
                                wait for 20 ns ;
                                rx_clk_100 <= '1' ;
                                wait for 20 ns ; 
                
                        end process ;     
        
                end generate;
        
                CLK_LOOPBACK_100: if( TB_RXFRAMES=0) generate      -- RX Loopback, use TX Clock
            
                        rx_clk_100 <= tx_clk_100;
            
                end generate;    
                
                process
                begin
        
                        tx_clk_100 <= '1' ;
                        wait for 20 ns ;
                        tx_clk_100 <= '0' ;
                        wait for 20 ns ; 
                
                end process ; 
                
                process
                begin
        
                        ref_clk_100 <= '1' ;
                        wait for 20 ns ;
                        ref_clk_100 <= '0' ;
                        wait for 20 ns ; 
                
                end process ;
                        
        --end generate ; 
        
        --E10_GEN: if (ETH_SPEED=10) generate
        --begin
        
                --ethernet_mode <= '0' ;
   
                CLK_NOLOOP_10: if( TB_RXFRAMES/=0) generate        -- RX extra test, generate own clock
                 
                        process
                        begin
        
                                rx_clk_10 <= '0' ;
                                wait for 200 ns ;
                                rx_clk_10 <= '1' ;
                                wait for 200 ns ; 
                
                        end process ;     
        
                end generate;
        
                CLK_LOOPBACK_10: if( TB_RXFRAMES=0) generate      -- RX Loopback, use TX Clock
            
                        rx_clk_10 <= tx_clk_10;
            
                end generate;    
                
                process
                begin
        
                        tx_clk_10 <= '1' ;
                        wait for 200 ns ;
                        tx_clk_10 <= '0' ;
                        wait for 200 ns ; 
                
                end process ;
                
                process
                begin
        
                        ref_clk_10 <= '1' ;
                        wait for 200 ns ;
                        ref_clk_10 <= '0' ;
                        wait for 200 ns ; 
                
                end process ; 
                
        --end generate ;  
        
        process
        begin
        
                ff_rx_clk <= '1' ;
                wait for 4 ns;
                ff_rx_clk <= '0' ;
                wait for 4 ns ; 
                
        end process ;                 

        process
        begin
        
                ff_tx_clk <= '1' ;
                wait for 4 ns;
                ff_tx_clk <= '0' ;
                wait for 4 ns; 
                
        end process ;   
        
   -- Collision Control
   -- -----------------
   
        GEN_NHD: if (HD_ENA=FALSE) generate
        begin
        
                m_rx_crs   <= '0' ;
                m_rx_col   <= '0' ;
                tx_col_reg <= '0' ;
               
        end generate ;          

   -- Half Duplex Control
   -- -------------------
   
        GEN_HD: if (HD_ENA=TRUE and ENABLE_HD_LOGIC=1) generate
        begin
        
           -- RX
           -- --
        
                process(reset, rx_clk_tb)
                begin
                
                        if (reset='1') then
                        
                                rx_nib_cnt     <= 0 ;
                                rx_col_sent <= 0 ;
                                
                        elsif (rx_clk_tb='1') and (rx_clk_tb'event) then
                        
                                if (m_rx_en='1') then
                                
                                        rx_nib_cnt <= rx_nib_cnt+1 ;
                                        
                                else
                                
                                        rx_nib_cnt <= 0 ;
                                        
                                end if ;
                                
                                if (m_rx_col='1' and rx_nib_cnt=RX_COL_GEN) then
                                
                                        rx_col_sent <= rx_col_sent+1 ;
                                        
                                end if ;        
                                
                        end if ;
                        
                end process ;
                
           -- Collision Control
           -- -----------------
                
                process(rxframe_cnt, rx_nib_cnt, m_rx_en, tx_frm_all, tx_nib_cnt)
                begin
                
                        if (TB_RXFRAMES>0 and rxframe_cnt=RX_COL_FRM and (rx_nib_cnt>=RX_COL_GEN and rx_nib_cnt<=RX_COL_GEN+4) and m_rx_en='1') then
                                
                                if (RX_COL_FRM>0) then
                                
                                        m_rx_col    <= '1' ;
                                        
                                else
                                
                                        m_rx_col <= '0' ;
                                        
                                end if ;
                                
                        elsif (tx_frm_all=TX_COL_FRM-1 and tx_nib_cnt>=TX_COL_GEN and tx_nib_cnt<=TX_COL_GEN+4) then
                        
                                if (TX_COL_FRM>0) then
                                
                                        m_rx_col    <= '1' ;
                                        
                                else
                                
                                        m_rx_col <= '0' ;
                                        
                                end if ;
                                                              
                        elsif (tx_frm_all>TX_COL_FRM-1 and tx_frm_all<TX_COL_FRM+TX_COL_NUM-1 and 
                               tx_nib_cnt>=TX_COL_GEN+(tx_frm_all-gm_txcnt)*TX_COL_DELAY and tx_nib_cnt<=TX_COL_GEN+(tx_frm_all-gm_txcnt)*TX_COL_DELAY+4) then
                                        
                                if (TX_COL_FRM>0) then
                                
                                        m_rx_col    <= '1' ;
                                        
                                else
                                
                                        m_rx_col <= '0' ;
                                        
                                end if ;
                        
                        else
                                
                                m_rx_col <= '0' ;
                                                                        
                        end if ;
                        
                end process ;
                
           -- TX
           -- --
           
                m_rx_crs <= '1' when (m_rx_en='1' or m_tx_en='1') else '0' ; 
                
                process(reset, tx_clk)
                begin
                
                        if (reset='1') then
                        
                                tx_nib_cnt  <= 0 ;
                                tx_col_sent <= 0 ;
                                tx_col_reg  <= '0' ;
                                
                        elsif (tx_clk='1') and (tx_clk'event) then
                        
                                if (m_tx_en='1') then
                                
                                        tx_nib_cnt <= tx_nib_cnt+1 ;
                                        
                                else
                                
                                        tx_nib_cnt <= 0 ;
                                        
                                end if ;
                                
                                if (m_rx_col='1' and tx_nib_cnt=TX_COL_GEN) then
                                
                                        tx_col_sent <= rx_col_sent+1 ;
                                        
                                end if ;   
                                
                                if (m_rx_col='1' and m_tx_en='1') then
                                
                                        tx_col_reg <= '1' ;
                                        
                                elsif (m_mgm_frm_rcvd='1') then
                                
                                        tx_col_reg <= '0' ;
                                        
                                end if ;    
                                
                        end if ;
                        
                end process ;                    
                
        end generate ; 
        
   -- -------------------------------------------------------------------
   -- Ethernet MAC Core        
   -- -------------------------------------------------------------------
                   
        ff_tx_crc_fwd <= '0' ;
        set_1000      <= '0' ;
        set_10        <= '0' ;
        magic_sleep_n    <= '0' after 300 ns when ((nextstate=NODE_SLEEP1 or nextstate=NODE_SLEEP2 or nextstate=GEN_MAGIC) and ENA_SLEEP_PIN) else '1' ;
  

        ff_rx_err_stat  <=  rx_err_stat(17) &  rx_err(5) & rx_err_stat(15 downto 0) & rx_err_stat(16) & rx_err(4 downto 1); 
        ff_rx_err       <=  rx_err(0);
        ff_rx_vlan      <=  rx_frm_type(3); 
        ff_rx_bcast     <=  rx_frm_type(2);
        ff_rx_mcast     <=  rx_frm_type(1);
        ff_rx_ucast     <=  rx_frm_type(0);

      
	dut: esoc_port_mac
	port map (
	  ff_tx_crc_fwd => ff_tx_crc_fwd,
	  ff_tx_data => ff_tx_data,
	  ff_tx_eop => ff_tx_eop,
	  ff_tx_err => ff_tx_err,
	  ff_tx_mod => ff_tx_mod,
	  ff_tx_rdy => ff_tx_rdy,
	  ff_tx_sop => ff_tx_sop,
	  ff_tx_wren => ff_tx_wren,
	  ff_tx_clk => ff_tx_clk,
	  ff_rx_data => ff_rx_data,
	  ff_rx_dval => ff_rx_dval,
	  ff_rx_eop => ff_rx_eop,
	  ff_rx_mod => ff_rx_mod,
	  ff_rx_rdy => ff_rx_rdy,
	  ff_rx_sop => ff_rx_sop,
	  rx_err => rx_err,
	  rx_err_stat => rx_err_stat,
	  rx_frm_type => rx_frm_type,
	  ff_rx_dsav => ff_rx_dsav,
	  ff_rx_clk => ff_rx_clk,
	  address => reg_addr(7 downto 0),
	  readdata => reg_data_out,
	  read => reg_rd,
	  writedata => reg_data_in,
	  write => reg_wr,
	  waitrequest => reg_busy,
	  clk => reg_clk,
	  reset => reset,
	  rgmii_in => rgmii_in,
	  rgmii_out => rgmii_out,
	  rx_control => rx_control,
	  tx_control => tx_control,
	  tx_clk => tx_clk,
	  rx_clk => rx_clk,
	  set_10 => '0',
	  set_1000 => '0',
	  ena_10 => open,
	  eth_mode => open,
	  ff_tx_septy => ff_tx_septy,
	  tx_ff_uflow => open,
	  ff_rx_a_full => ff_rx_a_full,
	  ff_rx_a_empty => ff_rx_a_empty,
	  ff_tx_a_full => ff_tx_a_full,
	  ff_tx_a_empty => ff_tx_a_empty,
	  xon_gen => xon_gen,
	  xoff_gen => xoff_gen,
	  magic_wakeup => magic_wakeup,
	  magic_sleep_n => magic_sleep_n,
	  mdio_out => mdio_out,
	  mdio_oen => mdio_oen,
	  mdio_in => mdio_in,
	  mdc => mdc
	);


                                     
   -- MAC Configuration
   -- -----------------

        mac_addr        <= X"EE1122334450" ;
        sup_mac_addr_0  <= X"EE2233445560" ;
        sup_mac_addr_1  <= X"EE3344556670" ;
        sup_mac_addr_2  <= X"EE4455667780" ;
        sup_mac_addr_3  <= X"EE5566778890" ;
        frm_length_max  <= conv_std_logic_vector(TB_MACLENMAX, 14) ;
                
   -- MDIO Slave Model
   -- ----------------
   
   MDIO_PORT_MAP_GEN: if (ENABLE_MDIO= 1) generate
        begin

        process
        begin
        
                mdio <= 'H' ;
                wait ;
                
        end process ;
   
        mdio_in <= mdio ;
        mdio    <= 'H' when (mdio_oen='1') else mdio_out ; 
   
        MDIO_0: top_mdio_slave port map (

                reset           => reset, 
                mdc             => mdc ,
                mdio            => mdio ,
                dev_addr        => phy_addr0 ,
                conf_done       => mdio0_done) ;
                
        MDIO_1: top_mdio_slave port map (

                reset           => reset, 
                mdc             => mdc ,
                mdio            => mdio ,
                dev_addr        => phy_addr1 ,
                conf_done       => mdio1_done) ;
                
        phy_addr0 <= conv_std_logic_vector(TB_MDIO_ADDR0, 5) ;
        phy_addr1 <= conv_std_logic_vector(TB_MDIO_ADDR1, 5) ;
        
    end generate;
        
   -- Checking FIFO Signals
   -- ---------------------
   
        process(reset, ff_rx_clk)
        begin
        
                if (reset='1') then
                
                        ff_rx_ucast_reg  <= '0' ;
                        ff_rx_bcast_reg  <= '0' ;
                        ff_rx_mcast_reg  <= '0' ;
                        ff_rx_vlan_reg   <= '0' ;
                        ff_rx_ucast_reg2 <= '0' ;
                        ff_rx_bcast_reg2 <= '0' ;
                        ff_rx_mcast_reg2 <= '0' ;
                        ff_rx_vlan_reg2  <= '0' ;
                        
                elsif (ff_rx_clk='1') and (ff_rx_clk'event) then
                
                        if (ff_rx_sop='1') then
                        
                                ff_rx_ucast_reg <= ff_rx_ucast ;
                                ff_rx_bcast_reg <= ff_rx_bcast ;
                                ff_rx_mcast_reg <= ff_rx_mcast ;
                                ff_rx_vlan_reg  <= ff_rx_vlan ;
                                
                        end if ; 
                        
                        ff_rx_ucast_reg2 <= ff_rx_ucast_reg ;
                        ff_rx_bcast_reg2 <= ff_rx_bcast_reg ;
                        ff_rx_mcast_reg2 <= ff_rx_mcast_reg ;
                        ff_rx_vlan_reg2  <= ff_rx_vlan_reg ;
                        
                end if ;
                
        end process ;
        
        process(ff_rx_clk)
        
                variable ln : line ;
        
        begin
        
                if (ff_rx_clk='1') and (ff_rx_clk'event) then
        
                        if (mff_frm_rcvd='1') then
                
                                if (mff_dst_reg=X"FFFFFFFFFFFF" and ff_rx_bcast_reg2='0') then
                                
                                        write(ln, string'(" ")) ; 
                                        writeline(output, ln) ; 
                                        write(ln, NOW) ;
                                        write(ln, string'(" - Error: FIFO Broadcast Frame Error")) ;
                                        writeline(output, ln) ; 
                                                                        
                                end if ;
                        
                                if (mff_dst_reg/=X"FFFFFFFFFFFF" and mff_dst_reg(0)='1' and ff_rx_mcast_reg2='0' and mff_is_pause='0') then
                                
                                        write(ln, string'(" ")) ; 
                                        writeline(output, ln) ; 
                                        write(ln, NOW) ;
                                        write(ln, string'(" - Error: FIFO Multicast Frame Error")) ;
                                        writeline(output, ln) ; 
                                                                
                                end if ;
                        
                                if (mff_dst_reg(0)='0' and ff_rx_ucast_reg2='0' and mff_is_pause='0') then
                                
                                        write(ln, string'(" ")) ; 
                                        writeline(output, ln) ; 
                                        write(ln, NOW) ;
                                        write(ln, string'(" - Error: FIFO Unicast Frame Error")) ;
                                        writeline(output, ln) ; 
                                                                
                                end if ;
                                
                                if (ff_rx_vlan_reg2='1' and mff_is_vlan='0') then
                                
                                        write(ln, string'(" ")) ; 
                                        writeline(output, ln) ; 
                                        write(ln, NOW) ;
                                        write(ln, string'(" - Error: FIFO VLAN Frame Error")) ;
                                        writeline(output, ln) ; 
                                                                
                                end if ;
                        
                        end if ;
                        
                end if ;
                
        end process ;
                        
   -- Frame generator feeds GMII/RGMII/MII RX (Ethernet PHY) 
   -- ------------------------------------------------
                    
        EXT_LOOPBACK: if( TB_RXFRAMES=0 and ENABLE_GMII_LOOPBACK=0 and REDUCED_INTERFACE_ENA = 0) generate        -- NO RX Test then switch Loopback
        
                gm_rx_data <= gm_tx_data;
                gm_rx_en   <= gm_tx_en;
                gm_rx_err  <= gm_tx_err; 
                
                m_rx_data <= m_tx_data;
                m_rx_en   <= m_tx_en;
                m_rx_err  <= m_tx_err;            
                    
        end generate;
        
        
        EXT_LOOPBACK_RGMII: if( TB_RXFRAMES=0  and REDUCED_INTERFACE_ENA = 1) generate        -- NO RX Test then switch Loopback
          
                rgmii_tx_data <= rgmii_out; 
                rgmii_in <=  rgmii_rx_data; 
                rgmii_tx_ctnl <= tx_control; 
                rx_control <=  rgmii_rx_ctnl; 
  
                rgmii_rx_data <= rgmii_tx_data;
                rgmii_rx_ctnl <= rgmii_tx_ctnl;
                
                m_rx_data <= m_tx_data;
                m_rx_en   <= m_tx_en;
                m_rx_err  <= m_tx_err;            
                    
        end generate;
          
        INT_LOOPBACK: if( TB_RXFRAMES=0 and ENABLE_GMII_LOOPBACK=1 and REDUCED_INTERFACE_ENA = 0) generate        -- NO RX Test then switch Loopback
        
                gm_rx_data <= (others=>'0');
                gm_rx_en   <= '0';
                gm_rx_err  <= '0'; 
                
                m_rx_data <= (others=>'0');
                m_rx_en   <= '0';
                m_rx_err  <= '0';            
                    
        end generate;
        
        
                NOLOOPBCK: if( TB_RXFRAMES>0 and REDUCED_INTERFACE_ENA = 0) generate  -- use RX Frame generator
        
                gm_rx_data <= gm_rxgen_rx_d;
                gm_rx_en   <= gm_rxgen_rx_en;
                gm_rx_err  <= gm_rxgen_rx_err;  
                
                m_rx_data <= m_rxgen_rx_d(3 downto 0);
                m_rx_en   <= m_rxgen_rx_en;
                m_rx_err  <= m_rxgen_rx_err;           
            
        end generate;                   
                                        
        
    NOLOOPBCK_RGMII: if( TB_RXFRAMES>0 and REDUCED_INTERFACE_ENA=1) generate  -- use RX Frame generator
        
        rgmii_tx_data <= rgmii_out; 
        rgmii_in <=  rgmii_rx_data; 
        rgmii_tx_ctnl <= tx_control; 
                rx_control <=  rgmii_rx_ctnl; 
  

                rgmii_rx_data <= gm_rxgen_rx_d(3 downto 0);
                rgmii_rx_ctnl <= gm_rxgen_rx_en;
                
                m_rx_data <= m_rxgen_rx_d(3 downto 0);
                m_rx_en   <= m_rxgen_rx_en;
                m_rx_err  <= m_rxgen_rx_err;           
            
        end generate;    
        
                     
    GMII_GEN_BLOCK: if( REDUCED_INTERFACE_ENA=0) generate  -- use RX Frame generator
                                        
        GMII_GEN: ethgenerator 

                generic map (  
                
                
                        THOLD           => 2 ns)

                port map (

                        reset           => reset ,          
                        rx_clk          => rx_clk_tb ,        -- GMII RX
                        enable          => '1',
                        rxd             => gm_rxgen_rx_d ,                     
                        rx_dv           => gm_rxgen_rx_en ,                    
                        rx_er           => gm_rxgen_rx_err ,                   
                        sop             => gm_gm_sop ,                            
                        eop             => gm_gm_eop ,                            
                        mac_reverse     => gm_mac_reverse ,   -- CONFIGURATION 
                        dst             => gm_dst ,                        
                        src             => gm_src ,                       
                        prmble_len      => gm_prmble_len ,                 
                        pquant          => gm_pquant ,                    
                        vlan_ctl        => gm_vlan_ctl ,                  
                        len             => gm_len ,                       
                        frmtype         => gm_frmtype ,                    
                        cntstart        => gm_cntstart ,                  
                        cntstep         => gm_cntstep ,                   
                        ipg_len         => gm_ipg_cnt ,                   
                        payload_err     => gm_payload_err ,                
                        prmbl_err       => gm_prmbl_err ,                 
                        crc_err         => gm_crc_err ,                   
                        vlan_en         => gm_vlan_en ,
                        stack_vlan      => gm_stack_vlan_en ,                   
                        pause_gen       => gm_pause_gen ,
                        wrong_pause_op  => '0' ,
                        wrong_pause_lgth=> '0' ,                 
                        pad_en          => gm_pad_en ,                    
                        phy_err         => gm_phy_err ,                   
                        end_err         => gm_end_err ,
                        magic           => gm_magic ,                   
                        data_only       => '0' ,                 
                        start           => gm_start_ether_gen ,                
                        done            => gm_gm_ether_gen_done) ;                
                        
        MII_GEN: ethgenerator2

                generic map (  
                
                        THOLD           => 2 ns)

                port map (

                        reset           => reset ,           
                        rx_clk          => rx_clk_tb ,
                        rxd             => m_rxgen_rx_d ,   
                        rx_dv           => m_rxgen_rx_en , 
                        rx_er           => m_rxgen_rx_err ,
                        sop             => m_gm_sop ,         
                        eop             => m_gm_eop ,         
                        ethernet_speed  => ethernet_mode,
                        mii_mode        => '1' ,
                        rgmii_mode      => '0' ,
                        mac_reverse     => gm_mac_reverse ,   -- CONFIGURATION  
                        dst             => gm_dst ,                            
                        src             => gm_src ,                            
                        prmble_len      => gm_prmble_len ,                     
                        pquant          => gm_pquant ,                         
                        vlan_ctl        => gm_vlan_ctl ,                       
                        len             => gm_len ,                            
                        frmtype         => gm_frmtype ,                        
                        cntstart        => gm_cntstart ,                       
                        cntstep         => gm_cntstep ,                        
                        ipg_len         => gm_ipg_cnt ,                        
                        payload_err     => gm_payload_err ,                    
                        prmbl_err       => gm_prmbl_err ,                      
                        crc_err         => gm_crc_err ,                        
                        vlan_en         => gm_vlan_en ,  
                        stack_vlan      => gm_stack_vlan_en ,                      
                        pause_gen       => gm_pause_gen , 
                        wrong_pause_op  => '0' ,  
                        wrong_pause_lgth=> '0' ,                     
                        pad_en          => gm_pad_en ,                         
                        phy_err         => gm_phy_err ,                        
                        end_err         => gm_end_err , 
                        magic           => gm_magic ,                       
                        data_only       => '0' ,                               
                        start           => m_start_ether_gen ,                          
                        done            => m_gm_ether_gen_done) ;
                        
                        
        end generate;
        
       
    RGMII_GEN_BLOCK: if( REDUCED_INTERFACE_ENA=1) generate  -- use RX Frame generator

    gm_rx_data <= X"00";
    gm_rx_en <= '0';
    gm_rx_err <= '0';

        RGMII_GEN: ethgenerator2

                generic map (  
                
                        THOLD           => 0 ns)

                port map (

                        reset           => reset ,           
                        rx_clk          => rx_clk_tb ,
                        rxd             => gm_rxgen_rx_d ,   
                        rx_dv            => gm_rxgen_rx_en , 
                        rx_er           => gm_rxgen_rx_err ,
                        sop             => gm_gm_sop ,         
                        eop             => gm_gm_eop ,         
                        ethernet_speed  => ethernet_mode,
                        mii_mode        => '0' ,
                        rgmii_mode      => '1' ,
                        mac_reverse     => gm_mac_reverse ,   -- CONFIGURATION  
                        dst             => gm_dst ,                            
                        src             => gm_src ,                            
                        prmble_len      => gm_prmble_len ,                     
                        pquant          => gm_pquant ,                         
                        vlan_ctl        => gm_vlan_ctl ,                       
                        len             => gm_len ,                            
                        frmtype         => gm_frmtype ,                        
                        cntstart        => gm_cntstart ,                       
                        cntstep         => gm_cntstep ,                        
                        ipg_len         => gm_ipg_cnt ,                        
                        payload_err     => gm_payload_err ,                    
                        prmbl_err       => gm_prmbl_err ,                      
                        crc_err         => gm_crc_err ,                        
                        vlan_en         => gm_vlan_en ,  
                        stack_vlan      => gm_stack_vlan_en ,                      
                        pause_gen       => gm_pause_gen , 
                        wrong_pause_op  => '0' ,  
                        wrong_pause_lgth=> '0' ,                     
                        pad_en          => gm_pad_en ,                         
                        phy_err         => gm_phy_err ,                        
                        end_err         => gm_end_err , 
                        magic           => gm_magic ,                       
                        data_only       => '0' ,                               
                        start           => gm_start_ether_gen ,                          
                        done            => gm_gm_ether_gen_done) ;
                        
        end generate;
                        
        gm_sop            <= m_gm_sop when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_gm_sop;                 
        gm_eop            <= m_gm_eop when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_gm_eop;                 
        gm_ether_gen_done <= m_gm_ether_gen_done when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_gm_ether_gen_done;

   -- Frame Monitor connected to GMII TX (Ethernet PHY) 
   -- ------------------------------------------------

    GMII_MON_BLOCK: if( REDUCED_INTERFACE_ENA=0) generate  -- use RX Frame generator

    rgm_tx_data <= x"00";
    rgm_tx_en   <= '0';


        GMII_MON: ETHMONITOR port map (

                reset         =>  reset,            
                tx_clk        =>  tx_clk,        -- GMII TX
                txd           =>  gm_tx_data,
                tx_dv         =>  gm_tx_en,
                tx_er         =>  gm_tx_err,
                tx_sop        =>  '0' ,
                tx_eop        =>  '0' ,
                dst           =>  gm_mgm_dst,          -- Analyzed Frame Indicators  
                src           =>  gm_mgm_src,           
                prmble_len    =>  gm_mgm_prmble_len,    
                pquant        =>  gm_mgm_pquant,
                vlan_ctl      =>  gm_mgm_vlan_ctl,
                len           =>  gm_mgm_len,     
                frmtype       =>  gm_mgm_frmtype,
                payload       =>  gm_mgm_payload,      
                payload_vld   =>  gm_mgm_payload_vld,
                is_vlan       =>  gm_mgm_is_vlan,
                is_stack_vlan =>  gm_mgm_is_stack_vlan,  
                is_pause      =>  gm_mgm_is_pause,      
                crc_err       =>  gm_mgm_crc_err,     
                prmbl_err     =>  gm_mgm_prmbl_err,
                len_err       =>  gm_mgm_len_err,      
                payload_err   =>  gm_mgm_payload_err,
                frame_err     =>  gm_mgm_frame_err,  
                pause_op_err  =>  gm_mgm_pause_op_err,
                pause_dst_err =>  gm_mgm_pause_dst_err,
                mac_err       =>  gm_mgm_mac_err, 
                end_err       =>  gm_mgm_end_err, 
                jumbo_en      =>  jumbo_enable,      
                data_only     =>  '0',     
                frm_rcvd      =>  gm_mgm_frm_rcvd );
                        
        m_tx_data_tmp <= "0000"& m_tx_data ;     

        MII_MON: ethmonitor2 port map (

                reset           => reset ,          
                tx_clk          => tx_clk ,
                txd             => m_tx_data_tmp ,
                tx_dv           => m_tx_en ,
                tx_er           => m_tx_err ,
                tx_sop          => '0' ,
                tx_eop          => '0' ,
                ethernet_speed  => ethernet_mode,
                mii_mode        => '1' ,
                rgmii_mode      => '0' ,
                dst             => m_mgm_dst,          
                src             => m_mgm_src,          
                prmble_len      => m_mgm_prmble_len,   
                pquant          => m_mgm_pquant,       
                vlan_ctl        => m_mgm_vlan_ctl,     
                len             => m_mgm_len,          
                frmtype         => m_mgm_frmtype,      
                payload         => m_mgm_payload,      
                payload_vld     => m_mgm_payload_vld,  
                is_vlan         => m_mgm_is_vlan,   
                is_stack_vlan   => m_mgm_is_stack_vlan,
                is_pause        => m_mgm_is_pause,     
                crc_err         => m_mgm_crc_err,      
                prmbl_err       => m_mgm_prmbl_err,    
                len_err         => m_mgm_len_err,      
                payload_err     => m_mgm_payload_err,          
                frame_err       => m_mgm_frame_err,    
                pause_op_err    => m_mgm_pause_op_err, 
                pause_dst_err   => m_mgm_pause_dst_err,
                mac_err         => m_mgm_mac_err,      
                end_err         => m_mgm_end_err,      
                jumbo_en        => jumbo_enable,        
                data_only       => '0',                 
                frm_rcvd        => m_mgm_frm_rcvd );  
                        
        end generate;
        
        
    RGMII_MON_BLOCK: if( REDUCED_INTERFACE_ENA=1) generate  -- use RX Frame generator

    gm_tx_data <= X"00";
    gm_tx_en <= '0';
    gm_tx_err <= '0';

    rgm_tx_data <= "0000"&rgmii_tx_data;
    rgm_tx_en   <= rgmii_tx_ctnl;
        
                
            RGMII_MON: ethmonitor2 port map (

                reset           => reset ,          
                tx_clk          => tx_clk ,
                txd             => rgm_tx_data ,
                tx_dv              => rgm_tx_en ,
                tx_er           => '0' ,
                tx_sop          => '0' ,
                tx_eop          => '0' ,
                ethernet_speed  => ethernet_mode,
                mii_mode        => '0' ,
                rgmii_mode      => '1' ,
                dst             => gm_mgm_dst,          
                src             => gm_mgm_src,          
                prmble_len      => gm_mgm_prmble_len,   
                pquant          => gm_mgm_pquant,       
                vlan_ctl        => gm_mgm_vlan_ctl,     
                len             => gm_mgm_len,          
                frmtype         => gm_mgm_frmtype,      
                payload         => gm_mgm_payload,      
                payload_vld     => gm_mgm_payload_vld,  
                is_vlan         => gm_mgm_is_vlan,   
                is_stack_vlan   => gm_mgm_is_stack_vlan,
                is_pause        => gm_mgm_is_pause,     
                crc_err         => gm_mgm_crc_err,      
                prmbl_err       => gm_mgm_prmbl_err,    
                len_err         => gm_mgm_len_err,      
                payload_err     => gm_mgm_payload_err,          
                frame_err       => gm_mgm_frame_err,    
                pause_op_err    => gm_mgm_pause_op_err, 
                pause_dst_err   => gm_mgm_pause_dst_err,
                mac_err         => gm_mgm_mac_err,      
                end_err         => gm_mgm_end_err,      
                jumbo_en        => jumbo_enable,        
                data_only       => '0',                 
                frm_rcvd        => gm_mgm_frm_rcvd );        
        end generate;            
                
                        
                                
        mgm_dst              <= m_mgm_dst when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_dst ;                                          
        mgm_src              <= m_mgm_src when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_src;         
        mgm_prmble_len       <= m_mgm_prmble_len when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_prmble_len;    
        mgm_pquant           <= m_mgm_pquant when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_pquant;            
        mgm_vlan_ctl         <= m_mgm_vlan_ctl when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_vlan_ctl;         
        mgm_len              <= m_mgm_len when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_len;         
        mgm_frmtype          <= m_mgm_frmtype when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_frmtype;      
        mgm_payload          <= m_mgm_payload when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_payload;     
        mgm_payload_vld      <= m_mgm_payload_vld when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_payload_vld;   
        mgm_is_vlan          <= m_mgm_is_vlan when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_is_vlan;  
        mgm_is_stack_vlan    <= m_mgm_is_stack_vlan when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_is_stack_vlan;  
        mgm_is_pause         <= m_mgm_is_pause when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_is_pause;    
        mgm_crc_err          <= m_mgm_crc_err when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_crc_err;     
        mgm_prmbl_err        <= m_mgm_prmbl_err when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_prmbl_err;   
        mgm_len_err          <= m_mgm_len_err when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_len_err;     
        mgm_payload_err      <= m_mgm_payload_err when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_payload_err;  
        mgm_frame_err        <= m_mgm_frame_err when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_frame_err;   
        mgm_pause_op_err     <= m_mgm_pause_op_err when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_pause_op_err;  
        mgm_pause_dst_err    <= m_mgm_pause_dst_err when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_pause_dst_err;
        mgm_mac_err          <= m_mgm_mac_err when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_mac_err;     
        mgm_end_err          <= m_mgm_end_err when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0') else gm_mgm_end_err;     
        mgm_frm_rcvd         <= m_mgm_frm_rcvd when (REDUCED_INTERFACE_ENA=0 and ethernet_mode = '0' and tx_col_reg='0') else gm_mgm_frm_rcvd;                                                           
                                   
   -- Frame generator feeds TX FIFO (simulate user application) 
   -- ---------------------------------------------------------
     
        FF_GEN_32: ethgenerator32 

                generic map (  
                
                        THOLD           => 2 ns,
                        ENABLE_SHIFT16  => ENABLE_SHIFT16,
                        ZERO_LATENCY    => ENABLE_MACLITE)
    
                port map (

                        reset           => reset ,                     
                        clk             => ff_tx_clk ,
                        enable          => ff_tx_rdy ,
                        dout            => ff_tx_data ,
                        dval            => ff_tx_wren_gen ,
                        derror          => ff_tx_err ,
                        sop             => ff_tx_sop , 
                        eop             => ff_tx_eop ,
                        tmod            => ff_tx_mod ,
                        mac_reverse     => ff_mac_reverse ,
                        dst             => ff_dst ,
                        src             => ff_src ,
                        prmble_len      => ff_prmble_len ,
                        pquant          => ff_pquant ,
                        vlan_ctl        => ff_vlan_ctl ,
                        len             => ff_len ,
                        frmtype         => ff_frmtype ,
                        cntstart        => ff_cntstart ,
                        cntstep         => ff_cntstep ,
                        ipg_len         => ff_ipg_len ,
                        payload_err     => ff_payload_err ,
                        prmbl_err       => ff_prmbl_err ,
                        crc_err         => ff_crc_err ,
                        vlan_en         => ff_vlan_en ,
                        stack_vlan      => ff_stack_vlan_en ,
                        pause_gen       => '0' ,
                        pad_en          => ff_pad_en ,
                        phy_err         => ff_phy_err ,
                        end_err         => ff_end_err ,
                        data_only       => '1' ,
                        start           => ff_start_ether_gen ,
                        done            => ff_ether_gen_done) ;

   -- FIFO Monitor RX (user appl)
   -- ----------------------------
        
        FF_MON_32: top_ethmonitor32

        generic map(
 
                 ENABLE_SHIFT16  => ENABLE_SHIFT16)

        port map (

                reset           => reset ,          
                clk             => ff_rx_clk ,
                din             => ff_rx_data ,
                dval            => ff_rx_dval ,
                derror          => '0' ,
                sop             => ff_rx_sop ,
                eop             => ff_rx_eop ,
                tmod            => ff_rx_mod ,
                dst             => mff_dst ,
                src             => mff_src ,
                prmble_len      => mff_prmble_len ,
                pquant          => mff_pquant ,
                vlan_ctl        => mff_vlan_ctl ,
                len             => mff_len ,
                frmtype         => mff_frmtype ,   
                payload         => mff_payload ,
                payload_vld     => mff_payload_vld ,
                is_vlan         => mff_is_vlan ,
                is_stack_vlan   => mff_is_stack_vlan ,
                is_pause        => mff_is_pause ,
                crc_err         => mff_crc_err ,
                prmbl_err       => mff_prmbl_err ,
                len_err         => mff_len_err ,
                payload_err     => mff_payload_err ,
                frame_err       => mff_frame_err ,
                pause_op_err    => mff_pause_op_err ,
                pause_dst_err   => mff_pause_dst_err ,
                mac_err         => mff_mac_err ,
                end_err         => mff_end_err ,
                jumbo_en        => jumbo_enable ,
                data_only       => '1' ,
                frm_rcvd        => mff_frm_rcvd) ;          
                                         
   -- Ethernet Generator GMII RX model configuration
   -- ------------------------------------------------

        gm_mac_reverse  <= '0' ;   
        gm_src          <= X"0E1122334450" ;       
        gm_prmble_len   <= 8 ;
        gm_pquant       <= conv_std_logic_vector(TB_MODPAUSEQ, 16) ;    
        gm_vlan_ctl     <= X"1234" ; 
        gm_frmtype      <= X"0000" ;    
        gm_cntstart     <= 0 ;  
        gm_cntstep      <= 1 ;   
        gm_payload_err  <= '1' when((rxframe_cnt mod  45) = 7 and gm_dst/=X"FFFFFFFFFFFF" and gm_phy_err='0' and TB_MACFWDCRC=FALSE) else '0' ;
        gm_prmbl_err    <= '0' ; 
        gm_crc_err      <= '0' ;--'1' when((rxframe_cnt mod  15) = 1 and gm_phy_err='0' and gm_pause_gen='0') else '0';
        gm_vlan_en      <= '1' when(TB_ENA_VLAN>0 and (rxframe_cnt mod TB_ENA_VLAN) = TB_ENA_VLAN-1) else '0';   
        gm_stack_vlan_en<= '1' when(TB_ENA_VLAN>0 and (rxframe_cnt mod (2*TB_ENA_VLAN)) = TB_ENA_VLAN-1) else '0';   
        gm_pad_en       <= '1' when TB_ENA_PADDING=true else '0';    
        gm_phy_err      <= '1' when((rxframe_cnt mod  61) = 17 and gm_pause_gen='0' and gm_vlan_en='0') else '0';   
        gm_end_err      <= '0';  
        gm_pause_gen    <= '1' when((rxframe_cnt mod  23) = 13 and HD_ENA=FALSE) else '0'; 
        gm_magic        <= '1' when (rxframe_cnt=TB_RXFRAMES and nextstate=GEN_MAGIC) else '0' ; 
                                       
   -- FIFO Generator model configuration (user application TX)
   -- -----------------------------------------------------
                                       
        ff_mac_reverse          <= '0' ;   
        ff_dst                  <= X"EE1122334450" ;        
        ff_src                  <= X"AA6655443322" ;       
        ff_prmble_len           <= 8 ; 
        ff_pquant               <= conv_std_logic_vector(200, 16) ;    
        ff_vlan_ctl             <= X"1234" ; 
        ff_frmtype              <= X"0000" ;    
        ff_cntstart             <= 0 ;  
        ff_cntstep              <= 1 ;   
        ff_ipg_len              <= 0 ;  
        ff_payload_err          <= '0' ;
        ff_prmbl_err            <= '0' ; 
        ff_crc_err              <= '0' ;  
        ff_vlan_en              <= '1' when( TB_ENA_VLAN>0 and (txframe_cnt mod  TB_ENA_VLAN)     = TB_ENA_VLAN-1) else '0';
        ff_stack_vlan_en        <= '1' when( TB_ENA_VLAN>0 and (txframe_cnt mod  (3*TB_ENA_VLAN)) = TB_ENA_VLAN-1) else '0';
        ff_pad_en               <= '0' ;    
        ff_phy_err              <= '1' when (TB_TX_FF_ERR=TRUE) else '0' ;   
        ff_end_err              <= '0' ;   

   -- --------------------------------------------------------------------------------    
   -- TX PATH Simulation
   -- --------------------------------------------------------------------------------    
    
        ff_tx_wren    <= ff_tx_wren_gen ; --and ff_tx_clk_gen_en;   -- and stop writing during hold
    
        ff_start_ether_gen <= '1' after 1 us when (state=SIM and sim_start='1' and txsim_done='0' and txframe_cnt < TB_TXFRAMES and HD_ENA=FALSE and ENA_INVERT_LB=FALSE) else
                              '1' after 1 us when (state=SIM and sim_start='1' and txsim_done='0' and rxframe_cnt >= TB_RXFRAMES and txframe_cnt < TB_TXFRAMES and HD_ENA=TRUE and ENA_INVERT_LB=FALSE) else '0'; -- START Generator

        process( reset, ff_tx_clk ) 
    
                variable ln: integer;
    
        begin
        
                if( reset='1' ) then
        
                        txframe_cnt             <= 0;
                        tx_vlan_sent            <= 0;
                        tx_stack_vlan_sent      <= 0;
                        tx_payload_err_sent     <= 0;
                        tx_good_sent            <= 0;
                        txsim_done              <= '0';
                        ff_tx_clk_gen_en        <= '1';            
                        ff_len                  <= conv_std_logic_vector(TB_LENSTART, 16);
            
                elsif( ff_tx_clk'event and ff_tx_clk='1' ) then

                   -- FIFO frame generator simulation finished
                   
                        if (ENA_INVERT_LB=TRUE and txframe_cnt >= TB_RXFRAMES) then
                        
                                txsim_done <= '1'; -- STOP after last frame sent        
            
                        elsif( (txframe_cnt >= TB_TXFRAMES and (gm_txcnt-tx_pause_rcvd) >= TB_TXFRAMES) and ff_ether_gen_done='1') then

                                txsim_done <= '1'; -- STOP after last frame sent

                        end if;

                   -- configure generator for every frame

                        if (ENA_INVERT_LB=TRUE) then
                        
                                txframe_cnt <= TB_RXFRAMES ;

                        elsif( ff_tx_sop='1' and ff_tx_wren_gen='1' and ((ff_tx_clk_gen_en='1' and ENABLE_MACLITE = 1) or ENABLE_MACLITE = 0)) then
            
                                txframe_cnt  <= txframe_cnt + 1;                       -- TX FRAMEs sent to FIFO

                           -- increment payload length  
                
                                ln := (conv_integer( ff_len ) + TB_LENSTEP) mod (TB_LENMAX+1);  -- increment length for next frame
                                                       
                                if (ln < 0) then  -- incase increment was negative
                        
                                        ln := TB_LENMAX;
                                       
                                end if;                        
                        
                                ff_len <= conv_std_logic_vector(ln,16);

                           -- update counters
                
                                if( ff_vlan_en='1' and ff_stack_vlan_en='0') then  
                                        
                                        tx_vlan_sent <= tx_vlan_sent+1;
                                       
                                end if;
                                
                                if(  ff_vlan_en='1' and  ff_stack_vlan_en='1' ) then  
                                        
                                        tx_stack_vlan_sent <= tx_stack_vlan_sent+1;
                                       
                                end if;

                                if( ff_payload_err='1' ) then  
                                        
                                        tx_payload_err_sent <= tx_payload_err_sent+1;
                
                                end if;
                
                                if( ff_frmtype=X"0000" and ff_phy_err = '0' and ff_end_err = '0') then  
                                        
                                        tx_good_sent <= tx_good_sent+1;
                
                                end if;
           
                        end if;                

                elsif( ff_tx_clk'event and ff_tx_clk='0' ) then
        
                        ff_tx_clk_gen_en <= ff_tx_rdy;               -- stop the generator clock if the FIFO signals "full"
                
                end if;
    
        end process; 

   -- GMII TX Monitor counters
   -- ------------------------

        process( reset, tx_clk ) 
        begin
        
                if( reset='1' ) then
        
                        tx_good_rcvd       <= 0;        -- should be same as good_sent at end of test
                        tx_pause_rcvd      <= 0;
                        tx_pause_err_rcvd  <= 0;
                        tx_align_err_rcvd  <= 0;        -- should NEVER happen
                        tx_vlan_rcvd       <= 0;        -- received by monitor
                        tx_stack_vlan_rcvd <= 0;        -- received by monitor
                        tx_phy_err_rcvd    <= 0;        -- GMII tx error signal detected
                        tx_payload_err_rcvd<= 0;
                        tx_wrong_src_rcvd  <= 0;
                        tx_crc_err_rcvd    <= 0;
                        gm_txcnt           <= 0;

                elsif( tx_clk'event and tx_clk='1' and mgm_frm_rcvd='1' ) then
                
                        gm_txcnt <= gm_txcnt+1 ;
                
                        if( mgm_is_vlan='1' and mgm_is_stack_vlan='0') then  
            
                                tx_vlan_rcvd <= tx_vlan_rcvd+1;
            
                        end if;
                        
                        if( mgm_is_vlan='1' and mgm_is_stack_vlan='1' ) then  
            
                                tx_stack_vlan_rcvd <= tx_stack_vlan_rcvd+1;
            
                        end if;
            
                        if( mgm_prmbl_err='1') then 
                
                                tx_align_err_rcvd <= tx_align_err_rcvd+1;
            
                        end if;
            
                        if( mgm_mac_err='1') then 
                
                                tx_phy_err_rcvd <= tx_phy_err_rcvd+1;
            
                        end if;
            
                        if( mgm_payload_err='1') then 
                
                                tx_payload_err_rcvd <= tx_payload_err_rcvd+1;  
            
                        end if;

                        if( mgm_crc_err='1') then 
                
                                tx_crc_err_rcvd <= tx_crc_err_rcvd+1;  
            
                        end if;

                        if( mgm_is_pause='1') then 
                
                                if( mgm_pause_op_err='0' and mgm_pause_dst_err='0' and mgm_frame_err='0') then
                
                                        tx_pause_rcvd <= tx_pause_rcvd+1;
                    
                                else
                
                                        tx_pause_err_rcvd <= tx_pause_err_rcvd+1;
                    
                                end if;
            
                        end if;            

                        if(mgm_crc_err      ='0' and
                           mgm_prmbl_err    ='0' and    
                           mgm_len_err      ='0' and
                           mgm_frame_err    ='0' and
                           mgm_is_pause     ='0' and       -- ignore pause frames
                           mgm_mac_err      ='0' and
                           mgm_end_err      ='0' ) then  
                
                                tx_good_rcvd <= tx_good_rcvd+1;
            
                                if (ENABLE_SUP_ADDR=0) then
            
                                        if( mgm_src /= mac_addr and TB_MACINSERT_ADDR and ENABLE_MAC_TXADDR_SET=1) then
                    
                                                tx_wrong_src_rcvd <= tx_wrong_src_rcvd+1;
                        
                                        elsif( mgm_src /= ff_src and not(TB_MACINSERT_ADDR) and ENABLE_MAC_TXADDR_SET=1) then
                    
                                                tx_wrong_src_rcvd <= tx_wrong_src_rcvd+1;
                        
                                        end if;
                                        
                                else
                                
                                        if (TB_ADDR_SEL=4 and TB_MACINSERT_ADDR and mgm_src/=sup_mac_addr_0 and ENABLE_MAC_TXADDR_SET=1) then
                                        
                                                tx_wrong_src_rcvd <= tx_wrong_src_rcvd+1;
                                                
                                        elsif (TB_ADDR_SEL=5 and TB_MACINSERT_ADDR and mgm_src/=sup_mac_addr_1 and ENABLE_MAC_TXADDR_SET=1) then
                                        
                                                tx_wrong_src_rcvd <= tx_wrong_src_rcvd+1;
                                                
                                        elsif (TB_ADDR_SEL=6 and TB_MACINSERT_ADDR and mgm_src/=sup_mac_addr_2 and ENABLE_MAC_TXADDR_SET=1) then
                                        
                                                tx_wrong_src_rcvd <= tx_wrong_src_rcvd+1;
                                                
                                        elsif (TB_ADDR_SEL=7 and TB_MACINSERT_ADDR and mgm_src/=sup_mac_addr_3 and ENABLE_MAC_TXADDR_SET=1) then
                                        
                                                tx_wrong_src_rcvd <= tx_wrong_src_rcvd+1;
                                                
                                        elsif (TB_ADDR_SEL=0 and TB_MACINSERT_ADDR and mgm_src/=mac_addr and ENABLE_MAC_TXADDR_SET=1) then
                                        
                                                tx_wrong_src_rcvd <= tx_wrong_src_rcvd+1;
                                                
                                        elsif ( mgm_src /= ff_src and not(TB_MACINSERT_ADDR)) then
                    
                                                tx_wrong_src_rcvd <= tx_wrong_src_rcvd+1;
                                                
                                        end if ;
                                        
                                end if ;
               
                        end if;
                                
                end if; 
    
        end process ;
                
   -- -----------------------------------------------------------------------------------
   -- TX/RX Pause Frame control block
   -- -----------------------------------------------------------------------------------

        process(reset, tx_clk)
    
                variable cnt : integer;
    
        begin
        
                if( reset='1') then
        
                        tx_pause_wait <= '0';
                        tx_pause_cnt  <= 0;
            
                elsif(tx_clk'event and tx_clk='1') then
        
                        if( tx_pause_cnt /= 0 ) then
            
                                if( gm_ether_gen_done='1' ) then      -- wait for TX to finish current frame

                                        tx_pause_cnt <= tx_pause_cnt-1;

                                end if;
                
                        else
            
                                tx_pause_wait <= '0';
                
                        end if;
                
                        if(mgm_frm_rcvd='1' and mgm_is_pause='1' and mgm_frame_err='0' and mgm_crc_err='0' and
                           TB_PAUSECONTROL=true) then
            
                                cnt := conv_integer( '0' & mgm_pquant);
                                cnt := cnt * 64;
                
                                tx_pause_cnt  <= cnt;         -- set pause counter
                                tx_pause_wait <= '1';        -- stop TX
                
                        end if;
        
                end if;
        
        end process;

   -- force generated pause frame
   -- ---------------------------        
    
        process(reset, tx_clk)
        begin
        
                if( reset='1') then
        
                        force_xoff_pause_cnt <= 0;
                        force_xon_pause_cnt  <= 0;
                        xoff_gen             <= '0';
                        xon_gen              <= '0' ;
            
                elsif(tx_clk'event and tx_clk='1') then
                
                   -- Xoff Frame Generation
                   -- ---------------------
                        
                        if (force_xoff_pause_cnt < TB_TRIGGERXOFF and state=SIM) then
            
                                force_xoff_pause_cnt <= force_xoff_pause_cnt + 1 ;  
            
                        elsif (force_xoff_pause_cnt=TB_TRIGGERXOFF and ETH_SPEED=1000 and state=SIM) then
            
                                force_xoff_pause_cnt <= force_xoff_pause_cnt + 1 ;
            
                        elsif ((force_xoff_pause_cnt=TB_TRIGGERXOFF or force_xoff_pause_cnt=TB_TRIGGERXOFF-1) and eth_mode/=1000 and state=SIM) then
            
                                force_xoff_pause_cnt <= force_xoff_pause_cnt + 1;
            
                        end if ;
                        
                        if (TB_TRIGGERXOFF=0 or HD_ENA=TRUE or ETH_SPEED=10 or ETH_SPEED=100) then
                        
                                xoff_gen <= '0' ;
            
                        elsif (force_xoff_pause_cnt=TB_TRIGGERXOFF and ETH_SPEED=1000 and state=SIM) then 
            
                                xoff_gen <= '1' ;   
            
                        elsif (state=SIM and (force_xoff_pause_cnt= TB_TRIGGERXOFF or force_xoff_pause_cnt=TB_TRIGGERXOFF-1) and (eth_mode=100 or eth_mode=10)) then
            
                                xoff_gen <= '1' ;   
            
                        else
            
                                xoff_gen <= '0' ;   
            
                        end if ;
                        
                   -- Xon Frame Generation
                   -- --------------------
                        
                        if (force_xon_pause_cnt < TB_TRIGGERXON and state=SIM) then
            
                                force_xon_pause_cnt <= force_xon_pause_cnt + 1 ;    
            
                        elsif (force_xon_pause_cnt=TB_TRIGGERXON and ETH_SPEED=1000 and state=SIM) then
            
                                force_xon_pause_cnt <= force_xon_pause_cnt + 1 ;
            
                        elsif ((force_xon_pause_cnt=TB_TRIGGERXON or force_xon_pause_cnt=TB_TRIGGERXON-1) and eth_mode/=1000 and state=SIM) then
            
                                force_xon_pause_cnt <= force_xon_pause_cnt + 1;
            
                        end if ;
                        
                        if (TB_TRIGGERXON=0 or HD_ENA=TRUE or ETH_SPEED=10 or ETH_SPEED=100) then
                        
                                xon_gen <= '0' ;
            
                        elsif (force_xon_pause_cnt=TB_TRIGGERXON and ETH_SPEED=1000 and state=SIM) then
            
                                xon_gen <= '1' ;    
            
                        elsif (state=SIM and (force_xon_pause_cnt= TB_TRIGGERXON or force_xon_pause_cnt=TB_TRIGGERXON-1) and (eth_mode=100 or eth_mode=10)) then
            
                                xon_gen <= '1' ;    
            
                        else
            
                                xon_gen <= '0' ;    
            
                        end if ; 
        
                end if;
           
        end process;
        
   -- -----------------------------------------------------------------------------------
   -- RX PATH Simulation
   -- -----------------------------------------------------------------------------------

        rx_is_good_frame <= (gm_prmbl_err='0') and
                            (gm_crc_err='0') and 
                            (gm_phy_err='0') and 
                            (gm_end_err='0') and
                            (gm_pad_en='1' or (gm_len >= 42 and gm_vlan_en='1') or 
                                              (gm_len >= 38 and gm_stack_vlan_en='1') or 
                                              (gm_len >= 46 and gm_vlan_en='0') 
                                              ) and
                            --((gm_vlan_en='1' and gm_len < (frm_length_max-21)) or
                            --(gm_stack_vlan_en='1' and gm_len < (frm_length_max-25)) or 
                            --(gm_vlan_en='0' and gm_len < (frm_length_max-17)) or 
                            (gm_len < (frm_length_max-17) or
                            gm_pause_gen='1' );
                            
        rx_is_good_addr  <= (promis_en='1') or (promis_en='0' and (
                            (gm_dst(0)='0' and (mac_addr = gm_dst or sup_mac_addr_0 = gm_dst or sup_mac_addr_1 = gm_dst or sup_mac_addr_2 = gm_dst or sup_mac_addr_3 = gm_dst) ) or
                            (gm_dst(0)='1' and (gm_dst = X"FFFFFFFFFFFF")) or
                            (gm_dst(0)='1' and gm_pause_gen='0' and (multicast_wrong=false)) ) );


    -- Stop detection and frame counter increment
    -- --------------

    gm_start_ether_gen <= '1' when (state=SIM and tx_pause_wait='0' and 
                                    sim_start='1' and rxsim_done='0' and 
                                    rxframe_cnt < TB_RXFRAMES) else
                          '1' when (nextstate=GEN_MAGIC and rxframe_cnt=TB_RXFRAMES)  else '0';
                                    
    m_start_ether_gen <= '1' when (state=SIM and tx_pause_wait='0' and
                                    sim_start='1' and rxsim_done='0' and 
                                    rxframe_cnt < TB_RXFRAMES and ethernet_mode='0' and REDUCED_INTERFACE_ENA = 0) else
                         '1' when (nextstate=GEN_MAGIC and rxframe_cnt=TB_RXFRAMES and ethernet_mode='0' and REDUCED_INTERFACE_ENA = 0)  else '0';
                            
    process( reset, rx_clk_tb ) 
    
        variable ln : integer;
    
    begin
        if( reset='1' ) then
        
            rxframe_cnt <= 0;
            rxsim_done  <= '0';
            gm_len  <= conv_std_logic_vector(TB_LENSTART, 16);  -- generated packets len
            gm_eop_dly  <= '0';
            gm_sop_dly  <= '0';
            gm_sop_dly2 <= '0';
            
        elsif( rx_clk_tb'event and rx_clk_tb='1' ) then
    
            gm_eop_dly <= gm_eop;
            gm_sop_dly <= gm_sop;
            gm_sop_dly2<= gm_sop_dly;
    
        -- non loopback mode
            if( gm_ether_gen_done='1' and rxframe_cnt >= TB_RXFRAMES and TB_RXFRAMES /= 0) then    -- last frame has been generated
 
            
                rxsim_done <= '1';
            
            end if;

        -- loopback mode
        if( gm_ether_gen_done='1' and rx_good_rcvd >= TB_RXFRAMES) then    -- last frame has been generated
            
                rxsim_done <= '1';
            
            end if;
            
        
        
        
            
            if (nextstate=GEN_MAGIC) then
            
                gm_len <= conv_std_logic_vector(42,16); 

        elsif(gm_eop_dly='1') then
            rxframe_cnt <= rxframe_cnt+1;
            elsif( gm_sop_dly='1') then
            
                --rxframe_cnt <= rxframe_cnt+1;
                ln     := (conv_integer( gm_len ) + TB_LENSTEP) mod (TB_LENMAX+1);  -- increment length for next frame

                if(ln < 0) then  -- incase increment was negative
                        ln := TB_LENMAX;
                end if;  
                
                gm_len <= conv_std_logic_vector(ln,16);
                                        
            end if;
            
        end if;
        
    end process;
    
   -- Inter-Packet Gap Counter
   -- ------------------------
   
        process( reset, rx_clk_tb) 
        
                variable cnt      : integer ;
                variable free_cnt : integer range 0 to 15 ;
           
        begin
        
                if( reset='1' ) then
                
                        gm_ipg_cnt <=  TB_RXIPG-1 ;       
                        
                elsif (rx_clk_tb='1') and (rx_clk_tb'event) then
                
                        free_cnt := (free_cnt+1) mod 16 ;
                
                        if (TB_ENA_VAR_IPG=TRUE) then
                
                                if( gm_sop_dly='1') then
                        
                                        cnt := gm_ipg_cnt+free_cnt ;
                                
                                end if ;
                        
                                if (cnt<0) then
                        
                                        cnt := TB_RXIPG-1 ;
                                
                                end if ;
                        
                                if (cnt>47) then
                        
                                        cnt := TB_RXIPG-1 ;
                                
                                end if ;       
                        
                                gm_ipg_cnt <= cnt ;
                                
                        else
                        
                                gm_ipg_cnt <= TB_RXIPG-1 ;  
                                
                        end if ;      
                        
                end if ;
                
        end process ;    

   -- Total (Including Collision) Frames
   -- ----------------------------------
   
        process(reset, tx_clk)
        begin
        
                if (reset='1') then
                
                        tx_frm_all <= 0 ;
                        
                elsif (tx_clk='1') and (tx_clk'event) then
                
                        if (m_mgm_frm_rcvd='1') then
                        
                                tx_frm_all <= tx_frm_all+1 ;
                                
                        end if ;
                        
                end if ;
                
        end process ; 

    -- Expected signals: decide when we should expect something to happen
    -- ------------------------------------------------------------------
    
    process( rx_clk_tb, reset ) 
    begin
        if( reset='1' ) then

            expect1     <= '0';
            expect2     <= '0';

        elsif( rx_clk_tb='1' and rx_clk_tb'event ) then

            if( gm_sop='1' and expect2='0' ) then
            
                expect2     <= '1';  -- immediately expect something
                expect1     <= '0';  -- and nothing else
                
            elsif( gm_sop='1' ) then
            
                expect1     <= '1';  -- ok, when done later, immediately expect something else coming
                
            end if;

            -- if a final event happend that indicates that something was received and
            -- therefore some expected behaviour occured we can continue to watch
            -- for new expected data

            if( pause_rcv='1' or       -- has no status fifo write
                frm_type_err='1' or    -- has no status fifo write (but should have, can strip down pipeline: TODO !!!!!)
                frm_align_err='1' or   -- has no status fifo write 
                ff_rx_eop='1') then    -- was: rx_stat_wren


                if( frm_align_err='1' and expect1='1' ) then
                
                    -- overlapped frame has an alignment error, but before the last frame
                    -- has been checked... so we have to do special things here
                    -- see alignment error checking behaviour.
                    
                    expect1 <= '0';  -- clear it, as it is processed now already
                    
                else
                
                    expect2     <='0';     -- pulse for at least 1 cycle    
                    
                end if;
                
            end if;
            
            -- if a new expectation was already inserted before we were done with the old, 
            -- immediately restart it now as we have processed the last expected (2)
            
            if( expect1='1' and expect2='0' ) then    -- there is something to expect !
            
                expect1 <= '0';
                expect2 <= '1';
                
            end if;
        end if;
    end process;

    -- RX generator: vary the destination address of the generator
    
    process( rx_clk_tb, reset ) 
        variable mdl : integer;
    begin
    
        if( reset = '1' ) then
        
            gm_dst        <= mac_addr; -- (others => '0');
            multicast_cnt <= 1;    -- dont put it to 0 as 0 is the PAUSE address

        elsif( rx_clk_tb='1' and rx_clk_tb'event ) then
    
            if( gm_sop_dly2='1') then
         -- if( gm_eop='1' and gm_eop_dly='0') then -- change it at end of sent
    
            mdl := rxframe_cnt mod 35;
            
            if( mdl = 7 ) then
        
                gm_dst <= X"AA123456789C";     -- different unicast mac address
            
            elsif( (mdl=12 or mdl=9 or mdl=20)) then 
        
                gm_dst <= MCAST_ADDRESSLIST( multicast_cnt );    
                
                if( multicast_cnt < MCAST_TABLEN-1 ) then
                    multicast_cnt <= multicast_cnt+1;
                    multicast_wrong <= false;
                    
                else
                    multicast_cnt <= 1;   -- dont use first which is PAUSE
                    if (ENA_HASH = 1) then
            multicast_wrong <= true;    -- send one wrong address on every wrap around
                    end if;
            gm_dst <= X"EEAB55EFF011";
                    
                end if;
                
            
            elsif( mdl = 31 or mdl=11) then
        
                gm_dst <= X"FFFFFFFFFFFF";     -- broadcast frame
            
            elsif (mdl=3) then
                
                if (ENABLE_SUP_ADDR=1) then
            
                        gm_dst <= sup_mac_addr_0;
                        
                else
                
                        gm_dst <= mac_addr ;
                        
                end if ;        
                
            elsif (mdl=5) then
            
                if (ENABLE_SUP_ADDR=1) then
            
                        gm_dst <= sup_mac_addr_2;
                        
                else
                
                        gm_dst <= mac_addr ;
                        
                end if ;
                
            elsif (mdl=6) then
            
                if (ENABLE_SUP_ADDR=1) then
            
                        gm_dst <= sup_mac_addr_3;
                        
                else
                
                        gm_dst <= mac_addr ;
                        
                end if ;
                
            elsif (mdl=2) then
            
                if (ENABLE_SUP_ADDR=1) then
            
                        gm_dst <= sup_mac_addr_1;
                        
                else
                
                        gm_dst <= mac_addr ;
                        
                end if ;
                
            else
            
                gm_dst <= mac_addr ;
                        
            end if;
            
            if( gm_pause_gen='1' ) then
        
                gm_dst <= X"010000c28001";
            
            end if;
          
         end if; -- gm_eop
         
            if (nextstate/=SIM) then
            
                gm_dst <= mac_addr ;
                
            end if ;
            
        end if;
        
    end process;

    -- ------------------------------------------------------------------- --
    -- RX Generator: good frames with and without payload error statistics --
    -- and all FIFO received error counters                                --
    -- ------------------------------------------------------------------- --

    process( rx_clk_tb, reset ) 
        
        variable maxlen : integer;
        variable payloadlen : integer;
        variable payloadminlen : integer;
        
    begin
        if( reset='1') then

            rx_good_sent <= 0;
            rx_payload_err_sent <= 0;
            rx_gmii_err_sent <= 0;

        elsif( rx_clk_tb='1' and rx_clk_tb'event ) then

            if( gm_sop='1' and state=SIM) then

                -- determine maximum length of a good frame
        
                payloadlen    := conv_integer('0' & gm_len);
                payloadminlen := 46;
                maxlen        := payloadlen + 18;        
                
                if (gm_stack_vlan_en='1' ) then
                    --maxlen := maxlen + 8;
                    payloadminlen := 38;     
                elsif( gm_vlan_en='1' ) then
                    --maxlen := maxlen + 4;
                    payloadminlen := 42;    
                end if;
                
                -- check if we send a good frame:
                --    pause is not a good in this sense
                --    wrong MAC address and non-promiscuous mode is not good in this sense       
            
                if( --(gm_frmtype   =0) and 
                    (gm_prmble_len=8) and 
                    (maxlen <= conv_integer(frm_length_max)) and
                    (gm_prmbl_err='0') and
                    (gm_crc_err  ='0') and
                    (gm_pause_gen='0') and
                    ((gm_pad_en  ='1') or (payloadlen >= payloadminlen)) and -- padding off, but not necessary anyway ?
                    (gm_phy_err  ='0') and
                    (gm_end_err  ='0') and
                    (    (gm_dst(0)='1' and gm_pause_gen='0' and multicast_wrong=false)
                      or ((gm_dst(0)='0') and (mac_addr=gm_dst or sup_mac_addr_0=gm_dst or sup_mac_addr_1=gm_dst or sup_mac_addr_2=gm_dst or sup_mac_addr_3=gm_dst)) 
                      or promis_en='1'  
                      or (gm_dst = X"FFFFFFFFFFFF") ) ) then  -- unicast address mismatch, or multicast always
                    
                        rx_good_sent <= rx_good_sent + 1;
                
                        if( gm_payload_err='1' and gm_len>2) then
                        
                            rx_payload_err_sent <= rx_payload_err_sent +1;
                            
                        end if;
                        
                end if;
                
                if( gm_phy_err='1' and rx_is_good_addr) then   -- ignore frames that will be discarded
                
                        if not(((gm_dst(0)='0') and (gm_dst /= mac_addr) and promis_en='0') or
                                   ((gm_dst(0)='1') and multicast_wrong and gm_pause_gen='0' and promis_en='0' and gm_dst/=X"FFFFFFFFFFFF" ) or
                                    (gm_prmbl_err='1') or
                                    (gm_pause_gen='1') ) then
                
                                rx_gmii_err_sent <= rx_gmii_err_sent+1;
                                
                        end if ;
                        
                end if;
                
             end if; -- gm_sop

        end if; --clk
    end process;

    -- FIFO INTERFACE receive statistics counters
    -- ------------------------------------------
    
    process( ff_rx_clk, reset ) 
    begin
        if( reset='1' ) then

            rx_good_rcvd            <= 0;
            rx_payload_err_rcvd     <= 0;
            rx_wrong_status_rcvd    <= 0;
            rx_length_err_rcvd      <= 0;
            rx_crc_err_rcvd         <= 0;
            rx_fifo_overflow_rcvd   <= 0;
            rx_gmii_err_rcvd        <= 0;
            rx_vlan_rcvd            <= 0;
            rx_stack_vlan_rcvd      <= 0;
            rx_broadcast_rcvd       <= 0;
            rx_wrong_mac_rcvd       <= 0;
            rx_multicast_rcvd       <= 0;
            rx_non_discard_rcvd     <= 0;
            last_err_stat           <= (others => '0' );
            ff_last_length          <= (others => '0' );
            rx_length_mismatch_rcvd <= 0;
            ff_frmlen               <= 0;
            rx_col_rcvd             <= 0 ;
            mff_dst_reg             <= (others=>'0') ;
            mff_is_pause_reg        <= '0' ;
            mff_end_err_reg         <= '0' ;

        elsif( ff_rx_clk='1' and ff_rx_clk'event ) then
        
                mff_dst_reg      <= mff_dst ;
                mff_is_pause_reg <= mff_is_pause ;
                mff_end_err_reg  <= mff_end_err ;

          -- count number of bytes received for the frame
          -- --------------------------------------------

             if(ff_rx_sop='1') then
             
                ff_frmlen <= 1;
             
             elsif(ff_rx_dval='1') then
             
                ff_frmlen <= ff_frmlen+1;
             
             end if;
           
             if (mff_frm_rcvd='1' and mff_end_err_reg='0' and TB_MACPADEN=TRUE) then
             
                    mff_rxcnt <= mff_rxcnt+1 ;
                
                    if(mff_payload_err='1') then

                        rx_payload_err_rcvd <= rx_payload_err_rcvd+1;
                      
                    end if;
                    
                  -- verify that the status word length field really matches what we find in the frame
                  -- ---------------------------------------------------------------------------------
                    
                    if( mff_len /= ff_last_length and mff_is_pause_reg='0') then
                        
                        rx_length_mismatch_rcvd <= rx_length_mismatch_rcvd + 1;
                        
                    end if;
                                    
                    if( last_err_stat="0000" ) then -- only good ones
                    
                        if(mff_dst_reg=X"FFFFFFFFFFFF") then
                    
                                rx_broadcast_rcvd <= rx_broadcast_rcvd+1;
                                
                        elsif (ENABLE_SUP_ADDR=0) then
    
                                if(mff_dst_reg(0)='0' and mac_addr /= mff_dst_reg and sup_mac_addr_0 /= mff_dst_reg and sup_mac_addr_1 /= mff_dst_reg and sup_mac_addr_2 /= mff_dst_reg and sup_mac_addr_3 /= mff_dst_reg) then  -- unicast but not for me
            
                                        rx_wrong_mac_rcvd <= rx_wrong_mac_rcvd+1;     
                    
                                elsif(mff_dst_reg(0)='1' and mff_is_pause_reg='0') then  -- multicast, but not broadcast
                
                                        rx_multicast_rcvd <= rx_multicast_rcvd + 1;
                
                                end if;
                                
                        else
                        
                                if(mff_dst_reg(0)='0' and mac_addr /= mff_dst_reg and sup_mac_addr_0 /= mff_dst_reg and sup_mac_addr_1 /= mff_dst_reg and sup_mac_addr_2 /= mff_dst_reg and sup_mac_addr_3 /= mff_dst_reg) then  -- unicast but not for me
            
                                        rx_wrong_mac_rcvd <= rx_wrong_mac_rcvd+1;     
                    
                                elsif(mff_dst_reg(0)='1' and mff_is_pause_reg='0') then  -- multicast, but not broadcast
                
                                        rx_multicast_rcvd <= rx_multicast_rcvd + 1;
                
                                end if;
                                
                        end if ;        
                    
                    end if;
                    
             elsif (mff_frm_rcvd='1' and TB_MACPADEN=FALSE) then
             
                        mff_rxcnt <= mff_rxcnt+1 ;                
                    
                  -- verify that the status word length field really matches what we find in the frame
                  -- ---------------------------------------------------------------------------------                   
                                                        
                        if(mff_dst_reg=X"FFFFFFFFFFFF") then
                    
                                rx_broadcast_rcvd <= rx_broadcast_rcvd+1;
    
                        elsif (ENABLE_SUP_ADDR=0) then
    
                                if(mff_dst_reg(0)='0' and (mac_addr /= mff_dst_reg) ) then  -- unicast but not for me
            
            
                                        rx_wrong_mac_rcvd <= rx_wrong_mac_rcvd+1;     
                    
                                elsif(mff_dst_reg(0)='1' and mff_is_pause_reg='0') then  -- multicast, but not broadcast
                
                                        rx_multicast_rcvd <= rx_multicast_rcvd + 1;
                
                                end if;
                                
                        else
                        
                                if(mff_dst_reg(0)='0' and mac_addr /= mff_dst_reg and sup_mac_addr_0 /= mff_dst_reg and sup_mac_addr_1 /= mff_dst_reg and sup_mac_addr_2 /= mff_dst_reg and sup_mac_addr_3 /= mff_dst_reg) then  -- unicast but not for me
            
                                        rx_wrong_mac_rcvd <= rx_wrong_mac_rcvd+1;     
                    
                                elsif(mff_dst_reg(0)='1' and mff_is_pause_reg='0') then  -- multicast, but not broadcast
                
                                        rx_multicast_rcvd <= rx_multicast_rcvd + 1;
                
                                end if;
                                
                        end if ;                    
                    
             end if;

             -- now check reception of good frames on FIFO interface
             -- (we have no Preamble and CRC there, so do not check these errors on the MFF status)
             
             if( ff_rx_eop='1' and mff_is_pause='0') then           -- good frames should come out
                         
                rx_non_discard_rcvd <= rx_non_discard_rcvd +1;
                
             end if ;

             if( ff_rx_eop='1' and mff_is_pause='0') then           -- good frames should come out
             
                -- remember the length as it was given from the FIFO
             
                ff_last_length  <= ff_rx_err_stat(20 downto 5);

                rx_non_discard_rcvd <= rx_non_discard_rcvd +1;

                last_err_stat( 3 downto 0 ) <= ff_rx_err_stat(3 downto 0);  -- save it for the monitor checks
                
                if( ff_rx_err_stat(3 downto 0) = 0 and mff_is_pause='0') then
                    
                    rx_good_rcvd <= rx_good_rcvd +1 ;
                    
                    if( ff_rx_err_stat(4)='1' and ff_rx_err_stat(22)='0' ) then
            
                        rx_vlan_rcvd <= rx_vlan_rcvd +1;
                        
                    end if;
                    
                    if( ff_rx_err_stat(4)='1' and ff_rx_err_stat(22)='1' ) then
            
                        rx_stack_vlan_rcvd <= rx_stack_vlan_rcvd +1;
                        
                    end if;
                    
                    if(ff_rx_err_stat(21) ='1') then
                    
                        rx_col_rcvd <= rx_col_rcvd+1;
                        
                    end if;
                
                elsif (mff_is_pause='0') then  -- some error occured
                    
                    rx_wrong_status_rcvd <= rx_wrong_status_rcvd+1;
                    
                    if(ff_rx_err_stat(0) ='1' ) then
                    
                        rx_length_err_rcvd <= rx_length_err_rcvd+1;
                        
                    elsif(ff_rx_err_stat(1) ='1') then
                    
                        rx_crc_err_rcvd <= rx_crc_err_rcvd+1;
                    
                    end if;
                        
                    if(ff_rx_err_stat(2) ='1') then
                     
                        rx_fifo_overflow_rcvd <= rx_fifo_overflow_rcvd + 1;                    
                    
                    end if;
                    
                    if(ff_rx_err_stat(3) ='1') then
                    
                        rx_gmii_err_rcvd <= rx_gmii_err_rcvd+1;
                        
                    end if;
                
                end if;
                
             end if;
    
        end if;
        
    end process;

    -- Frames with different MAC address and Broadcast MAC address
    -- -------------------------------------------------------------------
    
    promis_en <= '1' when TB_PROMIS_ENA else '0' ;
    
    process( rx_clk_tb, reset ) 
    begin
        if( reset='1' ) then
        
            rx_broadcast_sent   <= 0;
            rx_wrong_mac_sent   <= 0;
            rx_multicast_sent_total   <= 0;
            rx_multicast_sent   <= 0;
            rx_multicast_denied <= 0;
            
            
        elsif( rx_clk_tb='1' and rx_clk_tb'event ) then
    
            if( gm_sop='1' ) then
            
                if( gm_dst = X"FFFFFFFFFFFF") then
                
                    rx_broadcast_sent <= rx_broadcast_sent+1;
                    
                elsif( rx_is_good_frame and gm_pause_gen='0' and
                       ((gm_dst(0)='0') and        -- unicast address
                        (gm_dst/=mac_addr and gm_dst/=sup_mac_addr_0 and gm_dst/=sup_mac_addr_1 and gm_dst/=sup_mac_addr_2 and gm_dst/=sup_mac_addr_3) and   -- and not the same
                        (promis_en='1')          -- and is promiscuous, then should be received
                       )    ) then 
                
                    rx_wrong_mac_sent <= rx_wrong_mac_sent+1;
                    
                elsif( rx_is_good_frame and (gm_dst(0)='1') and gm_pause_gen='0') then    -- Multicast Address
                
                    rx_multicast_sent_total <= rx_multicast_sent_total +1;
                
                    if( multicast_wrong and promis_en='0' and ENA_HASH=1) then

                        rx_multicast_denied <= rx_multicast_denied+1;  -- then wrong multicast should be denied
                        
                    else 
                    
                        rx_multicast_sent <= rx_multicast_sent + 1;  -- count good frames here (which are expected to be received)
                        
                    end if;
                    
                end if;

            end if;
    
        end if;
    end process;
    
   -- Core Statistic Registers
   -- ------------------------
   
        process(reset, reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reset='1') then
                
                        rx_pause_rcvd <= 0 ;
                        
                elsif (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_PAUSE_RX and reg_busy='0') then
                        
                                rx_pause_rcvd <= conv_integer(reg_data_out) ;
                                                                                                
                                write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                                writeline(output, ln) ; 
                                write(ln, string'(" ")) ; 
                                writeline(output, ln) ; 
                                write(ln, string'(" Core Statistic Counters")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                writeline(output, ln) ; 
                                write(ln, string'("     - Number of Received Pause Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_PAUSE_TX and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Transmitted Pause Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_UNICAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Unicast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_MLTCAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Multicast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_BRDCAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Broadcast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=TX_UNICAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Transmitted Unicast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=TX_MLTCAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Transmitted Multicast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=TX_BRDCAST and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Transmitted Broadcast Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=TX_FRM_ERR and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Frames Transmitted with an Error : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                writeline(output, ln) ; 
                                write(ln, string'(" RMON Counters")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_FRM_ERR and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Frames Received with an Error : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_FRM_DROP and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Frames Dropped Because of FIFO Overflow : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_UNDERSZ_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Undersized Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_OVERSZ_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Oversized Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_64_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received 64-Bytes Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_65_127_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 65 and 127 Bytes : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_128_255_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 128 and 255 Bytes : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_256_511_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 256 and 511 Bytes : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_512_1023_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 512 and 1023 Bytes : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_1024_1518_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 1024 and 1518 Bytes : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_1519_X_FRM and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Frames with Size Between 1519 and Max Frame Length : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_JABBER and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Jabber Frames (Oversize with Wrong CRC) : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RX_FRAGMENT and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Fragments (Undersized with Wrong CRC) : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_SW_RESET and reg_busy='0') then
                        
                                write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;
                                write(ln, string'("     ")) ;
                                writeline(output, ln) ;
                        
                                if (reg_data_out(13)='0') then       
                        
                                        
                                        write(ln, string'("   - SW Reset Register Cleared")) ;
                                        writeline(output, ln) ;
                                        
                                else
                                
                                        write(ln, string'("   - Error: SW Reset Register NOT Cleared")) ;
                                        writeline(output, ln) ;
                                        
                                end if ;  
                                
                                if (reg_data_out(0)='0') then       
                        
                                        
                                        write(ln, string'("   - MAC Transmit Disabled")) ;
                                        writeline(output, ln) ;
                                        
                                else
                                
                                        write(ln, string'("   - Error: MAC Transmit NOT Disabled")) ;
                                        writeline(output, ln) ;
                                        
                                end if ;  
                                
                                if (reg_data_out(1)='0') then       
                        
                                        
                                        write(ln, string'("   - MAC Receive Disabled")) ;
                                        writeline(output, ln) ;
                                        
                                else
                                
                                        write(ln, string'("   - Error: MAC Receive NOT Disabled")) ;
                                        writeline(output, ln) ;
                                        
                                end if ;                                                                        
                                
                                write(ln, string'(" ")) ;    
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_FRM_TX and reg_busy='0') then
                                                       
                                write(ln, string'("     - Number of Transmitted Correct Frames - With Pause Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_FRM_RX and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Correct Frames - With Pause Frames : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_CRC_ERR and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Frames Received with CRC Error : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_ALIGN_ERR and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Frames Received with an Alignment Error : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_TX_OCTETS and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Transmitted Octets : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
        
        begin
                
                if (reg_clk='0') and (reg_clk'event) then
                
                        if (state=RD_RX_OCTETS and reg_busy='0') then
                        
                                write(ln, string'("     - Number of Received Octets : ")) ;
                                write(ln, conv_integer(reg_data_out)) ;
                                writeline(output, ln) ;
                                
                        end if ;
                        
                end if ;
                
        end process ;

    -- GMII RX Generator transmission statistics
    -- -----------------------------------------
    
        process( rx_clk_tb, reset ) 
        begin
        
                if( reset='1' ) then
        
                        rx_pause_sent           <= 0;
                        rx_align_err_sent       <= 0;
                        rx_align_err_rcvd       <= 0;
                        rx_vlan_sent            <= 0;
                        rx_stack_vlan_sent      <= 0;
                        rx_vlan_wrong_type_sent <= 0;
                        rx_crc_err_sent         <= 0;
                        rx_wrong_status_sent    <= 0;

                elsif( rx_clk_tb='1' and rx_clk_tb'event ) then

                        if( gm_sop='1' ) then
            
                           -- Pause Frame Counter
                           -- -------------------
            
                                if( gm_pause_gen='1' and rx_is_good_frame and gm_dst=X"010000c28001") then  -- only good ones
            
                                        rx_pause_sent <= rx_pause_sent +1;
                    
                                end if;
                
                           -- Alignment Errors Counter
                           -- ------------------------
                
                                if( gm_prmbl_err='1' ) then
                
                                        rx_align_err_sent <= rx_align_err_sent+1;
                    
                                end if;
                
                           -- CRC Errors Counter
                           -- ------------------
                
                                if( gm_crc_err='1' and rx_is_good_addr) then
                
                                        rx_crc_err_sent <= rx_crc_err_sent +1;
                
                                end if;
                
                           -- VLAN Frames Counter
                           -- -------------------
                
                                if(gm_vlan_en='1' and gm_stack_vlan_en='0' and gm_pause_gen='0' and rx_is_good_frame and rx_is_good_addr) then
            
                                        if( gm_frmtype = 0 ) then
                
                                                rx_vlan_sent <= rx_vlan_sent + 1;
                    
                                        else

                                                rx_vlan_wrong_type_sent <= rx_vlan_wrong_type_sent + 1;
                        
                                        end if;
                    
                                end if;
                                
                           -- Stacked VLAN Frames Counter
                           -- ---------------------------
                
                                if(gm_vlan_en='1' and  gm_stack_vlan_en='1' and gm_pause_gen='0' and rx_is_good_frame and rx_is_good_addr) then
            
                                        if( gm_frmtype = 0 ) then
                
                                                rx_stack_vlan_sent <= rx_stack_vlan_sent + 1;
                                            
                                        end if;
                    
                                end if;                                

                           -- Frames Received with Wrong Status
                           -- ---------------------------------

                                if( gm_prmbl_err='0' and   -- frames with wrong preamble are never pushed
                                    gm_pause_gen='0' and   -- pause frames are never delivered to the FIFO, therefore cannot cause wrong status
                                    rx_is_good_addr  ) then 
                        
                                        if((gm_crc_err='1' ) or
                                           (gm_end_err='1' ) or
                                           (gm_phy_err='1' ) or
                                           (gm_pad_en='0' and gm_vlan_en='1' and gm_len<42 ) or
                                           (gm_pad_en='0' and gm_stack_vlan_en='1' and gm_len<38 ) or
                                           (gm_pad_en='0' and gm_vlan_en='0' and gm_len<46 ) or
                                           --(gm_stack_vlan_en='1' and gm_len > (frm_length_max-26)) or
                                           --(gm_vlan_en='1' and gm_len > (frm_length_max-22)) or
                                           --(gm_vlan_en='0' and gm_len > (frm_length_max-18))) then
                                           (gm_len > (frm_length_max-18))) then -- new independent from VLAN
                                                rx_wrong_status_sent <= rx_wrong_status_sent + 1;

                                        end if;
                
                                end if;
           
                        end if;
            
                        if( frm_align_err='1' ) then
            
                                rx_align_err_rcvd <= rx_align_err_rcvd + 1;
                
                        end if;

                end if;

        end process;

    -- Frames that should be discarded
    -- -------------------------------
    
        process( rx_clk_tb, reset ) 
        begin
        
                if( reset='1' ) then
        
                        rx_discard_sent <= 0;
                        rx_discard_rcvd <= 0;
            
                elsif( rx_clk_tb='1' and rx_clk_tb'event ) then

                        if( gm_sop='1' ) then
            
                                if(((gm_dst(0)='0') and (gm_dst /= mac_addr and gm_dst /= sup_mac_addr_0 and gm_dst /= sup_mac_addr_1 and gm_dst /= sup_mac_addr_2 and gm_dst /= sup_mac_addr_3) and promis_en='0') or  -- invalid unicast mac address ?
                                   ((gm_dst(0)='1') and multicast_wrong and gm_pause_gen='0' and promis_en='0' and gm_dst/=X"FFFFFFFFFFFF" ) or
                                    (gm_prmbl_err='1') or
                                    --(gm_frmtype /= 0 ) or         -- TBD (pushed saving pipelines?)!!
                                    (gm_pause_gen='1') ) then
                    
                                        rx_discard_sent <= rx_discard_sent + 1;
                    
                                end if;

                        end if;
                            
                        rx_discard_rcvd <= rxframe_cnt - rx_non_discard_rcvd;

                end if;
    
        end process;

    -- Block RX FIFO Read
    -- ------------------

        ff_rx_rdy <= '0' when (stop_rx_fifo_read='1' and rx_hold_cnt < TB_HOLDREAD) else '1';

        process( ff_rx_clk, reset ) 
        begin
        
                if( reset='1' ) then

                        stop_rx_fifo_read <= '0';
                        rx_hold_cnt       <= 0;
                        rx_fifo_cnt       <= 0;
            
                elsif( ff_rx_clk='1' and ff_rx_clk'event ) then
        
                        if( ff_rx_sop='1' ) then
            
                                rx_fifo_cnt <= rx_fifo_cnt+1;     -- count each Frame read from the FIFO
                
                        end if;
        
                        if( TB_STOPREAD/=0 and TB_STOPREAD<rx_fifo_cnt and stop_rx_fifo_read='0')  then
            
                                stop_rx_fifo_read <= '1';
                
                        end if;
            
                        if( stop_rx_fifo_read='1' and rx_hold_cnt<TB_HOLDREAD ) then
            
                                rx_hold_cnt <= rx_hold_cnt + 1;
                
                        end if;

                end if;
    
        end process;
                            
   -- Control State Machine
   -- ---------------------
   
        process(reset, reg_clk)
        begin
        
                if (reset='1') then
                
                        state <= IDLE ;
                        
                elsif (reg_clk='1') and (reg_clk'event) then
                
                        state <= nextstate ;
                        
                end if ;
                
        end process ;
        
        process(state,sim_start, reg_busy, lut_prog_cnt, rxsim_done, txsim_done, ff_rx_dsav, gm_tx_en, m_tx_en , rgm_tx_en,sim_cnt_end, reg_wakeup, gm_ether_gen_done)
        begin
        
                case state is
                
                        when IDLE =>
                        
                                if (sim_start='1' ) then
                                
                                nextstate <= READ_VER ;
                                
                                else
                                
                                        nextstate <= IDLE ;
                                        
                                end if ;
                                
                        when READ_VER =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                  if (ENABLE_MACLITE = 0) then
                                        nextstate <= WR_SCRATCH ;
                                  else
                                        nextstate <= MAC_CONFIG ;
                                  end if;
                                        
                                else
                                
                                        nextstate <= READ_VER ;
                                        
                                end if ;
                                
                        when WR_SCRATCH =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_SCRATCH ;
                                        
                                else
                                
                                        nextstate <= WR_SCRATCH ;
                                        
                                end if ;
                                
                        when RD_SCRATCH =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= MAC_CONFIG ;
                                        
                                else
                                
                                        nextstate <= RD_SCRATCH ;
                                        
                                end if ; 

                        when MAC_CONFIG =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_MAC1 ;
                                        
                                else
                                
                                        nextstate <= MAC_CONFIG ;
                                        
                                end if ; 
                                
                        when WR_MAC1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_MAC2 ;
                                        
                                else
                                
                                        nextstate <= WR_MAC1 ;
                                        
                                end if ; 
                                
                        when WR_MAC2 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_IPG_LEN ;
                                        
                                else
                                
                                        nextstate <= WR_MAC2 ;
                                        
                                end if ;  
                                
                        when WR_IPG_LEN =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                   if (ENABLE_MACLITE = 0) then
                                        nextstate <= WR_FRM_LENGTH ;
                                   else
                                        nextstate <= LUT_PROG_INC ;
                                   end if;
                                else
                                
                                        nextstate <= WR_IPG_LEN ;
                                        
                                end if ;
                                
                        when WR_FRM_LENGTH =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_PAUSE_QUANTA ;
                                        
                                else
                                
                                        nextstate <= WR_FRM_LENGTH ;
                                        
                                end if ;
                                
                        when WR_PAUSE_QUANTA =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_RX_SE ;
                                        
                                else
                                
                                        nextstate <= WR_PAUSE_QUANTA ;
                                        
                                end if ; 
                                
                        when WR_RX_SE =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_RX_SF ;
                                        
                                else
                                
                                        nextstate <= WR_RX_SE ;
                                        
                                end if ; 
                                
                        when WR_RX_SF =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_TX_SE ;
                                        
                                else
                                
                                        nextstate <= WR_RX_SF ;
                                        
                                end if ; 
                                
                        when WR_TX_SE =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_TX_SF ;
                                        
                                else
                                
                                        nextstate <= WR_TX_SE ;
                                        
                                end if ;
                                
                        when WR_TX_SF =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_RX_AE ;
                                        
                                else
                                
                                        nextstate <= WR_TX_SF ;
                                        
                                end if ;
                                
                        when WR_RX_AE =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_RX_AF ;
                                        
                                else
                                
                                        nextstate <= WR_RX_AE ;
                                        
                                end if ;  
                                
                        when WR_RX_AF =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_TX_AE ;
                                        
                                else
                                
                                        nextstate <= WR_RX_AF ;
                                        
                                end if ; 
                                
                        when WR_TX_AE =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_TX_AF ;
                                        
                                else
                                
                                        nextstate <= WR_TX_AE ;
                                        
                                end if ; 
                                
                        when WR_TX_AF =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        if (TB_MDIO_SIMULATION=TRUE and  ENABLE_MDIO = 1) then
                                
                                                nextstate <= WR_MDIO_ADDR0 ;
                                                
                                        else
                                        
                                                nextstate <= LUT_PROG_INC ;
                                                
                                        end if ;
                                        
                                else
                                
                                        nextstate <= WR_TX_AF ;
                                        
                                end if ;           
                                
                        when WR_MDIO_ADDR0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_MDIO_ADDR1 ;
                                        
                                else
                                
                                        nextstate <= WR_MDIO_ADDR0 ;
                                        
                                end if ; 
                                
                        when WR_MDIO_ADDR1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WRITE_MDIO0 ;
                                        
                                else
                                
                                        nextstate <= WR_MDIO_ADDR1 ;
                                        
                                end if ;                                                              
                                
                        when WRITE_MDIO0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= READ_MDIO0 ;
                                        
                                else
                                
                                        nextstate <= WRITE_MDIO0 ;
                                        
                                end if ;
                                
                        when READ_MDIO0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WRITE_MDIO1 ;
                                        
                                else
                                
                                        nextstate <= READ_MDIO0 ;
                                        
                                end if ; 
                                
                        when WRITE_MDIO1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= READ_MDIO1 ;
                                        
                                else
                                
                                        nextstate <= WRITE_MDIO1 ;
                                        
                                end if ;
                                
                        when READ_MDIO1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= LUT_PROG ;
                                        
                                else
                                
                                        nextstate <= READ_MDIO1 ;
                                        
                                end if ;
                                
                        when LUT_PROG_INC =>
                                if (ENA_HASH = 1) then
                                   if (lut_prog_cnt=MCAST_TABLEN-1) then
                                   
                                           if (ENABLE_SUP_ADDR=1) then
                                           
                                                   nextstate <= WR_SUP_MAC0_0 ;
                                                   
                                           else
                                   
                                                   nextstate <= SIM ;
                                                   
                                           end if ;
                                           
                                   else
                                   
                                           nextstate <= LUT_PROG ;
                                           
                                   end if ;
                                 else
                                    nextstate <= SIM ;
                                end if; 
                        when WR_SUP_MAC0_0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC0_1 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC0_0 ;
                                        
                                end if ;
                                
                        when WR_SUP_MAC0_1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC1_0 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC0_1 ;
                                        
                                end if ;
                        
                        when WR_SUP_MAC1_0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC1_1 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC1_0 ;
                                        
                                end if ; 
                                
                        when WR_SUP_MAC1_1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC2_0 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC1_1 ;
                                        
                                end if ; 
                                
                        when WR_SUP_MAC2_0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC2_1 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC2_0 ; 
                                        
                                end if ;
                                
                        when WR_SUP_MAC2_1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC3_0 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC2_1 ; 
                                        
                                end if ;
                                        
                        when WR_SUP_MAC3_0 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= WR_SUP_MAC3_1 ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC3_0 ; 
                                        
                                end if ;
                                
                        when WR_SUP_MAC3_1 =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= SIM ;
                                        
                                else
                                
                                        nextstate <= WR_SUP_MAC3_1 ; 
                                        
                                end if ;                                
                                
                        when LUT_PROG =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= LUT_PROG_INC ;
                                        
                                else
                                
                                        nextstate <= LUT_PROG ;
                                        
                                end if ;
                                
                        when SIM =>
                        
                                if (rxsim_done='1' and txsim_done='1' and ff_rx_dsav/='1' and (gm_tx_en='0'or m_tx_en='0' or rgm_tx_en='0')) then
                                
                                        nextstate <= END_SIM_WAIT;
                                        
                                else
                        
                                        nextstate <= SIM ;
                                        
                                end if ;
                                
                        when END_SIM_WAIT =>
                        
                                if (sim_cnt_end > 1000) then
                                
                                        nextstate <= RD_PAUSE_RX ;
                                                                                                                                                                                                                        
                                else
                                
                                        nextstate <= END_SIM_WAIT ;
                                        
                                end if ; 
                                
                        when RD_PAUSE_RX =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        if (STAT_CNT_ENA=1) then
                                
                                                nextstate <= RD_FRM_TX ;
                                                
                                        else
                                        
                                                nextstate <= END_SIM ;
                                                
                                        end if ;
                                                                        
                                else
                                
                                        nextstate <= RD_PAUSE_RX ;
                                        
                                end if ; 
                                
                        when RD_FRM_TX =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_FRM_RX ;
                                        
                                else
                                
                                        nextstate <= RD_FRM_TX ;
                                        
                                end if ;
                                
                        when RD_FRM_RX =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_CRC_ERR ;
                                        
                                else
                                
                                        nextstate <= RD_FRM_RX ;
                                        
                                end if ;
                                
                        when RD_CRC_ERR =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_TX_OCTETS ;
                                        
                                else
                                
                                        nextstate <= RD_CRC_ERR ;
                                        
                                end if ;
                                
                        when RD_TX_OCTETS =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_RX_OCTETS ;
                                        
                                else
                                
                                        nextstate <= RD_TX_OCTETS ;
                                        
                                end if ;
                                
                        when RD_RX_OCTETS =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_ALIGN_ERR ;
                                        
                                else
                                
                                        nextstate <= RD_RX_OCTETS ;
                                        
                                end if ;
                                
                        when RD_ALIGN_ERR =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_PAUSE_TX ;
                                        
                                else
                                
                                        nextstate <= RD_ALIGN_ERR ;
                                        
                                end if ;
                                
                        when RD_PAUSE_TX =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_UNICAST ;
                                        
                                else
                                
                                        nextstate <= RD_PAUSE_TX ;
                                        
                                end if ;
                                
                        when RX_UNICAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_MLTCAST ;
                                        
                                else
                                
                                        nextstate <= RX_UNICAST ;
                                        
                                end if ;
                                
                        when RX_MLTCAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_BRDCAST ;
                                        
                                else
                                
                                        nextstate <= RX_MLTCAST ;
                                        
                                end if ;
                                
                        when RX_BRDCAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= TX_FRM_DISCARD ;
                                        
                                else
                                
                                        nextstate <= RX_BRDCAST ;
                                        
                                end if ;
                                
                        when TX_FRM_DISCARD =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= TX_UNICAST ;
                                        
                                else
                                
                                        nextstate <= TX_FRM_DISCARD ;
                                        
                                end if ;
                                
                        when TX_UNICAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= TX_MLTCAST ;
                                        
                                else
                                
                                        nextstate <= TX_UNICAST ;
                                        
                                end if ;
                                
                        when TX_MLTCAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= TX_BRDCAST ;
                                        
                                else
                                
                                        nextstate <= TX_MLTCAST ;
                                        
                                end if ;
                                
                        when TX_BRDCAST =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_FRM_ERR ;
                                        
                                else
                                
                                        nextstate <= TX_BRDCAST ;
                                        
                                end if ;
                                
                        when RX_FRM_ERR =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= TX_FRM_ERR ;
                                        
                                else
                                
                                        nextstate <= RX_FRM_ERR ;
                                        
                                end if ;
                                
                        when TX_FRM_ERR =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_FRM_DROP ;
                                        
                                else
                                
                                        nextstate <= TX_FRM_ERR ;
                                        
                                end if ;
                                
                        when RX_FRM_DROP =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_UNDERSZ_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_FRM_DROP ;
                                        
                                end if ;
                                
                        when RX_UNDERSZ_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_OVERSZ_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_UNDERSZ_FRM ;
                                        
                                end if ;
                                
                        when RX_OVERSZ_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_64_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_OVERSZ_FRM ;
                                        
                                end if ;
                                
                        when RX_64_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_65_127_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_64_FRM ;
                                        
                                end if ;
                                
                        when RX_65_127_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_128_255_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_65_127_FRM ;
                                        
                                end if ;
                                
                        when RX_128_255_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_256_511_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_128_255_FRM ;
                                        
                                end if ;
                                
                        when RX_256_511_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_512_1023_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_256_511_FRM ;
                                        
                                end if ;
                                
                        when RX_512_1023_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_1024_1518_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_512_1023_FRM ;
                                        
                                end if ;
                                
                        when RX_1024_1518_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_1519_X_FRM ;
                                        
                                else
                                
                                        nextstate <= RX_1024_1518_FRM ;
                                        
                                end if ;
                                
                        when RX_1519_X_FRM =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_JABBER ;
                                        
                                else
                                
                                        nextstate <= RX_1519_X_FRM ;
                                        
                                end if ;   
                                
                        when RX_JABBER =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RX_FRAGMENT ;
                                        
                                else
                                
                                        nextstate <= RX_JABBER ;
                                        
                                end if ;
                                
                        when RX_FRAGMENT =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        if (re_read_ena=TRUE) then
                                        
                                                nextstate <= RD_SW_RESET ;
                                                
                                        else
                                
                                                nextstate   <= SW_RESET ;
                                                re_read_ena <= TRUE ;
                                                
                                        end if ; 
                                                                                                                        
                                else
                                
                                        nextstate   <= RX_FRAGMENT ;
                                        
                                end if ;
                                
                        when SW_RESET =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= RD_PAUSE_RX ;
                                                                                        
                                else
                                
                                        nextstate <= SW_RESET ;
                                                                                        
                                end if ;
                                
                        when RD_SW_RESET =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        if (ENA_MAGIC=TRUE and TB_RXFRAMES/=0) then
                                        
                                                nextstate <= WR_ENA_MAGIC ;
                                                
                                        else
                                
                                                nextstate <= END_SIM ;
                                                
                                        end if ;
                                        
                                else
                                
                                        nextstate <= RD_SW_RESET ;
                                        
                                end if ;
                                
                        when WR_ENA_MAGIC =>
                        
                                if (reg_busy='0' and reg_busy'event) then
                                
                                        nextstate <= NODE_SLEEP1 ;
                                                                                        
                                else
                                
                                        nextstate   <= WR_ENA_MAGIC ;
                                                                                        
                                end if ; 
                                
                        when NODE_SLEEP1 =>
                        
                                if (sim_cnt_end=50) then
                                
                                        nextstate <= GEN_MAGIC ;
                                        
                                else
                                
                                        nextstate <= NODE_SLEEP1 ;
                                        
                                end if ;
                                
                        when GEN_MAGIC =>
                        
                                if (gm_ether_gen_done='0') then
                        
                                        nextstate <= NODE_SLEEP2 ;
                                        
                                else
                                
                                        nextstate <= GEN_MAGIC ;
                                        
                                end if ;
                                
                        when NODE_SLEEP2 => 
                        
                                if (reg_wakeup='1') then
                                
                                        nextstate <= NODE_ON ;
                                        
                                else
                                
                                        nextstate <= NODE_SLEEP2 ;
                                        
                                end if ;
                                
                        when NODE_ON =>
                        
                                if (ENA_SLEEP_PIN) then
                                
                                        if (reg_wakeup='0') then
                                        
                                                nextstate <= END_SIM ;
                                                
                                        else
                                        
                                                nextstate <= NODE_ON ;
                                                
                                        end if ;
                                        
                                else
                                
                                        if (reg_busy='0' and reg_busy'event) then
                                
                                                nextstate <= END_SIM ;
                                                                                        
                                        else
                                
                                                nextstate   <= END_SIM1 ;
                                                                                        
                                        end if ;         
                                        
                                end if ; 
                                
                        when END_SIM1 =>
                        
                                if (reg_wakeup='0') then
                                        
                                        nextstate <= END_SIM ;
                                                
                                else
                                        
                                        nextstate <= END_SIM1 ;
                                                
                                end if ;
                                                                                
                        when END_SIM =>
                        
                                nextstate <= END_SIM ;                                                             
                                
                end case ;
                
        end process ;
        
   -- End of Simulation Delay
   -- -----------------------
   
        process(reset, reg_clk)
        begin
        
                if (reset='1') then
                
                        sim_cnt_end <= 0 ;
                        
                elsif (reg_clk='1') and (reg_clk'event) then
                
                        if (nextstate=NODE_SLEEP1) then
                        
                                sim_cnt_end <= sim_cnt_end+1 ;       
                
                        elsif (nextstate=END_SIM_WAIT) then
                        
                                sim_cnt_end <= sim_cnt_end+1 ;
                                
                        else
                        
                                sim_cnt_end <= 0 ;        
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
   -- LUT Table Address and PHY Port Counter
   -- --------------------------------------
   
        process(reset, reg_clk)
        begin
        
                if (reset='1') then
                
                        lut_prog_cnt <= 0 ;
                        
                elsif (reg_clk='1') and (reg_clk'event) then
                
                        if (state=LUT_PROG_INC) then
                        
                                lut_prog_cnt <= lut_prog_cnt+1 ;      
                                                                        
                        end if ;
                        
                end if ;
                
        end process ;
        
    -- Register Interface
    -- ------------------
    
        process
        begin
        
                reg_clk <= '1' ;
                wait for 25 ns ;
                reg_clk <= '0' ;
                wait for 25 ns ;
                
        end process ;
        
        process(reset, reg_clk)
        
                variable hash_code  : std_logic_vector(5 downto 0) ;
                variable mcast_addr : std_logic_vector(47 downto 0) ;
        
        begin
        
                if (reset='1') then
                
                        reg_wr      <= '0' ;
                        reg_rd      <= '0' ;
                        reg_addr    <= (others=>'0') ;
                        reg_data_in <= (others=>'0') ;
                        
                elsif (reg_clk='1') and (reg_clk'event) then
        
                        if (nextstate=READ_VER) then
                
                                reg_wr      <= '0' after 5 ns ;
                                reg_rd      <= '1' after 5 ns ;
                                reg_addr    <= conv_std_logic_vector(0, 8) after 5 ns;
                                reg_data_in <= (others=>'0') after 5 ns; 
                        
                        elsif (nextstate=WR_SCRATCH) then
                
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(1, 8) after 5 ns;
                                reg_data_in <= X"AAAAAAAA" after 5 ns;
                        
                        elsif (nextstate=RD_SCRATCH) then
                
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(1, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=MAC_CONFIG or nextstate=WR_ENA_MAGIC or (nextstate=NODE_ON and ENA_SLEEP_PIN=FALSE)) then
                
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(2, 8) after 5 ns;
                                reg_data_in <= (others=>'0') ;
                                
                           -- Enable Tx and Rx
                           -- ----------------
                           
                                reg_data_in(0) <= '1' after 5 ns;
                                reg_data_in(1) <= '1' after 5 ns;
 
                           -- XON_Gen
                                reg_data_in(2) <= xon_gen after 5 ns;
                       
                           -- Speed Selection
                           -- ---------------
                                
                                if (ETH_SPEED=1000) then
                                
                                        reg_data_in(3) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(3) <= '0' after 5 ns;
                                        
                                end if ;
                                
                                
                           -- Unicast Filtering
                           -- -----------------
                           
                                if (TB_PROMIS_ENA=TRUE) then
                                
                                        reg_data_in(4) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(4) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- Enable Padding
                           -- --------------
                           
                                if (TB_MACPADEN=TRUE) then
                                
                                        reg_data_in(5) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(5) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- CRC Forwarding Enable
                           -- ---------------------
                           
                                if (TB_MACFWDCRC=TRUE) then
                                
                                        reg_data_in(6) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(6) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- Enable Pause Frame Forwarding
                           -- -----------------------------
                           
                                if (TB_MACFWD_PAUSE=TRUE) then 
                                
                                        reg_data_in(7) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(7) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- Ignore Pause Frames
                           -- -------------------
                           
                                if (TB_MACIGNORE_PAUSE=TRUE) then
                                
                                        reg_data_in(8) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(8) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- Source MAC Address Insertion
                           -- ----------------------------
                           
                                if (TB_MACINSERT_ADDR=TRUE and ENABLE_MAC_TXADDR_SET=1) then
                                
                                        reg_data_in(9) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(9) <= '0' after 5 ns;
                                        
                                end if ;

                                
                           -- Enable Half Duplex
                           -- ------------------
                                
                                if (HD_ENA=TRUE and ENABLE_HD_LOGIC=1) then
                                        
                                        reg_data_in(10) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(10) <= '0' after 5 ns;
                                        
                                end if ;
                                
                           -- Internal Loopback
                           -- -----------------
                                
                                if (ENABLE_GMII_LOOPBACK=1 and TB_RXFRAMES=0) then
                                        
                                        reg_data_in(15) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(15) <= '0' after 5 ns;
                                        
                                end if ;                                                                             
                                
                           -- Source MAC Address Selection 
                           -- -----------------------------
                           
                                if (ENABLE_SUP_ADDR=1) then
                                        
                                        reg_data_in(18 downto 16) <= conv_std_logic_vector(TB_ADDR_SEL, 3) after 5 ns;
                                        
                                else
                                
                                        reg_data_in(18 downto 16) <= "000" after 5 ns;
                                        
                                end if ;                                                                           
                                
                                reg_data_in(14) <= '0' ;
                                
                           -- Magic Packet Enable
                           -- -------------------
                                
                                if (ENA_MAGIC=TRUE and ENABLE_MAGIC_DETECT=1) then
                                
                                        reg_data_in(19) <= '1' ;
                                        
                                else
                                
                                        reg_data_in(19) <= '0' ;
                                        
                                end if ;
                                
                                if (nextstate=WR_ENA_MAGIC and ENA_SLEEP_PIN=FALSE) then
                                
                                        reg_data_in(20) <= '1' ;
                                        
                                else
                                
                                        reg_data_in(20) <= '0' ;
                                        
                                end if ;  
                                
                                reg_data_in(21) <= '0' ; 
                                
                           -- XOFF_Gen
                                reg_data_in(22) <= xoff_gen after 5 ns;
                                        
                           -- 10Mbps Speed Selection
                           -- ---------------
                                
                                if (ETH_SPEED=10) then
                                        
                                        reg_data_in(25) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(25) <= '0' after 5 ns;
                                        
                                end if ;                                                                                  

               -- Discard any errored in received frames
                           -- ---------------
                           
                                if (TB_MACRX_ERR_DISC=1) then
                                
                                        reg_data_in(26) <= '1' after 5 ns;
                                        
                                else
                                
                                        reg_data_in(26) <= '0' after 5 ns;
                                        
                                end if ;                                                                                  
                                
                        elsif (nextstate=WR_MAC1) then
                        
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(3, 8) after 5 ns;
                                reg_data_in <= mac_addr(31 downto 0) after 5 ns;
                                
                        elsif (nextstate=WR_MAC2) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(4, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= mac_addr(47 downto 32) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_IPG_LEN) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(23, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(TB_IPG_LENGTH, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns; 
                                
                        elsif (nextstate=WR_SUP_MAC0_0) then
                        
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(192, 8) after 5 ns;
                                reg_data_in <= sup_mac_addr_0(31 downto 0)   after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC0_1) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(193, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= sup_mac_addr_0(47 downto 32) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC1_0) then
                        
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(194, 8) after 5 ns;
                                reg_data_in <= sup_mac_addr_1(31 downto 0)   after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC1_1) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(195, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= sup_mac_addr_1(47 downto 32) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC2_0) then
                        
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(196, 8) after 5 ns;
                                reg_data_in <= sup_mac_addr_2(31 downto 0)   after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC2_1) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(197, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= sup_mac_addr_2(47 downto 32) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC3_0) then
                        
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(198, 8) after 5 ns;
                                reg_data_in <= sup_mac_addr_3(31 downto 0)   after 5 ns;
                                
                        elsif (nextstate=WR_SUP_MAC3_1) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(199, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= sup_mac_addr_3(47 downto 32) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_FRM_LENGTH) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(5, 8) after 5 ns;
                                reg_data_in(13 downto 0)  <= conv_std_logic_vector(TB_MACLENMAX, 14) after 5 ns; 
                                reg_data_in(31 downto 14) <= (others=>'0') after 5 ns;  
                                
                        elsif (nextstate=WR_PAUSE_QUANTA) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(6, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(TB_MACPAUSEQ, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns; 
                                
                        elsif (nextstate=WR_RX_SE) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(7, 8) after 5 ns;
                                reg_data_in               <= conv_std_logic_vector(RX_FIFO_SECTION_EMPTY, 32) after 5 ns; 
                                
                        elsif (nextstate=WR_RX_SF) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(8, 8) after 5 ns;
                                reg_data_in               <= conv_std_logic_vector(RX_FIFO_SECTION_FULL, 32) after 5 ns;
                                
                        elsif (nextstate=WR_TX_SE) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(9, 8) after 5 ns;
                                reg_data_in               <= conv_std_logic_vector(TX_FIFO_SECTION_EMPTY, 32) after 5 ns; 
                                
                        elsif (nextstate=WR_TX_SF) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(10, 8) after 5 ns;
                                reg_data_in               <= conv_std_logic_vector(TX_FIFO_SECTION_FULL, 32) after 5 ns;
                                
                        elsif (nextstate=WR_RX_AE) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(11, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(RX_FIFO_AE, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_RX_AF) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(12, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(RX_FIFO_AF, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_TX_AE) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(13, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(TX_FIFO_AE, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_TX_AF) then
                        
                                reg_wr                    <= '1' after 5 ns;
                                reg_rd                    <= '0' after 5 ns;
                                reg_addr                  <= conv_std_logic_vector(14, 8) after 5 ns;
                                reg_data_in(15 downto 0)  <= conv_std_logic_vector(TX_FIFO_AF, 16) after 5 ns; 
                                reg_data_in(31 downto 16) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_MDIO_ADDR0) then
                        
                                reg_wr                   <= '1' after 5 ns;
                                reg_rd                   <= '0' after 5 ns;
                                reg_addr                 <= conv_std_logic_vector(15, 8) after 5 ns;
                                reg_data_in(4 downto 0)  <= conv_std_logic_vector(TB_MDIO_ADDR0, 5) after 5 ns; 
                                reg_data_in(31 downto 5) <= (others=>'0') after 5 ns;
                                
                        elsif (nextstate=WR_MDIO_ADDR1) then
                        
                                reg_wr                   <= '1' after 5 ns;
                                reg_rd                   <= '0' after 5 ns;
                                reg_addr                 <= conv_std_logic_vector(16, 8) after 5 ns;
                                reg_data_in(4 downto 0)  <= conv_std_logic_vector(TB_MDIO_ADDR1, 5) after 5 ns; 
                                reg_data_in(31 downto 5) <= (others=>'0') after 5 ns;   
                                
                        elsif (nextstate=WRITE_MDIO0) then
                
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(128, 8) after 5 ns;
                                reg_data_in <= X"AAAAAAAA" after 5 ns; 
                                
                        elsif (nextstate=READ_MDIO0) then
                
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(128, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;                                                                                          
                                
                        elsif (nextstate=WRITE_MDIO1) then
                
                                reg_wr      <= '1' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(160, 8) after 5 ns;
                                reg_data_in <= X"55555555" after 5 ns; 
                                
                        elsif (nextstate=READ_MDIO1) then
                
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(160, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=LUT_PROG) then
                        
                                mcast_addr :=  MCAST_ADDRESSLIST(lut_prog_cnt);
        
                                for i in 0 to 5 loop
               
                                        hash_code(i) := xor_reduce(mcast_addr((i*8)+7 downto i*8)) ;
                       
                                end loop ;
                        
                                reg_wr               <= '1' after 5 ns;
                                reg_rd               <= '0' after 5 ns;
                                reg_addr(7 downto 6) <= "01" after 5 ns;
                                reg_addr(5 downto 0) <= hash_code after 5 ns; 
                                reg_data_in          <= X"00000001" after 5 ns;
                                
                        elsif (nextstate=RD_FRM_TX) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(26, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RD_FRM_RX) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(27, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RD_CRC_ERR) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(28, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RD_ALIGN_ERR) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(29, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RD_TX_OCTETS) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(30, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RD_RX_OCTETS) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(31, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RD_PAUSE_TX) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(32, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RD_PAUSE_RX) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(33, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RX_UNICAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(36, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RX_MLTCAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(37, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=RX_BRDCAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(38, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=TX_FRM_DISCARD) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(39, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=TX_UNICAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(40, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=TX_MLTCAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(41, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=TX_BRDCAST) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(42, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=RX_FRM_ERR) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(34, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=TX_FRM_ERR) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(35, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_FRM_DROP) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(43, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=RX_UNDERSZ_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(46, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;   
                                
                        elsif (nextstate=RX_OVERSZ_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(47, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RX_64_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(48, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_65_127_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(49, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;  
                                
                        elsif (nextstate=RX_128_255_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(50, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_256_511_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(51, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_512_1023_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(52, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_1024_1518_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(53, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_1519_X_FRM) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(54, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;
                                
                        elsif (nextstate=RX_JABBER) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(55, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                
                        elsif (nextstate=RX_FRAGMENT) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(56, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns; 
                                        
                        elsif (nextstate=SW_RESET) then
                
                                reg_wr          <= '1' after 5 ns;
                                reg_rd          <= '0' after 5 ns;
                                reg_addr        <= conv_std_logic_vector(2, 8) after 5 ns;
                                
                                reg_data_in(12 downto 0)  <= (others=>'0') ;
                                reg_data_in(13)           <= '1' ;
                                reg_data_in(31 downto 14) <= (others=>'0') ;
                                
                        elsif (nextstate=RD_SW_RESET) then
                        
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '1' after 5 ns;
                                reg_addr    <= conv_std_logic_vector(2, 8) after 5 ns;
                                reg_data_in <= X"00000000" after 5 ns;                                                     
                        
                        else
                
                                reg_wr      <= '0' after 5 ns;
                                reg_rd      <= '0' after 5 ns;
                                reg_addr    <= (others=>'0') after 5 ns;
                                reg_data_in <= (others=>'0') after 5 ns;
                        
                        end if ;
                        
                end if ;
                                
        end process ;
        
   -- Colision Detection
   -- ------------------
        
        process(m_rx_col)
        
                variable ln : line ;
                
        begin
        
                if (m_rx_col='1' and m_rx_col'event and m_tx_en='1') then
                
                        writeline(OUTPUT, ln); 
                        write(ln, NOW );
                        write(ln, string'(" - Collision, Frame Re-Transmitted after Back Off Period"));
                        writeline(OUTPUT, ln); 
                        
                end if ;
                
        end process ; 
        
    -- Version
    -- -------

        process(reg_clk)
        
                variable ln : line ;
                
        begin
        
                if (reg_clk='0' and reg_clk'event) then
        
                        if (state=READ_VER and reg_busy='0') then
                
                                                                        
                                        write(ln, string'("   - Altera Design Version : ")) ;
                                        write(ln, conv_integer(reg_data_out(15 downto 8))) ;
                                        write(ln, string'(".")) ;                               
                                        write(ln, conv_integer(reg_data_out(7 downto 0))) ;
                                        writeline(output, ln) ; 
                                        write(ln, string'(" ")) ;                               
                                        writeline(output, ln) ;
                                        
                                
                                
                                if (ETH_SPEED=1000 and HD_ENA=TRUE) then
                                
                                        write(ln, string'(" Error: Half Duplex must Disabled for Gigabit Operation")) ;  
                                        writeline(output, ln) ;
                                        write(ln, string'(" ")) ;
                                        writeline(output, ln) ;
                                        assert false report "Simulation Set Up Error" severity failure ;
                                        
                                end if ;
                                
                                if (HD_ENA=TRUE and ENABLE_HD_LOGIC=0) then
                                
                                        write(ln, string'(" Error: Half Duplex Logic is Disabled, Design Operates only Support Full Duplex Operation")) ;  
                                        writeline(output, ln) ;
                                        write(ln, string'(" ")) ;
                                        writeline(output, ln) ;
                                        assert false report "Design Set Up Error" severity failure ;
                                        
                                end if ;
                                
                                if (ENABLE_SUP_ADDR=1 and (TB_ADDR_SEL=1 or TB_ADDR_SEL=2 or TB_ADDR_SEL=3)) then
                                
                                        write(ln, string'(" Error: Address Selection must be 0, 4, 5, 6 or 7")) ;  
                                        writeline(output, ln) ;
                                        write(ln, string'(" ")) ;
                                        writeline(output, ln) ;
                                        assert false report "Design Set Up Error" severity failure ;
                                        
                                end if ;
                                
                                if (TB_MACPADEN=TRUE and TB_MACFWDCRC=TRUE) then
                                
                                        write(ln, string'(" Warning: Setting Padding Termination and Forward CRC Options may Results in Simulation Errors")) ;  
                                        writeline(output, ln) ;
                                        
                                end if ;
                                
                        end if ;
                        
                end if ;
                
        end process ;
        
   -- Simulation Info
   -- --------------- 
        
        process(mff_is_pause) 
        
                variable ln : line ;
                       
        begin
        
                if (mff_is_pause='1') then                              
                        
                        write(ln, NOW) ;
                        write(ln, string'(" - Pause Frame Received on FIFO Interface")) ; 
                        writeline(output, ln) ;
                        
                end if ;       
                                                      
        end process ;     
        
        process(xoff_gen)
        
                variable ln    : line;        
                file     log   : text open write_mode is LOG_FILE;
        
        begin
        
           -- Forced Xoff Frame tranmsitted
           -- -----------------------------
        
                if (xoff_gen='1' and xoff_gen'event) then
        
                        write(ln, NOW );
                        write(ln, string'(" - Xoff Pause Frame Generation Requested with Command Pin"));
                        writeline_log(log,ln);
                        write(ln, string'(" ")) ;                              
                        writeline(output, ln) ;

                end if; 
                
        end process ; 
        
        process(xon_gen)
        
                variable ln    : line;        
                file     log   : text open write_mode is LOG_FILE;
        
        begin
        
           -- Forced Xoff Frame tranmsitted
           -- -----------------------------
        
                if (xon_gen='1' and xon_gen'event) then
        
                        write(ln, NOW );
                        write(ln, string'(" - Xon Pause Frame Generation Requested with Command Pin"));
                        writeline_log(log,ln);

                end if; 
                
        end process ;            
        
    -- Scratch Register
    -- ----------------
    
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_SCRATCH ) then
                
                        write(ln, string'("   - Write Scratch : 0xaaaaaaaa")) ;
                        writeline(output, ln) ;                              
                        
                end if ;
                
        end process ;
        
        process(reg_clk)
        
                variable ln : line ;
                
        begin
        
                if (reg_clk='0' and reg_clk'event) then
                
                        if (state=RD_SCRATCH and reg_busy='0' ) then
                
                                write(ln, string'("   - Read Scratch: 0x")) ;
                                WRITE_HEX(ln, reg_data_out) ;
                                writeline(output, ln) ;
                                write(ln, string'(" ")) ;                              
                                writeline(output, ln) ;
                                readback_scratch <= reg_data_out;
                        end if ;
                        
                end if ;
                
        end process ;
                        
    -- Core Configuration
    -- ------------------
    
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=MAC_CONFIG ) then
                
                        write(ln, string'("   - MAC Configuration")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;                            
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;  
        

        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_MAC1 ) then
                
                        write(ln, string'("   - Write MAC Address")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;                            
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;

        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_SUP_MAC0_0 ) then
                
                        write(ln, string'("   - Setting Supplemental MAC Addresses")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;                            
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;         
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=LUT_PROG and lut_prog_cnt=1) then
                
                        write(ln, string'("   - Load Hash Table")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;                             
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;   
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_FRM_LENGTH ) then
                
                        write(ln, string'("   - Write Maximum Frame Length")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;                             
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ; 
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_PAUSE_QUANTA ) then
                
                        write(ln, string'("   - Write Pause Quanta")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;                             
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;  
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_RX_SE ) then
                
                        write(ln, string'("   - Setting FIFO thresholds")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                              
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;    
        
    -- MDIO Test
    -- ---------
    
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_MDIO_ADDR0) then
                
                        write(ln, string'("   - Programming MDIO Base Address 0")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;                             
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ; 
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_MDIO_ADDR1) then
                
                        write(ln, string'("   - Programming MDIO Base Address 1")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;                              
                        writeline(output, ln) ;
                        
                end if ;
                
        end process ;  
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WRITE_MDIO0) then
                
                        write(ln, string'("   - Write MDIO Slave 0 Register 0 : 0xaaaa")) ;
                        writeline(output, ln) ;                              
                        
                end if ;
                
        end process ; 
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WRITE_MDIO1) then
                
                        write(ln, string'("   - Write MDIO Slave 1 Register 0 : 0x5555")) ;
                        writeline(output, ln) ;                              
                        
                end if ;
                
        end process ; 
        
        process(reg_clk)
        
                variable ln : line ;
                
        begin
        
                if (reg_clk='1' and reg_clk'event) then
        
                        if (state=READ_MDIO0 and reg_busy='0') then
                
                                write(ln, string'("   - Read MDIO Slave 0 Register 0 : 0x")) ;
                                write_hex(ln, (reg_data_out(15 downto 0))) ;
                                writeline(output, ln) ; 
                                write(ln, string'(" ")) ;                             
                                writeline(output, ln) ;
                                readback_MDIO0_addr0(15 downto 0) <= reg_data_out(15 downto 0);
                        end if ;
                        
                end if ;
                
        end process ;  
        
        process(reg_clk)
        
                variable ln : line ;
                
        begin
        
                if (reg_clk='1' and reg_clk'event) then
        
                        if (state=READ_MDIO1 and reg_busy='0') then
                
                                write(ln, string'("   - Read MDIO Slave 1 Register 0 : 0x")) ;
                                write_hex(ln, (reg_data_out(15 downto 0))) ;
                                writeline(output, ln) ;  
                                write(ln, string'(" ")) ;                            
                                writeline(output, ln) ;
                                readback_MDIO1_addr0(15 downto 0) <= reg_data_out(15 downto 0);
                        end if ;
                        
                end if ;
                
        end process ;  
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=SIM) then
                
                        write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;
                        writeline(output, ln) ;                               
                        
                end if ;
                
                if (state=END_SIM) then
                
                        write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ;  
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=SW_RESET) then
                
                        write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;
                        writeline(output, ln) ;  
                        write(ln, string'("   - Clearing Statistics")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;
                        writeline(output, ln) ;                                                    
                        write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                        writeline(output, ln) ;
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ; 
        
   -- Magic Packet Detection
   -- ----------------------
           
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_ENA_MAGIC) then
                
                        write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                        writeline(output, ln) ; 
                        write(ln, string'(" ")) ;
                        writeline(output, ln) ;  
                        write(ln, string'("   - Magic Packet Detection Test")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ; 
        
        process(magic_sleep_n)
        
                variable ln : line ;
                
        begin
        
                if (magic_sleep_n='0' and magic_sleep_n'event) then
                
                        write(ln, string'("       Set Core in Sleep Mode with External Pin")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
                if (magic_sleep_n='1' and magic_sleep_n'event) then
                
                        write(ln, string'("       Set Core in Normal Mode with External Pin")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ;  
        
        process(state)
        
                variable ln : line ;
                
        begin
        
                if (state=WR_ENA_MAGIC) then
                
                        write(ln, string'("       Set Core in Sleep Mode with Register Access")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
                if (state=NODE_ON) then
                
                        write(ln, string'("       Set Core in Normal Mode with Register Access")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ; 
        
        process(reg_wakeup)
        
                variable ln : line ;
                
        begin
        
                if (reg_wakeup='1' and reg_wakeup'event) then
                
                        write(ln, string'("       Magic Packet Detected, Wakeup Request Asserted")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
                if (reg_wakeup='0' and reg_wakeup'event and NOW>100 ns) then
                
                        write(ln, string'("       Wakeup Request De-Asserted")) ;
                        writeline(output, ln) ;  
                        write(ln, string'(" ")) ;  
                        writeline(output, ln) ;                               
                        
                end if ;
                
        end process ;          
        

   --  register test status
   --  -----------------------
   process (reset,state,nextstate)
       variable ln : line ;
   begin

       if (reset = '1') then
          register_test <= 0;   
       else
          if (nextstate = END_SIM_WAIT and state = SIM) then
                -- expected scratch register readback is 0xaaaaaaaa
                -- expected MDIO slave 0 address 0 register readback is 0x0000aaaa
                -- expected MDIO slave 1 address 0 register readback is 0x00005555
                --
                if (readback_scratch /= x"aaaaaaaa" and ENABLE_MACLITE = 0) then
                     write(ln, string'("      Register test failed on SCRATCH registers")) ;
                     writeline(output, ln) ;  
                     register_test <= 1;
                end if;

                 if (TB_MDIO_SIMULATION=TRUE and  ENABLE_MDIO = 1) then
                   if ( (readback_MDIO0_addr0 /= x"aaaa") or (readback_MDIO1_addr0/= x"5555") ) then

                     write(ln, string'("      Register test failed on MDIO registers")) ;
                     writeline(output, ln) ;  
                     register_test <= 1;

                   end if;
                 end if;
          end if;
       end if;   
   end process;

        
    -- End of Simulation Status
    -- ------------------------
    
        process( rx_clk_tb, reset ) 

                variable ln             : line;        
                file log                : text open write_mode is LOG_FILE;   
                variable rx_no_errs     : boolean;
                variable tx_no_errs     : boolean;
        
        begin
    
                if( reset='1' ) then
    
                        promis_en_dly <= '0';
                        ff_rx_rdy_dly <= '1';

                elsif( rx_clk_tb='1' and rx_clk_tb'event ) then

                        if( sim_stop='1' ) then
                        
                                if (TB_MACPADEN=TRUE) then

                    if(STAT_CNT_ENA = 1 and ENABLE_MAC_FLOW_CTRL=1 and ENABLE_MAC_RX_VLAN=1 and ENABLE_MAC_TX_VLAN=1) then
                                        rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_payload_err_sent     = rx_payload_err_rcvd) and
                                                      (rx_pause_sent           = rx_pause_rcvd) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_sent            = rx_vlan_rcvd) and
                                                      (rx_stack_vlan_sent      = rx_stack_vlan_rcvd) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);
                    end if;
                    
                    if(STAT_CNT_ENA = 1 and ENABLE_MAC_FLOW_CTRL=0 and ENABLE_MAC_RX_VLAN=1 and ENABLE_MAC_TX_VLAN=1) then
                                    rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_payload_err_sent     = rx_payload_err_rcvd) and
                                                      (rx_pause_rcvd           = 0) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_sent            = rx_vlan_rcvd) and
                                                      (rx_stack_vlan_sent      = rx_stack_vlan_rcvd) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);                      
                    end if;

                    
                    if(STAT_CNT_ENA = 1 and ENABLE_MAC_FLOW_CTRL=0 and ENABLE_MAC_RX_VLAN=0 and ENABLE_MAC_TX_VLAN=0) then
                                    rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_payload_err_sent     = rx_payload_err_rcvd) and
                                                      (rx_pause_rcvd           = 0) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_rcvd            = 0) and
                                                      (rx_stack_vlan_rcvd      = 0) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);                      
                    end if;

                    if(STAT_CNT_ENA = 1 and ENABLE_MAC_FLOW_CTRL=1 and ENABLE_MAC_RX_VLAN=0 and ENABLE_MAC_TX_VLAN=0) then
                                    rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_payload_err_sent     = rx_payload_err_rcvd) and
                                                      (rx_pause_sent           = rx_pause_rcvd) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_rcvd            = 0) and
                                                      (rx_stack_vlan_rcvd      = 0) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);                      
                    end if;
                    
                    if(STAT_CNT_ENA = 0  and ENABLE_MAC_RX_VLAN=1 and ENABLE_MAC_TX_VLAN=1) then
                                    rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_payload_err_sent     = rx_payload_err_rcvd) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_sent            = rx_vlan_rcvd) and
                                                      (rx_stack_vlan_sent      = rx_stack_vlan_rcvd) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);                      
                    end if;
                    
                    if(STAT_CNT_ENA = 0  and ENABLE_MAC_RX_VLAN=0 and ENABLE_MAC_TX_VLAN=0) then
                                    rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_payload_err_sent     = rx_payload_err_rcvd) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_rcvd            = 0) and
                                                      (rx_stack_vlan_rcvd      = 0) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);                      
                    end if;
                              
                                                      
                                else
                                
                
                    if(STAT_CNT_ENA = 1 and ENABLE_MAC_FLOW_CTRL=1 and ENABLE_MAC_RX_VLAN=1 and ENABLE_MAC_TX_VLAN=1) then
                                        rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_pause_sent           = rx_pause_rcvd) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_sent            = rx_vlan_rcvd) and
                                                      (rx_stack_vlan_sent      = rx_stack_vlan_rcvd) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);
                    end if;
                    
                    if(STAT_CNT_ENA = 1 and ENABLE_MAC_FLOW_CTRL=0 and ENABLE_MAC_RX_VLAN=1 and ENABLE_MAC_TX_VLAN=1) then
                                        rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_pause_rcvd           = 0) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_sent            = rx_vlan_rcvd) and
                                                      (rx_stack_vlan_sent      = rx_stack_vlan_rcvd) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);
                    end if;

                    
                    if(STAT_CNT_ENA = 1 and ENABLE_MAC_FLOW_CTRL=0 and ENABLE_MAC_RX_VLAN=0 and ENABLE_MAC_TX_VLAN=0) then
                                        rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_pause_rcvd           = 0) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_rcvd            = 0) and
                                                      (rx_stack_vlan_rcvd      = 0) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);  
                    end if;

                    if(STAT_CNT_ENA = 1 and ENABLE_MAC_FLOW_CTRL=1 and ENABLE_MAC_RX_VLAN=0 and ENABLE_MAC_TX_VLAN=0) then
                                        rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_pause_sent           = rx_pause_rcvd) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_rcvd            = 0) and
                                                      (rx_stack_vlan_rcvd      = 0) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);          
                    end if;
                    
                    if(STAT_CNT_ENA = 0  and ENABLE_MAC_RX_VLAN=1 and ENABLE_MAC_TX_VLAN=1) then
                                        rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_sent            = rx_vlan_rcvd) and
                                                      (rx_stack_vlan_sent      = rx_stack_vlan_rcvd) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);
                    end if;
                    
                    if(STAT_CNT_ENA = 0  and ENABLE_MAC_RX_VLAN=0 and ENABLE_MAC_TX_VLAN=0) then
                                        rx_no_errs := (rx_good_sent            = rx_good_rcvd) and
                                                      (rx_align_err_sent       = rx_align_err_rcvd) and
                                                      (rx_discard_sent         = rx_discard_rcvd) and
                                                      (rx_wrong_status_sent    = rx_wrong_status_rcvd) and
                                                      (rx_vlan_rcvd            = 0) and
                                                      (rx_stack_vlan_rcvd      = 0) and
                                                      (rx_wrong_mac_sent       = rx_wrong_mac_rcvd) and
                                                      (rx_multicast_sent_total = rx_multicast_rcvd + rx_multicast_denied);
                    end if;
                                
                                                      
                                end if ;        
                                              
                           -- Loopback Simulation
                           -- -------------------

                                if( TB_RXFRAMES=0 ) then
                
                                        rx_no_errs := (rx_good_rcvd = tx_good_rcvd) and      -- THE RX monitor should have received all the TX monitor got
                                                      (rx_payload_err_rcvd = tx_payload_err_rcvd);
                                
                                end if;
                                
                                if (ENA_INVERT_LB=FALSE) then

                                        tx_no_errs := (((tx_good_sent      = tx_good_rcvd) and TB_TX_FF_ERR=FALSE) or ((tx_good_sent = tx_phy_err_rcvd) and TB_TX_FF_ERR=TRUE))and
                                              (tx_payload_err_sent = tx_payload_err_rcvd) and
                                              (tx_align_err_rcvd   = 0) and
                                              (tx_crc_err_rcvd     = 0) and
                                              (tx_pause_err_rcvd   = 0) and
                          (tx_vlan_sent = tx_vlan_rcvd) and
                              (tx_stack_vlan_sent = tx_stack_vlan_rcvd) and 
                                              (tx_wrong_src_rcvd   = 0);
                                              
                                else
                                
                                        tx_no_errs := (tx_good_rcvd = rx_good_sent) and
                                              (tx_align_err_rcvd   = 0) and
                                              (tx_crc_err_rcvd     = rx_crc_err_sent) and
                                              (tx_pause_err_rcvd   = 0) ;
                                              
                                end if ;
                                
                                if( TB_RXFRAMES > 0) then
                                                        
                                        write(ln, string'(" Statistics MAC Rx Path") );
                    
                                        writeline(output, ln) ;
                                        writeline(output, ln) ;
                                        write(ln, string'(" "));
                                        writeline(output, ln) ;
                
                                        write(ln, string'("     - Frames sent in RX path total: "));
                                        write(ln, rxframe_cnt); 
                                        writeline(output, ln) ;
                
                                        write(ln, string'("      - Broadcast sent total: "));
                                        write(ln, rx_broadcast_sent); 
                                        writeline(output, ln) ;
                                        
                                        write(ln, string'("      - Broadcast received: "));
                                        write(ln, rx_broadcast_rcvd); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - wrong_mac_sent (good during promiscuous): "));
                                        write(ln, rx_wrong_mac_sent); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - wrong_mac_rcvd: "));
                                        write(ln, rx_wrong_mac_rcvd); 
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - multicast_sent_total: "));
                                        write(ln, rx_multicast_sent_total); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - multicast_sent (good): "));
                                        write(ln, rx_multicast_sent); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - multicast_rcvd (good): "));
                                        write(ln, rx_multicast_rcvd); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - multicast_denied: "));
                                        write(ln, rx_multicast_denied); 
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - good_sent: ") );
                                        write(ln, rx_good_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - good_rcvd: ") );
                                        write(ln, rx_good_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - wrong_status_sent: ") );
                                        write(ln, rx_wrong_status_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - wrong_status_rcvd: ") );
                                        write(ln, rx_wrong_status_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - pause_sent: ") );
                                        write(ln, rx_pause_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - pause_rcvd: ") );
                                        write(ln, rx_pause_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - vlan_sent: ") );
                                        write(ln, rx_vlan_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - vlan_rcvd: ") );
                                        write(ln, rx_vlan_rcvd);
                                        writeline(output, ln) ;
                                        
                                        write(ln, string'("      - stack_vlan_sent: ") );
                                        write(ln, rx_stack_vlan_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - stack_vlan_rcvd: ") );
                                        write(ln, rx_stack_vlan_rcvd);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - vlan_wrong_type_sent: ") );
                                        write(ln, rx_vlan_wrong_type_sent);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - discard_sent: ") );
                                        write(ln, rx_discard_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - discard_rcvd: ") );
                                        write(ln, rx_discard_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - align_err_sent: ") );
                                        write(ln, rx_align_err_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - align_err_rcvd: ") );
                                        write(ln, rx_align_err_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - length_err_rcvd: ") );
                                        write(ln, rx_length_err_rcvd);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - length_mismatch_rcvd: ") );
                                        write(ln, rx_length_mismatch_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - crc_err_sent: ") );
                                        write(ln, rx_crc_err_sent);
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - crc_err_rcvd: ") );
                                        write(ln, rx_crc_err_rcvd);
                                        writeline(output, ln) ;
                                        
                                        if (TB_MACPADEN=TRUE) then
    
                                                write(ln, string'("      - payload_err_sent: ") );
                                                write(ln, rx_payload_err_sent);
                                                writeline(output, ln) ;
                    
                                                write(ln, string'("      - payload_err_rcvd: ") );
                                                write(ln, rx_payload_err_rcvd);
                                                writeline(output, ln) ;
                                                
                                        end if ;

                                        write(ln, string'("      - fifo_overflow_rcvd: ") );
                                        write(ln, rx_fifo_overflow_rcvd);
                                        writeline(output, ln) ;
    
                                        write(ln, string'("      - rx_gmii_err_sent: ") );
                                        write(ln, rx_gmii_err_sent);
                                        writeline(output, ln) ;

                                        write(ln, string'("      - rx_gmii_err_rcvd: ") );
                                        write(ln, rx_gmii_err_rcvd);
                                        writeline(output, ln) ;
                    
                                        if (HD_ENA) then
                    
                                                write(ln, string'("      - rx_col_sent: ") );
                                                write(ln, rx_col_sent);
                                                writeline(output, ln) ; 
                    
                                                write(ln, string'("      - rx_col_rcvd: ") );
                                                write(ln, rx_col_rcvd);
                                                writeline(output, ln) ;  
                        
                                        end if ;      

                                end if;

                                if( TB_TXFRAMES > 0) then
                                
                                        write(ln, string'("  "));
                                        writeline(output, ln) ;
                    
                                        write(ln, string'(" Statistics MAC Tx Path") );
                    
                                        writeline(output, ln) ;
                                        write(ln, string'("  "));
                                        writeline(output, ln) ;

                                        write(ln, string'("     - Frames sent in TX path total: "));
                                        write(ln, txframe_cnt); 
                                        writeline(output, ln) ;

                                        if (TB_TX_FF_ERR=FALSE) then
                                        
                                                write(ln, string'("      - tx_good_sent: "));
                                                write(ln, tx_good_sent); 
                                                writeline(output, ln) ;
                                                
                                        else
                                        
                                                write(ln, string'("      - tx_error_sent: "));
                                                write(ln, tx_good_sent); 
                                                writeline(output, ln) ;
                                                
                                        end if ;        

                                        write(ln, string'("      - tx_good_rcvd: "));
                                        write(ln, tx_good_rcvd); 
                                        writeline(output, ln) ;

                                        write(ln, string'("      - tx_align_err_rcvd: "));
                                        write(ln, tx_align_err_rcvd); 
                                        writeline(output, ln) ;

                                        write(ln, string'("      - tx_crc_err_rcvd: "));
                                        write(ln, tx_crc_err_rcvd); 
                                        writeline(output, ln) ;

                                        write(ln, string'("      - tx_vlan_sent: "));
                                        write(ln, tx_vlan_sent); 
                                        writeline(output, ln) ;

                                        write(ln, string'("      - tx_vlan_rcvd: "));
                                        write(ln, tx_vlan_rcvd); 
                                        writeline(output, ln) ;
                                        
                                        write(ln, string'("      - tx_stack_vlan_sent: "));
                                        write(ln, tx_stack_vlan_sent); 
                                        writeline(output, ln) ;

                                        write(ln, string'("      - tx_stack_vlan_rcvd: "));
                                        write(ln, tx_stack_vlan_rcvd); 
                                        writeline(output, ln) ;

                                        write(ln, string'("      - tx_phy_err_rcvd: "));
                                        write(ln, tx_phy_err_rcvd); 
                                        writeline(output, ln) ;

                                        write(ln, string'("      - payload_err_sent: "));
                                        write(ln, tx_payload_err_sent); 
                                        writeline(output, ln) ;

                                        write(ln, string'("      - payload_err_rcvd: "));
                                        write(ln, tx_payload_err_rcvd); 
                                        writeline(output, ln) ;
                                        
                                        if (ENA_INVERT_LB=FALSE) then

                                                write(ln, string'("      - wrong src MAC address: "));
                                                write(ln, tx_wrong_src_rcvd); 
                                                writeline_log(log,ln);
                                                
                                        end if ;

                                end if; -- TB_TXFRAMES


                                write(ln, string'("      - tx_pause_rcvd: "));         -- Pause can be received in both cases
                                write(ln, tx_pause_rcvd); 
                                writeline(output, ln) ;

                                write(ln, string'("      - tx_pause_err_rcvd: "));
                                write(ln, tx_pause_err_rcvd); 
                                writeline(output, ln) ;

                                if(TB_RXFRAMES=0) then
                    
                                        write(ln, string'(" ")); 
                                        writeline(output, ln) ;
                                        
                                        write(ln, string'("  Statistics MAC Rx Path - Loopback Test")); 
                                        writeline(output, ln) ;
                                        
                                        write(ln, string'(" ")); 
                                        writeline(output, ln) ;
                    
                                        write(ln, string'("      - rx_good_rcvd: ") );
                                        write(ln, rx_good_rcvd);
                                        writeline(output, ln) ;

                                        write(ln, string'("      - rx_fifo_overflow_rcvd: ") );
                                        write(ln, rx_fifo_overflow_rcvd);
                                        writeline(output, ln) ;

                                        write(ln, string'("      - rx_payload_err_rcvd: ") );
                                        write(ln, rx_payload_err_rcvd);
                                        writeline(output, ln) ;
                        
                                        write(ln, string'("      - rx_crc_err_rcvd: ") );
                                        write(ln, rx_crc_err_rcvd);
                                        writeline(output, ln) ;

                                        if( tx_pause_rcvd=0 and TB_TRIGGERXOFF>0) then

                                                write(ln, string'("ERROR: Pause Frame Generation (pin pause_gen) had no effect") );
                                                writeline(output, ln) ;
                    
                                        end if;
                    
                                        writeline(output, ln) ; 
                                        write(ln, string'(" ")); 
                                        writeline(output, ln) ;

                                        if (rx_no_errs = false or register_test /= 0) then 
                                                write(ln, string'("-- Loopback Simulation Ended with Error(s) !"));
                                        else
                                          write(ln, string'("-- Loopback Simulation Ended with no Error"));
                                        end if;
                                        writeline(output, ln) ;

                    
                                end if;
                                

                                if(TB_RXFRAMES>0) then
                                        writeline(output, ln) ; 
                                write(ln, string'(" ")); 
                                writeline(output, ln) ;

                                        if (rx_no_errs = false or tx_no_errs=false or register_test /= 0) then 
                                                write(ln, string'("-- Simulation Ended with Error(s) !"));
                                        else
                                          write(ln, string'("-- Simulation Ended with no Error"));
                                        end if;
                                writeline(output, ln) ; 

                                end if;

                                
                                write(ln, string'(" ")) ; 
                                writeline(output, ln) ; 
                                write(ln, string'("- ---------------------------------------------------------------------------------------- -")) ;
                                writeline(output, ln) ;
                                assert false report "End of Simulation - Break" severity failure  ;


                        end if;
            

                   -- Inform of Unexpected Signals Behaviour
                   -- --------------------------------------
        
                        if( expect2='0' and TB_RXFRAMES/=0) then  -- RX test is active and nothing is expected to happen

                                if( (pause_rcv or frm_align_err or frm_type_err or frm_length_err or frm_crc_err) = '1' ) then
                
                                        write(ln, NOW);
                                        write(ln, string'("    - Warning :"));

                                        if( pause_rcv='1' ) then 
                                        
                                                write(ln, string'(" Unexpected RX pause_rcv") );
                                                writeline(output, ln) ;
                                        
                                        end if;
            
                                        if( frm_align_err='1') then 
                                        
                                                write(ln, string'(" Unexpected RX frm_align_err") );
                                                writeline(output, ln) ;
                                        end if;
            
                                        if( frm_type_err='1' ) then 
                                        
                                                write(ln, string'(" Unexpected RX frm_type_err") );
                                                writeline(output, ln) ;
                                        
                                        end if;
            
                                        if( frm_length_err='1')then 
                                        
                                                write(ln, string'(" Unexpected RX frm_length_err") );
                                                writeline(output, ln) ;
                                        
                                        end if;

                                        if( frm_crc_err   ='1')then 
                                        
                                                write(ln, string'(" Unexpected RX frm_crc_err") );
                                                writeline(output, ln) ;
                                        
                                        end if;
                            
                                end if;

                      end if;

                   -- Promiscuous Mode Change
                   -- -----------------------
                   
                        promis_en_dly <= promis_en;

                        if(promis_en /= promis_en_dly) then
        
                                write(ln, NOW );

                                if( promis_en='1' and NOW>100 ns) then 
                
                                        write(ln, string'(" - Promiscuous Mode enabled with multicast sent: ") );
                                        write(ln, rx_multicast_sent );
                                        write(ln, string'(", rcvd:"));
                                        write(ln, rx_multicast_rcvd );
                                        write(ln, string'(", denied:"));
                                        write(ln, rx_multicast_denied );
                                        writeline(output, ln) ;
            
                                else                
                        
                                        write(ln, string'(" - Promiscuous Mode disabled") );
                                        writeline(output, ln) ;
            
                                end if;
                        
                        end if;                
        
                   -- FIFO Read Stop
                   -- --------------
                   
                        ff_rx_rdy_dly <= ff_rx_rdy;
        
                        if( ff_rx_rdy_dly /= ff_rx_rdy ) then
        
                                write(ln, NOW );

                                if( ff_rx_rdy='0' ) then 
            
                                        write(ln, string'("    - RX FIFO Read Stop"));
                
                                else
            
                                        write(ln, string'("    - RX FIFO Read Start"));
        
                                end if;
            
                                writeline(output, ln) ;

                        end if;
        
                end if;
    
        end process;                                  

    -- Global Simulation STOP
    -- -----------------------
    
        process( reset, rx_clk_tb ) 
        begin
        
                if( reset='1' ) then
        
                        delay_cnt <= 0;
                        sim_stop  <= '0' ;
            
                elsif( rx_clk_tb='1' and rx_clk_tb'event) then
        
                        if(state=END_SIM) then
                
                                delay_cnt <= delay_cnt + 1;
                                
                                if (delay_cnt=150) then
                                
                                        sim_stop <= '1' ;
                                        
                                end if ;
                
                                if( delay_cnt > 200 ) then
                
                                        assert false severity failure  ;                                        
                    
                                end if;
                
                        elsif(gm_tx_en='1' or m_tx_en='1' or rgm_tx_en='1') then
            
                                delay_cnt <= 0;
               
                        end if;
             
                end if;
        
        end process;

end a ;
