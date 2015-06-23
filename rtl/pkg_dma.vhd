--	-------------------------------------------------------------
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--     
--     Nov 2008 --> 64-bit
-- 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

package abb64Package is

-- Declare constants

  -- ----------------------------------------------------------------------
  -- Address definitions

  --  The 2 MSB's are for Addressing, i.e.
  --
  --  0x0000         : Design ID
  --  0x0008         : Interrupt status
  --  0x0010         : Interrupt enable
  --  0x0018         : General error
  --  0x0020         : General status
  --  0x0028         : General control

  --  0x002C ~ 0x004C: DMA upstream registers
  --  0x0050 ~ 0x0070: DMA upstream registers

  --  0x0074         : MRd channel control
  --  0x0078         : CplD channel control
  --  0x007C         : ICAP input/output

  --  0x0080 ~ 0x008C: Interrupt Generator (IG) registers

  --  0x4010         : TxFIFO write port
  --  0x4018         : W - TxFIFO Reset
  --                 : R - TxFIFO Vacancy status

  --  0x4020         : RxFIFO read port
  --  0x4028         : W - RxFIFO Reset
  --                 : R - RxFIFO Occupancy status

  --  0x8000 ~ 0xBFFF: BRAM space (BAR1)

  --  Others         : Reserved


  ------------------------------------------------------------------------
  --  Global Constants
  --

  ---       Number of Lanes for PCIe, 1, 4 or 8
  Constant  C_NUM_PCIE_LANES      : integer      :=   4;

  ---       Data bus width
  Constant  C_DBUS_WIDTH          : integer      :=   64;

  ---       Event Buffer: FIFO Data Count width
  Constant  C_FIFO_DC_WIDTH       : integer      :=   26;
  ---       Small BRAM FIFO for emulation
  Constant  C_EMU_FIFO_DC_WIDTH   : integer      :=   14;

  ---       Address width for endpoint device/peripheral
            -- 
  Constant  C_EP_AWIDTH           : integer  range 10 to 30
                                  :=   16;

  ---       Buffer width from the PCIe Core
  Constant  C_TBUF_AWIDTH         : integer      :=   4;  -- 5;

  ---       Width for Tx output Arbitration
  Constant  C_ARBITRATE_WIDTH     : integer      :=   4;

  ---       Number of BAR spaces
  Constant  CINT_BAR_SPACES       : integer      :=   4;

  ---       Max BAR number, 7
  Constant  C_BAR_NUMBER          : integer      :=   7;
  ---       Encoded BAR number takes 3 bits to represent 0~6.  7 means invalid or don't care
  Constant  C_ENCODE_BAR_NUMBER   : integer      :=   3;

  ---       Number of Channels, currently 4: Interrupt, PIO MRd, upstream DMA, downstream DMA
  Constant  C_CHANNEL_NUMBER      : integer      :=   4;

  ---       Data width of the channel buffers (FIFOs)
  Constant  C_CHANNEL_BUF_WIDTH   : integer      :=   128;

  ---       Higher 4 bits are for tag decoding
  Constant  C_TAG_DECODE_BITS     : integer      :=   4;

  ---       DDR SDRAM bank address pin number
  Constant  C_DDR_BANK_AWIDTH     : integer      :=   2;

  ---       DDR SDRAM address pin number
  Constant  C_DDR_AWIDTH          : integer      :=   13;

  ---       DDR SDRAM data pin number
  Constant  C_DDR_DWIDTH          : integer      :=   16;

  ---       DDR SDRAM module address width, dependent on total DDR memory capacity.
            --  128 Mb=  16MB : 24
            --  256 Mb=  32MB : 25
            --  512 Mb=  64MB : 26
            -- 1024 Mb= 128MB : 27
            -- 2048 Mb= 256MB : 28
  Constant  C_DDR_IAWIDTH         : integer  range 24 to 28
                                  :=   26;


  ---       Block RAM address bus width.  Variation requires BRAM core regeneration.
  Constant  C_PRAM_AWIDTH         : integer  range 8 to 28
                                  :=   12;

  ---       Width for Interrupt generation counter
  Constant  C_CNT_GINT_WIDTH      : integer      :=  30;


--  ---       Emulation FIFOs' address width
--  Constant  C_FIFO_AWIDTH         : integer      :=   5;

  ---       Tag RAM data bus width, 1 bit for AInc information and 3 bits for BAR number
  Constant  C_TAGRAM_DWIDTH       : integer      :=   36;

  ---       Configuration command width, e.g. cfg_dcommand, cfg_lcommand.
  Constant  C_CFG_COMMAND_DWIDTH  : integer      :=   16;

  ---       Tag RAM address bus width, only 6 bits (of 8) are used for MRd from DMA Write Channel
  Constant  C_TAGRAM_AWIDTH       : integer      :=   6;
  Constant  C_TAG_MAP_WIDTH       : integer      :=  64;  -- 2^C_TAGRAM_AWIDTH
  --        TAG map are partitioned into sub-parts
  Constant  C_SUB_TAG_MAP_WIDTH   : integer      :=   8;

  ---       Address_Increment bit is put in tag RAM
  Constant  CBIT_AINC_IN_TAGRAM   : integer      :=   C_TAGRAM_DWIDTH-1;

  -- Bit range of BAR field in TAG ram
  Constant  C_TAGBAR_BIT_TOP      : integer      :=   CBIT_AINC_IN_TAGRAM-1;
  Constant  C_TAGBAR_BIT_BOT      : integer      :=   C_TAGBAR_BIT_TOP-C_ENCODE_BAR_NUMBER+1;


  ---       Number of bits for Last DW BE and 1st DW BE in the header of a TLP
  Constant  C_BE_WIDTH            : integer      :=   4;


  ---       ICAP width: 8 or 32.
  Constant  C_ICAP_WIDTH          : integer      :=   32;

  ---       Feature Bits width
  Constant  C_FEAT_BITS_WIDTH     : integer      :=   8;

  ---       Channel lables
  Constant  C_CHAN_INDEX_IRPT     : integer      :=   3;
  Constant  C_CHAN_INDEX_MRD      : integer      :=   2;
  Constant  C_CHAN_INDEX_DMA_DS   : integer      :=   1;
  Constant  C_CHAN_INDEX_DMA_US   : integer      :=   0;

  ------------------------------------------------------------------------
  --  Bit ranges

  --        Bits range for Max_Read_Request_Size in cfg_dcommand
  Constant  C_CFG_MRS_BIT_TOP     : integer      :=   14;
  Constant  C_CFG_MRS_BIT_BOT     : integer      :=   12;

  --        Bits range for Max_Payload_Size in cfg_dcommand
  Constant  C_CFG_MPS_BIT_TOP     : integer      :=    7;
  Constant  C_CFG_MPS_BIT_BOT     : integer      :=    5;

  --        The bit in minimum Max_Read_Request_Size/Max_Payload_Size that is one
            --  i.e. 0x80 Bytes = 0x20 DW = "000000100000"
  Constant  CBIT_SENSE_OF_MAXSIZE : integer      :=    5;


