-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: generic_counter.vhd
--| Version: 0.1
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   CONTROL - Counter
--|   This is a simple counter
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1   | jul-2009 | First release
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------





--==================================================================================================
-- TODO
-- · ...
--==================================================================================================


library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
--use ieee.math_real.all





entity generic_counter is
  generic(
    OUTPUT_WIDTH: integer := 32 -- Output width for counter.
  );
  port(  
    clk_I:    in  std_logic;
    count_O:  out std_logic_vector( OUTPUT_WIDTH-1  downto 0);
    reset_I:  in  std_logic;
    enable_I: in  std_logic
  );
end entity generic_counter;




architecture arch01 of generic_counter is
  signal count: std_logic_vector( OUTPUT_WIDTH-1  downto 0);
begin
  
  count_O <= count; 
  
  P_count: process(clk_I, reset_I, count, enable_I)
  begin
    if clk_I'event and clk_I = '1' and clk_I'LAST_VALUE = '0' then      
      if reset_I = '1' then
        count <= (others => '0');
      elsif enable_I = '1' then
        count <= count + 1;
      end if;
    end if;
  end process;
  
end architecture;






-- Report for cell generic_counter.arch01
--   Core Cell usage:
--               cell count     area count*area
--               AOI1     2      1.0        2.0
--               BUFF     1      1.0        1.0
--                GND     1      0.0        0.0
--               NOR2     1      1.0        1.0
--              NOR2A     1      1.0        1.0
--              NOR2B    11      1.0       11.0
--               NOR3     2      1.0        2.0
--              NOR3B     2      1.0        2.0
--              NOR3C    15      1.0       15.0
--               OR2A    19      1.0       19.0
--               OR2B     3      1.0        3.0
--               OR3B     1      1.0        1.0
--               OR3C     2      1.0        2.0
--                VCC     1      0.0        0.0
--               XA1B     6      1.0        6.0
--               XA1C    24      1.0       24.0
-- 
-- 
--               DFN1    33      1.0       33.0
--                    -----          ----------
--              TOTAL   125               123.0
-- 
-- 
--   IO Cell usage:
--               cell count
--             CLKBUF     1
--              INBUF     1
--             OUTBUF    33
--                    -----
--              TOTAL    35
-- 
-- 
-- Core Cells         : 123 of 38400 (0%)
-- IO Cells           : 35

--                           Requested     Estimated     Requested     Estimated               Clock        Clock              
-- Starting Clock            Frequency     Frequency     Period        Period        Slack     Type         Group              
-- ----------------------------------------------------------------------------------------------------------------------------
-- generic_counter|clk_I     100.0 MHz     110.8 MHz     10.000        9.026         0.974     inferred     Inferred_clkgroup_0
-- ============================================================================================================================







