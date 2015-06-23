-- VHDL Entity work.FPadd.symbol
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

ENTITY FPadd IS
   PORT( 
      ADD_SUB : IN     std_logic;
      FP_A    : IN     std_logic_vector (31 DOWNTO 0);
      FP_B    : IN     std_logic_vector (31 DOWNTO 0);
      clk     : IN     std_logic;
      FP_Z    : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END FPadd ;

--
-- VHDL Architecture work.FPadd.single_cycle
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

ARCHITECTURE single_cycle OF FPadd IS

   -- Architecture declarations
      -- Non hierarchical truthtable declarations
    

      -- Non hierarchical truthtable declarations
    

      -- Non hierarchical truthtable declarations
    


   -- Internal signal declarations
   SIGNAL A_CS      : std_logic_vector(28 DOWNTO 0);
   SIGNAL A_EXP     : std_logic_vector(7 DOWNTO 0);
   SIGNAL A_SIG     : std_logic_vector(31 DOWNTO 0);
   SIGNAL A_SIGN    : std_logic;
   SIGNAL A_in      : std_logic_vector(28 DOWNTO 0);
   SIGNAL A_isDN    : std_logic;
   SIGNAL A_isINF   : std_logic;
   SIGNAL A_isNaN   : std_logic;
   SIGNAL A_isZ     : std_logic;
   SIGNAL B_CS      : std_logic_vector(28 DOWNTO 0);
   SIGNAL B_EXP     : std_logic_vector(7 DOWNTO 0);
   SIGNAL B_SIG     : std_logic_vector(31 DOWNTO 0);
   SIGNAL B_SIGN    : std_logic;
   SIGNAL B_XSIGN   : std_logic;
   SIGNAL B_in      : std_logic_vector(28 DOWNTO 0);
   SIGNAL B_isDN    : std_logic;
   SIGNAL B_isINF   : std_logic;
   SIGNAL B_isNaN   : std_logic;
   SIGNAL B_isZ     : std_logic;
   SIGNAL EXP_base  : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_diff  : std_logic_vector(8 DOWNTO 0);
   SIGNAL EXP_isINF : std_logic;
   SIGNAL EXP_norm  : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_round : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_selC  : std_logic_vector(7 DOWNTO 0);
   SIGNAL OV        : std_logic;
   SIGNAL SIG_norm  : std_logic_vector(27 DOWNTO 0);
   SIGNAL SIG_norm2 : std_logic_vector(27 DOWNTO 0);
   SIGNAL SIG_round : std_logic_vector(27 DOWNTO 0);
   SIGNAL SIG_selC  : std_logic_vector(27 DOWNTO 0);
   SIGNAL Z_EXP     : std_logic_vector(7 DOWNTO 0);
   SIGNAL Z_SIG     : std_logic_vector(22 DOWNTO 0);
   SIGNAL Z_SIGN    : std_logic;
   SIGNAL a_align   : std_logic_vector(28 DOWNTO 0);
   SIGNAL a_exp_in  : std_logic_vector(8 DOWNTO 0);
   SIGNAL a_inv     : std_logic_vector(28 DOWNTO 0);
   SIGNAL add_out   : std_logic_vector(28 DOWNTO 0);
   SIGNAL b_align   : std_logic_vector(28 DOWNTO 0);
   SIGNAL b_exp_in  : std_logic_vector(8 DOWNTO 0);
   SIGNAL b_inv     : std_logic_vector(28 DOWNTO 0);
   SIGNAL cin       : std_logic;
   SIGNAL cin_sub   : std_logic;
   SIGNAL invert_A  : std_logic;
   SIGNAL invert_B  : std_logic;
   SIGNAL isINF     : std_logic;
   SIGNAL isINF_tab : std_logic;
   SIGNAL isNaN     : std_logic;
   SIGNAL isZ       : std_logic;
   SIGNAL isZ_tab   : std_logic;
   SIGNAL mux_sel   : std_logic;
   SIGNAL zero      : std_logic;


   -- ModuleWare signal declarations(v1.1) for instance 'I13' of 'mux'
   SIGNAL mw_I13din0 : std_logic_vector(7 DOWNTO 0);
   SIGNAL mw_I13din1 : std_logic_vector(7 DOWNTO 0);

   -- Component Declarations
   COMPONENT FPadd_normalize
   PORT (
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_in  : IN     std_logic_vector (27 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (27 DOWNTO 0);
      zero    : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPalign
   PORT (
      A_in  : IN     std_logic_vector (28 DOWNTO 0);
      B_in  : IN     std_logic_vector (28 DOWNTO 0);
      cin   : IN     std_logic ;
      diff  : IN     std_logic_vector (8 DOWNTO 0);
      A_out : OUT    std_logic_vector (28 DOWNTO 0);
      B_out : OUT    std_logic_vector (28 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPinvert
   GENERIC (
      width : integer := 29
   );
   PORT (
      A_in     : IN     std_logic_vector (width-1 DOWNTO 0);
      B_in     : IN     std_logic_vector (width-1 DOWNTO 0);
      invert_A : IN     std_logic ;
      invert_B : IN     std_logic ;
      A_out    : OUT    std_logic_vector (width-1 DOWNTO 0);
      B_out    : OUT    std_logic_vector (width-1 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPnormalize
   GENERIC (
      SIG_width : integer := 28
   );
   PORT (
      SIG_in  : IN     std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPround
   GENERIC (
      SIG_width : integer := 28
   );
   PORT (
      SIG_in  : IN     std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPselComplement
   GENERIC (
      SIG_width : integer := 28
   );
   PORT (
      SIG_in  : IN     std_logic_vector (SIG_width DOWNTO 0);
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPswap
   GENERIC (
      width : integer := 29
   );
   PORT (
      A_in    : IN     std_logic_vector (width-1 DOWNTO 0);
      B_in    : IN     std_logic_vector (width-1 DOWNTO 0);
      swap_AB : IN     std_logic ;
      A_out   : OUT    std_logic_vector (width-1 DOWNTO 0);
      B_out   : OUT    std_logic_vector (width-1 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT PackFP
   PORT (
      SIGN  : IN     std_logic ;
      EXP   : IN     std_logic_vector (7 DOWNTO 0);
      SIG   : IN     std_logic_vector (22 DOWNTO 0);
      isNaN : IN     std_logic ;
      isINF : IN     std_logic ;
      isZ   : IN     std_logic ;
      FP    : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
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
   FOR ALL : FPadd_normalize USE ENTITY work.FPadd_normalize;
   FOR ALL : FPalign USE ENTITY work.FPalign;
   FOR ALL : FPinvert USE ENTITY work.FPinvert;
   FOR ALL : FPnormalize USE ENTITY work.FPnormalize;
   FOR ALL : FPround USE ENTITY work.FPround;
   FOR ALL : FPselComplement USE ENTITY work.FPselComplement;
   FOR ALL : FPswap USE ENTITY work.FPswap;
   FOR ALL : PackFP USE ENTITY work.PackFP;
   FOR ALL : UnpackFP USE ENTITY work.UnpackFP;
   -- pragma synthesis_on


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- eb1 1
   cin_sub <= (A_isDN OR A_isZ) XOR 
   (B_isDN OR B_isZ);

   -- HDL Embedded Text Block 2 eb2
   -- eb2 2
   Z_SIG <= SIG_norm2(25 DOWNTO 3);

   -- HDL Embedded Block 3 eb3
   -- Non hierarchical truthtable
   ---------------------------------------------------------------------------
   eb3_truth_process: PROCESS(ADD_SUB, A_isINF, A_isNaN, A_isZ, B_isINF, B_isNaN, B_isZ)
   ---------------------------------------------------------------------------
   BEGIN
      -- Block 1
      IF (A_isNaN = '1') THEN
         isINF_tab <= '0';
         isNaN <= '1';
         isZ_tab <= '0';
      ELSIF (B_isNaN = '1') THEN
         isINF_tab <= '0';
         isNaN <= '1';
         isZ_tab <= '0';
      ELSIF (ADD_SUB = '1') AND (A_isINF = '1') AND (B_isINF = '1') THEN
         isINF_tab <= '1';
         isNaN <= '0';
         isZ_tab <= '0';
      ELSIF (ADD_SUB = '0') AND (A_isINF = '1') AND (B_isINF = '1') THEN
         isINF_tab <= '0';
         isNaN <= '1';
         isZ_tab <= '0';
      ELSIF (A_isINF = '1') THEN
         isINF_tab <= '1';
         isNaN <= '0';
         isZ_tab <= '0';
      ELSIF (B_isINF = '1') THEN
         isINF_tab <= '1';
         isNaN <= '0';
         isZ_tab <= '0';
      ELSIF (A_isZ = '1') AND (B_isZ = '1') THEN
         isINF_tab <= '0';
         isNaN <= '0';
         isZ_tab <= '1';
      ELSE
         isINF_tab <= '0';
         isNaN <= '0';
         isZ_tab <= '0';
      END IF;

   END PROCESS eb3_truth_process;

   -- Architecture concurrent statements
    


   -- HDL Embedded Text Block 4 eb4
   -- eb4 4 
   mux_sel <= EXP_diff(8);

   -- HDL Embedded Block 5 InvertLogic
   -- Non hierarchical truthtable
   ---------------------------------------------------------------------------
   InvertLogic_truth_process: PROCESS(A_SIGN, B_XSIGN, EXP_diff)
   ---------------------------------------------------------------------------
   BEGIN
      -- Block 1
      IF (A_SIGN = '0') AND (B_XSIGN = '0') THEN
         invert_A <= '0';
         invert_B <= '0';
      ELSIF (A_SIGN = '1') AND (B_XSIGN = '1') THEN
         invert_A <= '0';
         invert_B <= '0';
      ELSIF (A_SIGN = '0') AND (B_XSIGN = '1') AND (EXP_diff(8) = '0') THEN
         invert_A <= '0';
         invert_B <= '1';
      ELSIF (A_SIGN = '0') AND (B_XSIGN = '1') AND (EXP_diff(8) = '1') THEN
         invert_A <= '1';
         invert_B <= '0';
      ELSIF (A_SIGN = '1') AND (B_XSIGN = '0') AND (EXP_diff(8) = '0') THEN
         invert_A <= '1';
         invert_B <= '0';
      ELSIF (A_SIGN = '1') AND (B_XSIGN = '0') AND (EXP_diff(8) = '1') THEN
         invert_A <= '0';
         invert_B <= '1';
      ELSE
         invert_A <= '0';
         invert_B <= '0';
      END IF;

   END PROCESS InvertLogic_truth_process;

   -- Architecture concurrent statements
    


   -- HDL Embedded Block 6 SignLogic
   -- Non hierarchical truthtable
   ---------------------------------------------------------------------------
   SignLogic_truth_process: PROCESS(A_SIGN, B_XSIGN, add_out)
   ---------------------------------------------------------------------------
      VARIABLE b1_A_SIGNB_XSIGNadd_out_28 : std_logic_vector(2 DOWNTO 0);
   BEGIN
      -- Block 1
      b1_A_SIGNB_XSIGNadd_out_28 := A_SIGN & B_XSIGN & add_out(28);

      CASE b1_A_SIGNB_XSIGNadd_out_28 IS
      WHEN "000" =>
         OV <= '0';
         Z_SIGN <= '0';
      WHEN "001" =>
         OV <= '1';
         Z_SIGN <= '0';
      WHEN "010" =>
         OV <= '0';
         Z_SIGN <= '0';
      WHEN "011" =>
         OV <= '0';
         Z_SIGN <= '1';
      WHEN "100" =>
         OV <= '0';
         Z_SIGN <= '0';
      WHEN "101" =>
         OV <= '0';
         Z_SIGN <= '1';
      WHEN "110" =>
         OV <= '0';
         Z_SIGN <= '1';
      WHEN "111" =>
         OV <= '1';
         Z_SIGN <= '1';
      WHEN OTHERS =>
         OV <= '0';
         Z_SIGN <= '0';
      END CASE;

   END PROCESS SignLogic_truth_process;

   -- Architecture concurrent statements
    


   -- HDL Embedded Text Block 7 eb5
   -- eb5 7 
   A_in <= "00" & A_SIG(23 DOWNTO 0) & "000";

   -- HDL Embedded Text Block 8 eb6
   -- eb6 8                      
   B_in <= "00" & B_SIG(23 DOWNTO 0) & "000";

   -- HDL Embedded Text Block 9 eb7
   -- eb7 9
   EXP_isINF <= '1' WHEN (OV='1' OR Z_EXP=X"FF") ELSE '0';

   -- HDL Embedded Text Block 10 eb8
   -- eb8 10
   a_exp_in <= "0" & A_EXP;

   -- HDL Embedded Text Block 11 eb9
   -- eb9 11
   b_exp_in <= "0" & B_EXP;


   -- ModuleWare code(v1.1) for instance 'I4' of 'add'
   I4combo: PROCESS (a_inv, b_inv, cin)
   VARIABLE mw_I4t0 : std_logic_vector(29 DOWNTO 0);
   VARIABLE mw_I4t1 : std_logic_vector(29 DOWNTO 0);
   VARIABLE mw_I4sum : signed(29 DOWNTO 0);
   VARIABLE mw_I4carry : std_logic;
   BEGIN
      mw_I4t0 := a_inv(28) & a_inv;
      mw_I4t1 := b_inv(28) & b_inv;
      mw_I4carry := cin;
      mw_I4sum := signed(mw_I4t0) + signed(mw_I4t1) + mw_I4carry;
      add_out <= conv_std_logic_vector(mw_I4sum(28 DOWNTO 0),29);
   END PROCESS I4combo;

   -- ModuleWare code(v1.1) for instance 'I13' of 'mux'
   I13combo: PROCESS(mw_I13din0, mw_I13din1, mux_sel)
   VARIABLE dtemp : std_logic_vector(7 DOWNTO 0);
   BEGIN
      CASE mux_sel IS
      WHEN '0'|'L' => dtemp := mw_I13din0;
      WHEN '1'|'H' => dtemp := mw_I13din1;
      WHEN OTHERS => dtemp := (OTHERS => 'X');
      END CASE;
      EXP_base <= dtemp;
   END PROCESS I13combo;
   mw_I13din0 <= A_EXP;
   mw_I13din1 <= B_EXP;

   -- ModuleWare code(v1.1) for instance 'I7' of 'or'
   isINF <= EXP_isINF OR isINF_tab;

   -- ModuleWare code(v1.1) for instance 'I15' of 'or'
   cin <= invert_B OR invert_A;

   -- ModuleWare code(v1.1) for instance 'I17' of 'or'
   isZ <= zero OR isZ_tab;

   -- ModuleWare code(v1.1) for instance 'I3' of 'sub'
   I3combo: PROCESS (a_exp_in, b_exp_in, cin_sub)
   VARIABLE mw_I3t0 : std_logic_vector(9 DOWNTO 0);
   VARIABLE mw_I3t1 : std_logic_vector(9 DOWNTO 0);
   VARIABLE diff : signed(9 DOWNTO 0);
   VARIABLE borrow : std_logic;
   BEGIN
      mw_I3t0 := a_exp_in(8) & a_exp_in;
      mw_I3t1 := b_exp_in(8) & b_exp_in;
      borrow := cin_sub;
      diff := signed(mw_I3t0) - signed(mw_I3t1) - borrow;
      EXP_diff <= conv_std_logic_vector(diff(8 DOWNTO 0),9);
   END PROCESS I3combo;

   -- ModuleWare code(v1.1) for instance 'I16' of 'xnor'
   B_XSIGN <= NOT(B_SIGN XOR ADD_SUB);

   -- Instance port mappings.
   I8 : FPadd_normalize
      PORT MAP (
         EXP_in  => EXP_selC,
         SIG_in  => SIG_selC,
         EXP_out => EXP_norm,
         SIG_out => SIG_norm,
         zero    => zero
      );
   I6 : FPalign
      PORT MAP (
         A_in  => A_CS,
         B_in  => B_CS,
         cin   => cin_sub,
         diff  => EXP_diff,
         A_out => a_align,
         B_out => b_align
      );
   I14 : FPinvert
      GENERIC MAP (
         width => 29
      )
      PORT MAP (
         A_in     => a_align,
         B_in     => b_align,
         invert_A => invert_A,
         invert_B => invert_B,
         A_out    => a_inv,
         B_out    => b_inv
      );
   I11 : FPnormalize
      GENERIC MAP (
         SIG_width => 28
      )
      PORT MAP (
         SIG_in  => SIG_round,
         EXP_in  => EXP_round,
         SIG_out => SIG_norm2,
         EXP_out => Z_EXP
      );
   I10 : FPround
      GENERIC MAP (
         SIG_width => 28
      )
      PORT MAP (
         SIG_in  => SIG_norm,
         EXP_in  => EXP_norm,
         SIG_out => SIG_round,
         EXP_out => EXP_round
      );
   I12 : FPselComplement
      GENERIC MAP (
         SIG_width => 28
      )
      PORT MAP (
         SIG_in  => add_out,
         EXP_in  => EXP_base,
         SIG_out => SIG_selC,
         EXP_out => EXP_selC
      );
   I5 : FPswap
      GENERIC MAP (
         width => 29
      )
      PORT MAP (
         A_in    => A_in,
         B_in    => B_in,
         swap_AB => EXP_diff(8),
         A_out   => A_CS,
         B_out   => B_CS
      );
   I2 : PackFP
      PORT MAP (
         SIGN  => Z_SIGN,
         EXP   => Z_EXP,
         SIG   => Z_SIG,
         isNaN => isNaN,
         isINF => isINF,
         isZ   => isZ,
         FP    => FP_Z
      );
   I0 : UnpackFP
      PORT MAP (
         FP    => FP_A,
         SIG   => A_SIG,
         EXP   => A_EXP,
         SIGN  => A_SIGN,
         isNaN => A_isNaN,
         isINF => A_isINF,
         isZ   => A_isZ,
         isDN  => A_isDN
      );
   I1 : UnpackFP
      PORT MAP (
         FP    => FP_B,
         SIG   => B_SIG,
         EXP   => B_EXP,
         SIGN  => B_SIGN,
         isNaN => B_isNaN,
         isINF => B_isINF,
         isZ   => B_isZ,
         isDN  => B_isDN
      );

END single_cycle;
