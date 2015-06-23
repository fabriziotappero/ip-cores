---------------------------------------------------------------------
----                                                             ----
----  FPU                                                        ----
----  Floating Point Unit (Double precision)                     ----
----                                                             ----
----  Author: David Lundgren                                     ----
----          davidklun@gmail.com                                ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2009 David Lundgren                           ----
----                  davidklun@gmail.com                        ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
----     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ----
---- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ----
---- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ----
---- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ----
---- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ----
---- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ----
---- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ----
---- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ----
---- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ----
---- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ----
---- POSSIBILITY OF SUCH DAMAGE.                                 ----
----                                                             ----
---------------------------------------------------------------------

	LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	USE ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;
	use ieee.std_logic_misc.all; 
	use IEEE.numeric_std.all;
	library work;
	use work.fpupack.all;
	
	ENTITY fpu_div IS

   PORT( 
      clk, rst, enable : IN     std_logic;
      opa, opb : IN     std_logic_vector (63 DOWNTO 0);
      sign : OUT    std_logic;
      mantissa_7 : OUT    std_logic_vector (55 DOWNTO 0);
      exponent_out : OUT    std_logic_vector (11 DOWNTO 0)
   );

	END fpu_div;
	
	architecture rtl of fpu_div is

	signal dividend_signal : std_logic_vector(53 downto 0);
	signal divisor_signal : std_logic_vector(53 downto 0);
	signal enable_signal : std_logic;
	signal enable_signal_2 : std_logic;
	signal enable_signal_a : std_logic;
	signal enable_signal_b : std_logic;
	signal enable_signal_c : std_logic;
	signal enable_signal_d : std_logic;
	signal enable_signal_e : std_logic;
	signal dividend_shift : std_logic_vector(5 downto 0);
	signal dividend_shift_2 : std_logic_vector(5 downto 0);
	signal divisor_shift : std_logic_vector(5 downto 0);
	signal divisor_shift_2 : std_logic_vector(5 downto 0);
	signal count_out : std_logic_vector(5 downto 0);
	signal mantissa_a : std_logic_vector(51 downto 0);
	signal mantissa_b : std_logic_vector(51 downto 0);
	signal expon_a : std_logic_vector(10 downto 0);
	signal expon_b : std_logic_vector(10 downto 0);
	signal a_is_norm : std_logic;
	signal b_is_norm : std_logic;
	signal a_is_zero : std_logic;
	signal exponent_a : std_logic_vector(11 downto 0);
	signal exponent_b : std_logic_vector(11 downto 0);
	signal dividend_a : std_logic_vector(51 downto 0);
	signal dividend_a_shifted : std_logic_vector(51 downto 0);
	signal dividend_denorm : std_logic_vector(52 downto 0);
	signal dividend_1 : std_logic_vector(53 downto 0);
	signal divisor_b : std_logic_vector(51 downto 0);
	signal divisor_b_shifted : std_logic_vector(51 downto 0);
	signal divisor_denorm : std_logic_vector(52 downto 0);
	signal divisor_1 : std_logic_vector(53 downto 0);
	signal count_index : std_logic_vector(5 downto 0);
	signal count_nonzero : std_logic;
	signal quotient : std_logic_vector(53 downto 0);
	signal quotient_out : std_logic_vector(53 downto 0);
	signal remainder : std_logic_vector(53 downto 0);
	signal remainder_out : std_logic_vector(53 downto 0);
	signal remainder_msb : std_logic;
	signal count_nonzero_signal : std_logic;
	signal count_nonzero_signal_2 : std_logic;
	signal expon_term : std_logic_vector(11 downto 0);
	signal expon_uf_1 : std_logic;
	signal expon_uf_term_1 : std_logic_vector(11 downto 0);
	signal expon_final_1 : std_logic_vector(11 downto 0);
	signal expon_final_2 : std_logic_vector(11 downto 0);
	signal expon_shift_a : std_logic_vector(11 downto 0);
	signal expon_shift_b : std_logic_vector(11 downto 0);
	signal expon_uf_2 : std_logic;
	signal expon_uf_term_2 : std_logic_vector(11 downto 0);
	signal expon_uf_term_3 : std_logic_vector(11 downto 0);
	signal expon_uf_gt_maxshift : std_logic;
	signal expon_uf_term_4 : std_logic_vector(11 downto 0);
	signal expon_final_3 : std_logic_vector(11 downto 0);
	signal expon_final_4 : std_logic_vector(11 downto 0);
	signal quotient_msb : std_logic; 
	signal expon_final_4_et0 : std_logic;
	signal expon_final_4_term : std_logic;
	signal expon_final_5 : std_logic_vector(11 downto 0);
	signal mantissa_1 : std_logic_vector(51 downto 0);
	signal mantissa_2 : std_logic_vector(51 downto 0);
	signal mantissa_3 : std_logic_vector(51 downto 0);
	signal mantissa_4 : std_logic_vector(51 downto 0);
	signal mantissa_5 : std_logic_vector(51 downto 0);
	signal mantissa_6 : std_logic_vector(51 downto 0);
	signal remainder_a : std_logic_vector(107 downto 0);
	signal remainder_shift_term : std_logic_vector(11 downto 0);
	signal remainder_b : std_logic_vector(107 downto 0);
	signal remainder_1 : std_logic_vector(55 downto 0);
	signal remainder_2 : std_logic_vector(55 downto 0);
	signal remainder_3 : std_logic_vector(55 downto 0);
	signal remainder_4 : std_logic_vector(55 downto 0);
	signal remainder_5 : std_logic_vector(55 downto 0);
	signal remainder_6 : std_logic_vector(55 downto 0);
	signal m_norm : std_logic;
	signal rem_lsb : std_logic;	
	
	begin
		sign  <= opa(63) xor opb(63);
		expon_a  <= opa(62 downto 52);
		expon_b  <= opb(62 downto 52);
		a_is_norm  <= or_reduce(expon_a);
		b_is_norm  <= or_reduce(expon_b);
		a_is_zero  <= not or_reduce(opa(62 downto 0)); 
		exponent_a  <=  '0' & expon_a;
		exponent_b  <=  '0' & expon_b;
		dividend_denorm <= dividend_a_shifted & '0';
		dividend_1  <= "01" & dividend_a when a_is_norm = '1' else '0' & dividend_denorm;
		divisor_denorm  <= divisor_b_shifted & '0';
		divisor_1  <= "01" & divisor_b when b_is_norm = '1' else '0' & divisor_denorm;
		count_nonzero  <= '0' when count_index = "000000" else '1';	  
		count_index <= count_out;
		quotient_msb  <= quotient_out(53);
		mantissa_2  <= quotient_out(52 downto 1);
		mantissa_3  <= quotient_out(51 downto 0);
		mantissa_4  <= mantissa_2 when quotient_msb = '1' else  mantissa_3;
		mantissa_5  <= mantissa_2 when expon_final_4 = "000000000001" else  mantissa_4;
        mantissa_6  <= mantissa_1 when expon_final_4_et0 = '1' else mantissa_5;
		remainder_a  <=  quotient_out(53 downto 0) & remainder_msb & remainder_out(52 downto 0);
		remainder_1  <= remainder_b(107 downto 53) & or_reduce(remainder_b(52 downto 0));
		remainder_2  <= quotient_out(0) & remainder_msb & remainder_out(52 downto 0) & '0' ;
		remainder_3  <=  remainder_msb & remainder_out(52 downto 0) & "00" ;
		remainder_4  <=  remainder_2 when quotient_msb = '1' else remainder_3;
		remainder_5  <=  remainder_2 when expon_final_4 = "000000000001" else remainder_4;
		remainder_6  <= remainder_1 when expon_final_4_et0 = '1' else remainder_5;
		m_norm  <= or_reduce(expon_final_5);
		rem_lsb <= or_reduce(remainder_6(54 downto 0));	
		mantissa_7  <=  '0' & m_norm & mantissa_6 & remainder_6(55) & rem_lsb ;	
	
