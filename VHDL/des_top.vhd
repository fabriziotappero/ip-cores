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
-- Title       : des_top
-- Company     : CoreTex Systems, LLC
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity des_top is
port (

		-- input/output core signals
		key_round_in:	in 	std_logic_vector(0 to 47);
		data_in:			in 	std_logic_vector(0 to 63);
		data_out:		out 	std_logic_vector(0 to 63);
		
		-- signals for communication with key expander module
		KeySelect: 		inout std_logic_vector(3 downto 0);		-- selector for key
		key_ready: 		in std_logic;						-- active high when key is ready
		data_ready: 	in std_logic;						-- active high when data is ready
		func_select:   in std_logic;						-- encryption/decryption flag

		des_out_rdy: out std_logic;						-- active high when decrypted/encrypted data are ready
		core_busy: out std_logic;							-- active high when core is in process of encryption

		reset: in std_logic; 								-- master reset
		clock: in std_logic  								-- master clock
		);
end des_top;

architecture Behavioral of des_top is

--
-- BLOCK_TOP entity performs encryption/deccryption operation. It uses expaned key for that process
--
component block_top is
port(
		L_in: in std_logic_vector(0 to 31);				-- left permuted input
		R_in: in std_logic_vector(0 to 31);				-- right permuted input
	
		L_out: out std_logic_vector(0 to 31);			-- left permuted output
		R_out: out std_logic_vector(0 to 31);			-- right permuted output

		round_key_des: in std_logic_vector(0 to 47)	-- current round key

	);
end component;

--
-- Internal DES_TOP signals
--
signal L_in_internal, R_in_internal: 	std_logic_vector(0 to 31);
signal L_out_internal, R_out_internal: std_logic_vector(0 to 31);
type statetype is (WaitKey, WaitData, InitialRound, RepeatRound, FinalRound);
signal nextstate: statetype;
signal RoundCounter: 						std_logic_vector(3 downto 0);

begin

