-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag - Symbol Decoder   
--
--     File name      : symbdec.vhd 
--
--     Description    : Tag symbol decoder detects valid frames decoding command 
--                      preambles and frame-syncs.    
--
--     Authors        : Erwing R. Sanchez <erwing.sanchezs@polito.it>
--                                 
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;
library work;
use work.epc_tag.all;


entity SymbolDecoder is
  generic (
    LOG2_10_TARI_CK_CYC        : integer := 9;  -- Log2(clock cycles for 10 maximum TARI value) (def:
-- Log2(490) = 9 @TCk=520ns)
    DELIMITIER_TIME_CK_CYC_MIN : integer := 22;  -- Min Clock cycles for 12,5 us delimitier
    DELIMITIER_TIME_CK_CYC_MAX : integer := 24);  -- Max Clock cycles for 12,5 us delimitier

  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;
    tdi      : in  std_logic;
    en       : in  std_logic;
    start    : in  std_logic;
    sserror  : out std_logic;
    ssovalid : out std_logic;
    sso      : out std_logic);          -- serial symbol output

end SymbolDecoder;


architecture symbdec1 of SymbolDecoder is

  component COUNTERCLR
    generic (
      width : integer);
    port (
      clk    : in  std_logic;
      rst_n  : in  std_logic;
      en     : in  std_logic;
      clear  : in  std_logic;
      outcnt : out std_logic_vector(width-1 downto 0));
  end component;

  type RecFSM_t is (st0_Start, st0b_Delimitier, st1_Dat0H, st2_Dat0L, st3_RTcalH, st4_RTcalL, st5_Sym0H, st6_Sym0L, st6b_Sym0L_TR, st7_SymH, st8_SymL, st9_SymH_TR, st10_SymL_TR);

  signal StRec, NextStRec                      : RecFSM_t;
  signal CntEn, CntClr                         : std_logic;
  signal CntEn_i, CntClr_i                     : std_logic;
  signal TRCalEn, RTCalEn                      : std_logic;
  signal TRCalEn_i, RTCalEn_i                  : std_logic;
  signal TARI4En, TARI4En_i                    : std_logic;
  signal CntReg, RTCalReg, TRCalReg            : std_logic_vector(LOG2_10_TARI_CK_CYC-1 downto 0);
  signal RTCaldiv2Reg, TARI4Reg                : std_logic_vector(LOG2_10_TARI_CK_CYC-1 downto 0);
  signal RTCal_GRTH_TRCal, Symb_GRTH_RTCaldiv2 : std_logic;
  signal Symb_GRTH_TARI4                       : std_logic;
  signal ssovalid_i, sso_i, sserror_i          : std_logic;
  signal DelimitierComparisoOK                 : std_logic;
  
