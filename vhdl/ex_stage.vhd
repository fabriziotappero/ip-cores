-------------------------------------------------------------------------------
-- File: ex_stage.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Execute stage
-------------------------------------------------------------------------------

library UNISIM;
use UNISIM.vcomponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.STD_LOGIC_ARITH.all;

use WORK.RISE_PACK.all;
use work.RISE_PACK_SPECIFIC.all;

entity ex_stage is
  
  port (
    clk                 : in std_logic;
    reset               : in std_logic;

    id_ex_register      : in ID_EX_REGISTER_T;
    ex_mem_register     : out EX_MEM_REGISTER_T;

    branch              : out std_logic;
    stall_in            : in std_logic;
    clear_in            : in std_logic;
    clear_out           : out std_logic;
    clear_locks         : out std_logic);

end ex_stage;



architecture ex_stage_rtl of ex_stage is

--  signal id_ex_register : ID_EX_REGISTER_T;
  
  signal ex_mem_register_int     : EX_MEM_REGISTER_T;
  signal ex_mem_register_next    : EX_MEM_REGISTER_T;
  signal isLoadOp : std_logic;
  signal isJmpOp : std_logic;

  signal aluop1_int : ALUOP1_T;
  signal aluop2_int : ALUOP2_T;

  signal execute : std_logic;
  signal clear_out_int : std_logic;
  signal branch_int : std_logic;

  signal bs_arithmetic : std_logic;
  signal bs_left : std_logic;
  signal bs_out : REGISTER_T;
  
  function isOverflowAdd (
    op1 : std_logic_vector;
    op2 : std_logic_vector;
    result : std_logic_vector)
    return std_logic is
    variable x : std_logic;
  begin
    x := '0';
    if op1(REGISTER_WIDTH-1) = '0' and op2(REGISTER_WIDTH-1) = '0' then
      x := result(REGISTER_WIDTH-1);       
    end if;
    if op1(REGISTER_WIDTH-1) = '1' and op2(REGISTER_WIDTH-1) = '1' then
      x := not result(REGISTER_WIDTH-1);       
    end if;
    return x;
  end isOverflowAdd;

  function isOverflowSub (
    op1 : std_logic_vector;
    op2 : std_logic_vector;
    result : std_logic_vector)
    return std_logic is
    variable x : std_logic;
  begin
    x := '0';
    if op1(REGISTER_WIDTH-1) = '0' and op2(REGISTER_WIDTH-1) = '1' then
      x := result(REGISTER_WIDTH-1);       
    end if;
    if op1(REGISTER_WIDTH-1) = '1' and op2(REGISTER_WIDTH-1) = '0' then
      x := not result(REGISTER_WIDTH-1);       
    end if;

    return x;
  end isOverflowSub;

  procedure getSRStatusBits ( value : in REGISTER_T; sr_reg : out SR_REGISTER_T ) is
  begin
    if value = CONV_STD_LOGIC_VECTOR(0, REGISTER_WIDTH) then
      sr_reg( SR_REGISTER_ZERO ) := '1';
    else
      sr_reg( SR_REGISTER_ZERO ) := '0';
    end if;
    if value( REGISTER_WIDTH - 1 ) = '1' then
      sr_reg( SR_REGISTER_NEGATIVE ) := '1';
    else
      sr_reg( SR_REGISTER_NEGATIVE ) := '0';
    end if;
  end getSRStatusBits;
  
  component barrel_shifter
    port(
      reg_a      : in  std_logic_vector(15 downto 0);
      reg_b      : in  std_logic_vector(15 downto 0);
      left       : in  std_logic;
      arithmetic : in  std_logic;
      reg_q      : out std_logic_vector(15 downto 0)
      );
  end component;
