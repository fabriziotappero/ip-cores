--    This file is part of JTAG_Master.
--
--    JTAG_Master is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    JTAG_Master is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with JTAG_Master.  If not, see <http://www.gnu.org/licenses/>.


----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Andreas Weschenfelder
-- 
-- Create Date:    07:53:01 04/29/2010 
-- Design Name: 
-- Module Name:    JTAG_Ctrl_Master - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity JTAG_Ctrl_Master is
    Generic (
           Addrbreite  : natural := 10;  -- Speicherlänge = 2^Addrbreite
           Wortbreite  : natural := 8
           );
    Port ( 
			  CLK 				: in  STD_LOGIC;
           
			  -- JTAG Part
           BitCount			: in  STD_LOGIC_VECTOR (15 downto 0);
           Shift_Strobe 	: in  STD_LOGIC;								-- eins aktiv...
           TDO 				: in  STD_LOGIC;
           TCK 				: out  STD_LOGIC;
           TMS 				: out  STD_LOGIC;
           TDI 				: out  STD_LOGIC;
           TRst 				: out  STD_LOGIC;
           Busy 				: out  STD_LOGIC;
			  StateStart		: in	 std_logic_vector(3 downto 0);
			  StateEnd			: in	 std_logic_vector(3 downto 0);
			  StateCurrent		: out	 std_logic_vector(3 downto 0);
			  
			  -- Ram Part
           A     				: in  STD_LOGIC_VECTOR (Addrbreite-1 downto 0);
           WR 					: in  STD_LOGIC;
           Din   				: in  STD_LOGIC_VECTOR (Wortbreite-1 downto 0);
           Dout  				: out STD_LOGIC_VECTOR (Wortbreite-1 downto 0)		  
			  );
end JTAG_Ctrl_Master;

architecture Behavioral of JTAG_Ctrl_Master is

	constant TEST_LOGIC_RESET  	: std_logic_vector(3 downto 0) := x"0";
	constant RUN_TEST_IDLE		  	: std_logic_vector(3 downto 0) := x"1";
	constant SELECT_DR			  	: std_logic_vector(3 downto 0) := x"2";
	constant CAPTURE_DR			  	: std_logic_vector(3 downto 0) := x"3";
	constant SHIFT_DR				  	: std_logic_vector(3 downto 0) := x"4";
	constant EXIT1_DR				  	: std_logic_vector(3 downto 0) := x"5";
	constant PAUSE_DR				  	: std_logic_vector(3 downto 0) := x"6";
	constant EXIT2_DR				  	: std_logic_vector(3 downto 0) := x"7";
	constant UPDATE_DR			 	: std_logic_vector(3 downto 0) := x"8";
	constant SELECT_IR			  	: std_logic_vector(3 downto 0) := x"9";
	constant CAPTURE_IR			  	: std_logic_vector(3 downto 0) := x"A";
	constant SHIFT_IR				  	: std_logic_vector(3 downto 0) := x"B";
	constant EXIT1_IR				  	: std_logic_vector(3 downto 0) := x"C";
	constant PAUSE_IR				  	: std_logic_vector(3 downto 0) := x"D";
	constant EXIT2_IR				  	: std_logic_vector(3 downto 0) := x"E";
	constant UPDATE_IR			 	: std_logic_vector(3 downto 0) := x"F";
	
--Signal fuer MainThread
	type TypeStateJTAGMaster is ( State_IDLE, State_TapToStart, State_Shift, State_TapToEnd, State_TapToEnd2 ); 
	signal StateJTAGMaster : TypeStateJTAGMaster := State_IDLE;
	
--Signal fuer TMS
	signal int_TMS_CurrState 	: std_logic_vector(3 downto 0) := TEST_LOGIC_RESET;
	signal int_TMS_StateIn	 	: std_logic_vector(3 downto 0);
	signal int_TMS_SoftResetCnt	: std_logic_vector(3 downto 0) := "0000";
	type TypeTMSStates is (idle, prepare_for_working, working_normal1, working_normal2, working_normal3 , 
									working_softreset1, working_softreset2, working_softreset3 );
	signal TMSState : TypeTMSStates := idle;
	
