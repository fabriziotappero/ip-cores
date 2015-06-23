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
	
	ENTITY fpu_sub IS

   PORT( 
      clk : IN     std_logic;
      rst : IN     std_logic;
      enable  : IN     std_logic;
      opa : IN     std_logic_vector (63 DOWNTO 0);
      opb : IN     std_logic_vector (63 DOWNTO 0);
      fpu_op : IN     std_logic_vector (2 DOWNTO 0);
      sign : OUT    std_logic;
      diff_2 : OUT    std_logic_vector (55 DOWNTO 0);
      exponent_2 : OUT    std_logic_vector (10 DOWNTO 0)
   );

	-- Declarations

	END fpu_sub;
	
	
	architecture rtl of fpu_sub is
	
	signal   fpu_op_add : std_logic;
	signal 	 diff_shift : std_logic_vector(5 downto 0);
	signal 	 diff_shift_2 : std_logic_vector(5 downto 0);
	signal   exponent_a : std_logic_vector(10 downto 0);
	signal   exponent_b : std_logic_vector(10 downto 0);
	signal   mantissa_a : std_logic_vector(51 downto 0);
	signal   mantissa_b : std_logic_vector(51 downto 0);
	signal   expa_gt_expb : std_logic;
	signal   expa_et_expb : std_logic;
	signal   mana_gtet_manb : std_logic;
	signal   a_gtet_b : std_logic;
	signal   exponent_small : std_logic_vector(10 downto 0);
	signal   exponent_large : std_logic_vector(10 downto 0);
	signal   mantissa_small : std_logic_vector(51 downto 0);
	signal   mantissa_large : std_logic_vector(51 downto 0);
	signal   small_is_denorm : std_logic;
	signal   large_is_denorm : std_logic;
	signal   large_norm_small_denorm : std_logic;
	signal   small_is_nonzero : std_logic;
	signal   exponent_diff : std_logic_vector(10 downto 0);
	signal   minuend : std_logic_vector(54 downto 0);
	signal   subtrahend : std_logic_vector(54 downto 0);
	signal   subtra_shift : std_logic_vector(54 downto 0);
	signal   subtra_shift_nonzero : std_logic;
	signal   subtra_fraction_enable : std_logic;
	signal   subtra_shift_2 : std_logic_vector(54 downto 0);
	signal   subtra_shift_3 : std_logic_vector(54 downto 0);
	signal   diff : std_logic_vector(54 downto 0);
	signal   diffshift_gt_exponent : std_logic;
	signal   diffshift_et_55 : std_logic; -- when the difference = 0
	signal   diff_1 : std_logic_vector(54 downto 0);
	signal   exponent : std_logic_vector(10 downto 0);
	signal   in_norm_out_denorm : std_logic;
	
	begin
	
	subtra_shift_nonzero <= or_reduce(subtra_shift);
	subtra_fraction_enable <= small_is_nonzero and not subtra_shift_nonzero;
	subtra_shift_2 <= "0000000000000000000000000000000000000000000000000000001";
	in_norm_out_denorm <= or_reduce(exponent_large) and not or_reduce(exponent);
	fpu_op_add <= '1' when fpu_op = "000" else '0';
	
