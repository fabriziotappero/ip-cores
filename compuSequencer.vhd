----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:03:49 06/11/2009 
-- Design Name: 
-- Module Name:    compuSequencer - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity compuSequencer is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  tableReady : in STD_LOGIC;
			  computeDone : in STD_LOGIC;
			  featureDataStrobe : out STD_LOGIC;
			  acknowledge : in STD_LOGIC;
			  indexMax : in  STD_LOGIC_VECTOR (9 downto 0);
           eqData : in  STD_LOGIC_VECTOR (9 downto 0);
           eqAddress : out  STD_LOGIC_VECTOR (9 downto 0);
           compuCode : out  STD_LOGIC_VECTOR (9 downto 0);
			  cntObjects : out  STD_LOGIC_VECTOR (9 downto 0);
           mergeEnable : out  STD_LOGIC;
           compute : buffer  STD_LOGIC;
           tablePreset : out  STD_LOGIC);
end compuSequencer;

architecture Behavioral of compuSequencer is

	signal mergeAddressDelayed, calcAddressDelayed : std_logic_vector(9 downto 0);
	signal mergeAddress, calcAddress, calcCode, mergeCode : std_logic_vector(9 downto 0);
	signal runCalc, computeDoneDelay : std_logic;
	
	type calc_state_type is (idle, initSearch, objectSearch, waitOnCompute1, waitOnCompute2, waitOnCompute3, waitOnComm1, waitOnComm2, waitOnComm3); --state declaration
							
	signal calc_state : calc_state_type := idle;
	
begin

	eqAddress <= calcAddress when runCalc = '1' else mergeAddress;
	compuCode <= calcCode when runCalc = '1' else mergeCode;

	resolve: process(clk,reset) 
		variable cnt : std_logic_vector(9 downto 0) := (others=>'0');
		variable destination : std_logic_vector(9 downto 0) := (others=>'0');
		variable cindex : std_logic_vector(10 downto 0) := (others=>'1');
		variable found : boolean := false;
		
		begin
			if reset = '1' then
				cindex := conv_std_logic_vector(1,11);
				mergeAddress <= cindex(9 downto 0);
				cnt := (others=>'0');
				mergeCode <= (others=>'0');
				mergeEnable <= '0';
				found := false;
				runCalc <= '0';
			elsif clk'event and clk = '1' then
				mergeCode <= (others=>'0');
				mergeEnable <= '0';
				if tableReady = '0' then
					cindex := conv_std_logic_vector(1,11);
					mergeAddress <= cindex(9 downto 0);
					cnt := (others=>'0');
					found := false;
					runCalc <= '0';
					
				else
					if cindex < indexMax+1 then
						if mergeAddressDelayed /= eqData and cindex > 1 and not found then
							cnt := cnt + 1;
							--mergeDest <= eqData;
							mergeCode <= mergeAddressDelayed;
							destination := eqData;
							--mergeEnable <= '1';
							found := true;
						elsif found then
							found := false;
							cindex := cindex + 1;
							mergeCode <= destination;
							mergeEnable <= '1';
						else
							cindex := cindex + 1;
						end if;
					elsif cindex = indexMax+1 then
						runCalc <= '1';
						cntObjects <= indexMax - cnt - 1;
						cindex := cindex + 1;
					end if;
				mergeAddressDelayed <= mergeAddress;
				mergeAddress <= cindex(9 downto 0);
				end if;
			end if;
				
		end process resolve;
		

calc: process(clk,reset) 
		variable cindex : std_logic_vector(10 downto 0) := (others=>'1');
		begin
			if reset = '1' then
				cindex := conv_std_logic_vector(1,11);
				calcAddress <= cindex(9 downto 0);
				tablePreset <= '0';
				compute <= '0';
				calcCode <= (others=>'0');
				
			elsif clk'event and clk = '1' then

				case calc_state is
					when idle => 
							tablePreset <= '0';
							compute <= '0';
							featureDataStrobe <= '0';
							calcCode <= (others=>'0');
					when initSearch => 
							cindex := conv_std_logic_vector(1,11);
							calcAddress <= cindex(9 downto 0);
							tablePreset <= '0';
							compute <= '0';
							featureDataStrobe <= '0';
							calcCode <= (others=>'0');
							if computeDone = '1' then
								calc_state <= objectSearch;
							end if;
					when objectSearch =>
							compute <= '0';
							if cindex < indexMax then
								if calcAddressDelayed = eqData and cindex >= 1 then
									calcCode <= calcAddressDelayed;
									compute <= '1';
									calc_state <= waitOnCompute1;
								end if;
								cindex := cindex + 1;
							else
								tablePreset <= '1';
								calc_state <= idle;
							end if;
					when waitOnCompute1 =>
							compute <= '0';
							calc_state <= waitOnCompute2;
							if calcAddressDelayed = eqData and eqData /=calcCode then--for two objects on consecutive codes
							   cindex:= cindex-1;
							end if;
					when waitOnCompute2 =>
							compute <= '0';
							calc_state <= waitOnCompute3;
					when waitOnCompute3 =>
							compute <= '0';
							if computeDone = '1' then
								featureDataStrobe <= '1';
								calc_state <= waitOnComm1;
							end if;
					when waitOnComm1 =>
							compute <= '0';
							featureDataStrobe <= '0';
							calc_state <= waitOnComm2;
					when waitOnComm2 =>
							compute <= '0';
							featureDataStrobe <= '0';
							calc_state <= waitOnComm3;
					when waitOnComm3 =>
							compute <= '0';
							featureDataStrobe <= '0';
							if acknowledge = '1' then
								calc_state <= objectSearch;
							end if;
					end case;
					
				if runCalc = '0' then 
					calc_state <= initSearch;
				end if;
				
				calcAddressDelayed <= calcAddress;
				calcAddress <= cindex(9 downto 0);

			end if; -- Syncronolus statements
		end process calc;
			
--	calc: process(clk,reset) 
--		variable cindex : std_logic_vector(10 downto 0) := (others=>'1');
--		begin
--			if reset = '1' then
--				cindex := conv_std_logic_vector(1,11);
--				calcAddress <= cindex(9 downto 0);
--				tablePreset <= '0';
--				compute <= '0';
--				calcCode <= (others=>'0');
--				
--			elsif clk'event and clk = '1' then
--				
--				if runCalc = '0' then
--					cindex := conv_std_logic_vector(1,11);
--					tablePreset <= '0';
--					calcAddress <= cindex(9 downto 0);
--					compute <= '0';
--					calcCode <= (others=>'0');
--				elsif computeDone = '1' and acknowledge = '1' then
--					compute <= '0';
--					if cindex < indexMax+1 then
--						if calcAddressDelayed = eqData and cindex > 1 then
--							calcCode <= calcAddressDelayed;
--							compute <= '1';
--						end if;
--						cindex := cindex + 1;
--					elsif cindex = indexMax+1 then
--						tablePreset <= '1';
--						cindex := cindex + 1;
--					else
--						tablePreset <= '0';
--					end if;
--					calcAddressDelayed <= calcAddress;
--					calcAddress <= cindex(9 downto 0);
--				else
--					compute <='0';
--				end if;
--				
--				if computeDone = '1'  and computeDoneDelay = '0' and acknowledge = '1' then
--					featureDataStrobe <= '1';
--				else
--					featureDataStrobe <= '0';
--				end if;
--				
--				computeDoneDelay <= computeDone;
--			end if;
--		end process calc;
		
end Behavioral;

