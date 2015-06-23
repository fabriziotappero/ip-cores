-- VHDL Entity HAVOC.FPmul_stage4.interface
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

ENTITY FPmul_stage4 IS
   PORT( 
      EXP_neg       : IN     std_logic;
      EXP_out_round : IN     std_logic_vector (7 DOWNTO 0);
      EXP_pos       : IN     std_logic;
      SIGN_out      : IN     std_logic;
      SIG_out_round : IN     std_logic_vector (27 DOWNTO 0);
      clk           : IN     std_logic;
      isINF_tab     : IN     std_logic;
      isNaN         : IN     std_logic;
      isZ_tab       : IN     std_logic;
      FP_Z          : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END FPmul_stage4 ;

--
-- VHDL Architecture HAVOC.FPmul_stage4.struct
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

ARCHITECTURE struct OF FPmul_stage4 IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL EXP_out       : std_logic_vector(7 DOWNTO 0);
   SIGNAL FP            : std_logic_vector(31 DOWNTO 0);
   SIGNAL SIG_isZ       : std_logic;
   SIGNAL SIG_out       : std_logic_vector(22 DOWNTO 0);
   SIGNAL SIG_out_norm2 : std_logic_vector(27 DOWNTO 0);
   SIGNAL isINF         : std_logic;
   SIGNAL isZ           : std_logic;


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
   FOR ALL : FPnormalize USE ENTITY work.FPnormalize;
   FOR ALL : PackFP USE ENTITY work.PackFP;
   -- pragma synthesis_on


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 trim
   -- trim 1 
   SIG_out <= SIG_out_norm2(25 DOWNTO 3);

   -- HDL Embedded Text Block 2 zero
   -- zero 2
   SIG_isZ <= '1' WHEN ((SIG_out_norm2(26 DOWNTO 3)=X"000000") OR 
   (EXP_neg='1' AND EXP_out(7)='1')) ELSE '0';

   -- HDL Embedded Text Block 3 isINF_logic
   -- isINF_logic 3
   PROCESS(isZ,isINF_tab, EXP_pos, EXP_out)
   BEGIN
      IF isZ='0' THEN
         IF isINF_tab='1' THEN
            isINF <= '1';
         ELSIF EXP_out=X"FF" THEN
           isINF <='1';
         ELSIF ((EXP_pos='1') AND (EXP_out(7)='0'))  THEN
           isINF <='1';
         ELSE
           isINF <= '0';
         END IF;
      ELSE
          isINF <= '0';
      END IF;
   END PROCESS;

   -- HDL Embedded Text Block 4 latch
   -- latch 4
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         FP_Z <= FP;
      END IF;
   END PROCESS;


   -- ModuleWare code(v1.1) for instance 'I2' of 'or'
   isZ <= SIG_isZ OR isZ_tab;

   -- Instance port mappings.
   I1 : FPnormalize
      GENERIC MAP (
         SIG_width => 28
      )
      PORT MAP (
         SIG_in  => SIG_out_round,
         EXP_in  => EXP_out_round,
         SIG_out => SIG_out_norm2,
         EXP_out => EXP_out
      );
   I3 : PackFP
      PORT MAP (
         SIGN  => SIGN_out,
         EXP   => EXP_out,
         SIG   => SIG_out,
         isNaN => isNaN,
         isINF => isINF,
         isZ   => isZ,
         FP    => FP
      );

END struct;