--Signal fuer TDI/TDO
	type TypeShiftStates is (idle, prepare_for_working, shifting1, shifting2, shifting3, shifting4 );
	signal ShiftState : TypeShiftStates := idle;
	signal int_BitCount				:	std_logic_vector( 15 downto 0 );
	
	
-- Speicher für SampleOut/SampleIn
	component RAM is
    Generic (
           Addrbreite  : natural := 10;  -- Speicherlänge = 2^Addrbreite
           Wortbreite  : natural := 8
           );
    Port ( clk   : in  STD_LOGIC;
           Write : in  STD_LOGIC;
           Awr   : in  STD_LOGIC_VECTOR (Addrbreite-1 downto 0);
           Ard   : in  STD_LOGIC_VECTOR (Addrbreite-1 downto 0);
           Din   : in  STD_LOGIC_VECTOR (Wortbreite-1 downto 0);
           Dout  : out STD_LOGIC_VECTOR (Wortbreite-1 downto 0)
         );
	end component;
	
	signal BRAM_adr 		: std_logic_vector(Addrbreite-1 downto 0);
	signal BRAM_Din 		: std_logic_vector(Wortbreite-1 downto 0);
	signal BRAM_Dout 		: std_logic_vector(Wortbreite-1 downto 0);
	signal BRAM_WR			: std_logic := '0';

begin

	StateCurrent <= int_TMS_CurrState;
	
	
	JTAG_BRAM : RAM
    Port Map ( 
				clk  => CLK,
           Write => BRAM_WR,
           Awr   => BRAM_adr,
           Ard   => BRAM_adr,
           Din   => BRAM_Din,
           Dout  => BRAM_Dout
         );
	

	Process ( CLK )
	begin
	
		if rising_edge( CLK ) then
		
		TRST <= '1';
		
		
	------------------------------------------
	-- BlockRAM Steuerung
	------------------------------------------
			Dout <= BRAM_Dout;
			if ShiftState = idle then
				BRAM_adr <= A;	
			else
				BRAM_adr <= int_BitCount(12 downto 3);
			end if;
			
------------------------------------------
-- Main Thread
------------------------------------------			
			case StateJTAGMaster is
			
				when State_IDLE =>
						
					Busy <= '0';
						
					if (Shift_Strobe='1') then
						Busy <= '1';
						int_TMS_StateIn <= StateStart;
						TMSState <= prepare_for_working;
						StateJTAGMaster <= State_TapToStart;
					end if;
					
					BRAM_WR <= WR;
					BRAM_Din <= Din;				
					
				when State_TapToStart =>
					
					if (TMSState = idle) then
						StateJTAGMaster <= State_Shift;
						ShiftState <= prepare_for_working; 						
					end if;
				
				when State_Shift =>
				
					if ShiftState = idle then
						int_TMS_StateIn <= StateEnd;
						TMSState <= prepare_for_working;
						StateJTAGMaster <= State_TapToEnd;
					end if;
				
				when State_TapToEnd =>
				
					if (TMSState = idle) then
						Busy <= '0';
						StateJTAGMaster <= State_TapToEnd2;
					end if;
				
				when State_TapToEnd2 =>
					if (Shift_Strobe='0') then
						StateJTAGMaster <= State_IDLE;
					end if;
				
				when others =>				
					StateJTAGMaster <= State_IDLE;
			end case;
			
			
			
		


