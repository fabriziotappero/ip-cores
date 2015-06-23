

-- Copyright (c) 2013 Antonio de la Piedra
 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_sha_256 IS
END tb_sha_256;
 
ARCHITECTURE behavior OF tb_sha_256 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sha_256
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
			gen_hash : in std_logic;
         msg_0 : IN  std_logic_vector(31 downto 0);
         msg_1 : IN  std_logic_vector(31 downto 0);
         msg_2 : IN  std_logic_vector(31 downto 0);
         msg_3 : IN  std_logic_vector(31 downto 0);
         msg_4 : IN  std_logic_vector(31 downto 0);
         msg_5 : IN  std_logic_vector(31 downto 0);
         msg_6 : IN  std_logic_vector(31 downto 0);
         msg_7 : IN  std_logic_vector(31 downto 0);
         msg_8 : IN  std_logic_vector(31 downto 0);
         msg_9 : IN  std_logic_vector(31 downto 0);
         msg_10 : IN  std_logic_vector(31 downto 0);
         msg_11 : IN  std_logic_vector(31 downto 0);
         msg_12 : IN  std_logic_vector(31 downto 0);
         msg_13 : IN  std_logic_vector(31 downto 0);
         msg_14 : IN  std_logic_vector(31 downto 0);
         msg_15 : IN  std_logic_vector(31 downto 0);
         a_out : OUT  std_logic_vector(31 downto 0);
         b_out : OUT  std_logic_vector(31 downto 0);
         c_out : OUT  std_logic_vector(31 downto 0);
         d_out : OUT  std_logic_vector(31 downto 0);
         e_out : OUT  std_logic_vector(31 downto 0);
         f_out : OUT  std_logic_vector(31 downto 0);
         g_out : OUT  std_logic_vector(31 downto 0);
         h_out : OUT  std_logic_vector(31 downto 0);
			block_ready : out std_logic;
			hash : out std_logic_vector(255 downto 0));
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
	signal gen_hash : std_logic := '0';
   signal msg_0 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_1 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_2 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_3 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_4 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_5 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_6 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_7 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_8 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_9 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_10 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_11 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_12 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_13 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_14 : std_logic_vector(31 downto 0) := (others => '0');
   signal msg_15 : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal a_out : std_logic_vector(31 downto 0);
   signal b_out : std_logic_vector(31 downto 0);
   signal c_out : std_logic_vector(31 downto 0);
   signal d_out : std_logic_vector(31 downto 0);
   signal e_out : std_logic_vector(31 downto 0);
   signal f_out : std_logic_vector(31 downto 0);
   signal g_out : std_logic_vector(31 downto 0);
   signal h_out : std_logic_vector(31 downto 0);
	signal block_ready : std_logic;
   signal hash : std_logic_vector(255 downto 0);				 	 

	-- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sha_256 PORT MAP (
          clk => clk,
          rst => rst,
			 gen_hash => gen_hash,
          msg_0 => msg_0,
          msg_1 => msg_1,
          msg_2 => msg_2,
          msg_3 => msg_3,
          msg_4 => msg_4,
          msg_5 => msg_5,
          msg_6 => msg_6,
          msg_7 => msg_7,
          msg_8 => msg_8,
          msg_9 => msg_9,
          msg_10 => msg_10,
          msg_11 => msg_11,
          msg_12 => msg_12,
          msg_13 => msg_13,
          msg_14 => msg_14,
          msg_15 => msg_15,
          a_out => a_out,
          b_out => b_out,
          c_out => c_out,
          d_out => d_out,
          e_out => e_out,
          f_out => f_out,
          g_out => g_out,
          h_out => h_out,
			 block_ready => block_ready,
			 hash => hash
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
     	wait for clk_period/2 + clk_period;
		
		-- Example from "APPENDIX B: SHA-256 EXAMPLES",
		-- B.1 SHA-256 Example (One-Block Message)
		-- FIPS 180-26
		
		msg_0 <= X"00000018";
      msg_1 <= X"00000000";
      msg_2 <= X"00000000";
      msg_3 <= X"00000000";
      msg_4 <= X"00000000";
      msg_5 <= X"00000000";
      msg_6 <= X"00000000";
      msg_7 <= X"00000000";
      msg_8 <= X"00000000";
      msg_9 <= X"00000000";
      msg_10 <= X"00000000";
      msg_11 <= X"00000000";
      msg_12 <= X"00000000";
      msg_13 <= X"00000000";
      msg_14 <= X"00000000";
      msg_15 <= X"61626380";
		
		rst <= '1';
		wait for clk_period;
		rst <= '0';
		gen_hash <= '1';
      
      wait for 0.66 us + clk_period;

      assert hash = X"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
			report "B.1 Hash output ERROR" severity FAILURE;
		
		-- Example from "APPENDIX B: SHA-256 EXAMPLES",
		-- B.1 SHA-256 Example (One-Block Message)
		-- FIPS 180-26
		
		gen_hash <= '0';
		wait for clk_period;
		
		rst <= '1';
		wait for clk_period;
		rst <= '0';
      		
		msg_15 <= X"61626364";
      msg_14 <= X"62636465";
      msg_13 <= X"63646566";
      msg_12 <= X"64656667";
      msg_11 <= X"65666768";
      msg_10 <= X"66676869";
      msg_9  <= X"6768696A";
      msg_8  <= X"68696A6B";
      msg_7  <= X"696A6B6C";
      msg_6  <= X"6A6B6C6D";
      msg_5  <= X"6B6C6D6E";
      msg_4  <= X"6C6D6E6F";
      msg_3  <= X"6D6E6F70";
      msg_2  <= X"6E6F7071";
      msg_1  <= X"80000000";
      msg_0  <= X"00000000";
	
		gen_hash <= '1';
		
      wait for 0.66 us + clk_period;

      assert hash = X"85e655d6417a17953363376a624cde5c76e09589cac5f811cc4b32c1f20e533a"
			report "B.2 (Part 1) Hash output ERROR" severity FAILURE;		
		
		gen_hash <= '0';
		wait for clk_period;

		msg_15 <= X"00000000";
      msg_14 <= X"00000000";
      msg_13 <= X"00000000";
      msg_12 <= X"00000000";
      msg_11 <= X"00000000";
      msg_10 <= X"00000000";
      msg_9 <= X"00000000";
      msg_8 <= X"00000000";
      msg_7 <= X"00000000";
      msg_6 <= X"00000000";
      msg_5 <= X"00000000";
      msg_4 <= X"00000000";
      msg_3 <= X"00000000";
      msg_2 <= X"00000000";
      msg_1 <= X"00000000";
      msg_0 <= X"000001c0";

		gen_hash <= '1';

     wait for 0.66 us + clk_period;

      assert hash = X"248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"
			report "B.2 (Part 2) Hash output ERROR" severity FAILURE;		
		
		gen_hash <= '0';
		
		wait;
   end process;

END;
