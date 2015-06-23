----------------------------------------------------------------------------------
-- Company:       VISENGI S.L. (www.visengi.com)
-- Engineer:      Victor Lopez Lorenzo (victor.lopez (at) visengi (dot) com)
-- 
-- Create Date:    19:34:36 04/November/2008
-- Project Name:   IMA ADPCM Encoder
-- Tool versions:  Xilinx ISE 9.2i
-- Description: 
--
-- Description: This project features a full-hardware sound compressor using the well known algorithm IMA ADPCM.
--              The core acts as a slave WISHBONE device. The output is perfectly compatible with any sound player
--              with the IMA ADPCM codec (included by default in every Windows). Includes a testbench that takes
--              an uncompressed PCM 16 bits Mono WAV file and outputs an IMA ADPCM compressed WAV file.
--              Compression ratio is fixed for IMA-ADPCM, being 4:1.
--
--
-- LICENSE TERMS: GNU GENERAL PUBLIC LICENSE Version 3
--
--     That is you may use it only in NON-COMMERCIAL projects.
--     You are only required to include in the copyrights/about section 
--     that your system contains a "IMA ADPCM Encoder (C) VISENGI S.L. under GPL license"
--     This holds also in the case where you modify the core, as the resulting core
--     would be a derived work.
--     Also, we would like to know if you use this core in a project of yours, just an email will do.
--
--    Please take good note of the disclaimer section of the GPL license, as we don't
--    take any responsability for anything that this core does.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IMA_ADPCM_Encode is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;

           PredictedValue_o : out std_logic_vector(15 downto 0);
           StepIndex_o : out std_logic_vector(6 downto 0);
           StateRDY : out std_logic;
			  
			  sample : in std_logic_vector(15 downto 0); --don't change it while sample_rdy='1'
           sample_rdy : in std_logic; --lower it only when ADPCM_sample_rdy = '1'
			  ADPCM_sample : out std_logic_vector(3 downto 0);
           ADPCM_sample_rdy : out std_logic
			  );
end IMA_ADPCM_Encode;

architecture Behavioral of IMA_ADPCM_Encode is
	signal PredictedValue : std_logic_vector(15 downto 0);
	signal StepIndex : std_logic_vector(6 downto 0);

	component IMA_adpcm_steptable_rom port( 
		addr0	: in  STD_LOGIC_VECTOR(6 downto 0); 
		clk   : in  STD_LOGIC; 
		datao0: out STD_LOGIC_VECTOR(14 downto 0));
	end component;
	
	signal Step : std_logic_vector(14 downto 0);
	
	signal comp16b_AbtB : std_logic; --A bigger than B
	signal delta, diff : std_logic_vector(15 downto 0);
   signal State : integer range 0 to 31;
