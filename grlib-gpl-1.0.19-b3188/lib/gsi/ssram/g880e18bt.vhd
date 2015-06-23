-- 	Copyright 2000.	GSI Technology
-- 						GSI Appications
-- 						apps@gsitechnology.com
--  v 1.0 4/23/2002 Jeff Duagherty  1) based on G16272
LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY G880E18BT IS	
  GENERIC (
    CONSTANT A_size      : integer := 19;
    CONSTANT DQ_size     : integer := 9;
    CONSTANT bank_size   : integer := 1024 * 512;-- *8M /4 bytes in parallel
--250MHZ
--    CONSTANT tKQpipe     : time    := 2.5 ns ;
--    CONSTANT tKQflow     : time    := 5.5 ns ;
--    CONSTANT tKQXpipe     : time    := 1.5 ns ;
--    CONSTANT tKQXflow     : time    := 3.0 ns );
--225MHZ
--    CONSTANT tKQpipe     : time    := 2.7 ns ;
--    CONSTANT tKQflow     : time    := 6.0 ns ;
--    CONSTANT tKQXpipe     : time    := 1.5 ns ;
--    CONSTANT tKQXflow     : time    := 3.0 ns );
--200MHZ
--    CONSTANT tKQpipe     : time    := 3.0 ns ;
--    CONSTANT tKQflow     : time    := 6.5 ns ;
--    CONSTANT tKQXpipe     : time    := 1.5 ns ;
--    CONSTANT tKQXflow     : time    := 3.0 ns );
--166MHZ
    CONSTANT tKQpipe     : time    := 3.4 ns ;
    CONSTANT tKQflow     : time    := 7.0 ns ;
    CONSTANT tKQXpipe     : time    := 1.5 ns ;
    CONSTANT tKQXflow     : time    := 3.0 ns );
--150MHZ
--    CONSTANT tKQpipe     : time    := 3.8 ns ;
--    CONSTANT tKQflow     : time    := 6.7 ns ;
--    CONSTANT tKQXpipe     : time    := 1.5 ns ;
--    CONSTANT tKQXflow     : time    := 3.0 ns );
--133MHZ
--    CONSTANT tKQpipe     : time    := 4.0 ns ;
--    CONSTANT tKQflow     : time    := 8.5 ns ;
--    CONSTANT tKQXpipe     : time    := 1.5 ns ;
--    CONSTANT tKQXflow     : time    := 3.0 ns );
  PORT (
    SIGNAL A88   : IN std_logic_vector(A_size - 1 DOWNTO 0);-- address
    SIGNAL DQa   : INOUT std_logic_vector(DQ_size DOWNTO 1) BUS;-- byte A data
    SIGNAL DQb   : INOUT std_logic_vector(DQ_size DOWNTO 1) BUS;-- byte B data
    SIGNAL nBa   : IN std_logic;-- bank A write enable
    SIGNAL nBb   : IN std_logic;-- bank B write enable
    SIGNAL CK    : IN std_logic;-- clock
    SIGNAL nBW   : IN std_logic;-- byte write enable
    SIGNAL nGW   : IN std_logic;-- Global write enable
    SIGNAL nE1   : IN std_logic;-- chip enable 1
    SIGNAL E2    : IN std_logic;-- chip enable 1
    SIGNAL nE3   : IN std_logic;-- chip enable 1
    SIGNAL nG    : IN std_logic;-- output enable
    SIGNAL nADV  : IN std_logic;-- Advance not / load
    SIGNAL nADSC : IN std_logic;      -- ONLY FOR BURST DEVICES
    SIGNAL nADSP : IN std_logic;      -- ONLY FOR BURST DEVICES
    SIGNAL ZZ    : IN std_logic;-- power down
    SIGNAL nFT   : IN std_logic;-- Pipeline / Flow through
    SIGNAL nLBO  : IN std_logic);-- Linear Burst Order not

END G880E18BT;

