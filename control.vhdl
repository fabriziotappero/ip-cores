-- 10/24/2005
-- Control Unit



library ieee;
use ieee.std_logic_1164.all;

entity control is port(
  instr:	in std_logic_vector(15 downto 0);
  clk:	        in std_logic;
  reset:	in std_logic;
  mem_ready:	in std_logic;
  a_or_l:       out std_logic;
  op:	        out std_logic_vector(2 downto 0);
  addr_a:	out std_logic_vector(2 downto 0);
  addr_b:	out std_logic_vector(2 downto 0);
  reg_addr:     out std_logic_vector(2 downto 0);
  to_regs:	out std_logic_vector(15 downto 0);
  to_pc:	out std_logic_vector(15 downto 0);
  load_pc:	out std_logic;
  reg_wr:	out std_logic;
  alu_or_imm:   out std_logic;
  next_instr:   out std_logic;
  curr_state:   out std_logic_vector(15 downto 0)
  );
end control;

architecture control_arch of control is	
  
  type state_type is (idle, alu_arith, alu_logic, load_imm_lo, load_imm_hi, mov_r, mov_w, mem, len, jmp_br, save_addr, wr_pc, halt, ret, compare, set_flags, write_res, alu_wait);
  signal state, next_state : state_type;

  signal return_addr: std_logic_vector(15 downto 0);
  signal temp_imm : std_logic_vector(15 downto 0) := x"0000";

begin
  -- don't forget to put the instruction in the sensitivity list!!!
  -- if you don't, nothing will happen, since the code won't run when the
  -- instruction changes!!
  state_logic:process(state, instr)
  begin
    case state is
      when idle =>
        curr_state <= x"0000";
        --initialize all signals to zero
        next_instr <= '1';
        a_or_l <= '0';
        op <= "000";
        addr_a <= "000";
        addr_b <= "000";
        --reg_addr <= "000";
        to_regs <= x"0000";
        to_pc <= x"0000";
        load_pc <= '0';
        reg_wr <= '0';
        --alu_or_imm <= '0';              -- 0 for alu, 1 for immediate
        case instr(15 downto 12) is
          when "0000" =>				-- nop
            next_state <= idle;
          when "0001" =>				-- return
            next_state <= ret;
          when "0010" =>				-- alu arithmetic
            next_state <= alu_arith;
          when "0011" =>				-- alu logic
            next_state <= alu_logic;
          when "0100" =>				-- load immediate
            if instr(0) = '0' then
              next_state <= load_imm_lo;
            else
              next_state <= load_imm_hi;
            end if;
          when "0101" =>				-- jump or branch
            next_state <= jmp_br;
	  --when "0110" =>				-- shift
            --next_state <= shift;
          when "0111" =>				-- compare
            next_state <= compare;
          when "1000" =>				-- move
            next_state <= mov_r;
          when "1001" =>				-- memory access
            next_state <= mem;
          when "1110" =>				-- len
            next_state <= len;
          when "1111" =>				-- halt
            next_state <= halt;
          when others =>
            next_state <= idle;
        end case;
      when alu_arith =>
        curr_state <= x"0001";
        next_instr <= '0';
        alu_or_imm <= '0';
        a_or_l <= '0';
        op <= instr(2 downto 0);
        --op <= "001";
        addr_a <= instr(8 downto 6);
        addr_b <= instr(5 downto 3);
        --next_state <= write_res;
        next_state <= alu_wait;
      when alu_wait =>
        curr_state <= x"001A";
        next_instr <= '0';
        next_state <= write_res;
      when alu_logic =>
        curr_state <= x"0002";
        next_instr <= '0';
        a_or_l <= '1';
        op <= instr(2 downto 0);
        addr_a <= instr(8 downto 6);
        addr_b <= instr(5 downto 3);
        next_state <= write_res;
      when load_imm_lo =>
        next_instr <= '0';
        alu_or_imm <= '1';
        --reg_addr <= instr(11 downto 9);
        addr_a <= instr(11 downto 9);
        curr_state <= x"003A";
        temp_imm(7 downto 0) <= instr(8 downto 1);
        next_state <= idle;
      when load_imm_hi =>
        curr_state <= x"003B";
        next_instr <= '0';
        alu_or_imm <= '1';
        --reg_addr <= instr(11 downto 9);
        addr_a <= instr(11 downto 9);
        temp_imm(15 downto 8) <= instr(8 downto 1);
        to_regs <= temp_imm;
        reg_wr <= '1';
        
        next_state <= idle;
        --next_state <= write_res;
      when mov_r =>
        curr_state <= x"0004";
        next_instr <= '0';
        addr_a <= instr(8 downto 6);
        next_state <= mov_w;
      when mov_w =>
        curr_state <= x"0005";
        next_instr <= '0';
        reg_wr <= '1';
        reg_addr <= instr(11 downto 9);
        next_state <= idle;
      when wr_pc =>
        curr_state <= x"0006";
        next_instr <= '0';
        load_pc <= '1';
        to_pc <= return_addr;
      when write_res =>
        curr_state <= x"0007";
        next_instr <= '0';
        reg_addr <= instr(11 downto 9);
        reg_wr <= '1';
        next_state <= idle;
      when halt =>
        curr_state <= x"0008";
        next_instr <= '0';
        next_state <= halt;
      when others =>
        curr_state <= x"0009";
        next_instr <= '0';
        next_state <= idle;
    end case;
  end process state_logic;

  
  
  state_reg:process(clk, reset)
  begin
    if reset = '1' then
      state <= idle;
      -- i set clk='0' here because it was transitioning states after 1 full
      -- clock cycle, which made things not work, since i'm looking at the
      -- instruction for how to process things.  and the instruction has
      -- changed by the time the state changes
      -- that doesn't seem to be working though, and it confuses me
    elsif (clk'EVENT and clk='1') then
      state <= next_state;
    end if;
  end process state_reg;
end control_arch;
