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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- WB: MASTER MUST NOT insert wait states!
-- WB: maximum burst length is 4 (but bursts may follow without wait states in between)

entity zbt_top is
    Port (  clk : in STD_LOGIC;
            reset : in STD_LOGIC;

            SRAM_CLK : out STD_LOGIC; --Synchronous Clock (up to 200 MHz)

            --A burst mode pin (MODE) defines the order of the burst sequence. When tied HIGH, the interleaved burst sequence is selected.
            --When tied LOW, the linear burst sequence is selected.
            SRAM_MODE : out STD_LOGIC; --Burst Sequence Selection (pulled down on PCB)
            
            SRAM_CS_B : out STD_LOGIC; --Synchronous Chip Enable (CE\, pulled up on PCB)
            
            --For write cycles following read cycles, the output buffers must be disabled with OE\, otherwise data bus contention will occur
            SRAM_OE_B : out STD_LOGIC; --Output Enable (OE\, pulled up on PCB)
            
            --Write cycles are internally self-timed and are initiated by the rising edge of the clock inputs and when WE\ is LOW.
            SRAM_FLASH_WE_B : out STD_LOGIC; --Synchronous Read/Write Control Input (pulled up on PCB)
            
            --All Read, Write and Deselect cycles are initiated by the ADV input. When the ADV input is HIGH the internal
            --burst counter is incremented. New external addresses can be loaded when ADV is LOW.
            SRAM_ADV_LD_B : out STD_LOGIC; --Synchronous Burst Address Advance/Load (pulled down on PCB)


            SRAM_BW0 : out STD_LOGIC; --Synchronous Byte Write Enable 0 (active low)
            SRAM_BW1 : out STD_LOGIC; --Synchronous Byte Write Enable 1 (active low)
            SRAM_BW2 : out STD_LOGIC; --Synchronous Byte Write Enable 2 (active low)
            SRAM_BW3 : out STD_LOGIC; --Synchronous Byte Write Enable 3 (active low)
            
            --SRAM_FLASH_A0 : out STD_LOGIC; --not connected to SRAM!
            SRAM_FLASH_A1 : out STD_LOGIC; --Synchronous Address Input 0
            SRAM_FLASH_A2 : out STD_LOGIC; --Synchronous Address Input 1
            SRAM_FLASH_A3 : out STD_LOGIC;
            SRAM_FLASH_A4 : out STD_LOGIC;
            SRAM_FLASH_A5 : out STD_LOGIC;
            SRAM_FLASH_A6 : out STD_LOGIC;
            SRAM_FLASH_A7 : out STD_LOGIC;
            SRAM_FLASH_A8 : out STD_LOGIC;
            SRAM_FLASH_A9 : out STD_LOGIC;
            SRAM_FLASH_A10 : out STD_LOGIC;
            SRAM_FLASH_A11 : out STD_LOGIC;
            SRAM_FLASH_A12 : out STD_LOGIC;
            SRAM_FLASH_A13 : out STD_LOGIC;
            SRAM_FLASH_A14 : out STD_LOGIC;
            SRAM_FLASH_A15 : out STD_LOGIC;
            SRAM_FLASH_A16 : out STD_LOGIC;
            SRAM_FLASH_A17 : out STD_LOGIC;
            SRAM_FLASH_A18 : out STD_LOGIC;
            
            SRAM_FLASH_D0 : inout STD_LOGIC;
            SRAM_FLASH_D1 : inout STD_LOGIC;
            SRAM_FLASH_D2 : inout STD_LOGIC;
            SRAM_FLASH_D3 : inout STD_LOGIC;
            SRAM_FLASH_D4 : inout STD_LOGIC;
            SRAM_FLASH_D5 : inout STD_LOGIC;
            SRAM_FLASH_D6 : inout STD_LOGIC;
            SRAM_FLASH_D7 : inout STD_LOGIC;
            SRAM_FLASH_D8 : inout STD_LOGIC;
            SRAM_FLASH_D9 : inout STD_LOGIC;
            SRAM_FLASH_D10 : inout STD_LOGIC;
            SRAM_FLASH_D11 : inout STD_LOGIC;
            SRAM_FLASH_D12 : inout STD_LOGIC;
            SRAM_FLASH_D13 : inout STD_LOGIC;
            SRAM_FLASH_D14 : inout STD_LOGIC;
            SRAM_FLASH_D15 : inout STD_LOGIC;
            SRAM_D16 : inout STD_LOGIC;
            SRAM_D17 : inout STD_LOGIC;
            SRAM_D18 : inout STD_LOGIC;
            SRAM_D19 : inout STD_LOGIC;
            SRAM_D20 : inout STD_LOGIC;
            SRAM_D21 : inout STD_LOGIC;
            SRAM_D22 : inout STD_LOGIC;
            SRAM_D23 : inout STD_LOGIC;
            SRAM_D24 : inout STD_LOGIC;
            SRAM_D25 : inout STD_LOGIC;
            SRAM_D26 : inout STD_LOGIC;
            SRAM_D27 : inout STD_LOGIC;
            SRAM_D28 : inout STD_LOGIC;
            SRAM_D29 : inout STD_LOGIC;
            SRAM_D30 : inout STD_LOGIC;
            SRAM_D31 : inout STD_LOGIC;

            SRAM_DQP0 : inout STD_LOGIC; --Parity Data I/O 0
            SRAM_DQP1 : inout STD_LOGIC; --Parity Data I/O 1
            SRAM_DQP2 : inout STD_LOGIC; --Parity Data I/O 2
            SRAM_DQP3 : inout STD_LOGIC; --Parity Data I/O 3
            
           

            wb_adr_i : in std_logic_vector(17 downto 0);
            wb_we_i : in std_logic;
            wb_dat_i : in std_logic_vector(35 downto 0);
            wb_sel_i : in std_logic_vector(3 downto 0);
            wb_dat_o : out std_logic_vector(35 downto 0);
            wb_cyc_i : in std_logic;
            wb_stb_i : in std_logic;
            wb_cti_i : in std_logic_vector(2 downto 0);
            wb_bte_i : in std_logic_vector(1 downto 0);
            wb_ack_o : out std_logic;
            wb_err_o : out std_logic;
            wb_tga_i: in std_logic := '0' --'0' to mean last (or single) 4 words burst
           
           );
