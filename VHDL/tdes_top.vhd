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
----------------------------------------------------------------------
--
-- Title       : tdes_top
-- Company     : CoreTex Systems, LLC
--
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tdes_top is
port(
		--
		-- inputs for key expander
		--
		key1_in:		in std_logic_vector(0 to 63);
		key2_in:		in std_logic_vector(0 to 63);
		key3_in:		in std_logic_vector(0 to 63);
		
		-- 
		-- function	select
		--
		function_select:	in	std_logic; -- active when encryption, inactive when decryption
		
		--
		-- input into des_cipher_top 
		--		
		data_in:		in std_logic_vector(0 to 63);
		
		--
		-- input into des_cipher_top 
		--		
		data_out:	out std_logic_vector(0 to 63);

		--
		-- data interface to MCU
		--
		lddata:			in 	std_logic;	-- active when data for loading is ready
		ldkey:			in 	std_logic;	-- active when key for loading is ready
		out_ready:	out	std_logic;	-- active when encryption of data is done	

		--
		-- General clock and reset
		--
		reset: in std_logic;
		clock: in std_logic
	);
end tdes_top;

architecture Behavioral of tdes_top is

component des_cipher_top is
port(
		--
		-- inputs for key expander
		--
		key_in:		in std_logic_vector(0 to 63);	-- interface to MCU
		--ldkey: 		in std_logic;						-- active signal for loading keys

		-- 
		-- function	select
		--
		function_select:	in	std_logic; -- active when encryption, inactive when decryption
		
		--
		-- input into des_cipher_top 
		--		
		data_in:		in std_logic_vector(0 to 63);
		
		--
		-- input into des_cipher_top 
		--		
		data_out:	out std_logic_vector(0 to 63);

		--
		-- data interface to MCU
		--
		lddata:			in 	std_logic;	-- active when data for loading is ready
		des_out_rdy:	out	std_logic;	-- active when encryption of data is done	

		--
		-- General clock and reset
		--
		reset: in std_logic;
		clock: in std_logic
	);
end component;

type statetype is (WaitKeyState, WaitDataState);
signal nextstate: statetype;
signal key1_in_internal: std_logic_vector(0 to 63);
signal key2_in_internal: std_logic_vector(0 to 63);
signal key3_in_internal: std_logic_vector(0 to 63);
signal memkey1: std_logic_vector(0 to 63);
signal memkey3: std_logic_vector(0 to 63);
signal fsel_internal: std_logic;
signal fsel_internal_inv: std_logic;
signal des_out_rdy_internal: std_logic;
signal des_out_rdy_internal1: std_logic; 
signal des_out_rdy_internal2: std_logic;
signal data_in_internal: std_logic_vector(0 to 63);
signal data_out_internal: std_logic_vector(0 to 63);
signal data_out_internal1: std_logic_vector(0 to 63);
signal data_out_internal2: std_logic_vector(0 to 63);
signal lddata_internal: std_logic;

begin

process (clock)
begin
if rising_edge(clock) then
	if reset = '1' then
		nextstate		<= WaitKeyState;
		lddata_internal		<= '0';
		out_ready		<= '0'; 
		fsel_internal		<= function_select;
		fsel_internal_inv	<= not function_select;
	else
		data_out				<= data_out_internal;
		out_ready				<= des_out_rdy_internal;

		case nextstate is
			--
			-- wait key state
			--
			when WaitKeyState =>	
				-- wait until key is ready (as well as the function_select)
				if ldkey = '0' then
					nextstate		<= WaitKeyState;
				else
					key1_in_internal	<= key1_in;					
					key2_in_internal	<= key2_in;
					key3_in_internal	<= key3_in;
					memkey1			<= key1_in;
					memkey3			<= key3_in;
					nextstate		<= WaitDataState;
				end if;
			--
			-- wait data state
			--
			when WaitDataState =>
				-- wait until data is ready to be loaded
				if lddata = '0' then
					nextstate	<= WaitDataState;
					lddata_internal		<= '0';
				else
					lddata_internal		<= '1';
					if fsel_internal = '0' then
						key1_in_internal <= memkey3;
						key3_in_internal <= memkey1;
					end if;
					data_in_internal	<= data_in;
					nextstate		<= WaitDataState;
				end if;

		end case;
	end if;
end if;
end process;


DESCIPHERTOP1: des_cipher_top 
port map (
		key_in => key1_in_internal, -- interface to MCU
		
		function_select => fsel_internal, -- active when encryption, inactive when decryption
		
		data_in => data_in_internal,
		
		data_out => data_out_internal1,

		lddata => lddata_internal,	-- active when data for loading is ready
		des_out_rdy => des_out_rdy_internal1,	-- active when encryption of data is done	

		reset => reset,
		clock =>	clock
);

DESCIPHERTOP2: des_cipher_top 
port map (
		key_in => key2_in_internal, --subkey_in_internal,	-- interface to MCU
		
		function_select => fsel_internal_inv, -- active when encryption, inactive when decryption
		
		data_in => data_out_internal1,
		
		data_out => data_out_internal2,

		lddata => des_out_rdy_internal1,	-- active when data for loading is ready
		des_out_rdy => des_out_rdy_internal2,	-- active when encryption of data is done	

		reset => reset,
		clock =>	clock
);

DESCIPHERTOP3: des_cipher_top 
port map (
		key_in => key3_in_internal, -- subkey_in_internal,	-- interface to MCU
		
		function_select => fsel_internal, -- active when encryption, inactive when decryption
		
		data_in => data_out_internal2,
		
		data_out => data_out_internal,

		lddata => des_out_rdy_internal2,	-- active when data for loading is ready
		des_out_rdy => des_out_rdy_internal,	-- active when encryption of data is done	

		reset => reset,
		clock =>	clock
);

end Behavioral;
