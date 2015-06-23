LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.components.ALL;
USE work.cpu_types.ALL;

ENTITY processor_E IS
  PORT(prog_adr        : OUT d_bus;
       prog_data       : IN  d_bus;
       datmem_data_in  : IN  d_bus;
       datmem_data_out : OUT d_bus;
       datmem_nrd      : OUT STD_LOGIC;
       datmem_nwr      : OUT STD_LOGIC;
       datmem_adr      : OUT d_bus;
       a               : OUT d_bus;
       b               : OUT d_bus;
       cflag           : OUT STD_LOGIC;
       zflag           : OUT STD_LOGIC;
       clk             : IN  STD_LOGIC;
       nreset          : IN  STD_LOGIC;
       nreset_int      : IN  STD_LOGIC;
       go_step         : IN  STD_LOGIC;
       one_step        : IN  STD_LOGIC);
END processor_E;


ARCHITECTURE rtl_A OF processor_E IS
  SIGNAL carry_reg_alu,zero_reg_alu,rst_int,carry_alu_reg,zero_alu_reg,flagz_alu_control,flagc_alu_control : STD_LOGIC; -- H-activ internal reset SIGNAL
  signal ram_data_reg,a_reg_alu,b_reg_alu,result_alu_reg : d_bus;
  SIGNAL control_int, control_nxt_int : opcode;
BEGIN
  rst_int <= (NOT nreset) OR (NOT nreset_int);
  a <= a_reg_alu;
  b <= b_reg_alu;
  cflag <= carry_reg_alu;
  zflag <= zero_reg_alu;

alu_i: alu
  port map(
    a => a_reg_alu,
    b => b_reg_alu,
    rom_data => prog_data,
    ram_data => ram_data_reg,
    control => control_int,
    carry => carry_reg_alu,
    zero => zero_reg_alu,
    result => result_alu_reg,
    carry_out => carry_alu_reg,
    zero_out => zero_alu_reg,
    flagc => flagc_alu_control,
    flagz => flagz_alu_control );

reg_i: reg
  port MAP(
    clk => clk,
    rst => rst_int,
    carry_in => carry_alu_reg,
    zero_in => zero_alu_reg,
    result_in => result_alu_reg,
    rom_data_in => prog_data,
    control => control_int,
    a_out => a_reg_alu,
    b_out => b_reg_alu,
    carry_out => carry_reg_alu,
    zero_out => zero_reg_alu );

control_i: control
  PORT MAP (
    clk    => clk,
    rst    => rst_int,
    carry  => carry_reg_alu,
    carry_new => carry_alu_reg,
    zero   => zero_reg_alu,
    zero_new => zero_alu_reg,
    input  => prog_data,
    output => control_int,
    output_nxt => control_nxt_int,
    flagz => flagz_alu_control,
    flagc => flagc_alu_control );
  
pc_i: pc
  PORT MAP (
    clk     => clk,
    rst     => rst_int,
    addr_in => prog_data,
    control => control_nxt_int,
    pc      => prog_adr );

ram_control_i: ram_control
  PORT MAP (
    clk       => clk,
    rst	      => rst_int,
    input_a   => a_reg_alu,
    input_rom => prog_data,
    input_ram => datmem_data_in,
    control   => control_int,
    ram_data_reg => ram_data_reg,
    addr      => datmem_adr,
    data      => datmem_data_out,
    ce_nwr    => datmem_nwr,
    ce_nrd    => datmem_nrd );
END rtl_A;
