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

use work.scarts_amba_pkg.all;

--library grlib;
--use grlib.amba.all;

package scarts_pkg is 

  -- supported technologies
  constant NTECH : natural := 2;
  type tech_type is array (0 to NTECH) of natural;
  
  constant NO_TARGET  : natural := 0;
  constant XILINX     : natural := 1;
  constant ALTERA     : natural := 2;

  type scarts_conf_type is record
    --
    --  Specify the target technology
    --
    tech : natural range 0 to NTECH;

    --
    --  word_size == 1  =>  16 bit configuration
    --
    --  word_size == 2  =>  32 bit configuration
    --
    word_size : natural range 16 to 32;

    --
    --  Defines the size of the boot rom
    --  Size is 2**boot_rom_size instructions
    --
    boot_rom_size : natural range 0 to 16;

    --
    --  Defines the size of the instruction memory
    --  Size is 2**instr_ram_cfg instructions
    --  Range for 16 bit version is only 5 to 16
    --
    instr_ram_size : natural range 5 to 32;

    --
    --  Defines the size of the data memory
    --  Size is 2**data_ram_size bytes
    --  Range for 16 bit version is only 5 to 16
    --
    data_ram_size : natural range 5 to 32;

    --
    --  Defines if the instruction memory and 
    --  programmer are used
    --
    use_iram : boolean;

    --
    --  Defines if the AMBA modules should be loaded
    --
    use_amba : boolean;

    --
    -- Defines size of AMBA shared memory (2**amba_shm_size bytes)
    --
    amba_shm_size    : natural;

    --
    -- Defines word size for AMBA bus
    --
    amba_word_size   : natural;
    
    --
    --  Configures the SCARTS-Core, so that it can execute the GDB remote-stub.
    --  The Boot-ROM is always visible and mapped directly after the instruction-ram.
    --  Execution does not start at Instruction-Adress 0x0, but at the first Boot-ROM instruction.
    --
    gdb_mode : natural range 0 to 1;

    --
    --  Defines the address where the boot-rom is mapped to.
    --  Boot-Rom starts at 2**bootrom_base_address.
    --  Range for 16 bit version is only 5 to 15
    --
    bootrom_base_address : natural range 5 to 31;
    
  end record;

  type scarts_in_type is record
    hold        : std_ulogic;
    interruptin : std_logic_vector(7 downto 0);
    data        : std_logic_vector(31 downto 0);
  end record;
  
  type scarts_out_type is record
    reset     : std_ulogic;
    data      : std_logic_vector(31 downto 0);
    addr      : std_logic_vector(14 downto 0);
    byte_en   : std_logic_vector(3 downto 0);
    write_en  : std_ulogic;
    extsel    : std_ulogic;
    cpu_halt  : std_ulogic;
  end record;

  type debug_if_out_type is record
    D_TxD : std_ulogic;
  end record;


  type debug_if_in_type is record
    D_RxD : std_ulogic;
  end record;

  --
  -- Scarts component declaration
  --
  
  component scarts is
  generic (
    CONF : scarts_conf_type);
  port (
    clk       : in  std_ulogic;
    extrst    : in  std_ulogic;
    sysrst    : out std_ulogic;
    --Extensiom Module Interface                                                                                                                                                                               
    scarts_i    : in  scarts_in_type;
    scarts_o    : out scarts_out_type;

    -- AMBA Interface                                                                                                                                                                                          
    ahbmi     : in  ahb_master_in_type;
    ahbmo     : out ahb_master_out_type;
        
--    ahbsl2sp  : in  ahb_slv_out_vector_type(NAHBSLV-1 downto 1);
--    ahbsp2sl  : out ahb_slv_in_type;
--    apbsl2sp  : in  apb_slv_out_vector;
--    apbsp2sl  : out apb_slv_in_type;
    -- Debug Interface                                                                                                                                                                                         
    debugi_if : IN  debug_if_in_type;
    debugo_if : OUT debug_if_out_type);
  end component scarts;


  --
  -- Declarations for extension modules
  --

  type module_in_type is record
    reset     : std_ulogic;
    write_en  : std_ulogic;
    byte_en   : std_logic_vector(3 downto 0);
    data      : std_logic_vector(31 downto 0);
    addr      : std_logic_vector(14 downto 0);
  end record;

  type module_out_type is record
    data      : std_logic_vector(31 downto 0);
    intreq    : std_ulogic;
  end record;

  constant MODULE_OUT_VOID : module_out_type := ((others => '0'), '0');  

  constant RST_ACT            : std_ulogic := '0';
  constant EXT_SEL            : std_ulogic := '1';
  
  constant STATUSREG      : integer := 0;
  constant CONFIGREG      : integer := 2;
  
  constant DATA0          : integer := 2;
  constant DATA1          : integer := 3;
  constant DATA2          : integer := 4;
  constant DATA3          : integer := 5;
  constant DATA4          : integer := 6;
  constant DATA5          : integer := 7;

  -- Status Register Flags
  constant STA_LOOR       : integer := 7;
  constant STA_RESH       : integer := 6;
  constant STA_RESL       : integer := 5;
  constant STA_FSS        : integer := 4;
  constant STA_BUSY       : integer := 3;
  constant STA_ERR        : integer := 2;
  constant STA_RDY        : integer := 1;
  constant STA_INT        : integer := 0;

  -- Control Register Flags
  constant CONF_LOOW     : integer := 7;
  constant CONF_RESH     : integer := 6;
  constant CONF_RESL     : integer := 5;
  constant CONF_EFSS     : integer := 4;
  constant CONF_OUTD     : integer := 3;
  constant CONF_SRES     : integer := 2;
  constant CONF_ID       : integer := 1;
  constant CONF_INTA     : integer := 0;

  constant MODULE_ID      : std_logic_vector(15 downto 0) := "0000000000000000";
  constant MODULE_VER     : std_logic_vector(15 downto 0) := "0000000000000000";

  constant CONF_PREXE         : integer := 7;

  constant CONF_INSTRSRC      : integer := 0;
  constant CONF_CLR           : integer := 1;

end scarts_pkg;
