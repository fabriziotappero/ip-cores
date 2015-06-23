---------------------------------------------------------------------
--				(c) Copyright 2006, CoreTex Systems, LLC					 --
--		                   www.coretexsys.com                        --    
--                                                            		 --
--		This source file may be used and distributed without         --
--		restriction provided that this copyright statement is not    --
--		removed from the file and that any derivative work contains  --
--		the original copyright notice and the associated disclaimer. --
--                                                            		 --
--		    THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY      --
--		EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    --
--		TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS    --
--		FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR       --
--		OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,          --
--		INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES     --
--		(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE    --
--		GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR         --
--		BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   --
--		LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT   --
--		(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT   --
--		OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE          --
--		POSSIBILITY OF SUCH DAMAGE.                                  --
--																						 --
---------------------------------------------------------------------

----------------------------------------------------------------------

-- Poject structure: 

--  |- tdes_top.vhd
--  |
--    |- des_cipher_top.vhd
--    |- des_top.vhd
--      |- block_top.vhd
--        |- add_key.vhd
--        |
--        |- add_left.vhd
--        |
--				|- e_expansion_function.vhd
--				|
--				|- p_box.vhd
--				|
--				|- s_box.vhd
--            |- s1_box.vhd
--            |- s2_box.vhd
--            |- s3_box.vhd
--            |- s4_box.vhd
--            |- s5_box.vhd
--            |- s6_box.vhd
--            |- s7_box.vhd
--            |- s8_box.vhd
--    |- key_schedule.vhd

----------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--
-- Title       : add_key
-- Company     : CoreTex Systems, LLC
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity add_key is
port(
    		x0_in: in std_logic_vector(0 to 5);
			x1_in: in std_logic_vector(0 to 5);
			x2_in: in std_logic_vector(0 to 5);
			x3_in: in std_logic_vector(0 to 5);
			x4_in: in std_logic_vector(0 to 5);
			x5_in: in std_logic_vector(0 to 5);
			x6_in: in std_logic_vector(0 to 5);
			x7_in: in std_logic_vector(0 to 5);
			key: in std_logic_vector(0 to 47);
			x0_out: out std_logic_vector(5 downto 0);
			x1_out: out std_logic_vector(5 downto 0);
			x2_out: out std_logic_vector(5 downto 0);
			x3_out: out std_logic_vector(5 downto 0);
			x4_out: out std_logic_vector(5 downto 0);
			x5_out: out std_logic_vector(5 downto 0);
			x6_out: out std_logic_vector(5 downto 0);
			x7_out: out std_logic_vector(5 downto 0)
 	);
end add_key;


architecture Behavioral of add_key is
begin

	x0_out <= x0_in xor key(0 to 5);
	x1_out <= x1_in xor key(6 to 11);
	x2_out <= x2_in xor key(12 to 17);
	x3_out <= x3_in xor key(18 to 23);
	x4_out <= x4_in xor key(24 to 29);
	x5_out <= x5_in xor key(30 to 35);
	x6_out <= x6_in xor key(36 to 41);
	x7_out <= x7_in xor key(42 to 47);

end Behavioral;