--
-- Finite state machine
--
process (clock)
begin
	if rising_edge(clock)  then	
		if reset = '1' then
			--
			-- Reset all signal to inital values
			--
			nextstate 				<= WaitKey;	  
			RoundCounter			<= "0000";	  
			core_busy				<= '0';				-- core is in reset state: not busy
			des_out_rdy				<= '0';				-- output data is not ready
			
		else
		
			case nextstate is

				--
				-- WaitKey: wait for key to be expanded
				--
				when WaitKey =>

					-- wait until key has been expanded
					if key_ready = '0' then
						nextstate	<= WaitKey;
					else
						nextstate	<= WaitData;
					end if;
					
					core_busy				<= '0';				-- core waits for the key: not busy
					des_out_rdy				<= '0';				-- output data is not ready
								
				--
				-- WaitData: waits for data until it is ready
				--
				when WaitData =>

					-- wait for data to be loaded in input registers
					if (data_ready = '0') then

						nextstate				<= WaitData;

					else
						core_busy				<= '1';				-- core is processing = busy 
						
						L_in_internal <= 	data_in(57) & data_in(49) & data_in(41) & data_in(33) & data_in(25) & data_in(17) & 
												data_in(9) & data_in(1) & data_in(59) & data_in(51) & data_in(43) & data_in(35) & 
												data_in(27) & data_in(19) & data_in(11) & data_in(3) & data_in(61) & data_in(53) & 
												data_in(45) & data_in(37) & data_in(29) & data_in(21) & data_in(13) & data_in(5) & 
												data_in(63) & data_in(55) & data_in(47) & data_in(39) & data_in(31) & data_in(23) & 
												data_in(15) & data_in(7);
						
						R_in_internal <= 	data_in(56) & data_in(48) & data_in(40) & data_in(32) & data_in(24) & data_in(16) & 
												data_in(8) & data_in(0) & data_in(58) & data_in(50) & data_in(42) & data_in(34) & 
												data_in(26) & data_in(18) & data_in(10) & data_in(2) & data_in(60) & data_in(52) & 
												data_in(44) & data_in(36) & data_in(28) & data_in(20) & data_in(12) & data_in(4) & 
												data_in(62) & data_in(54) & data_in(46) & data_in(38) & data_in(30) & data_in(22) & 
												data_in(14) & data_in(6);												
						
						nextstate		<= InitialRound;
						
						-- function select (decrypting/encrypting) will determine key selection
						if func_select = '1' then
							KeySelect	<= "0000";
						else
							KeySelect	<= "1111";
						end if;

					end if;						
		
				--
				-- Initial State where input is equal to a block that we need to encode
				--
				when InitialRound =>
							
						L_in_internal 	<= L_out_internal;
						R_in_internal 	<= R_out_internal;
						
						-- fuction select determines direction of key selection
						if func_select = '1' then
							KeySelect 	<= KeySelect + '1';
						else
							KeySelect 	<= KeySelect - '1';
						end if;

						nextstate 		<= RepeatRound;

				--
				-- Repeat Section, where input is output from prevous state
				--
				when RepeatRound =>
				
						L_in_internal <= L_out_internal;
						R_in_internal <= R_out_internal;	

						-- fuction select determines direction of key selection
						if func_select = '1' then
							KeySelect <= KeySelect + '1';
						else
							KeySelect <= KeySelect - '1';
						end if; 
						
						RoundCounter <= RoundCounter + '1'; 

						-- if finished with all rounds, go to the final round
						if RoundCounter = x"E" then

							-- perform inverse initial permutation
							data_out	<=	L_out_internal(7) & R_out_internal(7) & L_out_internal(15) & R_out_internal(15) & 
											L_out_internal(23) & R_out_internal(23) & L_out_internal(31) & R_out_internal(31) & 
											L_out_internal(6) & R_out_internal(6) & L_out_internal(14) & R_out_internal(14) & 
											L_out_internal(22) & R_out_internal(22) & L_out_internal(30) & R_out_internal(30) & 
											L_out_internal(5) & R_out_internal(5) & L_out_internal(13) & R_out_internal(13) & 
											L_out_internal(21) & R_out_internal(21) & L_out_internal(29) & R_out_internal(29) & 
											L_out_internal(4) & R_out_internal(4) & L_out_internal(12) & R_out_internal(12) & 
											L_out_internal(20) & R_out_internal(20) & L_out_internal(28) & R_out_internal(28) & 
											L_out_internal(3) & R_out_internal(3) & L_out_internal(11) & R_out_internal(11) & 
											L_out_internal(19) & R_out_internal(19) & L_out_internal(27) & R_out_internal(27) & 
											L_out_internal(2) & R_out_internal(2) & L_out_internal(10) & R_out_internal(10) & 
											L_out_internal(18) & R_out_internal(18) & L_out_internal(26) & R_out_internal(26) & 
											L_out_internal(1) & R_out_internal(1) & L_out_internal(9) & R_out_internal(9) & 
											L_out_internal(17) & R_out_internal(17) & L_out_internal(25) & R_out_internal(25) & 
											L_out_internal(0) & R_out_internal(0) & L_out_internal(8) & R_out_internal(8) & 
											L_out_internal(16) & R_out_internal(16) & L_out_internal(24) & R_out_internal(24);

							core_busy				<= '0';		-- core is not busy
							des_out_rdy				<= '1';		-- output data is ready
							nextstate 				<= FinalRound;

						else

							-- Continue with regular rounds
							nextstate <= RepeatRound;

						end if;

				--
				-- Last round
				--
				when FinalRound =>					

					RoundCounter 			<= "0000";
					nextstate 				<= WaitKey; 
					des_out_rdy				<= '0';		-- deselect out data ready signal 

				when others =>
					-- should never happen
			end case;	
		end if;
	end if;	
end process;

--
-- Instantations
--
BLOCKTOP: block_top 
port map (
		L_in 				=> L_in_internal,
		R_in 				=> R_in_internal,

		round_key_des 	=> key_round_in,	

		L_out 			=> L_out_internal,
		R_out 			=>	R_out_internal	

);

end Behavioral;
