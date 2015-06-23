---------------------------------------------------------------------------------------------------
--! @file
--! @brief This is the top-level design for a simple 8-bit microprossesor.
--! @details This is a 8-bit microprocessor which is know as SAP-1 or
--! Simple-As-Possible Computer. It is described in [1].
--! @author Ahmed Shahein
--! @email ahmed.shahein@ieee.org
--! @see [1] Malvino, A.P. and Brown, J.A., "Digital computer electronics", Glencoe/McGraw-Hill, 1992.
--!
--! @image html Architecture.png
---------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY MP IS
   PORT( 
      clk : IN     std_logic;								--! Active high asynchronous clear
      clr : IN     std_logic;								--! Rising edge clock
      hlt : OUT    std_logic;								--! Halt signal to stop processing data
      q3  : OUT    std_logic_vector (7 DOWNTO 0)	--! 8-bit output
   );
END MP ;

ARCHITECTURE struct OF MP IS

   -- Internal signal declarations
   SIGNAL Ce     : std_logic;								--! Chip select for ROM
   SIGNAL D      : std_logic_vector(3 DOWNTO 0);	--! MAR 4-bit address input
   SIGNAL Eu     : std_logic;								--! Enable ALU
   SIGNAL Lm     : std_logic;								--! Content of PC are latched into MAR on the next +ve edge (LOW)
   SIGNAL Q2     : std_logic_vector(3 DOWNTO 0);	--! MAR 4-bit address output
   SIGNAL Su     : std_logic;								--! Add or Sub
   SIGNAL W      : std_logic_vector(7 DOWNTO 0);	--! W-bus the major internal data bus
   SIGNAL add    : std_logic;								--! IR decoder add control signal
   SIGNAL con    : std_logic_vector(11 DOWNTO 0);	--! Control word bus
   SIGNAL Cp     : std_logic;								--! Chip select PC
   SIGNAL d1     : std_logic_vector(7 DOWNTO 0);	--! 8-bit output data to Adder-Subtractor block
   SIGNAL Ea     : std_logic;								--! Enable AC
   SIGNAL Ei     : std_logic;								--! Enable IR
   SIGNAL Ep     : std_logic;								--! Enable PC
   SIGNAL La     : std_logic;								--! Load Accumulator AC
   SIGNAL Lb     : std_logic;								--! Load B Register B
   SIGNAL lda    : std_logic;								--! Load Accumulator instruction
   SIGNAL Li     : std_logic;								--! Load Instruction Register IR
   SIGNAL Lo     : std_logic;								--! Load Output Register O
   SIGNAL output : std_logic;								--! Output the result
   SIGNAL q      : std_logic_vector(3 DOWNTO 0);	--! 4-bit PC output
   SIGNAL q1     : std_logic_vector(7 DOWNTO 0);	--! ALU B input 8-bit from B-register
   SIGNAL q_alu  : std_logic_vector(7 DOWNTO 0);	--! ALU A input 8-bit from AC
   SIGNAL q_c    : std_logic_vector(3 DOWNTO 0);	--! IR 4-bit output control word to Control-Sequencer block
   SIGNAL q_w    : std_logic_vector(3 DOWNTO 0);	--! IR 4-bit output data word to W-bus
   SIGNAL sub    : std_logic;								--! IR decoder sub control signal


   -- Component Declarations
   COMPONENT AC
   PORT (
      d      : IN     std_logic_vector (7 DOWNTO 0);
      q_alu  : OUT    std_logic_vector (7 DOWNTO 0);
      q_data : OUT    std_logic_vector (7 DOWNTO 0);
      clk    : IN     std_logic ;
      ea     : IN     std_logic ;
      clr    : IN     std_logic ;
      la     : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT ALU
   PORT (
      A  : IN     std_logic_vector (7 DOWNTO 0);
      B  : IN     std_logic_vector (7 DOWNTO 0);
      S  : OUT    std_logic_vector (7 DOWNTO 0);
      Su : IN     std_logic ;
      Eu : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT B_Reg
   PORT (
      d   : IN     std_logic_vector (7 DOWNTO 0);
      q   : OUT    std_logic_vector (7 DOWNTO 0);
      clk : IN     std_logic ;
      clr : IN     std_logic ;
      lb  : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT CU
   PORT (
      ADD : IN     std_logic ;
      CLK : IN     std_logic ;
      CLR : IN     std_logic ;
      LDA : IN     std_logic ;
      O   : IN     std_logic ;
      SUB : IN     std_logic ;
      con : OUT    std_logic_vector (11 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT IR
   PORT (
      clk : IN     std_logic ;
      clr : IN     std_logic ;
      li  : IN     std_logic ;
      ei  : IN     std_logic ;
      d   : IN     std_logic_vector (7 DOWNTO 0);
      q_w : OUT    std_logic_vector (3 DOWNTO 0);
      q_c : OUT    std_logic_vector (3 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT IRDec
   PORT (
      q_c    : IN     std_logic_vector (3 DOWNTO 0);
       LDA     : OUT    std_logic;
       ADD     : OUT    std_logic;
       SUB     : OUT    std_logic;
       OUTPUT  : OUT    std_logic;
       HLT     : OUT    std_logic
   );
   END COMPONENT;
   COMPONENT MAR
   PORT (
      CLK : IN     std_logic ;
      CLR : IN     std_logic ;
      Lm  : IN     std_logic ;
      D   : IN     std_logic_vector (3 DOWNTO 0);
      Q   : OUT    std_logic_vector (3 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT PC
   PORT (
      ep  : IN     std_logic ;
      clr : IN     std_logic ;
      clk : IN     std_logic ;
      cp  : IN     std_logic ;
      q   : OUT    std_logic_vector (3 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT ROM_16_8
   PORT (
      read     : IN     std_logic ;
      address  : IN     std_logic_vector (3 DOWNTO 0);
      data_out : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT O
   PORT (
      d   : IN     std_logic_vector (7 DOWNTO 0);
      q   : OUT    std_logic_vector (7 DOWNTO 0);
      clk : IN     std_logic ;
      clr : IN     std_logic ;
      lo  : IN     std_logic 
   );
   END COMPONENT;

BEGIN

   -- HDL Embedded Text Block 1 eb1
   Cp <= con(11);
   Ep <= con(10);
   Lm <= con(9);
   Ce <= con(8);
   Li <= con(7);
   Ei <= con(6);
   La <= con(5);
   Ea <= con(4);
   Su <= con(3);
   Eu <= con(2);
   Lb <= con(1);
   Lo <= con(0);

   -- HDL Embedded Text Block 2 eb2
   w(3 downto 0) <= q;

   -- HDL Embedded Text Block 3 eb3
   w(3 downto 0) <= q_w;

   -- HDL Embedded Text Block 4 eb4
   D <= w(3 downto 0);

   -- Instance port mappings.
   Accumulator : AC
      PORT MAP (
         d      => W,
         q_alu  => q_alu,
         q_data => d1,
         clk    => clk,
         ea     => ea,
         clr    => clr,
         la     => la
      );
   AddSub : ALU
      PORT MAP (
         A  => q_alu,
         B  => q1,
         S  => W,
         Su => Su,
         Eu => Eu
      );
   BReg : B_Reg
      PORT MAP (
         d   => W,
         q   => q1,
         clk => clk,
         clr => clr,
         lb  => lb
      );
   CPU : CU
      PORT MAP (
         ADD => add,
         CLK => clk,
         CLR => clr,
         LDA => lda,
         O   => output,
         SUB => sub,
         con => con
      );
   IRReg : IR
      PORT MAP (
         clk => clk,
         clr => clr,
         li  => li,
         ei  => ei,
         d   => W,
         q_w => q_w,
         q_c => q_c
      );
   IRDecoder : IRDec
      PORT MAP (
         q_c    => q_c,
         lda    => lda,
         add    => add,
         sub    => sub,
         output => output,
         hlt    => hlt
      );
   MemoryAddressReg : MAR
      PORT MAP (
         CLK => clk,
         CLR => clr,
         Lm  => Lm,
         D   => D,
         Q   => Q2
      );
   ProgramCounter : PC
      PORT MAP (
         ep  => ep,
         clr => clr,
         clk => clk,
         cp  => cp,
         q   => q
      );
   ROM : ROM_16_8
      PORT MAP (
         read     => Ce,
         address  => Q2,
         data_out => W
      );
   OReg : O
      PORT MAP (
         d   => d1,
         q   => q3,
         clk => clk,
         clr => clr,
         lo  => lo
      );

END struct;