begin  -- Receiver1

  RTCaldiv2Reg <= '0' & RTCalReg(LOG2_10_TARI_CK_CYC-1 downto 1);

  SYNCRO : process(clk, rst_n)
  begin  -- process
    if clk'event and clk = '1' then
      if rst_n = '0' then
        CntEn    <= '0';
        TRCalEn  <= '0';
        RTCalEn  <= '0';
        TARI4En  <= '0';
        sserror  <= '0';
        ssovalid <= '0';
        sso      <= '0';
        StRec    <= st0_start;
      else
        if en = '1' then
          StRec    <= NextStRec;
          CntEn    <= CntEn_i;
          TRCalEn  <= TRCalEn_i;
          RTCalEn  <= RTCalEn_i;
          TARI4En  <= TARI4En_i;
          CntClr   <= CntClr_i;
          sserror  <= sserror_i;
          ssovalid <= ssovalid_i;
          sso      <= sso_i;
        end if;
      end if;
    end if;
  end process;


  NEXT_ST : process (StRec, tdi, start, TRCalEn, Symb_GRTH_TARI4, DelimitierComparisoOK)
  begin  -- process NEXT_ST
    NextStRec <= StRec;
    case StRec is
      when st0_Start =>
        if tdi = '0' then
          NextStRec <= st0b_Delimitier;
        end if;
      when st0b_Delimitier =>
        if tdi = '1' then
          if DelimitierComparisoOK = '1' then
            NextStRec <= st1_Dat0H;
          else
            NextStRec <= st0_Start;
          end if;
        end if;
      when st1_Dat0H =>
        if tdi = '0' then
          NextStRec <= st2_Dat0L;
        end if;
      when st2_Dat0L =>
        if tdi = '1' then
          NextStRec <= st3_RTcalH;
        end if;
      when st3_RTcalH =>
        if tdi = '0' then
          NextStRec <= st4_RTcalL;
        end if;
      when st4_RTcalL =>
        if tdi = '1' then
          NextStRec <= st5_Sym0H;
        end if;
      when st5_Sym0H =>
        if tdi = '0' then
          NextStRec <= st6_Sym0L;
        end if;
      when st6_Sym0L =>
        if TRCalEn = '1' then
          NextStRec <= st6b_Sym0L_TR;
        elsif tdi = '1' then
          NextStRec <= st7_SymH;
        end if;
      when st6b_Sym0L_TR =>
        if tdi = '1' then
          NextStRec <= st9_SymH_TR;
        end if;
      when st9_SymH_TR =>
        if tdi = '0' then
          NextStRec <= st10_SymL_TR;
        end if;
      when st10_SymL_TR =>
        if tdi = '1' then
          NextStRec <= st7_SymH;
        end if;
      when st7_SymH =>
        if Symb_GRTH_TARI4 = '1' then
          NextStRec <= st0_Start;
        elsif start = '1'then
          NextStRec <= st0_Start;
        elsif tdi = '0' then
          NextStRec <= st8_SymL;
        end if;
      when st8_SymL =>
        if Symb_GRTH_TARI4 = '1' then
          NextStRec <= st0_Start;
        elsif start = '1' then
          NextStRec <= st0_Start;
        elsif tdi = '1' then
          NextStRec <= st7_SymH;
        end if;
      when others =>
        NextStRec <= st0_start;
    end case;
  end process NEXT_ST;


  OUTPUT_DEC : process (StRec, tdi, RTCal_GRTH_TRCal, Symb_GRTH_RTCaldiv2, Symb_GRTH_TARI4)
  begin  -- process OUTPUT_DEC
    CntEn_i    <= '0';
    TRCalEn_i  <= '0';
    RTCalEn_i  <= '0';
    TARI4En_i  <= '0';
    CntClr_i   <= '0';
    sserror_i  <= '0';
    ssovalid_i <= '0';
    sso_i      <= '0';

    case StRec is
      when st0_Start =>
        CntClr_i <= '1';
      when st0b_Delimitier =>
        if tdi = '0' then
          CntEn_i <= '1';
        else
          CntClr_i <= '1';
        end if;
      when st1_Dat0H =>
        CntEn_i <= '1';
      when st2_Dat0L =>
        if tdi = '0' then
          CntEn_i <= '1';
        else
          CntClr_i  <= '1';
          TARI4En_i <= '1';
        end if;
      when st3_RTcalH =>
        if tdi = '1' then
          CntEn_i <= '1';
        else
          -- Load RTCal value
          CntClr_i  <= '1';
          RTCalEn_i <= '1';
        end if;
      when st4_RTcalL =>
        if tdi = '1' then
          CntEn_i <= '1';
        end if;
      when st5_Sym0H =>
        if tdi = '1' then
          CntEn_i <= '1';
        else
          CntClr_i <= '1';
          if RTCal_GRTH_TRCal = '1' then
            -- Send valid Symbol
            ssovalid_i <= '1';
            if Symb_GRTH_RTCaldiv2 = '1' then
              sso_i <= '1';
            else
              sso_i <= '0';
            end if;
          else
            -- Load TRCal value (Preamble detected ("Query" comm.))
            TRCalEn_i <= '1';
          end if;
        end if;
      when st6_Sym0L =>
        if tdi = '1' then
          CntEn_i <= '1';
        end if;
      when st6b_Sym0L_TR =>
        if tdi = '1' then
          CntEn_i <= '1';
        end if;
      when st7_SymH =>
        if Symb_GRTH_TARI4 = '1' then
          sserror_i <= '1';
        elsif tdi = '1' then
          CntEn_i <= '1';
        else
          -- Send valid Symbol
          -- CntClr_i   <= '1';
          ssovalid_i <= '1';
          if Symb_GRTH_RTCaldiv2 = '1' then
            sso_i <= '1';
          else
            sso_i <= '0';
          end if;
        end if;
      when st8_SymL =>
        if Symb_GRTH_TARI4 = '1' then
          sserror_i <= '1';
        elsif tdi = '1' then
          CntClr_i <= '1';
        end if;
      when st9_SymH_TR =>
        if tdi = '1' then
          CntEn_i <= '1';
        else
          -- Send valid Symbol
          CntClr_i   <= '1';
          ssovalid_i <= '1';
          if Symb_GRTH_RTCaldiv2 = '1' then
            sso_i <= '1';
          else
            sso_i <= '0';
          end if;
        end if;
      when st10_SymL_TR =>
        if tdi = '1' then
          CntEn_i <= '1';
        end if;
      when others => null;
    end case;
  end process OUTPUT_DEC;


  GRTH1 : process (RTCalReg, CntReg)
  begin  -- process EQUAL
    if RTCalReg > CntReg then
      RTCal_GRTH_TRCal <= '1';
    else
      RTCal_GRTH_TRCal <= '0';
    end if;
  end process GRTH1;

  GRTH2 : process (CntReg, RTCaldiv2Reg)
  begin  -- process EQUAL
    if CntReg > RTCaldiv2Reg then
      Symb_GRTH_RTCaldiv2 <= '1';
    else
      Symb_GRTH_RTCaldiv2 <= '0';
    end if;
  end process GRTH2;

  GRTH3 : process (CntReg, TARI4Reg)
  begin  -- process EQUAL
    if CntReg > TARI4Reg then
      Symb_GRTH_TARI4 <= '1';
    else
      Symb_GRTH_TARI4 <= '0';
    end if;
  end process GRTH3;

  DELIMITIER_COMPARISON : process (CntReg)
  begin  -- process DELIMITIER_COMPARISON
    if conv_integer(CntReg) > DELIMITIER_TIME_CK_CYC_MIN or conv_integer(CntReg) = DELIMITIER_TIME_CK_CYC_MIN then
      if conv_integer(CntReg) < DELIMITIER_TIME_CK_CYC_MAX or conv_integer(CntReg) = DELIMITIER_TIME_CK_CYC_MAX then
        DelimitierComparisoOK <= '1';
      else
        DelimitierComparisoOK <= '0';
      end if;
    else
      DelimitierComparisoOK <= '0';
    end if;
  end process DELIMITIER_COMPARISON;

  RTCALR : process (clk, rst_n)
  begin  -- process RTCALREG
    if rst_n = '0' then                 -- asynchronous reset (active low)
      RTCalReg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if RTCalEn = '1' then
        RTCalReg <= CntReg;
      end if;
    end if;
  end process RTCALR;

  TRCALR : process (clk, rst_n)
  begin  -- process RTCALREG
    if rst_n = '0' then                 -- asynchronous reset (active low)
      TRCalReg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if TRCalEn = '1' then
        TRCalReg <= CntReg;
      end if;
    end if;
  end process TRCALR;

  TARI4R : process (clk, rst_n)
  begin  -- process TARI4R
    if rst_n = '0' then                 -- asynchronous reset (active low)
      TARI4Reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if TARI4En = '1' then
        TARI4Reg <= CntReg(LOG2_10_TARI_CK_CYC-3 downto 0) & "00";  --Multiplied by 4
      end if;
    end if;
  end process TARI4R;

  COUNTERCLR_1 : COUNTERCLR
    generic map (
      width => LOG2_10_TARI_CK_CYC)
    port map (
      clk    => clk,
      rst_n  => rst_n,
      en     => CntEn,
      clear  => CntClr,
      outcnt => CntReg);

end symbdec1;
