---------------------------------------------------------------------
----                                                             ----
----                                                         ----
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
----     THIS SOFTWARE IS PROVIDED `AS IS' AND WITHOUT ANY     ----
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
	
	ENTITY fpu_exceptions IS

   PORT( 
      clk, rst, enable : IN     std_logic;
      rmode : IN     std_logic_vector (1 DOWNTO 0);
      opa, opb, in_except : IN     std_logic_vector (63 DOWNTO 0);
      exponent_in : IN     std_logic_vector (11 DOWNTO 0);
      mantissa_in : IN     std_logic_vector (1 DOWNTO 0);
      fpu_op : IN     std_logic_vector (2 DOWNTO 0);
      out_fp : OUT    std_logic_vector (63 DOWNTO 0);
      ex_enable, underflow, overflow, inexact : OUT    std_logic;
      exception, invalid : OUT    std_logic
   );

	END fpu_exceptions;
	
	architecture rtl of fpu_exceptions is
	
	signal	in_et_zero : std_logic;
	signal	opa_et_zero : std_logic;
	signal	opb_et_zero : std_logic;
	signal	add : std_logic;
	signal	subtract : std_logic;
	signal	multiply : std_logic;
	signal	divide : std_logic;
	signal	opa_QNaN : std_logic;
	signal	opb_QNaN : std_logic;
	signal	opa_SNaN : std_logic;
	signal	opb_SNaN : std_logic;
	signal	opa_pos_inf : std_logic;
	signal	opb_pos_inf : std_logic;
	signal	opa_neg_inf : std_logic;
	signal	opb_neg_inf : std_logic;
	signal	opa_inf : std_logic;
	signal	opb_inf : std_logic;
	signal	NaN_input : std_logic;
	signal	SNaN_input : std_logic;
	signal	a_NaN : std_logic;
	signal	div_by_0 : std_logic;
	signal	div_0_by_0 : std_logic;
	signal	div_inf_by_inf : std_logic;
	signal	div_by_inf : std_logic;
	signal	mul_0_by_inf : std_logic;
	signal	mul_inf : std_logic;
	signal	div_inf : std_logic;
	signal	add_inf : std_logic;
	signal	sub_inf : std_logic;
	signal	addsub_inf_invalid : std_logic;
	signal	addsub_inf : std_logic;
	signal	out_inf_trigger : std_logic;
	signal	out_pos_inf : std_logic;
	signal	out_neg_inf : std_logic;
	signal	round_nearest : std_logic;
	signal	round_to_zero : std_logic;
	signal	round_to_pos_inf : std_logic;
	signal	round_to_neg_inf : std_logic;
	signal	inf_round_down_trigger : std_logic;
	signal	mul_uf : std_logic;
	signal	div_uf : std_logic;								
	signal	underflow_trigger : std_logic;			
	signal	invalid_trigger : std_logic;
	signal	overflow_trigger : std_logic;
	signal	inexact_trigger : std_logic;
	signal	except_trigger : std_logic;
	signal	enable_trigger : std_logic;
	signal	NaN_out_trigger : std_logic;
	signal	SNaN_trigger : std_logic;
	
	
	signal	exp_2047 : std_logic_vector(10 downto 0); 
	signal	exp_2046 : std_logic_vector(10 downto 0); 
	signal	NaN_output_0 : std_logic_vector(62 downto 0); 
	signal	NaN_output : std_logic_vector(62 downto 0); 
	signal	mantissa_max : std_logic_vector(51 downto 0);
	signal	inf_round_down : std_logic_vector(62 downto 0);
	signal	out_inf : std_logic_vector(62 downto 0);
	signal	out_0 : std_logic_vector(63 downto 0);
	signal	out_1 : std_logic_vector(63 downto 0);
	signal	out_2 : std_logic_vector(63 downto 0);
	
	begin
	
		exp_2047 <= "11111111111";
		exp_2046 <= "11111111110";
		mantissa_max <= "1111111111111111111111111111111111111111111111111111";
	
	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			in_et_zero <=    '0';
			opa_et_zero <=   '0';
			opb_et_zero <=   '0';
			add 	<= 	'0';
			subtract <= '0';
			multiply <= '0';
			divide 	<= 	'0';
			opa_QNaN <= '0';
			opb_QNaN <= '0';
			opa_SNaN <= '0';
			opb_SNaN <= '0';
			opa_pos_inf <= '0';
			opb_pos_inf <= '0';
			opa_neg_inf <= '0';
			opb_neg_inf <= '0'; 
			opa_inf <= '0';
			opb_inf <= '0';
			NaN_input <= '0'; 
			SNaN_input <= '0';
			a_NaN <= '0';
			div_by_0 <= '0';
			div_0_by_0 <= '0';
			div_inf_by_inf <= '0';
			div_by_inf <= '0';
			mul_0_by_inf <= '0';
			mul_inf <= '0';
			div_inf <= '0';
			add_inf <= '0';
			sub_inf <= '0';
			addsub_inf_invalid <= '0';
			addsub_inf <= '0';
			out_inf_trigger <= '0';
			out_pos_inf <= '0';
			out_neg_inf <= '0';
			round_nearest <= '0';
			round_to_zero <= '0';
			round_to_pos_inf <= '0';
			round_to_neg_inf <= '0';
			inf_round_down_trigger <= '0';
			mul_uf <= '0';
			div_uf <= '0';															
			underflow_trigger <= '0';		
			invalid_trigger <= '0';
			overflow_trigger <= '0';
			inexact_trigger <= '0';
			except_trigger <= '0';
			enable_trigger <= '0';
			NaN_out_trigger <= '0';
			SNaN_trigger <= '0';
			NaN_output_0 <= (others =>'0');
			NaN_output <= (others =>'0');
			inf_round_down <= (others =>'0');
			out_inf <= (others =>'0');
			out_0 <= (others =>'0');
			out_1 <= (others =>'0');
			out_2 <= (others =>'0');
		elsif (enable = '1') then
			if or_reduce(in_except(62 downto 0)) = '0' then
				in_et_zero <= '1';
			else
				in_et_zero <= '0';
			end if;
			if or_reduce(opa(62 downto 0)) = '0' then
				opa_et_zero <= '1';
			else
				opa_et_zero <= '0';
			end if;
			if or_reduce(opb(62 downto 0)) = '0' then
				opb_et_zero <= '1';
			else
				opb_et_zero <= '0';
			end if;
			if fpu_op = "000" then
				add <= '1';
			else
				add <= '0';
			end if;
			if fpu_op = "001" then
				subtract <= '1';
			else
				subtract <= '0';
			end if;
			if fpu_op = "010" then
				multiply <= '1';
			else
				multiply <= '0';
			end if;
			if fpu_op = "011" then
				divide <= '1';
			else
				divide <= '0';
			end if;
			if opa(62 downto 52) = "11111111111" and or_reduce(opa(51 downto 0)) = '1' and
					opa(51) = '1' then
				opa_QNaN <= '1';
			else
				opa_QNaN <= '0';
			end if;
			if opb(62 downto 52) = "11111111111" and or_reduce(opb(51 downto 0)) = '1' and
					opb(51) = '1' then
				opb_QNaN <= '1';
			else
				opb_QNaN <= '0';
			end if;
			if opa(62 downto 52) = "11111111111" and or_reduce(opa(51 downto 0)) = '1' and
					opa(51) = '0' then
				opa_SNaN <= '1';
			else
				opa_SNaN <= '0';
			end if;
			if opb(62 downto 52) = "11111111111" and or_reduce(opb(51 downto 0)) = '1' and
					opb(51) = '0' then
				opb_SNaN <= '1';
			else
				opb_SNaN <= '0';
			end if;
			if opa(62 downto 52) = "11111111111" and or_reduce(opa(51 downto 0)) = '0' and
					opa(63) = '0' then
				opa_pos_inf <= '1';
			else
				opa_pos_inf <= '0';
			end if;
			if opb(62 downto 52) = "11111111111" and or_reduce(opb(51 downto 0)) = '0' and
					opb(63) = '0' then
				opb_pos_inf <= '1';
			else
				opb_pos_inf <= '0';
			end if;
			if opa(62 downto 52) = "11111111111" and or_reduce(opa(51 downto 0)) = '0' and
					opa(63) = '1' then
				opa_neg_inf <= '1';
			else
				opa_neg_inf <= '0';
			end if;
			if opb(62 downto 52) = "11111111111" and or_reduce(opb(51 downto 0)) = '0' and
					opb(63) = '1' then
				opb_neg_inf <= '1';
			else
				opb_neg_inf <= '0';
			end if;
			if opa(62 downto 52) = "11111111111" and or_reduce(opa(51 downto 0)) = '0' then
				opa_inf <= '1';
			else
				opa_inf <= '0';
			end if;
			if opb(62 downto 52) = "11111111111" and or_reduce(opb(51 downto 0)) = '0' then
				opb_inf <= '1';
			else
				opb_inf <= '0';
			end if;
			if opa_QNaN = '1' or opb_QNaN = '1' or opa_SNaN = '1' or opb_SNaN = '1' then
				NaN_input <= '1';
			else
				NaN_input <= '0';
			end if;
			if opa_SNaN = '1' or opb_SNaN = '1' then
				SNaN_input <= '1';
			else
				SNaN_input <= '0';
			end if;
			if opa_SNaN = '1' or opa_QNaN = '1' then
				a_NaN <= '1';
			else
				a_NaN <= '0';
			end if;
			if divide = '1' and opb_et_zero = '1' and opa_et_zero = '0' then
				div_by_0 <= '1';
			else
				div_by_0 <= '0';
			end if;
			if divide = '1' and opb_et_zero = '1' and opa_et_zero = '1' then
				div_0_by_0 <= '1';
			else
				div_0_by_0 <= '0';
			end if;
			if divide = '1' and opa_inf = '1' and opb_inf = '1' then
				div_inf_by_inf <= '1';
			else
				div_inf_by_inf <= '0';
			end if;
			if divide = '1' and opa_inf = '0' and opb_inf = '1' then
				div_by_inf <= '1';
			else
				div_by_inf <= '0';
			end if;
			if multiply = '1' and ((opa_inf = '1' and opb_et_zero = '1') or
			 (opa_et_zero = '1' and opb_inf = '1')) then
				mul_0_by_inf <= '1';
			else
				mul_0_by_inf <= '0';
			end if;
			if multiply = '1' and (opa_inf = '1' or opb_inf = '1') and
			  mul_0_by_inf = '0' then
				mul_inf <= '1';
			else
				mul_inf <= '0';
			end if;
			if divide = '1' and opa_inf = '1' and opb_inf = '0' then
				div_inf <= '1';
			else
				div_inf <= '0';
			end if;
			if add = '1' and (opa_inf = '1' or opb_inf = '1') then
				add_inf <= '1';
			else
				add_inf <= '0';
			end if;
			if subtract = '1' and (opa_inf = '1' or opb_inf = '1') then
				sub_inf <= '1';
			else
				sub_inf <= '0';
			end if;
			if (add = '1' and opa_pos_inf = '1' and opb_neg_inf = '1') or
			  (add = '1' and opa_neg_inf = '1' and opb_pos_inf = '1') or
			  (subtract = '1' and opa_pos_inf = '1' and opb_pos_inf = '1') or
			  (subtract = '1' and opa_neg_inf = '1' and opb_neg_inf = '1') then
				addsub_inf_invalid <= '1';
			else
				addsub_inf_invalid <= '0';
			end if;
			if (add_inf = '1' or sub_inf = '1') and addsub_inf_invalid = '0' then
				addsub_inf <= '1';
			else
				addsub_inf <= '0';
			end if;
			if addsub_inf = '1' or mul_inf = '1' or div_inf = '1' or div_by_0 = '1' 
			  or (exponent_in > "011111111110") then -- 2046
				out_inf_trigger <= '1';
			else
				out_inf_trigger <= '0';	
			end if;
			if out_inf_trigger = '1' and in_except(63) = '0' then
				out_pos_inf <= '1';
			else
				out_pos_inf <= '0';	
			end if;
			if out_inf_trigger = '1' and in_except(63) = '1' then
				out_neg_inf <= '1';
			else
				out_neg_inf <= '0';	
			end if;
			if rmode = "00" then
				round_nearest <= '1';
			else
				round_nearest <= '0';
			end if;
			if rmode = "01" then
				round_to_zero <= '1';
			else
				round_to_zero <= '0';
			end if;
			if rmode = "10" then
				round_to_pos_inf <= '1';
			else
				round_to_pos_inf <= '0';
			end if;
			if rmode = "11" then
				round_to_neg_inf <= '1';
			else
				round_to_neg_inf <= '0';
			end if;
			if (out_pos_inf = '1' and round_to_neg_inf = '1') or
			   (out_neg_inf = '1' and round_to_pos_inf = '1') or
			   (out_inf_trigger = '1' and round_to_zero = '1') then
				inf_round_down_trigger <= '1';
			else
				inf_round_down_trigger <= '0';
			end if;
			if multiply = '1' and opa_et_zero = '0' and opb_et_zero = '0' and 
			  in_et_zero = '1' then
				mul_uf <= '1';
			else
				mul_uf <= '0';
			end if;
			if divide = '1' and opa_et_zero = '0' and in_et_zero = '1' then
				div_uf <= '1';
			else
				div_uf <= '0';
			end if;
			if div_by_inf = '1' or mul_uf = '1' or div_uf = '1' then
				underflow_trigger <= '1';
			else
				underflow_trigger <= '0';
			end if;
			if SNaN_input = '1' or addsub_inf_invalid = '1' or mul_0_by_inf = '1' or
				div_0_by_0 = '1' or div_inf_by_inf = '1' then
				invalid_trigger <= '1';
			else
				invalid_trigger <= '0';
			end if;																				
			if out_inf_trigger = '1' and NaN_input = '0' then
				overflow_trigger <= '1';
			else
				overflow_trigger <= '0';
			end if;	
			if (or_reduce(mantissa_in(1 downto 0)) = '1' or out_inf_trigger = '1' or 
			  underflow_trigger = '1') and NaN_input = '0' then
				inexact_trigger <= '1';
			else
				inexact_trigger <= '0';
			end if;	
			if (invalid_trigger = '1' or overflow_trigger = '1' or 
			  underflow_trigger = '1' or inexact_trigger = '1') then
				except_trigger <= '1';
			else
				except_trigger <= '0';
			end if;	
			if (except_trigger = '1' or out_inf_trigger = '1' or 
			  NaN_input = '1') then
				enable_trigger <= '1';
			else
				enable_trigger <= '0';
			end if;	
			if (NaN_input = '1' or invalid_trigger = '1') then
				NaN_out_trigger <= '1';
			else
				NaN_out_trigger <= '0';
			end if;	
			if (invalid_trigger = '1' and SNaN_input = '0') then
				SNaN_trigger <= '1';
			else
				SNaN_trigger <= '0';
			end if;	
			if a_NaN = '1' then
				NaN_output_0 <= exp_2047 & '1' & opa(50 downto 0);
			else
				NaN_output_0 <= exp_2047 & '1' & opb(50 downto 0);
			end if;	
			if SNaN_trigger = '1' then
				NaN_output <= exp_2047 & "01" & opa(49 downto 0);
			else
				NaN_output <= NaN_output_0;
			end if;	
			inf_round_down <= exp_2046 & mantissa_max;
			if inf_round_down_trigger = '1' then
				out_inf <= inf_round_down;
			else
				out_inf <=  exp_2047 & "0000000000000000000000000000000000000000000000000000";
			end if;
			if underflow_trigger = '1' then
				out_0 <= in_except(63) & "000000000000000000000000000000000000000000000000000000000000000";
			else
				out_0 <=  in_except;
			end if;
			if out_inf_trigger = '1' then
				out_1 <= in_except(63) & out_inf;
			else
				out_1 <= out_0;
			end if;
			if NaN_out_trigger = '1' then
				out_2 <= in_except(63) & NaN_output;
			else
				out_2 <= out_1;
			end if;
		end if;
	end process;


	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			ex_enable <= '0';
			underflow <= '0';
			overflow <= '0';	   
			inexact <= '0';
			exception <= '0';
			invalid <= '0';
			out_fp <= (others =>'0');
		elsif (enable = '1') then
			ex_enable <= enable_trigger;
			underflow <= underflow_trigger;
			overflow <= overflow_trigger;	   
			inexact <= inexact_trigger;
			exception <= except_trigger;
			invalid <= invalid_trigger;
			out_fp <= out_2;
		end if;
	end process;
	end rtl;
