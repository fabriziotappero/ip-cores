-- VHDL Entity work.FPadd_stage6.interface
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

ENTITY FPadd_stage6 IS
   PORT( 
      OV        : IN     std_logic;
      SIG_norm2 : IN     std_logic_vector (27 DOWNTO 0);
      Z_EXP     : IN     std_logic_vector (7 DOWNTO 0);
      Z_SIGN    : IN     std_logic;
      clk       : IN     std_logic;
      isINF_tab : IN     std_logic;
      isNaN     : IN     std_logic;
      isZ_tab   : IN     std_logic;
      zero      : IN     std_logic;
      FP_Z      : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END FPadd_stage6 ;

--
-- VHDL Architecture work.FPadd_stage6.struct
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

ARCHITECTURE struct OF FPadd_stage6 IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL EXP_isINF : std_logic;
   SIGNAL FP_Z_int  : std_logic_vector(31 DOWNTO 0);
   SIGNAL Z_SIG     : std_logic_vector(22 DOWNTO 0);
   SIGNAL isINF     : std_logic;
   SIGNAL isZ       : std_logic;


   -- Component Declarations
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

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : PackFP USE ENTITY work.PackFP;
   -- pragma synthesis_on


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   --reg1 1
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         FP_Z <= FP_Z_int;
      END IF;
   END PROCESS;

   -- HDL Embedded Text Block 2 eb2
   -- eb2 2
   Z_SIG <= SIG_norm2(25 DOWNTO 3);

   -- HDL Embedded Text Block 9 eb7
   -- eb7 9
   EXP_isINF <= '1' WHEN (OV='1' OR Z_EXP=X"FF") ELSE '0';


   -- ModuleWare code(v1.1) for instance 'I7' of 'or'
   isINF <= EXP_isINF OR isINF_tab;

   -- ModuleWare code(v1.1) for instance 'I17' of 'or'
   isZ <= zero OR isZ_tab;

   -- Instance port mappings.
   I2 : PackFP
      PORT MAP (
         SIGN  => Z_SIGN,
         EXP   => Z_EXP,
         SIG   => Z_SIG,
         isNaN => isNaN,
         isINF => isINF,
         isZ   => isZ,
         FP    => FP_Z_int
      );

END struct;
