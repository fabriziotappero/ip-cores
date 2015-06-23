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

  type state_type is (idle, n_round_1, n_round_2, n_round_3, n_round_4, n_round_5, n_round_6, last_round_1,
                      last_round_2, last_round_3, last_round_4, last_round_5, last_round_6, pre);  
  
  signal state, next_state: state_type ;  
  signal block_in_s :  std_logic_vector(127 downto 0);
  signal sub_key_s :  std_logic_vector(127 downto 0);
  signal load_s :  std_logic;
  signal enc_s :  std_logic;
  signal last_s, rst_cnt :  std_logic;
  signal block_out_s :  std_logic_vector(127 downto 0);
  signal count: natural range 0 to 10;
  signal en_cnt : std_logic;

  signal key_addr_1, key_addr_2 : std_logic_vector(3 downto 0);
  signal key_data_1, key_data_delay_1, key_data_2, key_data_delay_2 : std_logic_vector(127 downto 0);

begin

  process1: process (clk,rst)  
  begin  
    if (rst ='1') then  
      state <= idle;  
    elsif rising_edge(clk) then  
      state <= next_state;  
    end if;  
  end process process1; 
 
  process2 : process (state, enc, block_in, key, block_out_s)
    variable block_reg_v : std_logic_vector(127 downto 0);
  begin  
    next_state <= state;
    
    block_reg_v := (others => '0');
    block_in_s <= (others => '0');

   sub_key_s <= (others => '0');
   
   enc_s <= '0';
   load_s <= '0';
   last_s <= '0';
   block_ready <= '0';
       		      
    case state is  
          when idle => 
            if enc ='1' then  
              next_state <= pre;  
            else
              next_state <= idle; 
            end if; 
          when pre =>
            rst_cnt <= '0';
            
            for i in 0 to 127 loop
              block_reg_v(i) := block_in(i) xor key(i);
            end loop;  
            
            load_s <= '1';            
            enc_s <= '0';
            
            sub_key_s <= key_data_1;
            block_in_s <= block_reg_v;

            next_state <= n_round_1;
          when n_round_1 => 
            enc_s <= '1';
            load_s <= '0';
            
            next_state <= n_round_2;
            
          when n_round_2 =>
            enc_s <= '1';
            load_s <= '0';
            
            next_state <= n_round_3;
          when n_round_3 =>
            enc_s <= '1';
            load_s <= '0';

            next_state <= n_round_4;
          when n_round_4 =>

            enc_s <= '1';
            load_s <= '0';
            
            next_state <= n_round_5; 
          when n_round_5 =>
            enc_s <= '1';
            load_s <= '0';
              
            next_state <= n_round_6;
          when n_round_6 =>
            enc_s <= '1';
            load_s <= '1';
            
            sub_key_s <=  key_data_1;
            block_in_s <= block_out_s;
            
            if count = 9 then
              next_state <= last_round_1;
            else            
              next_state <= n_round_1;
            end if;                         
          when last_round_1 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';
            
            next_state <= last_round_2;
          when last_round_2 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';

            next_state <= last_round_3;
          when last_round_3 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';

            next_state <= last_round_4;
          when last_round_4 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';

            next_state <= last_round_5;
          when last_round_5 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';
            
            rst_cnt <= '1';
            next_state <= last_round_6;
          when last_round_6 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';
            
            block_ready <= '1';
            
            rst_cnt <= '0';
            next_state <= idle;
    end case;  
          
  end process process2; 

  mod_10_cnt : process(clk, rst_cnt)
  begin
    if rising_edge(clk) then
      if (rst_cnt = '1') then
        count <= 0;
      elsif(en_cnt = '1' and state = n_round_1) then
        if (count = 9) then
          count <= 0;
        else
          count <= count + 1;
        end if;
      end if;
     end if; 
  end process mod_10_cnt;

  en_cnt <= '1';
  
  AES_ROUND_N : entity work.aes_enc(Behavioral) port map (clk, 
                                                          rst, 
                                                          block_in_s, 
                                                          sub_key_s, 
                                                          load_s, 
                                                          enc_s, 
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
 


  key_addr_1 <= std_logic_vector(to_unsigned(count, key_addr_1'length));
  key_addr_2 <= std_logic_vector(to_unsigned(count, key_addr_2'length));

 block_out <= block_out_s;
  
end Behavioral;

