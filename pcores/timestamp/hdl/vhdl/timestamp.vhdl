--
-- PowerPC 405 APU FCM "timestamp"
-- record a time (counter value) of User Defined Instruction execution
--
-- Marek Peca <mp@duch.cz> 07/2008
-- KRT FEL CVUT http://dce.felk.cvut.cz/
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.RAMB16;

entity timestamp is
  port (
    reset: in std_logic;
    -- APU i/f:
    CPMFCMCLK: in std_logic;
    APUFCMFLUSH: in std_logic;
    APUFCMDECODED: in std_logic;
    APUFCMINSTRVALID: in std_logic;
    APUFCMDECUDIVALID: in std_logic;
    APUFCMDECUDI: in std_logic_vector (2 downto 0);
    APUFCMWRITEBACKOK: in std_logic;
    APUFCMRADATA: in std_logic_vector (31 downto 0);
    APUFCMRBDATA: in std_logic_vector (31 downto 0);
    FCMAPUDONE: out std_logic;
    FCMAPUSLEEPNOTREADY: out std_logic;
    -- BRAM slave i/f:
    BRAM_Rst_B: in std_logic;
    BRAM_Clk_B: in std_logic;
    BRAM_EN_B: in std_logic;
    BRAM_WEN_B: in std_logic_vector (7 downto 0);
    BRAM_Addr_B: in std_logic_vector (31 downto 0);
    BRAM_Dout_B: in std_logic_vector (63 downto 0);
    BRAM_Din_B: out std_logic_vector (63 downto 0);
    -- etc.
    debug: out std_logic_vector (3 downto 0)
  );
end timestamp;

architecture timestamp_fcm of timestamp is
  type state_type is (IDLE, WAIT_OPERAND);
  -- global
  signal clock: std_logic;
  -- FSM
  signal state, next_state: state_type;
  signal counter: std_logic_vector (31 downto 0);
  signal addr_counter: std_logic_vector (9 downto 0);
  signal save_udi_code: std_logic;
  signal udi_code: std_logic_vector (2 downto 0);
  -- BRAM
  signal wea: std_logic;
  signal dia0, dia1: std_logic_vector (31 downto 0);
  signal addra: std_logic_vector (9 downto 0);
begin
  clock <= CPMFCMCLK;
  dia0 <= counter;
  dia1 <= APUFCMRADATA;
  addra <= addr_counter;

  -- debug(0) <= addr_counter(0);
  -- debug(1) <= APUFCMDECUDIVALID;
  -- debug(2) <= APUFCMWRITEBACKOK;
  -- debug(3) <= wea;
  debug(0) <= CPMFCMCLK;
  debug(1) <= APUFCMDECODED;
  debug(2) <= APUFCMDECUDIVALID;
  debug(3) <= APUFCMWRITEBACKOK;

  seq: process
  begin
    wait until clock'event and clock = '1';
    if reset = '1' then
      state <= IDLE;
      counter <= X"00000000";
      addr_counter <= "0000000000";
    else
      if save_udi_code = '1' then
        udi_code <= APUFCMDECUDI;
      end if;
      state <= next_state;
      counter <= counter + 1;
      if wea = '1' then
        addr_counter <= addr_counter + 1;
      end if;
    end if;
  end process;

  comb_apu: process (state, udi_code,
                     APUFCMFLUSH, APUFCMINSTRVALID, APUFCMDECUDIVALID,
                     APUFCMWRITEBACKOK, APUFCMDECUDI)
  begin
    save_udi_code <= '0';
    wea <= '0';
    FCMAPUSLEEPNOTREADY <= '0';
    FCMAPUDONE <= '0';
    case state is
      when IDLE =>
        if APUFCMFLUSH = '1' then
          next_state <= IDLE;
        elsif (APUFCMINSTRVALID and APUFCMDECODED and APUFCMDECUDIVALID) = '1' then
          if APUFCMWRITEBACKOK = '1' then
            -- operands are ready
            if APUFCMDECUDI = "000" then
              wea <= '1';
              FCMAPUDONE <= '1';
            end if;
          else
            save_udi_code <= '1';
            next_state <= WAIT_OPERAND;
          end if;
        end if;
      when WAIT_OPERAND =>
        FCMAPUSLEEPNOTREADY <= '1';
        if APUFCMFLUSH = '1' then
          next_state <= IDLE;
        elsif APUFCMWRITEBACKOK = '1' then
          if udi_code = "000" then
            wea <= '1';
            FCMAPUDONE <= '1';
          end if;
        end if;
        next_state <= IDLE;
    end case;
  end process;

