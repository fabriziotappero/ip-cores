

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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sha_256 is
        port(clk  : in std_logic;
             rst : in std_logic;
				 gen_hash : in std_logic;
				 
				 msg_0 : in std_logic_vector(31 downto 0);
				 msg_1 : in std_logic_vector(31 downto 0);
				 msg_2 : in std_logic_vector(31 downto 0);  
				 msg_3 : in std_logic_vector(31 downto 0);
				 msg_4 : in std_logic_vector(31 downto 0);
			    msg_5 : in std_logic_vector(31 downto 0);
			    msg_6 : in std_logic_vector(31 downto 0);
				 msg_7 : in std_logic_vector(31 downto 0);
				 msg_8 : in std_logic_vector(31 downto 0);
				 msg_9 : in std_logic_vector(31 downto 0);
		       msg_10 : in std_logic_vector(31 downto 0);
		       msg_11 : in std_logic_vector(31 downto 0);
		       msg_12 : in std_logic_vector(31 downto 0);
		       msg_13 : in std_logic_vector(31 downto 0);
		       msg_14 : in std_logic_vector(31 downto 0);
		       msg_15 : in std_logic_vector(31 downto 0);

				 a_out : out std_logic_vector(31 downto 0);
				 b_out : out std_logic_vector(31 downto 0);
				 c_out : out std_logic_vector(31 downto 0);
				 d_out : out std_logic_vector(31 downto 0);
				 e_out : out std_logic_vector(31 downto 0);
				 f_out : out std_logic_vector(31 downto 0);
				 g_out : out std_logic_vector(31 downto 0);
				 h_out : out std_logic_vector(31 downto 0);
				 block_ready : out std_logic;
				 hash : out std_logic_vector(255 downto 0));				 	 
end sha_256;