---------------------------------------------------------------------------------------
-- Control data shifting to/from of device
---------------------------------------------------------------------------------------
				
			case ShiftState is
				when idle =>				
				
				when prepare_for_working =>
					
					if BitCount = "0000000000000000" then
						ShiftState <= idle;
					else 
						ShiftState <= shifting1;
						int_BitCount <= (others => '0');
					end if;
									
				when shifting1 =>
					-- TMS: Letztes Bit, bei TMS-Statewechsel setzen...
					if BitCount = (int_BitCount+1) then
						if (int_TMS_CurrState /= StateEnd) then
							TMS <= '1';
							int_TMS_CurrState <= int_TMS_CurrState + 1;
						end if;
					end if;
					-- TDI schieben
					TDI <= BRAM_Dout(CONV_INTEGER( int_BitCount ) mod 8);
				
					ShiftState <= shifting2;
					
				when shifting2 =>
					TCK <= '0';
					ShiftState <= shifting3;
					
				when shifting3 =>
					-- TDO schieben
					ShiftState <= shifting4;				
					BRAM_Din <= BRAM_Dout;
					BRAM_Din(CONV_INTEGER( int_BitCount ) mod 8) <= TDO;
					BRAM_WR <= '1';
					
				when shifting4 =>
				
					BRAM_WR <= '0';
				
					TCK <= '1';
					if BitCount = (int_BitCount+1) then
						ShiftState <= idle;
					else
						ShiftState <= shifting1;
						int_BitCount <= int_BitCount + 1;
					end if;

				when others =>
					ShiftState <= idle;			
			end  case;
			




