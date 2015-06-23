-- Copyright (c) 2011 Antonio de la Piedra
 
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

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
use ieee.numeric_std.all;

use work.aes_lib.all;

entity aes_fsm_enc is
	port(	  clk: in std_logic;
		  rst : in std_logic;
		  block_in : in std_logic_vector(127 downto 0);
		  key : in std_logic_vector(127 downto 0);
		  enc : in std_logic;
		  block_out : out std_logic_vector(127 downto 0);
		  block_ready : out std_logic);
	end aes_fsm_enc;

architecture Behavioral of aes_fsm_enc is

  attribute buffer_type: string;

  type state_type is (idle, n_round_1, n_round_2, reinit, pre, all_reset);  
  
  signal state, next_state: state_type ;  
  signal block_in_s :  std_logic_vector(127 downto 0);
  signal sub_key_s :  std_logic_vector(127 downto 0);
  signal last_s :  std_logic;
  signal block_out_s :  std_logic_vector(127 downto 0);

  signal key_addr_1, key_addr_2 : std_logic_vector(3 downto 0);
  signal key_data_1, key_data_delay_1, key_data_2, key_data_delay_2 : std_logic_vector(127 downto 0);

  signal count: natural range 0 to 10;
  signal en_cnt : std_logic;
  signal clk_div_2, rst_div, rst_cnt : std_logic;
  
  attribute buffer_type of clk_div_2: signal is "bufg"; 
  
begin

  process1: process (clk,rst)  
  begin  
    if (rst ='1') then  
      state <= idle;  
    elsif rising_edge(clk) then  
      state <= next_state;  
    end if;  
  end process process1; 
 
  process2 : process (state, enc, block_in, key)
  begin  
    next_state <= state;
    
    last_s <= '0';
    block_in_s <= (others => '0');
    sub_key_s <= (others => '0');
    block_ready <= '0';
  
    rst_div <= '0';
    rst_cnt <= '0';
    
    en_cnt <= '0';
             		      
    case state is  
          when idle => 
            if enc ='1' then
              rst_div <= '1';
              rst_cnt <= '1';
              
              next_state <= all_reset;
            else
              next_state <= idle; 
            end if;  
          when all_reset =>
            rst_div <= '0';
            rst_cnt <= '0';
            
            en_cnt <= '1';
            
            next_state <= pre;  
          when pre =>
            
            en_cnt <= '1';
            
              sub_key_s <= key_data_1;
              block_in_s <= block_in xor key;

              next_state <= n_round_1;  
          when n_round_1 =>
            en_cnt <= '1';
            
            sub_key_s <= key_data_1;
            last_s <= '0';
            block_in_s <= block_out_s;

            next_state <= n_round_2;
          when n_round_2 =>
            en_cnt <= '1';
            
            sub_key_s <= key_data_1;
            block_in_s <= block_out_s;
            
            if count = 9 then
              last_s <= '1';
              block_ready <= '1';
              
              next_state <= reinit;
            else
              last_s <= '0';
              next_state <= n_round_1;
            end if;
          when reinit =>
            en_cnt <= '0';
            
            next_state <= idle;
    end case;  
          
  end process process2; 


  mod_10_cnt : process(clk_div_2, rst_cnt)
  begin
    if rising_edge(clk_div_2) then
      if (rst_cnt = '1') then
        count <= 0;
      elsif(en_cnt = '1') then
        if (count = 9) then
          count <= 0;
        else
          count <= count + 1;
        end if;
      end if;
     end if; 
  end process mod_10_cnt;

  key_addr_1 <= std_logic_vector(to_unsigned(count, key_addr_1'length));
  key_addr_2 <= std_logic_vector(to_unsigned(count, key_addr_2'length));

  AES_ROUND_N : entity work.aes_enc(Behavioral) port map (clk, 
                                                          block_in_s, 
                                                          sub_key_s, 
                                                          last_s,
                                                          block_out_s);
  
  SUB_KEYS_DRAM : entity work.dual_mem(rtl) generic map (4, 128, 10)
                                            port map (clk,
                                                      '0',
                                                      key_addr_1,
                                                      key_addr_2,
                                                      (others => '0'),
                                                      key_data_1,
                                                      key_data_2);
  clk_div : process(clk, rst_div)
  begin
    if rising_edge(clk) then
      if rst_div = '1' then
        clk_div_2 <= '0';
      else   
        clk_div_2 <= not(clk_div_2);
      end if;  
    end if;  
  end process;
  
  block_out <= block_out_s;
  
end Behavioral;

