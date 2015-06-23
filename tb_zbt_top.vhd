----------------------------------------------------------------------------------
-- Company:       VISENGI S.L. (www.visengi.com) - URJC FRAV Group (www.frav.es)
-- Engineer:      Victor Lopez Lorenzo (victor.lopez (at) visengi (dot) com)
-- 
-- Create Date:    12:39:50 06-Oct-2008 
-- Project Name:   ZBT SRAM WISHBONE Controller
-- Target Devices: Xilinx ML506 board
-- Tool versions:  Xilinx ISE 9.2i
-- Description: This is a ZBT SRAM controller which is Wishbone rev B.3 compatible (classic + burst r/w operations).
--
-- Dependencies: It may be run on any board/FPGA with a ZBT SRAM pin compatible (or at least in the control signals)
--          with the one on the ML506 board (ISSI IS61NLP 256kx36 ZBT SRAM)
--
--
-- LICENSE TERMS: (CCPL) Creative Commons Attribution-Noncommercial-Share Alike 3.0 Unported.
--          http://creativecommons.org/licenses/by-nc-sa/3.0/
--
--     That is you may use it only in NON-COMMERCIAL projects.
--     You are required to include in the copyrights/about section 
--     that your system contains a "ZBT SRAM Controller (C) Victor Lopez Lorenzo under CCPL license"
--     This holds also in the case where you modify the core, as the resulting core
--     would be a derived work.
--     Also, we would like to know if you use this core in a project of yours, just an email will do.
--
--    Please take good note of the disclaimer section of the CCPL license, as we don't
--    take any responsability for anything that this core does.
----------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.all;

ENTITY tb_zbt_top_vhd IS
END tb_zbt_top_vhd;