begin  -- ex_stage_rtl

  ex_mem_register        <= ex_mem_register_int;
  
  bs : barrel_shifter port map(
    reg_a      => id_ex_register.rX,
    reg_b      => id_ex_register.rY,
    left       => bs_left,
    arithmetic => bs_arithmetic,
    reg_q      => bs_out
    );

  output: process (clk, reset)
  begin  -- process
    if reset = '0' then                 -- asynchronous reset (active low)
      ex_mem_register_int.aluop1        <= (others => '0');
      ex_mem_register_int.aluop2        <= (others => '0');
      ex_mem_register_int.reg           <= (others => '0');
      ex_mem_register_int.alu           <= (others => '0');
      ex_mem_register_int.dreg_addr     <= (others => '0');
      ex_mem_register_int.lr            <= (others => '0');
      ex_mem_register_int.sr            <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- if PIPELINE isn't stalled: update registers
      if stall_in = '0' then            
        ex_mem_register_int        <= ex_mem_register_next;
        --id_ex_register <= id_ex_register_in;
        clear_out <= clear_out_int;
        branch <= branch_int;
      end if;
    end if;
  end process output;  

  cond_check: process (id_ex_register, aluop1_int, aluop2_int)
  begin  -- process cond_check
    execute <= '0';

    case id_ex_register.cond is
      when COND_UNCONDITIONAL =>
        execute <= '1';
      when COND_NOT_ZERO =>
        if id_ex_register.sr(SR_ZERO_BIT) = '0' then
          execute <= '1';
        end if;
      when COND_ZERO =>
        if id_ex_register.sr(SR_ZERO_BIT) = '1' then
          execute <= '1';
        end if;
      when COND_CARRY =>
        if id_ex_register.sr(SR_CARRY_BIT) = '1' then
          execute <= '1';
        end if;
      when COND_NEGATIVE =>
        if id_ex_register.sr(SR_NEGATIVE_BIT) = '1' then
          execute <= '1';
        end if;
      when COND_OVERFLOW =>
        if id_ex_register.sr(SR_OVERFLOW_BIT) = '1' then
          execute <= '1';
        end if;
      when COND_ZERO_NEGATIVE =>
        if id_ex_register.sr(SR_ZERO_BIT) = '1' or
          id_ex_register.sr(SR_ZERO_BIT) = '1' then
          execute <= '1';
        end if;
      when others => null;
    end case;
  end process cond_check;

  aluop: process (execute, aluop1_int, aluop2_int, clear_in)
  begin  -- process aluop
    -- insert nop in pipeline if instruction is conditional and
    -- condition is not met, or if pipeline is cleared
    if execute = '0' or clear_in = '1' then
      ex_mem_register_next.aluop1 <= (others => '0');
      ex_mem_register_next.aluop2 <= (others => '0');
    else
      ex_mem_register_next.aluop1 <= aluop1_int;
      ex_mem_register_next.aluop2 <= aluop2_int;  
    end if;    
  end process aluop;
  
  alu: process (id_ex_register, ex_mem_register_next, bs_out)
    variable new_sr : SR_REGISTER_T;
  begin

    new_sr := id_ex_register.sr;
    ex_mem_register_next.alu <= (others => '0');
    ex_mem_register_next.dreg_addr <= id_ex_register.rX_addr;
    ex_mem_register_next.reg <= (others => '0');
    ex_mem_register_next.lr <= (others => '0');

    aluop1_int(ALUOP1_LD_MEM_BIT) <= '0';
    aluop1_int(ALUOP1_ST_MEM_BIT) <= '0';
    aluop1_int(ALUOP1_WB_REG_BIT) <= '1';

    aluop2_int <=  (ALUOP2_LR_BIT => '0', ALUOP2_SR_BIT => '1', others => '0');
    
    isLoadOp <= '0';
    isJmpOp <= '0';
    bs_left <= '0';
    bs_arithmetic <= '0';
    case id_ex_register.opcode is
      -- load opcodes
      when OPCODE_LD_IMM =>
        ex_mem_register_next.alu <= x"00" & id_ex_register.immediate(7 downto 0);
        getSRStatusBits( ex_mem_register_next.alu, new_sr );
        isLoadOp <= '1';
      when OPCODE_LD_IMM_HB =>
        ex_mem_register_next.alu <= id_ex_register.rX or (id_ex_register.immediate(7 downto 0) & x"00");
        getSRStatusBits( ex_mem_register_next.alu, new_sr );
        isLoadOp <= '1';
      when OPCODE_LD_DISP =>
        ex_mem_register_next.alu <= id_ex_register.rY + id_ex_register.rZ;
        aluop1_int(ALUOP1_LD_MEM_BIT) <= '1';
        isLoadOp <= '1';
      when OPCODE_LD_DISP_MS =>
        ex_mem_register_next.alu <= id_ex_register.rY + id_ex_register.rZ;
        aluop1_int(ALUOP1_LD_MEM_BIT) <= '1';
        isLoadOp <= '1';
      when OPCODE_LD_REG =>
        ex_mem_register_next.alu <= id_ex_register.rY;
        isLoadOp <= '1';

        -- store opcodes
      when OPCODE_ST_DISP =>
        ex_mem_register_next.alu <= id_ex_register.rY + id_ex_register.rZ;
        ex_mem_register_next.reg <= id_ex_register.rX;
        getSRStatusBits( ex_mem_register_next.reg, new_sr );
        aluop1_int(ALUOP1_ST_MEM_BIT) <= '1';
        aluop2_int(ALUOP2_SR_BIT) <= '0';
        aluop1_int(ALUOP1_WB_REG_BIT) <= '0';
        
        -- arithmetic opcodes
      when OPCODE_ADD =>
        ex_mem_register_next.alu <= id_ex_register.rX + id_ex_register.rY;
        getSRStatusBits( ex_mem_register_next.alu, new_sr );
        new_sr(SR_OVERFLOW_BIT) := isOverflowAdd(id_ex_register.rX,
                                                 id_ex_register.rY,
                                                 ex_mem_register_next.alu);
      when OPCODE_ADD_IMM =>
        ex_mem_register_next.alu <= id_ex_register.rX + id_ex_register.immediate;
        getSRStatusBits( ex_mem_register_next.alu, new_sr );
        new_sr(SR_OVERFLOW_BIT) := isOverflowAdd(id_ex_register.rX,
                                                id_ex_register.immediate,
                                                ex_mem_register_next.alu);
      when OPCODE_SUB =>
        ex_mem_register_next.alu <= id_ex_register.rX - id_ex_register.rY;
        getSRStatusBits( ex_mem_register_next.alu, new_sr );
        new_sr(SR_OVERFLOW_BIT) := isOverflowSub(id_ex_register.rX,
                                                 id_ex_register.rY,
                                                 ex_mem_register_next.alu);
      when OPCODE_SUB_IMM =>
        ex_mem_register_next.alu <= id_ex_register.rX - id_ex_register.immediate;
        getSRStatusBits( ex_mem_register_next.reg, new_sr );
        new_sr(SR_OVERFLOW_BIT) := isOverflowSub(id_ex_register.rX,
                                                 id_ex_register.immediate,
                                                 ex_mem_register_next.alu);
      when OPCODE_NEG =>
        ex_mem_register_next.alu <= not id_ex_register.rY + x"0001";
        getSRStatusBits( ex_mem_register_next.alu, new_sr );