-- ------------------------------------------------------------------------
--
--  Section for TLP headers' bit definition
--         ( not shown in user header file)
--
-- ------------------------------------------------------------------------

--  -- The bit in TLP header #0 that means whether the TLP comes with data
--  Constant  CBIT_TLP_HAS_PAYLOAD  : integer      :=   30;

--  -- The bit in TLP header #0 that means whether the TLP has 4-DW header
--  Constant  CBIT_TLP_HAS_4DW_HEAD : integer      :=   29;

--  -- The bit in TLP header #0 that means Cpl/CplD
--  Constant  C_TLP_CPLD_BIT        : integer      :=   27;

  -- The bit in TLP header #0 that means TLP Digest
  Constant  C_TLP_TD_BIT          : integer      :=   15 +32;

  -- The bit in TLP header #0 that means Error Poison
  Constant  C_TLP_EP_BIT          : integer      :=   14 +32;

  -- Bit range of Format field in TLP header #0
  Constant  C_TLP_FMT_BIT_TOP     : integer      :=   30 +32;    -- TLP has payload
  Constant  C_TLP_FMT_BIT_BOT     : integer      :=   29 +32;    -- TLP header has 4 DW

  -- Bit range of Type field in TLP header #0
  Constant  C_TLP_TYPE_BIT_TOP    : integer      :=   28 +32;
  Constant  C_TLP_TYPE_BIT_BOT    : integer      :=   24 +32;

  -- Bit range of TC field in TLP header #0
  Constant  C_TLP_TC_BIT_TOP      : integer      :=   22 +32;
  Constant  C_TLP_TC_BIT_BOT      : integer      :=   20 +32;

  -- Bit range of Attribute field in TLP header #0
  Constant  C_TLP_ATTR_BIT_TOP    : integer      :=   13 +32;
  Constant  C_TLP_ATTR_BIT_BOT    : integer      :=   12 +32;

  -- Bit range of Length field in TLP header #0
  Constant  C_TLP_LENG_BIT_TOP    : integer      :=    9 +32;
  Constant  C_TLP_LENG_BIT_BOT    : integer      :=    0 +32;

  -- Bit range of Requester ID field in header #1 of non-Cpl/D TLP
  Constant  C_TLP_REQID_BIT_TOP   : integer      :=   31;
  Constant  C_TLP_REQID_BIT_BOT   : integer      :=   16;

  -- Bit range of Tag field in header #1 of non-Cpl/D TLP
  Constant  C_TLP_TAG_BIT_TOP     : integer      :=   15;
  Constant  C_TLP_TAG_BIT_BOT     : integer      :=    8;

  -- Bit range of Last BE field in TLP header #1
  Constant  C_TLP_LAST_BE_BIT_TOP : integer      :=    7;
  Constant  C_TLP_LAST_BE_BIT_BOT : integer      :=    4;

  -- Bit range of 1st BE field in TLP header #1
  Constant  C_TLP_1ST_BE_BIT_TOP  : integer      :=    3;
  Constant  C_TLP_1ST_BE_BIT_BOT  : integer      :=    0;

  -- Bit range of Completion Status field in Cpl/D TLP header #1
  Constant  C_CPLD_CS_BIT_TOP     : integer      :=   15;
  Constant  C_CPLD_CS_BIT_BOT     : integer      :=   13;

  -- Bit range of Completion Byte Count field in Cpl/D TLP header #1
  Constant  C_CPLD_BC_BIT_TOP     : integer      :=   11;
  Constant  C_CPLD_BC_BIT_BOT     : integer      :=    0;

  -- Bit range of Completer ID field in header#1 of Cpl/D TLP
  Constant  C_CPLD_CPLT_ID_BIT_TOP : integer      :=   C_TLP_REQID_BIT_TOP;
  Constant  C_CPLD_CPLT_ID_BIT_BOT : integer      :=   C_TLP_REQID_BIT_BOT;

  -- Bit range of Requester ID field in header#2 of Cpl/D TLP
  Constant  C_CPLD_REQID_BIT_TOP  : integer      :=   31 +32;
  Constant  C_CPLD_REQID_BIT_BOT  : integer      :=   16 +32;

  -- Bit range of Completion Tag field in Cpl/D TLP 3rd header
  Constant  C_CPLD_TAG_BIT_TOP    : integer      :=   C_TLP_TAG_BIT_TOP +32;
  Constant  C_CPLD_TAG_BIT_BOT    : integer      :=   C_TLP_TAG_BIT_BOT +32;

  -- Bit range of Completion Lower Address field in Cpl/D TLP 3rd header
  Constant  C_CPLD_LA_BIT_TOP     : integer      :=    6 +32;
  Constant  C_CPLD_LA_BIT_BOT     : integer      :=    0 +32;


  -- Bit range of Message Code field in Msg 2nd header
  Constant  C_MSG_CODE_BIT_TOP    : integer      :=    7;
  Constant  C_MSG_CODE_BIT_BOT    : integer      :=    0;



  -- ----------------------------------------------------------------------
  -- TLP field widths
  -- For PCIe, the length field is 10 bits wide.
  Constant  C_TLP_FLD_WIDTH_OF_LENG      : integer
                                         := C_TLP_LENG_BIT_TOP-C_TLP_LENG_BIT_BOT+1;

  ------------------------------------------------------------------------
  ---       Tag width in TLP
  Constant  C_TAG_WIDTH                  : integer
                                         := C_TLP_TAG_BIT_TOP-C_TLP_TAG_BIT_BOT+1;

  ------------------------------------------------------------------------
  ---       Width for Local ID
  Constant  C_ID_WIDTH                   : integer
                                         := C_TLP_REQID_BIT_TOP-C_TLP_REQID_BIT_BOT+1;

  ------------------------------------------------------------------------
  ---       Width for Requester ID
  Constant  C_REQID_WIDTH                : integer
                                         := C_TLP_REQID_BIT_TOP-C_TLP_REQID_BIT_BOT+1;

