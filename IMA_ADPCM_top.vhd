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

entity IMA_ADPCM_top is
   Port (  wb_clk_i : in std_logic;
           wb_rst_i : in std_logic;           
           wb_cyc_i : in std_logic;
           wb_stb_i : in std_logic;
           wb_we_i  : in std_logic;
           wb_adr_i : in std_logic_vector(1 downto 0);
           wb_dat_i : in std_logic_vector(15 downto 0);
           wb_dat_o : out std_logic_vector(15 downto 0);
           wb_ack_o : out std_logic);
end IMA_ADPCM_top;

architecture Behavioral of IMA_ADPCM_top is
   component IMA_ADPCM_Encode port (
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           PredictedValue_o : out std_logic_vector(15 downto 0);
           StepIndex_o : out std_logic_vector(6 downto 0);
           StateRDY : out std_logic;
			  sample : in std_logic_vector(15 downto 0); --don't change it while sample_rdy='1'
           sample_rdy : in std_logic; --lower it only when ADPCM_sample_rdy = '1'
			  ADPCM_sample : out std_logic_vector(3 downto 0);
           ADPCM_sample_rdy : out std_logic);
   end component;

	component WAV_header_rom port( 
		addr0	: in  STD_LOGIC_VECTOR(5 downto 0); 
		clk   : in  STD_LOGIC; 
		datao0: out STD_LOGIC_VECTOR(7 downto 0));
	end component;
   
   signal WAV_addr : std_logic_vector(5 downto 0);
   signal WAV_data : std_logic_vector(7 downto 0);
   
   signal sample : std_logic_vector(15 downto 0);
   signal ADPCM_sample : std_logic_vector(3 downto 0);
   signal sample_rdy, ADPCM_sample_rdy : std_logic;
   
   signal soft_reset, isoft_reset : std_logic;
   signal iwb_ack_o : std_logic;
   
   
   -- IMPORTANT: Remember that flow control MUST be done externally (that is, if SamplesPerSec is set to 8000, then 8000 samples must be fed every second)
   -- The first 60 bytes of data correspond to the WAV header
   --
   --WISHBONE REGS' DESCRIPTION:
   --reg 0: Control(W: WRITES)/Status(R: READS)
   --    bit 15: (R) 0=finished, 1=compressing (W) 0=end file (if compressing), 1=start file compression
   --          clearing this bit while compressing doesn't immediately end it, because the current block must be finished (block size=256 bytes)
   --                the only thing that happens is that the next samples up to the end of the block (samples_per_block=505) will be zeros (silence).
   --    bit  1: (R) 1=ready for new input sample to be written on reg 3 (auto-cleared on write to reg 3), 0=processing last input sample
   --    bit  0: (R) 1=16 bits of output file are ready to be read on reg 3 (auto-cleared on read to reg 3), 0=processing next output word
   --reg 1: SamplesPerSec (i.e.: 8000, 22050, 32000, 44100, ...)
   --reg 2: SecondsToCompress (0 for undefined (max values will be used in file headers) -> the sound will be complete and reproducible but an "early EOF" or "damaged file" error may appear in player at the end of the sound)
   --reg 3: On writes: a 16 bit sample is expected - On reads: data lines will contain 16 bits of the compressed output file (only if reg(0)(0)='1'!!!)
      --output words of 16 bits should be read from MSB to LSB
   
   signal SamplesPerSec1, SecondsToCompress2, CompressedWord : std_logic_vector(15 downto 0);
   signal InputRDY, OutputRDY, OutputRDY_sync2, RDYOutput, FinishBlock : std_logic;
   signal StartCompressing, Compressing, EndCompression : std_logic;
   signal CompressedNibbles : integer range 0 to 4;
   
   signal WriteHeader, WriteHeader_sync2 : std_logic;
   signal WriteState, WriteState_sync2 : std_logic;
   signal BlockBytes : integer range 0 to 255;
   signal SecondsCompressed : std_logic_vector(15 downto 0);
   signal SamplesCompressed : std_logic_vector(15 downto 0);
   signal MSB, LoadROM : std_logic;
   signal SamplesInFile : std_logic_vector(31 downto 0);
   
 	signal PredictedValue : std_logic_vector(15 downto 0);
	signal StepIndex : std_logic_vector(6 downto 0);
   signal StateRDY : std_logic;
   signal WriteStateLSWord : std_logic;
