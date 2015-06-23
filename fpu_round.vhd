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

	
	ENTITY fpu_round IS

   PORT( 
      clk, rst, enable : IN     std_logic;
      round_mode : IN     std_logic_vector (1 DOWNTO 0);
      sign_term : IN    std_logic;
      mantissa_term : IN     std_logic_vector (55 DOWNTO 0);
      exponent_term : IN     std_logic_vector (11 DOWNTO 0);
      round_out : OUT    std_logic_vector (63 DOWNTO 0);
      exponent_final : OUT    std_logic_vector (11 DOWNTO 0)
   );

	END fpu_round;
	
	
	architecture rtl of fpu_round is

	signal	rounding_amount : std_logic_vector(55 downto 0);
	signal	round_nearest : std_logic; 
	signal	round_to_zero : std_logic; 
	signal	round_to_pos_inf : std_logic; 
	signal	round_to_neg_inf : std_logic; 
	signal 	round_nearest_trigger : std_logic;
	signal	round_to_pos_inf_trigger : std_logic; 
	signal	round_to_neg_inf_trigger : std_logic; 
	signal 	round_trigger : std_logic; 
	signal	sum_round : std_logic_vector(55 downto 0);
	signal	sum_round_overflow : std_logic; 
		-- will be 0 if no carry, 1 if overflow from the rounding unit
		-- overflow from rounding is extremely rare, but possible
	signal	sum_round_2 : std_logic_vector(55 downto 0);
	signal  exponent_round : std_logic_vector(11 downto 0);	 
	signal  exponent_final_2 : std_logic_vector(11 downto 0);
	signal	sum_final : std_logic_vector(55 downto 0); 
	
	begin
	
	rounding_amount  <= "00000000000000000000000000000000000000000000000000000100";
	round_nearest  <= '1' when (round_mode = "00") else '0';
	round_to_zero  <= '1' when (round_mode = "01") else '0';
	round_to_pos_inf  <= '1' when (round_mode = "10") else '0';
	round_to_neg_inf  <= '1' when (round_mode = "11") else '0';
	round_nearest_trigger  <= '1' when round_nearest = '1' and mantissa_term(1) = '1' 
							else '0'; 
	round_to_pos_inf_trigger  <= '1' when sign_term = '0' and 
							or_reduce(mantissa_term(1 downto 0)) = '1' else '0'; 
	round_to_neg_inf_trigger  <= '1' when sign_term = '1' and 
							or_reduce(mantissa_term(1 downto 0)) = '1' else '0';
	round_trigger <= '1' when ( round_nearest = '1' and round_nearest_trigger = '1')
							or (round_to_pos_inf = '1' and round_to_pos_inf_trigger = '1') 
							or (round_to_neg_inf = '1' and round_to_neg_inf_trigger = '1')
							else '0';
	sum_round_overflow <= sum_round(55); 
							
	
	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
				sum_round <= (others =>'0');
				sum_round_2 <= (others =>'0');
				exponent_round <= (others =>'0');
				sum_final <= (others =>'0'); 
				exponent_final <= (others =>'0'); 
				exponent_final_2 <= (others =>'0');
				round_out <= (others =>'0');
		else 
				sum_round <= rounding_amount + mantissa_term;
				if sum_round_overflow = '1' then
					sum_round_2 <= shr(sum_round, conv_std_logic_vector('1', 56));
					exponent_round <= exponent_term + "000000000001";
				else
					sum_round_2 <= sum_round;
					exponent_round <= exponent_term;
				end if;
				if round_trigger = '1' then
					sum_final <= sum_round_2;
					exponent_final_2 <= exponent_round;
				else
					sum_final <= mantissa_term;
					exponent_final_2 <= exponent_term;
				end if;		   
				exponent_final <= exponent_final_2;
				round_out <=  sign_term & exponent_final_2(10 downto 0) & sum_final(53 downto 2);
		end if;
	end process;
	end rtl;	