-- ------------------------------------------------------------------------
-- Section for Channel Buffer bit definition, referenced to TLP header definition
--         ( not shown in user header file)
--
-- ------------------------------------------------------------------------


  -- Bit range of Length field in Channel Buffer word
  Constant  C_CHBUF_LENG_BIT_BOT       : integer      :=    0;
  Constant  C_CHBUF_LENG_BIT_TOP       : integer      :=    C_CHBUF_LENG_BIT_BOT+C_TLP_FLD_WIDTH_OF_LENG-1;  -- 9

  -- Bit range of Attribute field in Channel Buffer word
  Constant  C_CHBUF_ATTR_BIT_BOT       : integer      :=   C_CHBUF_LENG_BIT_TOP+1; --10;
  Constant  C_CHBUF_ATTR_BIT_TOP       : integer      :=   C_CHBUF_ATTR_BIT_BOT+C_TLP_ATTR_BIT_TOP-C_TLP_ATTR_BIT_BOT; --11;

  -- The bit in Channel Buffer word that means Error Poison
  Constant  C_CHBUF_EP_BIT             : integer      :=   C_CHBUF_ATTR_BIT_TOP+1; --12;

  -- The bit in Channel Buffer word that means TLP Digest
  Constant  C_CHBUF_TD_BIT             : integer      :=   C_CHBUF_EP_BIT+1; --13;

  -- Bit range of TC field in Channel Buffer word
  Constant  C_CHBUF_TC_BIT_BOT         : integer      :=   C_CHBUF_TD_BIT+1; --14;
  Constant  C_CHBUF_TC_BIT_TOP         : integer      :=   C_CHBUF_TC_BIT_BOT+C_TLP_TC_BIT_TOP-C_TLP_TC_BIT_BOT; --16;

  -- Bit range of Format field in Channel Buffer word
  Constant  C_CHBUF_FMT_BIT_BOT        : integer      :=   C_CHBUF_TC_BIT_TOP+1; --17;
  Constant  C_CHBUF_FMT_BIT_TOP        : integer      :=   C_CHBUF_FMT_BIT_BOT+C_TLP_FMT_BIT_TOP-C_TLP_FMT_BIT_BOT; --18;


  -- Bit range of Tag field in Channel Buffer word except Cpl/D
  Constant  C_CHBUF_TAG_BIT_BOT        : integer      :=   C_CHBUF_FMT_BIT_TOP+1; --19;
  Constant  C_CHBUF_TAG_BIT_TOP        : integer      :=   C_CHBUF_TAG_BIT_BOT+C_TLP_TAG_BIT_TOP-C_TLP_TAG_BIT_BOT; --26;

  -- Bit range of BAR Index field in upstream DMA Channel Buffer word
  Constant  C_CHBUF_DMA_BAR_BIT_BOT    : integer      :=   C_CHBUF_TAG_BIT_TOP+1; --27;
  Constant  C_CHBUF_DMA_BAR_BIT_TOP    : integer      :=   C_CHBUF_DMA_BAR_BIT_BOT+C_ENCODE_BAR_NUMBER-1; --29;

  -- Bit range of Message Code field in Channel Buffer word for Msg
  Constant  C_CHBUF_MSG_CODE_BIT_BOT   : integer      :=   C_CHBUF_TAG_BIT_TOP+1; --27;
  Constant  C_CHBUF_MSG_CODE_BIT_TOP   : integer      :=   C_CHBUF_MSG_CODE_BIT_BOT+C_MSG_CODE_BIT_TOP-C_MSG_CODE_BIT_BOT; --34;


  -- Bit range of remaining Byte Count field in Cpl/D Channel Buffer word
  Constant  C_CHBUF_CPLD_BC_BIT_BOT    : integer      :=   C_CHBUF_FMT_BIT_TOP+1; --19;
  Constant  C_CHBUF_CPLD_BC_BIT_TOP    : integer      :=   C_CHBUF_CPLD_BC_BIT_BOT+C_TLP_FLD_WIDTH_OF_LENG-1+2;  --30;

  -- Bit range of Completion Status field in Cpl/D Channel Buffer word
  Constant  C_CHBUF_CPLD_CS_BIT_BOT    : integer      :=   C_CHBUF_CPLD_BC_BIT_TOP+1; --31;
  Constant  C_CHBUF_CPLD_CS_BIT_TOP    : integer      :=   C_CHBUF_CPLD_CS_BIT_BOT+C_CPLD_CS_BIT_TOP-C_CPLD_CS_BIT_BOT;  --33;

  -- Bit range of Lower Address field in Cpl/D Channel Buffer word
  Constant  C_CHBUF_CPLD_LA_BIT_BOT    : integer      :=   C_CHBUF_CPLD_CS_BIT_TOP+1; --34;
  Constant  C_CHBUF_CPLD_LA_BIT_TOP    : integer      :=   C_CHBUF_CPLD_LA_BIT_BOT+C_CPLD_LA_BIT_TOP-C_CPLD_LA_BIT_BOT; --40;

  -- Bit range of Tag field in Cpl/D Channel Buffer word
  Constant  C_CHBUF_CPLD_TAG_BIT_BOT   : integer      :=   C_CHBUF_CPLD_LA_BIT_TOP+1;  --41;
  Constant  C_CHBUF_CPLD_TAG_BIT_TOP   : integer      :=   C_CHBUF_CPLD_TAG_BIT_BOT+C_CPLD_TAG_BIT_TOP-C_CPLD_TAG_BIT_BOT; --48;

  -- Bit range of Requester ID field in Cpl/D Channel Buffer word
  Constant  C_CHBUF_CPLD_REQID_BIT_BOT : integer      :=   C_CHBUF_CPLD_TAG_BIT_TOP+1; --49;
  Constant  C_CHBUF_CPLD_REQID_BIT_TOP : integer      :=   C_CHBUF_CPLD_REQID_BIT_BOT+C_CPLD_REQID_BIT_TOP-C_CPLD_REQID_BIT_BOT;  --64;



  -- Bit range of BAR Index field in Cpl/D Channel Buffer word
  Constant  C_CHBUF_CPLD_BAR_BIT_BOT   : integer      :=   C_CHBUF_CPLD_REQID_BIT_TOP+1; --65;
  Constant  C_CHBUF_CPLD_BAR_BIT_TOP   : integer      :=   C_CHBUF_CPLD_BAR_BIT_BOT+C_ENCODE_BAR_NUMBER-1; --67;


  -- Bit range of host address in Channel Buffer word
  Constant  C_CHBUF_HA_BIT_BOT         : integer      :=   C_CHBUF_DMA_BAR_BIT_TOP+1;  --30;
