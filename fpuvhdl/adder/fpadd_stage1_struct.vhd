-- VHDL Entity work.FPadd_stage1.interface
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- 2003-2004. V1.0
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY FPadd_stage1 IS
   PORT( 
      ADD_SUB     : IN     std_logic;
      FP_A        : IN     std_logic_vector (31 DOWNTO 0);
      FP_B        : IN     std_logic_vector (31 DOWNTO 0);
      clk         : IN     std_logic;
      ADD_SUB_out : OUT    std_logic;
      A_EXP       : OUT    std_logic_vector (7 DOWNTO 0);
      A_SIGN      : OUT    std_logic;
      A_in        : OUT    std_logic_vector (28 DOWNTO 0);
      A_isINF     : OUT    std_logic;
      A_isNaN     : OUT    std_logic;
      A_isZ       : OUT    std_logic;
      B_EXP       : OUT    std_logic_vector (7 DOWNTO 0);
      B_XSIGN     : OUT    std_logic;
      B_in        : OUT    std_logic_vector (28 DOWNTO 0);
      B_isINF     : OUT    std_logic;
      B_isNaN     : OUT    std_logic;
      B_isZ       : OUT    std_logic;
      EXP_diff    : OUT    std_logic_vector (8 DOWNTO 0);
      cin_sub     : OUT    std_logic
   );

-- Declarations

END FPadd_stage1 ;

--
-- VHDL Architecture work.FPadd_stage1.struct
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- Copyright 2003-2004. V1.0
--


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ARCHITECTURE struct OF FPadd_stage1 IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL A_EXP_int    : std_logic_vector(7 DOWNTO 0);
   SIGNAL A_SIG        : std_logic_vector(31 DOWNTO 0);
   SIGNAL A_SIGN_int   : std_logic;
   SIGNAL A_in_int     : std_logic_vector(28 DOWNTO 0);
   SIGNAL A_isDN_int   : std_logic;
   SIGNAL A_isINF_int  : std_logic;
   SIGNAL A_isNaN_int  : std_logic;
   SIGNAL A_isZ_int    : std_logic;
   SIGNAL B_EXP_int    : std_logic_vector(7 DOWNTO 0);
   SIGNAL B_SIG        : std_logic_vector(31 DOWNTO 0);
   SIGNAL B_SIGN_int   : std_logic;
   SIGNAL B_XSIGN_int  : std_logic;
   SIGNAL B_in_int     : std_logic_vector(28 DOWNTO 0);
   SIGNAL B_isDN_int   : std_logic;
   SIGNAL B_isINF_int  : std_logic;
   SIGNAL B_isNaN_int  : std_logic;
   SIGNAL B_isZ_int    : std_logic;
   SIGNAL EXP_diff_int : std_logic_vector(8 DOWNTO 0);
   SIGNAL a_exp_in     : std_logic_vector(8 DOWNTO 0);
   SIGNAL b_exp_in     : std_logic_vector(8 DOWNTO 0);
   SIGNAL cin_sub_int  : std_logic;


   -- Component Declarations
   COMPONENT UnpackFP
   PORT (
      FP    : IN     std_logic_vector (31 DOWNTO 0);
      SIG   : OUT    std_logic_vector (31 DOWNTO 0);
      EXP   : OUT    std_logic_vector (7 DOWNTO 0);
      SIGN  : OUT    std_logic ;
      isNaN : OUT    std_logic ;
      isINF : OUT    std_logic ;
      isZ   : OUT    std_logic ;
      isDN  : OUT    std_logic 
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : UnpackFP USE ENTITY work.UnpackFP;
   -- pragma synthesis_on


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- reg1 1
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         A_SIGN <= A_SIGN_int;
         B_XSIGN <= B_XSIGN_int;
         A_in <= A_in_int;
         B_in <= B_in_int;
         A_EXP <= A_EXP_int;
         B_EXP <= B_EXP_int;
         EXP_diff <= EXP_diff_int;
         A_isZ <= A_isZ_int;
         B_isZ <= B_isZ_int;
         A_isINF <= A_isINF_int;
         B_isINF <= B_isINF_int;
         A_isNaN <= A_isNaN_int;
         B_isNaN <= B_isNaN_int;
         ADD_SUB_out <= ADD_SUB;
         cin_sub <= cin_sub_int;
      END IF;
   END PROCESS;

   -- HDL Embedded Text Block 2 eb2
   -- eb2 2
   a_exp_in <= "0" & A_EXP_int;

   -- HDL Embedded Text Block 3 eb3
   -- eb3 3
   b_exp_in <= "0" & B_EXP_int;

   -- HDL Embedded Text Block 4 eb4
   -- eb4 4 
   cin_sub_int <= (A_isZ_int OR A_isDN_int) XOR (B_isZ_int OR B_isDN_int);

   -- HDL Embedded Text Block 8 eb6
   -- eb5 7 
   A_in_int <= "00" & A_SIG(23 DOWNTO 0) & "000";

   -- HDL Embedded Text Block 10 eb8
   -- eb6 8                      
   B_in_int <= "00" & B_SIG(23 DOWNTO 0) & "000";


   -- ModuleWare code(v1.1) for instance 'I5' of 'sub'
   I5combo: PROCESS (a_exp_in, b_exp_in, cin_sub_int)
   VARIABLE mw_I5t0 : std_logic_vector(9 DOWNTO 0);
   VARIABLE mw_I5t1 : std_logic_vector(9 DOWNTO 0);
   VARIABLE diff : signed(9 DOWNTO 0);
   VARIABLE borrow : std_logic;
   BEGIN
      mw_I5t0 := a_exp_in(8) & a_exp_in;
      mw_I5t1 := b_exp_in(8) & b_exp_in;
      borrow := cin_sub_int;
      diff := signed(mw_I5t0) - signed(mw_I5t1) - borrow;
      EXP_diff_int <= conv_std_logic_vector(diff(8 DOWNTO 0),9);
   END PROCESS I5combo;

   -- ModuleWare code(v1.1) for instance 'I18' of 'xnor'
   B_XSIGN_int <= NOT(B_SIGN_int XOR ADD_SUB);

   -- Instance port mappings.
   I1 : UnpackFP
      PORT MAP (
         FP    => FP_A,
         SIG   => A_SIG,
         EXP   => A_EXP_int,
         SIGN  => A_SIGN_int,
         isNaN => A_isNaN_int,
         isINF => A_isINF_int,
         isZ   => A_isZ_int,
         isDN  => A_isDN_int
      );
   I3 : UnpackFP
      PORT MAP (
         FP    => FP_B,
         SIG   => B_SIG,
         EXP   => B_EXP_int,
         SIGN  => B_SIGN_int,
         isNaN => B_isNaN_int,
         isINF => B_isINF_int,
         isZ   => B_isZ_int,
         isDN  => B_isDN_int
      );

END struct;
