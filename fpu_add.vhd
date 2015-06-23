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


ENTITY fpu_add IS

   PORT( 
      clk : IN     std_logic;
      rst : IN     std_logic;
      enable  : IN     std_logic;
      opa : IN     std_logic_vector (63 DOWNTO 0);
      opb : IN     std_logic_vector (63 DOWNTO 0);
      sign : OUT    std_logic;
      sum_3 : OUT    std_logic_vector (55 DOWNTO 0);
      exponent_2 : OUT    std_logic_vector (10 DOWNTO 0)
   );

-- Declarations

END fpu_add;

architecture rtl of fpu_add is


signal   exponent_a : std_logic_vector(10 downto 0);
signal   exponent_b : std_logic_vector(10 downto 0);
signal   mantissa_a : std_logic_vector(51 downto 0);
signal   mantissa_b : std_logic_vector(51 downto 0);
signal   exponent_small : std_logic_vector(10 downto 0);
signal   exponent_large : std_logic_vector(10 downto 0);
signal   mantissa_small : std_logic_vector(51 downto 0);
signal   mantissa_large : std_logic_vector(51 downto 0);
signal   small_is_denorm : std_logic;
signal   large_is_denorm : std_logic;
signal   large_norm_small_denorm : std_logic_vector(10 downto 0);
signal   exponent_diff : std_logic_vector(10 downto 0);
signal   large_add : std_logic_vector(55 downto 0);
signal   small_add : std_logic_vector(55 downto 0);
signal   small_shift : std_logic_vector(55 downto 0);
signal   small_shift_nonzero : std_logic;
signal	 small_is_nonzero : std_logic;
signal   small_fraction_enable : std_logic; 
signal   small_shift_2 : std_logic_vector(55 downto 0); 
signal   small_shift_3 : std_logic_vector(55 downto 0);
signal   sum : std_logic_vector(55 downto 0);
signal   sum_2 : std_logic_vector(55 downto 0);
signal   sum_overflow : std_logic;
signal   exponent : std_logic_vector(10 downto 0);
signal   sum_leading_one : std_logic;
signal   denorm_to_norm : std_logic;

signal   exp_diff_int : integer;

begin

small_shift_nonzero <= or_reduce(small_shift);
small_is_nonzero <= or_reduce(exponent_small) or or_reduce(mantissa_small(51 downto 0));
small_fraction_enable <= small_is_nonzero and not small_shift_nonzero;
small_shift_2 <= "00000000000000000000000000000000000000000000000000000001";
sum_overflow <= sum(55); -- sum[55] will be 0 if there was no carry from adding the 2 numbers
sum_leading_one <= sum_2(54); -- this is where the leading one resides, unless denorm
--exp_diff_int <= to_integer(exponent_diff);

process
	begin
	wait until clk'event and clk = '1';
		if (rst = '1') then
			sign <= '0';
			exponent_a <= (others =>'0');
			exponent_b <= (others =>'0');
			mantissa_a <= (others =>'0');
			mantissa_b <= (others =>'0');
			exponent_small  <= (others =>'0');
			exponent_large  <= (others =>'0');
			mantissa_small  <= (others =>'0');
			mantissa_large  <= (others =>'0');
			small_is_denorm <= '0';
			large_is_denorm <= '0';
			large_norm_small_denorm <= (others =>'0');
			exponent_diff <= (others =>'0');
			large_add <= (others =>'0');
			small_add <= (others =>'0');
			small_shift <= (others =>'0');
			small_shift_3 <= (others =>'0');
			sum <= (others =>'0');
			sum_2 <= (others =>'0');
			sum_3 <= (others =>'0');
			exponent <= (others =>'0');
			denorm_to_norm <= '0';
			exponent_2 <= (others =>'0');
		elsif (enable = '1') then
			sign <= opa(63);
			exponent_a <= opa(62 downto 52);
			exponent_b <= opb(62 downto 52);
			mantissa_a <= opa(51 downto 0);
			mantissa_b <= opb(51 downto 0);
			if (exponent_a > exponent_b) then
				exponent_small <= exponent_b;
				exponent_large <= exponent_a;
				mantissa_small <= mantissa_b;
				mantissa_large <= mantissa_a;
			else 
				exponent_small <= exponent_a;
				exponent_large <= exponent_b;
				mantissa_small <= mantissa_a;
				mantissa_large <= mantissa_b;
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
				large_norm_small_denorm <= "00000000001";
			else
				large_norm_small_denorm <= "00000000000";	
			end if;
			exponent_diff <= exponent_large - exponent_small - large_norm_small_denorm;
			large_add <= '0' & not large_is_denorm & mantissa_large & "00";
			small_add <= '0' & not small_is_denorm & mantissa_small & "00";
			small_shift <= shr(small_add,  exponent_diff);
			if (small_fraction_enable = '1') then
				small_shift_3 <= small_shift_2;
			else
				small_shift_3 <= small_shift;
			end if;
			sum <= large_add + small_shift_3;
			if (sum_overflow = '1') then
				sum_2 <= shr(sum, conv_std_logic_vector('1', 56));
			else
				sum_2 <= sum;
			end if;
			sum_3 <= sum_2;
			if (sum_overflow = '1') then
				exponent <=  exponent_large + 1;
			else
				exponent <=  exponent_large;
			end if;
			denorm_to_norm <= sum_leading_one and large_is_denorm;
			if (denorm_to_norm = '1') then
				exponent_2 <= exponent + 1;
			else
				exponent_2 <= exponent;
			end if;
		end if;
	end process;


end rtl;