--------------------------------------------------------------------
-- Company       : XESS Corp.
-- Engineer      : Dave Vanden Bout
-- Creation Date : 05/17/2005
-- Copyright     : 2005, XESS Corp
-- Tool Versions : WebPACK 6.3.03i
--
-- Description:
--    Customizes the generic SDRAM controller module for the XSA Board.
--
-- Revision:
--    1.1.0
--
-- Additional Comments:
--    1.1.0:
--        Added CLK_DIV generic parameter to allow stepping-down the clock frequency.
--        Added MULTIPLE_ACTIVE_ROWS generic parameter to enable/disable keeping an active row in each bank.
--    1.0.0:
--        Initial release.
--
-- License:
--    This code can be freely distributed and modified as long as
--    this header is not removed.
--------------------------------------------------------------------



library IEEE, UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UNISIM.VComponents.all;
use WORK.common.all;
use WORK.sdram.all;


package XSASDRAM is

  component XSASDRAMCntl
    generic(
      FREQ                 :     natural := 50_000;  -- operating frequency in KHz
      CLK_DIV              :     real    := 1.0;  -- divisor for FREQ (can only be 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 8.0 or 16.0)
      PIPE_EN              :     boolean := true;  -- if true, enable pipelined read operations
      MAX_NOP              :     natural := 10000;  -- number of NOPs before entering self-refresh
      MULTIPLE_ACTIVE_ROWS :     boolean := true;  -- if true, allow an active row in each bank
      DATA_WIDTH           :     natural := 16;  -- host & SDRAM data width
      NROWS                :     natural := 4096;  -- number of rows in SDRAM array
      NCOLS                :     natural := 512;  -- number of columns in SDRAM array
      HADDR_WIDTH          :     natural := 23;  -- host-side address width
      SADDR_WIDTH          :     natural := 12  -- SDRAM-side address width
      );
    port(
      -- host side
      clk                  : in  std_logic;  -- master clock
      bufclk               : out std_logic;  -- buffered master clock
      clk1x                : out std_logic;  -- host clock sync'ed to master clock (and divided if CLK_DIV>1)
      clk2x                : out std_logic;  -- double-speed host clock
      lock                 : out std_logic;  -- true when host clock is locked to master clock
      rst                  : in  std_logic;  -- reset
      rd                   : in  std_logic;  -- initiate read operation
      wr                   : in  std_logic;  -- initiate write operation
      earlyOpBegun         : out std_logic;  -- read/write/self-refresh op begun     (async)
      opBegun              : out std_logic;  -- read/write/self-refresh op begun (clocked)
      rdPending            : out std_logic;  -- read operation(s) are still in the pipeline
      done                 : out std_logic;  -- read or write operation is done
      rdDone               : out std_logic;  -- read done and data is available
      hAddr                : in  std_logic_vector(HADDR_WIDTH-1 downto 0);  -- address from host
      hDIn                 : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- data from host
      hDOut                : out std_logic_vector(DATA_WIDTH-1 downto 0);  -- data to host
      status               : out std_logic_vector(3 downto 0);  -- diagnostic status of the FSM         

      -- SDRAM side
      sclkfb : in    std_logic;         -- clock from SDRAM after PCB delays
      sclk   : out   std_logic;         -- SDRAM clock sync'ed to master clock
      cke    : out   std_logic;         -- clock-enable to SDRAM
      cs_n   : out   std_logic;         -- chip-select to SDRAM
      ras_n  : out   std_logic;         -- SDRAM row address strobe
      cas_n  : out   std_logic;         -- SDRAM column address strobe
      we_n   : out   std_logic;         -- SDRAM write enable
      ba     : out   std_logic_vector(1 downto 0);  -- SDRAM bank address bits
      sAddr  : out   std_logic_vector(SADDR_WIDTH-1 downto 0);  -- SDRAM row/column address
      sData  : inout std_logic_vector(DATA_WIDTH-1 downto 0);  -- SDRAM in/out databus
      dqmh   : out   std_logic;         -- high databits I/O mask
      dqml   : out   std_logic          -- low databits I/O mask
      );
  end component;

