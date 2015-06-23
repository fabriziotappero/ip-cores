-------------------------------------------------------------------------------
-- File: rise_pack.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Package for RISE project.
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use work.RISE_PACK_SPECIFIC.all;

package RISE_PACK is

  constant ARCHITECTURE_WIDTH : integer := 16;
  constant REGISTER_COUNT : integer := 16;
  
  constant PC_WIDTH : integer := ARCHITECTURE_WIDTH;
  constant IR_WIDTH : integer := ARCHITECTURE_WIDTH;
  constant SR_WIDTH : integer := ARCHITECTURE_WIDTH;
  constant MEM_DATA_WIDTH : integer := ARCHITECTURE_WIDTH;
  constant MEM_ADDR_WIDTH : integer := ARCHITECTURE_WIDTH;
  
  constant REGISTER_WIDTH : integer := ARCHITECTURE_WIDTH;
  constant REGISTER_ADDR_WIDTH : integer := 4;
  constant IMMEDIATE_WIDTH : integer := ARCHITECTURE_WIDTH;
  constant LOCK_WIDTH : integer := REGISTER_COUNT;

  constant ALUOP1_WIDTH : integer := 3;
  constant ALUOP2_WIDTH : integer := 3;
  
  subtype PC_REGISTER_T is std_logic_vector(PC_WIDTH-1 downto 0);
  subtype IR_REGISTER_T is std_logic_vector(IR_WIDTH-1 downto 0);
  subtype SR_REGISTER_T is std_logic_vector(SR_WIDTH-1 downto 0);
  subtype REGISTER_T is std_logic_vector(REGISTER_WIDTH-1 downto 0);
  subtype REGISTER_ADDR_T is std_logic_vector(REGISTER_ADDR_WIDTH-1 downto 0);
  subtype MEM_DATA_T is std_logic_vector(MEM_DATA_WIDTH-1 downto 0);
  subtype MEM_ADDR_T is std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);

  subtype LOCK_REGISTER_T is std_logic_vector(LOCK_WIDTH-1 downto 0);
  
  subtype IMMEDIATE_T is std_logic_vector(IMMEDIATE_WIDTH-1 downto 0);

  subtype ALUOP1_T is std_logic_vector(ALUOP1_WIDTH-1 downto 0);
  subtype ALUOP2_T is std_logic_vector(ALUOP2_WIDTH-1 downto 0);

  --
  constant SR_REGISTER_ADDR : REGISTER_ADDR_T := "1111";
  constant PC_REGISTER_ADDR : REGISTER_ADDR_T := "1110";
  constant LR_REGISTER_ADDR : REGISTER_ADDR_T := "1101";
  
  constant SR_REGISTER_DI : INTEGER := 15;
  constant SR_REGISTER_IP_MASK : INTEGER := 12;
  constant SR_REGISTER_OVERFLOW : INTEGER := 3;
  constant SR_REGISTER_NEGATIVE : INTEGER := 2;
  constant SR_REGISTER_CARRY : INTEGER := 1;
  constant SR_REGISTER_ZERO : INTEGER := 0;
  constant RESET_PC_VALUE : PC_REGISTER_T := ( others => '0' );
  constant RESET_SR_VALUE : PC_REGISTER_T := ( others => '0' );

  constant PC_ADDR : REGISTER_ADDR_T := CONV_STD_LOGIC_VECTOR(14, REGISTER_ADDR_WIDTH);
  
  constant PC_RESET_VECTOR : MEM_ADDR_T := x"FFFE";
  
  
  -- STATUS REGISTER BITS --
  constant SR_ZERO_BIT          : integer := 0;
  constant SR_CARRY_BIT         : integer := 1;
  constant SR_NEGATIVE_BIT      : integer := 2;
  constant SR_OVERFLOW_BIT      : integer := 3;
  
  type IF_ID_REGISTER_T is record
                             pc : PC_REGISTER_T;
                             ir : IR_REGISTER_T;
                           end record;

  type ID_EX_REGISTER_T is record
                             sr         : SR_REGISTER_T;
                             pc         : PC_REGISTER_T;
                             opcode     : OPCODE_T;
                             cond       : COND_T;
                             rX_addr    : REGISTER_ADDR_T;  
                             rX         : REGISTER_T;
                             rY         : REGISTER_T;
                             rZ         : REGISTER_T;
                             immediate  : IMMEDIATE_T;
                           end record;

  -- bit positions for aluop1
  constant ALUOP1_LD_MEM_BIT : integer := 0;
  constant ALUOP1_ST_MEM_BIT : integer := 1;
  constant ALUOP1_WB_REG_BIT : integer := 2;

  -- bit positions for aluop2
  constant ALUOP2_SR_BIT : integer := 0;
  constant ALUOP2_LR_BIT : integer := 1;

  type EX_MEM_REGISTER_T is record
                              aluop1        : ALUOP1_T;
                              aluop2        : ALUOP2_T;
                              reg           : REGISTER_T;
                              alu           : REGISTER_T;
                              dreg_addr     : REGISTER_ADDR_T;
                              lr            : PC_REGISTER_T;
                              sr            : SR_REGISTER_T;
                            end record;
  
  type MEM_WB_REGISTER_T is record
                              aluop1        : ALUOP1_T;
                              aluop2        : ALUOP2_T;
                              reg           : REGISTER_T;
                              mem_reg       : REGISTER_T;
                              dreg_addr     : REGISTER_ADDR_T;                           
                              lr            : PC_REGISTER_T;
                              sr            : SR_REGISTER_T;
                            end record;
  
    constant CONST_UART_STATUS_ADDRESS: REGISTER_T := x"8000";
	 constant CONST_UART_DATA_ADDRESS: REGISTER_T := x"8001";
end RISE_PACK;

