-----------------------------------------------------------------
--                                                             --
-----------------------------------------------------------------
--                                                             --
-- Copyright (C) 2013 Stefano Tonello                          --
--                                                             --
-- This source file may be used and distributed without        --
-- restriction provided that this copyright statement is not   --
-- removed from the file and that any derivative work contains --
-- the original copyright notice and the associated disclaimer.--
--                                                             --
-- THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY         --
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   --
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   --
-- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      --
-- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         --
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    --
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   --
-- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        --
-- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  --
-- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  --
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  --
-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         --
-- POSSIBILITY OF SUCH DAMAGE.                                 --
--                                                             --
-----------------------------------------------------------------

---------------------------------------------------------------
-- G.729a codec (Single Data Port)
---------------------------------------------------------------

---------------------------------------------------------------
-- Notes:
-- SDP version uses a single data port (DI_i/DO_o) to transfer
-- coder input/output data, decoder input/output data and
-- ASIP state data, and it therefore more suitable for systems
-- with a single main bus, possibly connected to an external
-- DRAM memory.
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

library work;
use work.G729A_ASIP_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;
use WORK.G729A_ASIP_ARITH_PKG.all;
use WORK.G729A_ASIP_OP_PKG.all;
use WORK.G729A_ASIP_CFG_PKG.all;
use work.G729A_CODEC_INTF_PKG.all;

entity G729A_CODEC_SDP is
  generic(
    -- synthesis translate_off
    ST_FILE : string; 
    WB_FILE : string;
    -- synthesis translate_on
    REGISTER_INPUTS : std_logic := '0';
    REGISTER_OUTPUTS : std_logic := '0';
    USE_ROM_MIF : std_logic := '0';
    SIMULATION_ONLY : std_logic := '1'
  );
  port(
    CLK_i : in std_logic; -- clock
    RST_i : in std_logic; -- reset
    STRT_i : in std_logic; -- start
    OPS_i : in std_logic_vector(3-1 downto 0);
    RE_i : in std_logic; -- state read-enable
    WE_i : in std_logic; -- state write-enable
    DI_i : in std_logic_vector(SDLEN-1 downto 0); -- data-in

    BSY_o : out std_logic; -- busy
    DMAE_o : out std_logic; -- DMA enable
    STS_o : out std_logic_vector(3-1 downto 0); -- status
    DV_o : out std_logic; -- data-out valid
    DO_o : out std_logic_vector(SDLEN-1 downto 0) -- data-out
  );
end G729A_CODEC_SDP;

