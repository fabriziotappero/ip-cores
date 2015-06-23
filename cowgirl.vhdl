-- here's the whole thing

-- on 22 mar i did something strange.  i took the pc off the clock and made it
-- transition on the signal next_instr from the control unit.  that way, the
-- states will get the correct instruction

library ieee;
use ieee.std_logic_1164.all;

entity cowgirl is
  
  port (
    clk    : in  std_logic;                       -- system clock
    reset  : in  std_logic;                       -- system reset
    to_ram : out std_logic_vector(15 downto 0));   -- write to RAM
end cowgirl;

architecture cowgirl_arch of cowgirl is
  
  component alu
    port (
      a       : in std_logic_vector(15 downto 0);
      b       : in std_logic_vector(15 downto 0);
      a_or_l  : in std_logic;
      op      : in std_logic_vector(2 downto 0);
      o       : out std_logic_vector(15 downto 0));  
  end component;

  component pc
    port (
      reset : in  std_logic;
      clk   : in  std_logic;
      load  : in  std_logic;
      d     : in  std_logic_vector(15 downto 0);
      c     : out std_logic_vector(15 downto 0));
  end component;

  component registers
    port (
      d      : in  std_logic_vector(15 downto 0);
      clk    : in  std_logic;
      addr_a : in  std_logic_vector(2 downto 0);
      addr_b : in  std_logic_vector(2 downto 0);
      wr_en  : in  std_logic;
      a_o    : out std_logic_vector(15 downto 0);
      b_o    : out std_logic_vector(15 downto 0));
  end component;

  component shifter
    port (
      n_shift : in  std_logic_vector(7 downto 0);
      sh_type : in  std_logic_vector(1 downto 0);
      data    : in  std_logic_vector(15 downto 0);
      o       : out std_logic_vector(15 downto 0));
  end component;

  component control
    port (
      instr     : in  std_logic_vector(15 downto 0);
      clk       : in  std_logic;
      reset     : in  std_logic;
      mem_ready : in  std_logic;
      a_or_l    : out std_logic;
      op        : out std_logic_vector(2 downto 0);
      addr_a    : out std_logic_vector(2 downto 0);
      addr_b    : out std_logic_vector(2 downto 0);
      reg_addr  : out std_logic_vector(2 downto 0);
      to_regs   : out std_logic_vector(15 downto 0);
      to_pc     : out std_logic_vector(15 downto 0);
      load_pc   : out std_logic;
      reg_wr    : out std_logic;
      alu_or_imm: out std_logic;
      next_instr: out std_logic;
      curr_state: out std_logic_vector(15 downto 0));
  end component;

  component mux_2_1
    port (
      a   : in  std_logic_vector(15 downto 0);
      b   : in  std_logic_vector(15 downto 0);
      sel : in  std_logic;
      o   : out std_logic_vector(15 downto 0));
  end component;

  component prog_rom
    port (
      input  : in  std_logic_vector(15 downto 0);
      output : out std_logic_vector(15 downto 0));
  end component;

  -- here are my internal signals
  signal reg_a_out, reg_b_out, alu_out, pc_to_rom, rom_out, immediate, reg_val : std_logic_vector(15 downto 0);
  signal control_to_pc, curr_state : std_logic_vector(15 downto 0);
  signal address_a, address_b, alu_opcode, reg_wr_addr : std_logic_vector(2 downto 0);
  signal write_regs, a_or_l, load_pc, mem_ready, alu_or_imm, pc_clock : std_logic;

  
begin  -- cowgirl_arch

  regs: registers
    port map (d => reg_val, clk => clk, addr_a => address_a, addr_b => address_b, wr_en => write_regs, a_o => reg_a_out, b_o => reg_b_out);
  abacus: alu
    port map (reg_a_out, reg_b_out, a_or_l, alu_opcode, alu_out);
  program_counter: pc
    port map (reset, pc_clock, load_pc, reg_a_out, pc_to_rom);
  program_rom: prog_rom
    port map (pc_to_rom, rom_out);
  reg_mux: mux_2_1
    port map (alu_out, immediate, alu_or_imm, reg_val);
  brain: control
    port map (rom_out, clk, reset, mem_ready, a_or_l, alu_opcode, address_a, address_b, reg_wr_addr, immediate, control_to_pc, load_pc, write_regs, alu_or_imm, pc_clock, curr_state);
    
end cowgirl_arch;
