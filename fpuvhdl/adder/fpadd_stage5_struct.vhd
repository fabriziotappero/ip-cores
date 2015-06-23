-- VHDL Entity work.FPadd_stage5.interface
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

ENTITY FPadd_stage5 IS
   PORT( 
      EXP_norm         : IN     std_logic_vector (7 DOWNTO 0);
      OV_stage4        : IN     std_logic;
      SIG_norm         : IN     std_logic_vector (27 DOWNTO 0);
      Z_SIGN_stage4    : IN     std_logic;
      clk              : IN     std_logic;
      isINF_tab_stage4 : IN     std_logic;
      isNaN_stage4     : IN     std_logic;
      isZ_tab_stage4   : IN     std_logic;
      zero_stage4      : IN     std_logic;
      OV               : OUT    std_logic;
      SIG_norm2        : OUT    std_logic_vector (27 DOWNTO 0);
      Z_EXP            : OUT    std_logic_vector (7 DOWNTO 0);
      Z_SIGN           : OUT    std_logic;
      isINF_tab        : OUT    std_logic;
      isNaN            : OUT    std_logic;
      isZ_tab          : OUT    std_logic;
      zero             : OUT    std_logic
   );

-- Declarations

END FPadd_stage5 ;

--
-- VHDL Architecture work.FPadd_stage5.struct
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

ARCHITECTURE struct OF FPadd_stage5 IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL EXP_round_int : std_logic_vector(7 DOWNTO 0);
   SIGNAL SIG_norm2_int : std_logic_vector(27 DOWNTO 0);
   SIGNAL SIG_round_int : std_logic_vector(27 DOWNTO 0);
   SIGNAL Z_EXP_int     : std_logic_vector(7 DOWNTO 0);


   -- Component Declarations
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

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : FPnormalize USE ENTITY work.FPnormalize;
   FOR ALL : FPround USE ENTITY work.FPround;
   -- pragma synthesis_on


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   --reg1 1
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         Z_EXP <= Z_EXP_int;
         SIG_norm2 <= SIG_norm2_int;
         Z_SIGN <= Z_SIGN_stage4;
         OV <= OV_stage4;
         zero <= zero_stage4;
         isINF_tab <= isINF_tab_stage4;
         isNaN <= isNaN_stage4;
         isZ_tab <= isZ_tab_stage4;
      END IF;
   END PROCESS;


   -- Instance port mappings.
   I11 : FPnormalize
      GENERIC MAP (
         SIG_width => 28
      )
      PORT MAP (
         SIG_in  => SIG_round_int,
         EXP_in  => EXP_round_int,
         SIG_out => SIG_norm2_int,
         EXP_out => Z_EXP_int
      );
   I10 : FPround
      GENERIC MAP (
         SIG_width => 28
      )
      PORT MAP (
         SIG_in  => SIG_norm,
         EXP_in  => EXP_norm,
         SIG_out => SIG_round_int,
         EXP_out => EXP_round_int
      );

END struct;
