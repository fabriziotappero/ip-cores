-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag - Receiver    
--
--     File name      : receiver.vhd 
--
--     Description    : Tag receiver detects valid frames decoding command 
--                      preambles and frame-syncs.    
--
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
s--                                 
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;
library work;
use work.epc_tag.all;


entity receiver is
  generic (
    LOG2_10_TARI_CK_CYC        : integer := 9;  -- Log2(clock cycles for 10 maximum TARI value) (def:Log2(490) = 9 @TCk=520ns)
    DELIMITIER_TIME_CK_CYC_MIN : integer := 22;  -- Min Clock cycles for 12,5 us delimitier
    DELIMITIER_TIME_CK_CYC_MAX : integer := 24);  -- Max Clock cycles for 12,5 us delimitier
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


end receiver;


architecture Receiver1 of receiver is

  component CommandDecoder
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


begin

  CommandDecoder_i : CommandDecoder
    generic map (
      LOG2_10_TARI_CK_CYC        => LOG2_10_TARI_CK_CYC,
      DELIMITIER_TIME_CK_CYC_MIN => DELIMITIER_TIME_CK_CYC_MIN,
      DELIMITIER_TIME_CK_CYC_MAX => DELIMITIER_TIME_CK_CYC_MAX)
    port map (
      clk       => clk,
      rst_n     => rst_n,
      tdi       => tdi,
      en        => en,
      CommDone  => CommDone,
      Data_r    => Data_r,
      CRC_r     => CRC_r,
      Pointer_r => Pointer_r,
      RN16_r    => RN16_r,
      Length_r  => Length_r,
      Mask_r    => Mask_r);


end Receiver1;


