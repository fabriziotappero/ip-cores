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
-- Title       : key_schedule
-- Company     : CoreTex Systems, LLC
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity key_schedule is
port (

		key_in:			in std_logic_vector(0 to 63);		-- key to be expanded
		
		-- interface signals for communication with DES 
		KeySelect: 		in std_logic_vector(3 downto 0);	-- selector for key
    	key_out: 		out std_logic_vector(0 to 47);	-- expaned key output
		key_ready: 		out std_logic;							-- signal for DES that key has been expanded
	
		reset: 			in std_logic; 							-- reset
		clock: 			in std_logic  							-- master clock
		);
end key_schedule;

architecture Behavioral of key_schedule is

--
-- Storage for expanded key 
--
signal K16, K1:  std_logic_vector(0 to 47);
signal K2,  K3:  std_logic_vector(0 to 47);
signal K4,  K5:  std_logic_vector(0 to 47);
signal K6,  K7:  std_logic_vector(0 to 47);
signal K8,  K9:  std_logic_vector(0 to 47);
signal K10, K11: std_logic_vector(0 to 47);
signal K12, K13: std_logic_vector(0 to 47);
signal K14, K15: std_logic_vector(0 to 47);

begin


--
-- Selector for expaned key
--
key_out <= 	K1 	when 	KeySelect = x"0" else
				K2 	when 	KeySelect = x"1" else
				K3 	when 	KeySelect = x"2" else
				K4 	when 	KeySelect = x"3" else
				K5 	when 	KeySelect = x"4" else
				K6 	when 	KeySelect = x"5" else
				K7 	when 	KeySelect = x"6" else
				K8 	when 	KeySelect = x"7" else
				K9 	when 	KeySelect = x"8" else
				K10 	when 	KeySelect = x"9" else
				K11 	when 	KeySelect = x"A" else
				K12 	when 	KeySelect = x"B" else
				K13 	when 	KeySelect = x"C" else
				K14 	when 	KeySelect = x"D" else
				K15 	when 	KeySelect = x"E" else
				K16;

process (clock)
begin
	