--  Constant  C_CHBUF_HA_BIT_TOP         : integer      :=   C_CHBUF_HA_BIT_BOT+2*C_DBUS_WIDTH-1;  --93;
  Constant  C_CHBUF_HA_BIT_TOP         : integer      :=   C_CHBUF_HA_BIT_BOT+C_DBUS_WIDTH-1;  --93;


  -- The bit in Channel Buffer word that means whether this TLP is valid for output arbitration
  --        (against channel buffer reset during arbitration)
  Constant  C_CHBUF_QVALID_BIT         : integer      :=   C_CHBUF_HA_BIT_TOP+1; --94;

  -- The bit in Channel Buffer word that means address increment
  Constant  C_CHBUF_AINC_BIT           : integer      :=   C_CHBUF_QVALID_BIT+1; --95;

  -- The bit in Channel Buffer word that means zero-length
  Constant  C_CHBUF_0LENG_BIT          : integer      :=   C_CHBUF_AINC_BIT+1;   --96;



  -- Bit range of peripheral address in Channel Buffer word
  Constant  C_CHBUF_PA_BIT_BOT         : integer      :=  C_CHANNEL_BUF_WIDTH-C_EP_AWIDTH;  --112;
  Constant  C_CHBUF_PA_BIT_TOP         : integer      :=  C_CHANNEL_BUF_WIDTH-1; --127;


  -- Bit range of BRAM address in Channel Buffer word
  Constant  C_CHBUF_MA_BIT_BOT         : integer      :=  C_CHANNEL_BUF_WIDTH-C_PRAM_AWIDTH-2;  --114;
  Constant  C_CHBUF_MA_BIT_TOP         : integer      :=  C_CHANNEL_BUF_WIDTH-1; --127;

  -- Bit range of DDR address in Channel Buffer word
  Constant  C_CHBUF_DDA_BIT_BOT         : integer      :=  C_CHANNEL_BUF_WIDTH-C_DDR_IAWIDTH;  --102;
  Constant  C_CHBUF_DDA_BIT_TOP         : integer      :=  C_CHANNEL_BUF_WIDTH-1; --127;



  ------------------------------------------------------------------------
  -- The Relaxed Ordering bit constant in TLP
  Constant  C_RELAXED_ORDERING           : std_logic
                                         := '0';

  -- The NO SNOOP bit constant in TLP
  Constant  C_NO_SNOOP                   : std_logic
                                         := '0'; -- '1';

  -- AK, 2007-11-07: SNOOP-bit corrupts DMA, if set on INTEL platform. Seems to be don't care on AMD

  ------------------------------------------------------------------------
  -- TLP resolution concerning Format
  Constant  C_FMT3_NO_DATA               : std_logic_vector(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT)
                                         := "00";
  Constant  C_FMT3_WITH_DATA             : std_logic_vector(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT)
                                         := "10";

  Constant  C_FMT4_NO_DATA               : std_logic_vector(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT)
                                         := "01";
  Constant  C_FMT4_WITH_DATA             : std_logic_vector(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT)
                                         := "11";

  -- TLP resolution concerning Type
  Constant  C_TYPE_MEM_REQ               : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "00000";
  Constant  C_TYPE_IO_REQ                : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "00010";

  Constant  C_TYPE_MEM_REQ_LK            : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "00001";
  Constant  C_TYPE_COMPLETION            : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "01010";
  Constant  C_TYPE_COMPLETION_LK         : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "01011";

  Constant  C_TYPE_MSG_TO_ROOT           : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "10000";
  Constant  C_TYPE_MSG_BY_ADDRESS        : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "10001";
  Constant  C_TYPE_MSG_BY_ID             : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "10010";
  Constant  C_TYPE_MSG_FROM_ROOT         : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "10011";
  Constant  C_TYPE_MSG_LOCAL             : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "10100";
  Constant  C_TYPE_MSG_GATHER_TO_ROOT    : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := "10101";

  --  Select this constant to test system response
  Constant  C_TYPE_OF_MSG                : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
                                         := C_TYPE_MSG_LOCAL;   -- C_TYPE_MSG_TO_ROOT;

  ------------------------------------------------------------------------
  -- Lowest priority for Tx_Output_Arbitration module
  Constant  C_LOWEST_PRIORITY            :  std_logic_vector (C_ARBITRATE_WIDTH-1 downto 0)
                                         := (0=>'1', OTHERS=>'0');

  ------------------------------------------------------------------------
  Constant  C_DECODE_BIT_TOP             : integer      :=   C_EP_AWIDTH-1;       -- 15;
  Constant  C_DECODE_BIT_BOT             : integer      :=   C_DECODE_BIT_TOP-1;  -- 14;


  ------------------------------------------------------------------------
  -- Current buffer descriptor length is 8 DW.
  Constant  C_NEXT_BD_LENGTH             : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0)
                                         := CONV_STD_LOGIC_VECTOR(8*4, C_TLP_FLD_WIDTH_OF_LENG+2);

  --  Maximum 8 DW for the CplD carrying next BDA
  Constant  C_NEXT_BD_LENG_MSB           : integer      := 3;

  ------------------------------------------------------------------------
  --  To determine the max.size parameters, 6 bits are used.
  Constant  C_MAXSIZE_FLD_BIT_TOP        : integer      := C_TLP_FLD_WIDTH_OF_LENG +2;
  Constant  C_MAXSIZE_FLD_BIT_BOT        : integer      := 7;


  -- DDR commands: RASn-CASn-WEn
  Constant  CMD_NOP             : std_logic_vector(2 downto 0)  :=  "111";
  Constant  CMD_LMR             : std_logic_vector(2 downto 0)  :=  "000";
  Constant  CMD_ACT             : std_logic_vector(2 downto 0)  :=  "011";
  Constant  CMD_READ            : std_logic_vector(2 downto 0)  :=  "101";
  Constant  CMD_WRITE           : std_logic_vector(2 downto 0)  :=  "100";
  Constant  CMD_PRECH           : std_logic_vector(2 downto 0)  :=  "010";
  Constant  CMD_BTERM           : std_logic_vector(2 downto 0)  :=  "110";
  Constant  CMD_AREF            : std_logic_vector(2 downto 0)  :=  "001";


  ------------------------------------------------------------------------
  --  Time-out counter width
  Constant  C_TOUT_WIDTH                 : integer      := 32;

  --  Bottom bit for determining time-out
  Constant  CBIT_TOUT_BOT                : integer      := 16;

  --  Time-out value
  Constant  C_TIME_OUT_VALUE             : std_logic_vector(C_TOUT_WIDTH-1 downto CBIT_TOUT_BOT)
