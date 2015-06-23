----------------------------------------------------------------------
----                                                              ----
---- Parallel Scrambler.                                              
----                                                              ----
---- This file is part of the Configurable Parallel Scrambler project 
---- http://opencores.org/project,parallel_scrambler              ----
----                                                              ----
---- Description                                                  ----
---- Test bench for Parallel scrambler/descrambler module		  ----
----                                                 			  ----
----                                                              ----
---- License: LGPL                                                ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Howard Yin, sparkish@opencores.org                         ----
----                                                              ----
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
ENTITY tb_par_scram IS
END tb_par_scram;
 
ARCHITECTURE behavior OF tb_par_scram IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component par_scrambler  
	generic (
		Data_Width 			: integer;
		Polynomial_Width	: integer
		);
	port ( 
		rst, clk, scram_rst : in std_logic;
		Polynomial			: in std_logic_vector (Polynomial_Width downto 0);
		data_in 			: in std_logic_vector (Data_Width-1 downto 0);
		scram_en			: in std_logic; 
		data_out 			: out std_logic_vector (Data_Width-1 downto 0);
		out_valid			: out std_logic
		);
	end component;

   --Inputs
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal scram_en : std_logic := '0';
   signal scram_start : std_logic := '0';
   signal rst : std_logic := '1';
   signal clk : std_logic := '0';

 	--Outputs
   signal scram_data_out : std_logic_vector(7 downto 0);
   signal descram_data_out : std_logic_vector(7 downto 0);
   signal scram_data_valid : std_logic;
   signal descram_data_valid : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   scram_mod: par_scrambler 
	Generic Map (
		Data_Width			=> 8,
		Polynomial_Width	=> 7
		
	)
	PORT MAP (
		  Polynomial			=> "10010001",
          data_in => data_in,
          scram_en => scram_en,
          scram_rst => scram_start,
          rst => rst,
          clk => clk,
          data_out => scram_data_out,
          out_valid => scram_data_valid
        );
		
   descram_mod: par_scrambler 
	Generic Map (
		Data_Width			=> 8,
		Polynomial_Width	=> 7
		
	)
	PORT MAP (
	      Polynomial			=> "10010001",
          data_in => scram_data_out,
          scram_en => scram_data_valid,
          scram_rst => scram_start,
          rst => rst,
          clk => clk,
          data_out => descram_data_out,
          out_valid => descram_data_valid
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
      -- hold reset state for 100 ns.
		rst <= '1';
		wait for 90 ns;
		rst <= '0';
		wait for clk_period*10;
		scram_start <= '1';
		wait for clk_period;
		scram_start <= '0';
		wait for clk_period*10;
		
		for i in 0 to 7 loop
			wait until (rising_edge(clk));
			scram_en <= '1';
			data_in <= std_logic_vector(to_unsigned(i, 8));		
		end loop;
		wait until (rising_edge(clk));
		scram_en <= '0';
		
		wait for clk_period*10;
		
		for i in 0 to 7 loop
			wait until (rising_edge(clk));
			scram_en <= '1';
			data_in <= std_logic_vector(to_unsigned(i, 8));		
			wait until (rising_edge(clk));
			scram_en <= '0';
			wait for clk_period*10;
		end loop;

      wait;
   end process;

END;
