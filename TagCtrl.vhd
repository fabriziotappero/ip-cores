-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica       
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     File name      : tagCtrl.vhd 
--
--     Description    : top level of the tag control - Includes TagFSM.
--
--     Author         : Erwing R. Sanchez Sanchez <erwing.sanchez@polito.it>
--            
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library WORK;
use WORK.epc_tag.all;

entity TagCtrl is
  generic(
    WordsRSV : integer := 8;
    WordsEPC : integer := 16;
    WordsTID : integer := 8;
    WordsUSR : integer := 256;
    AddrRSV  : integer := 2;            -- 1/2 memory address pins
    AddrEPC  : integer := 3;            -- 1/2 memory address pins
    AddrTID  : integer := 2;            -- 1/2 memory address pins
    AddrUSR  : integer := 5;            -- 1/2 memory address pins (maximum)
    Data     : integer := 16);          -- memory data width
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    -- Receiver
    CommDone  : in  CommandInternalCode_t;
    Data_r    : in  std_logic_vector(31 downto 0);
    Pointer_r : in  std_logic_vector(15 downto 0);
    RN16_r    : in  std_logic_vector(15 downto 0);
    Length_r  : in  std_logic_vector(7 downto 0);
    Mask_r    : in  std_logic_vector(MASKLENGTH-1 downto 0);
    -- Transmitter Command and Output buffer
    trm_cmd   : out std_logic_vector(2 downto 0);
    trm_buf   : out std_logic_vector(15 downto 0)
    );
end TagCtrl;


architecture struct of TagCtrl is

  component TagFSM
    generic (
      WordsRSV : integer;
      WordsEPC : integer;
      WordsTID : integer;
      WordsUSR : integer;
      AddrUSR  : integer;
      Data     : integer);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      CommDone  : in  CommandInternalCode_t;
      Data_r    : in  std_logic_vector(31 downto 0);
      Pointer_r : in  std_logic_vector(15 downto 0);
      RN16_r    : in  std_logic_vector(15 downto 0);
      Length_r  : in  std_logic_vector(7 downto 0);
      Mask_r    : in  std_logic_vector(MASKLENGTH-1 downto 0);
      SInvD     : out std_logic_vector(3 downto 0);
      SelD      : out std_logic;
      SInvQ     : in  std_logic_vector(3 downto 0);
      SelQ      : in  std_logic;
      SInvCE    : out std_logic_vector(3 downto 0);
      SelCE     : out std_logic;
      rng_init  : out std_logic;
      rng_cin   : out std_logic_vector(30 downto 0);
      rng_ce    : out std_logic;
      rng_cout  : in  std_logic_vector(30 downto 0);
      mem_WR    : out std_logic;
      mem_RD    : out std_logic;
      mem_RB    : in  std_logic;
      mem_BANK  : out std_logic_vector(1 downto 0);
      mem_ADR   : out std_logic_vector((2*AddrUSR)-1 downto 0);
      mem_DTI   : out std_logic_vector(Data-1 downto 0);
      mem_DTO   : in  std_logic_vector(Data-1 downto 0);
      T2ExpFlag : in  std_logic;
      trm_cmd   : out std_logic_vector(2 downto 0);
      trm_buf   : out std_logic_vector(15 downto 0));
  end component;

  component Mem_ctrl
    generic (
      WordsRSV : integer;
      WordsEPC : integer;
      WordsTID : integer;
      WordsUSR : integer;
      AddrRSV  : integer;
      AddrEPC  : integer;
      AddrTID  : integer;
      AddrUSR  : integer;
      Data     : integer);
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      BANK  : in  std_logic_vector(1 downto 0);
      WR    : in  std_logic;
      RD    : in  std_logic;
      ADR   : in  std_logic_vector((2*AddrUSR)-1 downto 0);
      DTI   : in  std_logic_vector(Data-1 downto 0);
      DTO   : out std_logic_vector(Data-1 downto 0);
      RB    : out std_logic);
  end component;

  component prng
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      init  : in  std_logic;
      cin   : in  std_logic_vector(30 downto 0);
      ce    : in  std_logic;
      cout  : out std_logic_vector(30 downto 0));
  end component;

  component InvSelFlagCtrl
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      S0in  : in  std_logic;
      S1in  : in  std_logic;
      S2in  : in  std_logic;
      S3in  : in  std_logic;
      SLin  : in  std_logic;
      S0en  : in  std_logic;
      S1en  : in  std_logic;
      S2en  : in  std_logic;
      S3en  : in  std_logic;
      SLen  : in  std_logic;
      S0out : out std_logic;
      S1out : out std_logic;
      S2out : out std_logic;
      S3out : out std_logic;
      SLout : out std_logic);
  end component;


  signal SInvD     : std_logic_vector(3 downto 0);
  signal SelD      : std_logic;
  signal SInvQ     : std_logic_vector(3 downto 0);
  signal SelQ      : std_logic;
  signal SInvCE    : std_logic_vector(3 downto 0);
  signal SelCE     : std_logic;
  signal rng_init  : std_logic;
  signal rng_cin   : std_logic_vector(30 downto 0);
  signal rng_ce    : std_logic;
  signal rng_cout  : std_logic_vector(30 downto 0);
  signal mem_WR    : std_logic;
  signal mem_RD    : std_logic;
  signal mem_RB    : std_logic;
  signal mem_BANK  : std_logic_vector(1 downto 0);
  signal mem_ADR   : std_logic_vector((2*AddrUSR)-1 downto 0);
  signal mem_DTI   : std_logic_vector(Data-1 downto 0);
  signal mem_DTO   : std_logic_vector(Data-1 downto 0);
  signal T2ExpFlag : std_logic := '0';

  
