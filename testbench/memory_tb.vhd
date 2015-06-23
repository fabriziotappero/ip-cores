LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY memory_tb IS
END memory_tb;
 
ARCHITECTURE behavior OF memory_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)
 
  component memory
    port(
      Address: in std_logic_vector(15 downto 0); --memory address (in bytes)
      WriteWord: in std_logic; --if set, will write a full 16-bit word instead of a byte. Address must be aligned to 16-bit address. (bottom bit must be 0)
      WriteEnable: in std_logic;
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0);
      DataOut: out std_logic_vector(15 downto 0);
      Port0: inout std_logic_vector(7 downto 0)
    );
  end component;
    

  --Inputs
  signal Address: std_logic_vector(15 downto 0) := (others => '0');
  signal WriteWord: std_logic := '0';
  signal WriteEnable: std_logic := '0';
  signal DataIn: std_logic_vector(15 downto 0) := (others => '0');

  --Outputs
  signal DataOut: std_logic_vector(15 downto 0);

  --inouts
  signal Port0: std_logic_vector(7 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: memory PORT MAP (
    Address => Address,
    WriteWord => WriteWord,
    WriteEnable => WriteEnable,
    Clock => Clock,
    DataIn => DataIn,
    DataOut => DataOut,
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
    wait for 50 ns;    

    
    Address <= x"0100";
    WriteWord <= '1';
    WriteEnable <='1';
    DataIn <= x"1234";
    wait for 10 ns;
    WriteWord <= '0';
    WriteEnable <= '0';
    wait for 10 ns;
    assert (DataOut = x"1234") report "Basic storage failure" severity error;
    
    Address <= x"0122";
    WriteWord <= '1';
    WriteEnable <= '1';
    DataIn <= x"5215";
    wait for 10 ns;
    assert (DataOut = x"1234") report "no-change block ram failure" severity error;
    WriteWord <= '0';
    WriteEnable <= '0';
    Address <= x"0100";
    wait for 10 ns;
    assert( DataOut = x"1234") report "Memory retention failure" severity error;
    Address <= x"0122";
    wait for 10 ns;
    assert( DataOut = x"5215") report "memory timing is too slow" severity error;
    
    Address <= x"0110";
    WriteWord <= '1';
    WriteEnable <= '1';
    DataIn <= x"1234";
    wait for 10 ns;
    WriteWord <= '0';
    WriteEnable <= '0';
    Address <= x"0111";
    wait for 10 ns;
    assert (DataOut = x"0012") report "unaligned 8-bit memory read is wrong" severity error;
    WriteWord <='0';
    WriteEnable <= '1';
    DataIn <= x"0056";
    wait for 10 ns;
    WriteEnable <= '0';
    wait for 10 ns;
    assert (DataOut = x"0056") report "unaligned 8 bit memory write and then read is wrong" severity error;
    Address <= x"0110";
    wait for 10 ns;
    assert (DataOut = x"5634") report "aligned memory read after unaligned write is wrong" severity error;
    WriteEnable <= '1';
    DataIn <= x"0078";
    wait for 10 ns;
    WriteEnable <= '0';
    wait for 10 ns;
    assert (DataOut = x"5678") report "aligned 8-bit memory write is wrong" severity error;
    
    Address <= x"0001";
    Port0 <= "ZZZZZZ1Z";
    WriteWord<='0';
    WriteEnable <= '1';
    DataIn <= x"0001";
    wait for 10 ns;
    WriteEnable <= '0';
    Address <= x"1234";
    wait for 20 ns;
    WriteEnable <= '1';
    Address <= x"0000";
    DataIn <= x"0001";
    
    wait for 10 ns;
    WriteEnable <= '0';
    assert(Port0(0)='1') report "port0 not right 1" severity error;
    wait for 10 ns;
    assert(DataOut(1)='1') report "port0 not right 2" severity error;


    wait for 10 ns;
    Address <= x"0001";
    WriteWord <= '0';
    WriteEnable <= '1';
    DataIn <= b"00000000_0011_1000";
    wait for 10 ns;
    Address <= x"0000";
    Port0 <= "10ZZZ101";
    DataIn <= x"00" & b"00_101_011";
    wait for 10 ns;
    WriteEnable <= '0';
    wait for 10 ns;
    assert(Port0 = "10101101") report "Memory mapped port does not work correctly" severity error;
    assert(DataOut = x"00" & "10101101") report "Memory read of mapped port does not work correctly" severity error;
    

   assert false
   report "Testbench of memory completed successfully!"
   severity note;
            
    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