architecture ARC of G729A_CODEC_SDP is

  -- I/O transfer sub-programs starting address
  constant DATA_IN : natural := 7645;
  constant COD_DATA_OUT : natural := 8663;
  constant DEC_DATA_IN : natural := 8695;
  constant DEC_DATA_OUT : natural := 8679;
  constant STATE_IN : natural := 8719;
  constant STATE_OUT : natural := 8743;

  component G729A_ASIP_TOP_2W is
    generic(
      -- synthesis translate_off
      ST_FILE : string := "NONE";
      WB_FILE : string := "NONE";
      -- synthesis translate_on
      USE_ROM_MIF : std_logic := '0';
      SIMULATION_ONLY : std_logic := '1'
    );
    port(
      CLK_i : in std_logic; -- clock
      RST_i : in std_logic; -- reset
      STRT_i : in std_logic; -- start
      SADR_i : in std_logic_vector(ALEN-1 downto 0);
      SRST_i : in std_logic; -- soft_reset
      DIWE_i : in std_logic; -- data-in write-enable
      DI_i : in std_logic_vector(SDLEN-1 downto 0); -- data-in
      DORE_i : in std_logic; -- data-out read-enable
      CHK_ENB_i : in std_logic; -- check-enable
      XDMAE_i : in std_logic; -- DMA enable
      XWE_i : in std_logic; -- DMA write-enable
      XADR_i : in std_logic_vector(ALEN-1 downto 0);
      XDI_i : in std_logic_vector(SDLEN-1 downto 0); -- DMA data-in

      BSY_o : out std_logic; -- busy
      DIV_o : out std_logic; --
      DOV_o : out std_logic; --
      DO_o : out std_logic_vector(SDLEN-1 downto 0); -- data-out
      XDO_o : out std_logic_vector(SDLEN-1 downto 0) -- DMA data-out
    );
  end component;

  component G729A_ASIP_SPC is
    generic(
      SIMULATION_ONLY : std_logic := '1'
    );
    port(
      CLK_i : in std_logic;
      RST_i : in std_logic;
      STRT_i : in std_logic;
      OPS_i : in std_logic_vector(3-1 downto 0);
      A_BSY_i : in std_logic;
      D_BSY_i : in std_logic;

      SADR_o : out unsigned(ALEN-1 downto 0);
      A_STRT_o : out std_logic;
      A_DMAE_o : out std_logic;
      A_ADR_o : out unsigned(ALEN-1 downto 0);
      D_STRT_o : out std_logic;
      D_WE_o : out std_logic;
      ASEL_o : out std_logic_vector(3-1 downto 0);
      BLEN_o : out natural range 0 to 2048-1;
      BSY_o : out std_logic;
      STS_o : out std_logic_vector(3-1 downto 0);
      CHKE_o : out std_logic
    );
  end component;

  signal STRT_q : std_logic;
  signal OPS_q : std_logic_vector(3-1 downto 0);
  signal RE_q : std_logic;
  signal WE_q : std_logic;
  signal DI_q : std_logic_vector(SDLEN-1 downto 0);
  signal DO_q : std_logic_vector(SDLEN-1 downto 0);
  signal DV_q,DV_Q2 : std_logic;

  signal SRST : std_logic := '0';
  signal STRT : std_logic;
  signal SADR : unsigned(ALEN-1 downto 0);
  signal IO_DDATI : std_logic_vector(SDLEN-1 downto 0);
  signal ASIP_BSY : std_logic;
  signal IO_DIWE : std_logic;
  signal IO_DORE : std_logic;
  signal DADR_L,DADR_S : unsigned(ALEN-1 downto 0);
  signal IO_DDATO : std_logic_vector(SDLEN-1 downto 0);
  signal ASIP_DIV,ASIP_DOV : std_logic;

  signal SPC_D_WE : std_logic;
  signal SPC_CHKE : std_logic;
  signal SPC_BSY : std_logic;
  signal SPC_A_DMAE : std_logic;
  signal SPC_D_STRT : std_logic;
  signal SPC_A_STRT : std_logic;
  signal SPC_A_ADR : unsigned(ALEN-1 downto 0);
  signal SPC_BLEN : natural range 0 to 2048-1;
  signal SPC_SADR : unsigned(ALEN-1 downto 0);
  signal SPC_ASEL : std_logic_vector(3-1 downto 0);

  signal DMA_ENB : std_logic;
  signal DMA_BSY : std_logic;
  signal DMA_WE : std_logic;
  signal DMA_ADR : std_logic_vector(ALEN-1 downto 0);
  signal DMA_ADR_q,DMA_ADR_q2 : unsigned(ALEN-1 downto 0);
  signal DMA_DI,DMA_DI_q : std_logic_vector(SDLEN-1 downto 0);
  signal DMA_DO,DMA_DO_q : std_logic_vector(SDLEN-1 downto 0);
  signal DMA_CNT_q : unsigned(ALEN-1 downto 0);
  signal DMA_DEC : std_logic;

  signal ERROR_q : std_logic := '0';
  signal CHK : integer;
  signal VALID_OPS : std_logic;

