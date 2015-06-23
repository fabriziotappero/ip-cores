-----------------------------------------------------------------------
-- This file is part of SCARTS.
-- 
-- SCARTS is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- SCARTS is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with SCARTS.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.scarts_pkg.all;
use work.scarts_amba_pkg.all;

package scarts_core_pkg is

  constant INSTR_W            : integer := 16;
  constant ALUFLAG_W          : integer := 5;
  constant REGADDR_W          : integer := 4;
  constant EXCADDR_W          : integer := 5;
  
  constant EXCVECTAB_S        : integer  := 2**EXCADDR_W;
  constant REGFILE_S          : integer  := 2**REGADDR_W;
  
  constant EXCRETREG          : integer := REGFILE_S-1;
  constant SUBRETREG          : integer := REGFILE_S-2;
  
  subtype INSTR   is std_logic_vector(INSTR_W-1 downto 0);
  subtype ALUFLAG is std_logic_vector(ALUFLAG_W-1 downto 0);
  subtype REGADDR is std_logic_vector(REGADDR_W-1 downto 0);


  constant SLEEP_ACT          : std_ulogic := '1';
  constant HOLD_ACT           : std_ulogic := '1';
  constant EXC_ACT            : std_ulogic := '0';
  constant JMP_EXE            : std_ulogic := '1';
  constant TRAP_ACT           : std_ulogic := '1';
  constant BROM_SEL           : std_ulogic := '0';
  constant ILLOP              : std_ulogic := '1';
  constant REGF_WR            : std_ulogic := '1';
  constant STA_EN             : std_ulogic := '1';
  constant MEM_WR             : std_ulogic := '1';
  constant MEM_EN             : std_ulogic := '1';
  constant VECTAB_WR          : std_ulogic := '1';
  constant COND_INSTR         : std_ulogic := '1';

  constant PR_UPDATE          : std_logic     := '1';
  constant NOP                : INSTR := "1111111000000000";

  constant SIGNED_AC          : std_ulogic := '1';  
  
  type MEMACCESSTYPE is (MEM_DISABLE, BYTE_A, HWORD_A, WORD_A);

  type ALUSRCCTRL is (REGF_SRC, EXE_SRC, WB_SRC, DEC_SRC);
  
  type WBSRCCTRL is (ALU_SRC, MEM_SRC);
  
  type CARRYCTRL is (CARRY_IN, CARRY_NOT, CARRY_ZERO, CARRY_ONE);
  
  type JMPCTRL is (NO_SAVE, SAVE_JMP, SAVE_EXC);

  type STACTRL is (SET_FLAG, SET_COND, SAVE_SR, REST_SR);



  constant GIE    : integer := 7;
  constant SLEEP  : integer := 6;
  --  constant CPROT0 : integer := 5;
  constant COND   : integer := 4;
  constant ZERO   : integer := 3;
  constant NEG    : integer := 2;
  constant CARRY  : integer := 1;
  constant OVER   : integer := 0;

  type ALUCTRL is (ALU_NOP, ALU_LDLIU, ALU_LDHI,
                   ALU_AND, ALU_OR, ALU_EOR, ALU_ADD,
                   ALU_SUB, ALU_CMPEQ, ALU_CMPUGT, ALU_CMPULT,
                   ALU_CMPGT, ALU_CMPLT,
                   ALU_NOT, ALU_NEG,
                   ALU_SL, ALU_SR, ALU_SRA, ALU_RRC, ALU_BYPR1,
                   ALU_BYPR2, ALU_BYPEXC);

  component scarts_core is
    generic (
      CONF : scarts_conf_type);
    port (
      clk   : in  std_ulogic;
      sysrst : in  std_ulogic;
      hold  : in  std_ulogic;
      
      iramo_rdata       : in INSTR;
      irami_wdata       : out INSTR;
      irami_waddr       : out std_logic_vector(CONF.instr_ram_size-1 downto 0);
      irami_wen         : out std_ulogic;
      irami_raddr       : out std_logic_vector(CONF.instr_ram_size-1 downto 0);
      
      regfi_wdata       : out std_logic_vector(CONF.word_size-1 downto 0);
      regfi_waddr       : out std_logic_vector(REGADDR_W-1 downto 0);
      regfi_wen         : out std_ulogic;
      regfi_raddr1      : out std_logic_vector(REGADDR_W-1 downto 0);
      regfi_raddr2      : out std_logic_vector(REGADDR_W-1 downto 0);
      regfo_rdata1      : in  std_logic_vector(CONF.word_size-1 downto 0);
      regfo_rdata2      : in  std_logic_vector(CONF.word_size-1 downto 0);
      
      corei_interruptin : in  std_logic_vector(15 downto 0);
      corei_extdata     : in  std_logic_vector(CONF.word_size-1 downto 0);
      coreo_extwr       : out std_ulogic;
      coreo_signedac    : out std_ulogic;
      coreo_extaddr     : out std_logic_vector(CONF.word_size-1 downto 0);
      coreo_extdata     : out std_logic_vector(CONF.word_size-1 downto 0);
      coreo_memaccess   : out MEMACCESSTYPE;
      coreo_memen       : out std_ulogic;
      coreo_illop       : out std_ulogic;
      
      bromi_addr        : out std_logic_vector(CONF.word_size-1 downto 0);
      bromo_data        : in  INSTR;
      
      vecti_data_in     : out std_logic_vector(CONF.word_size-1 downto 0);
      vecti_interruptnr : out std_logic_vector(EXCADDR_W-2 downto 0);
      vecti_trapnr      : out std_logic_vector(EXCADDR_W-1 downto 0);
      vecti_wrvecnr     : out std_logic_vector(EXCADDR_W-1 downto 0);
      vecti_intcmd      : out std_ulogic;
      vecti_wrvecen     : out std_ulogic;    
      vecto_data_out    : in  std_logic_vector(CONF.word_size-1 downto 0);
      
      sysci_staen       : out std_ulogic;
      sysci_stactrl     : out STACTRL;
      sysci_staflag     : out std_logic_vector(ALUFLAG_W-1 downto 0);
      sysci_interruptin : out std_logic_vector(15 downto 0);
      sysci_fptrwnew    : out std_logic_vector(CONF.word_size-1 downto 0);
      sysci_fptrxnew    : out std_logic_vector(CONF.word_size-1 downto 0);
      sysci_fptrynew    : out std_logic_vector(CONF.word_size-1 downto 0);
      sysci_fptrznew    : out std_logic_vector(CONF.word_size-1 downto 0);
      
      sysco_condflag    : in  std_ulogic;
      sysco_carryflag   : in  std_ulogic;
      sysco_interruptnr : in  std_logic_vector(EXCADDR_W-2 downto 0);
      sysco_intcmd      : in  std_ulogic;
      sysco_fptrw       : in  std_logic_vector(CONF.word_size-1 downto 0);
      sysco_fptrx       : in  std_logic_vector(CONF.word_size-1 downto 0);
      sysco_fptry       : in  std_logic_vector(CONF.word_size-1 downto 0);
      sysco_fptrz       : in  std_logic_vector(CONF.word_size-1 downto 0);
      
      progo_instrsrc    : in  std_ulogic;
      progo_prupdate    : in  std_ulogic;
      progo_praddr      : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
      progo_prdata      : in  INSTR);
  end component scarts_core;


  component scarts_iram
    generic (
      CONF : scarts_conf_type);
    port (
      wclk        : in  std_ulogic;
      rclk        : in  std_ulogic;
      hold        : in  std_ulogic;
      wdata       : in  INSTR;
      waddr       : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
      wen         : in  std_ulogic;
      raddr       : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
      rdata       : out INSTR);
  end component;

  component scarts_regfram
    generic (
      CONF : scarts_conf_type);
    port (
      wclk        : in  std_ulogic;
      rclk        : in  std_ulogic;
      enable      : in  std_ulogic;
      
      wdata       : in  std_logic_vector(CONF.word_size-1 downto 0);
      waddr       : in  std_logic_vector(REGADDR_W-1 downto 0);
      wen         : in  std_ulogic;
      raddr       : in  std_logic_vector(REGADDR_W-1 downto 0);
      rdata       : out std_logic_vector(CONF.word_size-1 downto 0));
  end component;
  
  component scarts_regf
    generic (
      CONF : scarts_conf_type);
    port (
      wclk        : in  std_ulogic;
      rclk        : in  std_ulogic;
      hold        : in  std_ulogic;

      wdata       : in  std_logic_vector(CONF.word_size-1 downto 0);
      waddr       : in  std_logic_vector(REGADDR_W-1 downto 0);
      wen         : in  std_ulogic;
      raddr1      : in  std_logic_vector(REGADDR_W-1 downto 0);
      raddr2      : in  std_logic_vector(REGADDR_W-1 downto 0);
                  
      rdata1      : out std_logic_vector(CONF.word_size-1 downto 0);
      rdata2      : out std_logic_vector(CONF.word_size-1 downto 0));
  end component;

  component scarts_brom
    generic (
      CONF : scarts_conf_type);
    port (
      clk     : in  std_ulogic;
      hold    : in  std_ulogic;
      addr    : in  std_logic_vector(CONF.word_size-1 downto 0);
      data    : out INSTR);
  end component;

  component scarts_vectab is
    generic (
      CONF : scarts_conf_type);
    port (
      clk         : in  std_ulogic;
      hold        : in  std_ulogic;
      data_in     : in  std_logic_vector(CONF.word_size-1 downto 0);
      interruptnr : in  std_logic_vector(EXCADDR_W-2 downto 0);
      trapnr      : in  std_logic_vector(EXCADDR_W-1 downto 0);
      wrvecnr     : in  std_logic_vector(EXCADDR_W-1 downto 0);
      intcmd      : in  std_ulogic;
      wrvecen     : in  std_ulogic;
      data_out    : out std_logic_vector(CONF.word_size-1 downto 0));
  end component;

  component scarts_sysc
    generic (
      CONF : scarts_conf_type);
    port (
      clk               : in  std_ulogic;
      extrst            : in  std_ulogic;
      sysrst            : out std_ulogic;
      hold              : in  std_ulogic;
      cpu_halt          : out std_ulogic;
      extsel            : in  std_ulogic;
      exti              : in  module_in_type;
      exto              : out module_out_type;


      staen       : in  std_ulogic;
      stactrl     : in  STACTRL;
      staflag     : in  std_logic_vector(ALUFLAG_W-1 downto 0);
      interruptin : in  std_logic_vector(15 downto 0);
      fptrwnew    : in  std_logic_vector(CONF.word_size-1 downto 0);
      fptrxnew    : in  std_logic_vector(CONF.word_size-1 downto 0);
      fptrynew    : in  std_logic_vector(CONF.word_size-1 downto 0);
      fptrznew    : in  std_logic_vector(CONF.word_size-1 downto 0);
      
      condflag    : out std_ulogic;
      carryflag   : out std_ulogic;
      interruptnr : out std_logic_vector(EXCADDR_W-2 downto 0);
      intcmd      : out std_ulogic;
      fptrw       : out std_logic_vector(CONF.word_size-1 downto 0);
      fptrx       : out std_logic_vector(CONF.word_size-1 downto 0);
      fptry       : out std_logic_vector(CONF.word_size-1 downto 0);
      fptrz       : out std_logic_vector(CONF.word_size-1 downto 0));
  end component;

  component scarts_prog
    generic (
      CONF : scarts_conf_type);
    port (
      clk         : in  std_ulogic;
      extrst      : in  std_ulogic;
      progrst     : out std_ulogic;
      hold        : in  std_ulogic;
      extsel      : in  std_ulogic;
      exti        : in  module_in_type;
      exto        : out module_out_type;
      
      instrsrc    : out std_ulogic;
      prupdate    : out std_ulogic;
      praddr      : out std_logic_vector(CONF.instr_ram_size-1 downto 0);
      prdata      : out INSTR);
  end component;

  component scarts_byteram
    generic (
      CONF : scarts_conf_type);
    port (
      wclk        : in  std_ulogic;
      rclk        : in  std_ulogic;
      enable      : in  std_ulogic;
      
      wdata       : in  std_logic_vector(7 downto 0);
      waddr       : in  std_logic_vector((CONF.data_ram_size-3) downto 0);
      wen         : in  std_ulogic;
      raddr       : in  std_logic_vector((CONF.data_ram_size-3) downto 0);
      rdata       : out std_logic_vector(7 downto 0)
      );
  end component;

  component scarts_dram
    generic (
      CONF : scarts_conf_type);
    port (
      clk     : in  std_ulogic;
      hold    : in  std_ulogic;
      dramsel : in  std_ulogic;

      write_en  : in  std_ulogic;
      byte_en   : in  std_logic_vector(3 downto 0);
      data_in   : in  std_logic_vector(31 downto 0);
      addr      : in  std_logic_vector(CONF.data_ram_size-1 downto 2);
      
      data_out  : out std_logic_vector(31 downto 0));
  end component;
  
  --
  --  ALTERA components
  --
  component altera_boot_rom
    generic (
      CONF : scarts_conf_type);
    port(
      address	: in  std_logic_vector(15 DOWNTO 0);
      clken       : in  std_logic;
      clock       : in  std_logic;
      q           : out std_logic_vector(15 DOWNTO 0)
      );
  end component;

