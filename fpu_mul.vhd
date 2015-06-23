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
	use work.fpupack.all;
	
	ENTITY fpu_mul IS

   PORT( 
      clk : IN     std_logic;
      rst : IN     std_logic;
      enable  : IN     std_logic;
      opa : IN     std_logic_vector (63 DOWNTO 0);
      opb : IN     std_logic_vector (63 DOWNTO 0);
      sign : OUT    std_logic;
      product_7 : OUT    std_logic_vector (55 DOWNTO 0);
      exponent_5 : OUT    std_logic_vector (11 DOWNTO 0)
   );

	END fpu_mul;
	
	
	architecture rtl of fpu_mul is
	
	signal 		product_shift : std_logic_vector(5 downto 0);
	signal 		product_shift_2 : std_logic_vector(5 downto 0);
	signal 		mantissa_a : std_logic_vector(51 downto 0);
	signal 		mantissa_b : std_logic_vector(51 downto 0);
	signal 		exponent_a : std_logic_vector(11 downto 0);
	signal 		exponent_b : std_logic_vector(11 downto 0);
	signal		a_is_norm : std_logic;
	signal		b_is_norm : std_logic;
	signal		a_is_zero : std_logic; 
	signal		b_is_zero : std_logic; 
	signal		in_zero : std_logic;
	signal   	exponent_terms : std_logic_vector(11 downto 0);
	signal    	exponent_gt_expoffset : std_logic;
	signal   	exponent_under : std_logic_vector(11 downto 0);
	signal   	exponent_1 : std_logic_vector(11 downto 0);
	signal   	exponent : std_logic_vector(11 downto 0);
	signal   	exponent_2 : std_logic_vector(11 downto 0);
	signal   	exponent_gt_prodshift : std_logic;
	signal   	exponent_3 : std_logic_vector(11 downto 0);
	signal   	exponent_4 : std_logic_vector(11 downto 0);
	signal  	exponent_et_zero : std_logic;
	signal   	mul_a : std_logic_vector(52 downto 0);
	signal   	mul_b : std_logic_vector(52 downto 0);
	signal		product_a : std_logic_vector(40 downto 0);
	signal		product_b : std_logic_vector(40 downto 0);
	signal		product_c : std_logic_vector(40 downto 0);
	signal		product_d : std_logic_vector(25 downto 0);
	signal		product_e : std_logic_vector(33 downto 0);
	signal		product_f : std_logic_vector(33 downto 0);
	signal		product_g : std_logic_vector(35 downto 0);
	signal		product_h : std_logic_vector(28 downto 0);
	signal		product_i : std_logic_vector(28 downto 0);
	signal		product_j : std_logic_vector(30 downto 0);
	signal		sum_0 : std_logic_vector(41 downto 0);
	signal		sum_1 : std_logic_vector(35 downto 0);
	signal		sum_2 : std_logic_vector(41 downto 0);
	signal		sum_3 : std_logic_vector(35 downto 0);
	signal		sum_4 : std_logic_vector(36 downto 0);
	signal		sum_5 : std_logic_vector(27 downto 0);
	signal		sum_6 : std_logic_vector(29 downto 0);
	signal		sum_7 : std_logic_vector(36 downto 0);
	signal		sum_8 : std_logic_vector(30 downto 0);
	signal  	product : std_logic_vector(105 downto 0);
	signal  	product_1 : std_logic_vector(105 downto 0);
	signal  	product_2 : std_logic_vector(105 downto 0);
	signal  	product_3 : std_logic_vector(105 downto 0);
	signal  	product_4 : std_logic_vector(105 downto 0); 
	signal  	product_5 : std_logic_vector(105 downto 0);
	signal  	product_6 : std_logic_vector(105 downto 0);
	signal		product_lsb : std_logic;	

	begin
		product_7 <= '0' & product_6(105 downto 52) & product_lsb; 
		exponent <= "000000000000";
	process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			sign <= '0';
			mantissa_a <= (others =>'0');
			mantissa_b <= (others =>'0');
			exponent_a <= (others =>'0');
			exponent_b <= (others =>'0');
			a_is_norm <= '0';
			b_is_norm <= '0';
			a_is_zero <= '0'; 
			b_is_zero <= '0'; 
			in_zero <= '0';
			exponent_terms <= (others =>'0');
			exponent_gt_expoffset <= '0';
			exponent_under <= (others =>'0');
			exponent_1 <= (others =>'0'); 
			exponent_2 <= (others =>'0');
			exponent_gt_prodshift <= '0';
			exponent_3 <= (others =>'0');
			exponent_4 <= (others =>'0');
			exponent_et_zero <= '0';
			mul_a <= (others =>'0'); 
			mul_b <= (others =>'0');
			product_a <= (others =>'0');
			product_b <= (others =>'0');
			product_c <= (others =>'0');
			product_d <= (others =>'0');
			product_e <= (others =>'0');
			product_f <= (others =>'0');
			product_g <= (others =>'0');
			product_h <= (others =>'0');
			product_i <= (others =>'0');
			product_j <= (others =>'0');
			sum_0 <= (others =>'0');
			sum_1 <= (others =>'0');
			sum_2 <= (others =>'0');
			sum_3 <= (others =>'0');
			sum_4 <= (others =>'0');
			sum_5 <= (others =>'0');
			sum_6 <= (others =>'0');
			sum_7 <= (others =>'0');
			sum_8 <= (others =>'0');
			product <= (others =>'0');
			product_1 <= (others =>'0');
			product_2 <= (others =>'0'); 
			product_3 <= (others =>'0');
			product_4 <= (others =>'0');
			product_5 <= (others =>'0'); 
			product_6 <= (others =>'0');
			product_lsb <= '0';
			exponent_5 <= (others =>'0');
			product_shift <= (others =>'0');
			product_shift_2 <= (others =>'0');
		elsif (enable = '1') then
			sign <= opa(63) xor opb(63);
			exponent_a <= '0' & opa(62 downto 52);
			exponent_b <= '0' & opb(62 downto 52);
			mantissa_a <= opa(51 downto 0);
			mantissa_b <= opb(51 downto 0);
			a_is_norm <= or_reduce(exponent_a);
			b_is_norm <= or_reduce(exponent_b);
			a_is_zero <= not or_reduce(opa(62 downto 0)); 
			b_is_zero <= not or_reduce(opb(62 downto 0)); 
			in_zero <= a_is_zero or b_is_zero;
			exponent_terms <= exponent_a + exponent_b + ( "0000000000" & not a_is_norm) + 
							("0000000000" & not b_is_norm);
			if (exponent_terms > "001111111101") then
				exponent_gt_expoffset <= '1';
			else
				exponent_gt_expoffset <= '0';
			end if;
			exponent_under <= "001111111110" - exponent_terms;
			exponent_1 <= exponent_terms - "001111111110"; 
			if (exponent_gt_expoffset = '1') then
				exponent_2 <= exponent_1;
			else
				exponent_2 <= exponent;
			end if;
			if (exponent_2 > product_shift_2) then
				exponent_gt_prodshift <= '1';
			else
				exponent_gt_prodshift <= '0';
			end if;
			exponent_3 <= exponent_2 - product_shift_2;
			if (exponent_gt_prodshift = '1') then
				exponent_4 <= exponent_3;
			else
				exponent_4 <= exponent;
			end if;
			if (exponent_4 = "000000000000") then
				exponent_et_zero <= '1';
			else
				exponent_et_zero <= '0';
			end if;
			mul_a <= a_is_norm & mantissa_a;
			mul_b <= b_is_norm & mantissa_b;
			product_a <= mul_a(23 downto 0) * mul_b(16 downto 0);
			product_b <= mul_a(23 downto 0) * mul_b(33 downto 17);
			product_c <= mul_a(23 downto 0) * mul_b(50 downto 34);
			product_d <= mul_a(23 downto 0) * mul_b(52 downto 51);
			product_e <= mul_a(40 downto 24) * mul_b(16 downto 0);
			product_f <= mul_a(40 downto 24) * mul_b(33 downto 17);
			product_g <= mul_a(40 downto 24) * mul_b(52 downto 34);
			product_h <= mul_a(52 downto 41) * mul_b(16 downto 0);
			product_i <= mul_a(52 downto 41) * mul_b(33 downto 17);
			product_j <= mul_a(52 downto 41) * mul_b(52 downto 34);
			sum_0 <= product_a(40 downto 17) + ( '0' & product_b);
			sum_1 <= ('0' & sum_0(41 downto 7)) + product_e;
			sum_2 <= sum_1(35 downto 10) + ('0' & product_c);
			sum_3 <= ( '0' & sum_2(41 downto 7)) + product_h;
			sum_4 <= ( '0' & sum_3) + product_f;
			sum_5 <= ('0' & sum_4(36 downto 10)) + product_d;
			sum_6 <= sum_5(27 downto 7) + ('0' & product_i);
			sum_7 <= sum_6 + ('0' & product_g);
			sum_8 <= sum_7(36 downto 17) + product_j;
			product <=  sum_8 & sum_7(16 downto 0) & sum_5(6 downto 0) & sum_4(9 downto 0) & sum_2(6 downto 0) &
						sum_1(9 downto 0) & sum_0(6 downto 0) & product_a(16 downto 0);
			product_1 <= shr(product, exponent_under);
			if (exponent_gt_prodshift = '1') then
				product_5 <= product_3;
			else
				product_5 <= product_4;
			end if;
			if (exponent_gt_expoffset = '1') then
				product_2 <= product;
			else
				product_2 <= product_1;
			end if;
			product_3 <= shl(product_2, product_shift_2);
			product_4 <= shl(product_2, exponent_2);
			if (exponent_gt_prodshift = '1') then
				product_5 <= product_3;
			else
				product_5 <= product_4;
			end if;
			if (exponent_et_zero = '1') then
				product_6 <= shr(product_5, conv_std_logic_vector('1', 106));
			else
				product_6 <= product_5;
			end if;
			product_lsb <= or_reduce(product_6(51 downto 0));
			if (in_zero = '1') then
				exponent_5 <= "000000000000";
			else
				exponent_5 <= exponent_4;
			end if;
			product_shift <= count_zeros_mul(product(105 downto 0));
			product_shift_2 <= product_shift;
		end if;
	end process;
	end rtl;