-- -- Version: 8.5 SP1 8.5.1.13
-- 
-- library ieee;
-- use ieee.std_logic_1164.all;
-- library proasic3e;
-- use proasic3e.all;
-- 
-- entity counter is
-- 
--     port( Sload  : in    std_logic;
--           Clock  : in    std_logic;
--           Data   : in    std_logic_vector(14 downto 0);
--           Enable : in    std_logic;
--           Q      : out   std_logic_vector(14 downto 0)
--         );
-- 
-- end counter;
-- 
-- architecture DEF_ARCH of counter is 
-- 
--   component AND2
--     port( A : in    std_logic := 'U';
--           B : in    std_logic := 'U';
--           Y : out   std_logic
--         );
--   end component;
-- 
--   component MX2
--     port( A : in    std_logic := 'U';
--           B : in    std_logic := 'U';
--           S : in    std_logic := 'U';
--           Y : out   std_logic
--         );
--   end component;
-- 
--   component XOR2
--     port( A : in    std_logic := 'U';
--           B : in    std_logic := 'U';
--           Y : out   std_logic
--         );
--   end component;
-- 
--   component AND3
--     port( A : in    std_logic := 'U';
--           B : in    std_logic := 'U';
--           C : in    std_logic := 'U';
--           Y : out   std_logic
--         );
--   end component;
-- 
--   component DFN1E1
--     port( D   : in    std_logic := 'U';
--           CLK : in    std_logic := 'U';
--           E   : in    std_logic := 'U';
--           Q   : out   std_logic
--         );
--   end component;
-- 
--   component INV
--     port( A : in    std_logic := 'U';
--           Y : out   std_logic
--         );
--   end component;
-- 
--   component BUFF
--     port( A : in    std_logic := 'U';
--           Y : out   std_logic
--         );
--   end component;
-- 
--   component OR2
--     port( A : in    std_logic := 'U';
--           B : in    std_logic := 'U';
--           Y : out   std_logic
--         );
--   end component;
-- 
--   component DFN1
--     port( D   : in    std_logic := 'U';
--           CLK : in    std_logic := 'U';
--           Q   : out   std_logic
--         );
--   end component;
-- 
--     signal N_Sload_0, N_Sload_1, N_Q_0, N_Q_1, N_Q_2, N_Q_3, 
--         N_Q_4, N_Q_5, N_Q_6, N_Q_7, N_Q_8, N_INV_Q0_Y, N_LA_0_LA, 
--         N_Q_9, N_Q_10, N_Q_11, N_Q_12, N_Q_13, N_Q_14, AND3_3_Y, 
--         OR2_0_Y, AND3_9_Y, AND2_4_Y, AND2_8_Y, AND2_9_Y, 
--         AND3_11_Y, MX2_6_Y, XOR2_8_Y, MX2_12_Y, XOR2_11_Y, 
--         MX2_10_Y, INV_0_Y, MX2_11_Y, XOR2_0_Y, MX2_8_Y, XOR2_2_Y, 
--         MX2_0_Y, XOR2_6_Y, AND2_2_Y, MX2_9_Y, XOR2_12_Y, 
--         AND2_10_Y, MX2_7_Y, XOR2_5_Y, AND2_6_Y, MX2_1_Y, XOR2_4_Y, 
--         AND2_1_Y, AND3_4_Y, OR2_1_Y, AND3_10_Y, AND2_5_Y, 
--         AND2_0_Y, MX2_2_Y, XOR2_7_Y, MX2_13_Y, INV_1_Y, MX2_15_Y, 
--         XOR2_10_Y, MX2_5_Y, XOR2_1_Y, MX2_14_Y, XOR2_3_Y, 
--         AND2_3_Y, MX2_4_Y, XOR2_9_Y, AND2_7_Y, OR2_2_Y, AND3_5_Y, 
--         MX2_3_Y, AND3_1_Y, AND3_6_Y, AND3_7_Y, AND3_2_Y, AND3_0_Y, 
--         AND3_12_Y, AND3_8_Y : std_logic;
-- 
-- begin 
-- 
--     Q(14) <= N_Q_14;
--     Q(13) <= N_Q_13;
--     Q(12) <= N_Q_12;
--     Q(11) <= N_Q_11;
--     Q(10) <= N_Q_10;
--     Q(9) <= N_Q_9;
--     Q(8) <= N_Q_8;
--     Q(7) <= N_Q_7;
--     Q(6) <= N_Q_6;
--     Q(5) <= N_Q_5;
--     Q(4) <= N_Q_4;
--     Q(3) <= N_Q_3;
--     Q(2) <= N_Q_2;
--     Q(1) <= N_Q_1;
--     Q(0) <= N_Q_0;
-- 
--     AND2_9 : AND2
--       port map(A => N_Q_5, B => N_Q_6, Y => AND2_9_Y);
--     
--     MX2_12 : MX2
--       port map(A => XOR2_11_Y, B => Data(1), S => N_Sload_0, Y
--          => MX2_12_Y);
--     
--     XOR2_9 : XOR2
--       port map(A => N_Q_14, B => AND2_7_Y, Y => XOR2_9_Y);
--     
--     AND3_5 : AND3
--       port map(A => AND3_6_Y, B => AND3_7_Y, C => AND3_2_Y, Y => 
--         AND3_5_Y);
--     
--     AND3_10 : AND3
--       port map(A => N_Q_10, B => N_Q_11, C => N_Q_12, Y => 
--         AND3_10_Y);
--     
--     MX2_10 : MX2
--       port map(A => INV_0_Y, B => Data(2), S => N_Sload_0, Y => 
--         MX2_10_Y);
--     
--     DFN1E1_N_Q_2 : DFN1E1
--       port map(D => MX2_10_Y, CLK => Clock, E => OR2_0_Y, Q => 
--         N_Q_2);
--     
--     MX2_7 : MX2
--       port map(A => XOR2_5_Y, B => Data(7), S => N_Sload_0, Y => 
--         MX2_7_Y);
--     
--     MX2_15 : MX2
--       port map(A => XOR2_10_Y, B => Data(11), S => N_Sload_1, Y
--          => MX2_15_Y);
--     
--     DFN1E1_N_Q_6 : DFN1E1
--       port map(D => MX2_9_Y, CLK => Clock, E => OR2_0_Y, Q => 
--         N_Q_6);
--     
--     XOR2_1 : XOR2
--       port map(A => N_Q_12, B => AND2_0_Y, Y => XOR2_1_Y);
--     
--     XOR2_10 : XOR2
--       port map(A => N_Q_11, B => N_Q_10, Y => XOR2_10_Y);
--     
--     DFN1E1_N_LA_0_LA : DFN1E1
--       port map(D => MX2_3_Y, CLK => Clock, E => OR2_2_Y, Q => 
--         N_LA_0_LA);
--     
--     AND3_2 : AND3
--       port map(A => Data(6), B => Data(7), C => Data(8), Y => 
--         AND3_2_Y);
--     
--     AND2_0 : AND2
--       port map(A => N_Q_10, B => N_Q_11, Y => AND2_0_Y);
--     
--     XOR2_7 : XOR2
--       port map(A => N_Q_9, B => AND2_5_Y, Y => XOR2_7_Y);
--     
--     MX2_2 : MX2
--       port map(A => XOR2_7_Y, B => Data(9), S => N_Sload_0, Y => 
--         MX2_2_Y);
--     
--     AND3_9 : AND3
--       port map(A => N_Q_2, B => N_Q_3, C => N_Q_4, Y => AND3_9_Y);
--     
--     DFN1E1_N_Q_3 : DFN1E1
--       port map(D => MX2_11_Y, CLK => Clock, E => OR2_0_Y, Q => 
--         N_Q_3);
--     
--     INV_1 : INV
--       port map(A => N_Q_10, Y => INV_1_Y);
--     
--     U_BUFF_ld_1 : BUFF
--       port map(A => Sload, Y => N_Sload_1);
--     
--     AND2_2 : AND2
--       port map(A => N_Q_4, B => AND2_8_Y, Y => AND2_2_Y);
--     
--     MX2_1 : MX2
--       port map(A => XOR2_4_Y, B => Data(8), S => N_Sload_0, Y => 
--         MX2_1_Y);
--     
--     AND2_8 : AND2
--       port map(A => N_Q_2, B => N_Q_3, Y => AND2_8_Y);
--     
--     AND2_5 : AND2
--       port map(A => Enable, B => N_LA_0_LA, Y => AND2_5_Y);
--     
--     AND3_7 : AND3
--       port map(A => Data(3), B => Data(4), C => Data(5), Y => 
--         AND3_7_Y);
--     
--     AND3_6 : AND3
--       port map(A => Data(0), B => Data(1), C => Data(2), Y => 
--         AND3_6_Y);
--     
--     AND2_4 : AND2
--       port map(A => Enable, B => N_Q_0, Y => AND2_4_Y);
--     
--     AND2_1 : AND2
--       port map(A => AND3_11_Y, B => AND3_9_Y, Y => AND2_1_Y);
--     
--     AND3_11 : AND3
--       port map(A => N_Q_5, B => N_Q_6, C => N_Q_7, Y => AND3_11_Y);
--     
--     AND2_3 : AND2
--       port map(A => N_Q_12, B => AND2_0_Y, Y => AND2_3_Y);
--     
--     MX2_0 : MX2
--       port map(A => XOR2_6_Y, B => Data(5), S => N_Sload_0, Y => 
--         MX2_0_Y);
--     
--     AND2_7 : AND2
--       port map(A => N_Q_13, B => AND3_10_Y, Y => AND2_7_Y);
--     
--     AND3_0 : AND3
--       port map(A => N_INV_Q0_Y, B => N_Q_1, C => N_Q_2, Y => 
--         AND3_0_Y);
--     
--     AND3_12 : AND3
--       port map(A => N_Q_3, B => N_Q_4, C => N_Q_5, Y => AND3_12_Y);
--     
--     AND3_8 : AND3
--       port map(A => N_Q_6, B => N_Q_7, C => N_Q_8, Y => AND3_8_Y);
--     
--     OR2_0 : OR2
--       port map(A => N_Sload_0, B => AND3_3_Y, Y => OR2_0_Y);
--     
--     XOR2_12 : XOR2
--       port map(A => N_Q_6, B => AND2_10_Y, Y => XOR2_12_Y);
--     
--     DFN1E1_N_Q_7 : DFN1E1
--       port map(D => MX2_7_Y, CLK => Clock, E => OR2_0_Y, Q => 
--         N_Q_7);
--     
--     U_BUFF_ld_0 : BUFF
--       port map(A => Sload, Y => N_Sload_0);
--     
--     XOR2_3 : XOR2
--       port map(A => N_Q_13, B => AND2_3_Y, Y => XOR2_3_Y);
--     
--     MX2_5 : MX2
--       port map(A => XOR2_1_Y, B => Data(12), S => N_Sload_1, Y
--          => MX2_5_Y);
--     
--     MX2_14 : MX2
--       port map(A => XOR2_3_Y, B => Data(13), S => N_Sload_1, Y
--          => MX2_14_Y);
--     
--     AND2_6 : AND2
--       port map(A => AND2_9_Y, B => AND3_9_Y, Y => AND2_6_Y);
--     
--     MX2_9 : MX2
--       port map(A => XOR2_12_Y, B => Data(6), S => N_Sload_0, Y
--          => MX2_9_Y);
--     
--     DFN1E1_N_Q_12 : DFN1E1
--       port map(D => MX2_5_Y, CLK => Clock, E => OR2_1_Y, Q => 
--         N_Q_12);
--     
--     DFN1_N_Q_9 : DFN1
--       port map(D => MX2_2_Y, CLK => Clock, Q => N_Q_9);
--     
--     MX2_4 : MX2
--       port map(A => XOR2_9_Y, B => Data(14), S => N_Sload_1, Y
--          => MX2_4_Y);
--     
--     DFN1E1_N_Q_4 : DFN1E1
--       port map(D => MX2_8_Y, CLK => Clock, E => OR2_0_Y, Q => 
--         N_Q_4);
--     
--     DFN1E1_N_Q_11 : DFN1E1
--       port map(D => MX2_15_Y, CLK => Clock, E => OR2_1_Y, Q => 
--         N_Q_11);
--     
--     XOR2_0 : XOR2
--       port map(A => N_Q_3, B => N_Q_2, Y => XOR2_0_Y);
--     
--     AND3_3 : AND3
--       port map(A => Enable, B => N_Q_0, C => N_Q_1, Y => AND3_3_Y);
--     
--     DFN1E1_N_Q_5 : DFN1E1
--       port map(D => MX2_0_Y, CLK => Clock, E => OR2_0_Y, Q => 
--         N_Q_5);
--     
--     AND2_10 : AND2
--       port map(A => N_Q_5, B => AND3_9_Y, Y => AND2_10_Y);
--     
--     U_INV_Q0 : INV
--       port map(A => N_Q_0, Y => N_INV_Q0_Y);
--     
--     AND3_1 : AND3
--       port map(A => AND3_0_Y, B => AND3_12_Y, C => AND3_8_Y, Y
--          => AND3_1_Y);
--     
--     XOR2_5 : XOR2
--       port map(A => N_Q_7, B => AND2_6_Y, Y => XOR2_5_Y);
--     
--     DFN1_N_Q_0 : DFN1
--       port map(D => MX2_6_Y, CLK => Clock, Q => N_Q_0);
--     
--     OR2_1 : OR2
--       port map(A => N_Sload_0, B => AND3_4_Y, Y => OR2_1_Y);
--     
--     XOR2_2 : XOR2
--       port map(A => N_Q_4, B => AND2_8_Y, Y => XOR2_2_Y);
--     
--     DFN1_N_Q_1 : DFN1
--       port map(D => MX2_12_Y, CLK => Clock, Q => N_Q_1);
--     
--     XOR2_6 : XOR2
--       port map(A => N_Q_5, B => AND2_2_Y, Y => XOR2_6_Y);
--     
--     MX2_6 : MX2
--       port map(A => XOR2_8_Y, B => Data(0), S => N_Sload_0, Y => 
--         MX2_6_Y);
--     
--     XOR2_4 : XOR2
--       port map(A => N_Q_8, B => AND2_1_Y, Y => XOR2_4_Y);
--     
--     XOR2_8 : XOR2
--       port map(A => N_Q_0, B => Enable, Y => XOR2_8_Y);
--     
--     DFN1E1_N_Q_8 : DFN1E1
--       port map(D => MX2_1_Y, CLK => Clock, E => OR2_0_Y, Q => 
--         N_Q_8);
--     
--     MX2_13 : MX2
--       port map(A => INV_1_Y, B => Data(10), S => N_Sload_0, Y => 
--         MX2_13_Y);
--     
--     XOR2_11 : XOR2
--       port map(A => N_Q_1, B => AND2_4_Y, Y => XOR2_11_Y);
--     
--     INV_0 : INV
--       port map(A => N_Q_2, Y => INV_0_Y);
--     
--     DFN1E1_N_Q_13 : DFN1E1
--       port map(D => MX2_14_Y, CLK => Clock, E => OR2_1_Y, Q => 
--         N_Q_13);
--     
--     DFN1E1_N_Q_10 : DFN1E1
--       port map(D => MX2_13_Y, CLK => Clock, E => OR2_1_Y, Q => 
--         N_Q_10);
--     
--     DFN1E1_N_Q_14 : DFN1E1
--       port map(D => MX2_4_Y, CLK => Clock, E => OR2_1_Y, Q => 
--         N_Q_14);
--     
--     AND3_4 : AND3
--       port map(A => Enable, B => N_LA_0_LA, C => N_Q_9, Y => 
--         AND3_4_Y);
--     
--     MX2_3 : MX2
--       port map(A => AND3_1_Y, B => AND3_5_Y, S => N_Sload_0, Y
--          => MX2_3_Y);
--     
--     MX2_8 : MX2
--       port map(A => XOR2_2_Y, B => Data(4), S => N_Sload_0, Y => 
--         MX2_8_Y);
--     
--     OR2_2 : OR2
--       port map(A => N_Sload_0, B => Enable, Y => OR2_2_Y);
--     
--     MX2_11 : MX2
--       port map(A => XOR2_0_Y, B => Data(3), S => N_Sload_0, Y => 
--         MX2_11_Y);
--     
-- 
-- end DEF_ARCH; 
-- 
-- --================================================================================================--
-- -- Report for cell channel_selector.arch01
-- --   Core Cell usage:
-- --               cell count     area count*area
--               AND2     1      1.0        1.0
--                AO1     3      1.0        3.0
--               AOI1     3      1.0        3.0
--              AOI1B     1      1.0        1.0
--                AX1     1      1.0        1.0
--               AX1A     1      1.0        1.0
--               AX1C     2      1.0        2.0
--               AX1D     1      1.0        1.0
--               AX1E     2      1.0        2.0
--                GND     1      0.0        0.0
--                MX2    48      1.0       48.0
--               MX2B     1      1.0        1.0
--               MX2C    17      1.0       17.0
--               NOR2     7      1.0        7.0
--              NOR2A     9      1.0        9.0
--              NOR2B     7      1.0        7.0
--               NOR3     2      1.0        2.0
--              NOR3A     4      1.0        4.0
--              NOR3B     1      1.0        1.0
--              NOR3C     5      1.0        5.0
--               OA1A     1      1.0        1.0
--               OA1C     2      1.0        2.0
--               OAI1     1      1.0        1.0
--                OR2     6      1.0        6.0
--               OR2A     4      1.0        4.0
--               OR2B     8      1.0        8.0
--                OR3     1      1.0        1.0
--               OR3B     3      1.0        3.0
--               OR3C     5      1.0        5.0
--                VCC     1      0.0        0.0
--               XOR2     4      1.0        4.0
-- 
-- 
--               DFN1     4      1.0        4.0
--                    -----          ----------
--              TOTAL   157               155.0
-- 
-- 
--   IO Cell usage:
--               cell count
--             CLKBUF     1
--              INBUF    18
--             OUTBUF     4
--                    -----
--              TOTAL    23
-- 
-- 
-- Core Cells         : 155 of 38400 (0%)
-- IO Cells           : 23

--================================================================================================--
-- 
--                            Requested     Estimated     Requested     Estimated                Clock        Clock              
-- Starting Clock             Frequency     Frequency     Period        Period        Slack      Type         Group              
-- ------------------------------------------------------------------------------------------------------------------------------
-- channel_selector|clk_I     100.0 MHz     68.9 MHz      10.000        14.521        -4.521     inferred     Inferred_clkgroup_0
--
-- 
--================================================================================================--