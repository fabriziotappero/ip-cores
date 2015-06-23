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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
use ieee.numeric_std.all;

ENTITY tb_IMA_ADPCM_top_vhd IS
END tb_IMA_ADPCM_top_vhd;

ARCHITECTURE behavior OF tb_IMA_ADPCM_top_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT IMA_ADPCM_top
	PORT(
		wb_clk_i : IN std_logic;
		wb_rst_i : IN std_logic;
		wb_cyc_i : IN std_logic;
		wb_stb_i : IN std_logic;
		wb_we_i : IN std_logic;
		wb_adr_i : IN std_logic_vector(1 downto 0);
		wb_dat_i : IN std_logic_vector(15 downto 0);          
		wb_dat_o : OUT std_logic_vector(15 downto 0);
		wb_ack_o : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL wb_clk_i :  std_logic := '0';
	SIGNAL wb_rst_i :  std_logic := '0';
	SIGNAL wb_cyc_i :  std_logic := '0';
	SIGNAL wb_stb_i :  std_logic := '0';
	SIGNAL wb_we_i :  std_logic := '0';
	SIGNAL wb_adr_i :  std_logic_vector(1 downto 0) := (others=>'0');
	SIGNAL wb_dat_i :  std_logic_vector(15 downto 0) := (others=>'0');

	--Outputs
	SIGNAL wb_dat_o :  std_logic_vector(15 downto 0);
	SIGNAL wb_ack_o :  std_logic;


   type ByteFileType is file of character;
   file infile : ByteFileType open read_mode is "input.wav";
   file outfile : ByteFileType open write_mode is "output.wav";   

   signal bytes, bytesout : std_logic_vector(23 downto 0);
   
   signal SamplesPerSec : std_logic_vector(15 downto 0);
   signal SecondsToCompress : std_logic_vector(31 downto 0);
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: IMA_ADPCM_top PORT MAP(
		wb_clk_i => wb_clk_i,
		wb_rst_i => wb_rst_i,
		wb_cyc_i => wb_cyc_i,
		wb_stb_i => wb_stb_i,
		wb_we_i => wb_we_i,
		wb_adr_i => wb_adr_i,
		wb_dat_i => wb_dat_i,
		wb_dat_o => wb_dat_o,
		wb_ack_o => wb_ack_o
	);
  
   wb_rst_i <= '1', '0' after 40 ns; --active high reset
	
	Clocking : process --50 MHz -> T = 20 ns
	begin
		wb_clk_i <= '1'; wait for 20 ns;
		wb_clk_i <= '0'; wait for 20 ns;
	end process;      
   
   
   
   
   Control_Compressor : process (wb_clk_i, wb_rst_i)
      variable byte : character;
      variable WaitACK, EndSignaled : std_logic;
      variable State : integer;
      variable data : std_logic_vector(15 downto 0);
      variable DataBytes : std_logic_vector(31 downto 0);
   begin  
      if (wb_rst_i = '1') then
         bytes <= (others => '0');
         bytesout <= (others => '0');
         State := 0;
         WaitACK := '0';
         EndSignaled := '0';
         wb_cyc_i <= '0';
         wb_stb_i <= '0';
         wb_we_i <= '0';
         wb_adr_i <= (others => '0');
         wb_dat_i <= (others => '0');
         data := (others => '0');
      elsif (wb_clk_i = '1' and wb_clk_i'event) then
         if (WaitACK = '1') then
            if (wb_ack_o = '1') then
               wb_cyc_i <= '0'; wb_stb_i <= '0'; wb_we_i <= '0';
               data := wb_dat_o; WaitACK := '0';
            end if;
         end if;
         
         if (WaitACK = '0') then
            case State is
               when 0 =>
                  --read the WAV header in search of SamplesPerSecond (bytes 19h and 18h in little endian)
                  --and DataBytes (bytes 39h,38h,37h,36h in little endian) to get SecondsToCompress as DataBytes/2/SamplesPerSecond
                  for i in 0 to 57 loop --PCM header has 58 bytes
                     read(infile, byte);
                     case i is
                        when 25 => --x"19" => --MSB of SamplesPerSecond
                           SamplesPerSec(15 downto 8) <= conv_std_logic_vector(character'pos(byte),8);
                        when 24 => --x"18" => --LSB of SamplesPerSecond
                           SamplesPerSec(7 downto 0) <= conv_std_logic_vector(character'pos(byte),8);
      
                        when 7 => --x"39" => --1stMSB of DataBytes
                           DataBytes(31 downto 24) := conv_std_logic_vector(character'pos(byte),8);
                        when 6 => --x"38" => --2ndMSB of DataBytes
                           DataBytes(23 downto 16) := conv_std_logic_vector(character'pos(byte),8);
                        when 5 => --x"37" => --3rdMSB of DataBytes
                           DataBytes(15 downto 8) := conv_std_logic_vector(character'pos(byte),8);
                        when 4 => --x"36" => --4thMSB of DataBytes
                           DataBytes(7 downto 0) := conv_std_logic_vector(character'pos(byte),8);
                        when others =>
                           null;
                     end case;      
                  end loop;
                  EndSignaled := '0';
                  bytes <= (others => '0');
                  bytesout <= (others => '0');
                  DataBytes := DataBytes - x"32"; --with fmt18 and fact4 chunks
                  State := State + 1;
               when 1 =>
                  SecondsToCompress <= conv_std_logic_vector((conv_integer(DataBytes)/conv_integer(SamplesPerSec))/2,32);
                  wb_adr_i <= "01"; wb_dat_i <= SamplesPerSec; wb_we_i <= '1'; WaitACK := '1';
                  State := State + 1;
               when 2 =>
                  wb_adr_i <= "10"; wb_dat_i <= SecondsToCompress(15 downto 0); wb_we_i <= '1'; WaitACK := '1';
                  State := State + 1;
               when 3 =>
                  wb_adr_i <= "00"; wb_dat_i <= x"8000"; wb_we_i <= '1'; WaitACK := '1';
                  State := State + 1;
               when 4 =>
                  wb_adr_i <= "00"; wb_we_i <= '0'; WaitACK := '1'; State := State + 1;
               when 5 =>
                  if (data(15) = '0') then --compression end
                     File_Close(infile); --finished
                     report "Input bytes = " & integer'image(conv_integer(bytes)) & " at time " & time'image(now);
                     report "Output bytes = " & integer'image(conv_integer(bytesout)) & " at time " & time'image(now);
                     File_Close(outfile); --finished
                     report "-----------> Compression Finished OK!" severity FAILURE; --everything went fine, it's just to stop the simulation
                  else
                     if (data(0) = '1') then --output word ready
                        wb_adr_i <= "11"; wb_we_i <= '0'; WaitACK := '1';
                        State := 15; --write word
                     elsif (data(1) = '1' and EndSignaled = '0') then --ready for new input sample AND haven't reached the input file's EOF?
                        if (bytes < DataBytes(23 downto 0) and not endfile(infile)) then
                           --send two bytes to the WAV compressor
                           read(infile,byte); --1st byte ----> goes in LSBs!!! (little endian)
                           wb_dat_i(7 downto 0) <= conv_std_logic_vector(character'pos(byte),8);
                           read(infile,byte); --2nd byte
                           wb_dat_i(15 downto 8) <= conv_std_logic_vector(character'pos(byte),8);
                           bytes <= bytes + x"2";                  
                           wb_adr_i <= "11"; wb_we_i <= '1'; WaitACK := '1'; State := State - 1;
                        else --already sent the number of bytes indicated in PCM WAV header
                           wb_adr_i <= "00"; wb_dat_i <= x"0000"; wb_we_i <= '1'; WaitACK := '1'; --signal finish compression
                           EndSignaled := '1'; State := State - 1; --there will be still bytes to write but don't get in here again (EndSignaled='1')
                        end if;
                     else
                        wb_adr_i <= "00"; wb_we_i <= '0'; WaitACK := '1'; --read again and stay in this state
                     end if;
                  end if;
               
               
               when 15 => --write word
                  write(outfile, character'val(conv_integer(data(15 downto 8))));
                  write(outfile, character'val(conv_integer(data(7 downto 0))));
                  bytesout <= bytesout + x"2";
                  wb_adr_i <= "00"; wb_we_i <= '0'; WaitACK := '1'; State := 5; --go back and continue
                  
               when others =>
                  State := 0;
            end case;
         end if;
         if (WaitACK = '1') then wb_cyc_i <= '1'; wb_stb_i <= '1'; end if;
      end if;
   end process Control_Compressor;

END;