LIBRARY GSI;
LIBRARY Std;
ARCHITECTURE BURST_8MEG_x18 OF G880E18BT IS
  USE GSI.FUNCTIONS.ALL;
  USE Std.textio.ALL;
  component VHDL_BURST_CORE
    generic (
      CONSTANT bank_size   : integer := 1024 * 512;-- *8M /4 bytes in parallel
      CONSTANT A_size      : integer := 19;
      CONSTANT DQ_size     : integer := 9);
    port (
      signal       A           : in    std_logic_vector(A_size - 1 downto 0);  -- address
      signal       DQa         : inout std_logic_vector(DQ_size downto 1) bus;  -- byte A data
      signal       DQb         : inout std_logic_vector(DQ_size downto 1) bus;  -- byte B data
      signal       DQc         : inout std_logic_vector(DQ_size downto 1) bus;  -- byte C data
      signal       DQd         : inout std_logic_vector(DQ_size downto 1) bus;  -- byte D data
      signal       DQe         : inout std_logic_vector(DQ_size downto 1) bus;  -- byte E data
      signal       DQf         : inout std_logic_vector(DQ_size downto 1) bus;  -- byte F data
      signal       DQg         : inout std_logic_vector(DQ_size downto 1) bus;  -- byte G data
      signal       DQh         : inout std_logic_vector(DQ_size downto 1) bus;  -- byte H data
      signal       nBa         : in    std_logic;  -- bank A write enable
      signal       nBb         : in    std_logic;  -- bank B write enable
      signal       nBc         : in    std_logic;  -- bank C write enable
      signal       nBd         : in    std_logic;  -- bank D write enable
      signal       nBe         : in    std_logic;
      signal       nBf         : in    std_logic;
      signal       nBg         : in    std_logic;
      signal       nBh         : in    std_logic;
      signal       CK          : in    std_logic;  -- clock
      signal       nBW         : in    std_logic;  -- byte write enable
      signal       nGW         : in    std_logic;  -- Global write enable
      signal       nE1         : in    std_logic;  -- chip enable 1
      signal       E2          : in    std_logic;  -- chip enable 2
      signal       nE3         : in    std_logic;  -- chip enable 3
      signal       nG          : in    std_logic;  -- output enable
      signal       nADV        : in    std_logic;  -- Advance not / load
      signal       nADSC       : in    std_logic;  -- ONLY FOR BURST DEVICES
      signal       nADSP       : in    std_logic;  -- ONLY FOR BURST DEVICES
      signal       ZZ          : in    std_logic;  -- power down
      signal       nFT         : in    std_logic;  -- Pipeline / Flow through
      signal       nLBO        : in    std_logic;  -- Linear Burst Order not
      signal       SCD         : in    std_logic;  -- ONLY FOR BURST DEVICES
      SIGNAL       HighZ       : std_logic_vector(DQ_size downto 1) ;
      signal       tKQ         :       time;
      signal       tKQX         :       time);
  end component;

  SIGNAL HighZ : std_logic_vector(DQ_size downto 1);
  SIGNAL nBc   : std_logic := '1';
  SIGNAL nBd   : std_logic := '1';
  SIGNAL nBe   : std_logic := '1';
  SIGNAL nBf   : std_logic := '1';
  SIGNAL nBg   : std_logic := '1';
  SIGNAL nBh   : std_logic := '1';
  SIGNAL SCD   : std_logic := '0';-- ONLY FOR BURST DEVICES
  SIGNAL DQc   : std_logic_vector(DQ_size DOWNTO 1);-- byte C data
  SIGNAL DQd   : std_logic_vector(DQ_size DOWNTO 1);-- byte D data
  SIGNAL DQe   : std_logic_vector(DQ_size DOWNTO 1);-- byte E data
  SIGNAL DQf   : std_logic_vector(DQ_size DOWNTO 1);-- byte F data
  SIGNAL DQg   : std_logic_vector(DQ_size DOWNTO 1);-- byte G data
  SIGNAL DQh   : std_logic_vector(DQ_size DOWNTO 1);-- byte H data
  signal A     : std_logic_vector(A_size - 1 downto 0);
  signal tKQ   : time;
  signal tKQX   : time;
begin 
  tKQ <= TERNARY(nFT, tKQpipe, tKQflow);
  tKQX <= TERNARY(nFT, tKQXpipe, tKQXflow);
  HighZ <= to_stdlogicvector( "ZZZZZZZZZZ" ,DQ_size);
  A     <= to_stdlogicvector(A88, A_size);
  CORE_CALL : VHDL_BURST_CORE port map (
    A, DQA, DQB, DQC, DQD, DQE, DQF, DQG, DQH, NBA, NBB, NBC, NBD, NBE, NBF, NBG, NBH, CK, NBW, NGW, NE1, E2, NE3, NG, NADV, NADSC, NADSP, ZZ, NFT, NLBO, SCD, HighZ, tKQ, tKQX);

END BURST_8MEG_x18;