--
-- input key will expaned and stored after rising edge of the first clock after mater reset.  
-- the keys are captured at a triple-des level
--
if rising_edge(clock) then

	if reset = '1' then 
		key_ready <= '0';
	else
		
		--
		-- key expansion from the input key
		--
		K1 <= key_in(9) & key_in(50) & key_in(33) & key_in(59) & key_in(48) & key_in(16) & key_in(32) & key_in(56) & 
				key_in(1) & key_in(8) & key_in(18) & key_in(41) & key_in(2) & key_in(34) & key_in(25) & key_in(24) & 
				key_in(43) & key_in(57) & key_in(58) & key_in(0) & key_in(35) & key_in(26) & key_in(17) & key_in(40) & 
				key_in(21) & key_in(27) & key_in(38) & key_in(53) & key_in(36) & key_in(3) & key_in(46) & key_in(29) & 
				key_in(4) & key_in(52) & key_in(22) & key_in(28) & key_in(60) & key_in(20) & key_in(37) & key_in(62) & 
				key_in(14) & key_in(19) & key_in(44) & key_in(13) & key_in(12) & key_in(61) & key_in(54) & key_in(30);			

		K2 <= key_in(1) & key_in(42) & key_in(25) & key_in(51) & key_in(40) & key_in(8) & key_in(24) & key_in(48) & 
				key_in(58) & key_in(0) & key_in(10) & key_in(33) & key_in(59) & key_in(26) & key_in(17) & key_in(16) & 
				key_in(35) & key_in(49) & key_in(50) & key_in(57) & key_in(56) & key_in(18) & key_in(9) & key_in(32) & 
				key_in(13) & key_in(19) & key_in(30) & key_in(45) & key_in(28) & key_in(62) & key_in(38) & key_in(21) & 
				key_in(27) & key_in(44) & key_in(14) & key_in(20) & key_in(52) & key_in(12) & key_in(29) & key_in(54) & 
				key_in(6) & key_in(11) & key_in(36) & key_in(5) & key_in(4) & key_in(53) & key_in(46) & key_in(22);

		K3 <= key_in(50) & key_in(26) & key_in(9) & key_in(35) & key_in(24) & key_in(57) & key_in(8) & key_in(32) & 
				key_in(42) & key_in(49) & key_in(59) & key_in(17) & key_in(43) & key_in(10) & key_in(1) & key_in(0) & 
				key_in(48) & key_in(33) & key_in(34) & key_in(41) & key_in(40) & key_in(2) & key_in(58) & key_in(16) & 
				key_in(60) & key_in(3) & key_in(14) & key_in(29) & key_in(12) & key_in(46) & key_in(22) & key_in(5) & 
				key_in(11) & key_in(28) & key_in(61) & key_in(4) & key_in(36) & key_in(27) & key_in(13) & key_in(38) & 
				key_in(53) & key_in(62) & key_in(20) & key_in(52) & key_in(19) & key_in(37) & key_in(30) & key_in(6);
		
		K4 <= key_in(34) & key_in(10) & key_in(58) & key_in(48) & key_in(8) & key_in(41) & key_in(57) & key_in(16) & 
				key_in(26) & key_in(33) & key_in(43) & key_in(1) & key_in(56) & key_in(59) & key_in(50) & key_in(49) & 
				key_in(32) & key_in(17) & key_in(18) & key_in(25) & key_in(24) & key_in(51) & key_in(42) & key_in(0) & 
				key_in(44) & key_in(54) & key_in(61) & key_in(13) & key_in(27) & key_in(30) & key_in(6) & key_in(52) & 
				key_in(62) & key_in(12) & key_in(45) & key_in(19) & key_in(20) & key_in(11) & key_in(60) & key_in(22) & 
				key_in(37) & key_in(46) & key_in(4) & key_in(36) & key_in(3) & key_in(21) & key_in(14) & key_in(53);
		
		K5 <= key_in(18) & key_in(59) & key_in(42) & key_in(32) & key_in(57) & key_in(25) & key_in(41) & key_in(0) & 
				key_in(10) & key_in(17) & key_in(56) & key_in(50) & key_in(40) & key_in(43) & key_in(34) & key_in(33) & 
				key_in(16) & key_in(1) & key_in(2) & key_in(9) & key_in(8) & key_in(35) & key_in(26) & key_in(49) & 
				key_in(28) & key_in(38) & key_in(45) & key_in(60) & key_in(11) & key_in(14) & key_in(53) & key_in(36) & 
				key_in(46) & key_in(27) & key_in(29) & key_in(3) & key_in(4) & key_in(62) & key_in(44) & key_in(6) & 
				key_in(21) & key_in(30) & key_in(19) & key_in(20) & key_in(54) & key_in(5) & key_in(61) & key_in(37);
		
		K6 <= key_in(2) & key_in(43) & key_in(26) & key_in(16) & key_in(41) & key_in(9) & key_in(25) & key_in(49) & 
				key_in(59) & key_in(1) & key_in(40) & key_in(34) & key_in(24) & key_in(56) & key_in(18) & key_in(17) & 
				key_in(0) & key_in(50) & key_in(51) & key_in(58) & key_in(57) & key_in(48) & key_in(10) & key_in(33) & 
				key_in(12) & key_in(22) & key_in(29) & key_in(44) & key_in(62) & key_in(61) & key_in(37) & key_in(20) & 
				key_in(30) & key_in(11) & key_in(13) & key_in(54) & key_in(19) & key_in(46) & key_in(28) & key_in(53) & 
				key_in(5) & key_in(14) & key_in(3) & key_in(4) & key_in(38) & key_in(52) & key_in(45) & key_in(21);
		
		K7 <= key_in(51) & key_in(56) & key_in(10) & key_in(0) & key_in(25) & key_in(58) & key_in(9) & key_in(33) & 
				key_in(43) & key_in(50) & key_in(24) & key_in(18) & key_in(8) & key_in(40) & key_in(2) & key_in(1) & 
				key_in(49) & key_in(34) & key_in(35) & key_in(42) & key_in(41) & key_in(32) & key_in(59) & key_in(17) & 
				key_in(27) & key_in(6) & key_in(13) & key_in(28) & key_in(46) & key_in(45) & key_in(21) & key_in(4) & 
				key_in(14) & key_in(62) & key_in(60) & key_in(38) & key_in(3) & key_in(30) & key_in(12) & key_in(37) & 
				key_in(52) & key_in(61) & key_in(54) & key_in(19) & key_in(22) & key_in(36) & key_in(29) & key_in(5);
		
		K8 <= key_in(35) & key_in(40) & key_in(59) & key_in(49) & key_in(9) & key_in(42) & key_in(58) & key_in(17) & 
				key_in(56) & key_in(34) & key_in(8) & key_in(2) & key_in(57) & key_in(24) & key_in(51) & key_in(50) & 
				key_in(33) & key_in(18) & key_in(48) & key_in(26) & key_in(25) & key_in(16) & key_in(43) & key_in(1) & 
				key_in(11) & key_in(53) & key_in(60) & key_in(12) & key_in(30) & key_in(29) & key_in(5) & key_in(19) & 
				key_in(61) & key_in(46) & key_in(44) & key_in(22) & key_in(54) & key_in(14) & key_in(27) & key_in(21) & 
				key_in(36) & key_in(45) & key_in(38) & key_in(3) & key_in(6) & key_in(20) & key_in(13) & key_in(52);
		
		K9 <= key_in(56) & key_in(32) & key_in(51) & key_in(41) & key_in(1) & key_in(34) & key_in(50) & key_in(9) & 
				key_in(48) & key_in(26) & key_in(0) & key_in(59) & key_in(49) & key_in(16) & key_in(43) & key_in(42) & 
				key_in(25) & key_in(10) & key_in(40) & key_in(18) & key_in(17) & key_in(8) & key_in(35) & key_in(58) & 
				key_in(3) & key_in(45) & key_in(52) & key_in(4) & key_in(22) & key_in(21) & key_in(60) & key_in(11) & 
				key_in(53) & key_in(38) & key_in(36) & key_in(14) & key_in(46) & key_in(6) & key_in(19) & key_in(13) & 
				key_in(28) & key_in(37) & key_in(30) & key_in(62) & key_in(61) & key_in(12) & key_in(5) & key_in(44);
		
		K10 <= key_in(40) & key_in(16) & key_in(35) & key_in(25) & key_in(50) & key_in(18) & key_in(34) & key_in(58) & 
				key_in(32) & key_in(10) & key_in(49) & key_in(43) & key_in(33) & key_in(0) & key_in(56) & key_in(26) & 
				key_in(9) & key_in(59) & key_in(24) & key_in(2) & key_in(1) & key_in(57) & key_in(48) & key_in(42) & 
				key_in(54) & key_in(29) & key_in(36) & key_in(19) & key_in(6) & key_in(5) & key_in(44) & key_in(62) & 
				key_in(37) & key_in(22) & key_in(20) & key_in(61) & key_in(30) & key_in(53) & key_in(3) & key_in(60) & 
				key_in(12) & key_in(21) & key_in(14) & key_in(46) & key_in(45) & key_in(27) & key_in(52) & key_in(28);
		
		K11 <= key_in(24) & key_in(0) & key_in(48) & key_in(9) & key_in(34) & key_in(2) & key_in(18) & key_in(42) & 
				key_in(16) & key_in(59) & key_in(33) & key_in(56) & key_in(17) & key_in(49) & key_in(40) & key_in(10) & 
				key_in(58) & key_in(43) & key_in(8) & key_in(51) & key_in(50) & key_in(41) & key_in(32) & key_in(26) & 
				key_in(38) & key_in(13) & key_in(20) & key_in(3) & key_in(53) & key_in(52) & key_in(28) & key_in(46) & 
				key_in(21) & key_in(6) & key_in(4) & key_in(45) & key_in(14) & key_in(37) & key_in(54) & key_in(44) & 
				key_in(27) & key_in(5) & key_in(61) & key_in(30) & key_in(29) & key_in(11) & key_in(36) & key_in(12);
		
		K12 <= key_in(8) & key_in(49) & key_in(32) & key_in(58) & key_in(18) & key_in(51) & key_in(2) & key_in(26) & 
				key_in(0) & key_in(43) & key_in(17) & key_in(40) & key_in(1) & key_in(33) & key_in(24) & key_in(59) & 
				key_in(42) & key_in(56) & key_in(57) & key_in(35) & key_in(34) & key_in(25) & key_in(16) & key_in(10) & 
				key_in(22) & key_in(60) & key_in(4) & key_in(54) & key_in(37) & key_in(36) & key_in(12) & key_in(30) & 
				key_in(5) & key_in(53) & key_in(19) & key_in(29) & key_in(61) & key_in(21) & key_in(38) & key_in(28) & 
				key_in(11) & key_in(52) & key_in(45) & key_in(14) & key_in(13) & key_in(62) & key_in(20) & key_in(27);
		
		K13 <= key_in(57) & key_in(33) & key_in(16) & key_in(42) & key_in(2) & key_in(35) & key_in(51) & key_in(10) & 
				key_in(49) & key_in(56) & key_in(1) & key_in(24) & key_in(50) & key_in(17) & key_in(8) & key_in(43) & 
				key_in(26) & key_in(40) & key_in(41) & key_in(48) & key_in(18) & key_in(9) & key_in(0) & key_in(59) & 
				key_in(6) & key_in(44) & key_in(19) & key_in(38) & key_in(21) & key_in(20) & key_in(27) & key_in(14) & 
				key_in(52) & key_in(37) & key_in(3) & key_in(13) & key_in(45) & key_in(5) & key_in(22) & key_in(12) & 
				key_in(62) & key_in(36) & key_in(29) & key_in(61) & key_in(60) & key_in(46) & key_in(4) & key_in(11);
		
		K14 <= key_in(41) & key_in(17) & key_in(0) & key_in(26) & key_in(51) & key_in(48) & key_in(35) & key_in(59) & 
				key_in(33) & key_in(40) & key_in(50) & key_in(8) & key_in(34) & key_in(1) & key_in(57) & key_in(56) & 
				key_in(10) & key_in(24) & key_in(25) & key_in(32) & key_in(2) & key_in(58) & key_in(49) & key_in(43) & 
				key_in(53) & key_in(28) & key_in(3) & key_in(22) & key_in(5) & key_in(4) & key_in(11) & key_in(61) & 
				key_in(36) & key_in(21) & key_in(54) & key_in(60) & key_in(29) & key_in(52) & key_in(6) & key_in(27) & 
				key_in(46) & key_in(20) & key_in(13) & key_in(45) & key_in(44) & key_in(30) & key_in(19) & key_in(62);
		
		K15 <= key_in(25) & key_in(1) & key_in(49) & key_in(10) & key_in(35) & key_in(32) & key_in(48) & key_in(43) & 
				key_in(17) & key_in(24) & key_in(34) & key_in(57) & key_in(18) & key_in(50) & key_in(41) & key_in(40) & 
				key_in(59) & key_in(8) & key_in(9) & key_in(16) & key_in(51) & key_in(42) & key_in(33) & key_in(56) & 
				key_in(37) & key_in(12) & key_in(54) & key_in(6) & key_in(52) & key_in(19) & key_in(62) & key_in(45) & 
				key_in(20) & key_in(5) & key_in(38) & key_in(44) & key_in(13) & key_in(36) & key_in(53) & key_in(11) & 
				key_in(30) & key_in(4) & key_in(60) & key_in(29) & key_in(28) & key_in(14) & key_in(3) & key_in(46);
		
		K16 <= key_in(17) & key_in(58) & key_in(41) & key_in(2) & key_in(56) & key_in(24) & key_in(40) & key_in(35) & 
				key_in(9) & key_in(16) & key_in(26) & key_in(49) & key_in(10) & key_in(42) & key_in(33) & key_in(32) & 
				key_in(51) & key_in(0) & key_in(1) & key_in(8) & key_in(43) & key_in(34) & key_in(25) & key_in(48) & 
				key_in(29) & key_in(4) & key_in(46) & key_in(61) & key_in(44) & key_in(11) & key_in(54) & key_in(37) & 
				key_in(12) & key_in(60) & key_in(30) & key_in(36) & key_in(5) & key_in(28) & key_in(45) & key_in(3) & 
				key_in(22) & key_in(27) & key_in(52) & key_in(21) & key_in(20) & key_in(6) & key_in(62) & key_in(38);
	
		key_ready <= '1';

	end if;
	
end if;
end process;


end Behavioral;
