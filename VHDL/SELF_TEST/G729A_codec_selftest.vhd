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
-- G.729a Codec self-test module
---------------------------------------------------------------

---------------------------------------------------------------
-- Notes:
-- This module performs codec self-test (decoding+encoding on
-- a fixed set of data packets, comparing expected outputs with
-- actual ones). Self-test results are flagged by DONE and PASS
-- output signals (DONE = '1' => test is complete, PASS = '1'
-- => no error has been detected).
-- This module only needs clock and reset inputs: all input 
-- data are stored in ROM.
-- This module is synthesizable.
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

library work;
use work.G729A_ASIP_PKG.all;
use work.G729A_ASIP_CFG_PKG.all;
use work.G729A_CODEC_INTF_PKG.all;

entity G729A_CODEC_SELFTEST is
  port(
    CLK_i : in std_logic; -- clock
    RST_i : in std_logic; -- reset

    DONE_o : out std_logic; -- test complete
    PASS_o : out std_logic -- test pass
  );
end G729A_CODEC_SELFTEST;

architecture ARC of G729A_CODEC_SELFTEST is

  -- number of packets to encode/decode (do not modify!)
  constant MAX_CNT : natural := 5;

  -- use ROM models with MIF file.
  constant USE_ROM_MIF : std_logic := '0';

  -- Input/Output data ROM word count
  constant ST_MEM_SIZE : natural := MAX_CNT * (ENCODED_LEN + DECODED_LEN);

  -- Control FSM state type
  type XS_T is (
    XS_IDLE,
    XS_INIT,
    XS_RUN,
    XS_STOP
  );

  -- Write FSM state type
  type WS_T is (
    WS_IDLE,
    WS_WRITE,
    WS_WAIT
  );

  -- Read FSM state type
  type RS_T is (
    RS_IDLE,
    RS_READ,
    RS_WAIT
  );

  component G729A_CODEC_SDP is
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
      RE_i : in std_logic; -- read-enable
      WE_i : in std_logic; -- write-enable
      DI_i : in std_logic_vector(SDLEN-1 downto 0); -- DMA data-in

      BSY_o : out std_logic; -- busy
      DMAE_o : out std_logic; -- DMA enable
      STS_o : out std_logic_vector(3-1 downto 0);
      DV_o : out std_logic; -- data-out valid
      DO_o : out std_logic_vector(SDLEN-1 downto 0) -- DMA data-out
    );
  end component;

  component G729A_ASIP_ROM_MIF is
    generic(
      WCOUNT : natural := 256;
      DATA_WIDTH : natural := 8;
      ADDR_WIDTH : natural := 8;
      ROM_INIT_FILE : string := "NONE"
    );
    port(
      CLK_i : in std_logic;
      A_i : in unsigned(ADDR_WIDTH-1 downto 0);

      Q_o : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

  component G729A_ASIP_STI_ROM is
    generic(
      WCOUNT : natural := 425;
      DATA_WIDTH : natural := 16;
      ADDR_WIDTH : natural := 9
    );
    port(
      CLK_i : in std_logic;
      A_i : in unsigned(ADDR_WIDTH-1 downto 0);

      Q_o : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

  component G729A_ASIP_STO_ROM is
    generic(
      WCOUNT : natural := 425;
      DATA_WIDTH : natural := 16;
      ADDR_WIDTH : natural := 9
    );
    port(
      CLK_i : in std_logic;
      A_i : in unsigned(ADDR_WIDTH-1 downto 0);

      Q_o : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

  signal XS,XS_q : XS_T;
  signal STRT : std_logic;
  signal OPS : std_logic_vector(3-1 downto 0);
  signal RE : std_logic;
  signal WE : std_logic;
  signal SRST : std_logic := '0'; -- inactive!
  signal CDC_BSY : std_logic;
  signal CDC_DV : std_logic;
  signal CDC_DO : std_logic_vector(SDLEN-1 downto 0); 
  signal CDC_STS : std_logic_vector(3-1 downto 0);
  signal PKT_CNT_q : natural range 0 to MAX_CNT;
  signal DONE,DONE_q : std_logic;
  signal PASS,PASS_q : std_logic;
  signal WS,WS_q : WS_T;
  signal RS,RS_q : RS_T;
  signal WRITE_OP : std_logic;
  signal READ_OP : std_logic;
  signal WRITEF,WRITEF_q,WRITEF_q2 : std_logic;
  signal READF,READF_q : std_logic;
  signal CNT_q : natural range 0 to DECODED_LEN-1;
  signal CNT_INIT : natural range 0 to DECODED_LEN-1;
  signal CNT_RST_R,CNT_RST_W : std_logic;
  signal ERR : std_logic;
  signal ERR_CNT_q : natural range 0 to ST_MEM_SIZE-1;
  signal STI_RE : std_logic;
  signal STI_ADR : unsigned(log2(ST_MEM_SIZE)-1 downto 0);
  signal STI_DO : std_logic_vector(SDLEN-1 downto 0); 
  signal STI_CNT_q : natural range 0 to ST_MEM_SIZE-1;
  signal STO_RE : std_logic;
  signal STO_ADR : unsigned(log2(ST_MEM_SIZE)-1 downto 0);
  signal STO_DO : std_logic_vector(SDLEN-1 downto 0); 
  signal STO_CNT_q : natural range 0 to ST_MEM_SIZE-1;

begin

  ---------------------------------------------------
  -- Test control FSM
  ---------------------------------------------------

  -- This FSM performs codec initialization and then
  -- run decoding+encoding on MAX_CNT data packets.

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        DONE_q <= '0';
        XS_q <= XS_IDLE;
      else
        DONE_q <= DONE;
        XS_q <= XS;
      end if;
    end if;
  end process;

  process(XS_q,CDC_BSY,PKT_CNT_q)
  begin
    STRT <= '0';
    OPS <= NOP;
    DONE <= '0';
    case XS_q is

	 -- do nothing while reset is on
      when XS_IDLE =>
        STRT <= '1'; -- assert codec start
        OPS <= INIT; -- select codec operation
        XS <= XS_INIT;

	 -- initialize codec
      when XS_INIT =>
        if(CDC_BSY = '0') then
          STRT <= '1'; -- assert codec start
          OPS <= RUNF; -- select codec operation
          XS <= XS_RUN;
        else
          XS <= XS_INIT;
        end if;

	 -- run decoding+encoding
      when XS_RUN =>
        if(CDC_BSY = '0') then
          if(PKT_CNT_q > 0) then
            STRT <= '1'; -- assert codec start
            OPS <= RUNF; -- select codec operation
            XS <= XS_RUN;
          else
            XS <= XS_STOP;
          end if;
        else
          XS <= XS_RUN;
        end if;

      -- forever stop...
      when XS_STOP =>
        DONE <= '1';
        XS <= XS_STOP;

      when others =>
        XS <= XS_IDLE;

    end case;
  end process;

  ---------------------------------------------------
  -- decoded/encoded data packet (down-) counter
  ---------------------------------------------------

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        PKT_CNT_q <= MAX_CNT;
      elsif(STRT = '1' and OPS = RUNF and PKT_CNT_q > 0) then
        PKT_CNT_q <= PKT_CNT_q - 1;
      end if;
    end if;
  end process;

  ---------------------------------------------------
  -- Input data ROM address generator
  ---------------------------------------------------

  STI_RE <= WRITEF_q;

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        STI_CNT_q <= 0;
      elsif(STI_RE = '1' and STI_CNT_q < ST_MEM_SIZE-1) then
        STI_CNT_q <= STI_CNT_q + 1;
      end if;
    end if;
  end process;

  STI_ADR <= to_unsigned(STI_CNT_q,log2(ST_MEM_SIZE));

  ---------------------------------------------------
  -- Output data ROM address generator
  ---------------------------------------------------

  STO_RE <= READF_q;

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        STO_CNT_q <= 0;
      elsif(STO_RE = '1' and STO_CNT_q < ST_MEM_SIZE-1) then
        STO_CNT_q <= STO_CNT_q + 1;
      end if;
    end if;
  end process;

  STO_ADR <= to_unsigned(STO_CNT_q,log2(ST_MEM_SIZE));

  ---------------------------------------------------
  -- Compare output data to expected data
  -- (error counter)
  ---------------------------------------------------

  -- error flag
  ERR <= '1' when (CDC_DV = '1') and not(STO_DO = CDC_DO) else '0'; 

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        ERR_CNT_q <= 0;
      elsif(ERR = '1') then
        ERR_CNT_q <= ERR_CNT_q + 1;
      end if;
    end if;
  end process;

  PASS <= '1' when (ERR_CNT_q = 0) else '0';

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        PASS_q <= '0';
      elsif(DONE = '1') then
        PASS_q <= PASS;
      end if;
    end if;
  end process;

  ---------------------------------------------------
  -- Write FSM
  ---------------------------------------------------

  -- This FSM monitors codec status output to detect
  -- when a write (to codec memory) operation is
  -- needed.

  -- write (to codec) operation-in-progress flag
  WRITE_OP <= '1' when (
     CDC_STS = STS_COD_DIN or -- data to be encoded 
     CDC_STS = STS_DEC_DIN -- data to be decoded
    ) else '0';

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        WRITEF_q <= '0';
        WS_q <= WS_IDLE;
      else
        WRITEF_q <= WRITEF;
        WS_q <= WS;
      end if;
    end if;
  end process;

  process(WS_q,WRITE_OP,CNT_q)
  begin
    WRITEF <= '0';
    CNT_RST_W <= '0';
    case WS_q is
      when WS_IDLE =>
        if(WRITE_OP = '1') then
          CNT_RST_W <= '1'; -- reset counter
          WS <= WS_WRITE;
        else
          WS <= WS_IDLE;
        end if;
      when WS_WRITE =>
        WRITEF <= '1';
        if(CNT_q = 0) then
          WS <= WS_WAIT;
        else
          WS <= WS_WRITE;
        end if;
      when WS_WAIT =>
        if(WRITE_OP = '0') then
          WS <= WS_IDLE;
        else
          WS <= WS_WAIT;
        end if;
      when others =>
        WS <= WS_IDLE;
    end case;
  end process;

  -- delay write flag by 1 cycle.
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        WRITEF_q2 <= '0';
      else
        WRITEF_q2 <= WRITEF_q;
      end if;
    end if;
  end process;

  WE <= WRITEF_q2;

  ---------------------------------------------------
  -- Read FSM
  ---------------------------------------------------

  -- This FSM monitors codec status output to detect
  -- when a read (from codec memory) operation is
  -- needed.

  -- read (from codec) operation-in-progress flag
  READ_OP <= '1' when (
    CDC_STS = STS_COD_DOUT or -- encoded data
    CDC_STS = STS_DEC_DOUT -- decoded data
  ) else '0';

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        READF_q <= '0';
        RS_q <= RS_IDLE;
      else
        READF_q <= READF;
        RS_q <= RS;
      end if;
    end if;
  end process;

  process(RS_q,READ_OP,CNT_q)
  begin
    READF <= '0';
    CNT_RST_R <= '0';
    case RS_q is
      when RS_IDLE =>
        if(READ_OP = '1') then
          CNT_RST_R <= '1'; -- reset counter
          RS <= RS_READ;
        else
          RS <= RS_IDLE;
        end if;
      when RS_READ =>
        READF <= '1';
        if(CNT_q = 0) then
          RS <= RS_WAIT;
        else
          RS <= RS_READ;
        end if;
      when RS_WAIT =>
        if(READ_OP = '0') then
          RS <= RS_IDLE;
        else
          RS <= RS_WAIT;
        end if;
      when others =>
        RS <= RS_IDLE;
    end case;
  end process;

  RE <= READF_q;

  ---------------------------------------------------
  -- Read/Write word (down-) counter
  ---------------------------------------------------

  -- This counter counts the data word to be read from
  -- codec memory, or written to codec memory.

  --process(CDC_STS)
  --begin
  --  case CDC_STS is
  --    when STS_COD_DIN => CNT_INIT <= DECODED_LEN-1;
  --    when STS_COD_DOUT => CNT_INIT <= ENCODED_LEN-1;
  --    when STS_DEC_DIN => CNT_INIT <= ENCODED_LEN-1;
  --    when STS_DEC_DOUT => CNT_INIT <= DECODED_LEN-1;
  --    when others => CNT_INIT <= 0;
  --  end case;
  --end process;

  CNT_INIT <= DECODED_LEN-1 when (
    CDC_STS = STS_COD_DIN or
    CDC_STS = STS_DEC_DOUT
  ) else ENCODED_LEN-1;

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        CNT_q <= 0;
      elsif(CNT_RST_W = '1' or CNT_RST_R = '1') then
        CNT_q <= CNT_INIT;
      elsif(CNT_q > 0) then
        CNT_q <= CNT_q - 1;
      end if;
    end if;
  end process;

  ---------------------------------------------------
  -- Codec instance
  ---------------------------------------------------

  U_CODEC : G729A_CODEC_SDP
    generic map(
      -- synthesis translate_off
      ST_FILE => "NONE",
      WB_FILE => "NONE",
      -- synthesis translate_on
      REGISTER_INPUTS => '0',
      REGISTER_OUTPUTS => '0',
      USE_ROM_MIF => USE_ROM_MIF,
      SIMULATION_ONLY => '0'
    )
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i, 
      STRT_i => STRT,
      OPS_i => OPS,
      RE_i => RE,
      WE_i => WE,
      DI_i  => STI_DO,

      BSY_o  => CDC_BSY,
      DMAE_o => open, 
      STS_o => CDC_STS,
      DV_o  => CDC_DV,
      DO_o  => CDC_DO
    );

  ---------------------------------------------------
  -- Input data ROM
  ---------------------------------------------------

  G_STIROM_1 : if (USE_ROM_MIF = '1') generate

  -- Data content for this ROM is assigned through a MIF file.
  -- This type of ROM is ok for synthesis with Altera tools.

  U_STIROM : G729A_ASIP_ROM_MIF
    generic map(
      WCOUNT => ST_MEM_SIZE,
      DATA_WIDTH => SDLEN,
      ADDR_WIDTH => log2(ST_MEM_SIZE),
      ROM_INIT_FILE => "G729A_codec_sti_rom.mif"
    )
    port map(
      CLK_i => CLK_i,
      A_i => STI_ADR,

      Q_o => STI_DO
    );

  end generate;

  G_STIROM_0 : if (USE_ROM_MIF = '0') generate

  -- Data content for this ROM is explicitly assigned in VHDL code.
  -- This type of ROM is ok for simulation and for synthesis with
  -- Xilinx tools.

  U_STIROM : G729A_ASIP_STI_ROM
    generic map(
      WCOUNT => ST_MEM_SIZE,
      DATA_WIDTH => SDLEN,
      ADDR_WIDTH => log2(ST_MEM_SIZE)
    )
    port map(
      CLK_i => CLK_i,
      A_i => STI_ADR,

      Q_o => STI_DO
    );

  end generate;

  ---------------------------------------------------
  -- Output data ROM
  ---------------------------------------------------

  G_STOROM_1 : if (USE_ROM_MIF = '1') generate

  -- Data content for this ROM is assigned through a MIF file.
  -- This type of ROM is ok for synthesis with Altera tools.

  U_STOROM : G729A_ASIP_ROM_MIF
    generic map(
      WCOUNT => ST_MEM_SIZE,
      DATA_WIDTH => SDLEN,
      ADDR_WIDTH => log2(ST_MEM_SIZE),
      ROM_INIT_FILE => "G729A_codec_sto_rom.mif"
    )
    port map(
      CLK_i => CLK_i,
      A_i => STO_ADR,

      Q_o => STO_DO
    );

  end generate;

  G_STOROM_0 : if (USE_ROM_MIF = '0') generate

  -- Data content for this ROM is explicitly assigned in VHDL code.
  -- This type of ROM is ok for simulation and for synthesis with
  -- Xilinx tools.

  U_STOROM : G729A_ASIP_STO_ROM
    generic map(
      WCOUNT => ST_MEM_SIZE,
      DATA_WIDTH => SDLEN,
      ADDR_WIDTH => log2(ST_MEM_SIZE)
    )
    port map(
      CLK_i => CLK_i,
      A_i => STO_ADR,

      Q_o => STO_DO
    );

  end generate;

  ---------------------------------------------------
  -- Outputs
  ---------------------------------------------------

  DONE_o <= DONE_q;

  PASS_o <= PASS_q;

end ARC;
