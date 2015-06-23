LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.tinycpu.all;

ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)
 
  component alu is 
    port(
      Op: in std_logic_vector(4 downto 0);
      DataIn1: in std_logic_vector(7 downto 0);
      DataIn2: in std_logic_vector(7 downto 0);
      DataOut: out std_logic_vector(7 downto 0);
      TR: out std_logic
    );
  end component;
    

  --Inputs
  signal Op: std_logic_vector(4 downto 0) := "00000";
  signal DataIn1: std_logic_vector(7 downto 0) := "00000000";
  signal DataIn2: std_logic_vector(7 downto 0) := "00000000";
  --Outputs
  signal DataOut: std_logic_vector(7 downto 0);
  signal TR: std_logic;

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: alu PORT MAP (
    Op => Op,
    DataIn1 => DataIn1,
    DataIn2 => DataIn2,
    DataOut => DataOut,
    TR => TR
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
    wait for 20 ns;    

    --wait for clock_period*10;

    -- case 1
    Op <= "00000"; --and
    DataIn1 <= "10000001";
    DataIn2 <= "11111110";
    wait for 10 ns;
    assert (DataOut="10000000") report "And operation error case 1" severity error;
    -- case 2
    Op <= "00001"; --or
    DataIn1 <= "10000001";
    DataIn2 <= "11111100";
    wait for 10 ns;
    assert (DataOut="11111101") report "Or operation error" severity error;

    Op <= "00010"; --xor
    DataIn1 <= "10000001";
    DataIn2 <= "11111100";
    wait for 10 ns;
    assert (DataOut="01111101") report "Xor operation error" severity error;

    Op <= "00011"; --not
    DataIn1 <= "10000001";
    DataIn2 <= "11111100";
    wait for 10 ns;
    assert (DataOut="00000011") report "Not operation error" severity error;

    Op <= "00100"; --shift left
    DataIn1 <= "11110011";
    DataIn2 <= x"02";
    wait for 10 ns;
    assert (DataOut="11001100") report "shift left operation error" severity error;

    Op <= "00101"; --shift right
    DataIn1 <= "11110011";
    DataIn2 <= x"02";
    wait for 10 ns;
    assert (DataOut="00111100") report "shift right operation error" severity error;

    Op <= "00110"; --rotate left
    DataIn1 <= "11110011";
    DataIn2 <= x"02";
    wait for 10 ns;
    assert (DataOut="11001111") report "rotate left operation error" severity error;

    Op <= "00111"; --rotate right
    DataIn1 <= "11110011";
    DataIn2 <= x"02";
    wait for 10 ns;
    assert (DataOut="11111100") report "rotate right operation error" severity error;

    Op <= "01000"; --is greater than
    DataIn1 <= x"20";
    DataIn2 <= x"40";
    wait for 10 ns;
    assert (TR='0') report "is greater than operation error" severity error;

    Op <= "01001"; --is greater than or equal
    DataIn1 <= x"20";
    DataIn2 <= x"40";
    wait for 10 ns;
    assert (TR='0') report "greater than or equal operation error case 1" severity error;

    Op <= "01001"; --is greater than or equal
    DataIn1 <= x"40";
    DataIn2 <= x"40";
    wait for 10 ns;
    assert (TR='1') report "greater than or equal operation error case 2" severity error;

    Op <= "01010"; --is less than
    DataIn1 <= x"20";
    DataIn2 <= x"40";
    wait for 10 ns;
    assert (TR='1') report "less than operation error case 1" severity error;

    Op <= "01010"; --less than
    DataIn1 <= x"40";
    DataIn2 <= x"40";
    wait for 10 ns;
    assert (TR='0') report "less than operation error case 2" severity error;

    Op <= "01011"; --less than or equal
    DataIn1 <= x"20";
    DataIn2 <= x"40";
    wait for 10 ns;
    assert (TR='1') report "less than or equal operation error" severity error;
    
    Op <= "01100"; --equal
    DataIn1 <= x"20";
    DataIn2 <= x"40";
    wait for 10 ns;
    assert (TR='0') report "equal operation error" severity error;

    Op <= "01100"; --equal
    DataIn1 <= x"40";
    DataIn2 <= x"40";
    wait for 10 ns;
    assert (TR='1') report "equal operation error" severity error;

    Op <= "01101"; --not equal
    DataIn1 <= x"20";
    DataIn2 <= x"40";
    wait for 10 ns;
    assert (TR='1') report "not equal operation error" severity error;

    Op <= "01101"; --not equal
    DataIn1 <= x"40";
    DataIn2 <= x"40";
    wait for 10 ns;
    assert (TR='0') report "not equal operation error" severity error;

    Op <= "01110"; --equal to 0
    DataIn1 <= x"40";
    DataIn2 <= x"50";
    wait for 10 ns;
    assert (TR='0') report "equal to 0 operation error" severity error;
    Op <= "01110"; --equal to 0
    DataIn1 <= x"00";
    DataIn2 <= x"50";
    wait for 10 ns;
    assert (TR='1') report "equal to 0 operation error" severity error;

    Op <= "01111"; --not equal to 0
    DataIn1 <= x"40";
    DataIn2 <= x"50";
    wait for 10 ns;
    assert (TR='1') report "not equal to 0 operation error" severity error;
    Op <= "01111"; --not equal to 0
    DataIn1 <= x"00";
    DataIn2 <= x"50";
    wait for 10 ns;
    assert (TR='0') report "not equal to 0 operation error" severity error;

    Op <= "10000"; --set TR
    wait for 10 ns;
    assert (TR='1') report "set TR operation error" severity error;
    Op <= "10001"; --reset TR
    wait for 10 ns;
    assert (TR='0') report "reset TR operation error" severity error;

    Op <= "10010"; --increment
    DataIn1 <= x"42";
    DataIn2 <= x"50";
    wait for 10 ns;
    assert (DataOut=x"43") report "increment operation error" severity error;

    Op <= "10011"; --decrement
    DataIn1 <= x"42";
    DataIn2 <= x"50";
    wait for 10 ns;
    assert (DataOut=x"41") report "decrement operation error" severity error;

    Op <= "10100"; --add
    DataIn1 <= x"42";
    DataIn2 <= x"50";
    wait for 10 ns;
    assert (DataOut=x"92") report "add operation error" severity error;

    Op <= "10101"; --subtract
    DataIn1 <= x"50";
    DataIn2 <= x"42";
    wait for 10 ns;
    assert (DataOut=x"0E") report "subtract operation error" severity error;

    Op <= "10100"; --add
    DataIn1 <= x"FF";
    DataIn2 <= x"02";
    wait for 10 ns;
    assert (DataOut=x"01") report "add overflow operation error" severity error;

    Op <= "10101"; --subtract
    DataIn1 <= x"00";
    DataIn2 <= x"02";
    wait for 10 ns;
    assert (DataOut=x"FE") report "subtract underflow operation error" severity error;




    -- summary of testbench
    assert false
    report "Testbench of alu completed successfully!"
    severity note;

    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
