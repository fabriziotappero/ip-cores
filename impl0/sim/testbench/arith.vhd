-- VHDL model created from D:\installed-software\xilinx\spartan3\data\drawing\m2_1.sch - Tue Jul 19 11:19:51 2005


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
-- synopsys translate_off
library UNISIM;
use UNISIM.Vcomponents.ALL;
-- synopsys translate_on

entity M2_1_MXILINX_arith is
   port ( D0 : in    std_logic; 
          D1 : in    std_logic; 
          S0 : in    std_logic; 
          O  : out   std_logic);
end M2_1_MXILINX_arith;

architecture BEHAVIORAL of M2_1_MXILINX_arith is
   attribute BOX_TYPE   : STRING ;
   signal M0 : std_logic;
   signal M1 : std_logic;
   component AND2B1
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of AND2B1 : COMPONENT is "BLACK_BOX";
   
   component OR2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of OR2 : COMPONENT is "BLACK_BOX";
   
   component AND2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of AND2 : COMPONENT is "BLACK_BOX";
   
begin
   I_36_7 : AND2B1
      port map (I0=>S0, I1=>D0, O=>M0);
   
   I_36_8 : OR2
      port map (I0=>M1, I1=>M0, O=>O);
   
   I_36_9 : AND2
      port map (I0=>D1, I1=>S0, O=>M1);
   
end BEHAVIORAL;


-- VHDL model created from D:\installed-software\xilinx\spartan3\data\drawing\adsu16.sch - Tue Jul 19 11:19:52 2005


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
-- synopsys translate_off
library UNISIM;
use UNISIM.Vcomponents.ALL;
-- synopsys translate_on

entity ADSU16_MXILINX_arith is
   port ( A   : in    std_logic_vector (15 downto 0); 
          ADD : in    std_logic; 
          B   : in    std_logic_vector (15 downto 0); 
          CI  : in    std_logic; 
          CO  : out   std_logic; 
          OFL : out   std_logic; 
          S   : out   std_logic_vector (15 downto 0));
end ADSU16_MXILINX_arith;

