-- File: ex_stage.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Execute stage
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.rise_pack.all;
use work.RISE_PACK_SPECIFIC.all;

entity tb_id_stage_unit_vhd is
end tb_id_stage_unit_vhd;

architecture behavior of tb_id_stage_unit_vhd is

  -- component Declaration for the Unit Under Test (UUT)
  component id_stage
    port(
      clk   : in std_logic;
      reset : in std_logic;

      if_id_register : in  IF_ID_REGISTER_T;
      id_ex_register : out ID_EX_REGISTER_T;

      rx_addr : out REGISTER_ADDR_T;
      ry_addr : out REGISTER_ADDR_T;
      rz_addr : out REGISTER_ADDR_T;

      rx : in REGISTER_T;
      ry : in REGISTER_T;
      rz : in REGISTER_T;
      sr : in SR_REGISTER_T;

      lock_register  : in  LOCK_REGISTER_T;
      set_reg_lock0  : out std_logic;
      lock_reg_addr0 : out REGISTER_ADDR_T;
      set_reg_lock1  : out std_logic;
      lock_reg_addr1 : out REGISTER_ADDR_T;
      
      stall_in  : in  std_logic;
      stall_out : out std_logic;
      clear_in  : in  std_logic
      );
  end component;

  --inputs
  signal clk            : std_logic := '0';
  signal reset          : std_logic := '0';
  signal if_id_register : IF_ID_REGISTER_T;

  signal stall_in       : std_logic := '0';
  signal clear_in       : std_logic := '0';
  signal rx             : REGISTER_T;
  signal ry             : REGISTER_T;
  signal rz             : REGISTER_T;
  signal sr             : SR_REGISTER_T;
  signal lock_register  : LOCK_REGISTER_T := ( others => '0' );
  --Outputs
  signal id_ex_register : ID_EX_REGISTER_T;
  signal rx_addr        : REGISTER_ADDR_T;
  signal ry_addr        : REGISTER_ADDR_T;
  signal rz_addr        : REGISTER_ADDR_T;
  signal set_reg_lock0  : std_logic;
  signal lock_reg_addr0 : REGISTER_ADDR_T;
  signal set_reg_lock1  : std_logic;
  signal lock_reg_addr1 : REGISTER_ADDR_T;
  signal stall_out      : std_logic;

  constant TB_COND_TEST_VALUE : COND_T := COND_UNCONDITIONAL;

  constant TB_R1_TEST_VALUE : REGISTER_T := x"0001";
  constant TB_R2_TEST_VALUE : REGISTER_T := x"0002";
  constant TB_R3_TEST_VALUE : REGISTER_T := x"0003";

  constant TB_SR_TEST_VALUE : SR_REGISTER_T := x"A55A";
  constant TB_PC_TEST_VALUE : SR_REGISTER_T := x"1234";

  constant TB_CLOCK : time := 20 ns;