begin
	StepTable_ROM : IMA_adpcm_steptable_rom port map ( 
			 addr0 => StepIndex, 
			 clk   => clk,
			 datao0=> Step);



	process (reset, clk)
      variable AdderSub16 : std_logic_vector(15 downto 0);
		variable ADPCM_sample2 : std_logic_vector(3 downto 0);
	begin
		if (reset = '1') then
			State <= 0;
         AdderSub16 := (others => '0');
			ADPCM_sample <= x"0";
			ADPCM_sample2 := x"0";
         ADPCM_sample_rdy <= '0';
			
			PredictedValue <= (others => '0');
			StepIndex <= (others => '0');
         PredictedValue_o <= (others => '0');
         StepIndex_o <= (others => '0');
         StateRDY <= '0';
			delta <= (others => '0');
			diff <= (others => '0');
			comp16b_AbtB <= '0';
		elsif (clk='1' and clk'event) then
         ADPCM_sample_rdy <= '0';
         
			case State is
				when 0 =>
               PredictedValue_o <= PredictedValue; StepIndex_o <= StepIndex; StateRDY <= '1';
               if (sample_rdy = '1') then State <= 10; StateRDY <= '0'; end if;
				when 10 => --Signed comparison between A:sample and B:PredictedValue
               if (sample(15) = '1' and PredictedValue(15) = '0') then
                  comp16b_AbtB <= '0'; --sample<0, Pred>=0
               elsif (sample(15) = '0' and PredictedValue(15) = '1') then
                  comp16b_AbtB <= '1'; --sample>=0, Pred<0
               else --both positives or both negatives --> normal comparison
                  if (sample > PredictedValue) then comp16b_AbtB <= '1'; else comp16b_AbtB <= '0'; end if;
               end if;
					State <= State + 1;
				when 11 =>
					if (comp16b_AbtB = '1') then --it really should be beq but a negative zero is as good as a positive one
						delta <= sample - PredictedValue;
						ADPCM_sample2(3) := '0';
					else
						delta <= PredictedValue - sample;
						ADPCM_sample2(3) := '1'; --set the sign (negative)
					end if;
					State <= State + 1;

				when 12 => --we've got the rigth Step now
					diff <= "0000" & Step(14 downto 3);
					if (delta > '0' & Step) then comp16b_AbtB <= '1'; else comp16b_AbtB <= '0'; end if;
					State <= State + 1;
				when 13 =>
					if (comp16b_AbtB = '1') then --delta > step
						delta <= delta - ('0' & Step);
						diff <= diff + ('0' & Step);
						ADPCM_sample2(2) := '1';
					else
						ADPCM_sample2(2) := '0';
					end if;
					State <= State + 1;
					
				when 14 =>
					if (delta > "00" & Step(14 downto 1)) then comp16b_AbtB <= '1'; else comp16b_AbtB <= '0'; end if;
					State <= State + 1;
				when 15 =>
					if (comp16b_AbtB = '1') then --delta > step
						delta <= delta - ("00" & Step(14 downto 1));
						diff <= diff + ("00" & Step(14 downto 1));
						ADPCM_sample2(1) := '1';
					else
						ADPCM_sample2(1) := '0';
					end if;
					State <= State + 1;
					
				when 16 =>
					if (delta > "000" & Step(14 downto 2)) then comp16b_AbtB <= '1'; else comp16b_AbtB <= '0'; end if;
					State <= State + 1;
				when 17 =>
					if (comp16b_AbtB = '1') then --delta > step
						diff <= diff + ("000" & Step(14 downto 2));
						ADPCM_sample2(0) := '1';
					else
						ADPCM_sample2(0) := '0';
					end if;
               ADPCM_sample_rdy <= '1';
					State <= State + 1;
								
				when 18 =>
					if (ADPCM_sample2(3) = '1') then --negative
                  AdderSub16 := PredictedValue - diff;
					else
                  AdderSub16 := PredictedValue + diff;
					end if;
					
					--IMA_ADPCMIndexTable[8] =	-1, -1, -1, -1, 2, 4, 6, 8,
					case ADPCM_sample2(2 downto 0) is
						when "111" => StepIndex <= StepIndex + "0001000";
						when "110" => StepIndex <= StepIndex + "0000110";
						when "101" => StepIndex <= StepIndex + "0000100";
						when "100" => StepIndex <= StepIndex + "0000010";
						when others => StepIndex <= StepIndex - "0000001";
					end case;
					State <= State + 1;
				when 19 =>
					if (StepIndex = "1111111") then
						StepIndex <= (others => '0');
					elsif (StepIndex > "1011000") then
						StepIndex <= "1011000";
					end if;
               
               --diff is always positive, it becomes negative if we substract Pred - diff == Pred + (-diff)
               --so the sign of diff is marked by ADPCM_sample2(3)
               if (PredictedValue(15) = '0' and ADPCM_sample2(3) = '0' and AdderSub16(15) = '1') then --both positives result in negative?
                  PredictedValue <= '0' & (14 downto 0 => '1'); --positive overflow -> set biggest positive
               elsif (PredictedValue(15) = '1' and ADPCM_sample2(3) = '1' and AdderSub16(15) = '0') then --both negatives result positive?
                  PredictedValue <= '1' & (14 downto 0 => '0'); --negative overflow -> set biggest negative
               else --one positive, the other negative (overflow not possible)
                  PredictedValue <= AdderSub16(15 downto 0);
               end if;
					State <= 0; --go wait for new sample ready
			
				when others =>
					State <= 0;
			end case;
			ADPCM_sample <= ADPCM_sample2;
		end if;
	end process;
			
end Behavioral;

