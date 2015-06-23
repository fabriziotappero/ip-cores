
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
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY d_encoder_d_decoder_tb IS
END d_encoder_d_decoder_tb;
 
ARCHITECTURE behavior OF d_encoder_d_decoder_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT d_encoder_d_decoder
    PORT(
         tx_tetra_clk_36_KHz : IN  std_logic;
         tx_tetra_clk_18_KHz : IN  std_logic;
         tx_tetra_rst : IN  std_logic;
         tx_tetra_bit_stream_input : IN  std_logic;
         tx_tetra_valid_input : IN  std_logic;
         tx_tetra_debug_dbit_output : OUT  std_logic_vector(1 downto 0);
         tx_tetra_diffPhaseEncoder_output_0 : OUT  std_logic_vector(7 downto 0);
         tx_tetra_diffPhaseEncoder_output_1 : OUT  std_logic_vector(7 downto 0);
         rx_clk_18_KHz : IN  std_logic;
         rx_rst : IN  std_logic;
         rx_en : IN  std_logic;
         rx_a_k : OUT  std_logic_vector(7 downto 0);
         rx_b_k : OUT  std_logic_vector(7 downto 0);
         rx_i_k : IN  std_logic_vector(7 downto 0);
         rx_q_k : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal tx_tetra_clk_36_KHz : std_logic := '0';
   signal tx_tetra_clk_18_KHz : std_logic := '0';
   signal tx_tetra_rst : std_logic := '0';
   signal tx_tetra_bit_stream_input : std_logic := '0';
   signal tx_tetra_valid_input : std_logic := '0';
   signal rx_clk_18_KHz : std_logic := '0';
   signal rx_rst : std_logic := '0';
   signal rx_en : std_logic := '0';
   signal rx_i_k : std_logic_vector(7 downto 0) := (others => '0');
   signal rx_q_k : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal tx_tetra_debug_dbit_output : std_logic_vector(1 downto 0);
   signal tx_tetra_diffPhaseEncoder_output_0 : std_logic_vector(7 downto 0);
   signal tx_tetra_diffPhaseEncoder_output_1 : std_logic_vector(7 downto 0);
   signal rx_a_k : std_logic_vector(7 downto 0);
   signal rx_b_k : std_logic_vector(7 downto 0);
 
	signal start_decoding : std_logic;
 
	constant tetra_clk_36_KHz_period : time := 27.778 us;
	constant tetra_clk_18_KHz_period : time := 55.556 us;
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: d_encoder_d_decoder PORT MAP (
          tx_tetra_clk_36_KHz => tx_tetra_clk_36_KHz,
          tx_tetra_clk_18_KHz => tx_tetra_clk_18_KHz,
          tx_tetra_rst => tx_tetra_rst,
          tx_tetra_bit_stream_input => tx_tetra_bit_stream_input,
          tx_tetra_valid_input => tx_tetra_valid_input,
          tx_tetra_debug_dbit_output => tx_tetra_debug_dbit_output,
          tx_tetra_diffPhaseEncoder_output_0 => tx_tetra_diffPhaseEncoder_output_0,
          tx_tetra_diffPhaseEncoder_output_1 => tx_tetra_diffPhaseEncoder_output_1,
          rx_clk_18_KHz => rx_clk_18_KHz,
          rx_rst => rx_rst,
          rx_en => rx_en,
          rx_a_k => rx_a_k,
          rx_b_k => rx_b_k,
          rx_i_k => rx_i_k,
          rx_q_k => rx_q_k
        );
 
 tetra_clk_36_KHz_process :process
   begin
		tx_tetra_clk_36_KHz <= '0';
		wait for tetra_clk_36_KHz_period/2;
		tx_tetra_clk_36_KHz <= '1';
		wait for tetra_clk_36_KHz_period/2;
   end process;
 
    tetra_clk_18_KHz_process :process
   begin
		tx_tetra_clk_18_KHz <= '0';
		rx_clk_18_KHz <= '0';
		wait for tetra_clk_18_KHz_period/2;
		tx_tetra_clk_18_KHz <= '1';
		rx_clk_18_KHz <= '1';
		wait for tetra_clk_18_KHz_period/2;
   end process;
 
	 rx_i_k <= tx_tetra_diffPhaseEncoder_output_0 when start_decoding = '1' else (others=>'0');
	 rx_q_k <= tx_tetra_diffPhaseEncoder_output_1 when start_decoding = '1' else (others=>'0');
	 rx_en <= '1' when start_decoding = '1' else '0';
	 
	decode_tx: process
	begin
		wait for 166.668 us;
		start_decoding <= '1';
		wait;
	end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      tx_tetra_rst <= '1';
		rx_rst <= '1';
		wait for tetra_clk_18_KHz_period*2;
		tx_tetra_rst <= '0';
		rx_rst <= '0';

		tx_tetra_valid_input <= '1';
		
		tx_tetra_bit_stream_input <= '1';
		wait for tetra_clk_36_KHz_period;
		
		tx_tetra_bit_stream_input <= '0';
		wait for tetra_clk_36_KHz_period;
		
		tx_tetra_bit_stream_input <= '1';
		wait for tetra_clk_36_KHz_period;
		
		tx_tetra_bit_stream_input <= '1';
		wait for tetra_clk_36_KHz_period;

		tx_tetra_bit_stream_input <= '0';
		wait for tetra_clk_36_KHz_period;
		
		tx_tetra_bit_stream_input <= '0';
		wait for tetra_clk_36_KHz_period;
		
		tx_tetra_bit_stream_input <= '1';
		wait for tetra_clk_36_KHz_period;
		
		tx_tetra_bit_stream_input <= '1';
		
		wait for tetra_clk_36_KHz_period*50;
      wait;		
		

      -- insert stimulus here 

      wait;
   end process;

END;
