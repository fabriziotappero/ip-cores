LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.tinycpu.all;

ENTITY registerfile_tb IS
END registerfile_tb;
 
ARCHITECTURE behavior OF registerfile_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)
 
  component registerfile
  port(
    WriteEnable: in regwritetype;
    DataIn: in regdatatype;
    Clock: in std_logic;
    DataOut: out regdatatype
  );
  end component;
    

  --Inputs
  signal WriteEnable : regwritetype := (others => '0');
  signal DataIn: regdatatype := (others => "00000000");

  --Outputs
  signal DataOut: regdatatype := (others => "00000000");

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: registerfile PORT MAP (
    WriteEnable => WriteEnable,
    DataIn => DataIn,
    Clock => Clock,
    DataOut => DataOut
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
    -- hold reset state for 100 ns.
    wait for 100 ns;	

    wait for clock_period*10;

    -- case 1
    WriteEnable(1) <= '1';
    DataIn(1) <= "11110000";
    wait for 10 ns;
    WriteEnable(1) <= '0';
    wait for 10 ns;
    assert (DataOut(1)="11110000") report "Storage error case 1" severity error;

    -- case 2
    WriteEnable(5) <= '1';
    DataIn(5) <= "11110001";
    wait for 10 ns;
    WriteEnable(5) <= '0';
    wait for 10 ns;
    assert (DataOut(5)="11110001") report "Storage selector error case 2" severity error;

    -- case 3;
    wait for 10 ns;
    assert (DataOut(1)="11110000") report "Storage selector(remembering) error case 3" severity error;
    
    --case 4
    DataIn(0) <= x"12";
    DataIn(1) <= x"34";
    WriteEnable(0) <= '1';
    WriteEnable(1) <= '1';
    wait for 10 ns;
    DataIn(0) <= x"90";
    WriteEnable(0) <= '0';
    WriteEnable(1) <= '0';
    wait for 10 ns;
    assert (DataOut(0)=x"12" and DataOut(1)=x"34") report "simultaneous write and read error case 4" severity error;
    
    --case 5
    DataIn(0) <= x"55";
    WriteEnable(0) <= '1';
    wait for 10 ns;
    DataIn(0) <= x"77";
    assert (DataOut(0)=x"55") report "Write during read error case 5" severity error;
    wait for 10 ns;




    -- summary of testbench
    assert false
    report "Testbench of registerfile completed successfully!"
    severity note;

    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
