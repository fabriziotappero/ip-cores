-------------------------------------------------------------------------------
-- File: ex_stage.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Execute stage
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.all;
use work.rise_pack.all;
use work.RISE_PACK_SPECIFIC.all;

entity tb_ex_stage_unit_vhd is
end tb_ex_stage_unit_vhd;

architecture behavior of tb_ex_stage_unit_vhd is

  -- component Declaration for the Unit Under Test (UUT)
  component ex_stage is
                       
                       port (
                         clk                 : in std_logic;
                         reset               : in std_logic;

                         id_ex_register      : in ID_EX_REGISTER_T;
                         ex_mem_register     : out EX_MEM_REGISTER_T;

                         branch              : out std_logic;
                         stall_in            : in std_logic;
                         clear_in            : in std_logic;
                         clear_out           : out std_logic);

  end component;

  constant clk_period : time := 10 ns;

  --inputs
  signal clk            : std_logic := '0';
  signal reset          : std_logic := '0';
  signal id_ex_register : ID_EX_REGISTER_T;

  signal stall_in       : std_logic     := '0';
  signal clear_in       : std_logic     := '0';
  
  --Outputs
  signal ex_mem_register : EX_MEM_REGISTER_T; 
  signal branch          : std_logic;
  signal clear_out       : std_logic;

begin

  -- instantiate the Unit Under Test (UUT)
  uut : ex_stage port map(
    clk            => clk,
    reset          => reset,

    id_ex_register   => id_ex_register,
    ex_mem_register  => ex_mem_register,

    branch           => branch,
    stall_in         => stall_in,
    clear_in         => clear_in,
    clear_out        => clear_out);

  
  cg : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;

  tb : process
  begin
    reset <= '0';
    wait for 10 * clk_period;
    reset <= '1';

    
    id_ex_register.sr <= (others => '0');
    id_ex_register.pc <= CONV_STD_LOGIC_VECTOR(3, PC_WIDTH);
    id_ex_register.opcode <= OPCODE_NOP;
    id_ex_register.cond <= COND_UNCONDITIONAL;
    id_ex_register.rX_addr <= CONV_STD_LOGIC_VECTOR(2, REGISTER_ADDR_WIDTH);
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(0, REGISTER_WIDTH);
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(0, REGISTER_WIDTH);
    id_ex_register.rZ <= CONV_STD_LOGIC_VECTOR(0, REGISTER_WIDTH);
    id_ex_register.immediate <= CONV_STD_LOGIC_VECTOR(0, IMMEDIATE_WIDTH);
    

    ---------------------------------------------------------------------------
    -- test computation results
    ---------------------------------------------------------------------------
    -- load/store
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_LD_IMM;
    id_ex_register.immediate <= CONV_STD_LOGIC_VECTOR(1, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_LD_IMM_HB;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(1, REGISTER_WIDTH);
    id_ex_register.immediate <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_LD_DISP;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);    
    id_ex_register.rZ <= CONV_STD_LOGIC_VECTOR(1, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_LD_DISP_MS;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);    
    id_ex_register.rZ <= CONV_STD_LOGIC_VECTOR(1, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_LD_REG;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(6, REGISTER_WIDTH);    
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_ST_DISP;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);    
    id_ex_register.rZ <= CONV_STD_LOGIC_VECTOR(1, REGISTER_WIDTH);
    wait for clk_period;
    -- arithmetic opcodes
    id_ex_register.opcode <= OPCODE_ADD;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(8, REGISTER_WIDTH);    
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(3, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_ADD;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(-8, REGISTER_WIDTH);    
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_ADD_IMM;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(3, REGISTER_WIDTH);    
    id_ex_register.immediate <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_ADD_IMM;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(3, REGISTER_WIDTH);    
    id_ex_register.immediate <= CONV_STD_LOGIC_VECTOR(-2, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_SUB;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);    
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_SUB;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);    
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(6, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_SUB_IMM;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(-4, REGISTER_WIDTH);    
    id_ex_register.immediate <= CONV_STD_LOGIC_VECTOR(6, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_SUB_IMM;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);    
    id_ex_register.immediate <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_NEG;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_ARS;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_ALS;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);
    -- als with overflow
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_ALS;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(30000, REGISTER_WIDTH);
    -- als with overflow
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_ALS;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(-30000, REGISTER_WIDTH);
    
    -- logical opcodes
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_AND;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);    
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_NOT;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_EOR;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(4, REGISTER_WIDTH);    
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_LS;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(3, REGISTER_WIDTH);
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_RS;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(73, REGISTER_WIDTH);
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(1, REGISTER_WIDTH);

    -- other
    wait for clk_period;
    id_ex_register.opcode <= OPCODE_JMP;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(8, REGISTER_WIDTH);

    ---------------------------------------------------------------------------
    -- test stall/clear
    ---------------------------------------------------------------------------
    wait for clk_period;
    stall_in <= '1';
    id_ex_register.opcode <= OPCODE_JMP;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(8, REGISTER_WIDTH);
    wait for clk_period;
    stall_in <= '0';
    id_ex_register.rX_addr <= CONV_STD_LOGIC_VECTOR(6, REGISTER_ADDR_WIDTH);
    id_ex_register.opcode <= OPCODE_LD_REG;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(6, REGISTER_WIDTH);
    wait for clk_period;
    clear_in <= '1';
    wait for clk_period;
    clear_in <= '0';
    
    ---------------------------------------------------------------------------
    -- branch (i.e. load instruction with PC as destination)
    ---------------------------------------------------------------------------
    wait for clk_period;
    id_ex_register.rX_addr <= PC_ADDR;
    id_ex_register.opcode <= OPCODE_LD_REG;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(6, REGISTER_WIDTH);

    wait for clk_period;
    id_ex_register.rX_addr <= CONV_STD_LOGIC_VECTOR(6, REGISTER_ADDR_WIDTH);
    id_ex_register.opcode <= OPCODE_LD_REG;
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(6, REGISTER_WIDTH);

    ---------------------------------------------------------------------------
    -- test conditionals
    ---------------------------------------------------------------------------
    wait for clk_period;
    id_ex_register.cond <= COND_ZERO;
    id_ex_register.sr <= (SR_ZERO_BIT => '0', others => '0');
    id_ex_register.opcode <= OPCODE_ADD;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(8, REGISTER_WIDTH);    
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(3, REGISTER_WIDTH);
    wait for clk_period;
    id_ex_register.cond <= COND_UNCONDITIONAL;
    id_ex_register.opcode <= OPCODE_ADD;
    id_ex_register.rX <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);    
    id_ex_register.rY <= CONV_STD_LOGIC_VECTOR(2, REGISTER_WIDTH);    
    
    wait;                               -- will wait forever
  end process;

end;