begin

  ---------------------------------------------------
  -- I/O Interface signals (unused)
  ---------------------------------------------------

  IO_DIWE <= '0';
  IO_DDATI <= (others => '0');
  IO_DORE <= '0';

  ---------------------------------------------------
  -- Input signal registers
  ---------------------------------------------------

  -- Warning: registering RE_i adds an extra delay
  -- cycles between RE_i assertion and data output.

  G0_T : if (REGISTER_INPUTS = '1') generate

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        STRT_q <= '0';
        RE_q <= '0';
        WE_q <= '0';
      else
        STRT_q <= STRT_i;
        RE_q <= RE_i;
        WE_q <= WE_i;
      end if;
      OPS_q <= OPS_i;
      DI_q <= DI_i;
    end if;
  end process;

  end generate;

  G0_F : if (REGISTER_INPUTS = '0') generate

    STRT_q <= STRT_i;
    RE_q <= RE_i;
    WE_q <= WE_i;
    OPS_q <= OPS_i;
    DI_q <= DI_i;

  end generate;

  ---------------------------------------------------
  -- Output signal registers
  ---------------------------------------------------

  -- Note: only data-out signal DO_o needs to be
  -- explicitly registred, other output signals are
  -- already driven by registers.

  -- Warning: registering DO_o adds an extra delay
  -- cycles between RE_i assertion and data output.

  G1_T : if (REGISTER_OUTPUTS = '1') generate

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      DO_q <= DMA_DO;
    end if;
  end process;

  end generate;

  G1_F : if (REGISTER_OUTPUTS = '0') generate

    DO_q <= DMA_DO;

  end generate;

  ---------------------------------------------------
  -- Data(-out) valid flag
  ---------------------------------------------------

  -- this flag get asserted when valid data are available
  -- on DO_o in response to an assertion of RE_i.

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        DV_q <= '0';
      else
        DV_q <= (DMA_ENB and not(SPC_D_WE) and RE_q);
      end if;
    end if;
  end process;

  G2_T : if (REGISTER_OUTPUTS = '1') generate

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        DV_q2 <= '0';
      else
        DV_q2 <= DV_q;
      end if;
    end if;
  end process;

  end generate;

  ---------------------------------------------------
  -- DMA logic
  ---------------------------------------------------

  DMA_ENB <= SPC_A_DMAE;

  DMA_WE <= (SPC_D_WE and WE_q);

  DMA_DI <= DI_q;

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        DMA_CNT_q <= to_unsigned(0,ALEN);
      elsif(RST_i = '1' or SPC_D_STRT = '1') then
        DMA_CNT_q <= to_unsigned(SPC_BLEN - 1,ALEN);
      elsif(DMA_CNT_q > 0 and DMA_DEC = '1') then
        DMA_CNT_q <= DMA_CNT_q - 1;
      end if;
    end if;
  end process;

  DMA_DEC <= (SPC_D_WE and WE_q) or (not(SPC_D_WE) and RE_q);

  DMA_BSY <= '1' when DMA_CNT_q > 0 else '0';

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        DMA_ADR_q <= to_unsigned(0,ALEN);
      elsif(RST_i = '1' or SPC_D_STRT = '1') then
        DMA_ADR_q <= SPC_A_ADR;
      elsif(DMA_CNT_q > 0 and DMA_DEC = '1') then
        DMA_ADR_q <= DMA_ADR_q + 1;
      end if;
    end if;
  end process;

  DMA_ADR <= to_std_logic_vector(DMA_ADR_q);

  ---------------------------------------------------
  -- ASIP Core Top module
  ---------------------------------------------------

  U_ASIP : G729A_ASIP_TOP_2W
    generic map(
      -- synthesis translate_off
      ST_FILE => ST_FILE,
      WB_FILE => WB_FILE,
      -- synthesis translate_on
      USE_ROM_MIF => USE_ROM_MIF,
      SIMULATION_ONLY => SIMULATION_ONLY
    )
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i, 
      STRT_i => SPC_A_STRT, 
      SADR_i => to_std_logic_vector(SPC_SADR), 
      SRST_i => SRST, -- inactive!
      DIWE_i => IO_DIWE,
      DI_i => IO_DDATI,
      DORE_i => IO_DORE,
      CHK_ENB_i => SPC_CHKE,
      XDMAE_i => DMA_ENB,
      XWE_i => DMA_WE,
      XADR_i => DMA_ADR,
      XDI_i => DMA_DI,

      BSY_o => ASIP_BSY,
      DIV_o => open, --ASIP_DIV, -- not used
      DOV_o => open, --ASIP_DOV, -- not used
      DO_o => open, --IO_DDATO,
      XDO_o => DMA_DO
    );

  ---------------------------------------------------
  -- ASIP Sub-program Controller
  ---------------------------------------------------

  U_SPC : G729A_ASIP_SPC
    generic map(
      SIMULATION_ONLY => SIMULATION_ONLY
    )
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i, 
      STRT_i => STRT_q,
      OPS_i => OPS_q,
      A_BSY_i => ASIP_BSY,
      D_BSY_i => DMA_BSY,

      SADR_o => SPC_SADR,
      A_STRT_o => SPC_A_STRT, -- ASIP start
      A_DMAE_o => SPC_A_DMAE, -- ASIP DMA enable
      A_ADR_o => SPC_A_ADR, -- ASIP DMA adr.
      D_STRT_o => SPC_D_STRT, -- DMA start
      D_WE_o => SPC_D_WE, -- DMA write-enable
      ASEL_o => open, --SPC_ASEL, -- unused
      BLEN_o => SPC_BLEN, -- DMA burst len.
      BSY_o => SPC_BSY,
      STS_o => STS_o,
      CHKE_o => SPC_CHKE
    );

  ---------------------------------------------------
  -- Outputs
  ---------------------------------------------------

  DMAE_o <= DMA_ENB;
  BSY_o <= SPC_BSY;

  G3_T : if (REGISTER_OUTPUTS = '1') generate
  DV_o <= DV_q2;
  end generate;

  G3_F : if (REGISTER_OUTPUTS = '0') generate
  DV_o <= DV_q;
  end generate;

  DO_o <= DO_q;

  ---------------------------------------------------
  -- Checkers
  ---------------------------------------------------

  -- synthesis translate_off

  -- Check that STRT_i signal is either '0' or '1' on clock
  -- rising edge (ignore reset).

  assert not(not(STRT_i = '0' or STRT_i = '1') and RST_i = '0'
    and CLK_i = '1' and CLK_i'event) 
  report "STRT_i is not '0' or '1' on clock rising edge!"
  severity ERROR;

  -- Check that OPS_i has a valid value when STRT_i is asserted
  -- on a clock rising edge (ignore reset).

  VALID_OPS <= '1' when (
    OPS_i = INIT or
    OPS_i = SAVS or
    OPS_i = RSTS or
    OPS_i = RUNF or
    OPS_i = RUNC or
    OPS_i = RUND
  ) else '0';

  assert not(VALID_OPS = '0' and STRT_i = '1' and RST_i = '0' and
    CLK_i = '1' and CLK_i'event) 
  report "invalid OPS_i value when STRT_i asserted!"
  severity ERROR;

  -- Check that RE_i is asserted only in DMA mode (ignore reset).

  assert not(DMA_ENB = '0' and RE_i = '1' and RST_i = '0' and
    CLK_i = '1' and CLK_i'event) 
  report "RE_i asserted not in DMA mode!"
  severity ERROR;

  -- Check that RE_i is asserted only in DMA read mode (ignore reset).

  assert not(DMA_ENB = '1' and SPC_D_WE = '1' and RE_i = '1' and RST_i = '0' and
    CLK_i = '1' and CLK_i'event) 
  report "RE_i asserted in DMA write mode!"
  severity ERROR;

  -- Check that WE_i is asserted only in DMA mode (ignore reset).

  assert not(DMA_ENB = '0' and WE_i = '1' and RST_i = '0' and
    CLK_i = '1' and CLK_i'event) 
  report "WE_i asserted not in DMA mode!"
  severity ERROR;

  -- Check that WE_i is asserted only in DMA write mode (ignore reset).

  assert not(DMA_ENB = '1' and SPC_D_WE = '0' and WE_i = '1' and RST_i = '0' and
    CLK_i = '1' and CLK_i'event) 
  report "WE_i asserted in DMA read mode!"
  severity ERROR;

  -- synthesis translate_on

end ARC;