process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			exponent_a <= (others =>'0');
			exponent_b <= (others =>'0');
			mantissa_a <= (others =>'0');
			mantissa_b <= (others =>'0');
			expa_gt_expb <= '0';
			expa_et_expb <= '0';
			mana_gtet_manb <= '0';
   			a_gtet_b <= '0';
			exponent_small  <= (others =>'0');
			exponent_large  <= (others =>'0');
			mantissa_small  <= (others =>'0');
			mantissa_large  <= (others =>'0');
			sign <= '0';
			small_is_denorm <= '0';
			large_is_denorm <= '0';
			large_norm_small_denorm <= '0';
			small_is_nonzero <= '0';
			exponent_diff <= (others =>'0');
			minuend <= (others =>'0');
			subtrahend <= (others =>'0');
			subtra_shift <= (others =>'0');
			subtra_shift_3 <= (others =>'0');
			diff_shift <= (others =>'0');
			diff_shift_2 <= (others =>'0');
			diff <= (others =>'0');
			diffshift_gt_exponent <= '0';
			diffshift_et_55 <= '0';
			diff_1 <= (others =>'0');
			exponent <= (others =>'0');
			exponent_2 <= (others =>'0');
			diff_2 <= (others =>'0');
		elsif (enable = '1') then
			exponent_a <= opa(62 downto 52);
			exponent_b <= opb(62 downto 52);
			mantissa_a <= opa(51 downto 0);
			mantissa_b <= opb(51 downto 0);
			if (exponent_a > exponent_b) then
				expa_gt_expb <= '1';
			else
				expa_gt_expb <= '0';
			end if;
			if (exponent_a = exponent_b) then
				expa_et_expb <= '1';
			else
				expa_et_expb <= '0';
			end if;
			if (mantissa_a >= mantissa_b) then
				mana_gtet_manb <= '1';
			else
				mana_gtet_manb <= '0';
			end if;
			a_gtet_b <= expa_gt_expb or (expa_et_expb and mana_gtet_manb);
			if (a_gtet_b = '1') then
				exponent_small <= exponent_b;
				exponent_large <= exponent_a;
				mantissa_small <= mantissa_b;
				mantissa_large <= mantissa_a;
				sign <= opa(63);
			else 
				exponent_small <= exponent_a;
				exponent_large <= exponent_b;
				mantissa_small <= mantissa_a;
				mantissa_large <= mantissa_b;
				sign <= (not opb(63)) xor fpu_op_add;
			end if;
			if (exponent_small > 0) then
				small_is_denorm <= '0';
			else
				small_is_denorm <= '1';
			end if;
			if (exponent_large > 0) then
				large_is_denorm <= '0';
			else
				large_is_denorm <= '1';
			end if;
			if (small_is_denorm = '1' and large_is_denorm = '0') then
				large_norm_small_denorm <= '1';
			else
				large_norm_small_denorm <= '0';	
			end if;
			small_is_nonzero <= (not small_is_denorm) or or_reduce(mantissa_small);
			exponent_diff <= exponent_large - exponent_small - large_norm_small_denorm;
			minuend <= not large_is_denorm & mantissa_large & "00";
			subtrahend <= not small_is_denorm & mantissa_small & "00";
			subtra_shift <= shr(subtrahend,  exponent_diff);
			if (subtra_fraction_enable = '1') then
				subtra_shift_3 <= subtra_shift_2;
			else
				subtra_shift_3 <= subtra_shift;
			end if;
			diff <= minuend - subtra_shift_3;
			diff_shift <= count_l_zeros(diff(54 downto 0));
			diff_shift_2 <= diff_shift;
			if (diff_shift_2 > exponent_large) then
				diffshift_gt_exponent <= '1';
			else
				diffshift_gt_exponent <= '0';
			end if;
			if (diff_shift_2 = "0110111") then -- 55
				diffshift_et_55 <= '1';
			else
				diffshift_et_55 <= '0';
			end if;
			if (diffshift_gt_exponent = '1') then
				diff_1 <= shl(diff, exponent_large);
				exponent <= "00000000000";
			else
				diff_1 <= shl(diff, diff_shift_2);
				exponent <= exponent_large - diff_shift_2;
			end if;
			if (diffshift_et_55 = '1') then
				exponent_2 <= "00000000000";
			else
				exponent_2 <=  exponent;
			end if;
			if (in_norm_out_denorm = '1') then
				diff_2 <= '0' & shr(diff_1,conv_std_logic_vector('1', 55));
			else
				diff_2 <= '0' & diff_1;
			end if;
		end if;
	end process;

	end rtl;

	
