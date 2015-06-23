LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.tinycpu.all;

ENTITY fetch_tb IS
END fetch_tb;
 
ARCHITECTURE behavior OF fetch_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)
 
  component fetch is 
    port(
      Enable: in std_logic;
      AddressIn: in std_logic_vector(15 downto 0);
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0); --interface from memory
      IROut: out std_logic_vector(15 downto 0);
      AddressOut: out std_logic_vector(15 downto 0) --interface to memory
    );
  end component;
    
  

  signal Enable: std_logic := '0';
  signal AddressIn: std_logic_vector(15 downto 0) := x"0000";
  signal DataIn: std_logic_vector(15 downto 0) := x"0000";
  
  signal IROut: std_logic_vector(15 downto 0);
  signal AddressOut: std_logic_vector(15 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: fetch PORT MAP (
    Enable => Enable,
    AddressIn => AddressIn,
    Clock => Clock,
    DataIn => DataIn,
    IROut => IROut,
    AddressOut => AddressOut
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
    -- hold reset state for 20 ns.
    wait for 10 ns;    

    --wait for clock_period*10;
    Enable<= '1';
    wait for 10 ns;
    
    Enable <= '1';
    AddressIn <= x"1234";
    DataIn <= x"5321";
    wait for 10 ns; 
    assert (IROut = x"5321" and AddressOut = x"1234") report "basic operation failure" severity error;
    
    AddressIn <= x"5121";
    DataIn <= x"1234";
    wait for 5 ns;
    assert (IROut = x"5321" and AddressOut = x"1234") report "Timing of latching is too early" severity error;
    wait for 5 ns;
    assert (IROut = x"1234" and AddressOut =x"5121") report "basic operation failure 2" severity error;


    AddressIn <= x"4278";
    DataIn <= x"5213";
    Enable <= '0';
    wait for 10 ns;
    assert (IROut = x"1234" and AddressOut = "ZZZZZZZZZZZZZZZZ") report "Latching doesn't work on disable" severity error;

    -- summary of testbench
    assert false
    report "Testbench of fetch completed successfully!"
    severity note;

    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