begin

  -- instantiate the Unit Under Test (UUT)
  uut : id_stage port map(
    clk            => clk,
    reset          => reset,
    if_id_register => if_id_register,
    id_ex_register => id_ex_register,
    rx_addr        => rx_addr,
    ry_addr        => ry_addr,
    rz_addr        => rz_addr,
    rx             => rx,
    ry             => ry,
    rz             => rz,
    sr             => sr,
    lock_register  => lock_register,
    set_reg_lock0  => set_reg_lock0,
    lock_reg_addr0 => lock_reg_addr0,
    set_reg_lock1  => set_reg_lock1,
    lock_reg_addr1 => lock_reg_addr1,    
    stall_in       => stall_in,
    stall_out      => stall_out,
    clear_in       => clear_in
    );

  cg : process
  begin
    clk <= '0';
    wait for TB_CLOCK/2;
    clk <= '1';
    wait for TB_CLOCK/2;
  end process;

  regfile : process(rx_addr, ry_addr, rz_addr)
  begin
    case rx_addr is
      when x"1"   => rx <= TB_R1_TEST_VALUE;
      when x"2"   => rx <= TB_R2_TEST_VALUE;
      when x"3"   => rx <= TB_R3_TEST_VALUE;
      when others => rz <= (others => 'X');
    end case;

    case ry_addr is
      when x"1"   => ry <= TB_R1_TEST_VALUE;
      when x"2"   => ry <= TB_R2_TEST_VALUE;
      when x"3"   => ry <= TB_R3_TEST_VALUE;
      when others => rz <= (others => 'X');
    end case;

    case rz_addr is
      when x"1"   => rz <= TB_R1_TEST_VALUE;
      when x"2"   => rz <= TB_R2_TEST_VALUE;
      when x"3"   => rz <= TB_R3_TEST_VALUE;
      when others => rz <= (others => 'X');
    end case;

    sr <= TB_SR_TEST_VALUE;
    
  end process;

  tb : process
  begin
    reset <= '0';
    wait for 100 ns;
    reset <= '1';

    -- test case: basic functionallity
    if_id_register.pc <= TB_PC_TEST_VALUE;
    wait for TB_CLOCK;

    -- test case: OPCODE_LD_IMM 
    if_id_register.ir <= "100"& "0" & x"1" & x"55";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_LD_IMM;
    assert id_ex_register.immediate = x"0055";
    assert id_ex_register.cond = COND_UNCONDITIONAL;
    assert rx_addr = x"1";
    assert id_ex_register.rX_addr = x"1";
    assert id_ex_register.rX = TB_R1_TEST_VALUE;
    assert ( lock_reg_addr0 = x"1" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"1" and set_reg_lock1 = '1' );
    
    -- test case: OPCODE_LD_IMM_HB
    if_id_register.ir <= "100"& "1" & x"1" & x"55";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_LD_IMM_HB;
    assert id_ex_register.immediate = x"5500";
    assert id_ex_register.cond = COND_UNCONDITIONAL;
    assert rx_addr = x"1";
    assert id_ex_register.rX_addr = x"1";
    assert id_ex_register.rX = TB_R1_TEST_VALUE;
    assert ( lock_reg_addr0 = x"1" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"1" and set_reg_lock1 = '1' );

    -- test case: OPCODE_LD_IMM_HB
    if_id_register.ir <= "100"& "1" & x"1" & x"55";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_LD_IMM_HB;
    assert id_ex_register.immediate = x"5500";
    assert id_ex_register.cond = COND_UNCONDITIONAL;
    assert rx_addr = x"1";
    assert id_ex_register.rX_addr = x"1";
    assert id_ex_register.rX = TB_R1_TEST_VALUE;
    assert ( lock_reg_addr0 = x"1" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"1" and set_reg_lock1 = '1' );

    -- test case: OPCODE_LD_DISP
    if_id_register.ir <= "101"& "000" & "11" & x"1" & x"2";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_LD_DISP;
    assert id_ex_register.rX_addr = x"1";
    assert id_ex_register.rX = TB_R1_TEST_VALUE;
    assert id_ex_register.rY = TB_R2_TEST_VALUE;
    assert id_ex_register.rZ = TB_R3_TEST_VALUE;
    assert id_ex_register.cond = TB_COND_TEST_VALUE;
    assert rx_addr = x"1";
    assert ry_addr = x"2";
    assert rz_addr = x"3";
    assert ( lock_reg_addr0 = x"1" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"1" and set_reg_lock1 = '1' );

    -- test case: OPCODE_LD_DISP_MS
    if_id_register.ir <= "110" & "000" & "11" & x"1" & x"2";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_LD_DISP_MS;
    assert id_ex_register.rX_addr = x"1";
    assert id_ex_register.rX = TB_R1_TEST_VALUE;
    assert id_ex_register.rY = TB_R2_TEST_VALUE;
    assert id_ex_register.rZ = TB_R3_TEST_VALUE;
    assert id_ex_register.cond = TB_COND_TEST_VALUE;
    assert rx_addr = x"1";
    assert ry_addr = x"2";
    assert rz_addr = x"3";
    assert ( lock_reg_addr0 = x"1" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"1" and set_reg_lock1 = '1' );

    -- test case: OPCODE_LD_REG
    if_id_register.ir <= "00001" & "001" & x"2" & x"1";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_LD_REG;
    assert id_ex_register.rX_addr = x"2";
    assert id_ex_register.rX = TB_R2_TEST_VALUE;
    assert id_ex_register.rY = TB_R1_TEST_VALUE;
    assert id_ex_register.cond = COND_NOT_ZERO;
    assert rx_addr = x"2";
    assert ry_addr = x"1";
    assert ( lock_reg_addr0 = x"2" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"2" and set_reg_lock1 = '1' );
    
    -- test case: OPCODE_LD_REG WITH STALL
    lock_register(1) <= '1';
    if_id_register.ir <= "00001" & "001" & x"2" & x"1";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_LD_REG;
    assert id_ex_register.rX_addr = x"2";
    assert id_ex_register.rX = TB_R2_TEST_VALUE;
    assert id_ex_register.rY = TB_R1_TEST_VALUE;
    assert id_ex_register.cond = COND_NOT_ZERO;
    assert rx_addr = x"2";
    assert ry_addr = x"1";
    assert stall_out = '1';
    assert ( lock_reg_addr0 = x"2" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"2" and set_reg_lock1 = '1' );
    lock_register(1) <= '0';

    -- test case: OPCODE_ST_DISP
    if_id_register.ir <= "111" & "100" & "11" & x"1" & x"2";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_ST_DISP;
    assert id_ex_register.rX_addr = x"1";
    assert id_ex_register.rX = TB_R1_TEST_VALUE;
    assert id_ex_register.rY = TB_R2_TEST_VALUE;
    assert id_ex_register.rZ = TB_R3_TEST_VALUE;
    assert id_ex_register.cond = COND_NEGATIVE;
    assert rx_addr = x"1";
    assert ry_addr = x"2";
    assert rz_addr = x"3";
    
    -- test case: OPCODE_ADD
    if_id_register.ir <= "00010" & "000" & x"3" & x"2";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_ADD;
    assert id_ex_register.rX_addr = x"3";
    assert id_ex_register.rX = TB_R3_TEST_VALUE;
    assert id_ex_register.rY = TB_R2_TEST_VALUE;
    assert id_ex_register.cond = COND_UNCONDITIONAL;
    assert rx_addr = x"3";
    assert ry_addr = x"2";
    assert ( lock_reg_addr0 = x"3" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"3" and set_reg_lock1 = '1' );
    
    -- test case: OPCODE_ADD_IMM
    if_id_register.ir <= "00011" & "010" & x"2" & x"5";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_ADD_IMM;
    assert id_ex_register.rX_addr = x"2";
    assert id_ex_register.rX = TB_R2_TEST_VALUE;
    assert id_ex_register.immediate = x"0005";
    assert id_ex_register.cond = COND_ZERO;
    assert rx_addr = x"2";
    assert ( lock_reg_addr0 = x"2" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"2" and set_reg_lock1 = '1' );
    
    -- test case: OPCODE_SUB
    if_id_register.ir <= "00100" & "011" & x"1" & x"2";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_SUB;
    assert id_ex_register.rX_addr = x"1";
    assert id_ex_register.rX = TB_R1_TEST_VALUE;
    assert id_ex_register.rY = TB_R2_TEST_VALUE;
    assert id_ex_register.cond = COND_CARRY;
    assert rx_addr = x"1";
    assert ry_addr = x"2";
    assert ( lock_reg_addr0 = x"1" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"1" and set_reg_lock1 = '1' );
    
    -- test case: OPCODE_SUB_IMM
    if_id_register.ir <= "00101" & "100" & x"1" & x"A";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_SUB_IMM;
    assert id_ex_register.rX_addr = x"1";
    assert id_ex_register.rX = TB_R1_TEST_VALUE;
    assert id_ex_register.immediate = x"000A";
    assert id_ex_register.cond = COND_NEGATIVE;
    assert rx_addr = x"1";
    assert ( lock_reg_addr0 = x"1" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"1" and set_reg_lock1 = '1' );
    
    -- test case: OPCODE_NEG
    if_id_register.ir <= "00110" & "101" & x"2" & x"2";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_NEG;
    assert id_ex_register.rX_addr = x"2";
    assert id_ex_register.rX = TB_R2_TEST_VALUE;
    assert id_ex_register.rY = TB_R2_TEST_VALUE;
    assert id_ex_register.cond = COND_OVERFLOW;
    assert rx_addr = x"2";
    assert ry_addr = x"2";
    assert ( lock_reg_addr0 = x"2" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"2" and set_reg_lock1 = '1' );
    
    -- test case: OPCODE_ARS
    if_id_register.ir <= "00111" & "110" & x"3" & x"2";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_ARS;
    assert id_ex_register.rX_addr = x"3";
    assert id_ex_register.rX = TB_R3_TEST_VALUE;
    assert id_ex_register.rY = TB_R2_TEST_VALUE;
    assert id_ex_register.cond = COND_ZERO_NEGATIVE;
    assert rx_addr = x"3";
    assert ry_addr = x"2";
    assert ( lock_reg_addr0 = x"3" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"3" and set_reg_lock1 = '1' );
    
    -- test case: OPCODE_ALS
    if_id_register.ir <= "01000" & "000" & x"2" & x"1";
    wait for TB_CLOCK;
    assert id_ex_register.opcode = OPCODE_ALS;
    assert id_ex_register.rX_addr = x"2";
    assert id_ex_register.rX = TB_R2_TEST_VALUE;
    assert id_ex_register.rY = TB_R1_TEST_VALUE;
    assert id_ex_register.cond = COND_UNCONDITIONAL;
    assert rx_addr = x"2";
    assert ry_addr = x"1";
    assert ( lock_reg_addr0 = x"2" and set_reg_lock0 = '1' ) or ( lock_reg_addr1 = x"2" and set_reg_lock1 = '1' );
    
    
    wait;
  end process;

end;
