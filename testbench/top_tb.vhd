LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY top_tb IS
END top_tb;
 
ARCHITECTURE behavior OF top_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)

  component top is
    port(
      Reset: in std_logic;
      Hold: in std_logic;
      HoldAck: out std_logic;
      Clock: in std_logic;
      DMA: in std_logic; --when high, Address, WriteEnable, and Data are connected to memory
      Address: in std_logic_vector(15 downto 0); --memory address (in bytes)
      WriteEnable: in std_logic;
      Data: inout std_logic_vector(15 downto 0);
      Port0: inout std_logic_vector(7 downto 0);
      --debug ports
      DebugR0: out std_logic_vector(7 downto 0)
    );
  end component;
    

  signal Reset:std_logic:='0';
  signal Hold: std_logic:='0';
  signal HoldAck: std_logic;
  signal DMA: std_logic:='0'; --when high, Address, WriteEnable, and Data are connected to memory
  signal Address: std_logic_vector(15 downto 0):=x"0000"; --memory address (in bytes)
  signal WriteEnable: std_logic:='0';
  signal Data: std_logic_vector(15 downto 0):=x"0000";
  signal Port0: std_logic_vector(7 downto 0);
  --debug ports
  signal DebugR0: std_logic_vector(7 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: top PORT MAP (
    Reset => Reset,
    Hold => Hold,
    HoldAck => HoldAck,
    Clock => Clock,
    DMA => DMA,
    Address => Address,
    WriteEnable => WriteEnable,
    Data => Data,
    DebugR0 => DebugR0,
    Port0 => Port0
  );

  -- Clock process definitions
  clock_process :process
  begin
    Clock <= '0';
    wait for clock_period/2;
    Clock <= '1';
    wait for clock_period/2;
  end process;
 

  -- Stimulus process
  stim_proc: process
    variable err_cnt: integer :=0;
  begin         
    Port0 <= "ZZZZZZZZ";
    -- hold reset state for 100 ns.
    Reset <= '0';
    wait for 10 ns;
    Reset <= '1';
    wait for 200 ns;
    Reset <= '0';
    wait for 50 ns;
    Port0(1) <= '1';
    wait for 200 ns;
    assert(Port0(0)='1') report "Toggle app not working" severity error;
    wait for 10 ns;
    Port0(1) <= '0';
    wait for 200 ns;
    assert(Port0(0)='0') report "Toggle app not working 2" severity error;







    Reset <= '1';
    wait for 100 ns;
    wait for 10 ns;
    Hold <= '1';
    wait for 10 ns;
    assert (HoldAck ='1') report "HoldAck not becoming high" severity error;
    --load memory image
    DMA <= '1';
    WriteEnable <= '1';
    Address <= x"0100";
    Data <= x"0057";
    wait for 10 ns;
    Address <= x"0102";
    Data <= x"00F1";
    wait for 10 ns;
    Address <= x"0104";
    Data <= x"00FF";
    wait for 10 ns;
    Address <= x"0106";
    Data <= x"0063";
    wait for 10 ns;
    --Address <= x"0108";
    --wait for 10 ns;
    DMA <= '0';
    wait for 10 ns;
    Hold <= '0';
    wait for 10 ns;
    
    --start the processor
    Reset <= '0';
    wait for 30 ns; --wait 3 clock cycles for CPU to execute first instruction
    wait for 10 ns; --wait 1 clock cycle for first instruction decode
    assert(Debugr0 = x"57") report "R0 is not loaded properly for first instruction" severity error;
    wait for 10 ns;
    assert(DebugR0 = x"F1") report "R0 is not loaded properly for second instruction" severity error;
    


    


   assert false
   report "Testbench of top completed successfully!"
   severity note;
            
    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