architecture BEHAVIORAL of ADSU16_MXILINX_arith is
   attribute BOX_TYPE   : STRING ;
   attribute RLOC       : STRING ;
   signal C0       : std_logic;
   signal C1       : std_logic;
   signal C2       : std_logic;
   signal C3       : std_logic;
   signal C4       : std_logic;
   signal C5       : std_logic;
   signal C6       : std_logic;
   signal C7       : std_logic;
   signal C8       : std_logic;
   signal C9       : std_logic;
   signal C10      : std_logic;
   signal C11      : std_logic;
   signal C12      : std_logic;
   signal C13      : std_logic;
   signal C14      : std_logic;
   signal C14O     : std_logic;
   signal dummy    : std_logic;
   signal I0       : std_logic;
   signal I1       : std_logic;
   signal I2       : std_logic;
   signal I3       : std_logic;
   signal I4       : std_logic;
   signal I5       : std_logic;
   signal I6       : std_logic;
   signal I7       : std_logic;
   signal I8       : std_logic;
   signal I9       : std_logic;
   signal I10      : std_logic;
   signal I11      : std_logic;
   signal I12      : std_logic;
   signal I13      : std_logic;
   signal I14      : std_logic;
   signal I15      : std_logic;
   signal SUB0     : std_logic;
   signal SUB1     : std_logic;
   signal SUB2     : std_logic;
   signal SUB3     : std_logic;
   signal SUB4     : std_logic;
   signal SUB5     : std_logic;
   signal SUB6     : std_logic;
   signal SUB7     : std_logic;
   signal SUB8     : std_logic;
   signal SUB9     : std_logic;
   signal SUB10    : std_logic;
   signal SUB11    : std_logic;
   signal SUB12    : std_logic;
   signal SUB13    : std_logic;
   signal SUB14    : std_logic;
   signal SUB15    : std_logic;
   signal CO_DUMMY : std_logic;
   component FMAP
      port ( I1 : in    std_logic; 
             I2 : in    std_logic; 
             I3 : in    std_logic; 
             I4 : in    std_logic; 
             O  : in    std_logic);
   end component;
   attribute BOX_TYPE of FMAP : COMPONENT is "BLACK_BOX";
   
   component XOR3
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             I2 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of XOR3 : COMPONENT is "BLACK_BOX";
   
   component MUXCY_L
      port ( CI : in    std_logic; 
             DI : in    std_logic; 
             S  : in    std_logic; 
             LO : out   std_logic);
   end component;
   attribute BOX_TYPE of MUXCY_L : COMPONENT is "BLACK_BOX";
   
   component MUXCY
      port ( CI : in    std_logic; 
             DI : in    std_logic; 
             S  : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of MUXCY : COMPONENT is "BLACK_BOX";
   
   component XORCY
      port ( CI : in    std_logic; 
             LI : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of XORCY : COMPONENT is "BLACK_BOX";
   
   component MUXCY_D
      port ( CI : in    std_logic; 
             DI : in    std_logic; 
             S  : in    std_logic; 
             LO : out   std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of MUXCY_D : COMPONENT is "BLACK_BOX";
   
   component XOR2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of XOR2 : COMPONENT is "BLACK_BOX";
   
   component INV
      port ( I : in    std_logic; 
             O : out   std_logic);
   end component;
   attribute BOX_TYPE of INV : COMPONENT is "BLACK_BOX";
   
   attribute RLOC of I_36_16 : LABEL is "X1Y4";
   attribute RLOC of I_36_17 : LABEL is "X1Y4";
   attribute RLOC of I_36_18 : LABEL is "X1Y5";
   attribute RLOC of I_36_19 : LABEL is "X1Y5";
   attribute RLOC of I_36_20 : LABEL is "X1Y6";
   attribute RLOC of I_36_21 : LABEL is "X1Y6";
   attribute RLOC of I_36_22 : LABEL is "X1Y7";
   attribute RLOC of I_36_23 : LABEL is "X1Y7";
   attribute RLOC of I_36_55 : LABEL is "X1Y4";
   attribute RLOC of I_36_58 : LABEL is "X1Y5";
   attribute RLOC of I_36_62 : LABEL is "X1Y5";
   attribute RLOC of I_36_63 : LABEL is "X1Y6";
   attribute RLOC of I_36_64 : LABEL is "X1Y7";
   attribute RLOC of I_36_107 : LABEL is "X1Y7";
   attribute RLOC of I_36_110 : LABEL is "X1Y6";
   attribute RLOC of I_36_111 : LABEL is "X1Y4";
   attribute RLOC of I_36_248 : LABEL is "X1Y3";
   attribute RLOC of I_36_249 : LABEL is "X1Y3";
   attribute RLOC of I_36_250 : LABEL is "X1Y2";
   attribute RLOC of I_36_251 : LABEL is "X1Y2";
   attribute RLOC of I_36_252 : LABEL is "X1Y1";
   attribute RLOC of I_36_253 : LABEL is "X1Y1";
   attribute RLOC of I_36_254 : LABEL is "X1Y0";
   attribute RLOC of I_36_255 : LABEL is "X1Y0";
   attribute RLOC of I_36_272 : LABEL is "X1Y0";
   attribute RLOC of I_36_275 : LABEL is "X1Y0";
   attribute RLOC of I_36_279 : LABEL is "X1Y1";
   attribute RLOC of I_36_283 : LABEL is "X1Y1";
   attribute RLOC of I_36_287 : LABEL is "X1Y2";
   attribute RLOC of I_36_291 : LABEL is "X1Y2";
   attribute RLOC of I_36_295 : LABEL is "X1Y3";
   attribute RLOC of I_36_299 : LABEL is "X1Y3";
begin
   CO <= CO_DUMMY;
   I_36_16 : FMAP
      port map (I1=>A(8), I2=>B(8), I3=>ADD, I4=>dummy, O=>I8);
   
   I_36_17 : FMAP
      port map (I1=>A(9), I2=>B(9), I3=>ADD, I4=>dummy, O=>I9);
   
   I_36_18 : FMAP
      port map (I1=>A(10), I2=>B(10), I3=>ADD, I4=>dummy, O=>I10);
   
   I_36_19 : FMAP
      port map (I1=>A(11), I2=>B(11), I3=>ADD, I4=>dummy, O=>I11);
   
   I_36_20 : FMAP
      port map (I1=>A(12), I2=>B(12), I3=>ADD, I4=>dummy, O=>I12);
   
   I_36_21 : FMAP
      port map (I1=>A(13), I2=>B(13), I3=>ADD, I4=>dummy, O=>I13);
   
   I_36_22 : FMAP
      port map (I1=>A(14), I2=>B(14), I3=>ADD, I4=>dummy, O=>I14);
   
   I_36_23 : FMAP
      port map (I1=>A(15), I2=>B(15), I3=>ADD, I4=>dummy, O=>I15);
   
   I_36_50 : XOR3
      port map (I0=>A(8), I1=>B(8), I2=>SUB8, O=>I8);
   
   I_36_55 : MUXCY_L
      port map (CI=>C8, DI=>A(9), S=>I9, LO=>C9);
   
   I_36_56 : XOR3
      port map (I0=>A(10), I1=>B(10), I2=>SUB10, O=>I10);
   
   I_36_57 : XOR3
      port map (I0=>A(11), I1=>B(11), I2=>SUB11, O=>I11);
   
   I_36_58 : MUXCY_L
      port map (CI=>C10, DI=>A(11), S=>I11, LO=>C11);
   
   I_36_59 : XOR3
      port map (I0=>A(14), I1=>B(14), I2=>SUB14, O=>I14);
   
   I_36_60 : XOR3
      port map (I0=>A(12), I1=>B(12), I2=>SUB12, O=>I12);
   
   I_36_62 : MUXCY_L
      port map (CI=>C9, DI=>A(10), S=>I10, LO=>C10);
   
   I_36_63 : MUXCY_L
      port map (CI=>C11, DI=>A(12), S=>I12, LO=>C12);
   
   I_36_64 : MUXCY
      port map (CI=>C14, DI=>A(15), S=>I15, O=>CO_DUMMY);
   
   I_36_73 : XORCY
      port map (CI=>C7, LI=>I8, O=>S(8));
   
   I_36_74 : XORCY
      port map (CI=>C8, LI=>I9, O=>S(9));
   
   I_36_75 : XORCY
      port map (CI=>C10, LI=>I11, O=>S(11));
   
   I_36_76 : XORCY
      port map (CI=>C9, LI=>I10, O=>S(10));
   
   I_36_77 : XORCY
      port map (CI=>C12, LI=>I13, O=>S(13));
   
   I_36_78 : XORCY
      port map (CI=>C11, LI=>I12, O=>S(12));
   
   I_36_79 : XOR3
      port map (I0=>A(15), I1=>B(15), I2=>SUB15, O=>I15);
   
   I_36_80 : XORCY
      port map (CI=>C14, LI=>I15, O=>S(15));
   
   I_36_81 : XORCY
      port map (CI=>C13, LI=>I14, O=>S(14));
   
   I_36_100 : XOR3
      port map (I0=>A(9), I1=>B(9), I2=>SUB9, O=>I9);
   
   I_36_107 : MUXCY_D
      port map (CI=>C13, DI=>A(14), S=>I14, LO=>C14, O=>C14O);
   
   I_36_109 : XOR3
      port map (I0=>A(13), I1=>B(13), I2=>SUB13, O=>I13);
   
   I_36_110 : MUXCY_L
      port map (CI=>C12, DI=>A(13), S=>I13, LO=>C13);
   
   I_36_111 : MUXCY_L
      port map (CI=>C7, DI=>A(8), S=>I8, LO=>C8);
   
   I_36_220 : XOR3
      port map (I0=>A(0), I1=>B(0), I2=>SUB0, O=>I0);
   
   I_36_222 : XOR3
      port map (I0=>A(2), I1=>B(2), I2=>SUB2, O=>I2);
   
   I_36_223 : XOR3
      port map (I0=>A(3), I1=>B(3), I2=>SUB3, O=>I3);
   
   I_36_224 : XOR3
      port map (I0=>A(6), I1=>B(6), I2=>SUB6, O=>I6);
   
   I_36_225 : XOR3
      port map (I0=>A(4), I1=>B(4), I2=>SUB4, O=>I4);
   
   I_36_226 : XORCY
      port map (CI=>CI, LI=>I0, O=>S(0));
   
   I_36_227 : XORCY
      port map (CI=>C0, LI=>I1, O=>S(1));
   
   I_36_228 : XORCY
      port map (CI=>C2, LI=>I3, O=>S(3));
   
   I_36_229 : XORCY
      port map (CI=>C1, LI=>I2, O=>S(2));
   
   I_36_230 : XORCY
      port map (CI=>C4, LI=>I5, O=>S(5));
   
   I_36_231 : XORCY
      port map (CI=>C3, LI=>I4, O=>S(4));
   
   I_36_232 : XOR3
      port map (I0=>A(7), I1=>B(7), I2=>SUB7, O=>I7);
   
   I_36_233 : XORCY
      port map (CI=>C6, LI=>I7, O=>S(7));
   
   I_36_234 : XORCY
      port map (CI=>C5, LI=>I6, O=>S(6));
   
   I_36_243 : XOR3
      port map (I0=>A(1), I1=>B(1), I2=>SUB1, O=>I1);
   
   I_36_245 : XOR3
      port map (I0=>A(5), I1=>B(5), I2=>SUB5, O=>I5);
   
   I_36_248 : MUXCY_L
      port map (CI=>C6, DI=>A(7), S=>I7, LO=>C7);
   
   I_36_249 : MUXCY_L
      port map (CI=>C5, DI=>A(6), S=>I6, LO=>C6);
   
   I_36_250 : MUXCY_L
      port map (CI=>C4, DI=>A(5), S=>I5, LO=>C5);
   
   I_36_251 : MUXCY_L
      port map (CI=>C3, DI=>A(4), S=>I4, LO=>C4);
   
   I_36_252 : MUXCY_L
      port map (CI=>C2, DI=>A(3), S=>I3, LO=>C3);
   
   I_36_253 : MUXCY_L
      port map (CI=>C1, DI=>A(2), S=>I2, LO=>C2);
   
   I_36_254 : MUXCY_L
      port map (CI=>C0, DI=>A(1), S=>I1, LO=>C1);
   
   I_36_255 : MUXCY_L
      port map (CI=>CI, DI=>A(0), S=>I0, LO=>C0);
   
   I_36_272 : FMAP
      port map (I1=>A(1), I2=>B(1), I3=>ADD, I4=>dummy, O=>I1);
   
   I_36_275 : FMAP
      port map (I1=>A(0), I2=>B(0), I3=>ADD, I4=>dummy, O=>I0);
   
   I_36_279 : FMAP
      port map (I1=>A(2), I2=>B(2), I3=>ADD, I4=>dummy, O=>I2);
   
   I_36_283 : FMAP
      port map (I1=>A(3), I2=>B(3), I3=>ADD, I4=>dummy, O=>I3);
   
   I_36_287 : FMAP
      port map (I1=>A(4), I2=>B(4), I3=>ADD, I4=>dummy, O=>I4);
   
   I_36_291 : FMAP
      port map (I1=>A(5), I2=>B(5), I3=>ADD, I4=>dummy, O=>I5);
   
   I_36_295 : FMAP
      port map (I1=>A(6), I2=>B(6), I3=>ADD, I4=>dummy, O=>I6);
   
   I_36_299 : FMAP
      port map (I1=>A(7), I2=>B(7), I3=>ADD, I4=>dummy, O=>I7);
   
   I_36_353 : XOR2
      port map (I0=>C14O, I1=>CO_DUMMY, O=>OFL);
   
   I_36_355 : INV
      port map (I=>ADD, O=>SUB0);
   
   I_36_356 : INV
      port map (I=>ADD, O=>SUB1);
   
   I_36_357 : INV
      port map (I=>ADD, O=>SUB2);
   
   I_36_358 : INV
      port map (I=>ADD, O=>SUB3);
   
   I_36_359 : INV
      port map (I=>ADD, O=>SUB4);
   
   I_36_360 : INV
      port map (I=>ADD, O=>SUB5);
   
   I_36_361 : INV
      port map (I=>ADD, O=>SUB6);
   
   I_36_362 : INV
      port map (I=>ADD, O=>SUB7);
   
   I_36_363 : INV
      port map (I=>ADD, O=>SUB8);
   
   I_36_364 : INV
      port map (I=>ADD, O=>SUB9);
   
   I_36_365 : INV
      port map (I=>ADD, O=>SUB10);
   
   I_36_366 : INV
      port map (I=>ADD, O=>SUB11);
   
   I_36_367 : INV
      port map (I=>ADD, O=>SUB12);
   
   I_36_368 : INV
      port map (I=>ADD, O=>SUB13);
   
   I_36_369 : INV
      port map (I=>ADD, O=>SUB14);
   
   I_36_370 : INV
      port map (I=>ADD, O=>SUB15);
   
end BEHAVIORAL;


-- VHDL model created from arith.sch - Tue Jul 19 11:19:52 2005


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
-- synopsys translate_off
library UNISIM;
use UNISIM.Vcomponents.ALL;
-- synopsys translate_on

entity arith is
   port ( a       : in    std_logic_vector (15 downto 0); 
          b       : in    std_logic_vector (15 downto 0); 
          c_in    : in    std_logic; 
          s0      : in    std_logic; 
          s1      : in    std_logic; 
          c_out   : out   std_logic; 
          ofl_out : out   std_logic; 
          result  : out   std_logic_vector (15 downto 0));
end arith;

architecture BEHAVIORAL of arith is
   attribute HU_SET     : STRING ;
   attribute BOX_TYPE   : STRING ;
   signal XLXN_14 : std_logic;
   signal XLXN_15 : std_logic;
   signal XLXN_18 : std_logic;
   signal XLXN_24 : std_logic;
   signal XLXN_29 : std_logic;
   signal XLXN_30 : std_logic;
   signal XLXN_35 : std_logic;
   signal zero_i  : std_logic;
   component ADSU16_MXILINX_arith
      port ( A   : in    std_logic_vector (15 downto 0); 
             ADD : in    std_logic; 
             B   : in    std_logic_vector (15 downto 0); 
             CI  : in    std_logic; 
             CO  : out   std_logic; 
             OFL : out   std_logic; 
             S   : out   std_logic_vector (15 downto 0));
   end component;
   
   component M2_1_MXILINX_arith
      port ( D0 : in    std_logic; 
             D1 : in    std_logic; 
             S0 : in    std_logic; 
             O  : out   std_logic);
   end component;
   
   component INV
      port ( I : in    std_logic; 
             O : out   std_logic);
   end component;
   attribute BOX_TYPE of INV : COMPONENT is "BLACK_BOX";
   
   component GND
      port ( G : out   std_logic);
   end component;
   attribute BOX_TYPE of GND : COMPONENT is "BLACK_BOX";
   
   attribute HU_SET of XLXI_1 : LABEL is "XLXI_1_0";
   attribute HU_SET of XLXI_2 : LABEL is "XLXI_2_1";
   attribute HU_SET of XLXI_3 : LABEL is "XLXI_3_2";
   attribute HU_SET of XLXI_4 : LABEL is "XLXI_4_4";
   attribute HU_SET of XLXI_11 : LABEL is "XLXI_11_3";
begin
   XLXI_1 : ADSU16_MXILINX_arith
      port map (A(15 downto 0)=>a(15 downto 0), ADD=>s0, B(15 downto 0)=>b(15
            downto 0), CI=>XLXN_35, CO=>XLXN_14, OFL=>ofl_out, S(15 downto
            0)=>result(15 downto 0));
   
   XLXI_2 : M2_1_MXILINX_arith
      port map (D0=>XLXN_15, D1=>XLXN_14, S0=>s0, O=>c_out);
   
   XLXI_3 : M2_1_MXILINX_arith
      port map (D0=>XLXN_29, D1=>XLXN_30, S0=>s1, O=>XLXN_35);
   
   XLXI_4 : M2_1_MXILINX_arith
      port map (D0=>XLXN_24, D1=>c_in, S0=>s0, O=>XLXN_30);
   
   XLXI_8 : INV
      port map (I=>zero_i, O=>XLXN_18);
   
   XLXI_10 : INV
      port map (I=>XLXN_14, O=>XLXN_15);
   
   XLXI_11 : M2_1_MXILINX_arith
      port map (D0=>XLXN_18, D1=>zero_i, S0=>s0, O=>XLXN_29);
   
   XLXI_13 : INV
      port map (I=>c_in, O=>XLXN_24);
   
   XLXI_14 : GND
      port map (G=>zero_i);
   
end BEHAVIORAL;


