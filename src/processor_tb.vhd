LIBRARY ieee;
USE ieee.std_logic_1164.all;
use work.cpu_types.all;

ENTITY processor_tb IS
END processor_tb;

ARCHITECTURE testbench OF processor_tb IS

  SIGNAL clk : STD_LOGIC := 'X';
  SIGNAL nreset : STD_LOGIC := 'X';
  SIGNAL one_step, go_step : STD_LOGIC := 'X';
  signal zflag, cflag : STD_LOGIC := 'X';
  signal a, b : STD_LOGIC_VECTOR(d_bus_width-1 DOWNTO 0) := (OTHERS => 'X');
  signal datmem_nrd, datmem_nwr : STD_LOGIC := 'X';
  signal datmem_adr : STD_LOGIC_VECTOR(a_bus_width-1 DOWNTO 0) := (OTHERS => 'X');
  signal datmem_data_in, datmem_data_out : STD_LOGIC_VECTOR(d_bus_width-1 DOWNTO 0) := (OTHERS => 'X');
  signal prog_adr : std_logic_vector(a_bus_width-1 DOWNTO 0) := (OTHERS => 'X');
  SIGNAL prog_data : STD_LOGIC_VECTOR(d_bus_width-1 DOWNTO 0) := (OTHERS => 'X');
  
  COMPONENT cpu
    PORT( prog_adr        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
          prog_data       : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
          datmem_data_in  : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
          datmem_data_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
          datmem_nrd      : OUT STD_LOGIC;
          datmem_nwr      : OUT STD_LOGIC;
          datmem_adr      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
          a               : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
          b               : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
          cflag           : OUT STD_LOGIC;
          zflag           : OUT STD_LOGIC;
          clk             : IN  STD_LOGIC;
          nreset          : IN  STD_LOGIC;
          nreset_int	  : in std_logic; 
          go_step         : IN  STD_LOGIC;
          one_step        : IN  STD_LOGIC );
  END COMPONENT;

  COMPONENT ram
    port( addr : IN a_bus;
          data_in : in d_bus;
          data_out : OUT d_bus;
          ce_nwr : in STD_LOGIC ;
          ce_nrd : in STD_LOGIC );
  END component;

  COMPONENT rom
    port( addr : IN a_bus;
          data : out d_bus );
  END COMPONENT;
  
for all: cpu USE ENTITY work.processor_E(rtl_A);
--for all: cpu use entity work.processor_E(structure); --vasco's cpu processor.model.vhdl

BEGIN

u_cpu: cpu
  PORT MAP( prog_adr => prog_adr, prog_data => prog_data, datmem_data_in => datmem_data_in, datmem_data_out => datmem_data_out,
            datmem_nrd => datmem_nrd, datmem_nwr => datmem_nwr, datmem_adr => datmem_adr, a => a, b => b, cflag => cflag,
            zflag => zflag, clk => clk, nreset_int => nreset, nreset => nreset, go_step => go_step, one_step => one_step);

u_ram: ram
  PORT MAP(addr => datmem_adr, data_in => datmem_data_out, data_out => datmem_data_in , ce_nwr => datmem_nwr, ce_nrd => datmem_nrd); 
   
u_rom: rom
  port map(addr => prog_adr, data => prog_data);

clk_p: PROCESS
  BEGIN
    clk <= '1'; 
    WAIT FOR 500 ns;
    clk <= '0';
    WAIT for 500 ns;
  END process;

init:PROCESS
  begin
    go_step <= '0';
    one_step <= '0';
    nreset <= '0', '1' AFTER 200000 ns; --200 us
    wait;
  END process;
  
END testbench;