process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			exponent_out <= (others =>'0');
		else 
			if (a_is_zero = '1') then
				exponent_out <= "000000000000";
			else
				exponent_out <= expon_final_5;
			end if;
		end if;
	end process;
	
process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			count_out <= (others =>'0');
		elsif (enable_signal = '1') then
			count_out <= "110101"; -- 53
		elsif (count_nonzero = '1') then
			count_out <= count_out - "000001"; 
		end if;
	end process;
	
process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			quotient_out <= (others =>'0');
			remainder_out <= (others =>'0');
		else 
			quotient_out <= quotient;
			remainder_out <= remainder;
		end if;
	end process;
	

process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			quotient <= (others =>'0');
		elsif (count_nonzero_signal = '1') then
			if (divisor_signal > dividend_signal) then
				quotient(conv_integer(count_index)) <= '0';
			else
				quotient(conv_integer(count_index)) <= '1';
			end if; 
		end if;
	end process;

process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			remainder <= (others =>'0');
			remainder_msb <= '0';
		elsif ((not count_nonzero_signal and count_nonzero_signal_2) = '1') then	  
		    remainder <= dividend_signal;
		    if (divisor_signal > dividend_signal) then
		    	remainder_msb <= '0';
		    else
		    	remainder_msb <= '1';
		    end if;
		end if;
	end process;

