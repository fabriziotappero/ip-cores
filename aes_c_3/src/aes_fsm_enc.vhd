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
----------------------------------------------------------------------------------
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

  type state_type is (idle, n_round_1, n_round_2, n_round_3, reinit, reinit2, pre, all_reset);  
  
  signal state, next_state: state_type ;  
  signal block_in_s :  std_logic_vector(127 downto 0);
  signal sub_key_s :  std_logic_vector(127 downto 0);
  signal last_s :  std_logic;
  signal block_out_s, tmp :  std_logic_vector(127 downto 0);

  signal key_addr_1, key_addr_2 : std_logic_vector(3 downto 0);
  signal key_data_1, key_data_delay_1, key_data_2, key_data_delay_2 : std_logic_vector(127 downto 0);

  signal count: natural range 0 to 10;
  signal en_cnt : std_logic;
  signal clk_3, clk_tmp : std_logic;

  signal pos_cnt :std_logic_vector (1 downto 0);
  signal neg_cnt :std_logic_vector (1 downto 0);

  signal rst_div, rst_cnt : std_logic;
  
  attribute buffer_type of clk_3: signal is "bufg"; 
  
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
    en_cnt <= '0';

    rst_div <= '0';
    rst_cnt <= '0';
               		      
    case state is  
          when idle => 
            if enc ='1' then
              next_state <= all_reset;
            else
              en_cnt <= '0';
              next_state <= idle; 
            end if;  
          when all_reset =>
            rst_div <= '1';
            rst_cnt <= '1';
            
            next_state <= pre;  
          when pre =>
              rst_cnt <= '0';
              rst_div <= '0';
              
              sub_key_s <= key_data_1;
              block_in_s <= block_in xor key;
              en_cnt <= '1';

              next_state <= n_round_1;  
          when n_round_1 =>
            en_cnt <= '1';
            block_in_s <= tmp; 
            sub_key_s <= key_data_1;
            next_state <= n_round_2;
          when n_round_2 =>
            en_cnt <= '1';
            sub_key_s <= key_data_1;
            block_in_s <= tmp; 
            next_state <= n_round_3;
          when n_round_3 =>
            en_cnt <= '1';
            sub_key_s <= key_data_1;

            block_in_s <= tmp; 
              
              if count = 9 then
                last_s <= '1';
                block_ready <= '1';
                sub_key_s <= key_data_1;
                block_in_s <= tmp; 
                next_state <= reinit;
            else
              next_state <= n_round_1;
            end if;
          when reinit =>
            en_cnt <= '1';
            next_state <= idle;  
          when reinit2 =>
            en_cnt <= '1';
            next_state <= idle;
          end case;  
          
  end process process2; 

  get_output : process(clk, state)
  begin
    if rising_edge(clk) then
      if state = n_round_1 then
        tmp <= block_out_s;
      end if;
    end if;
  end process;

  mod_10_cnt : process(clk_3, rst_cnt)
  begin
    if rising_edge(clk_3) then
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
 
  block_out <= block_out_s;

      div_3_p_1: process (clk, rst_div) begin
          if (rst_div = '1') then
              pos_cnt <= (others=>'0');
          elsif (rising_edge(clk)) then
              pos_cnt <= pos_cnt + 1;
              if (pos_cnt = 2) then
                  pos_cnt <= (others => '0');
              end if;
         end if;
      end process;
     
      div_3_p_2: process (clk, rst_div) begin
          if (rst_div = '1') then
              neg_cnt <= (others=>'0');
          elsif (falling_edge(clk)) then
              neg_cnt <= neg_cnt + 1;
              if (neg_cnt = 2) then
                  neg_cnt <= (others => '0');
              end if;
          end if;
      end process;

      block_out <= block_out_s;


      clk_3 <= '0' when ((pos_cnt /= 2) and (neg_cnt /= 2)) else
              '1';
  
end Behavioral;

