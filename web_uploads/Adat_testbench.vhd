LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Adat_Test IS
END Adat_Test;

ARCHITECTURE behavior OF Adat_Test IS

 COMPONENT adat_receiver
 PORT(
  m_clk : in std_logic;
  adat_in : IN std_logic;
  
  bus_address : IN std_logic_vector(2 downto 0);
  bus_enable : IN std_logic;
  
  bus_data : OUT std_logic_vector(23 downto 0);
  adat_wordclock : OUT std_logic;
  adat_user : OUT std_logic_vector(3 downto 0)
 );
 END COMPONENT;
 
 -- **Inputs**
 SIGNAL m_clk : std_logic := '0';
 SIGNAL adat_in : std_logic := '0';
 SIGNAL bus_address : std_logic_vector(2 downto 0) := (others=>'0');
 SIGNAL bus_enable : std_logic := '0';
 
 -- **Outputs**
 SIGNAL bus_data : Std_logic_vector(23 downto 0);
 SIGNAL adat_user : std_logic_vector(3 downto 0);
 SIGNAL adat_wordclock: std_logic := '0';
 
 constant m_clk_half_period : time := 5 ns;
 constant adat_period : time := 81.380208333333333333333333333333 ns;
 constant adat_half_period : time := 40.690104166666666666666666666667 ns;
 
BEGIN

 uut: adat_receiver PORT MAP(
  m_clk => m_clk,
  adat_in => adat_in,
  bus_address => bus_address,
  bus_enable => bus_enable,
  bus_data => bus_data,
  adat_user => adat_user,
  adat_wordclock => adat_wordclock
 );
 
 m_clk_clock_gen : process is
 begin
  m_clk <= '0' after m_clk_half_period, '1' after 2 * m_clk_half_period;
  wait for 2 * m_clk_half_period;
 end process m_clk_clock_gen;
 
 tb : PROCESS
 BEGIN
  -- wait for reset
  for frame_counter in 0 to 50 loop
   -- send adat training sequence
   adat_in <= '0';
   wait for 10 * adat_period;
   -- send adat sync symbol (1)
   adat_in <= not(adat_in);
   wait for adat_period;
   -- Send user characters
   wait for adat_period;
   wait for adat_period;
   wait for adat_period;
   wait for adat_period;
   -- send adat sync symbol (1)
   adat_in <= not(adat_in);
   wait for adat_period;
    for channel_counter in 0 to 7 loop
     for nibble_counter in 0 to 5 loop
      -- Send channel data
      adat_in <= not(adat_in);      
      wait for adat_period;
      adat_in <= not(adat_in);
      wait for adat_period;
      adat_in <= not(adat_in);
      wait for adat_period;
      adat_in <= not(adat_in);
      wait for adat_period;
      -- send adat sync symbol (1)
      adat_in <= not(adat_in);
      wait for adat_period;
     end loop;
    end loop;

   -- send adat training sequence
   adat_in <= '0';
   wait for 10 * adat_period;
   -- send adat sync symbol (1)
   adat_in <= not(adat_in);
   wait for adat_period;
   -- Send user characters
      adat_in <= not(adat_in);
   wait for adat_period;
      adat_in <= not(adat_in);
   wait for adat_period;
      adat_in <= not(adat_in);
   wait for adat_period;
      adat_in <= not(adat_in);
   wait for adat_period;
   -- send adat sync symbol (1)
   adat_in <= not(adat_in);
   wait for adat_period;
    for channel_counter in 0 to 7 loop
     for nibble_counter in 0 to 5 loop
      -- Send channel data
      wait for adat_period;
      wait for adat_period;
      wait for adat_period;
      wait for adat_period;
      -- send adat sync symbol (1)
      adat_in <= not(adat_in);
      wait for adat_period;


     end loop;
    end loop;
   end loop;
  wait; -- wait forever
 END PROCESS;
END;