begin
   isoft_reset <= soft_reset or wb_rst_i;

   WAV_ROM: WAV_header_rom port map (
      addr0 => WAV_addr,
      clk => wb_clk_i,
      datao0 => WAV_data);
   
   IMA_ADPCM_Encoder : IMA_ADPCM_Encode port map (
      clk => wb_clk_i,
      reset => isoft_reset,
      PredictedValue_o => PredictedValue,
      StepIndex_o => StepIndex,
      StateRDY => StateRDY,
      sample => sample,
      sample_rdy => sample_rdy,
      ADPCM_sample => ADPCM_sample,
      ADPCM_sample_rdy => ADPCM_sample_rdy);
      
   Input_process : process (wb_clk_i, wb_rst_i)
      variable WaitW : std_logic;
   begin
      if (wb_rst_i = '1') then
         iwb_ack_o <= '0';
         wb_dat_o <= (others => '0');
         InputRDY <= '0';
         OutputRDY <= '0';
         OutputRDY_sync2 <= '0';
         SamplesPerSec1 <= (others => '0');
         SecondsToCompress2 <= (others => '0');
         Compressing <= '0';
         StartCompressing <= '0';
         WaitW := '0';
         soft_reset <= '0';

         sample <= (others => '0');
         sample_rdy <= '0';
      elsif (wb_clk_i = '1' and wb_clk_i'event) then
         OutputRDY_sync2 <= OutputRDY;
         soft_reset <= '0';
         iwb_ack_o <= wb_cyc_i and wb_stb_i and not iwb_ack_o;
         
         if (RDYOutput = '1') then OutputRDY <= '1'; end if;
         if (ADPCM_sample_rdy = '1') then
            sample_rdy <= '0';
            if (CompressedNibbles < 3 and WriteState = '0') then InputRDY <= '1'; end if;
         end if;
         
         if (OutputRDY_sync2 = '1' and OutputRDY = '0' and WriteState = '0' and WriteHeader = '0') then InputRDY <= '1'; end if;
         if (((OutputRDY_sync2 = '1' and OutputRDY = '0') or (WriteHeader_sync2 = '1' and WriteHeader = '0')) and WriteState = '1' and BlockBytes = 0 and WaitW = '0') then InputRDY <= '1'; WaitW := '1'; end if; --to write the block header one input sample is required
         if (WriteState_sync2 = '1' and WriteState = '0') then InputRDY <= '1'; WaitW := '0'; end if; --after writing the block header, ask for input sample
         
         
         if (EndCompression = '1') then Compressing <= '0'; end if;

         if (FinishBlock = '1') then
            sample <= x"0000";
            sample_rdy <= '1';
            InputRDY <= '0';
         end if;
         
         if (wb_cyc_i = '1' and wb_stb_i = '1') then
            case wb_adr_i is
               when "00" => --control/status
                  if (wb_we_i = '0') then --read = status
                     wb_dat_o <= (others => '0');
                     wb_dat_o(15) <= Compressing;
                     wb_dat_o(1) <= InputRDY;
                     wb_dat_o(0) <= OutputRDY;
                  else --write = control
                     StartCompressing <= wb_dat_i(15);
                     if (wb_dat_i(15) = '1' and Compressing = '0') then --start new operation?
                        soft_reset <= '1';
                        OutputRDY <= '0';
                        InputRDY <= '0'; --wait for WriteHeader
                        Compressing <= '1';
                     end if;                        
                  end if;
               when "11" => --data in/out
                  if (wb_we_i = '0') then --read = get compressed data
                     if (OutputRDY = '1') then
                        wb_dat_o <= CompressedWord;
                        OutputRDY <= '0';
                     end if;
                  else --write = put input sample
                     if (InputRDY = '1') then
                        if (FinishBlock = '0') then sample <= wb_dat_i; else sample <= x"0000"; end if;
                        sample_rdy <= '1';
                        InputRDY <= '0';
                     end if;
                  end if;
               when "01" => --SamplesPerSec
                  if (wb_we_i = '0') then --read
                     wb_dat_o <= SamplesPerSec1;
                  else --write
                     SamplesPerSec1 <= wb_dat_i;
                  end if;
               when "10" => --SecondsToCompress
                  if (wb_we_i = '0') then --read
                     wb_dat_o <= SecondsToCompress2;
                  else --write
                     SecondsToCompress2 <= wb_dat_i;
                  end if;
               when others =>
                  report "-----------> Wrong WB Address!" severity WARNING;               
            end case;
         end if;         
      end if;
   end process;
   
   wb_ack_o <= iwb_ack_o;
      
      
   Output_process : process (wb_clk_i, wb_rst_i)
      variable WaitADPCM : std_logic;
      variable WAV_data_to_write : std_logic_vector(7 downto 0);
   begin
      if (wb_rst_i = '1') then
         CompressedWord <= (others => '0');
         RDYOutput <= '0';
         WriteHeader <= '1';
         WriteHeader_sync2 <= '1';
         FinishBlock <= '0';
         BlockBytes <= 0;
         CompressedNibbles <= 0;
         EndCompression <= '0';
         MSB <= '1';
         LoadROM <= '1';
         WAV_addr <= (others => '0');
         WAV_data_to_write := (others => '0');

         SecondsCompressed <= (others => '0');
         SamplesCompressed <= (others => '0');
         
         WriteState <= '0';
         WriteState_sync2 <= '0';
         WriteStateLSWord  <= '0';
         WaitADPCM := '0';
      elsif (wb_clk_i = '1' and wb_clk_i'event) then
         WriteHeader_sync2 <= WriteHeader;
         WriteState_sync2 <= WriteState;
         
         if (WriteState_sync2 = '0' and WriteState = '1') then WaitADPCM := '1'; end if;
         
         EndCompression <= '0';
         RDYOutput <= '0';
         if (StartCompressing = '0' and Compressing = '1') then FinishBlock <= '1'; end if; --finish compression on end of current block!

         if (ADPCM_sample_rdy = '1' and WriteState = '0') then --because WriteState uses one ADPCM_sample_rdy to write its own header sample
            case CompressedNibbles is --little endian on each byte (byte 0:n1n0, byte 1:n3n2, ...)
               when 0 =>
                  CompressedWord(11 downto 8) <= ADPCM_sample;
                  CompressedNibbles <= CompressedNibbles + 1;
               when 1 =>
                  CompressedWord(15 downto 12) <= ADPCM_sample;
                  CompressedNibbles <= CompressedNibbles + 1;
               when 2 =>
                  CompressedWord(3 downto 0) <= ADPCM_sample;
                  CompressedNibbles <= CompressedNibbles + 1;
               when 3 =>
                  CompressedWord(7 downto 4) <= ADPCM_sample;
                  CompressedNibbles <= CompressedNibbles + 1;
                  if (BlockBytes /= 254) then
                     BlockBytes <= BlockBytes + 2;
                  else
                     BlockBytes <= 0;
                     WriteState <= '1';
                  end if;
               when others => --4 pending wb read of reg 3
                  CompressedNibbles <= CompressedNibbles;
            end case;
            
            
            if (SamplesCompressed = SamplesPerSec1) then
               if (SecondsCompressed = SecondsToCompress2) then
                  FinishBlock <= '1'; --finish compression on end of current block!
               else
                  SamplesCompressed <= (others => '0');
                  SecondsCompressed <= SecondsCompressed + 1;
               end if;
            else
               SamplesCompressed <= SamplesCompressed + 1;
            end if;
         end if;

         if (Compressing = '1' and EndCompression = '0') then
            if (CompressedNibbles = 4) then
               if (OutputRDY_sync2 = '1' and OutputRDY = '0') then
                  CompressedNibbles <= 0;
                  if (WriteStateLSWord  = '0' and BlockBytes = 4) then WriteState <= '0'; end if; --lower it (but not in the cycle it is risen!)
               else
                  if (OutputRDY = '0' and RDYOutput = '0') then RDYOutput <= '1'; end if;
               end if;
            else 
               if (RDYOutput = '0' and OutputRDY = '0') then --get next nibble/s if last CompressedWord is read
                  if (FinishBlock = '1') then --finish compression on end of current block!
                     if (BlockBytes = 0) then
                        EndCompression <= '1'; --signal input process the end of the compression
                     end if;
                  else --normal operation
                     if (WriteHeader = '1') then --output WAV header
                        if (LoadROM = '0') then
                           LoadROM <= '1'; --give the ROM time to read a byte
                           if (WAV_addr = "111100") then --last header byte + 1
                              WAV_addr <= (others => '0');
                              WriteHeader <= '0';
                              WriteState <= '1';
                           end if;
                        else
                           WAV_addr <= WAV_addr + 1;
                           WAV_data_to_write := WAV_data; --by default times are for undefined in WAV header
                           case WAV_addr is --all data is little-endian!
                              when "000100" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(7 downto 0); end if; --LSB of file_size-8 (FF for undefined)
                              when "000101" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(15 downto 8); end if; --LSB2 of file_size-8 (FF for undefined)
                              when "000110" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(23 downto 16); end if; --MSB2 of file_size-8 (FF for undefined)
                              when "000111" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(31 downto 24); end if; --MSB of file_size-8 (7F for undefined)

                              when "011000" => WAV_data_to_write := SamplesPerSec1(7 downto 0); --LSB of SamplesPerSec
                              when "011001" => WAV_data_to_write := SamplesPerSec1(15 downto 8); --MSB of SamplesPerSec
                              when "011100" => WAV_data_to_write := SamplesPerSec1(8 downto 1); --LSB of AvgBytesPerSec : approx. SamplesPerSec/2
                              when "011101" => WAV_data_to_write := '0' & SamplesPerSec1(15 downto 9); --MSB of AvgBytesPerSec : approx. SamplesPerSec/2

                              when "110000" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(7 downto 0); end if; --LSB of SamplesPerChannelInFile (FF for undefined)
                              when "110001" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(15 downto 8); end if; --LSB2 of SamplesPerChannelInFile (FF for undefined)
                              when "110010" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(23 downto 16); end if; --MSB2 of SamplesPerChannelInFile (FF for undefined)
                              when "110011" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(31 downto 24); end if; --MSB of SamplesPerChannelInFile (7F for undefined)

                              when "111000" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(7 downto 0); end if; --LSB of file_size-60 (FF for undefined)
                              when "111001" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(15 downto 8); end if; --LSB2 of file_size-60 (FF for undefined)
                              when "111010" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(23 downto 16); end if; --MSB2 of file_size-60 (FF for undefined)
                              when "111011" => if (SecondsToCompress2 /= x"0000") then WAV_data_to_write := SamplesInFile(31 downto 24); end if; --MSB of file_size-60 (7F for undefined)
                              when others => null;
                           end case;
                           if (MSB = '1') then
                              CompressedWord(15 downto 8) <= WAV_data_to_write;
                           else
                              CompressedWord(7 downto 0) <= WAV_data_to_write;
                              CompressedNibbles <= 4; --signal word ready
                           end if;
                           MSB <= not MSB;
                           LoadROM <= '0';
                        end if;
                     else --output ADPCM data
                        if (WriteState = '1' and FinishBlock = '0') then --block header with state at the beginning and every 256 bytes
                           if (WaitADPCM = '1') then
                              if (ADPCM_sample_rdy = '1') then WaitADPCM := '0'; end if;
                           else
                              if (StateRDY = '1') then
                                 if (WriteStateLSWord  = '0') then --write first two bytes of state: PredictedValue
                                    CompressedWord <= PredictedValue(7 downto 0) & PredictedValue(15 downto 8); --little endian!
                                    BlockBytes <= 2;
                                    SamplesCompressed <= SamplesCompressed + 1;
                                 else --write second two bytes of state: StepIndex & x"00"
                                    CompressedWord <= '0' & StepIndex & x"00";
                                    --WriteState <= '0'; lower it only after Output written
                                    BlockBytes <= BlockBytes + 2;
                                 end if;
                                 WriteStateLSWord <= not WriteStateLSWord;
                                 CompressedNibbles <= 4; --signal word ready
                              end if;
                           end if;
                        else --data nibbles
                           null; --taken care of above
                        end if;
                     end if;
                  end if;
               end if;            
            end if;
         else
            CompressedWord <= (others => '0');
            RDYOutput <= '0';
            WriteHeader <= '1';
            FinishBlock <= '0';
            BlockBytes <= 0;
            CompressedNibbles <= 0;
            EndCompression <= '0';
            MSB <= '1';
            LoadROM <= '1';
            WAV_addr <= (others => '0');
            SecondsCompressed <= (others => '0');
            SamplesCompressed <= (others => '0');
            WriteState <= '0';
            WriteStateLSWord  <= '0';
            WaitADPCM := '0';            
         end if;
      end if;
   end process;    

   process (wb_clk_i, wb_rst_i)
   begin
      if (wb_rst_i = '1') then
         SamplesInFile <= (others => '0');
      elsif (wb_clk_i = '1' and wb_clk_i'event) then
         --comment next lines to save up a lot of resources (multiplier),
         --but then use undefined number of seconds for compression!!
         --(to stop it just write 0 to the MSb of WB reg 0)
         --just be aware that final WAV file will play but at the end,
         --some players will display an error saying something like "Early EOF" or "Corrupted file".
         
         --if (Compressing = '1' and EndCompression = '0') then
            --SamplesInFile <= SamplesPerSec1 * SecondsToCompress2;
         --else
            if (LoadROM = '1') then
               if (WAV_addr = "000000") then --file_size-8=SamplesInFile/2+52
                  --file size calculation is approximate, unless you want to mess up with floats
                  --or you have a fixed sampling rate (and want to modify the source code of this process)
                  SamplesInFile <= (('0' & SamplesPerSec1(15 downto 1)) * SecondsToCompress2) + x"34";
                  --SamplesInFile <= '0' & (SamplesInFile(31 downto 1) + x"34");
               elsif (WAV_addr = "011101") then --get raw SamplesInFile
                  SamplesInFile <= SamplesPerSec1 * SecondsToCompress2;
               elsif (WAV_addr = "110100") then --file_size-60=SamplesInFile/2
                  SamplesInFile <= '0' & SamplesInFile(31 downto 1);
               end if;
            end if;
         --end if;
      end if;
   end process;
end Behavioral;

