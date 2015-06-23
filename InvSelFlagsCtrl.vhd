-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag - Inventoried and Selected Flags Controller
--
--     File name      : InvSelFlagsCtrl.vhd 
--
--     Description    : Inventoried and Selected flag controller. It provides a
--                      suitable interface with the flag model and deals with
--                      refreshing procedures.
--                      
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
--                                 
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;


entity InvSelFlagCtrl is
  generic (   
    REFRESHING_CLK_CYC     : integer := 255);  -- Number of clock cycles to refresh flags
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

end InvSelFlagCtrl;


architecture FlagController1 of InvSelFlagCtrl is

  component InvSelFlag
    port (
      S1i : in  std_logic;
      S2i : in  std_logic;
      S3i : in  std_logic;
      SLi : in  std_logic;
      S1o : out std_logic;
      S2o : out std_logic;
      S3o : out std_logic;
      SLo : out std_logic);
  end component;
-- synopsys synthesis_off
  signal S0out_i, S1out_i, S2out_i, S3out_i, SLout_i : std_logic;
  signal S1i, S2i, S3i, SLi                          : std_logic;
  signal S1o, S2o, S3o, SLo                          : std_logic;
  signal RefCnt                                      : integer;
-- synopsys synthesis_on  
begin  -- FlagController1
-- synopsys synthesis_off
  -- OUTPUT WIRES
  S0out <= S0out_i;
  S1out <= S1out_i;
  S2out <= S2out_i;
  S3out <= S3out_i;
  SLout <= SLout_i;

  REGISTERS : process (clk, rst_n)
  begin  -- process REGISTERS
    if rst_n = '0' then                 -- asynchronous reset (active low)
      S0out_i <= '0';
      S1out_i <= '0';
      S2out_i <= '0';
      S3out_i <= '0';
      SLout_i <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if S0en = '1' then
        S0out_i <= S0in;
      else
        S0out_i <= S0out_i;
      end if;

      -- Flag Model Input Registers
      --S1
      if S1en = '1' then
        S1i <= S1in;
      elsif RefCnt = REFRESHING_CLK_CYC then
        S1i <= S1out_i;
      else
        S1i <= 'Z';
      end if;
      --S2
      if S2en = '1' then
        S2i <= S2in;
      elsif RefCnt = REFRESHING_CLK_CYC then
        S2i <= S2out_i;
      else
        S2i <= 'Z';
      end if;
      --S3
      if S3en = '1' then
        S3i <= S3in;
      elsif RefCnt = REFRESHING_CLK_CYC then
        S3i <= S3out_i;
      else
        S3i <= 'Z';
      end if;
      --SL
      if SLen = '1' then
        SLi <= SLin;
      elsif RefCnt = REFRESHING_CLK_CYC then
        SLi <= SLout_i;
      else
        SLi <= 'Z';
      end if;

      -- Flag Model Output Registers
      S1out_i <= S1o;
      S2out_i <= S2o;
      S3out_i <= S3o;
      SLout_i <= SLo;
    end if;
  end process REGISTERS;

  REF_COUNTER : process (clk, rst_n)
  begin  -- process REF_COUNTER
    if rst_n = '0' then                 -- asynchronous reset (active low)
      RefCnt <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if RefCnt = REFRESHING_CLK_CYC then
        RefCnt <= 0;
      else
        RefCnt <= RefCnt + 1;
      end if;
    end if;
  end process REF_COUNTER;

  InvSelFlag_i : InvSelFlag
    port map (
      S1i => S1i,
      S2i => S2i,
      S3i => S3i,
      SLi => SLi,
      S1o => S1o,
      S2o => S2o,
      S3o => S3o,
      SLo => SLo);
-- synopsys synthesis_on
end FlagController1;