architecture Behavioral of sha_256 is

	component msg_comp is
        port(clk  : in std_logic;
             rst : in std_logic;
				 
				 h_0 : in std_logic_vector(31 downto 0);
				 h_1 : in std_logic_vector(31 downto 0);
				 h_2 : in std_logic_vector(31 downto 0);  
				 h_3 : in std_logic_vector(31 downto 0);
				 h_4 : in std_logic_vector(31 downto 0);
			    h_5 : in std_logic_vector(31 downto 0);
			    h_6 : in std_logic_vector(31 downto 0);
				 h_7 : in std_logic_vector(31 downto 0);
				 	 	 
			    w_i : in std_logic_vector(31 downto 0);
				 k_i : in std_logic_vector(31 downto 0);
				 
				 a : out std_logic_vector(31 downto 0);
				 b : out std_logic_vector(31 downto 0);
				 c : out std_logic_vector(31 downto 0);
				 d : out std_logic_vector(31 downto 0);
				 e : out std_logic_vector(31 downto 0);
				 f : out std_logic_vector(31 downto 0);
				 g : out std_logic_vector(31 downto 0);
				 h : out std_logic_vector(31 downto 0));
	end component;

	component sh_reg is
        port(clk  : in std_logic;
             rst : in std_logic;
				 
				 msg_0 : in std_logic_vector(31 downto 0);
				 msg_1 : in std_logic_vector(31 downto 0);
				 msg_2 : in std_logic_vector(31 downto 0);  
				 msg_3 : in std_logic_vector(31 downto 0);
				 msg_4 : in std_logic_vector(31 downto 0);
			    msg_5 : in std_logic_vector(31 downto 0);
			    msg_6 : in std_logic_vector(31 downto 0);
				 msg_7 : in std_logic_vector(31 downto 0);
				 msg_8 : in std_logic_vector(31 downto 0);
				 msg_9 : in std_logic_vector(31 downto 0);
		       msg_10 : in std_logic_vector(31 downto 0);
		       msg_11 : in std_logic_vector(31 downto 0);
		       msg_12 : in std_logic_vector(31 downto 0);
		       msg_13 : in std_logic_vector(31 downto 0);
		       msg_14 : in std_logic_vector(31 downto 0);
		       msg_15 : in std_logic_vector(31 downto 0);   
				 	 
				 w_j : out std_logic_vector(31 downto 0));
	end component;

  component dual_mem is
  generic (ADDR_LENGTH : integer := 6;
           DATA_LENGTH : integer := 32;
           N_ADDR      : integer := 64);
  port (clk  : in std_logic;  
        we   : in std_logic;  
        a    : in std_logic_vector(ADDR_LENGTH - 1 downto 0);
        dpra : in std_logic_vector(ADDR_LENGTH - 1 downto 0);
        di   : in std_logic_vector(DATA_LENGTH - 1 downto 0);
        spo  : out std_logic_vector(DATA_LENGTH - 1 downto 0);
        dpo  : out std_logic_vector(DATA_LENGTH - 1 downto 0));
	end component;  

	signal w_j_tmp : std_logic_vector(31 downto 0);

	signal h_0_tmp : std_logic_vector(31 downto 0);
	signal h_1_tmp : std_logic_vector(31 downto 0);
	signal h_2_tmp : std_logic_vector(31 downto 0);  
	signal h_3_tmp : std_logic_vector(31 downto 0);
	signal h_4_tmp : std_logic_vector(31 downto 0);
	signal h_5_tmp : std_logic_vector(31 downto 0);
	signal h_6_tmp : std_logic_vector(31 downto 0);
	signal h_7_tmp : std_logic_vector(31 downto 0);

	signal k_i_tmp : std_logic_vector(31 downto 0);
	
	signal start_cnt_tmp, rst_sch_tmp, rst_comp_tmp : std_logic;
	signal cnt_s : std_logic_vector(5 downto 0);
	
	signal m_tmp : std_logic_vector(31 downto 0);
  
   type state_type is (idle, init, run, m_1, m_2, m_3, m_4, m_5, m_6, m_7,
	m_8, m_9, m_10, m_11, m_12, m_13, m_14, m_15, w_s);
   signal state, next_state: state_type ;
	
  type delay_buffer_t is array(67 downto 0) of
   std_logic;
	
  signal hash_delay : delay_buffer_t;

  signal a_out_tmp : std_logic_vector(31 downto 0);
  signal b_out_tmp : std_logic_vector(31 downto 0);
  signal c_out_tmp : std_logic_vector(31 downto 0);
  signal d_out_tmp : std_logic_vector(31 downto 0);
  signal e_out_tmp : std_logic_vector(31 downto 0);
  signal f_out_tmp : std_logic_vector(31 downto 0);
  signal g_out_tmp : std_logic_vector(31 downto 0);
  signal h_out_tmp : std_logic_vector(31 downto 0);
	
  signal gen_hash_tmp : std_logic;
  signal rst_cnt_s : std_logic;	
	