--      when OPCODE_ALS =>
--        ex_mem_register_next.alu <= id_ex_register.rY(REGISTER_WIDTH-2 downto 0) & "0";
--        ex_mem_register_next.sr(SR_OVERFLOW_BIT) <= id_ex_register.rY(REGISTER_WIDTH-1) xor
--                                                    id_ex_register.rY(REGISTER_WIDTH-2);
--      when OPCODE_ARS =>
--        ex_mem_register_next.alu <= id_ex_register.rY(REGISTER_WIDTH-1) & id_ex_register.rY(REGISTER_WIDTH-1 downto 1);
      when OPCODE_ALS =>
        bs_left                  <= '1';
        bs_arithmetic            <= '1';
        ex_mem_register_next.alu <= bs_out;
        getSRStatusBits( bs_out, new_sr );
        new_sr(SR_OVERFLOW_BIT)  := id_ex_register.rY(REGISTER_WIDTH-1) xor
                                    id_ex_register.rY(REGISTER_WIDTH-2);
      when OPCODE_ARS =>
        bs_left                  <= '0';
        bs_arithmetic            <= '1';
        ex_mem_register_next.alu <= bs_out;
        getSRStatusBits( bs_out, new_sr );
        new_sr(SR_OVERFLOW_BIT)  := id_ex_register.rY(REGISTER_WIDTH-1) xor
                                    id_ex_register.rY(REGISTER_WIDTH-2);
        -- logical opcodes
      when OPCODE_AND =>
        ex_mem_register_next.alu <= id_ex_register.rX and id_ex_register.rY;
        getSRStatusBits( ex_mem_register_next.alu, new_sr );
      when OPCODE_NOT =>
        ex_mem_register_next.alu <= not id_ex_register.rY;
        getSRStatusBits( ex_mem_register_next.alu, new_sr );        
      when OPCODE_EOR =>
        ex_mem_register_next.alu <= id_ex_register.rX xor id_ex_register.rY;            
        getSRStatusBits( ex_mem_register_next.alu, new_sr );