process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			dividend_signal <= (others =>'0');
			divisor_signal <= (others =>'0');
		elsif (enable_signal_e = '1') then
			dividend_signal <= dividend_1;
			divisor_signal <= divisor_1;
		elsif (count_nonzero_signal = '1') then
			if (divisor_signal > dividend_signal) then
				dividend_signal <= shl(dividend_signal, conv_std_logic_vector('1', 54));
			else
				dividend_signal <= shl(dividend_signal - divisor_signal, conv_std_logic_vector('1', 54));
			end if;
		end if;
	end process;

process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			expon_term  <= (others =>'0');
 			expon_uf_1 <= '0';
        	expon_uf_term_1 <= (others =>'0');
        	expon_final_1 <= (others =>'0');
        	expon_final_2 <= (others =>'0');
        	expon_shift_a <= (others =>'0');
        	expon_shift_b <= (others =>'0');
 			expon_uf_2 <= '0';
        	expon_uf_term_2 <= (others =>'0');
        	expon_uf_term_3 <= (others =>'0');
 			expon_uf_gt_maxshift <= '0';
        	expon_uf_term_4 <= (others =>'0');
        	expon_final_3 <= (others =>'0');
        	expon_final_4 <= (others =>'0');
 			expon_final_4_et0 <= '0';
 			expon_final_4_term <= '0';
        	expon_final_5 <= (others =>'0');
        	mantissa_a <= (others =>'0');
			mantissa_b <= (others =>'0');
			dividend_a <= (others =>'0');
			divisor_b <= (others =>'0');
			dividend_shift <= (others =>'0');
			divisor_shift <= (others =>'0');
			dividend_shift_2 <= (others =>'0');
			divisor_shift_2 <= (others =>'0');
			remainder_shift_term <= (others =>'0');
			remainder_b <= (others =>'0');
			dividend_a_shifted <= (others =>'0');
			divisor_b_shifted <=  (others =>'0');
			mantissa_1 <= (others =>'0');
		elsif (enable_signal_2 = '1') then
			expon_term  <= exponent_a + "001111111111"; -- 1023
			if (exponent_b > expon_term) then
				expon_uf_1 <= '1';
			else
				expon_uf_1 <= '0';
			end if;
			if (expon_uf_1 = '1') then
				expon_uf_term_1 <= exponent_b - expon_term;
				expon_final_2 <= (others =>'0');
			else
				expon_uf_term_1 <= (others =>'0');
				expon_final_2 <= expon_final_1;
			end if;
        	expon_final_1 <= expon_term - exponent_b;
        	if (expon_uf_1 = '1') then
				expon_uf_term_1 <= exponent_b - expon_term;
			else
				expon_uf_term_1 <= (others =>'0');
			end if;
 			if (a_is_norm = '1') then
				expon_shift_a <= (others =>'0');
			else
				expon_shift_a <= "000000" & dividend_shift_2;
			end if;
        	if (b_is_norm = '1') then
				expon_shift_b <= (others =>'0');
			else
				expon_shift_b <= "000000" & divisor_shift_2;
			end if;
 			if (expon_shift_a > expon_final_2) then
				expon_uf_2 <= '1';
			else
				expon_uf_2 <= '0';
			end if;
			if (expon_uf_2 = '1') then
				expon_uf_term_2 <= expon_shift_a - expon_final_2;
			else
				expon_uf_term_2 <= (others =>'0');
			end if;
        	expon_uf_term_3 <= expon_uf_term_2 + expon_uf_term_1;
        	if (expon_uf_term_3 > "000000110011") then -- 51
				expon_uf_gt_maxshift <= '1';
			else
				expon_uf_gt_maxshift <= '0';
			end if;
 			if (expon_uf_gt_maxshift = '1') then
				expon_uf_term_4 <= "000000110100"; --52
			else
				expon_uf_term_4 <= expon_uf_term_3;
			end if;
			if (expon_uf_2 = '1') then
				expon_final_3 <= (others =>'0');
			else
				expon_final_3 <= expon_final_2 - expon_shift_a;
			end if;
        	expon_final_4 <= expon_final_3 + expon_shift_b;
        	if (expon_final_4 = "000000000000") then 
				expon_final_4_et0 <= '1';
			else
				expon_final_4_et0 <= '0';
			end if;
 			if (expon_final_4_et0 = '1') then 
				expon_final_4_term <= '0';
			else
				expon_final_4_term <= '1';
 			end if;
 			if (quotient_msb = '1') then
				expon_final_5 <= expon_final_4;
			else
				expon_final_5 <= expon_final_4 - expon_final_4_term;
			end if;
			mantissa_a <= opa(51 downto 0);
			mantissa_b <= opb(51 downto 0);
			dividend_a <= mantissa_a;
			divisor_b <= mantissa_b;
			dividend_shift <= count_l_zeros(dividend_a);
			divisor_shift <= count_l_zeros(divisor_b);
			dividend_shift_2 <= dividend_shift;
			divisor_shift_2 <= divisor_shift;
			remainder_shift_term <= "000000110100" - expon_uf_term_4; -- 52
			remainder_b <= shl(remainder_a, remainder_shift_term);
			dividend_a_shifted <= shl(dividend_a, dividend_shift_2);
			divisor_b_shifted <= shl(divisor_b, divisor_shift_2);
			mantissa_1 <= shr(quotient_out(53 downto 2), expon_uf_term_4);
		end if;
	end process;

process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			count_nonzero_signal <= '0';	
			count_nonzero_signal_2 <= '0';
			enable_signal <= '0';
			enable_signal_a <= '0';
			enable_signal_b <= '0';
			enable_signal_c <= '0';
			enable_signal_d <= '0';
			enable_signal_e <= '0';
		else 
			count_nonzero_signal <= count_nonzero;	 
			count_nonzero_signal_2 <= count_nonzero_signal;
			enable_signal <= enable_signal_e;
			enable_signal_a <= enable;
			enable_signal_b <= enable_signal_a;
			enable_signal_c <= enable_signal_b;
			enable_signal_d <= enable_signal_c;
			enable_signal_e <= enable_signal_d;
		end if;
	end process;

process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			enable_signal_2 <= '0';
		elsif (enable = '1') then
			enable_signal_2 <= '1';
		end if;
	end process;

	end rtl;