-- VHDL Entity HAVOC.FPmul_stage3.interface
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

ENTITY FPmul_stage3 IS
   PORT( 
      EXP_in          : IN     std_logic_vector (7 DOWNTO 0);
      EXP_neg_stage2  : IN     std_logic;
      EXP_pos_stage2  : IN     std_logic;
      SIGN_out_stage2 : IN     std_logic;
      SIG_in          : IN     std_logic_vector (27 DOWNTO 0);
      clk             : IN     std_logic;
      isINF_stage2    : IN     std_logic;
      isNaN_stage2    : IN     std_logic;
      isZ_tab_stage2  : IN     std_logic;
      EXP_neg         : OUT    std_logic;
      EXP_out_round   : OUT    std_logic_vector (7 DOWNTO 0);
      EXP_pos         : OUT    std_logic;
      SIGN_out        : OUT    std_logic;
      SIG_out_round   : OUT    std_logic_vector (27 DOWNTO 0);
      isINF_tab       : OUT    std_logic;
      isNaN           : OUT    std_logic;
      isZ_tab         : OUT    std_logic
   );

-- Declarations

END FPmul_stage3 ;

--
-- VHDL Architecture HAVOC.FPmul_stage3.struct
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

ARCHITECTURE struct OF FPmul_stage3 IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL EXP_out      : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_out_norm : std_logic_vector(7 DOWNTO 0);
   SIGNAL SIG_out      : std_logic_vector(27 DOWNTO 0);
   SIGNAL SIG_out_norm : std_logic_vector(27 DOWNTO 0);


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
   -- HDL Embedded Text Block 1 latch
   -- latch 1
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         EXP_out_round <= EXP_out;
         SIG_out_round <= SIG_out;
      END IF;
   END PROCESS;

   -- HDL Embedded Text Block 2 latch2
   -- latch2 2
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         isINF_tab <= isINF_stage2;
         isNaN <= isNaN_stage2;
         isZ_tab <= isZ_tab_stage2;
         SIGN_out <= SIGN_out_stage2;
         EXP_pos <= EXP_pos_stage2;
         EXP_neg <= EXP_neg_stage2;
      END IF;
   END PROCESS;


   -- Instance port mappings.
   I9 : FPnormalize
      GENERIC MAP (
         SIG_width => 28
      )
      PORT MAP (
         SIG_in  => SIG_in,
         EXP_in  => EXP_in,
         SIG_out => SIG_out_norm,
         EXP_out => EXP_out_norm
      );
   I11 : FPround
      GENERIC MAP (
         SIG_width => 28
      )
      PORT MAP (
         SIG_in  => SIG_out_norm,
         EXP_in  => EXP_out_norm,
         SIG_out => SIG_out,
         EXP_out => EXP_out
      );

END struct;