end package XSASDRAM;



library IEEE, UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UNISIM.VComponents.all;
use WORK.common.all;
use WORK.sdram.all;

entity XSASDRAMCntl is
  generic(
    FREQ                 :     natural := 50_000;  -- operating frequency in KHz
    CLK_DIV              :     real    := 1.0;  -- divisor for FREQ (can only be 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 8.0 or 16.0)
    PIPE_EN              :     boolean := true;  -- if true, enable pipelined read operations
    MAX_NOP              :     natural := 10000;  -- number of NOPs before entering self-refresh
    MULTIPLE_ACTIVE_ROWS :     boolean := true;  -- if true, allow an active row in each bank
    DATA_WIDTH           :     natural := 16;  -- host & SDRAM data width
    NROWS                :     natural := 4096;  -- number of rows in SDRAM array
    NCOLS                :     natural := 512;  -- number of columns in SDRAM array
    HADDR_WIDTH          :     natural := 23;  -- host-side address width
    SADDR_WIDTH          :     natural := 12  -- SDRAM-side address width
    );
  port(
    -- host side
    clk                  : in  std_logic;  -- master clock
    bufclk               : out std_logic;  -- buffered master clock
    clk1x                : out std_logic;  -- host clock sync'ed to master clock (and divided if CLK_DIV>1)
    clk2x                : out std_logic;  -- double-speed host clock
    lock                 : out std_logic;  -- true when host clock is locked to master clock
    rst                  : in  std_logic;  -- reset
    rd                   : in  std_logic;  -- initiate read operation
    wr                   : in  std_logic;  -- initiate write operation
    earlyOpBegun         : out std_logic;  -- read/write/self-refresh op begun     (async)
    opBegun              : out std_logic;  -- read/write/self-refresh op begun (clocked)
    rdPending            : out std_logic;  -- read operation(s) are still in the pipeline
    done                 : out std_logic;  -- read or write operation is done
    rdDone               : out std_logic;  -- read done and data is available
    hAddr                : in  std_logic_vector(HADDR_WIDTH-1 downto 0);  -- address from host
    hDIn                 : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- data from host
    hDOut                : out std_logic_vector(DATA_WIDTH-1 downto 0);  -- data to host
    status               : out std_logic_vector(3 downto 0);  -- diagnostic status of the FSM         

    -- SDRAM side
    sclkfb : in    std_logic;           -- clock from SDRAM after PCB delays
    sclk   : out   std_logic;           -- SDRAM clock sync'ed to master clock
    cke    : out   std_logic;           -- clock-enable to SDRAM
    cs_n   : out   std_logic;           -- chip-select to SDRAM
    ras_n  : out   std_logic;           -- SDRAM row address strobe
    cas_n  : out   std_logic;           -- SDRAM column address strobe
    we_n   : out   std_logic;           -- SDRAM write enable
    ba     : out   std_logic_vector(1 downto 0);  -- SDRAM bank address bits
    sAddr  : out   std_logic_vector(SADDR_WIDTH-1 downto 0);  -- SDRAM row/column address
    sData  : inout std_logic_vector(DATA_WIDTH-1 downto 0);  -- SDRAM in/out databus
    dqmh   : out   std_logic;           -- high databits I/O mask
    dqml   : out   std_logic            -- low databits I/O mask
    );
end XSASDRAMCntl;