--                                         := (OTHERS=>'1' );  -- Maximum value (-1)
                                         := (24=>'1', OTHERS=>'0' );

  ----------------------------------------------------------------------------------
  Constant  C_REGS_BASE_ADDR             : std_logic_vector(C_EP_AWIDTH-1 downto 0) 
                                                        := (C_DECODE_BIT_TOP => '0'
                                                          , C_DECODE_BIT_BOT => '0'
                                                          , OTHERS => '0' );

  Constant  C_BRAM_BASE_ADDR             : std_logic_vector(C_EP_AWIDTH-1 downto 0) 
                                                        := (C_DECODE_BIT_TOP => '1'
                                                          , C_DECODE_BIT_BOT => '0'
                                                          , OTHERS => '0' );

  Constant  C_FIFO_BASE_ADDR             : std_logic_vector(C_EP_AWIDTH-1 downto 0) 
                                                        := (C_DECODE_BIT_TOP => '0'
                                                          , C_DECODE_BIT_BOT => '0'
                                                          , OTHERS => '0' );


  ----------------------------------------------------------------------------------
--  Constant  CINT_ADDR_TXFIFO_DATA  : integer  := 4;
--  Constant  CINT_ADDR_TXFIFO_CTRL  : integer  := 6;
--  Constant  CINT_ADDR_TXFIFO_STA   : integer  := 6;
--
--  Constant  CINT_ADDR_RXFIFO_DATA  : integer  := 8;
--  Constant  CINT_ADDR_RXFIFO_CTRL  : integer  := 10;
--  Constant  CINT_ADDR_RXFIFO_STA   : integer  := 10;

  Constant  CINT_REGS_SPACE_BAR    : integer  := 0;
  Constant  CINT_FIFO_SPACE_BAR    : integer  := 2;
  Constant  CINT_BRAM_SPACE_BAR    : integer  := 3;
  Constant  CINT_DDR_SPACE_BAR     : integer  := 1;
  ------------------------------------------------------------------------