begin  -- struct


  
  TagFSM_i : TagFSM
    generic map (
      WordsRSV => WordsRSV,
      WordsEPC => WordsEPC,
      WordsTID => WordsTID,
      WordsUSR => WordsUSR,
      AddrUSR  => AddrUSR,
      Data     => Data)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      CommDone  => CommDone,
      Data_r    => Data_r,
      Pointer_r => Pointer_r,
      RN16_r    => RN16_r,
      Length_r  => Length_r,
      Mask_r    => Mask_r,
      SInvD     => SInvD,
      SelD      => SelD,
      SInvQ     => SInvQ,
      SelQ      => SelQ,
      SInvCE    => SInvCE,
      SelCE     => SelCE,
      rng_init  => rng_init,
      rng_cin   => rng_cin,
      rng_ce    => rng_ce,
      rng_cout  => rng_cout,
      mem_WR    => mem_WR,
      mem_RD    => mem_RD,
      mem_RB    => mem_RB,
      mem_BANK  => mem_BANK,
      mem_ADR   => mem_ADR,
      mem_DTI   => mem_DTI,
      mem_DTO   => mem_DTO,
      T2ExpFlag => T2ExpFlag,
      trm_cmd   => trm_cmd,
      trm_buf   => trm_buf);


  Mem_ctrl_i : Mem_ctrl
    generic map (
      WordsRSV => WordsRSV,
      WordsEPC => WordsEPC,
      WordsTID => WordsTID,
      WordsUSR => WordsUSR,
      AddrRSV  => AddrRSV,
      AddrEPC  => AddrEPC,
      AddrTID  => AddrTID,
      AddrUSR  => AddrUSR,
      Data     => Data)
    port map (
      clk   => clk,
      rst_n => rst_n,
      BANK  => mem_BANK,
      WR    => mem_WR,
      RD    => mem_RD,
      ADR   => mem_ADR,
      DTI   => mem_DTI,
      DTO   => mem_DTO,
      RB    => mem_RB);

  prng_i : prng
    port map (
      clk   => clk,
      rst_n => rst_n,
      init  => rng_init,
      cin   => rng_cin,
      ce    => rng_ce,
      cout  => rng_cout);

  InvSelFlagCtrl_i : InvSelFlagCtrl
    port map (
      clk   => clk,
      rst_n => rst_n,
      S0in  => SInvD(0),
      S1in  => SInvD(1),
      S2in  => SInvD(2),
      S3in  => SInvD(3),
      SLin  => SelD,
      S0en  => SInvCE(0),
      S1en  => SInvCE(1),
      S2en  => SInvCE(2),
      S3en  => SInvCE(3),
      SLen  => SelCE,
      S0out => SInvQ(0),
      S1out => SInvQ(1),
      S2out => SInvQ(2),
      S3out => SInvQ(3),
      SLout => SelQ);

end struct;
