-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica       
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     File name      : tag.vhd 
--
--     Description    : top level of the whole architecture
--
--     Author         : Erwing R. Sanchez Sanchez <erwing.sanchez@polito.it>
--            
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library WORK;
use WORK.epc_tag.all;


entity EPCTAG is
  generic (
    LOG2_10_TARI_CK_CYC        : integer := 9;  -- Log2(clock cycles for 10 maximum TARI value) (def: Log2(490) = 9 @TCk=520ns)
    DELIMITIER_TIME_CK_CYC_MIN : integer := 22;  -- Min Clock cycles for 12,5 us delimitier
    DELIMITIER_TIME_CK_CYC_MAX : integer := 24;  -- Max Clock cycles for 12,5 us delimitier
    WordsRSV                   : integer := 8;
    WordsEPC                   : integer := 16;
    WordsTID                   : integer := 8;
    WordsUSR                   : integer := 256;
    AddrRSV                    : integer := 2;  -- 1/2 memory address pins
    AddrEPC                    : integer := 3;  -- 1/2 memory address pins
    AddrTID                    : integer := 2;  -- 1/2 memory address pins  
    AddrUSR                    : integer := 5;  -- 1/2 memory address pins (maximum)
    Data                       : integer := 16);  -- memory data width
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    tdi       : in  std_logic;
    tdo       : out std_logic;
    Data_r    : out std_logic_vector(31 downto 0);
    CRC_r     : out std_logic_vector(15 downto 0);
    Pointer_r : out std_logic_vector(15 downto 0);
    RN16_r    : out std_logic_vector(15 downto 0);
    Length_r  : out std_logic_vector(7 downto 0);
    Mask_r    : out std_logic_vector(MASKLENGTH-1 downto 0);
    trm_cmd   : out std_logic_vector(2 downto 0);
    trm_buf   : out std_logic_vector(15 downto 0));
end EPCTAG;

architecture STRUCTURAL of EPCTAG is

  component receiver
    generic (
      LOG2_10_TARI_CK_CYC        : integer;
      DELIMITIER_TIME_CK_CYC_MIN : integer;
      DELIMITIER_TIME_CK_CYC_MAX : integer);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      tdi       : in  std_logic;
      en        : in  std_logic;
      CommDone  : out CommandInternalCode_t;
      Data_r    : out std_logic_vector(31 downto 0);
      CRC_r     : out std_logic_vector(15 downto 0);
      Pointer_r : out std_logic_vector(15 downto 0);
      RN16_r    : out std_logic_vector(15 downto 0);
      Length_r  : out std_logic_vector(7 downto 0);
      Mask_r    : out std_logic_vector(MASKLENGTH-1 downto 0));
  end component;

  component TagCtrl
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
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      CommDone  : in  CommandInternalCode_t;
      Data_r    : in  std_logic_vector(31 downto 0);
      Pointer_r : in  std_logic_vector(15 downto 0);
      RN16_r    : in  std_logic_vector(15 downto 0);
      Length_r  : in  std_logic_vector(7 downto 0);
      Mask_r    : in  std_logic_vector(MASKLENGTH-1 downto 0);
      trm_cmd   : out std_logic_vector(2 downto 0);
      trm_buf   : out std_logic_vector(15 downto 0));
  end component;



  component transmitter
    port (
      clk     : in  std_logic;
      rst_n   : in  std_logic;
      trm_cmd : in  std_logic_vector(2 downto 0);
      trm_buf : in  std_logic_vector(15 downto 0);
      tdo     : out std_logic);
  end component;


  signal Data_ri    : std_logic_vector(31 downto 0);
  signal CRC_ri     : std_logic_vector(15 downto 0);
  signal Pointer_ri : std_logic_vector(15 downto 0);
  signal RN16_ri    : std_logic_vector(15 downto 0);
  signal Length_ri  : std_logic_vector(7 downto 0);
  signal Mask_ri    : std_logic_vector(MASKLENGTH-1 downto 0);

  signal rec_en    : std_logic;
  signal CommDone  : CommandInternalCode_t;
  signal trm_cmd_i : std_logic_vector(2 downto 0);
  signal trm_buf_i : std_logic_vector(15 downto 0);
  
begin

-- Enabling signals 
  rec_en <= '1';
-- Output signals
   Data_r    <= Data_ri;
  CRC_r     <= CRC_ri;
  Pointer_r <= Pointer_ri;
  RN16_r    <= RN16_ri;
  Length_r  <= Length_ri;
  Mask_r    <= Mask_ri;
  trm_cmd   <= trm_cmd_i;
  trm_buf   <= trm_buf_i;


  receiver_i : receiver
    generic map (
      LOG2_10_TARI_CK_CYC        => LOG2_10_TARI_CK_CYC,
      DELIMITIER_TIME_CK_CYC_MIN => DELIMITIER_TIME_CK_CYC_MIN,
      DELIMITIER_TIME_CK_CYC_MAX => DELIMITIER_TIME_CK_CYC_MAX)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      tdi       => tdi,
      en        => rec_en,
      CommDone  => CommDone,
      Data_r    => Data_ri,
      CRC_r     => CRC_ri,
      Pointer_r => Pointer_ri,
      RN16_r    => RN16_ri,
      Length_r  => Length_ri,
      Mask_r    => Mask_ri);

  TagCtrl_i : TagCtrl
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
      clk       => clk,
      rst_n     => rst_n,
      CommDone  => CommDone,
      Data_r    => Data_ri,
      Pointer_r => Pointer_ri,
      RN16_r    => RN16_ri,
      Length_r  => Length_ri,
      Mask_r    => Mask_ri,
      trm_cmd   => trm_cmd_i,
      trm_buf   => trm_buf_i);

  transmitter_i: transmitter
    port map (
      clk     => clk,
      rst_n   => rst_n,
      trm_cmd => trm_cmd_i,
      trm_buf => trm_buf_i,
      tdo     => tdo);

end STRUCTURAL;