ARCHITECTURE behavior OF tb_zbt_top_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT zbt_top
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		wb_adr_i : IN std_logic_vector(17 downto 0);
		wb_we_i : IN std_logic;
		wb_dat_i : IN std_logic_vector(35 downto 0);
		wb_sel_i : IN std_logic_vector(3 downto 0);
		wb_cyc_i : IN std_logic;
		wb_stb_i : IN std_logic;
		wb_cti_i : IN std_logic_vector(2 downto 0);
		wb_bte_i : IN std_logic_vector(1 downto 0);
		wb_tga_i : IN std_logic;    
		SRAM_FLASH_D0 : INOUT std_logic;
		SRAM_FLASH_D1 : INOUT std_logic;
		SRAM_FLASH_D2 : INOUT std_logic;
		SRAM_FLASH_D3 : INOUT std_logic;
		SRAM_FLASH_D4 : INOUT std_logic;
		SRAM_FLASH_D5 : INOUT std_logic;
		SRAM_FLASH_D6 : INOUT std_logic;
		SRAM_FLASH_D7 : INOUT std_logic;
		SRAM_FLASH_D8 : INOUT std_logic;
		SRAM_FLASH_D9 : INOUT std_logic;
		SRAM_FLASH_D10 : INOUT std_logic;
		SRAM_FLASH_D11 : INOUT std_logic;
		SRAM_FLASH_D12 : INOUT std_logic;
		SRAM_FLASH_D13 : INOUT std_logic;
		SRAM_FLASH_D14 : INOUT std_logic;
		SRAM_FLASH_D15 : INOUT std_logic;
		SRAM_D16 : INOUT std_logic;
		SRAM_D17 : INOUT std_logic;
		SRAM_D18 : INOUT std_logic;
		SRAM_D19 : INOUT std_logic;
		SRAM_D20 : INOUT std_logic;
		SRAM_D21 : INOUT std_logic;
		SRAM_D22 : INOUT std_logic;
		SRAM_D23 : INOUT std_logic;
		SRAM_D24 : INOUT std_logic;
		SRAM_D25 : INOUT std_logic;
		SRAM_D26 : INOUT std_logic;
		SRAM_D27 : INOUT std_logic;
		SRAM_D28 : INOUT std_logic;
		SRAM_D29 : INOUT std_logic;
		SRAM_D30 : INOUT std_logic;
		SRAM_D31 : INOUT std_logic;
		SRAM_DQP0 : INOUT std_logic;
		SRAM_DQP1 : INOUT std_logic;
		SRAM_DQP2 : INOUT std_logic;
		SRAM_DQP3 : INOUT std_logic;      
		SRAM_CLK : OUT std_logic;
		SRAM_MODE : OUT std_logic;
		SRAM_CS_B : OUT std_logic;
		SRAM_OE_B : OUT std_logic;
		SRAM_FLASH_WE_B : OUT std_logic;
		SRAM_ADV_LD_B : OUT std_logic;
		SRAM_BW0 : OUT std_logic;
		SRAM_BW1 : OUT std_logic;
		SRAM_BW2 : OUT std_logic;
		SRAM_BW3 : OUT std_logic;
		SRAM_FLASH_A1 : OUT std_logic;
		SRAM_FLASH_A2 : OUT std_logic;
		SRAM_FLASH_A3 : OUT std_logic;
		SRAM_FLASH_A4 : OUT std_logic;
		SRAM_FLASH_A5 : OUT std_logic;
		SRAM_FLASH_A6 : OUT std_logic;
		SRAM_FLASH_A7 : OUT std_logic;
		SRAM_FLASH_A8 : OUT std_logic;
		SRAM_FLASH_A9 : OUT std_logic;
		SRAM_FLASH_A10 : OUT std_logic;
		SRAM_FLASH_A11 : OUT std_logic;
		SRAM_FLASH_A12 : OUT std_logic;
		SRAM_FLASH_A13 : OUT std_logic;
		SRAM_FLASH_A14 : OUT std_logic;
		SRAM_FLASH_A15 : OUT std_logic;
		SRAM_FLASH_A16 : OUT std_logic;
		SRAM_FLASH_A17 : OUT std_logic;
		SRAM_FLASH_A18 : OUT std_logic;
		wb_dat_o : OUT std_logic_vector(35 downto 0);
		wb_ack_o : OUT std_logic;
		wb_err_o : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL clk :  std_logic := '0';
	SIGNAL reset :  std_logic := '0';
	SIGNAL wb_we_i :  std_logic := '0';
	SIGNAL wb_cyc_i :  std_logic := '0';
	SIGNAL wb_stb_i :  std_logic := '0';
	SIGNAL wb_tga_i :  std_logic := '0';
	SIGNAL wb_adr_i, ZBT_ADDR :  std_logic_vector(17 downto 0) := (others=>'0');
	SIGNAL wb_dat_i :  std_logic_vector(35 downto 0) := (others=>'0');
	SIGNAL wb_sel_i :  std_logic_vector(3 downto 0) := (others=>'0');
	SIGNAL wb_cti_i :  std_logic_vector(2 downto 0) := (others=>'0');
	SIGNAL wb_bte_i :  std_logic_vector(1 downto 0) := (others=>'0');

	--BiDirs
	SIGNAL SRAM_FLASH_D0 :  std_logic;
	SIGNAL SRAM_FLASH_D1 :  std_logic;
	SIGNAL SRAM_FLASH_D2 :  std_logic;
	SIGNAL SRAM_FLASH_D3 :  std_logic;
	SIGNAL SRAM_FLASH_D4 :  std_logic;
	SIGNAL SRAM_FLASH_D5 :  std_logic;
	SIGNAL SRAM_FLASH_D6 :  std_logic;
	SIGNAL SRAM_FLASH_D7 :  std_logic;
	SIGNAL SRAM_FLASH_D8 :  std_logic;
	SIGNAL SRAM_FLASH_D9 :  std_logic;
	SIGNAL SRAM_FLASH_D10 :  std_logic;
	SIGNAL SRAM_FLASH_D11 :  std_logic;
	SIGNAL SRAM_FLASH_D12 :  std_logic;
	SIGNAL SRAM_FLASH_D13 :  std_logic;
	SIGNAL SRAM_FLASH_D14 :  std_logic;
	SIGNAL SRAM_FLASH_D15 :  std_logic;
	SIGNAL SRAM_D16 :  std_logic;
	SIGNAL SRAM_D17 :  std_logic;
	SIGNAL SRAM_D18 :  std_logic;
	SIGNAL SRAM_D19 :  std_logic;
	SIGNAL SRAM_D20 :  std_logic;
	SIGNAL SRAM_D21 :  std_logic;
	SIGNAL SRAM_D22 :  std_logic;
	SIGNAL SRAM_D23 :  std_logic;
	SIGNAL SRAM_D24 :  std_logic;
	SIGNAL SRAM_D25 :  std_logic;
	SIGNAL SRAM_D26 :  std_logic;
	SIGNAL SRAM_D27 :  std_logic;
	SIGNAL SRAM_D28 :  std_logic;
	SIGNAL SRAM_D29 :  std_logic;
	SIGNAL SRAM_D30 :  std_logic;
	SIGNAL SRAM_D31 :  std_logic;
	SIGNAL SRAM_DQP0 :  std_logic;
	SIGNAL SRAM_DQP1 :  std_logic;
	SIGNAL SRAM_DQP2 :  std_logic;
	SIGNAL SRAM_DQP3 :  std_logic;

	--Outputs
	SIGNAL SRAM_CLK :  std_logic;
	SIGNAL SRAM_MODE :  std_logic;
	SIGNAL SRAM_CS_B :  std_logic;
	SIGNAL SRAM_OE_B :  std_logic;
	SIGNAL SRAM_FLASH_WE_B :  std_logic;
	SIGNAL SRAM_ADV_LD_B :  std_logic;
	SIGNAL SRAM_BW0 :  std_logic;
	SIGNAL SRAM_BW1 :  std_logic;
	SIGNAL SRAM_BW2 :  std_logic;
	SIGNAL SRAM_BW3 :  std_logic;
	SIGNAL SRAM_FLASH_A1 :  std_logic;
	SIGNAL SRAM_FLASH_A2 :  std_logic;
	SIGNAL SRAM_FLASH_A3 :  std_logic;
	SIGNAL SRAM_FLASH_A4 :  std_logic;
	SIGNAL SRAM_FLASH_A5 :  std_logic;
	SIGNAL SRAM_FLASH_A6 :  std_logic;
	SIGNAL SRAM_FLASH_A7 :  std_logic;
	SIGNAL SRAM_FLASH_A8 :  std_logic;
	SIGNAL SRAM_FLASH_A9 :  std_logic;
	SIGNAL SRAM_FLASH_A10 :  std_logic;
	SIGNAL SRAM_FLASH_A11 :  std_logic;
	SIGNAL SRAM_FLASH_A12 :  std_logic;
	SIGNAL SRAM_FLASH_A13 :  std_logic;
	SIGNAL SRAM_FLASH_A14 :  std_logic;
	SIGNAL SRAM_FLASH_A15 :  std_logic;
	SIGNAL SRAM_FLASH_A16 :  std_logic;
	SIGNAL SRAM_FLASH_A17 :  std_logic;
	SIGNAL SRAM_FLASH_A18 :  std_logic;
	SIGNAL wb_dat_o, ZBT_OUT, ZBT_IN :  std_logic_vector(35 downto 0);
	SIGNAL wb_ack_o :  std_logic;
	SIGNAL wb_err_o :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: zbt_top PORT MAP(
		clk => clk,
		reset => reset,
		SRAM_CLK => SRAM_CLK,
		SRAM_MODE => SRAM_MODE,
		SRAM_CS_B => SRAM_CS_B,
		SRAM_OE_B => SRAM_OE_B,
		SRAM_FLASH_WE_B => SRAM_FLASH_WE_B,
		SRAM_ADV_LD_B => SRAM_ADV_LD_B,
		SRAM_BW0 => SRAM_BW0,
		SRAM_BW1 => SRAM_BW1,
		SRAM_BW2 => SRAM_BW2,
		SRAM_BW3 => SRAM_BW3,
		SRAM_FLASH_A1 => SRAM_FLASH_A1,
		SRAM_FLASH_A2 => SRAM_FLASH_A2,
		SRAM_FLASH_A3 => SRAM_FLASH_A3,
		SRAM_FLASH_A4 => SRAM_FLASH_A4,
		SRAM_FLASH_A5 => SRAM_FLASH_A5,
		SRAM_FLASH_A6 => SRAM_FLASH_A6,
		SRAM_FLASH_A7 => SRAM_FLASH_A7,
		SRAM_FLASH_A8 => SRAM_FLASH_A8,
		SRAM_FLASH_A9 => SRAM_FLASH_A9,
		SRAM_FLASH_A10 => SRAM_FLASH_A10,
		SRAM_FLASH_A11 => SRAM_FLASH_A11,
		SRAM_FLASH_A12 => SRAM_FLASH_A12,
		SRAM_FLASH_A13 => SRAM_FLASH_A13,
		SRAM_FLASH_A14 => SRAM_FLASH_A14,
		SRAM_FLASH_A15 => SRAM_FLASH_A15,
		SRAM_FLASH_A16 => SRAM_FLASH_A16,
		SRAM_FLASH_A17 => SRAM_FLASH_A17,
		SRAM_FLASH_A18 => SRAM_FLASH_A18,
		SRAM_FLASH_D0 => SRAM_FLASH_D0,
		SRAM_FLASH_D1 => SRAM_FLASH_D1,
		SRAM_FLASH_D2 => SRAM_FLASH_D2,
		SRAM_FLASH_D3 => SRAM_FLASH_D3,
		SRAM_FLASH_D4 => SRAM_FLASH_D4,
		SRAM_FLASH_D5 => SRAM_FLASH_D5,
		SRAM_FLASH_D6 => SRAM_FLASH_D6,
		SRAM_FLASH_D7 => SRAM_FLASH_D7,
		SRAM_FLASH_D8 => SRAM_FLASH_D8,
		SRAM_FLASH_D9 => SRAM_FLASH_D9,
		SRAM_FLASH_D10 => SRAM_FLASH_D10,
		SRAM_FLASH_D11 => SRAM_FLASH_D11,
		SRAM_FLASH_D12 => SRAM_FLASH_D12,
		SRAM_FLASH_D13 => SRAM_FLASH_D13,
		SRAM_FLASH_D14 => SRAM_FLASH_D14,
		SRAM_FLASH_D15 => SRAM_FLASH_D15,
		SRAM_D16 => SRAM_D16,
		SRAM_D17 => SRAM_D17,
		SRAM_D18 => SRAM_D18,
		SRAM_D19 => SRAM_D19,
		SRAM_D20 => SRAM_D20,
		SRAM_D21 => SRAM_D21,
		SRAM_D22 => SRAM_D22,
		SRAM_D23 => SRAM_D23,
		SRAM_D24 => SRAM_D24,
		SRAM_D25 => SRAM_D25,
		SRAM_D26 => SRAM_D26,
		SRAM_D27 => SRAM_D27,
		SRAM_D28 => SRAM_D28,
		SRAM_D29 => SRAM_D29,
		SRAM_D30 => SRAM_D30,
		SRAM_D31 => SRAM_D31,
		SRAM_DQP0 => SRAM_DQP0,
		SRAM_DQP1 => SRAM_DQP1,
		SRAM_DQP2 => SRAM_DQP2,
		SRAM_DQP3 => SRAM_DQP3,
		wb_adr_i => wb_adr_i,
		wb_we_i => wb_we_i,
		wb_dat_i => wb_dat_i,
		wb_sel_i => wb_sel_i,
		wb_dat_o => wb_dat_o,
		wb_cyc_i => wb_cyc_i,
		wb_stb_i => wb_stb_i,
		wb_cti_i => wb_cti_i,
		wb_bte_i => wb_bte_i,
		wb_ack_o => wb_ack_o,
		wb_err_o => wb_err_o,
		wb_tga_i => wb_tga_i
	);
   
   
   reset <= '1', '0' after 40 ns; --active high reset
	
	Clocking : process
	begin
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
	end process;
   
   
   ZBT_dout : process (reset, clk)
      variable GetDin, GetWords : integer;
      variable SRAM_BW4 : std_logic_vector(3 downto 0);
   begin
      if (reset = '1') then
         ZBT_OUT <= (others => '0');
         GetDin := 5;
         GetWords := 0;
         SRAM_BW4 := "0000";
      elsif (clk = '1' and clk'event) then
         GetDin := GetDin + 1;
         if (GetDin >= 1 and GetDin <=3 and SRAM_ADV_LD_B = '1') then GetWords := GetWords + 1; end if;            
         if (SRAM_FLASH_WE_B = '0' and SRAM_CS_B = '0' and SRAM_ADV_LD_B = '0') then
            GetDin := 1;
            GetWords := 1;
            SRAM_BW4 := SRAM_BW3 & SRAM_BW2 & SRAM_BW1 & SRAM_BW0; --active low
         end if;
         if (GetDin >= 3 and GetWords > 0) then
            if (SRAM_BW4(3) = '0') then ZBT_OUT(35) <= ZBT_IN(35); ZBT_OUT(31 downto 24) <= ZBT_IN(31 downto 24); end if;
            if (SRAM_BW4(2) = '0') then ZBT_OUT(34) <= ZBT_IN(34); ZBT_OUT(23 downto 16) <= ZBT_IN(23 downto 16); end if;
            if (SRAM_BW4(1) = '0') then ZBT_OUT(33) <= ZBT_IN(33); ZBT_OUT(15 downto 8) <= ZBT_IN(15 downto 8); end if;
            if (SRAM_BW4(0) = '0') then ZBT_OUT(32) <= ZBT_IN(32); ZBT_OUT(7 downto 0) <= ZBT_IN(7 downto 0); end if;
            GetWords := GetWords - 1;
         end if;
      end if;
   end process ZBT_dout;
   
   
   
   Control : process (reset, clk)
      variable WaitACK : std_logic;
      variable State, ack_count : integer;
      variable wb_adr_i2 : std_logic_vector(15 downto 0);
   begin
      if (reset = '1') then
         wb_adr_i2 := x"0000";
         wb_adr_i <= (others => '0');
         wb_dat_i <= (others => '0');
         wb_sel_i <= (others => '0');
         wb_cti_i <= (others => '0');
         wb_bte_i <= (others => '0');
         wb_cyc_i <= '0';
         wb_stb_i <= '0';
         wb_we_i <= '0';
         wb_tga_i <= '0';
         
         ack_count := 0;
         WaitACK := '0';
         State := 0;
      elsif (clk = '1' and clk'event) then
         if (WaitACK = '1') then
            if (wb_ack_o = '1') then
               if (ack_count /= 0) then
                  if (ack_count /= 1) then
                     if (wb_we_i='1') then wb_dat_i <= wb_dat_i + 1; end if;
                     wb_adr_i2 := wb_adr_i2 + 1;
                  end if;
                  if (ack_count = 2 and wb_tga_i = '0') then wb_cti_i <= "111"; wb_sel_i <= "0001"; end if;
                  ack_count := ack_count - 1;
               end if;

               if (ack_count = 0) then
                  WaitACK := '0';
                  wb_cyc_i <= '0';
                  wb_stb_i <= '0';
               end if;
            end if;
         end if;
         
         if (WaitACK = '0') then
            case State is
               when 0 => --single word write as a EOB cycle
                  wb_adr_i2 := x"1234"; wb_we_i <= '1'; wb_tga_i <= '0'; wb_cti_i <= "111";
                  wb_sel_i <= "1111"; wb_dat_i <= x"123456789"; ack_count := 0;
                  WaitACK := '1'; State := State + 1;
               when 1 => --single word read as a classic cycle
                  wb_adr_i2 := x"ABCD"; wb_we_i <= '0'; wb_tga_i <= '0'; wb_cti_i <= "000"; --classic cycle
                  WaitACK := '1'; State := State + 1; ack_count := 0;
               when 2 => --single half-word write as a classic cycle
                  wb_adr_i2 := x"4321"; wb_we_i <= '1'; wb_tga_i <= '0'; wb_cti_i <= "000"; --classic cycle
                  wb_sel_i <= "0011"; wb_dat_i <= x"987654321";
                  WaitACK := '1'; State := State + 1; ack_count := 0;
               when 3 => --single word read as a EOB cycle
                  wb_adr_i2 := x"DCBA"; wb_we_i <= '0'; wb_tga_i <= '0'; wb_cti_i <= "111";
                  WaitACK := '1'; State := State + 1; ack_count := 0;
               when 4 => --1 burst write
                  wb_adr_i2 := x"4567"; wb_we_i <= '1'; wb_tga_i <= '0'; wb_cti_i <= "010";
                  wb_sel_i <= "1111"; wb_dat_i <= wb_dat_o + 1;
                  WaitACK := '1'; State := State + 1; ack_count := 4;
               when 5 => --3 bursts read --> first
                  wb_adr_i2 := x"90AB"; wb_we_i <= '0'; wb_tga_i <= '1'; wb_cti_i <= "010";
                  WaitACK := '1'; State := State + 1; ack_count := 4;
               when 6 => --3 bursts read --> second
                  wb_adr_i2 := x"90AF"; wb_we_i <= '0'; wb_tga_i <= '1'; wb_cti_i <= "010";
                  WaitACK := '1'; State := State + 1; ack_count := 4;
               when 7 => --3 bursts read --> third
                  wb_adr_i2 := x"90B3"; wb_we_i <= '0'; wb_tga_i <= '0'; wb_cti_i <= "010";
                  WaitACK := '1'; State := State + 1; ack_count := 4;
               when others =>
                  if (State = 15) then report "NORMAL TB END." severity FAILURE; end if;            
                  State := State + 1;
            end case;         
         end if;
         if (WaitACK = '1') then wb_cyc_i <= '1'; wb_stb_i <= '1'; end if;
         wb_adr_i <= "00" & wb_adr_i2;
      end if;
   end process Control;




   -- The following lines are to have a handy std_logic_vector to read and write data to ZBT
   -- instead of having 72 individual signals on a wave window
   
   ---------------------------------
   --  DATA OUT LINES
   ---------------------------------
   SRAM_FLASH_D0 <= ZBT_OUT(0) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D1 <= ZBT_OUT(1) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D2 <= ZBT_OUT(2) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D3 <= ZBT_OUT(3) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D4 <= ZBT_OUT(4) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D5 <= ZBT_OUT(5) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D6 <= ZBT_OUT(6) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D7 <= ZBT_OUT(7) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D8 <= ZBT_OUT(8) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D9 <= ZBT_OUT(9) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D10 <= ZBT_OUT(10) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D11 <= ZBT_OUT(11) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D12 <= ZBT_OUT(12) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D13 <= ZBT_OUT(13) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D14 <= ZBT_OUT(14) when (SRAM_OE_B = '0') else 'Z';
   SRAM_FLASH_D15 <= ZBT_OUT(15) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D16 <= ZBT_OUT(16) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D17 <= ZBT_OUT(17) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D18 <= ZBT_OUT(18) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D19 <= ZBT_OUT(19) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D20 <= ZBT_OUT(20) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D21 <= ZBT_OUT(21) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D22 <= ZBT_OUT(22) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D23 <= ZBT_OUT(23) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D24 <= ZBT_OUT(24) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D25 <= ZBT_OUT(25) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D26 <= ZBT_OUT(26) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D27 <= ZBT_OUT(27) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D28 <= ZBT_OUT(28) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D29 <= ZBT_OUT(29) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D30 <= ZBT_OUT(30) when (SRAM_OE_B = '0') else 'Z';
   SRAM_D31 <= ZBT_OUT(31) when (SRAM_OE_B = '0') else 'Z';
   SRAM_DQP0 <= ZBT_OUT(32) when (SRAM_OE_B = '0') else 'Z';
   SRAM_DQP1 <= ZBT_OUT(33) when (SRAM_OE_B = '0') else 'Z';
   SRAM_DQP2 <= ZBT_OUT(34) when (SRAM_OE_B = '0') else 'Z';
   SRAM_DQP3 <= ZBT_OUT(35) when (SRAM_OE_B = '0') else 'Z';
   

   ---------------------------------
   --  DATA IN LINES
   ---------------------------------
   ZBT_IN(0) <= SRAM_FLASH_D0;
   ZBT_IN(1) <= SRAM_FLASH_D1;
   ZBT_IN(2) <= SRAM_FLASH_D2;
   ZBT_IN(3) <= SRAM_FLASH_D3;
   ZBT_IN(4) <= SRAM_FLASH_D4;
   ZBT_IN(5) <= SRAM_FLASH_D5;
   ZBT_IN(6) <= SRAM_FLASH_D6;
   ZBT_IN(7) <= SRAM_FLASH_D7;
   ZBT_IN(8) <= SRAM_FLASH_D8;
   ZBT_IN(9) <= SRAM_FLASH_D9;
   ZBT_IN(10) <= SRAM_FLASH_D10;
   ZBT_IN(11) <= SRAM_FLASH_D11;
   ZBT_IN(12) <= SRAM_FLASH_D12;
   ZBT_IN(13) <= SRAM_FLASH_D13;
   ZBT_IN(14) <= SRAM_FLASH_D14;
   ZBT_IN(15) <= SRAM_FLASH_D15;
   ZBT_IN(16) <= SRAM_D16;
   ZBT_IN(17) <= SRAM_D17;
   ZBT_IN(18) <= SRAM_D18;
   ZBT_IN(19) <= SRAM_D19;
   ZBT_IN(20) <= SRAM_D20;
   ZBT_IN(21) <= SRAM_D21;
   ZBT_IN(22) <= SRAM_D22;
   ZBT_IN(23) <= SRAM_D23;
   ZBT_IN(24) <= SRAM_D24;
   ZBT_IN(25) <= SRAM_D25;
   ZBT_IN(26) <= SRAM_D26;
   ZBT_IN(27) <= SRAM_D27;
   ZBT_IN(28) <= SRAM_D28;
   ZBT_IN(29) <= SRAM_D29;
   ZBT_IN(30) <= SRAM_D30;
   ZBT_IN(31) <= SRAM_D31;
   ZBT_IN(32) <= SRAM_DQP0;
   ZBT_IN(33) <= SRAM_DQP1;
   ZBT_IN(34) <= SRAM_DQP2;
   ZBT_IN(35) <= SRAM_DQP3;


   
   ---------------------------------
   --  ADDRESS LINES
   ---------------------------------
   ZBT_ADDR(0) <= SRAM_FLASH_A1;
   ZBT_ADDR(1) <= SRAM_FLASH_A2;
   ZBT_ADDR(2) <= SRAM_FLASH_A3;
   ZBT_ADDR(3) <= SRAM_FLASH_A4;
   ZBT_ADDR(4) <= SRAM_FLASH_A5;
   ZBT_ADDR(5) <= SRAM_FLASH_A6;
   ZBT_ADDR(6) <= SRAM_FLASH_A7;
   ZBT_ADDR(7) <= SRAM_FLASH_A8;
   ZBT_ADDR(8) <= SRAM_FLASH_A9;
   ZBT_ADDR(9) <= SRAM_FLASH_A10;
   ZBT_ADDR(10) <= SRAM_FLASH_A11;
   ZBT_ADDR(11) <= SRAM_FLASH_A12;
   ZBT_ADDR(12) <= SRAM_FLASH_A13;
   ZBT_ADDR(13) <= SRAM_FLASH_A14;
   ZBT_ADDR(14) <= SRAM_FLASH_A15;
   ZBT_ADDR(15) <= SRAM_FLASH_A16;
   ZBT_ADDR(16) <= SRAM_FLASH_A17;
   ZBT_ADDR(17) <= SRAM_FLASH_A18;
END;