--      when OPCODE_LS =>
--        ex_mem_register_next.alu <= id_ex_register.rY(REGISTER_WIDTH-2 downto 0) & "0";
--      when OPCODE_RS =>
--        ex_mem_register_next.alu <= "0" & id_ex_register.rY(REGISTER_WIDTH-1 downto 1);
      when OPCODE_LS =>
        bs_left                  <= '1';
        bs_arithmetic            <= '0';
        ex_mem_register_next.alu <= bs_out;
        getSRStatusBits( bs_out, new_sr );
      when OPCODE_RS =>
        bs_left                  <= '0';
        bs_arithmetic            <= '0';
        ex_mem_register_next.alu <= bs_out;
        getSRStatusBits( bs_out, new_sr );
        -- program control
      when OPCODE_JMP =>
        ex_mem_register_next.lr             <= id_ex_register.pc;
        ex_mem_register_next.dreg_addr      <= PC_ADDR;
        ex_mem_register_next.alu            <= id_ex_register.rX;
        getSRStatusBits( ex_mem_register_next.alu, new_sr );
        aluop1_int(ALUOP1_WB_REG_BIT) <= '0';
        aluop2_int(ALUOP2_SR_BIT) <= '0';
        aluop2_int(ALUOP2_LR_BIT) <= '1';
        isJmpOp <= '1';

      when OPCODE_NOP =>
        aluop1_int(ALUOP1_WB_REG_BIT) <= '0';
        aluop2_int(ALUOP2_SR_BIT) <= '0';

      when OPCODE_TST =>
        aluop1_int(ALUOP1_WB_REG_BIT) <= '0';
        aluop2_int(ALUOP2_SR_BIT) <= '1';
        getSRStatusBits( id_ex_register.rX, new_sr );
        
      when others =>
        aluop1_int(ALUOP1_WB_REG_BIT) <= '0';
        aluop2_int(ALUOP2_SR_BIT) <= '0';
        
    end case;
    
    -- update current SR register value.
    ex_mem_register_next.sr <= new_sr;
  end process;

  branch_logic: process (id_ex_register, isLoadOp, isJmpOp, execute)
  begin  -- process branch_logic
    branch_int <= '0';
    clear_out_int <= '0';
    clear_locks <= '0';
    if execute = '1' then
      if (id_ex_register.rX_addr = PC_ADDR and isLoadOp = '1') or (isJmpOp = '1') then
        branch_int <= '1';
        clear_out_int <= '1';
        clear_locks <= '1';
      end if;
    end if;         
  end process branch_logic;
  
end ex_stage_rtl;
