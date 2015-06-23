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
	library work;	  
	use work.comppack.all;
	use work.fpupack.all;
	
	ENTITY fpu_double IS

   PORT( 
      clk, rst, enable : IN     std_logic;
      rmode : IN     std_logic_vector (1 DOWNTO 0);
      fpu_op : IN     std_logic_vector (2 DOWNTO 0);
      opa, opb : IN     std_logic_vector (63 DOWNTO 0);
      out_fp: OUT    std_logic_vector (63 DOWNTO 0);
      ready, underflow, overflow, inexact : OUT    std_logic;
      exception, invalid : OUT    std_logic
   );

	END fpu_double;
	
-- FPU Operations (fpu_op):
--========================
--	0 = add
--	1 = sub
--	2 = mul
--	3 = div

--Rounding Modes (rmode):
--=======================
--	0 = round_nearest_even
--	1 = round_to_zero
--	2 = round_up
--	3 = round_down  

	architecture rtl of fpu_double is
	
	signal  opa_reg : std_logic_vector(63 downto 0);
	signal  opb_reg : std_logic_vector(63 downto 0);
	signal  fpu_op_reg : std_logic_vector(2 downto 0);
	signal  rmode_reg : std_logic_vector(1 downto 0);
	signal	enable_reg : std_logic;
	signal	enable_reg_1 : std_logic; -- high for one clock cycle
	signal	enable_reg_2 : std_logic; -- high for one clock cycle		 
	signal	enable_reg_3 : std_logic; -- high for two clock cycles
	signal	op_enable : std_logic;	  
	signal  count_cycles : std_logic_vector(6 downto 0);
	signal  count_ready : std_logic_vector(6 downto 0);
	signal	count_busy : std_logic;
	signal	ready_0 : std_logic;
	signal	ready_1 : std_logic;
	signal	underflow_0 : std_logic;
	signal	overflow_0 : std_logic;
	signal	inexact_0 : std_logic;
	signal	exception_0 : std_logic;
	signal	invalid_0 : std_logic;
	
	signal	add_enable_0 : std_logic;
	signal	add_enable_1 : std_logic;
	signal	add_enable : std_logic; 
	signal	sub_enable_0 : std_logic;
	signal	sub_enable_1 : std_logic;
	signal	sub_enable : std_logic; 
	signal	mul_enable : std_logic; 
	signal	div_enable : std_logic;  
	signal	except_enable : std_logic;
	signal	sum_out : std_logic_vector(55 downto 0);
	signal	diff_out : std_logic_vector(55 downto 0);
	signal	addsub_out : std_logic_vector(55 downto 0);
	signal	mul_out : std_logic_vector(55 downto 0);
	signal	div_out : std_logic_vector(55 downto 0);
	signal	mantissa_round : std_logic_vector(55 downto 0);
	signal	exp_add_out : std_logic_vector(10 downto 0);
	signal	exp_sub_out : std_logic_vector(10 downto 0);
	signal	exp_mul_out : std_logic_vector(11 downto 0);
	signal	exp_div_out : std_logic_vector(11 downto 0);
	signal	exponent_round : std_logic_vector(11 downto 0);
	signal	exp_addsub : std_logic_vector(11 downto 0);
	signal	exponent_post_round : std_logic_vector(11 downto 0);
	signal	add_sign : std_logic;
	signal	sub_sign : std_logic;
	signal	mul_sign : std_logic;
	signal	div_sign : std_logic;
	signal	addsub_sign : std_logic;
	signal	sign_round : std_logic;
	signal	out_round : std_logic_vector(63 downto 0);
	signal	out_except : std_logic_vector(63 downto 0);
	
	begin
				
	i_fpu_add: fpu_add 
		port map (
		clk => clk , rst => rst , enable => add_enable , opa => opa_reg , opb => opb_reg , 
		sign => add_sign , sum_3 => sum_out , exponent_2 => exp_add_out);
	
	i_fpu_sub: fpu_sub 
		port map (
		clk => clk , rst => rst , enable => sub_enable , opa => opa_reg , opb => opb_reg , 
		fpu_op => fpu_op_reg , sign => sub_sign , diff_2 => diff_out , 
		exponent_2 => exp_sub_out);
	
	i_fpu_mul: fpu_mul 
		port map (
		clk => clk , rst => rst , enable => mul_enable , opa => opa_reg , opb => opb_reg , 
		sign => mul_sign , product_7 => mul_out , exponent_5 => exp_mul_out);	
	
	i_fpu_div: fpu_div 
		port map (
		clk => clk , rst => rst , enable => div_enable , opa => opa_reg , opb => opb_reg , 
		sign => div_sign , mantissa_7 => div_out , exponent_out => exp_div_out);	
	
	i_fpu_round: fpu_round 
		port map (
		clk => clk , rst => rst , enable => op_enable , 	round_mode => rmode_reg , 
		sign_term => sign_round , mantissa_term => mantissa_round ,  exponent_term => exponent_round , 
		round_out => out_round , exponent_final => exponent_post_round);		
		
	i_fpu_exceptions: fpu_exceptions 
		port map (
		clk => clk , rst => rst , enable => op_enable , rmode => rmode_reg , 
		opa => opa_reg , opb => opb_reg , 
		in_except => out_round ,  exponent_in => exponent_post_round , 
		mantissa_in => mantissa_round(1 downto 0) , fpu_op => fpu_op_reg , out_fp => out_except , 
		ex_enable => except_enable , underflow => underflow_0 , overflow => overflow_0 , 
		inexact => inexact_0 , exception => exception_0 , invalid => invalid_0);
			
	count_busy <= '1' when (count_ready <= count_cycles) else '0';	 

	add_enable_0  <= '1' when fpu_op_reg = "000" and (opa_reg(63) xor opb_reg(63)) = '0' else '0';
	add_enable_1  <= '1' when (fpu_op_reg = "001") and (opa_reg(63) xor opb_reg(63)) = '1' else '0';
	sub_enable_0  <= '1' when (fpu_op_reg = "000") and (opa_reg(63) xor opb_reg(63)) = '1' else '0';
	sub_enable_1  <= '1' when (fpu_op_reg = "001") and (opa_reg(63) xor opb_reg(63)) = '0' else '0';
		
	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			mantissa_round <= (others =>'0');
			exponent_round <= (others =>'0');
			sign_round <= '0';
			count_cycles <= (others =>'0');
		else
			if (fpu_op_reg = "000") then -- add
				mantissa_round <= addsub_out;
				exponent_round <= exp_addsub;
				sign_round <= addsub_sign;
				count_cycles <= "0010100"; -- 20
			elsif (fpu_op_reg = "001") then -- subtract
				mantissa_round <= addsub_out;
				exponent_round <= exp_addsub;
				sign_round <= addsub_sign;
				count_cycles <= "0010101"; -- 21
			elsif (fpu_op_reg = "010") then
				mantissa_round <= mul_out;
				exponent_round <= exp_mul_out;
				sign_round <= mul_sign;
				count_cycles <= "0011000"; -- 24	
			elsif (fpu_op_reg = "011") then
				mantissa_round <= div_out;
				exponent_round <= exp_div_out;
				sign_round <= div_sign;
				count_cycles <= "1000111"; -- 71
			else
				mantissa_round <= (others =>'0');
				exponent_round <= (others =>'0');
				sign_round <= '0';
				count_cycles <= (others =>'0');
			end if;
		end if;
	end process;
			

	
	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			add_enable <= '0';
			sub_enable <= '0';
			mul_enable <= '0';
			div_enable <= '0';
			addsub_out <= (others =>'0');
			addsub_sign <= '0';
			exp_addsub <= (others =>'0');
		else 
			if ((add_enable_0 = '1' or add_enable_1 = '1') and op_enable= '1') then
				add_enable <= '1';
			else
				add_enable <= '0';
			end if;
			if ((sub_enable_0 = '1' or sub_enable_1 = '1') and op_enable = '1') then
				sub_enable <= '1';
			else
				sub_enable <= '0';
			end if;
			if fpu_op_reg = "010" and op_enable = '1' then
				mul_enable <= '1';
			else
				mul_enable <= '0';
			end if;
			if fpu_op_reg = "011" and op_enable = '1' and enable_reg_3 = '1' then
				div_enable <= '1';
			else
				div_enable <= '0';
			end if;  -- div_enable needs to be high for two clock cycles
			if add_enable = '1' then
				addsub_out <= sum_out;
				addsub_sign <= add_sign;
				exp_addsub <= '0' & exp_add_out;
			else
				addsub_out <= diff_out;
				addsub_sign <= sub_sign;
				exp_addsub <= '0' & exp_sub_out;
			end if;
		end if;
	end process;
	
	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			count_ready <= (others =>'0');
		elsif (enable_reg_1 = '1') then 
			count_ready <= (others =>'0');
		elsif (count_busy = '1') then
			count_ready <= count_ready + "0000001";
		end if; 
	end process;
	
	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			enable_reg <= '0';
			enable_reg_1 <= '0';
			enable_reg_2 <= '0';	   
			enable_reg_3 <= '0';
		else
			enable_reg <= enable;
			if enable = '1' and enable_reg = '0' then
				enable_reg_1 <= '1';
			else
				enable_reg_1 <= '0';
			end if;
			enable_reg_2 <= enable_reg_1;
			if enable_reg_1 = '1' or enable_reg_2 = '1' then   
				enable_reg_3 <= '1';
			else
				enable_reg_3 <= '0';
			end if;
		end if; 
	end process;
			
	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			opa_reg <= (others =>'0');
			opb_reg <= (others =>'0');
			fpu_op_reg <= (others =>'0'); 
			rmode_reg <= (others =>'0');
			op_enable <= '0';
		elsif (enable_reg_1 = '1') then
			opa_reg <= opa;
			opb_reg <= opb;
			fpu_op_reg <= fpu_op; 
			rmode_reg <= rmode;
			op_enable <= '1';
		end if; 
	end process;
	
	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			ready_0 <= '0';
			ready_1 <= '0';
			ready <= '0';	   
		elsif (enable_reg_1 = '1') then
			ready_0 <= '0';
			ready_1 <= '0';
			ready <= '0';	 
		else 
			ready_0 <= not count_busy;
			ready_1 <= ready_0;
			ready <= ready_1;  
		end if; 
	end process;
	
	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			underflow <= '0';
			overflow <= '0';
			inexact <= '0';
			exception <= '0';
			invalid <= '0';	   	 
			out_fp <= (others =>'0');
		elsif (ready_1 = '1') then
			underflow <= underflow_0;
			overflow <= overflow_0;
			inexact <= inexact_0;
			exception <= exception_0;
			invalid <= invalid_0; 
			if except_enable = '1' then	
				out_fp <= out_except;
			else
				out_fp <= out_round;
			end if;
		end if; 
	end process;
	end rtl;
