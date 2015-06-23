-- VHDL Entity work.FPadd_stage3.interface
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

ENTITY FPadd_stage3 IS
   PORT( 
      A_SIGN_stage2    : IN     std_logic;
      A_align          : IN     std_logic_vector (28 DOWNTO 0);
      B_XSIGN_stage2   : IN     std_logic;
      B_align          : IN     std_logic_vector (28 DOWNTO 0);
      EXP_base_stage2  : IN     std_logic_vector (7 DOWNTO 0);
      cin              : IN     std_logic;
      clk              : IN     std_logic;
      invert_A         : IN     std_logic;
      invert_B         : IN     std_logic;
      isINF_tab_stage2 : IN     std_logic;
      isNaN_stage2     : IN     std_logic;
      isZ_tab_stage2   : IN     std_logic;
      A_SIGN_stage3    : OUT    std_logic;
      B_XSIGN_stage3   : OUT    std_logic;
      EXP_base         : OUT    std_logic_vector (7 DOWNTO 0);
      add_out          : OUT    std_logic_vector (28 DOWNTO 0);
      isINF_tab_stage3 : OUT    std_logic;
      isNaN_stage3     : OUT    std_logic;
      isZ_tab_stage3   : OUT    std_logic
   );

-- Declarations

END FPadd_stage3 ;

--
-- VHDL Architecture work.FPadd_stage3.struct
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

ARCHITECTURE struct OF FPadd_stage3 IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL A_inv       : std_logic_vector(28 DOWNTO 0);
   SIGNAL B_inv       : std_logic_vector(28 DOWNTO 0);
   SIGNAL add_out_int : std_logic_vector(28 DOWNTO 0);


   -- Component Declarations
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

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : FPinvert USE ENTITY work.FPinvert;
   -- pragma synthesis_on


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 reg1
   -- reg1 1                                  
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
         add_out <= add_out_int;
         EXP_base <= EXP_base_stage2;
         A_SIGN_stage3 <= A_SIGN_stage2;
         B_XSIGN_stage3 <= B_XSIGN_stage2;
         isINF_tab_stage3 <= isINF_tab_stage2;
         isNaN_stage3 <= isNaN_stage2;
         isZ_tab_stage3 <= isZ_tab_stage2;
      END IF;
   END PROCESS;


   -- ModuleWare code(v1.1) for instance 'I4' of 'add'
   I4combo: PROCESS (A_inv, B_inv, cin)
   VARIABLE mw_I4t0 : std_logic_vector(29 DOWNTO 0);
   VARIABLE mw_I4t1 : std_logic_vector(29 DOWNTO 0);
   VARIABLE mw_I4sum : signed(29 DOWNTO 0);
   VARIABLE mw_I4carry : std_logic;
   BEGIN
      mw_I4t0 := A_inv(28) & A_inv;
      mw_I4t1 := B_inv(28) & B_inv;
      mw_I4carry := cin;
      mw_I4sum := signed(mw_I4t0) + signed(mw_I4t1) + mw_I4carry;
      add_out_int <= conv_std_logic_vector(mw_I4sum(28 DOWNTO 0),29);
   END PROCESS I4combo;

   -- Instance port mappings.
   I14 : FPinvert
      GENERIC MAP (
         width => 29
      )
      PORT MAP (
         A_in     => A_align,
         B_in     => B_align,
         invert_A => invert_A,
         invert_B => invert_B,
         A_out    => A_inv,
         B_out    => B_inv
      );

END struct;
