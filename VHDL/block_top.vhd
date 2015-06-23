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
-- Title       : block_top
-- Company     : CoreTex Systems, LLC
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity block_top is
port(
		--
		-- input into top level block
		--
		L_in: in std_logic_vector(0 to 31);
		R_in: in std_logic_vector(0 to 31);
	
		--
		-- output from top level block
	   --
		L_out: out std_logic_vector(0 to 31);
		R_out: out std_logic_vector(0 to 31);

     	--
		-- expanded key from key block
		--
		round_key_des: in std_logic_vector(0 to 47)	-- current round key

	);
end block_top;

architecture Behavioral of block_top is
--
-- DECLARATION OF MODULES IN THE BLOCK_TOP
--

--
--  E _ E X P A N S I O N _ F U N C T I O N
--
component e_expansion_function
	port(
	    	x_in: in std_logic_vector(0 to 31);
    		block0_out: out std_logic_vector(0 to 5);
			block1_out: out std_logic_vector(0 to 5);
			block2_out: out std_logic_vector(0 to 5);
			block3_out: out std_logic_vector(0 to 5);
			block4_out: out std_logic_vector(0 to 5);
			block5_out: out std_logic_vector(0 to 5);
			block6_out: out std_logic_vector(0 to 5);
			block7_out: out std_logic_vector(0 to 5)
 	);
end component;

--
--  A D D _ K E Y
--
component add_key
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
end component;

--
--  S _ B O X
--
component s_box
	port(
    		block0_in: in std_logic_vector(5 downto 0);
			block1_in: in std_logic_vector(5 downto 0);
			block2_in: in std_logic_vector(5 downto 0);
			block3_in: in std_logic_vector(5 downto 0);
			block4_in: in std_logic_vector(5 downto 0);
			block5_in: in std_logic_vector(5 downto 0);
			block6_in: in std_logic_vector(5 downto 0);
			block7_in: in std_logic_vector(5 downto 0);
			x0_out: out std_logic_vector(3 downto 0);
			x1_out: out std_logic_vector(3 downto 0);
			x2_out: out std_logic_vector(3 downto 0);
			x3_out: out std_logic_vector(3 downto 0);
			x4_out: out std_logic_vector(3 downto 0);
			x5_out: out std_logic_vector(3 downto 0);
			x6_out: out std_logic_vector(3 downto 0);
			x7_out: out std_logic_vector(3 downto 0)
 	);
end component;

--
--  P _ B O X
--
component p_box
	port(
    		x0_in: in std_logic_vector(3 downto 0);
			x1_in: in std_logic_vector(3 downto 0);
			x2_in: in std_logic_vector(3 downto 0);
			x3_in: in std_logic_vector(3 downto 0);
			x4_in: in std_logic_vector(3 downto 0);
			x5_in: in std_logic_vector(3 downto 0);
			x6_in: in std_logic_vector(3 downto 0);
			x7_in: in std_logic_vector(3 downto 0);
			x_out: out std_logic_vector(0 to 31)
 	);
end component;

--
--  A D D _ L E F T
--
component add_left
	port(
    		x_in: in std_logic_vector(0 to 31);
			left_in: in std_logic_vector(0 to 31);
			x_out: out std_logic_vector(0 to 31)
 	);
end component;


--
-- Signals that connects modules within block_top
--
signal a0, a1, a2, a3, a4, a5, a6, a7: std_logic_vector(0 to 5);
signal b0, b1, b2, b3, b4, b5, b6, b7: std_logic_vector(5 downto 0);
signal c0, c1, c2, c3, c4, c5, c6, c7: std_logic_vector(3 downto 0);
signal d0: std_logic_vector(0 to 31);
signal R_out_internal: std_logic_vector(0 to 31);

begin

L_out <= R_in;
R_out <= R_out_internal;

--
-- INSTANTIATION OF E_EXPANSIONFUNCTION
--
E_EXPANSIONFUNCTION : e_expansion_function
port map (
			x_in => R_in,   		
			block0_out => a0,
    		block1_out => a1,
			block2_out => a2,
			block3_out => a3,
			block4_out => a4,
			block5_out => a5,
			block6_out => a6,
			block7_out => a7
);

--
-- INSTANTIATION OF ADDKEY
--
ADDKEY : add_key
port map (
			x0_in => a0,
    		x1_in => a1,
			x2_in => a2,
			x3_in => a3,
			x4_in => a4,
			x5_in => a5,
			x6_in => a6,
			x7_in => a7,
			key => round_key_des,
			x0_out => b0,
    		x1_out => b1,
			x2_out => b2,
			x3_out => b3,
			x4_out => b4,
			x5_out => b5,
			x6_out => b6,
			x7_out => b7
);

--						 
-- INSTANTIATION OF SBOX 
--
SBOX : s_box
port map (
			block0_in => b0,
    		block1_in => b1,
			block2_in => b2,
			block3_in => b3,
			block4_in => b4,
			block5_in => b5,
			block6_in => b6,
			block7_in => b7,
			x0_out =>  c0,
			x1_out =>  c1,
			x2_out =>  c2,
			x3_out =>  c3,
			x4_out =>  c4,
			x5_out =>  c5,
			x6_out =>  c6,
			x7_out =>  c7
);

--						 
-- INSTANTIATION OF PBOX 
--
PBOX : p_box
port map (
			x0_in => c0,
			x1_in => c1,
			x2_in => c2,
			x3_in => c3,
			x4_in => c4,
			x5_in => c5,
			x6_in => c6,
			x7_in => c7,
			x_out => d0
);


--						 
-- INSTANTIATION OF ADDLEFT 
--
ADDLEFT : add_left
port map (
			x_in => d0,
			left_in => L_in,
			x_out => R_out_internal
);


end Behavioral;