--  -- Default channel buffer word for CplD
--  Constant  C_DEF_CPLD_WORD        : std_logic_vector(C_DBUS_WIDTH-1 downto 0)
--                                   :=X"CA000000";

  ----------------------------------------------------------------------------------
  --  1st word of MRd, for requesting the next descriptor
--  Constant  C_MRD_HEAD0_WORD       : std_logic_vector(C_DBUS_WIDTH-1 downto 0)
--                                   := X"80000000";
  Constant  C_TLP_HAS_DATA         : std_logic 
                                   := '1';
  Constant  C_TLP_HAS_NO_DATA      : std_logic 
                                   := '0';
  Constant  C_TLP_3DW_HEADER       : std_logic 
                                   := '0';
  Constant  C_TLP_4DW_HEADER       : std_logic 
                                   := '1';

  ------------------------------------------------------------------------
  Constant  C_TLP_TYPE_IS_MRD_H3   : std_logic_vector(3 downto 0)
                                   := "1000";
  Constant  C_TLP_TYPE_IS_MRDLK_H3 : std_logic_vector(3 downto 0)
                                   := "0100";
  Constant  C_TLP_TYPE_IS_MRD_H4   : std_logic_vector(3 downto 0)
                                   := "0010";
  Constant  C_TLP_TYPE_IS_MRDLK_H4 : std_logic_vector(3 downto 0)
                                   := "0001";

  Constant  C_TLP_TYPE_IS_MWR_H3   : std_logic_vector(1 downto 0)
                                   := "10";
  Constant  C_TLP_TYPE_IS_MWR_H4   : std_logic_vector(1 downto 0)
                                   := "01";

  Constant  C_TLP_TYPE_IS_CPLD     : std_logic_vector(3 downto 0)
                                   := "1000";
  Constant  C_TLP_TYPE_IS_CPL      : std_logic_vector(3 downto 0)
                                   := "0100";
  Constant  C_TLP_TYPE_IS_CPLDLK   : std_logic_vector(3 downto 0)
                                   := "0010";
  Constant  C_TLP_TYPE_IS_CPLLK    : std_logic_vector(3 downto 0)
                                   := "0001";

  ------------------------------------------------------------------------
  --        Maximal number of Interrupts
  Constant  C_NUM_OF_INTERRUPTS    : integer  := 16;


  ------------------------------------------------------------------------
    -- Minimal register set 
  Constant  CINT_ADDR_VERSION      : integer  := 0;  

  Constant  CINT_ADDR_IRQ_STAT     : integer  := 2;     

  -- IRQ Enable. Write '1' turns on the interrupt, '0' masks.

  Constant  CINT_ADDR_IRQ_EN       : integer  := 4;

  Constant  CINT_ADDR_ERROR        : integer  := 6;   -- unused

  Constant  CINT_ADDR_STATUS       : integer  := 8;

  Constant  CINT_ADDR_CONTROL      : integer  := 10;

  -- Upstream DMA channel Constants
  Constant  CINT_ADDR_DMA_US_PAH   : integer  := 11;  

  Constant  CINT_ADDR_DMA_US_PAL   : integer  := 12;  

  Constant  CINT_ADDR_DMA_US_HAH   : integer  := 13;  

  Constant  CINT_ADDR_DMA_US_HAL   : integer  := 14;  

  Constant  CINT_ADDR_DMA_US_BDAH  : integer  := 15;  

  Constant  CINT_ADDR_DMA_US_BDAL  : integer  := 16;  

  Constant  CINT_ADDR_DMA_US_LENG  : integer  := 17;  

  Constant  CINT_ADDR_DMA_US_CTRL  : integer  := 18;  

  Constant  CINT_ADDR_DMA_US_STA   : integer  := 19;  


  -- Downstream DMA channel Constants
  Constant  CINT_ADDR_DMA_DS_PAH   : integer  := 20;  

  Constant  CINT_ADDR_DMA_DS_PAL   : integer  := 21;  

  Constant  CINT_ADDR_DMA_DS_HAH   : integer  := 22;  

  Constant  CINT_ADDR_DMA_DS_HAL   : integer  := 23;  

  Constant  CINT_ADDR_DMA_DS_BDAH  : integer  := 24;  

  Constant  CINT_ADDR_DMA_DS_BDAL  : integer  := 25;  

  Constant  CINT_ADDR_DMA_DS_LENG  : integer  := 26;  

  Constant  CINT_ADDR_DMA_DS_CTRL  : integer  := 27;  

  Constant  CINT_ADDR_DMA_DS_STA   : integer  := 28;  


  --------  Address for MRd channel control
  Constant  CINT_ADDR_MRD_CTRL     : integer  := 29;

  --------  Address for Tx module control
  Constant  CINT_ADDR_TX_CTRL      : integer  := 30;

  --------  Address for ICAP access
  Constant  CINT_ADDR_ICAP         : integer  := 31;



  --------  Address of Interrupt Generator Control (W)
  Constant  CINT_ADDR_IG_CONTROL      : integer  := 32;

  --------  Address of Interrupt Generator Latency (W+R)
  Constant  CINT_ADDR_IG_LATENCY      : integer  := 33;

  --------  Address of Interrupt Generator Assert Number (R)
  Constant  CINT_ADDR_IG_NUM_ASSERT   : integer  := 34;

  --------  Address of Interrupt Generator Deassert Number (R)
  Constant  CINT_ADDR_IG_NUM_DEASSERT : integer  := 35;


  --------  Event Buffer FIFO status (R) + control (W)
  Constant  CINT_ADDR_EB_STACON       : integer  := 36;

  --------  Upstream DMA transferred byte count (R)
  Constant  CINT_ADDR_US_TRANSF_BC       : integer  := 37;
  --------  Downstream DMA transferred byte count (R)
  Constant  CINT_ADDR_DS_TRANSF_BC       : integer  := 38;

  --------  DCB protocol link status (R) + control (W)
  Constant  CINT_ADDR_PROTOCOL_STACON    : integer  := 39;

  --------  CTL class register rx(R) + tx (W)
  Constant  CINT_ADDR_CTL_CLASS          : integer  := 40;

  --------  DLM class register rx(R) + tx (W)
  Constant  CINT_ADDR_DLM_CLASS          : integer  := 41;

  --------  Data generator control register (W)
  Constant  CINT_ADDR_DG_CTRL            : integer  := 42;

  --------  Traffice classes status (R)
  Constant  CINT_ADDR_TC_STATUS          : integer  := 43;

  ------------------------------------------------------------------------
  --        Number of registers
  Constant  C_NUM_OF_ADDRESSES           : integer  := 44;
  -- 
  ------------------------------------------------------------------------


  -- ----------------------------------------------------------------------
  -- Bit definitions of the Control register for DMA channels
  --
  Constant  CINT_BIT_DMA_CTRL_VALID        : integer      :=   25;
  Constant  CINT_BIT_DMA_CTRL_LAST         : integer      :=   24;
  Constant  CINT_BIT_DMA_CTRL_UPA          : integer      :=   20;
  Constant  CINT_BIT_DMA_CTRL_AINC         : integer      :=   15;
  Constant  CINT_BIT_DMA_CTRL_END          : integer      :=   08;

  -- Bit range of BAR field in DMA Control register
  Constant  CINT_BIT_DMA_CTRL_BAR_TOP      : integer      :=   18;
  Constant  CINT_BIT_DMA_CTRL_BAR_BOT      : integer      :=   16;


  --  Default DMA Control register value