--   comb_action: process (action, action_udi_code)
  -- -- following block causes "gated clock" warning
  -- -- after FCMAPUDONE removal, everything seems to be OK
  -- -- what is strange: the same construct above at FCMAPUSLEEPNOTREADY
  -- -- causes no warning
--   begin
--     wea <= '0';
--     FCMAPUDONE <= '0';
--     if (action = '1') and (action_udi_code = "111") then
--       wea <= '1';
--       FCMAPUDONE <= '1';
--     end if;
--   end process;

  bram0: RAMB16
    generic map (
      INVERT_CLK_DOA_REG => false,
      INVERT_CLK_DOB_REG => false,
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      READ_WIDTH_A => 36,
      READ_WIDTH_B => 36,
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 36,
      WRITE_WIDTH_B => 36
    )
    port map (
      DOA => open,
      DOB => BRAM_Din_B(31 downto 0),
      ADDRA(14 downto 5) => addra,
      ADDRA(4 downto 0) => "00000",
      ADDRB(14 downto 2) => BRAM_Addr_B(12 downto 0),
      ADDRB(1 downto 0) => "00",
      CASCADEINA => '0', CASCADEINB => '0',
      CLKA => clock,
      CLKB => BRAM_Clk_B,
      DIA => dia0,
      DIB => BRAM_Dout_B(31 downto 0),
      DIPA => "0000", DIPB => "0000",
      ENA => '1',
      ENB => BRAM_EN_B,
      REGCEA => '1', REGCEB => '1',
      SSRA => '0',
      SSRB => BRAM_Rst_B,
      WEA(0) => wea, WEA(1) => wea, WEA(2) => wea, WEA(3) => wea,
      WEB => BRAM_WEN_B(3 downto 0)
    );
  bram1: RAMB16
    generic map (
      INVERT_CLK_DOA_REG => false,
      INVERT_CLK_DOB_REG => false,
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      READ_WIDTH_A => 36,
      READ_WIDTH_B => 36,
      WRITE_MODE_A => "WRITE_FIRST",
      WRITE_MODE_B => "WRITE_FIRST",
      WRITE_WIDTH_A => 36,
      WRITE_WIDTH_B => 36
    )
    port map (
      DOA => open,
      DOB => BRAM_Din_B(63 downto 32),
      ADDRA(14 downto 5) => addra,
      ADDRA(4 downto 0) => "00000",
      ADDRB(14 downto 2) => BRAM_Addr_B(12 downto 0),
      ADDRB(1 downto 0) => "00",
      CASCADEINA => '0', CASCADEINB => '0',
      CLKA => clock,
      CLKB => BRAM_Clk_B,
      DIA => dia1,
      DIB => BRAM_Dout_B(63 downto 32),
      DIPA => "0000", DIPB => "0000",
      ENA => '1',
      ENB => BRAM_EN_B,
      REGCEA => '1', REGCEB => '1',
      SSRA => '0',
      SSRB => BRAM_Rst_B,
      WEA(0) => wea, WEA(1) => wea, WEA(2) => wea, WEA(3) => wea,
      WEB => BRAM_WEN_B(7 downto 4)
    );
end timestamp_fcm;

-- EOF
