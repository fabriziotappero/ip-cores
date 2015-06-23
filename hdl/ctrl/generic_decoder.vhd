-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: generic_decoder.vhd
--| Version: 0.1
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   CONTROL - Decoder
--|   This is a simple decoder
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1   | jul-2009 | First release
--|   0.2   | jul-2009 | New output code
----------------------------------------------------------------------------------------------------
--| Copyright © 2009, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------


-- NOTE: Look at the end for comparisons between the SmartGen decoder and this decoder.
--       If you are using an Actel's FPGA, you may want to use the SmartGen decoder.


-- Example for 3 bits
-- Input    Output
-- 000      00000001
-- 001      00000011
-- 010      00000111
-- 011      00001111
-- 100      00011111
-- 101      00111111
-- 110      01111111
-- 111      11111111
--                  

--==================================================================================================
-- TODO
-- · ...
--==================================================================================================


library IEEE;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

entity generic_decoder is
  generic(
    INPUT_WIDTH: integer := 5 -- Input with for decoder (decodes INPUT_WIDTH to 2^INPUT_WIDTH)
  );
  Port(  
    enable_I:   in std_logic;
    data_I:     in std_logic_vector(INPUT_WIDTH-1 downto 0);
    decoded_O:  out std_logic_vector( integer(2**real(INPUT_WIDTH))-1  downto 0)
  );
end entity generic_decoder;
 
architecture beh of generic_decoder is
  
begin
   
  P_main: process (data_I, enable_I)
    variable i: integer range 0 to decoded_O'length-1;
  begin
    for i in 0 to decoded_O'length-1 loop
      if i <= to_integer(unsigned(data_I)) and enable_I = '1' then
        decoded_O(i) <= '1';
      else
        decoded_O(i) <= '0';
      end if;
    end loop;
  
  end process;
   
   
end architecture;




--================================================================================================--
-- SYNPLIFY REPORT for this decoder (INPUT_WIDTH := 5)
--
-- Report for cell generic_decoder.beh
--   Core Cell usage:
--               cell count     area count*area
--                AO1     1      1.0        1.0
--                GND     1      0.0        0.0
--              NOR2B    11      1.0       11.0
--              NOR3C     1      1.0        1.0
--                OA1    22      1.0       22.0
--                OR2     3      1.0        3.0
--                VCC     1      0.0        0.0
-- 
-- 
--                    -----          ----------
--              TOTAL    40                38.0
-- 
-- 
--   IO Cell usage:
--               cell count
--              INBUF     6
--             OUTBUF    32
--                    -----
--              TOTAL    38
-- 
-- 
-- Core Cells         : 38 of 38400 (0%)
-- IO Cells           : 38
--
--================================================================================================--
-- Designer timing report SUMMARY (Auto layout, without constraints)
-- 
--                             Input to Output
-- Min Delay (ns):             2.770 
-- Max Delay (ns):             16     
--================================================================================================--






----------------------------------------------------------------------------------------------------
-- SmartGen decoder5to32