end zbt_top;

architecture Behavioral of zbt_top is
   signal ZBT_addr, ZBT_addr2  : std_logic_vector(17 downto 0);
   signal ZBT_din, ZBT_din2, ZBT_din1 : std_logic_vector(35 downto 0);
   signal ZBT_dout : std_logic_vector(35 downto 0);
   signal BW_enable, SRAM_OE_B2 : std_logic;
   
   signal State : integer;
   
   constant IDLE : integer := 0;
   constant C1 : integer := 1;
   constant C2 : integer := 2;
   constant C3 : integer := 3;
   constant C4 : integer := 4;
   constant B1 : integer := 5;
   constant B2 : integer := 6;
   constant B3 : integer := 7;
   constant B4 : integer := 8;
   constant B5 : integer := 9;
   constant B6 : integer := 10;
   constant B4L : integer := 11;
   constant B5L : integer := 12;
   constant B6L : integer := 13;
   constant B0W : integer := 14;
   constant B1W : integer := 15;
   constant B2W : integer := 16;
   constant B3W : integer := 17;
   constant B4WL : integer := 18;
   constant B5WL : integer := 19;
begin

   FSM_State_Control : process (clk, reset)
   begin
      if (reset = '1') then
         State <= IDLE;
      elsif (clk = '1' and clk'event) then
         case State is
            when IDLE =>
               if (wb_cyc_i = '1' and wb_stb_i = '1') then --start of WB cycle?
                  if (wb_bte_i /= "00" or wb_cti_i /= "010") then --classic cycle
                     --(WB rule 4.25, only linear bursts accepted, WB permission 4.40: EOB=single access~=sync.classic cycle, WB rule 4.10: unknown=classic cycles)
                     --we were in idle state, so any classic cycle, EOB cycle or any cycle with a non linear burst is executed as a classic one
                     State <= C1;
                  else --Incrementing burst cycle with linear burst type
                     assert (wb_bte_i = "00" and wb_cti_i="010") report "Bad else on IDLE state (cti=" & integer'image(conv_integer(wb_cti_i)) & ", bte=" & integer'image(conv_integer(wb_bte_i)) & ")" severity FAILURE;
                     if (wb_we_i = '0') then --wb burst read?
                        State <= B1;
                     else --wb burst write?
                        State <= B0W;
                     end if;
                  end if;
               else
                  State <= IDLE;
               end if;
            
            --start single word read/write
            when C1 =>
               if (wb_cyc_i = '1' and wb_stb_i = '1') then State <= C2; else State <= IDLE; end if;
            when C2 => --wb_ack <= '1' in this cycle
               if (wb_cyc_i = '1' and wb_stb_i = '1') then State <= C3; else State <= IDLE; end if;
            when C3 => --wb_ack = '1' in this cycle
               State <= C4;
            when C4 =>
               State <= IDLE;

               
            --Burst read
            when B1 =>
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then State <= B2; else State <= IDLE; end if;
            when B2 =>
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then State <= B3; else State <= IDLE; end if;
            when B3 =>
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then
                  if (wb_tga_i = '0') then --last burst?
                     State <= B4L;
                  else
                     State <= B4;
                  end if;
               else
                  State <= IDLE;
               end if;
            when B4 =>
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then State <= B5; else State <= IDLE; end if;
            when B5 =>
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then State <= B6; else State <= IDLE; end if;
            when B6 => --go back to B3
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then State <= B3; else State <= IDLE; end if;
            --last burst read
            when B4L =>
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then State <= B5L; else State <= IDLE; end if;
            when B5L =>
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then State <= B6L; else State <= IDLE; end if;
            when B6L =>  --in this cycle wb_cti_i must be 111 because the ZBT has a burst length of 4
               State <= IDLE;
               
            --Burst write   
            when B0W =>
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then State <= B1W; else State <= IDLE; end if;
            when B1W =>
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then State <= B2W; else State <= IDLE; end if;
            when B2W =>
               if (wb_cyc_i = '1' and wb_stb_i = '1' and wb_cti_i /= "111") then State <= B3W; else State <= IDLE; end if;
            when B3W =>
               if (wb_cyc_i = '1' and wb_stb_i = '1') then --wb_cti should be "111" if it is the last burst
                  if (wb_tga_i = '0') then --last burst?
                     State <= B4WL;
                  else
                     State <= B0W;
                  end if;
               else
                  State <= IDLE;
               end if;
            
            --last burst write
            when B4WL => --don't check cti as it was 111 in B3W for the last burst!
               State <= B5WL;
            when B5WL =>
               State <= IDLE;

            when others =>
               report "Bad state on FSM_State_Control " & integer'image(State) severity FAILURE;
         end case;
      end if;
   end process FSM_State_Control;



   Wishbone_Slave_Control : process (clk, reset)
   begin
      if (reset = '1') then
         wb_ack_o <= '0';
         wb_err_o <= '0';
      elsif (clk = '1' and clk'event) then
         wb_err_o <= '0';         
         case State is
            when IDLE =>
               if (wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='1' and wb_bte_i="00" and wb_cti_i="010") then --burst write cycle?
                  wb_ack_o <= '1'; --preack the master to have it give us the next wb_sel_i and wb_dat_i signals
               else
                  wb_ack_o <= '0';
               end if;

            when C1 | C3 | C4 | B1 | B6L | B4WL | B5WL => --in the case of bursts cyc MUST be lowered after cti="111"
               wb_ack_o <= '0'; --in the case of classic cycles, we have C3 and C4 where ack is lowered, to make the master lower cyc

            when C2 | B2 | B3 | B4 | B5 | B6 | B4L | B5L | B0W | B1W | B2W =>
               wb_ack_o <= wb_cyc_i and wb_stb_i; --ack should be 1, but it will only go up if cyc and stb are so

            when B3W => --last write burst?
               wb_ack_o <= wb_tga_i and wb_cyc_i and wb_stb_i; --ack should be 1, but it will only go up if cyc and stb are so (and if it is not the last burst)

            when others =>
               report "Bad state on WB_Slave_Control " & integer'image(State) severity FAILURE;
         end case;
      end if;
   end process Wishbone_Slave_Control;

   wb_dat_o <= ZBT_dout;
   
   ZBT_SRAM_Control : process (clk, reset)
      variable vBW_enable : std_logic;
   begin
      if (reset = '1') then
         SRAM_ADV_LD_B <= '0';
         SRAM_CS_B <= '1'; --chip NOT selected
         SRAM_FLASH_WE_B <= '1'; --DON'T write anything
         
         --by default output is not enabled to avoid bus contemption with the wb master
         SRAM_OE_B2 <= '1'; --output NOT enabled
         
         ZBT_addr <= (others => '0');
         ZBT_addr2 <= (others => '0');
         
         ZBT_din2 <= (others => '0');
         ZBT_din1 <= (others => '0');
         ZBT_din <= (others => '0');
         
         BW_enable <= '0';
         vBW_enable := '0';
         SRAM_BW0 <= '1';
         SRAM_BW1 <= '1';
         SRAM_BW2 <= '1';
         SRAM_BW3 <= '1';
      elsif (clk = '1' and clk'event) then
         --two stage datain pipeline
         ZBT_din2 <= wb_dat_i;
         ZBT_din1 <= ZBT_din2;
         ZBT_din <= ZBT_din1;
         
         --REASON WHY THERE IS A DATAIN PIPELINE:
         --Based on the ZBT SRAM datasheet:
         --it doesn't make much sense but the "byte write enables" are not fed to the ZBT
         --at the same time than the data to be written, so the wb_sel_i lines arrive late
         --(because they arrive, obviously, at the same time than their associated wb_dat_i lines)
         --which is 2 cycles later than when they should be fed to the ZBT
         --the only solution is, on wb writes:
         -- 1) start wb_acking soon (to have the master give us soon enough the right wb_sel lines for each data word to write)
         -- 2) make two registers to have a two stage pipeline for the data words in order to feed them to the ZBT at the 3rd cycle
         -- this means 72 extra FFs for the registers and a more complex wb slave logic (differentiate if read or write)
         -- there would be the same number of acks but the 2 cycles response latency would happen at the end of the last burst of the wb write
      
         case State is
            when IDLE => --prepare signals for next cycle
               vBW_enable := '0';
               SRAM_ADV_LD_B <= '0';
               if (wb_cyc_i = '1' and wb_stb_i = '1') then
                  ZBT_addr <= wb_adr_i;
                  ZBT_addr2 <= wb_adr_i + x"4";
                  if (wb_bte_i /= "00" or wb_cti_i /= "010") then --classic cycle?
                     SRAM_CS_B <= '0'; --chip selected
                     SRAM_OE_B2 <= wb_we_i; --if it's a read -> enable outputs
                     SRAM_FLASH_WE_B <= not wb_we_i;
                     vBW_enable := wb_we_i;
                  else --burst
                     if (wb_we_i = '0') then --wb burst read?
                        SRAM_CS_B <= '0'; --chip selected
                        SRAM_OE_B2 <= wb_we_i; --if it's a read -> enable outputs
                        SRAM_FLASH_WE_B <= not wb_we_i;
                     else --wb burst write? start ZBT in B0W but get now ZBT_addr2!
                        ZBT_addr2 <= wb_adr_i; --important because ZBT_addr2 will be assigned in next cycle (so don't sum 4 to it)
                        SRAM_CS_B <= '1'; --chip NOT selected
                        SRAM_OE_B2 <= '1'; --output NOT enabled for next cycle
                        SRAM_FLASH_WE_B <= '1'; --DON'T write anything
                     end if;
                  end if;
               else
                  SRAM_CS_B <= '1'; --chip NOT selected
                  SRAM_OE_B2 <= '1'; --output NOT enabled for next cycle
                  SRAM_FLASH_WE_B <= '1'; --DON'T write anything
                  ZBT_addr <= (others => '0');
                  ZBT_addr2 <= (others => '0');
               end if;
               
               
            when C1 | C2 =>
               SRAM_CS_B <= '1'; --chip NOT selected (doesn't affect current op.: don't care in datasheet)
               SRAM_ADV_LD_B <= '0'; --NOT a burst
               --SRAM_OE_B2 keep the selected output enable for the current WB operation
               vBW_enable := '0'; --it only matters for the ADV=0 cycle of the ZBT operation
               
            when C3 | C4 =>
               SRAM_CS_B <= '1'; --chip NOT selected (doesn't affect current op.: don't care in datasheet)
               SRAM_ADV_LD_B <= '0'; --NOT a burst
               SRAM_OE_B2 <= '1'; --output NOT enabled for next cycle
               vBW_enable := '0';



            when B1 | B2 | B3 | B5 | B6 =>
               SRAM_ADV_LD_B <= '1';
               
            when B4 => --precharge address for next 4 word burst
               SRAM_ADV_LD_B <= '0';
               ZBT_addr <= ZBT_addr2;
               ZBT_addr2 <= ZBT_addr2 + x"4";
            
            when B4L | B5L | B6L => --last burst
               SRAM_ADV_LD_B <= '0';
               SRAM_CS_B <= '1'; --chip NOT selected
            
            
            when B0W => --a wb write starts here
               SRAM_ADV_LD_B <= '0'; --first write cycle
               SRAM_OE_B2 <= '1'; --keep output NOT enabled (it's a write)
               SRAM_CS_B <= '0'; --chip selected
               SRAM_FLASH_WE_B <= '0'; --start writing
               ZBT_addr <= ZBT_addr2;
               ZBT_addr2 <= ZBT_addr2 + x"4";
               vBW_enable := '1';
            
            when B1W | B2W | B3W =>
               SRAM_ADV_LD_B <= '1';
               vBW_enable := '1';
               
            when B4WL | B5WL =>
               SRAM_CS_B <= '1'; --chip NOT selected (don't care in datasheet)
               SRAM_FLASH_WE_B <= '1'; --DON'T write (don't care in datasheet)
               SRAM_ADV_LD_B <= '0';
               vBW_enable := '0';
            
            when others =>
               report "Bad state on ZBT_SRAM_Control " & integer'image(State) severity FAILURE;
         end case;
         
         BW_enable <= vBW_enable;
         --Byte write enables are active low
         SRAM_BW0 <= not (wb_sel_i(0) and vBW_enable);
         SRAM_BW1 <= not (wb_sel_i(1) and vBW_enable);
         SRAM_BW2 <= not (wb_sel_i(2) and vBW_enable);
         SRAM_BW3 <= not (wb_sel_i(3) and vBW_enable);         
      end if;
   end process ZBT_SRAM_Control;   


   
   SRAM_CLK <= clk;
   SRAM_MODE <= '0'; --linear bursts
   SRAM_OE_B <= SRAM_OE_B2; --to let OE_B2 be read to mux the data lines


   ---------------------------------
   --  DATA IN LINES
   ---------------------------------
   SRAM_FLASH_D0 <= ZBT_din(0) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D1 <= ZBT_din(1) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D2 <= ZBT_din(2) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D3 <= ZBT_din(3) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D4 <= ZBT_din(4) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D5 <= ZBT_din(5) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D6 <= ZBT_din(6) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D7 <= ZBT_din(7) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D8 <= ZBT_din(8) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D9 <= ZBT_din(9) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D10 <= ZBT_din(10) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D11 <= ZBT_din(11) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D12 <= ZBT_din(12) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D13 <= ZBT_din(13) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D14 <= ZBT_din(14) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_FLASH_D15 <= ZBT_din(15) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D16 <= ZBT_din(16) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D17 <= ZBT_din(17) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D18 <= ZBT_din(18) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D19 <= ZBT_din(19) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D20 <= ZBT_din(20) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D21 <= ZBT_din(21) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D22 <= ZBT_din(22) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D23 <= ZBT_din(23) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D24 <= ZBT_din(24) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D25 <= ZBT_din(25) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D26 <= ZBT_din(26) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D27 <= ZBT_din(27) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D28 <= ZBT_din(28) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D29 <= ZBT_din(29) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D30 <= ZBT_din(30) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_D31 <= ZBT_din(31) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_DQP0 <= ZBT_din(32) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_DQP1 <= ZBT_din(33) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_DQP2 <= ZBT_din(34) when (SRAM_OE_B2 = '1') else 'Z';
   SRAM_DQP3 <= ZBT_din(35) when (SRAM_OE_B2 = '1') else 'Z';
   

   ---------------------------------
   --  DATA OUT LINES
   ---------------------------------
   ZBT_dout(0) <= SRAM_FLASH_D0;
   ZBT_dout(1) <= SRAM_FLASH_D1;
   ZBT_dout(2) <= SRAM_FLASH_D2;
   ZBT_dout(3) <= SRAM_FLASH_D3;
   ZBT_dout(4) <= SRAM_FLASH_D4;
   ZBT_dout(5) <= SRAM_FLASH_D5;
   ZBT_dout(6) <= SRAM_FLASH_D6;
   ZBT_dout(7) <= SRAM_FLASH_D7;
   ZBT_dout(8) <= SRAM_FLASH_D8;
   ZBT_dout(9) <= SRAM_FLASH_D9;
   ZBT_dout(10) <= SRAM_FLASH_D10;
   ZBT_dout(11) <= SRAM_FLASH_D11;
   ZBT_dout(12) <= SRAM_FLASH_D12;
   ZBT_dout(13) <= SRAM_FLASH_D13;
   ZBT_dout(14) <= SRAM_FLASH_D14;
   ZBT_dout(15) <= SRAM_FLASH_D15;
   ZBT_dout(16) <= SRAM_D16;
   ZBT_dout(17) <= SRAM_D17;
   ZBT_dout(18) <= SRAM_D18;
   ZBT_dout(19) <= SRAM_D19;
   ZBT_dout(20) <= SRAM_D20;
   ZBT_dout(21) <= SRAM_D21;
   ZBT_dout(22) <= SRAM_D22;
   ZBT_dout(23) <= SRAM_D23;
   ZBT_dout(24) <= SRAM_D24;
   ZBT_dout(25) <= SRAM_D25;
   ZBT_dout(26) <= SRAM_D26;
   ZBT_dout(27) <= SRAM_D27;
   ZBT_dout(28) <= SRAM_D28;
   ZBT_dout(29) <= SRAM_D29;
   ZBT_dout(30) <= SRAM_D30;
   ZBT_dout(31) <= SRAM_D31;
   ZBT_dout(32) <= SRAM_DQP0;
   ZBT_dout(33) <= SRAM_DQP1;
   ZBT_dout(34) <= SRAM_DQP2;
   ZBT_dout(35) <= SRAM_DQP3;

   
   ---------------------------------
   --  ADDRESS LINES
   ---------------------------------
   SRAM_FLASH_A1 <= ZBT_addr(0);
   SRAM_FLASH_A2 <= ZBT_addr(1);
   SRAM_FLASH_A3 <= ZBT_addr(2);
   SRAM_FLASH_A4 <= ZBT_addr(3);
   SRAM_FLASH_A5 <= ZBT_addr(4);
   SRAM_FLASH_A6 <= ZBT_addr(5);
   SRAM_FLASH_A7 <= ZBT_addr(6);
   SRAM_FLASH_A8 <= ZBT_addr(7);
   SRAM_FLASH_A9 <= ZBT_addr(8);
   SRAM_FLASH_A10 <= ZBT_addr(9);
   SRAM_FLASH_A11 <= ZBT_addr(10);
   SRAM_FLASH_A12 <= ZBT_addr(11);
   SRAM_FLASH_A13 <= ZBT_addr(12);
   SRAM_FLASH_A14 <= ZBT_addr(13);
   SRAM_FLASH_A15 <= ZBT_addr(14);
   SRAM_FLASH_A16 <= ZBT_addr(15);
   SRAM_FLASH_A17 <= ZBT_addr(16);
   SRAM_FLASH_A18 <= ZBT_addr(17);

end Behavioral;