architecture arch of XSASDRAMCntl is

  -- The SDRAM controller and external SDRAM chip will clock on the same edge
  -- if the frequency and divided frequency are both greater than the minimum DLL lock frequency.
  -- Otherwise the DLLs cannot be used so the SDRAM controller and external SDRAM clock on opposite edges
  -- to try and mitigate the clock skew between the internal FPGA logic and the external SDRAM.
  constant MIN_LOCK_FREQ : real    := 25_000.0;
  constant IN_PHASE      : boolean := real(FREQ)/CLK_DIV >= MIN_LOCK_FREQ;
  -- Calculate the frequency of the clock for the SDRAM.
  constant SDRAM_FREQ    : natural := int_select(IN_PHASE, (FREQ*integer(2.0*CLK_DIV))/2, FREQ);
  -- Compute the CLKDV_DIVIDE generic paramter for the DLL modules.  It defaults to 2 when CLK_DIV=1
  -- because the DLL does not support a divisor of 1 on the CLKDV output.  We use the CLK0 output
  -- when CLK_DIV=1 so we don't care what is output on thr CLK_DIV output of the DLL.
  constant CLKDV_DIVIDE  : real    := real_select(CLK_DIV = 1.0, 2.0, CLK_DIV);

  signal int_clkin,                     -- signals for internal logic clock DLL
    int_clk1x, int_clk1x_b,
    int_clk2x, int_clk2x_b,
    int_clkdv, int_clkdv_b              : std_logic;
  signal ext_clkin, sclkfb_b, ext_clk1x : std_logic;  -- signals for external logic clock DLL
  signal dllext_rst, dllext_rst_n       : std_logic;  -- external DLL reset signal
  signal clk_i                          : std_logic;  -- clock for SDRAM controller logic
  signal int_lock, ext_lock, lock_i     : std_logic;  -- DLL lock signals

  -- bus for holding output data from SDRAM
  signal sDOut   : std_logic_vector(sData'range);
  signal sDOutEn : std_logic;

begin

  -----------------------------------------------------------
  -- setup the DLLs for clock generation 
  -----------------------------------------------------------

  -- master clock must come from a dedicated clock pin
  clkin : IBUFG port map (I => clk, O => int_clkin);

  -- The external DLL is driven from the same source as the internal DLL
  -- if the clock divisor is 1.  If CLK_DIV is greater than 1, then the external DLL 
  -- is driven by the divided clock from the internal DLL.  Otherwise, the SDRAM will be
  -- clocked on the opposite edge if the internal and external logic are not in-phase.
  ext_clkin <= int_clkin    when (IN_PHASE and (CLK_DIV = 1.0)) else
                int_clkdv_b when (IN_PHASE and (CLK_DIV/=1.0))  else
                not int_clkin;

  -- Generate the DLLs for sync'ing the clocks as long as the clocks
  -- have a frequency high enough for the DLLs to lock
  gen_dlls : if IN_PHASE generate

    -- generate an internal clock sync'ed to the master clock
    dllint : CLKDLL
      generic map(
        CLKDV_DIVIDE => CLKDV_DIVIDE
        )
      port map(
        CLKIN        => int_clkin,
        CLKFB        => int_clk1x_b,
        CLK0         => int_clk1x,
        RST          => ZERO,
        CLK90        => open,
        CLK180       => open,
        CLK270       => open,
        CLK2X        => int_clk2x,
        CLKDV        => int_clkdv,
        LOCKED       => int_lock
        );

    -- sync'ed single, doubled and divided clocks for use by internal logic
    int_clk1x_buf : BUFG port map(I => int_clk1x, O => int_clk1x_b);
    int_clk2x_buf : BUFG port map(I => int_clk2x, O => int_clk2x_b);
    int_clkdv_buf : BUFG port map(I => int_clkdv, O => int_clkdv_b);

    -- The external DLL is held in a reset state until the internal DLL locks.
    -- Then the external DLL reset is released after a delay set by this shift register.
    -- This keeps the external DLL from locking onto the internal DLL clock signal
    -- until it is stable.
    SRL16_inst : SRL16
      generic map (
        INIT => X"0000"
        )
      port map (
        CLK  => clk_i,
        A0   => '1',
        A1   => '1',
        A2   => '1',
        A3   => '1',
        D    => int_lock,
        Q    => dllext_rst_n
        );
    dllext_rst <= not dllext_rst when CLK_DIV/=1.0 else ZERO;

    -- generate an external SDRAM clock sync'ed to the master clock
    sclkfb_buf : IBUFG port map(I => sclkfb, O => sclkfb_b);  -- SDRAM clock with PCB delays
    dllext     : CLKDLL port map(
      CLKIN                       => ext_clkin,  -- this is either the master clock or the divided clock from the internal DLL
      CLKFB                       => sclkfb_b,
      CLK0                        => ext_clk1x,
      RST                         => dllext_rst,
      CLK90                       => open,
      CLK180                      => open,
      CLK270                      => open,
      CLK2X                       => open,
      CLKDV                       => open,
      LOCKED                      => ext_lock
      );

  end generate;

  -- The buffered clock is just a buffered version of the master clock.
  bufclk <= int_clkin;
  -- The host-side clock comes from the CLK0 output of the internal DLL if the clock divisor is 1.
  -- Otherwise it comes from the CLKDV output if the clock divisor is greater than 1.
  -- Otherwise it is just a copy of the master clock if the DLLs aren't being used.
  clk_i  <= int_clk1x_b when (IN_PHASE and (CLK_DIV = 1.0)) else
            int_clkdv_b when (IN_PHASE and (CLK_DIV/=1.0))  else
            int_clkin;
  clk1x  <= clk_i;                      -- This is the output of the host-side clock
  clk2x  <= int_clk2x_b when IN_PHASE                       else int_clkin;  -- this is the doubled master clock
  sclk   <= ext_clk1x   when IN_PHASE                       else ext_clkin;  -- this is the clock for the external SDRAM

  -- indicate the lock status of the internal and external DLL
  lock_i <= int_lock and ext_lock when IN_PHASE else YES;
  lock   <= lock_i;                     -- lock signal for the host logic

  -- SDRAM memory controller module
  u1 : sdramCntl
    generic map(
      FREQ                 => SDRAM_FREQ,
      IN_PHASE             => IN_PHASE,
      PIPE_EN              => PIPE_EN,
      MAX_NOP              => MAX_NOP,
      MULTIPLE_ACTIVE_ROWS => MULTIPLE_ACTIVE_ROWS,
      DATA_WIDTH           => DATA_WIDTH,
      NROWS                => NROWS,
      NCOLS                => NCOLS,
      HADDR_WIDTH          => HADDR_WIDTH,
      SADDR_WIDTH          => SADDR_WIDTH
      )
    port map(
      clk                  => clk_i,    -- master clock from external clock source (unbuffered)
      lock                 => lock_i,   -- valid synchronized clocks indicator
      rst                  => rst,      -- reset
      rd                   => rd,       -- host-side SDRAM read control from memory tester
      wr                   => wr,       -- host-side SDRAM write control from memory tester
      rdPending            => rdPending,
      opBegun              => opBegun,  -- SDRAM memory read/write done indicator
      earlyOpBegun         => earlyOpBegun,  -- SDRAM memory read/write done indicator
      rdDone               => rdDone,   -- SDRAM memory read/write done indicator
      done                 => done,
      hAddr                => hAddr,    -- host-side address from memory tester
      hDIn                 => hDIn,     -- test data pattern from memory tester
      hDOut                => hDOut,    -- SDRAM data output to memory tester
      status               => status,   -- SDRAM controller state (for diagnostics)
      cke                  => cke,      -- SDRAM clock enable
      ce_n                 => cs_n,     -- SDRAM chip-select
      ras_n                => ras_n,    -- SDRAM RAS
      cas_n                => cas_n,    -- SDRAM CAS
      we_n                 => we_n,     -- SDRAM write-enable
      ba                   => ba,       -- SDRAM bank address
      sAddr                => sAddr,    -- SDRAM address
      sDIn                 => sData,    -- input data from SDRAM
      sDOut                => sDOut,    -- output data to SDRAM
      sDOutEn              => sDOutEn,  -- enable drivers to send data to SDRAM
      dqmh                 => dqmh,     -- SDRAM DQMH
      dqml                 => dqml      -- SDRAM DQML
      );

  sData <= sDOut when sDOutEn = YES else (others => 'Z');

end arch;
