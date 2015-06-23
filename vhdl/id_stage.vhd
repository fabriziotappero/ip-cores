-- File: id_stage.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Instruction decode stage
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.RISE_PACK.all;
use work.RISE_PACK_SPECIFIC.all;

entity id_stage is
  
  port (
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
    clear_in  : in  std_logic);


end id_stage;

architecture id_stage_rtl of id_stage is

  signal rx_addr_int         : REGISTER_ADDR_T;
  signal ry_addr_int         : REGISTER_ADDR_T;
  signal rz_addr_int         : REGISTER_ADDR_T;
  signal id_ex_register_int  : ID_EX_REGISTER_T;
  signal id_ex_register_next : ID_EX_REGISTER_T;
  signal stall_out_int       : std_logic;

  function opcode_modifies_sr(opcode : in OPCODE_T) return std_logic is
    variable modifies : std_logic;
  begin
    case opcode is
      when OPCODE_NOP        => modifies := '0';
      when OPCODE_JMP        => modifies := '0';
      when OPCODE_LD_DISP_MS => modifies := '0';
      when others            => modifies := '1';
    end case;
    return modifies;
  end;

  function opcode_modifies_rx(opcode : in OPCODE_T) return std_logic is
    variable modifies : std_logic;
  begin
    case opcode is
      when OPCODE_JMP     => modifies := '0';
      when OPCODE_TST     => modifies := '0';
      when OPCODE_NOP     => modifies := '0';
      when OPCODE_ST_DISP => modifies := '0';
      when others         => modifies := '1';
    end case;
    return modifies;
  end;
  
begin  -- id_stage_rtl

  rx_addr        <= rx_addr_int;
  ry_addr        <= ry_addr_int;
  rz_addr        <= rz_addr_int;
  id_ex_register <= id_ex_register_int;
  stall_out      <= stall_out_int;