begin

  process1: process (clk, rst)
  begin  
    if (rst ='1') then
      state <= idle;  
    elsif rising_edge(clk) then
      state <= next_state;     
    end if;  
  end process process1;

  process2 : process (state, gen_hash, m_tmp, msg_0, msg_1, w_j_tmp, hash_delay(66))
  begin  
    next_state <= state;

	 rst_sch_tmp <= '0'; 
	 rst_comp_tmp <= '0';
	 rst_cnt_s <= '0';
	 
	 start_cnt_tmp <= '0';
	 m_tmp <= (others => '0');
	 
	 gen_hash_tmp <= '0';
	 
	 case state is 
		when idle =>
			if gen_hash = '1' then
				gen_hash_tmp <= '1';
				rst_cnt_s <= '1';
				next_state <= init;
			else
				next_state <= idle;
			end if;	
		when init =>
			rst_comp_tmp <= '1';
			start_cnt_tmp <= '1';
			
			next_state <= run;
		when run =>
			rst_comp_tmp <= '0';
			start_cnt_tmp <= '1';
			m_tmp <= msg_15;
			
			next_state <= m_1;
		when m_1 =>
			m_tmp <= msg_14;
			start_cnt_tmp <= '1';
			next_state <= m_2;
		when m_2 =>
			m_tmp <= msg_13;
			start_cnt_tmp <= '1';
			next_state <= m_3;
		when m_3 =>
			m_tmp <= msg_12;
			start_cnt_tmp <= '1';
			next_state <= m_4;
		when m_4 =>
			m_tmp <= msg_11;
			start_cnt_tmp <= '1';
			next_state <= m_5;			
		when m_5 =>
			m_tmp <= msg_10;
			start_cnt_tmp <= '1';
			next_state <= m_6;
		when m_6 =>
			m_tmp <= msg_9;
			start_cnt_tmp <= '1';
			next_state <= m_7;
		when m_7 =>
			m_tmp <= msg_8;
			start_cnt_tmp <= '1';
			next_state <= m_8;			
		when m_8 =>
			m_tmp <= msg_7;
			start_cnt_tmp <= '1';
			next_state <= m_9;
		when m_9 =>
			m_tmp <= msg_6;
			start_cnt_tmp <= '1';
			next_state <= m_10;			
		when m_10 =>
			m_tmp <= msg_5;
			start_cnt_tmp <= '1';
			next_state <= m_11;
		when m_11 =>
			m_tmp <= msg_4;
			start_cnt_tmp <= '1';
			next_state <= m_12;
		when m_12 =>
			m_tmp <= msg_3;
			start_cnt_tmp <= '1';
			next_state <= m_13;						
		when m_13 =>
			m_tmp <= msg_2;
			start_cnt_tmp <= '1';
			
			next_state <= m_14;
		when m_14 =>
			m_tmp <= msg_1;
			start_cnt_tmp <= '1';
			next_state <= m_15;
		when m_15 =>
			m_tmp <= msg_0;
			start_cnt_tmp <= '1';
			rst_sch_tmp <= '1'; 						
			next_state <= w_s;
		when w_s =>
			m_tmp <= w_j_tmp;
			start_cnt_tmp <= '1';
			
			if hash_delay(66) = '1' then
				next_state <= idle;
			else
				next_state <= w_s;
			end if;	
	 end case;

 end process;

	message_schedule: sh_reg port map (clk, 
												  rst_sch_tmp,
												  msg_0,
												  msg_1,
												  msg_2,
												  msg_3,
												  msg_4,
												  msg_5,
												  msg_6,
												  msg_7,
												  msg_8,
												  msg_9,
												  msg_10,
												  msg_11,
												  msg_12,
												  msg_13,
												  msg_14,
												  msg_15,
												  w_j_tmp);
	
	
	message_compression: msg_comp port map (clk, 
														 rst_comp_tmp,												 
													    h_0_tmp,
														 h_1_tmp,
														 h_2_tmp,
														 h_3_tmp, 
														 h_4_tmp, 
														 h_5_tmp, 
														 h_6_tmp, 
														 h_7_tmp,
														 m_tmp,
														 k_i_tmp,
														 a_out_tmp,
														 b_out_tmp, 
														 c_out_tmp,
														 d_out_tmp,
														 e_out_tmp,
														 f_out_tmp,
														 g_out_tmp,
														 h_out_tmp);

	a_out <= a_out_tmp;
	b_out <= b_out_tmp;
	c_out <= c_out_tmp;
	d_out <= d_out_tmp;
	e_out <= e_out_tmp;
	f_out <= f_out_tmp;
	g_out <= g_out_tmp;
	h_out <= h_out_tmp;
														 	
	k_mem: dual_mem port map(clk, 
									 '0',
									 cnt_s, --cnt_s,
									 (others => '0'),
									 (others => '0'),
									 k_i_tmp,
									 open);

        cnt_k_pr: process(clk, rst_cnt_s, start_cnt_tmp)  
                variable cnt_v : unsigned(5 downto 0) := (others => '0');
        begin
                if rising_edge(clk) then  
                        if rst_cnt_s = '1' then 
                                cnt_v := (others => '0');
                        elsif
                                start_cnt_tmp = '1' then
                                        cnt_v := cnt_v + 1;
                        end if;
                end if;
                
                cnt_s <= std_logic_vector(cnt_v);
        end process;
		  			
			hash_delay(0) <= gen_hash_tmp;

			delay_chain: for i in 1 to 66 generate
				delay_ff_proc: process(clk)
				begin
					if rising_edge(clk) then
						hash_delay(i) <= hash_delay(i-1);
					end if;
				end process delay_ff_proc;
			end generate delay_chain;

			block_ready <= hash_delay(66);
		  		  
			final_block: process(clk, rst, gen_hash, hash_delay(65),
										a_out_tmp,
										b_out_tmp,
										c_out_tmp,
										d_out_tmp,
										e_out_tmp,
										f_out_tmp,
										g_out_tmp,
										h_out_tmp)
				variable h_0_tmp_v : std_logic_vector(31 downto 0) := (others => '0');
				variable h_1_tmp_v : std_logic_vector(31 downto 0) := (others => '0');
				variable h_2_tmp_v : std_logic_vector(31 downto 0) := (others => '0');
				variable h_3_tmp_v : std_logic_vector(31 downto 0) := (others => '0');
				variable h_4_tmp_v : std_logic_vector(31 downto 0) := (others => '0');
				variable h_5_tmp_v : std_logic_vector(31 downto 0) := (others => '0');
				variable h_6_tmp_v : std_logic_vector(31 downto 0) := (others => '0');
				variable h_7_tmp_v : std_logic_vector(31 downto 0) := (others => '0');
			begin
				if rising_edge(clk) then
					if rst = '1' then				 
						h_0_tmp_v := X"6a09e667"; 
						h_1_tmp_v := X"bb67ae85"; 
						h_2_tmp_v := X"3c6ef372"; 
						h_3_tmp_v := X"a54ff53a"; 
						h_4_tmp_v := X"510e527f"; 
						h_5_tmp_v := X"9b05688c"; 
						h_6_tmp_v := X"1f83d9ab"; 
						h_7_tmp_v := X"5be0cd19";
					elsif hash_delay(65) = '1' then
						h_0_tmp_v := std_logic_vector(unsigned(h_0_tmp_v) + unsigned(a_out_tmp));
						h_1_tmp_v := std_logic_vector(unsigned(h_1_tmp_v) + unsigned(b_out_tmp));
						h_2_tmp_v := std_logic_vector(unsigned(h_2_tmp_v) + unsigned(c_out_tmp));
						h_3_tmp_v := std_logic_vector(unsigned(h_3_tmp_v) + unsigned(d_out_tmp));
						h_4_tmp_v := std_logic_vector(unsigned(h_4_tmp_v) + unsigned(e_out_tmp));
						h_5_tmp_v := std_logic_vector(unsigned(h_5_tmp_v) + unsigned(f_out_tmp));
						h_6_tmp_v := std_logic_vector(unsigned(h_6_tmp_v) + unsigned(g_out_tmp));
						h_7_tmp_v := std_logic_vector(unsigned(h_7_tmp_v) + unsigned(h_out_tmp));					
					end if;
				end if;	
				
				h_0_tmp <= h_0_tmp_v; 
				h_1_tmp <= h_1_tmp_v;
				h_2_tmp <= h_2_tmp_v;
				h_3_tmp <= h_3_tmp_v;
				h_4_tmp <= h_4_tmp_v;
				h_5_tmp <= h_5_tmp_v;
				h_6_tmp <= h_6_tmp_v;
				h_7_tmp <= h_7_tmp_v;
						
			end process;
				  
			hash <= h_0_tmp & h_1_tmp &
					  h_2_tmp & h_3_tmp &
					  h_4_tmp & h_5_tmp &
					  h_6_tmp & h_7_tmp;
end Behavioral;