-- -- Version: 8.5 SP1 8.5.1.13
-- 
-- library ieee;
-- use ieee.std_logic_1164.all;
-- library proasic3e;
-- use proasic3e.all;
-- 
-- entity decoder5to32 is 
--     port(Data0, Data1, Data2, Data3, Data4 : in std_logic; Eq : 
--         out std_logic_vector(31 downto 0)) ;
-- end decoder5to32;
-- 
-- 
-- architecture DEF_ARCH of  decoder5to32 is
-- 
--     component AND2
--         port(A, B : in std_logic := 'U'; Y : out std_logic) ;
--     end component;
-- 
--     component AND2A
--         port(A, B : in std_logic := 'U'; Y : out std_logic) ;
--     end component;
-- 
--     component AND3C
--         port(A, B, C : in std_logic := 'U'; Y : out std_logic) ;
--     end component;
-- 
--     component AND3
--         port(A, B, C : in std_logic := 'U'; Y : out std_logic) ;
--     end component;
-- 
--     component AND3A
--         port(A, B, C : in std_logic := 'U'; Y : out std_logic) ;
--     end component;
-- 
--     component AND3B
--         port(A, B, C : in std_logic := 'U'; Y : out std_logic) ;
--     end component;
-- 
--     component NOR2
--         port(A, B : in std_logic := 'U'; Y : out std_logic) ;
--     end component;
-- 
--     signal AND3C_0_Y, AND3B_2_Y, AND3B_1_Y, AND3A_0_Y, AND3B_0_Y, 
--         AND3A_1_Y, AND3A_2_Y, AND3_0_Y, NOR2_0_Y, AND2A_1_Y, 
--         AND2A_0_Y, AND2_0_Y : std_logic ;
--     begin   
-- 
--     AND2_Eq_5_inst : AND2
--       port map(A => AND3A_1_Y, B => NOR2_0_Y, Y => Eq(5));
--     AND2_Eq_2_inst : AND2
--       port map(A => AND3B_1_Y, B => NOR2_0_Y, Y => Eq(2));
--     AND2_0 : AND2
--       port map(A => Data4, B => Data3, Y => AND2_0_Y);
--     AND2_Eq_28_inst : AND2
--       port map(A => AND3B_0_Y, B => AND2_0_Y, Y => Eq(28));
--     AND2_Eq_10_inst : AND2
--       port map(A => AND3B_1_Y, B => AND2A_1_Y, Y => Eq(10));
--     AND2_Eq_19_inst : AND2
--       port map(A => AND3A_0_Y, B => AND2A_0_Y, Y => Eq(19));
--     AND2_Eq_21_inst : AND2
--       port map(A => AND3A_1_Y, B => AND2A_0_Y, Y => Eq(21));
--     AND2A_1 : AND2A
--       port map(A => Data4, B => Data3, Y => AND2A_1_Y);
--     AND2_Eq_14_inst : AND2
--       port map(A => AND3A_2_Y, B => AND2A_1_Y, Y => Eq(14));
--     AND3C_0 : AND3C
--       port map(A => Data2, B => Data1, C => Data0, Y => AND3C_0_Y);
--     AND2_Eq_31_inst : AND2
--       port map(A => AND3_0_Y, B => AND2_0_Y, Y => Eq(31));
--     AND2_Eq_1_inst : AND2
--       port map(A => AND3B_2_Y, B => NOR2_0_Y, Y => Eq(1));
--     AND2_Eq_16_inst : AND2
--       port map(A => AND3C_0_Y, B => AND2A_0_Y, Y => Eq(16));
--     AND3_0 : AND3
--       port map(A => Data2, B => Data1, C => Data0, Y => AND3_0_Y);
--     AND2_Eq_23_inst : AND2
--       port map(A => AND3_0_Y, B => AND2A_0_Y, Y => Eq(23));
--     AND2_Eq_9_inst : AND2
--       port map(A => AND3B_2_Y, B => AND2A_1_Y, Y => Eq(9));
--     AND2_Eq_22_inst : AND2
--       port map(A => AND3A_2_Y, B => AND2A_0_Y, Y => Eq(22));
--     AND2_Eq_6_inst : AND2
--       port map(A => AND3A_2_Y, B => NOR2_0_Y, Y => Eq(6));
--     AND2_Eq_8_inst : AND2
--       port map(A => AND3C_0_Y, B => AND2A_1_Y, Y => Eq(8));
--     AND2_Eq_18_inst : AND2
--       port map(A => AND3B_1_Y, B => AND2A_0_Y, Y => Eq(18));
--     AND2_Eq_25_inst : AND2
--       port map(A => AND3B_2_Y, B => AND2_0_Y, Y => Eq(25));
--     AND3A_2 : AND3A
--       port map(A => Data0, B => Data1, C => Data2, Y => AND3A_2_Y);
--     AND2_Eq_27_inst : AND2
--       port map(A => AND3A_0_Y, B => AND2_0_Y, Y => Eq(27));
--     AND2_Eq_7_inst : AND2
--       port map(A => AND3_0_Y, B => NOR2_0_Y, Y => Eq(7));
--     AND2_Eq_11_inst : AND2
--       port map(A => AND3A_0_Y, B => AND2A_1_Y, Y => Eq(11));
--     AND3A_1 : AND3A
--       port map(A => Data1, B => Data2, C => Data0, Y => AND3A_1_Y);
--     AND2_Eq_0_inst : AND2
--       port map(A => AND3C_0_Y, B => NOR2_0_Y, Y => Eq(0));
--     AND2_Eq_3_inst : AND2
--       port map(A => AND3A_0_Y, B => NOR2_0_Y, Y => Eq(3));
--     AND2_Eq_12_inst : AND2
--       port map(A => AND3B_0_Y, B => AND2A_1_Y, Y => Eq(12));
--     AND2_Eq_13_inst : AND2
--       port map(A => AND3A_1_Y, B => AND2A_1_Y, Y => Eq(13));
--     AND2A_0 : AND2A
--       port map(A => Data3, B => Data4, Y => AND2A_0_Y);
--     AND3B_1 : AND3B
--       port map(A => Data2, B => Data0, C => Data1, Y => AND3B_1_Y);
--     AND3B_0 : AND3B
--       port map(A => Data0, B => Data1, C => Data2, Y => AND3B_0_Y);
--     AND2_Eq_17_inst : AND2
--       port map(A => AND3B_2_Y, B => AND2A_0_Y, Y => Eq(17));
--     AND2_Eq_15_inst : AND2
--       port map(A => AND3_0_Y, B => AND2A_1_Y, Y => Eq(15));
--     AND2_Eq_20_inst : AND2
--       port map(A => AND3B_0_Y, B => AND2A_0_Y, Y => Eq(20));
--     AND2_Eq_29_inst : AND2
--       port map(A => AND3A_1_Y, B => AND2_0_Y, Y => Eq(29));
--     NOR2_0 : NOR2
--       port map(A => Data4, B => Data3, Y => NOR2_0_Y);
--     AND3B_2 : AND3B
--       port map(A => Data2, B => Data1, C => Data0, Y => AND3B_2_Y);
--     AND2_Eq_4_inst : AND2
--       port map(A => AND3B_0_Y, B => NOR2_0_Y, Y => Eq(4));
--     AND2_Eq_24_inst : AND2
--       port map(A => AND3C_0_Y, B => AND2_0_Y, Y => Eq(24));
--     AND3A_0 : AND3A
--       port map(A => Data2, B => Data1, C => Data0, Y => AND3A_0_Y);
--     AND2_Eq_26_inst : AND2
--       port map(A => AND3B_1_Y, B => AND2_0_Y, Y => Eq(26));
--     AND2_Eq_30_inst : AND2
--       port map(A => AND3A_2_Y, B => AND2_0_Y, Y => Eq(30));
-- end DEF_ARCH;

--================================================================================================--
-- SYNPLIFY REPORT for SmartGen decoder
-- 
-- Report for cell decoder5to32.def_arch
--   Core Cell usage:
--               cell count     area count*area
--               AND2    33      1.0       33.0  Too many ands!
--              AND2A     2      1.0        2.0
--               AND3     1      1.0        1.0
--              AND3A     3      1.0        3.0
--              AND3B     3      1.0        3.0
--              AND3C     1      1.0        1.0
--                GND     1      0.0        0.0
--               NOR2     1      1.0        1.0
--                VCC     1      0.0        0.0
-- 
-- 
--                    ---          ----------
--              TOTAL    46                44.0
-- 
-- 
--   IO Cell usage:
--               cell count
--              INBUF     5
--             OUTBUF    32
--                    ---
--              TOTAL    37
-- 
-- 
-- Core Cells         : 44 of 38400 (0%)
-- IO Cells           : 37
--
--================================================================================================--
-- Designer timing report SUMMARY (Auto layout, without constraints)
-- SUMMARY
-- 
--                             Input to Output
-- Min Delay (ns):             3.087 
-- Max Delay (ns):             17 
--================================================================================================--