--
--  XILINX components
--
--  component xilinx_instr_rom
--    port(
--      clk     : in  std_ulogic;
--      enable  : in  std_ulogic;
--      addr    : in  std_logic_vector(15 downto 0);
--      data    : out std_logic_vector(15 downto 0)
--      );
--  end component;

--  component xilinx_vectab_ram
--    port(
--      clk     : in  std_ulogic;
--      enable  : in  std_ulogic;
--      raddr   : in  std_logic_vector(EXCADDR_W-1 downto 0);
--      rdata   : out std_logic_vector(WORD_W-1 downto 0);
--      waddr   : in  std_logic_vector(EXCADDR_W-1 downto 0);
--      wdata   : in  std_logic_vector(WORD_W-1 downto 0);
--      wen     : in  std_ulogic
--      );
--  end component;

--  component xilinx_data_ram
--    port(
--      clk     : in  std_ulogic;
--      enable  : in  std_ulogic;
--      ram0i   : in  byteram_in_type;
--      ram0o   : out byteram_out_type;
--      ram1i   : in  byteram_in_type;
--      ram1o   : out byteram_out_type;
--      ram2i   : in  byteram_in_type;
--      ram2o   : out byteram_out_type;
--      ram3i   : in  byteram_in_type;
--      ram3o   : out byteram_out_type
--      );
--  end component;


  component ext_breakpoint
    generic (
      CONF : scarts_conf_type);
    port (
      clk              : IN  std_logic;
      extsel           : in  std_ulogic;
      exti             : in  module_in_type;
      exto             : out module_out_type;
      -- Modul specific interface (= Pins)
      debugo_wdata     : in  INSTR;
      debugo_waddr     : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
      debugo_wen       : in  std_ulogic;
      debugo_raddr     : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
      debugo_rdata     : in  INSTR;
      debugo_read_en   : in  std_ulogic;
      debugo_hi_addr   : in  std_logic_vector(CONF.word_size-1 downto 15);
      debugi_rdata     : out INSTR;
      watchpoint_act   : in std_ulogic);
    end component;  

  component ext_watchpoint
    generic (
      CONF : scarts_conf_type);
    port (
      clk     : IN  std_logic;
      extsel  : in  std_ulogic;
      exti    : in  module_in_type;
      exto    : out module_out_type;
      -- Modul specific interface (= Pins) 
      read_en : in std_ulogic;
      hi_addr : in std_logic_vector(CONF.word_size-1 downto 15) --lower 15 bits in exti.addr
      );
  end component;



  -------------------------------------------------------------------------------
  -- AMBA Part
  -------------------------------------------------------------------------------
 
  -- Position of Registers of the 32-bit Generic Interface
  constant STATUSREG_GEN   : integer := 0;
  constant STATUSREG_CUST  : integer := 1;
  constant CONFIGREG_GEN   : integer := 2;
  constant CONFIGREG_CUST  : integer := 3;
  constant SLOT1_CONFIG    : integer := 4;
  constant SLOT1_MEMOFFSET : integer := 5;
  constant SLOT2_CONFIG    : integer := 6;
  constant SLOT2_MEMOFFSET : integer := 7;
  constant SLOT1_AMBAADDR  : integer := 8;
  constant SLOT2_AMBAADDR  : integer := 12;
  
  -- Bitposition of flags in corresponding register
  constant CFG_READ_WRITE  : integer := 5;
  constant CFG_START       : integer := 4;
  constant CFG_MASKINT     : integer := 3;
  constant CFG_ACCTYPE     : integer := 0;
  constant CFG_MEMOFFSET   : integer := 0;
  constant STA_READY_1     : integer := 7;
  constant STA_SUCCESS_1   : integer := 6;
  constant STA_ERROR_1     : integer := 5;
  constant STA_READY_2     : integer := 4;
  constant STA_SUCCESS_2   : integer := 3;
  constant STA_ERROR_2     : integer := 2;
  constant STA_SUCCESS_T   : integer := 1;
  constant STA_ERROR_T     : integer := 0;

  -- Bridge Signalflow SCARTS to AMBA
  type brg_scarts_to_amba_type is record
    sHBUSREQ : STD_LOGIC;
    sBADDR : STD_LOGIC_VECTOR (31 downto 0);
    sHADDR : STD_LOGIC_VECTOR (31 downto 0);
    sMRDATA : STD_LOGIC_VECTOR (31 downto 0);
    sHWRITE : STD_LOGIC;
    sHSIZE : STD_LOGIC_VECTOR (2 downto 0);
    sWAIT : STD_LOGIC;
  end record;

  -- Bridge Signalflow AMBA to AMBA
  type brg_amba_to_scarts_type is record
    sMADDR : STD_LOGIC_VECTOR (31 downto 0);
    sMWDATA : STD_LOGIC_VECTOR (31 downto 0);
    sMWRITE : STD_LOGIC;
    sByteEn : STD_LOGIC_VECTOR (3 downto 0);
    sERROR : STD_LOGIC;
    sFinished : STD_LOGIC;
    sBusRequest : STD_LOGIC;
    sIRQ : STD_LOGIC_VECTOR (7 downto 0);
  end record;

  -- component declaration for shared memory byte ram
  component AMBA_sharedmem_byteram is
    generic (
      CONF : scarts_conf_type);
    port (
      wclk        : in  std_ulogic;
      rclk        : in  std_ulogic;
      
      wdata       : in  std_logic_vector(7 downto 0);
      waddr       : in  std_logic_vector((CONF.amba_shm_size - CONF.amba_word_size/16-1) downto 0);
      wen         : in  std_ulogic;
      raddr       : in  std_logic_vector((CONF.amba_shm_size - CONF.amba_word_size/16-1) downto 0);
      
      rdata       : out std_logic_vector(7 downto 0));
  end component AMBA_sharedmem_byteram;
    

  -- component declaration for shared memory dram
  component AMBA_sharedmem_dram is
    generic (
      CONF : scarts_conf_type);
    port (
      clk     : in  std_ulogic;
      dramsel : in  std_ulogic;
      
      write_en  : in  std_ulogic;
      byte_en   : in  std_logic_vector(3 downto 0);
      data_in   : in  std_logic_vector(CONF.word_size-1 downto 0);
      addr      : in  std_logic_vector(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      data_out  : out std_logic_vector(CONF.word_size-1 downto 0));
  end component AMBA_sharedmem_dram;
    
  -- component declaration for shared memory
  component ext_AMBA_sharedmem is
    generic (
      CONF : scarts_conf_type);
    port (
      clk          : in  std_ulogic;
      rst          : in  std_ulogic;
      --ren          : in  std_ulogic;
      ambadramsel  : in  std_ulogic;
      ambadramlock : in  std_ulogic;
      exti         : in  module_in_type;
      exto         : out module_out_type;

      adrami_write_en  : in  std_ulogic;
      adrami_byte_en   : in  std_logic_vector(3 downto 0);
      adrami_data_in   : in  std_logic_vector(CONF.word_size-1 downto 0);
      adrami_addr      : in  std_logic_vector(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      adramo_data_out  : out std_logic_vector(CONF.word_size-1 downto 0));
  end component;

  -- Componentdeclaration for AMBA Extension-Module
  component ext_AMBA
    generic(
      CONF       : scarts_conf_type;
      DRAMOffset : bit_vector(31 downto 8) := (others => '0')
      );
    port(
      -- normal signals
      clk          : in  STD_ULOGIC;
      rst          : in  STD_ULOGIC;
      extsel       : in  STD_ULOGIC;
      ambadramlock : out STD_ULOGIC;
      transmode    : in  STD_ULOGIC;
      -- Extension-Module Interface
      exti         : in  module_in_type;
      exto         : out module_out_type;
      addr_high    : in  std_logic_vector(31 downto 15);
      -- Gaisler Interrupt
      gIRQ         : out STD_ULOGIC;
      -- stall processor
      scarts_hold    : out STD_ULOGIC;
      -- AMBA-Interface
      AMBAI        : in  ahb_master_in_type;
      AMBAO        : out ahb_master_out_type;
      -- DRAM-Interface
      --ambadram_ren : out STD_ULOGIC;

      AtD_write_en  : out std_ulogic;
      AtD_byte_en   : out std_logic_vector(3 downto 0);
      AtD_data_in   : out std_logic_vector(CONF.word_size-1 downto 0);
      AtD_addr      : out std_logic_vector(CONF.amba_shm_size-1 downto CONF.amba_word_size/16);
      DtA_data_out  : in  std_logic_vector(CONF.word_size-1 downto 0)
      );
  end component;

  -- Componentdeclaration for AMBA-Statemachine
  component AMBA_AHBMasterStatemachine
    port(HRESET : in STD_ULOGIC;
         HCLK  : in STD_ULOGIC;
         -- AHB Master Input
         AMBAI : in ahb_master_in_type;
         -- AHB Master Output
         AMBAO : out ahb_master_out_type;
         -- Bridge Signalflow SCARTS to AMBA
         BStA  : in brg_scarts_to_amba_type;
         -- Bridge Signalflow AMBA to SCARTS
         BAtS  : out brg_amba_to_scarts_type);
  end component;

  -------------------------------------------------------------------------------
  -- MiniUART
  -------------------------------------------------------------------------------  
  constant DATA_W        : integer := 16;
  constant EXTREG_S      : integer := 8;
  
  constant EXT_ACT : std_logic := '1';
  
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                             KONSTANTEN
-------------------------------------------------------------------------------  
-------------------------------------------------------------------------------

  -- globale Konstanten TODO: nur für einzelne Tests!
  --constant EXT_ACT         : std_logic := '1';
  constant OUTD_ACT : std_logic := '1';  -- Output Disable
  constant FAILSAFE : std_logic := '1';  -- Failsafestate
 
--  constant MINIUART_BASE : integer := 51;  --TODO: richtige BaseAddr herausfinden!!!
--  constant MINIUART_INTVEC : std_logic_vector(16-1 downto 0) := (others => '0');

  -- Register allgemein
--   constant DATA0        : integer := 2;
--   constant DATA1        : integer := 3;
--   constant DATA2        : integer := 4;
--   constant DATA3        : integer := 5;
--   constant DATA4        : integer := 6;
--   constant DATA5        : integer := 7;
  constant MSGREG_LOW   : integer := 6;--DATA2;   -- Message register
  constant MSGREG_HIGH  : integer := 7;--DATA2;   -- Message register
  constant UBRSREG_LOW  : integer := 4;--DATA5;  -- UART Baud Rate Selection Register
  constant UBRSREG_HIGH : integer := 5;--DATA5;  -- UART Baud Rate Selection Register

  --constant STATUSREG_CUST      : integer := 1; -- Already defined
--  constant CONFIGREG_CUST      : integer := 3; -- Already defined
  -- Statusregister
--constant EXTSTATUS    : integer := 0;
--  constant EXTSTATUS_CUST    : integer := 1;
  constant STA_TRANSERR  : integer := 6;--14;
  constant STA_PARERR    : integer := 5;--13;f
  constant STA_EVF       : integer := 4;--12;
  constant STA_OVF       : integer := 3;--11;
  constant STA_RBR       : integer := 2;--10;
  constant STA_TBR       : integer := 1;--9;     
--constant ST_LOOR      : integer := 7;
--constant ST_FSS       : integer := 4;
--constant ST_BUSY      : integer := 3;
--constant ST_ERR       : integer := 2;
--constant ST_RDY       : integer := 1;
--constant ST_INT       : integer := 0;

  -- Configregister
--constant EXTCONFIG      : integer := 1;
--constant EXTCONF_LOOW    : integer := 7;
--constant EXTCONF_EFSS    : integer := 4;
constant EXTCONF_OUTD    : integer := 3;
--constant EXTCONF_SRES    : integer := 2;
--constant EXTCONF_ID      : integer := 1;
--constant EXTCONF_INTA    : integer := 0;

  -- UARTConfigregister
  constant EXTUARTCONF         : integer := CONFIGREG_CUST;--4; --DATA0;
  constant EXTCONF_PARENA      : integer := 7;--15;
  constant EXTCONF_PARODD      : integer := 6;--14;
  constant EXTCONF_STOP        : integer := 5;--13;
  constant EXTCONF_TRCTRL      : integer := 4;--12;
  constant EXTCONF_MSGL_H      : integer := 3;--11;
  constant EXTCONF_MSGL_L      : integer := 0;--8;

  -- Commandregister
  constant EXTCMD          : integer := 8;--DATA1;  
  constant EXTCMD_ERRI    : integer := 7;
  constant EXTCMD_EI      : integer := 6;
  constant EXTCMD_ASA_H   : integer := 5;
  constant EXTCMD_ASA_L   : integer := 3;
  constant EXTCMD_EVS_H   : integer := 2;
  constant EXTCMD_EVS_L   : integer := 1;

  -- Config & Statusbits
  constant PARITY_ENABLE : std_logic := '1';  -- Parity enabled
  constant SECOND_STOPBIT : std_logic := '1';  -- Zweites Stopbit enabled
  constant RB_READY : std_logic := '1';  -- Receive Buffer Ready
  constant TB_READY : std_logic := '1';  -- Transmit Buffer Ready
  constant FRAME_ERROR : std_logic := '1';  -- !!!ACHTUNG: FE ist immer 1!!!
  constant PARITY_ERROR : std_logic := '1';  -- Parity Error
  constant OVERFLOW : std_logic := '1';  -- Overflow occured
  constant TRCTRL_ENA : std_logic := '1';  -- Error Control enabled
  

  -- Transmitter
  constant TRANS_COMP : std_logic := '1';  -- Transmission Complete

  -- Receiver
  constant RECEIVER_ENABLED : std_logic := '1';  -- !!!ACHTUNG: muss 1 sein!!!
  constant REC_BUSY : std_logic := '1';  -- Receiving / Startbit detected
  constant REC_COMPLETE : std_logic := '1';  -- komplette Nachricht empfangen

  -- Busdriver
  constant BUSDRIVER_ON : std_logic := '1';  -- Einschaltsignal für Busdriver

  -- Baud Rate Generator
  constant BRG_ON : std_logic := '1';     -- Einschaltsignal für BRG

  -- Events
  constant EV_NONE  : std_logic_vector(1 downto 0) := "00";  -- no event
  constant EV_SBD   : std_logic_vector(1 downto 0) := "01";  -- Startbitdetection
  constant EV_RCOMP : std_logic_vector(1 downto 0) := "10";  -- Receive completion
  constant EV_TCOMP : std_logic_vector(1 downto 0) := "11";  -- Transmit completion
  constant EV_OCC : std_logic := '1';     -- Event occured (muß 1 sein!!!)
  constant EV_INT : std_logic := '1';   -- Event Interrupt enable

  -- Assigned Actions
  constant ASA_STRANS : std_logic_vector(2 downto 0) := "011";  -- start transmission
  constant ASA_EREC : std_logic_vector(2 downto 0) := "100";  -- enable receiver
  constant ASA_DREC : std_logic_vector(2 downto 0) := "101";  -- disable receiver


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                               TYPES
-------------------------------------------------------------------------------  
-------------------------------------------------------------------------------

  -- Messagelength Signaltyp
  subtype MsgLength_type is std_logic_vector((EXTCONF_MSGL_H - EXTCONF_MSGL_L) downto 0);

  -- Nachricht
  subtype Data_type is std_logic_vector(15 downto 0);
  
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                             KOMPONENTEN
-------------------------------------------------------------------------------  
-------------------------------------------------------------------------------

  component ext_miniUART IS
         PORT(   ---------------------------------------------------------------
                -- Generic Ports
                ---------------------------------------------------------------
                clk           : IN  std_logic; 	
                extsel        : in  std_logic;
                Exti          : in module_in_type;
                Exto          : out module_out_type;
                
                ---------------------------------------------------------------
                -- Module Specific Ports
                ---------------------------------------------------------------
                RxD           : IN std_logic;  -- Empfangsleitung
                TxD           : OUT std_logic  --;  -- Sendeleitung
                );
  END component;


  component miniUART_control  
    port (
      clk : in std_logic;
      reset : in std_logic;               
--      MsgLength : in MsgLength_type;      
      ParEna : in std_logic;              -- Parity?
      Odd : in std_logic;                 -- Odd or Even Parity?
      AsA : in std_logic_vector(2 downto 0);  -- Assigned Action
      EvS : in std_logic_vector(1 downto 0);  -- Event Selector
      Data_r : in Data_type;              -- received Data
      ParBit_r : in std_logic;            -- empfangenes Paritybit
      FrameErr : in std_logic;
      RecComp : in std_logic;             -- Receive Complete
      RecBusy : in std_logic;             -- Reciever Busy (Startbit detected)        
      TransComp : in std_logic;           -- Transmission complete
      EnaRec : out std_logic;             -- Enable receiver
      Data_r_out : out Data_type;         -- empfangene Daten
      FrameErr_out : out std_logic;
      ParityErr : out std_logic;
      RBR : out std_logic;                -- Receive Buffer Ready (Rec Complete)
      StartTrans : out std_logic;         -- Start Transmitter (halten bis TrComp!)
      TBR : out std_logic;                -- Transmit Buffer Ready (MSGREG read,
                                          -- transmitter started)
      event : out std_logic               -- Selected Event occured!
      );
  end component;


  component miniUART_transmitter
    port (
      clk : in std_logic;
      reset : in std_logic;               
      MsgLength : in MsgLength_type;      
      Stop2 : in std_logic;               -- Zweites Stopbit?
      ParEna : in std_logic;              -- Parity?
      ParBit : in std_logic;              -- Vorberechnetes Paritybit
      Data : in Data_type;
      tp : in std_logic;                  -- Transmitpulse vom BRG
      TransEna : out std_logic;           -- Busdriver einschalten
      TrComp : out std_logic;              -- Transmission complete
      TxD : out std_logic                 -- Sendeausgang
      );
  end component;


  component miniUART_receiver
    port (
      clk : in std_logic;
      reset : in std_logic;               
      enable : in std_logic;              -- Receiver eingeschaltet?
      MsgLength : in MsgLength_type;      
      Stop2 : in std_logic;               -- Zweites Stopbit?
      ParEna : in std_logic;              -- Parity?
      rp : in std_logic;                  -- Receivepulse vom BRG
      RxD : in std_logic;                 -- Empfangseingang
      Data : out Data_type;
      ParBit : out std_logic;             -- Empfangenes Paritybit
      RecEna : out std_logic;             -- Busdriver einschalten
      StartRecPulse : out std_logic;      -- Receivepulse generieren
      busy : out std_logic;               -- Receiving / Startbit detected
      RecComplete : out std_logic;        -- komplettes Frame empfangen
      FrameErr : out std_logic         
      );
  end component;


  component miniUART_BRG  
    port (
      clk : in std_logic;
      reset : in std_logic;               
      StartTrans : in std_logic;          -- Transmitterpulse eingeschaltet?
      StartRec : in std_logic;            -- Receiverpulse eingeschaltet?
      UBRS : in std_logic_vector(15 downto 0);  -- Baud Rate Selection Register 
                                                -- (12bit ganzzahlig, 4bit fraction)
      tp : out std_logic;                 -- Transmitterpulse
      rp : out std_logic                  -- Receiverpulse
      );
  end component;


  component miniUART_busdriver
    port (
      clk : in std_logic;
      reset : in std_logic;               
      OutD : in std_logic;                -- Output disable
      TransEna : in std_logic;            -- Einschalten, von Transmitter
      RecEna : in std_logic;              -- Einschalten, von Receiver
      Data_t : in std_logic;              -- zu sendendes Bit
      Data_r : out std_logic;             -- empfangenes Bit
      TxD : out std_logic;                -- Sendeleitung
      RxD : in std_logic                  -- Empfangsleitung
      );
  end component;

  
end scarts_core_pkg;
