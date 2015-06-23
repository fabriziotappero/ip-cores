-- VHDL Entity HAVOC.FPmul_stage1.interface
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

ENTITY FPmul_stage1 IS
   PORT( 
      FP_A            : IN     std_logic_vector (31 DOWNTO 0);
      FP_B            : IN     std_logic_vector (31 DOWNTO 0);
      clk             : IN     std_logic;
      A_EXP           : OUT    std_logic_vector (7 DOWNTO 0);
      A_SIG           : OUT    std_logic_vector (31 DOWNTO 0);
      B_EXP           : OUT    std_logic_vector (7 DOWNTO 0);
      B_SIG           : OUT    std_logic_vector (31 DOWNTO 0);
      SIGN_out_stage1 : OUT    std_logic;
      isINF_stage1    : OUT    std_logic;
      isNaN_stage1    : OUT    std_logic;
      isZ_tab_stage1  : OUT    std_logic
   );

-- Declarations

END FPmul_stage1 ;

--
-- VHDL Architecture HAVOC.FPmul_stage1.struct
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


ARCHITECTURE struct OF FPmul_stage1 IS

   -- Architecture declarations
      -- Non hierarchical truthtable declarations
    


   -- Internal signal declarations
   SIGNAL A_EXP_int    : std_logic_vector(7 DOWNTO 0);
   SIGNAL A_SIGN       : std_logic;
   SIGNAL A_SIG_int    : std_logic_vector(31 DOWNTO 0);
   SIGNAL A_isINF      : std_logic;
   SIGNAL A_isNaN      : std_logic;
   SIGNAL A_isZ        : std_logic;
   SIGNAL B_EXP_int    : std_logic_vector(7 DOWNTO 0);
   SIGNAL B_SIGN       : std_logic;
   SIGNAL B_SIG_int    : std_logic_vector(31 DOWNTO 0);
   SIGNAL B_isINF      : std_logic;
   SIGNAL B_isNaN      : std_logic;
   SIGNAL B_isZ        : std_logic;
   SIGNAL SIGN_out_int : std_logic;
   SIGNAL isINF_int    : std_logic;
   SIGNAL isNaN_int    : std_logic;
   SIGNAL isZ_tab_int  : std_logic;


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
   -- HDL Embedded Text Block 1 latch
   -- latch 1
   
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         SIGN_out_stage1 <= SIGN_out_int;
         A_EXP <= A_EXP_int;
         A_SIG <= A_SIG_int;
         isINF_stage1 <= isINF_int;
         isNaN_stage1 <= isNaN_int;
         isZ_tab_stage1 <= isZ_tab_int;
         B_EXP <= B_EXP_int;
         B_SIG <= B_SIG_int;
      END IF;
   END PROCESS;

   -- HDL Embedded Block 2 exceptions
   -- Non hierarchical truthtable
   ---------------------------------------------------------------------------
   exceptions_truth_process: PROCESS(A_isINF, A_isNaN, A_isZ, B_isINF, B_isNaN, B_isZ)
   ---------------------------------------------------------------------------
   BEGIN
      -- Block 1
      IF (A_isINF = '0') AND (A_isNaN = '0') AND (A_isZ = '0') AND (B_isINF = '0') AND (B_isNaN = '0') AND (B_isZ = '0') THEN
         isZ_tab_int <= '0';
         isINF_int <= '0';
         isNaN_int <= '0';
      ELSIF (A_isINF = '1') AND (B_isZ = '1') THEN
         isZ_tab_int <= '0';
         isINF_int <= '0';
         isNaN_int <= '1';
      ELSIF (A_isZ = '1') AND (B_isINF = '1') THEN
         isZ_tab_int <= '0';
         isINF_int <= '0';
         isNaN_int <= '1';
      ELSIF (A_isINF = '1') THEN
         isZ_tab_int <= '0';
         isINF_int <= '1';
         isNaN_int <= '0';
      ELSIF (B_isINF = '1') THEN
         isZ_tab_int <= '0';
         isINF_int <= '1';
         isNaN_int <= '0';
      ELSIF (A_isNaN = '1') THEN
         isZ_tab_int <= '0';
         isINF_int <= '0';
         isNaN_int <= '1';
      ELSIF (B_isNaN = '1') THEN
         isZ_tab_int <= '0';
         isINF_int <= '0';
         isNaN_int <= '1';
      ELSIF (A_isZ = '1') THEN
         isZ_tab_int <= '1';
         isINF_int <= '0';
         isNaN_int <= '0';
      ELSIF (B_isZ = '1') THEN
         isZ_tab_int <= '1';
         isINF_int <= '0';
         isNaN_int <= '0';
      ELSE
         isZ_tab_int <= '0';
         isINF_int <= '0';
         isNaN_int <= '0';
      END IF;

   END PROCESS exceptions_truth_process;

   -- Architecture concurrent statements
    



   -- ModuleWare code(v1.1) for instance 'I3' of 'xor'
   SIGN_out_int <= A_SIGN XOR B_SIGN;

   -- Instance port mappings.
   I0 : UnpackFP
      PORT MAP (
         FP    => FP_A,
         SIG   => A_SIG_int,
         EXP   => A_EXP_int,
         SIGN  => A_SIGN,
         isNaN => A_isNaN,
         isINF => A_isINF,
         isZ   => A_isZ,
         isDN  => OPEN
      );
   I1 : UnpackFP
      PORT MAP (
         FP    => FP_B,
         SIG   => B_SIG_int,
         EXP   => B_EXP_int,
         SIGN  => B_SIGN,
         isNaN => B_isNaN,
         isINF => B_isINF,
         isZ   => B_isZ,
         isDN  => OPEN
      );

END struct;