--  Constant  C_DEF_DMA_CTRL_WORD    : std_logic_vector(C_DBUS_WIDTH-1 downto 0)
  Constant  C_DEF_DMA_CTRL_WORD    : std_logic_vector(C_DBUS_WIDTH-1 downto 0)
                                   := (CINT_BIT_DMA_CTRL_VALID => '1' ,
                                       CINT_BIT_DMA_CTRL_END   => '1' ,
                                       OTHERS                  => '0'
                                      );

  ------------------------------------------------------------------------
  Constant  C_CHANNEL_RST_BITS     : std_logic_vector(C_FEAT_BITS_WIDTH-1 downto 0)
                                   := X"0A";

  ------------------------------------------------------------------------
  Constant  C_HOST_ICLR_BITS       : std_logic_vector(C_FEAT_BITS_WIDTH-1 downto 0)
                                   := X"F0";

  ----------------------------------------------------------------------------------
  -- Initial MWr Tag for upstream DMA
  Constant  C_TAG0_DMA_US_MWR      : std_logic_vector(C_TAG_WIDTH-1 downto 0)
                                   := X"D0";

  -- Initial MRd Tag for upstream DMA descriptor
  Constant  C_TAG0_DMA_USB         : std_logic_vector(C_TAG_WIDTH-1 downto 0)
                                   := X"E0";

  -- Initial MRd Tag for downstream DMA descriptor
  Constant  C_TAG0_DMA_DSB         : std_logic_vector(C_TAG_WIDTH-1 downto  0)
                                   := X"C0";

  -- Initial Msg Tag Hihger 4 bits for interrupt
  Constant  C_MSG_TAG_HI           : std_logic_vector( 3 downto 0) 
                                   := X"F";
  -- Msg code for IntA (fixed by PCIe)
  Constant  C_MSGCODE_INTA         : std_logic_vector( 7 downto 0) 
                                   := X"20";
  -- Msg code for #IntA  (fixed by PCIe)
  Constant  C_MSGCODE_INTA_N       : std_logic_vector( 7 downto 0) 
                                   := X"24";

  ----------------------------------------------------------------------------------
  -- DMA status bit definition
  Constant  CINT_BIT_DMA_STAT_NALIGN   : integer  := 7;
  Constant  CINT_BIT_DMA_STAT_TIMEOUT  : integer  := 4;
  Constant  CINT_BIT_DMA_STAT_BDANULL  : integer  := 3;
  Constant  CINT_BIT_DMA_STAT_BUSY     : integer  := 1;
  Constant  CINT_BIT_DMA_STAT_DONE     : integer  := 0;

  -- Bit definition in interrup status register (ISR)
  Constant  CINT_BIT_US_DONE_IN_ISR    : integer  := 0;
  Constant  CINT_BIT_DS_DONE_IN_ISR    : integer  := 1;

  Constant  CINT_BIT_INTGEN_IN_ISR     : integer  := 2;
  Constant  CINT_BIT_DGEN_IN_ISR       : integer  := 3;

  Constant  CINT_BIT_USTOUT_IN_ISR     : integer  := 4;
  Constant  CINT_BIT_DSTOUT_IN_ISR     : integer  := 5;

  Constant  CINT_BIT_DAQ_IN_ISR        : integer  := 6;
  Constant  CINT_BIT_CTL_IN_ISR        : integer  := 7;
  Constant  CINT_BIT_DLM_IN_ISR        : integer  := 8;

  -- The Time-out bits in System Error Register (SER)
  Constant  CINT_BIT_TX_TOUT_IN_SER    : integer  := 18;
  Constant  CINT_BIT_EB_TOUT_IN_SER    : integer  := 19;
  Constant  CINT_BIT_EB_OVERWRITTEN    : integer  := 20;

  -- The separate RST bit in DG_CTRL register
  Constant  CINT_BIT_DG_RST            : integer  := 12;

  -- The MASK bit in DG_CTRL register
  Constant  CINT_BIT_DG_MASK           : integer  := 8;

  -- The BUSY bit in DG_CTRL register
  Constant  CINT_BIT_DG_BUSY           : integer  := 1;

  -- The AVAIL bit in DG_CTRL register
  Constant  CINT_BIT_DG_AVAIL          : integer  := 0;

  -- Bit definition of msg routing method in General Control Register (GCR)
  Constant  C_GCR_MSG_ROUT_BIT_BOT     : integer  := 0;
  Constant  C_GCR_MSG_ROUT_BIT_TOP     : integer  := 2;

  -- Bit definition of ICAP Busy in global status register (GSR)
  Constant  CINT_BIT_ICAP_BUSY_IN_GSR  : integer  := 4;

  -- Bit definition of Data Generator available in global status register (GSR)
  Constant  CINT_BIT_DG_AVAIL_IN_GSR   : integer  := 5;

  -- Bit definition of DCB link_active in global status register (GSR)
  Constant  CINT_BIT_LINK_ACT_IN_GSR   : integer  := 6;


  -- Bit range of link width in GSR
  Constant  CINT_BIT_LWIDTH_IN_GSR_BOT : integer  := 10;  -- 16;
  Constant  CINT_BIT_LWIDTH_IN_GSR_TOP : integer  := 15;  -- 21;


  ----------------------------------------------------------------------------------
  -- Carry bit, only for better timing, used to divide 32-bit add into 2 stages
  Constant  CBIT_CARRY                 : integer  := 16;

  ----------------------------------------------------------------------------------
  --   Zero and -1 constants for different dimensions
  -- 
  Constant  C_ALL_ZEROS            : std_logic_vector(255 downto 0)
                                   := (OTHERS=>'0');
  Constant  C_ALL_ONES             : std_logic_vector(255 downto 0)
                                   := (OTHERS=>'1');


  ----------------------------------------------------------------------------------
  -- Implement interrupt generator (IG)
  constant IMP_INT_GENERATOR       : boolean   := FALSE;

  -- interrupt type: cfg(aka legacy) or MSI
  constant USE_CFG_INTERRUPT       : boolean   := FALSE;