--  process (clk, reset)
--  begin  -- process
--    if reset = '0' then                 -- asynchronous reset (active low)
--      id_ex_register_int        <= (others => (others => '0'));
--      id_ex_register_next       <= (others => (others => '0'));
--    elsif clk'event and clk = '1' then  -- rising clock edge
--      id_ex_register_int        <= id_ex_register_next;
--    end if;
--  end process;  

  process (clk, reset, stall_in, clear_in)
  begin
    if reset = '0' or clear_in = '1' then
      id_ex_register_int.sr        <= RESET_SR_VALUE;
      id_ex_register_int.pc        <= RESET_PC_VALUE;
      id_ex_register_int.opcode    <= OPCODE_NOP;
      id_ex_register_int.cond      <= COND_UNCONDITIONAL;
      id_ex_register_int.rX_addr   <= (others => '0');
      id_ex_register_int.rX        <= (others => '0');
      id_ex_register_int.rY        <= (others => '0');
      id_ex_register_int.rZ        <= (others => '0');
      id_ex_register_int.immediate <= (others => '0');
    elsif clk'event and clk = '1' then
      if stall_in = '0' then
        if stall_out_int = '0' then
          id_ex_register_int <= id_ex_register_next;
        else
          id_ex_register_int.sr        <= RESET_SR_VALUE;
          id_ex_register_int.pc        <= RESET_PC_VALUE;
          id_ex_register_int.opcode    <= OPCODE_NOP;
          id_ex_register_int.cond      <= COND_UNCONDITIONAL;
          id_ex_register_int.rX_addr   <= (others => '0');
          id_ex_register_int.rX        <= (others => '0');
          id_ex_register_int.rY        <= (others => '0');
          id_ex_register_int.rZ        <= (others => '0');
          id_ex_register_int.immediate <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  -- The opc_extender decodes the two different formats used for the opcodes
  -- in the instruction set into a single 5-bit opcode format.
  opc_extender : process (clk, reset, if_id_register)
  begin
    if reset = '0' then
      id_ex_register_next.opcode <= OPCODE_NOP;
      -- decodes: OPCODE_LD_IMM, OPCODE_LD_IMM_HB
    elsif if_id_register.ir(15 downto 13) = "100" then
      id_ex_register_next.opcode <= svector2opcode(if_id_register.ir(15 downto 13) & if_id_register.ir(12) & "0");
      -- decodes: OPCODE_LD_DISP, OPCODE_LD_DISP_MS, OPCODE_ST_DISP
    elsif if_id_register.ir(15) = '1' then
      id_ex_register_next.opcode <= svector2opcode(if_id_register.ir(15 downto 13) & "00");
      -- decodes: OPCODE_XXX
    else
      id_ex_register_next.opcode <= svector2opcode(if_id_register.ir(15 downto 11));
    end if;
  end process;

  cond_decode : process (clk, reset, if_id_register)
  begin
    if reset = '0' then
      id_ex_register_next.cond <= COND_UNCONDITIONAL;
      -- decodes: OPCODE_LD_IMM, OPCODE_LD_IMM_HB
    elsif if_id_register.ir(15 downto 13) = "100" then
      id_ex_register_next.cond <= COND_UNCONDITIONAL;
      -- decodes: OPCODE_LD_DISP, OPCODE_LD_DISP_MS, OPCODE_ST_DISP      
    elsif if_id_register.ir(15) = '1' then
      id_ex_register_next.cond <= svector2cond(if_id_register.ir(12 downto 10));
      -- decodes: OPCODE_XXX
    else
      id_ex_register_next.cond <= svector2cond(if_id_register.ir(10 downto 8));
    end if;
  end process;

  pc : process(reset, if_id_register)
  begin
    if reset = '0' then
      id_ex_register_next.pc <= RESET_PC_VALUE;
    else
      id_ex_register_next.pc <= if_id_register.pc;
    end if;
  end process;

  -- The SR fetch process read the value of the SR registers and passes it to
  -- the execute pipeline. In addition it checks if the opcode modifies the
  -- SR register and if yes locks the register.
  sr_fetch : process (reset, sr, id_ex_register_next, stall_out_int, clear_in)
  begin
    if reset = '0' then
      id_ex_register_next.sr <= RESET_SR_VALUE;
    else
      id_ex_register_next.sr <= sr;
    end if;

    if opcode_modifies_sr(id_ex_register_next.opcode) = '1' and stall_out_int = '0' and clear_in = '0' then
      lock_reg_addr1 <= SR_REGISTER_ADDR;
      set_reg_lock1  <= '1';
    else
      lock_reg_addr1 <= (others => '-');
      set_reg_lock1  <= '0';
    end if;
  end process;

  rx_decode_and_fetch : process (reset, if_id_register, id_ex_register_next, rx, stall_out_int, clear_in)
  begin
    -- make sure we don't synthesize a latch for rx_addr
    rx_addr_int <= (others => '0');

    if reset = '0' then
      id_ex_register_next.rX      <= (others => '0');
      id_ex_register_next.rX_addr <= (others => '0');
    elsif id_ex_register_next.opcode = OPCODE_LD_IMM or
      id_ex_register_next.opcode = OPCODE_LD_IMM_HB then
      rx_addr_int                 <= if_id_register.ir(11 downto 8);
      id_ex_register_next.rX      <= rx;
      id_ex_register_next.rX_addr <= if_id_register.ir(11 downto 8);
    else
      rx_addr_int                 <= if_id_register.ir(7 downto 4);
      id_ex_register_next.rX      <= rx;
      id_ex_register_next.rX_addr <= if_id_register.ir(7 downto 4);
    end if;

    if opcode_modifies_rx(id_ex_register_next.opcode) = '1' and stall_out_int = '0' and clear_in = '0' then
      lock_reg_addr0 <= id_ex_register_next.rX_addr;
      set_reg_lock0  <= '1';
    elsif id_ex_register_next.opcode = OPCODE_JMP then
      lock_reg_addr0 <= LR_REGISTER_ADDR;
      set_reg_lock0  <= '1';
    else
      lock_reg_addr0 <= (others => '-');
      set_reg_lock0  <= '0';
    end if;
  end process;


  ry_decode_and_fetch : process (reset, if_id_register, id_ex_register_next, ry)
  begin
    -- make sure we don't synthesize a latch for ry_addr_int
    ry_addr_int <= (others => '0');

    if reset = '0' then
      id_ex_register_next.rY <= (others => '0');
    else
      ry_addr_int            <= if_id_register.ir(3 downto 0);
      id_ex_register_next.rY <= ry;
    end if;
  end process;

  rz_decode_and_fetch : process (reset, if_id_register, id_ex_register_next, rz)
  begin
    -- make sure we don't synthesize a latch for rz_addr_int
    rz_addr_int <= (others => '0');

    if reset = '0' then
      id_ex_register_next.rZ <= (others => '0');
    else
      -- only the lower 2-bits of rz are encoded in the instruction
      rz_addr_int            <= "00" & if_id_register.ir(9 downto 8);
      id_ex_register_next.rZ <= rz;
    end if;
  end process;

  -- The immediate fetch process checks for all opcodes needing constants
  -- and decides which immediate format was present. If the instruction
  -- does not include an immediate value the result is undefined and must
  -- not be used.
  imm_fetch : process (reset, if_id_register, id_ex_register_next)
  begin
    case id_ex_register_next.opcode is
      -- The immediate values holds the upper 8 bits of a 16 bit value.
      when OPCODE_LD_IMM_HB =>
        id_ex_register_next.immediate <= x"00" & if_id_register.ir(7 downto 0);
        -- The immediate values holds the lower 8 bits of a 16 bit value. 
      when OPCODE_LD_IMM =>
        id_ex_register_next.immediate <= x"00" & if_id_register.ir(7 downto 0);
        -- Default format holds the lower 4 bits of a 16 bit value.
      when others =>
        id_ex_register_next.immediate <= x"000" & if_id_register.ir(3 downto 0);
    end case;
  end process;

  -- Check if all registers are available. If not stall the pipeline.
  lock : process(reset, id_ex_register_next, rx_addr_int, ry_addr_int, rz_addr_int, lock_register, clear_in)
    variable required : LOCK_REGISTER_T;
  begin
    required := (others => '0');
    if id_ex_register_next.cond /= COND_UNCONDITIONAL then
      required(TO_INTEGER(unsigned(SR_REGISTER_ADDR))) := '1';
    end if;
    case id_ex_register_next.opcode is
      -- looks strange but ld rX, #0xAA also needs the register because we
      -- can only load the high or low byte and the other one must be
      -- preserved.
      when OPCODE_LD_IMM =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
      when OPCODE_LD_IMM_HB =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
      when OPCODE_LD_DISP =>
        required(TO_INTEGER(unsigned(rz_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_LD_DISP_MS =>
        required(TO_INTEGER(unsigned(rz_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_LD_REG =>
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_ST_DISP =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
        required(TO_INTEGER(unsigned(rz_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_ADD =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_ADD_IMM =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
      when OPCODE_SUB =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_SUB_IMM =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
      when OPCODE_NEG =>
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_ARS =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_ALS =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_AND =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_NOT =>
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_EOR =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_LS =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_RS =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
        required(TO_INTEGER(unsigned(ry_addr_int))) := '1';
      when OPCODE_JMP =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
      when OPCODE_TST =>
        required(TO_INTEGER(unsigned(rx_addr_int))) := '1';
      when others => null;
    end case;

    -- no checks if all registers are not locked.
    stall_out_int <= '0';
    if (required and lock_register) /= x"0000" and (clear_in = '0') then
      stall_out_int <= '1';
    end if;
  end process;
  
end id_stage_rtl;
