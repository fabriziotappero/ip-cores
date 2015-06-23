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
-- VHDL Architecture work.FPadd.pipeline
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

ARCHITECTURE pipeline OF FPadd IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL ADD_SUB_out      : std_logic;
   SIGNAL A_EXP            : std_logic_vector(7 DOWNTO 0);
   SIGNAL A_SIGN           : std_logic;
   SIGNAL A_SIGN_stage2    : std_logic;
   SIGNAL A_SIGN_stage3    : std_logic;
   SIGNAL A_align          : std_logic_vector(28 DOWNTO 0);
   SIGNAL A_in             : std_logic_vector(28 DOWNTO 0);
   SIGNAL A_isINF          : std_logic;
   SIGNAL A_isNaN          : std_logic;
   SIGNAL A_isZ            : std_logic;
   SIGNAL B_EXP            : std_logic_vector(7 DOWNTO 0);
   SIGNAL B_XSIGN          : std_logic;
   SIGNAL B_XSIGN_stage2   : std_logic;
   SIGNAL B_XSIGN_stage3   : std_logic;
   SIGNAL B_align          : std_logic_vector(28 DOWNTO 0);
   SIGNAL B_in             : std_logic_vector(28 DOWNTO 0);
   SIGNAL B_isINF          : std_logic;
   SIGNAL B_isNaN          : std_logic;
   SIGNAL B_isZ            : std_logic;
   SIGNAL EXP_base         : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_base_stage2  : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_diff         : std_logic_vector(8 DOWNTO 0);
   SIGNAL EXP_norm         : std_logic_vector(7 DOWNTO 0);
   SIGNAL OV               : std_logic;
   SIGNAL OV_stage4        : std_logic;
   SIGNAL SIG_norm         : std_logic_vector(27 DOWNTO 0);
   SIGNAL SIG_norm2        : std_logic_vector(27 DOWNTO 0);
   SIGNAL Z_EXP            : std_logic_vector(7 DOWNTO 0);
   SIGNAL Z_SIGN           : std_logic;
   SIGNAL Z_SIGN_stage4    : std_logic;
   SIGNAL add_out          : std_logic_vector(28 DOWNTO 0);
   SIGNAL cin              : std_logic;
   SIGNAL cin_sub          : std_logic;
   SIGNAL invert_A         : std_logic;
   SIGNAL invert_B         : std_logic;
   SIGNAL isINF_tab        : std_logic;
   SIGNAL isINF_tab_stage2 : std_logic;
   SIGNAL isINF_tab_stage3 : std_logic;
   SIGNAL isINF_tab_stage4 : std_logic;
   SIGNAL isNaN            : std_logic;
   SIGNAL isNaN_stage2     : std_logic;
   SIGNAL isNaN_stage3     : std_logic;
   SIGNAL isNaN_stage4     : std_logic;
   SIGNAL isZ_tab          : std_logic;
   SIGNAL isZ_tab_stage2   : std_logic;
   SIGNAL isZ_tab_stage3   : std_logic;
   SIGNAL isZ_tab_stage4   : std_logic;
   SIGNAL zero             : std_logic;
   SIGNAL zero_stage4      : std_logic;


   -- Component Declarations
   COMPONENT FPadd_stage1
   PORT (
      ADD_SUB     : IN     std_logic ;
      FP_A        : IN     std_logic_vector (31 DOWNTO 0);
      FP_B        : IN     std_logic_vector (31 DOWNTO 0);
      clk         : IN     std_logic ;
      ADD_SUB_out : OUT    std_logic ;
      A_EXP       : OUT    std_logic_vector (7 DOWNTO 0);
      A_SIGN      : OUT    std_logic ;
      A_in        : OUT    std_logic_vector (28 DOWNTO 0);
      A_isINF     : OUT    std_logic ;
      A_isNaN     : OUT    std_logic ;
      A_isZ       : OUT    std_logic ;
      B_EXP       : OUT    std_logic_vector (7 DOWNTO 0);
      B_XSIGN     : OUT    std_logic ;
      B_in        : OUT    std_logic_vector (28 DOWNTO 0);
      B_isINF     : OUT    std_logic ;
      B_isNaN     : OUT    std_logic ;
      B_isZ       : OUT    std_logic ;
      EXP_diff    : OUT    std_logic_vector (8 DOWNTO 0);
      cin_sub     : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPadd_stage2
   PORT (
      ADD_SUB_out      : IN     std_logic ;
      A_EXP            : IN     std_logic_vector (7 DOWNTO 0);
      A_SIGN           : IN     std_logic ;
      A_in             : IN     std_logic_vector (28 DOWNTO 0);
      A_isINF          : IN     std_logic ;
      A_isNaN          : IN     std_logic ;
      A_isZ            : IN     std_logic ;
      B_EXP            : IN     std_logic_vector (7 DOWNTO 0);
      B_XSIGN          : IN     std_logic ;
      B_in             : IN     std_logic_vector (28 DOWNTO 0);
      B_isINF          : IN     std_logic ;
      B_isNaN          : IN     std_logic ;
      B_isZ            : IN     std_logic ;
      EXP_diff         : IN     std_logic_vector (8 DOWNTO 0);
      cin_sub          : IN     std_logic ;
      clk              : IN     std_logic ;
      A_SIGN_stage2    : OUT    std_logic ;
      A_align          : OUT    std_logic_vector (28 DOWNTO 0);
      B_XSIGN_stage2   : OUT    std_logic ;
      B_align          : OUT    std_logic_vector (28 DOWNTO 0);
      EXP_base_stage2  : OUT    std_logic_vector (7 DOWNTO 0);
      cin              : OUT    std_logic ;
      invert_A         : OUT    std_logic ;
      invert_B         : OUT    std_logic ;
      isINF_tab_stage2 : OUT    std_logic ;
      isNaN_stage2     : OUT    std_logic ;
      isZ_tab_stage2   : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPadd_stage3
   PORT (
      A_SIGN_stage2    : IN     std_logic ;
      A_align          : IN     std_logic_vector (28 DOWNTO 0);
      B_XSIGN_stage2   : IN     std_logic ;
      B_align          : IN     std_logic_vector (28 DOWNTO 0);
      EXP_base_stage2  : IN     std_logic_vector (7 DOWNTO 0);
      cin              : IN     std_logic ;
      clk              : IN     std_logic ;
      invert_A         : IN     std_logic ;
      invert_B         : IN     std_logic ;
      isINF_tab_stage2 : IN     std_logic ;
      isNaN_stage2     : IN     std_logic ;
      isZ_tab_stage2   : IN     std_logic ;
      A_SIGN_stage3    : OUT    std_logic ;
      B_XSIGN_stage3   : OUT    std_logic ;
      EXP_base         : OUT    std_logic_vector (7 DOWNTO 0);
      add_out          : OUT    std_logic_vector (28 DOWNTO 0);
      isINF_tab_stage3 : OUT    std_logic ;
      isNaN_stage3     : OUT    std_logic ;
      isZ_tab_stage3   : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPadd_stage4
   PORT (
      A_SIGN_stage3    : IN     std_logic ;
      B_XSIGN_stage3   : IN     std_logic ;
      EXP_base         : IN     std_logic_vector (7 DOWNTO 0);
      add_out          : IN     std_logic_vector (28 DOWNTO 0);
      clk              : IN     std_logic ;
      isINF_tab_stage3 : IN     std_logic ;
      isNaN_stage3     : IN     std_logic ;
      isZ_tab_stage3   : IN     std_logic ;
      EXP_norm         : OUT    std_logic_vector (7 DOWNTO 0);
      OV_stage4        : OUT    std_logic ;
      SIG_norm         : OUT    std_logic_vector (27 DOWNTO 0);
      Z_SIGN_stage4    : OUT    std_logic ;
      isINF_tab_stage4 : OUT    std_logic ;
      isNaN_stage4     : OUT    std_logic ;
      isZ_tab_stage4   : OUT    std_logic ;
      zero_stage4      : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPadd_stage5
   PORT (
      EXP_norm         : IN     std_logic_vector (7 DOWNTO 0);
      OV_stage4        : IN     std_logic ;
      SIG_norm         : IN     std_logic_vector (27 DOWNTO 0);
      Z_SIGN_stage4    : IN     std_logic ;
      clk              : IN     std_logic ;
      isINF_tab_stage4 : IN     std_logic ;
      isNaN_stage4     : IN     std_logic ;
      isZ_tab_stage4   : IN     std_logic ;
      zero_stage4      : IN     std_logic ;
      OV               : OUT    std_logic ;
      SIG_norm2        : OUT    std_logic_vector (27 DOWNTO 0);
      Z_EXP            : OUT    std_logic_vector (7 DOWNTO 0);
      Z_SIGN           : OUT    std_logic ;
      isINF_tab        : OUT    std_logic ;
      isNaN            : OUT    std_logic ;
      isZ_tab          : OUT    std_logic ;
      zero             : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPadd_stage6
   PORT (
      OV        : IN     std_logic ;
      SIG_norm2 : IN     std_logic_vector (27 DOWNTO 0);
      Z_EXP     : IN     std_logic_vector (7 DOWNTO 0);
      Z_SIGN    : IN     std_logic ;
      clk       : IN     std_logic ;
      isINF_tab : IN     std_logic ;
      isNaN     : IN     std_logic ;
      isZ_tab   : IN     std_logic ;
      zero      : IN     std_logic ;
      FP_Z      : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : FPadd_stage1 USE ENTITY work.FPadd_stage1;
   FOR ALL : FPadd_stage2 USE ENTITY work.FPadd_stage2;
   FOR ALL : FPadd_stage3 USE ENTITY work.FPadd_stage3;
   FOR ALL : FPadd_stage4 USE ENTITY work.FPadd_stage4;
   FOR ALL : FPadd_stage5 USE ENTITY work.FPadd_stage5;
   FOR ALL : FPadd_stage6 USE ENTITY work.FPadd_stage6;
   -- pragma synthesis_on


BEGIN

   -- Instance port mappings.
   I1 : FPadd_stage1
      PORT MAP (
         ADD_SUB     => ADD_SUB,
         FP_A        => FP_A,
         FP_B        => FP_B,
         clk         => clk,
         ADD_SUB_out => ADD_SUB_out,
         A_EXP       => A_EXP,
         A_SIGN      => A_SIGN,
         A_in        => A_in,
         A_isINF     => A_isINF,
         A_isNaN     => A_isNaN,
         A_isZ       => A_isZ,
         B_EXP       => B_EXP,
         B_XSIGN     => B_XSIGN,
         B_in        => B_in,
         B_isINF     => B_isINF,
         B_isNaN     => B_isNaN,
         B_isZ       => B_isZ,
         EXP_diff    => EXP_diff,
         cin_sub     => cin_sub
      );
   I2 : FPadd_stage2
      PORT MAP (
         ADD_SUB_out      => ADD_SUB_out,
         A_EXP            => A_EXP,
         A_SIGN           => A_SIGN,
         A_in             => A_in,
         A_isINF          => A_isINF,
         A_isNaN          => A_isNaN,
         A_isZ            => A_isZ,
         B_EXP            => B_EXP,
         B_XSIGN          => B_XSIGN,
         B_in             => B_in,
         B_isINF          => B_isINF,
         B_isNaN          => B_isNaN,
         B_isZ            => B_isZ,
         EXP_diff         => EXP_diff,
         cin_sub          => cin_sub,
         clk              => clk,
         A_SIGN_stage2    => A_SIGN_stage2,
         A_align          => A_align,
         B_XSIGN_stage2   => B_XSIGN_stage2,
         B_align          => B_align,
         EXP_base_stage2  => EXP_base_stage2,
         cin              => cin,
         invert_A         => invert_A,
         invert_B         => invert_B,
         isINF_tab_stage2 => isINF_tab_stage2,
         isNaN_stage2     => isNaN_stage2,
         isZ_tab_stage2   => isZ_tab_stage2
      );
   I3 : FPadd_stage3
      PORT MAP (
         A_SIGN_stage2    => A_SIGN_stage2,
         A_align          => A_align,
         B_XSIGN_stage2   => B_XSIGN_stage2,
         B_align          => B_align,
         EXP_base_stage2  => EXP_base_stage2,
         cin              => cin,
         clk              => clk,
         invert_A         => invert_A,
         invert_B         => invert_B,
         isINF_tab_stage2 => isINF_tab_stage2,
         isNaN_stage2     => isNaN_stage2,
         isZ_tab_stage2   => isZ_tab_stage2,
         A_SIGN_stage3    => A_SIGN_stage3,
         B_XSIGN_stage3   => B_XSIGN_stage3,
         EXP_base         => EXP_base,
         add_out          => add_out,
         isINF_tab_stage3 => isINF_tab_stage3,
         isNaN_stage3     => isNaN_stage3,
         isZ_tab_stage3   => isZ_tab_stage3
      );
   I4 : FPadd_stage4
      PORT MAP (
         A_SIGN_stage3    => A_SIGN_stage3,
         B_XSIGN_stage3   => B_XSIGN_stage3,
         EXP_base         => EXP_base,
         add_out          => add_out,
         clk              => clk,
         isINF_tab_stage3 => isINF_tab_stage3,
         isNaN_stage3     => isNaN_stage3,
         isZ_tab_stage3   => isZ_tab_stage3,
         EXP_norm         => EXP_norm,
         OV_stage4        => OV_stage4,
         SIG_norm         => SIG_norm,
         Z_SIGN_stage4    => Z_SIGN_stage4,
         isINF_tab_stage4 => isINF_tab_stage4,
         isNaN_stage4     => isNaN_stage4,
         isZ_tab_stage4   => isZ_tab_stage4,
         zero_stage4      => zero_stage4
      );
   I5 : FPadd_stage5
      PORT MAP (
         EXP_norm         => EXP_norm,
         OV_stage4        => OV_stage4,
         SIG_norm         => SIG_norm,
         Z_SIGN_stage4    => Z_SIGN_stage4,
         clk              => clk,
         isINF_tab_stage4 => isINF_tab_stage4,
         isNaN_stage4     => isNaN_stage4,
         isZ_tab_stage4   => isZ_tab_stage4,
         zero_stage4      => zero_stage4,
         OV               => OV,
         SIG_norm2        => SIG_norm2,
         Z_EXP            => Z_EXP,
         Z_SIGN           => Z_SIGN,
         isINF_tab        => isINF_tab,
         isNaN            => isNaN,
         isZ_tab          => isZ_tab,
         zero             => zero
      );
   I6 : FPadd_stage6
      PORT MAP (
         OV        => OV,
         SIG_norm2 => SIG_norm2,
         Z_EXP     => Z_EXP,
         Z_SIGN    => Z_SIGN,
         clk       => clk,
         isINF_tab => isINF_tab,
         isNaN     => isNaN,
         isZ_tab   => isZ_tab,
         zero      => zero,
         FP_Z      => FP_Z
      );

END pipeline;