------------------------------------------------------------------------------------
----  ------------ Author ID
  constant AUTHOR_UNKNOWN          : std_logic_vector(4-1 downto 0)  := X"0";
  constant AUTHOR_AKUGEL           : std_logic_vector(4-1 downto 0)  := X"1";
  constant AUTHOR_WGAO             : std_logic_vector(4-1 downto 0)  := X"2";
  ----------------------------------------------------------------------------------

----  ------------ design ID              ---------------------
---- design id now contains a version: upper 8 bits, a major revision: next 8 bits, 
---- and author code: next 4 bits and a minor revision: lower 12 bits
---- keep the autor file seperate and don't submit to CVS
----
  constant DESIGN_VERSION          : std_logic_vector( 8-1 downto 0)  := X"03";
  constant DESIGN_MAJOR_REVISION   : std_logic_vector( 8-1 downto 0)  := X"01";
  constant DESIGN_MINOR_REVISION   : std_logic_vector(12-1 downto 0)  := X"001";
  constant C_DESIGN_ID             : std_logic_vector(64-1 downto 0)
                                   := X"00000000"
                                    & DESIGN_VERSION 
                                    & DESIGN_MAJOR_REVISION 
                                    & AUTHOR_WGAO
                                    & DESIGN_MINOR_REVISION
                                    ;


  ----------------------------------------------------------------------------------
  --       Function to invert endian for 32-bit data 
  --
  function Endian_Invert_32 (Word_in: std_logic_vector) return std_logic_vector;
  function Endian_Invert_64 (Word_in: std_logic_vector(64-1 downto 0)) return std_logic_vector;


  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  -- revision log
  -- 2007-05-30: AK - abbPackage added, address map changed
  -- 2007-06-12: WGao - C_DEF_DMA_CTRL_WORD added, 
  --                    DMA Control word bit definition added,
  --                    Function Endian_Invert_32 added.
  --                    CINT_ADDR_MRD_CTRL and CINT_ADDR_CPLD_CTRL changed,
  --                    CINT_ADDR_US_SAH and CINT_ADDR_DS_SAH removed.
  -- 2007-07-16: AK - dma status bits added


end abb64Package;


package body abb64Package is

  -- ------------------------------------------------------------------------------------------
  --   Function to invert bytewise endian for 32-bit data 
  -- ------------------------------------------------------------------------------------------
  function Endian_Invert_32 (Word_in: std_logic_vector) return std_logic_vector is
  begin
    return Word_in(7 downto 0)&Word_in(15 downto 8)&Word_in(23 downto 16)&Word_in(31 downto 24);
  end Endian_Invert_32;

  -- ------------------------------------------------------------------------------------------
  --   Function to invert bytewise endian for 64-bit data 
  -- ------------------------------------------------------------------------------------------
  function Endian_Invert_64 (Word_in: std_logic_vector(64-1 downto 0)) return std_logic_vector is
  begin
    return Word_in(39 downto 32)&Word_in(47 downto 40)&Word_in(55 downto 48)&Word_in(63 downto 56)
         & Word_in(7 downto 0)&Word_in(15 downto 8)&Word_in(23 downto 16)&Word_in(31 downto 24);
  end Endian_Invert_64;

end abb64Package;