---------------------------------------------------------------------------------------
-- Control TAP state of device
---------------------------------------------------------------------------------------
			case TMSState is
				
				when idle =>
						

				when prepare_for_working =>
									

							
					if (int_TMS_CurrState /= int_TMS_StateIn) then
						TMSState <= working_normal1;
					else
						if ( int_TMS_StateIn = TEST_LOGIC_RESET ) then
							TMSState <= working_softreset1; 
						else
							-- already in state -> do nothing
							TMSState <= idle;
						end if;
					end if;				
				
				when working_normal1 =>
		
					case int_TMS_CurrState is
					
						when TEST_LOGIC_RESET =>
							if int_TMS_StateIn = TEST_LOGIC_RESET then
								TMS <= '1';
								int_TMS_CurrState <= TEST_LOGIC_RESET;
							else
								TMS <= '0';
								int_TMS_CurrState <= RUN_TEST_IDLE;	
							end if;
							
						when RUN_TEST_IDLE =>
							if int_TMS_StateIn = RUN_TEST_IDLE then
								TMS <= '0';
								int_TMS_CurrState <= RUN_TEST_IDLE;
							else
								TMS <= '1';
								int_TMS_CurrState <= SELECT_DR;
							end if;
								
						when SELECT_DR =>
							if ( int_TMS_StateIn = TEST_LOGIC_RESET ) 	or
								( int_TMS_StateIn = RUN_TEST_IDLE ) 		or
								( int_TMS_StateIn = SELECT_IR ) 			or 
								( int_TMS_StateIn = CAPTURE_IR ) 			or 
								( int_TMS_StateIn = SHIFT_IR ) 			or 
								( int_TMS_StateIn = EXIT1_IR ) 			or 
								( int_TMS_StateIn = PAUSE_IR ) 			or 
								( int_TMS_StateIn = EXIT2_IR ) 			or
								( int_TMS_StateIn = UPDATE_IR ) 			then
								TMS <= '1';
								int_TMS_CurrState <= SELECT_IR;
							else 
								TMS <= '0';
								int_TMS_CurrState <= CAPTURE_DR;
							end if;
												
						when CAPTURE_DR =>
							if int_TMS_StateIn = EXIT1_DR then
								TMS <= '1';
								int_TMS_CurrState <= EXIT1_DR;	
							else 
								TMS <= '0';
								int_TMS_CurrState <= SHIFT_DR;
							end if;
							
						when SHIFT_DR =>
							if int_TMS_StateIn = SHIFT_DR then
								TMS <= '0';
								int_TMS_CurrState <= SHIFT_DR;
							else
								TMS <= '1';
								int_TMS_CurrState <= EXIT1_DR;
							end if;
								
						when EXIT1_DR =>
							if int_TMS_StateIn = UPDATE_DR then
								TMS <= '1';
								int_TMS_CurrState <= UPDATE_DR;
							else
								TMS <= '0';
								int_TMS_CurrState <= PAUSE_DR;
							end if;
							
						when PAUSE_DR =>
							if int_TMS_StateIn = PAUSE_DR then
								TMS <= '0';
								int_TMS_CurrState <= PAUSE_DR;
							else
								TMS <= '1';
								int_TMS_CurrState <= EXIT2_DR;
							end if;
								
						when EXIT2_DR =>
							if int_TMS_StateIn = SHIFT_DR then
								TMS <= '0';
								int_TMS_CurrState <= SHIFT_DR;
							else
								TMS <= '1';
								int_TMS_CurrState <= UPDATE_DR;
							end if;
							
						when UPDATE_DR =>
							if int_TMS_StateIn = RUN_TEST_IDLE then
								TMS <= '0';
								int_TMS_CurrState <= RUN_TEST_IDLE; 
							else 
								TMS <= '1';
								int_TMS_CurrState <= SELECT_DR;
							end if;
								
						when SELECT_IR =>
							if int_TMS_StateIn = TEST_LOGIC_RESET then
								TMS <= '1';
								int_TMS_CurrState <= TEST_LOGIC_RESET;
							else
								TMS <= '0';
								int_TMS_CurrState <= CAPTURE_IR;							
							end if;

						when CAPTURE_IR =>
							if int_TMS_StateIn = EXIT1_IR then
								TMS <= '1';
								int_TMS_CurrState <= EXIT1_IR;	
							else 
								TMS <= '0';
								int_TMS_CurrState <= SHIFT_IR;
							end if;
							
						when SHIFT_IR =>
							if int_TMS_StateIn = SHIFT_IR then
								TMS <= '0';
								int_TMS_CurrState <= SHIFT_IR;
							else
								TMS <= '1';
								int_TMS_CurrState <= EXIT1_IR;
							end if;
								
						when EXIT1_IR =>
							if int_TMS_StateIn = UPDATE_IR then
								TMS <= '1';
								int_TMS_CurrState <= UPDATE_IR;
							else
								TMS <= '0';
								int_TMS_CurrState <= PAUSE_IR;
							end if;
							
						when PAUSE_IR =>
							if int_TMS_StateIn = PAUSE_IR then
								TMS <= '0';
								int_TMS_CurrState <= PAUSE_IR;
							else
								TMS <= '1';
								int_TMS_CurrState <= EXIT2_IR;
							end if;
								
						when EXIT2_IR =>
							if int_TMS_StateIn = SHIFT_IR then
								TMS <= '0';
								int_TMS_CurrState <= SHIFT_IR;
							else
								TMS <= '1';
								int_TMS_CurrState <= UPDATE_IR;
							end if;
							
						when UPDATE_IR =>
							if int_TMS_StateIn = RUN_TEST_IDLE then
								TMS <= '0';
								int_TMS_CurrState <= RUN_TEST_IDLE; 
							else 
								TMS <= '1';
								int_TMS_CurrState <= SELECT_DR;
							end if;									
						
						when others =>
							int_TMS_CurrState <= TEST_LOGIC_RESET;
					
					end case;
					
					TMSState <= working_normal2;

				when working_normal2 =>
					TCK <= '0';
					TMSState <= working_normal3;

				when working_normal3 =>
					
					TCK <= '1';
					
					if (int_TMS_CurrState = int_TMS_StateIn) then 
						TMSState <= idle; 
					else
						TMSState <= working_normal1;
					end if;
						

				when working_softreset1 =>					
					TMS <= '1';
					int_TMS_SoftResetCnt <= "0101";
					TMSState <= working_softreset2;

				when working_softreset2 =>	
					TCK <= '0';
					TMSState <= working_softreset3;
					
				when working_softreset3 =>	

					TCK <= '1';
					int_TMS_SoftResetCnt <= int_TMS_SoftResetCnt - 1;
					
					if (int_TMS_SoftResetCnt > "0000") then
						TMSState <= working_softreset2;
					else
						int_TMS_CurrState <= TEST_LOGIC_RESET;
						TMSState <= idle; 
					end if;
			
				when others => 
					TMSState <= idle;
				
			end case;	


		
		end if;
		
				
		
	End Process;


end Behavioral;

