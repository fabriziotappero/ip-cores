--------------------------------------------------------------------
-- Company : XESS Corp.
-- Engineer : Dave Vanden Bout
-- Creation Date : 05/17/2005
-- Copyright : 2005, XESS Corp
-- Tool Versions : WebPACK 6.3.03i
--
-- Description:
-- SDRAM controller
--
-- Revision:
-- n.a. (because of hacking by Hellwig Geisse)
--
-- Additional Comments:
-- 1.4.0:
-- Added generic parameter to enable/disable independent active rows in each bank.
-- 1.3.0:
-- Modified to allow independently active rows in each bank.
-- 1.2.0:
-- Modified to allow pipelining of read/write operations.
-- 1.1.0:
-- Initial release.
--
-- License:
-- This code can be freely distributed and modified as long as
-- this header is not removed.
--------------------------------------------------------------------

library IEEE, UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity sdramCntl is
  port(
    -- host side
    clk                  : in  std_logic;  -- master clock
    clk_ok               : in  std_logic;  -- true if clock is stable
    rd                   : in  std_logic;  -- initiate read operation
    wr                   : in  std_logic;  -- initiate write operation
    done                 : out std_logic;  -- read or write operation is done
    hAddr                : in  std_logic_vector(23 downto 0);  -- address from host to SDRAM
    hDIn                 : in  std_logic_vector(15 downto 0);  -- data from host       to SDRAM
    hDOut                : out std_logic_vector(15 downto 0);  -- data from SDRAM to host

    -- SDRAM side
    cke     : out std_logic;            -- clock-enable to SDRAM
    ce_n    : out std_logic;            -- chip-select to SDRAM
    ras_n   : out std_logic;            -- SDRAM row address strobe
    cas_n   : out std_logic;            -- SDRAM column address strobe
    we_n    : out std_logic;            -- SDRAM write enable
    ba      : out std_logic_vector(1 downto 0);  -- SDRAM bank address
    sAddr   : out std_logic_vector(12 downto 0);  -- SDRAM row/column address
    sDIn    : in  std_logic_vector(15 downto 0);  -- data from SDRAM
    sDOut   : out std_logic_vector(15 downto 0);  -- data to SDRAM
    sDOutEn : out std_logic;            -- true if data is output to SDRAM on sDOut
    dqmh    : out std_logic;            -- enable upper-byte of SDRAM databus if true
    dqml    : out std_logic             -- enable lower-byte of SDRAM databus if true
    );
end sdramCntl;


architecture arch of sdramCntl is

  constant YES                :    std_logic := '1';
  constant NO                 :    std_logic := '0';

  -- select one of two integers based on a Boolean
  function int_select(s : in boolean; a : in integer; b : in integer) return integer is
  begin
    if s then
      return a;
    else
      return b;
    end if;
    return a;
  end function int_select;

  constant OUTPUT : std_logic := '1';   -- direction of dataflow w.r.t. this controller
  constant INPUT  : std_logic := '0';
  constant NOP    : std_logic := '0';   -- no operation
  constant READ   : std_logic := '1';   -- read operation
  constant WRITE  : std_logic := '1';   -- write operation

  -- SDRAM timing parameters
  constant Tinit : natural := 200;      -- min initialization interval (us)
  constant Tras  : natural := 45;       -- min interval between active to precharge commands (ns)
  constant Trcd  : natural := 20;       -- min interval between active and R/W commands (ns)
  constant Tref  : natural := 64_000_000;  -- maximum refresh interval (ns)
  constant Trfc  : natural := 66;       -- duration of refresh operation (ns)
  constant Trp   : natural := 20;       -- min precharge command duration (ns)
  constant Twr   : natural := 15;       -- write recovery time (ns)
  constant Txsr  : natural := 75;       -- exit self-refresh time (ns)

  -- SDRAM timing parameters converted into clock cycles (based on FREQ = 50_000)
  constant NORM        : natural := 1_000_000;  -- normalize ns * KHz
  constant INIT_CYCLES : natural := 1+((Tinit*50_000)/1000);  -- SDRAM power-on initialization interval
  constant RAS_CYCLES  : natural := 1+((Tras*50_000)/NORM);  -- active-to-precharge interval
  constant RCD_CYCLES  : natural := 1+((Trcd*50_000)/NORM);  -- active-to-R/W interval
  constant REF_CYCLES  : natural := 1+(((Tref/8192)*50_000)/NORM);  -- interval between row refreshes
  constant RFC_CYCLES  : natural := 1+((Trfc*50_000)/NORM);  -- refresh operation interval
  constant RP_CYCLES   : natural := 1+((Trp*50_000)/NORM);  -- precharge operation interval
  constant WR_CYCLES   : natural := 1+((Twr*50_000)/NORM);  -- write recovery time
  constant XSR_CYCLES  : natural := 1+((Txsr*50_000)/NORM);  -- exit self-refresh time
  constant MODE_CYCLES : natural := 2;  -- mode register setup time
  constant CAS_CYCLES  : natural := 3;  -- CAS latency
  constant RFSH_OPS    : natural := 8;  -- number of refresh operations needed to init SDRAM

  -- timer registers that count down times for various SDRAM operations
  signal timer_r, timer_x       : natural range 0 to INIT_CYCLES;  -- current SDRAM op time
  signal rasTimer_r, rasTimer_x : natural range 0 to RAS_CYCLES;  -- active-to-precharge time
  signal wrTimer_r, wrTimer_x   : natural range 0 to WR_CYCLES;  -- write-to-precharge time
  signal refTimer_r, refTimer_x : natural range 0 to REF_CYCLES;  -- time between row refreshes
  signal rfshCntr_r, rfshCntr_x : natural range 0 to 8192;  -- counts refreshes that are neede
  signal nopCntr_r, nopCntr_x   : natural range 0 to 10000;  -- counts consecutive NOP operations

  signal doSelfRfsh : std_logic;        -- active when the NOP counter hits zero and self-refresh can start

  -- states of the SDRAM controller state machine
  type cntlState is (
    INITWAIT,                           -- initialization - waiting for power-on initialization to complete
    INITPCHG,                           -- initialization - initial precharge of SDRAM banks
    INITSETMODE,                        -- initialization - set SDRAM mode
    INITRFSH,                           -- initialization - do initial refreshes
    RW,                                 -- read/write/refresh the SDRAM
    ACTIVATE,                           -- open a row of the SDRAM for reading/writing
    REFRESHROW,                         -- refresh a row of the SDRAM
    SELFREFRESH                         -- keep SDRAM in self-refresh mode with CKE low
    );
  signal state_r, state_x : cntlState;  -- state register and next state

  -- commands that are sent to the SDRAM to make it perform certain operations
  -- commands use these SDRAM input pins (ce_n,ras_n,cas_n,we_n,dqmh,dqml)
  subtype sdramCmd is unsigned(5 downto 0);
  constant NOP_CMD    : sdramCmd := "011100";
  constant ACTIVE_CMD : sdramCmd := "001100";
  constant READ_CMD   : sdramCmd := "010100";
  constant WRITE_CMD  : sdramCmd := "010000";
  constant PCHG_CMD   : sdramCmd := "001011";
  constant MODE_CMD   : sdramCmd := "000011";
  constant RFSH_CMD   : sdramCmd := "000111";

  -- SDRAM mode register
  -- the SDRAM is placed in a non-burst mode (burst length = 1) with a 3-cycle CAS
  subtype sdramMode is std_logic_vector(12 downto 0);
  constant MODE : sdramMode := "000" & "0" & "00" & "011" & "0" & "000";

  -- the host address is decomposed into these sets of SDRAM address components
  constant ROW_LEN : natural := 13;  -- number of row address bits
  constant COL_LEN : natural := 9;  -- number of column address bits
  signal   bank    : std_logic_vector(ba'range);  -- bank address bits
  signal   row     : std_logic_vector(ROW_LEN - 1 downto 0);  -- row address within bank
  signal   col     : std_logic_vector(sAddr'range);  -- column address within row

  -- registers that store the currently active row in each bank of the SDRAM
  constant NUM_ACTIVE_ROWS            : integer := 1;
  type activeRowType is array(0 to NUM_ACTIVE_ROWS-1) of std_logic_vector(row'range);
  signal   activeRow_r, activeRow_x   : activeRowType;
  signal   activeFlag_r, activeFlag_x : std_logic_vector(0 to NUM_ACTIVE_ROWS-1);  -- indicates that some row in a bank is active
  signal   bankIndex                  : natural range 0 to NUM_ACTIVE_ROWS-1;  -- bank address bits
  signal   activeBank_r, activeBank_x : std_logic_vector(ba'range);  -- indicates the bank with the active row
  signal   doActivate                 : std_logic;  -- indicates when a new row in a bank needs to be activated

  -- there is a command bit embedded within the SDRAM column address
  constant CMDBIT_POS    : natural   := 10;  -- position of command bit
  constant AUTO_PCHG_ON  : std_logic := '1';  -- CMDBIT value to auto-precharge the bank
  constant AUTO_PCHG_OFF : std_logic := '0';  -- CMDBIT value to disable auto-precharge
  constant ONE_BANK      : std_logic := '0';  -- CMDBIT value to select one bank
  constant ALL_BANKS     : std_logic := '1';  -- CMDBIT value to select all banks

  -- status signals that indicate when certain operations are in progress
  signal wrInProgress       : std_logic;  -- write operation in progress
  signal rdInProgress       : std_logic;  -- read operation in progress
  signal activateInProgress : std_logic;  -- row activation is in progress

  -- these registers track the progress of read and write operations
  signal rdPipeline_r, rdPipeline_x : std_logic_vector(CAS_CYCLES+1 downto 0);  -- pipeline of read ops in progress
  signal wrPipeline_r, wrPipeline_x : std_logic_vector(0 downto 0);  -- pipeline of write ops (only need 1 cycle)

  -- registered outputs to host
  signal hDOut_r, hDOut_x                 : std_logic_vector(hDOut'range);  -- holds data read from SDRAM and sent to the host

  -- registered outputs to SDRAM
  signal cke_r, cke_x           : std_logic;  -- clock enable 
  signal cmd_r, cmd_x           : sdramCmd;  -- SDRAM command bits
  signal ba_r, ba_x             : std_logic_vector(ba'range);  -- SDRAM bank address bits
  signal sAddr_r, sAddr_x       : std_logic_vector(sAddr'range);  -- SDRAM row/column address
  signal sData_r, sData_x       : std_logic_vector(sDOut'range);  -- SDRAM out databus
  signal sDataDir_r, sDataDir_x : std_logic;  -- SDRAM databus direction control bit

begin

  -----------------------------------------------------------
  -- attach some internal signals to the I/O ports 
  -----------------------------------------------------------

  -- attach registered SDRAM control signals to SDRAM input pins
  (ce_n, ras_n, cas_n, we_n, dqmh, dqml) <= cmd_r;  -- SDRAM operation control bits
  cke                                    <= cke_r;  -- SDRAM clock enable
  ba                                     <= ba_r;  -- SDRAM bank address
  sAddr                                  <= sAddr_r;  -- SDRAM address
  sDOut                                  <= sData_r;  -- SDRAM output data bus
  sDOutEn                                <= YES when sDataDir_r = OUTPUT else NO;  -- output databus enable

  -- attach some port signals
  hDOut   <= hDOut_r;                   -- data back to host


  -----------------------------------------------------------
  -- compute the next state and outputs 
  -----------------------------------------------------------

  combinatorial : process(rd, wr, hAddr, hDIn, hDOut_r, sDIn, state_r,
                          activeFlag_r, activeRow_r, activeBank_r,
                          rdPipeline_r, wrPipeline_r,
                          nopCntr_r, rfshCntr_r, timer_r, rasTimer_r,
                          wrTimer_r, refTimer_r, cmd_r, cke_r)
  begin

    -----------------------------------------------------------
    -- setup default values for signals 
    -----------------------------------------------------------

    cke_x        <= YES;                -- enable SDRAM clock
    cmd_x        <= NOP_CMD;            -- set SDRAM command to no-operation
    sDataDir_x   <= INPUT;              -- accept data from the SDRAM
    sData_x      <= hDIn(sData_x'range);  -- output data from host to SDRAM
    state_x      <= state_r;            -- reload these registers and flags
    activeFlag_x <= activeFlag_r;       --              with their existing values
    activeRow_x  <= activeRow_r;
    activeBank_x <= activeBank_r;
    rfshCntr_x   <= rfshCntr_r;

    -----------------------------------------------------------
    -- setup default value for the SDRAM address 
    -----------------------------------------------------------

    -- extract bank field from host address
    ba_x                    <= hAddr(ba'length + ROW_LEN + COL_LEN - 1 downto ROW_LEN + COL_LEN);
    bank                    <= ba_x;
    bankIndex               <= 0;
    -- extract row, column fields from host address
    row                     <= hAddr(ROW_LEN + COL_LEN - 1 downto COL_LEN);
    -- extend column (if needed) until it is as large as the (SDRAM address bus - 1)
    col                     <= (others => '0');  -- set it to all zeroes
    col(COL_LEN-1 downto 0) <= hAddr(COL_LEN-1 downto 0);
    -- by default, set SDRAM address to the column address with interspersed
    -- command bit set to disable auto-precharge
    sAddr_x                 <= col(col'high-1 downto CMDBIT_POS) & AUTO_PCHG_OFF
                               & col(CMDBIT_POS-1 downto 0);

    -----------------------------------------------------------
    -- manage the read and write operation pipelines
    -----------------------------------------------------------

    -- determine if read operations are in progress by the presence of
    -- READ flags in the read pipeline 
    if rdPipeline_r(rdPipeline_r'high downto 1) /= 0 then
      rdInProgress <= YES;
    else
      rdInProgress <= NO;
    end if;

    -- enter NOPs into the read and write pipeline shift registers by default
    rdPipeline_x    <= NOP & rdPipeline_r(rdPipeline_r'high downto 1);
    wrPipeline_x(0) <= NOP;

    -- transfer data from SDRAM to the host data register if a read flag has exited the pipeline
    -- (the transfer occurs 1 cycle before we tell the host the read operation is done)
    if rdPipeline_r(1) = READ then
      -- get the SDRAM data for the host directly from the SDRAM if the controller and SDRAM are in-phase
      hDOut_x       <= sDIn(hDOut'range);
    else
      -- retain contents of host data registers if no data from the SDRAM has arrived yet
      hDOut_x         <= hDOut_r;
    end if;

    done   <= rdPipeline_r(0) or wrPipeline_r(0);  -- a read or write operation is done

    -----------------------------------------------------------
    -- manage row activation
    -----------------------------------------------------------

    -- request a row activation operation if the row of the current address
    -- does not match the currently active row in the bank, or if no row
    -- in the bank is currently active
    if (bank /= activeBank_r) or (row /= activeRow_r(bankIndex)) or (activeFlag_r(bankIndex) = NO) then
      doActivate <= YES;
    else
      doActivate <= NO;
    end if;

    -----------------------------------------------------------
    -- manage self-refresh
    -----------------------------------------------------------

    -- enter self-refresh if neither a read or write is requested for 10000 consecutive cycles.
    if (rd = YES) or (wr = YES) then
      -- any read or write resets NOP counter and exits self-refresh state
      nopCntr_x  <= 0;
      doSelfRfsh <= NO;
    elsif nopCntr_r /= 10000 then
      -- increment NOP counter whenever there is no read or write operation 
      nopCntr_x  <= nopCntr_r + 1;
      doSelfRfsh <= NO;
    else
      -- start self-refresh when counter hits maximum NOP count and leave counter unchanged
      nopCntr_x  <= nopCntr_r;
      doSelfRfsh <= YES;
    end if;

    -----------------------------------------------------------
    -- update the timers 
    -----------------------------------------------------------

    -- row activation timer
    if rasTimer_r /= 0 then
      -- decrement a non-zero timer and set the flag
      -- to indicate the row activation is still inprogress
      rasTimer_x         <= rasTimer_r - 1;
      activateInProgress <= YES;
    else
      -- on timeout, keep the timer at zero     and reset the flag
      -- to indicate the row activation operation is done
      rasTimer_x         <= rasTimer_r;
      activateInProgress <= NO;
    end if;

    -- write operation timer            
    if wrTimer_r /= 0 then
      -- decrement a non-zero timer and set the flag
      -- to indicate the write operation is still inprogress
      wrTimer_x    <= wrTimer_r - 1;
      wrInPRogress <= YES;
    else
      -- on timeout, keep the timer at zero and reset the flag that
      -- indicates a write operation is in progress
      wrTimer_x    <= wrTimer_r;
      wrInPRogress <= NO;
    end if;

    -- refresh timer            
    if refTimer_r /= 0 then
      refTimer_x <= refTimer_r - 1;
    else
      -- on timeout, reload the timer with the interval between row refreshes
      -- and increment the counter for the number of row refreshes that are needed
      refTimer_x <= REF_CYCLES;
      rfshCntr_x <= rfshCntr_r + 1;
    end if;

    -- main timer for sequencing SDRAM operations               
    if timer_r /= 0 then
      -- decrement the timer and do nothing else since the previous operation has not completed yet.
      timer_x <= timer_r - 1;
    else
      -- the previous operation has completed once the timer hits zero
      timer_x <= timer_r;               -- by default, leave the timer at zero

      -----------------------------------------------------------
      -- compute the next state and outputs 
      -----------------------------------------------------------
      case state_r is

        -----------------------------------------------------------
        -- let clock stabilize and then wait for the SDRAM to initialize 
        -----------------------------------------------------------
        when INITWAIT =>
                                        -- wait for SDRAM power-on initialization once the clock is stable
            timer_x <= INIT_CYCLES;     -- set timer for initialization duration
            state_x <= INITPCHG;

          -----------------------------------------------------------
          -- precharge all SDRAM banks after power-on initialization 
          -----------------------------------------------------------
        when INITPCHG =>
          cmd_x               <= PCHG_CMD;
          sAddr_x(CMDBIT_POS) <= ALL_BANKS;  -- precharge all banks
          timer_x             <= RP_CYCLES;  -- set timer for precharge operation duration
          rfshCntr_x          <= RFSH_OPS;  -- set counter for refresh ops needed after precharge
          state_x             <= INITRFSH;

          -----------------------------------------------------------
          -- refresh the SDRAM a number of times after initial precharge 
          -----------------------------------------------------------
        when INITRFSH =>
          cmd_x      <= RFSH_CMD;
          timer_x    <= RFC_CYCLES;     -- set timer to refresh operation duration
          rfshCntr_x <= rfshCntr_r - 1;  -- decrement refresh operation counter
          if rfshCntr_r = 1 then
            state_x  <= INITSETMODE;    -- set the SDRAM mode once all refresh ops are done
          end if;

          -----------------------------------------------------------
          -- set the mode register of the SDRAM 
          -----------------------------------------------------------
        when INITSETMODE =>
          cmd_x   <= MODE_CMD;
          sAddr_x <= MODE;              -- output mode register bits on the SDRAM address bits
          timer_x <= MODE_CYCLES;       -- set timer for mode setting operation duration
          state_x <= RW;

          -----------------------------------------------------------
          -- process read/write/refresh operations after initialization is done 
          -----------------------------------------------------------
        when RW                                      =>
          -----------------------------------------------------------
          -- highest priority operation: row refresh 
          -- do a refresh operation if the refresh counter is non-zero
          -----------------------------------------------------------
          if rfshCntr_r /= 0 then
                                        -- wait for any row activations, writes or reads to finish before doing a precharge
            if (activateInProgress = NO) and (wrInProgress = NO) and (rdInProgress = NO) then
              cmd_x                       <= PCHG_CMD;  -- initiate precharge of the SDRAM
              sAddr_x(CMDBIT_POS)         <= ALL_BANKS;  -- precharge all banks
              timer_x                     <= RP_CYCLES;  -- set timer for this operation
              activeFlag_x                <= (others => NO);  -- all rows are inactive after a precharge operation
              state_x                     <= REFRESHROW;  -- refresh the SDRAM after the precharge
            end if;
            -----------------------------------------------------------
            -- do a host-initiated read operation 
            -----------------------------------------------------------
          elsif rd = YES then
					  -- Wait one clock cycle if the bank address has just changed and each bank has its own active row.
            -- This gives extra time for the row activation circuitry.
            if (true) then
                                        -- activate a new row if the current read is outside the active row or bank
              if doActivate = YES then
                                        -- activate new row only if all previous activations, writes, reads are done
                if (activateInProgress = NO) and (wrInProgress = NO) and (rdInProgress = NO) then
                  cmd_x                   <= PCHG_CMD;  -- initiate precharge of the SDRAM
                  sAddr_x(CMDBIT_POS)     <= ONE_BANK;  -- precharge this bank
                  timer_x                 <= RP_CYCLES;  -- set timer for this operation
                  activeFlag_x(bankIndex) <= NO;  -- rows in this bank are inactive after a precharge operation
                  state_x                 <= ACTIVATE;  -- activate the new row after the precharge is done
                end if;
                                        -- read from the currently active row if no previous read operation
                                        -- is in progress or if pipeline reads are enabled
                                        -- we can always initiate a read even if a write is already in progress
              elsif (rdInProgress = NO) then
                cmd_x                     <= READ_CMD;  -- initiate a read of the SDRAM
                                        -- insert a flag into the pipeline shift register that will exit the end
                                        -- of the shift register when the data from the SDRAM is available
                rdPipeline_x              <= READ & rdPipeline_r(rdPipeline_r'high downto 1);
              end if;
            end if;
            -----------------------------------------------------------
            -- do a host-initiated write operation 
            -----------------------------------------------------------
          elsif wr = YES then
					  -- Wait one clock cycle if the bank address has just changed and each bank has its own active row.
            -- This gives extra time for the row activation circuitry.
            if (true) then
                                        -- activate a new row if the current write is outside the active row or bank
              if doActivate = YES then
                                        -- activate new row only if all previous activations, writes, reads are done
                if (activateInProgress = NO) and (wrInProgress = NO) and (rdInProgress = NO) then
                  cmd_x                   <= PCHG_CMD;  -- initiate precharge of the SDRAM
                  sAddr_x(CMDBIT_POS)     <= ONE_BANK;  -- precharge this bank
                  timer_x                 <= RP_CYCLES;  -- set timer for this operation
                  activeFlag_x(bankIndex) <= NO;  -- rows in this bank are inactive after a precharge operation
                  state_x                 <= ACTIVATE;  -- activate the new row after the precharge is done
                end if;
                                        -- write to the currently active row if no previous read operations are in progress
              elsif rdInProgress = NO then
                cmd_x                     <= WRITE_CMD;  -- initiate the write operation
                sDataDir_x                <= OUTPUT;  -- turn on drivers to send data to SDRAM
                                        -- set timer so precharge doesn't occur too soon after write operation
                wrTimer_x                 <= WR_CYCLES;
                                        -- insert a flag into the 1-bit pipeline shift register that will exit on the
                                        -- next cycle.  The write into SDRAM is not actually done by that time, but
                                        -- this doesn't matter to the host
                wrPipeline_x(0)           <= WRITE;
              end if;
            end if;
            -----------------------------------------------------------
            -- do a host-initiated self-refresh operation 
            -----------------------------------------------------------
          elsif doSelfRfsh = YES then
                                        -- wait until all previous activations, writes, reads are done
            if (activateInProgress = NO) and (wrInProgress = NO) and (rdInProgress = NO) then
              cmd_x                       <= PCHG_CMD;  -- initiate precharge of the SDRAM
              sAddr_x(CMDBIT_POS)         <= ALL_BANKS;  -- precharge all banks
              timer_x                     <= RP_CYCLES;  -- set timer for this operation
              activeFlag_x                <= (others => NO);  -- all rows are inactive after a precharge operation
              state_x                     <= SELFREFRESH;  -- self-refresh the SDRAM after the precharge
            end if;
            -----------------------------------------------------------
            -- no operation
            -----------------------------------------------------------
          else
            state_x                       <= RW;  -- continue to look for SDRAM operations to execute
          end if;

          -----------------------------------------------------------
          -- activate a row of the SDRAM 
          -----------------------------------------------------------
        when ACTIVATE                        =>
          cmd_x                   <= ACTIVE_CMD;
          sAddr_x                 <= (others => '0');  -- output the address for the row to be activated
          sAddr_x(row'range)      <= row;
          activeBank_x            <= bank;
          activeRow_x(bankIndex)  <= row;  -- store the new active SDRAM row address
          activeFlag_x(bankIndex) <= YES;  -- the SDRAM is now active
          rasTimer_x              <= RAS_CYCLES;  -- minimum time before another precharge can occur 
          timer_x                 <= RCD_CYCLES;  -- minimum time before a read/write operation can occur
          state_x                 <= RW;  -- return to do read/write operation that initiated this activation

          -----------------------------------------------------------
          -- refresh a row of the SDRAM         
          -----------------------------------------------------------
        when REFRESHROW =>
          cmd_x      <= RFSH_CMD;
          timer_x    <= RFC_CYCLES;     -- refresh operation interval
          rfshCntr_x <= rfshCntr_r - 1;  -- decrement the number of needed row refreshes
          state_x    <= RW;             -- process more SDRAM operations after refresh is done

          -----------------------------------------------------------
          -- place the SDRAM into self-refresh and keep it there until further notice           
          -----------------------------------------------------------
        when SELFREFRESH            =>
          if (doSelfRfsh = YES) then
                                        -- keep the SDRAM in self-refresh mode as long as requested and until there is a stable clock
            cmd_x        <= RFSH_CMD;   -- output the refresh command; this is only needed on the first clock cycle
            cke_x        <= NO;         -- disable the SDRAM clock
          else
                                        -- else exit self-refresh mode and start processing read and write operations
            cke_x        <= YES;        -- restart the SDRAM clock
            rfshCntr_x   <= 0;          -- no refreshes are needed immediately after leaving self-refresh
            activeFlag_x <= (others => NO);  -- self-refresh deactivates all rows
            timer_x      <= XSR_CYCLES;  -- wait this long until read and write operations can resume
            state_x      <= RW;
          end if;

          -----------------------------------------------------------
          -- unknown state
          -----------------------------------------------------------
        when others =>
          state_x <= INITWAIT;          -- reset state if in erroneous state

      end case;
    end if;
  end process combinatorial;


  -----------------------------------------------------------
  -- update registers on the appropriate clock edge     
  -----------------------------------------------------------

  update : process(clk_ok, clk)
  begin

    if clk_ok = NO then
      -- asynchronous reset
      state_r      <= INITWAIT;
      activeFlag_r <= (others => NO);
      rfshCntr_r   <= 0;
      timer_r      <= 0;
      refTimer_r   <= REF_CYCLES;
      rasTimer_r   <= 0;
      wrTimer_r    <= 0;
      nopCntr_r    <= 0;
      rdPipeline_r <= (others => '0');
      wrPipeline_r <= (others => '0');
      cke_r        <= NO;
      cmd_r        <= NOP_CMD;
      ba_r         <= (others => '0');
      sAddr_r      <= (others => '0');
      sData_r      <= (others => '0');
      sDataDir_r   <= INPUT;
      hDOut_r      <= (others => '0');
    elsif rising_edge(clk) then
      state_r      <= state_x;
      activeBank_r <= activeBank_x;
      activeRow_r  <= activeRow_x;
      activeFlag_r <= activeFlag_x;
      rfshCntr_r   <= rfshCntr_x;
      timer_r      <= timer_x;
      refTimer_r   <= refTimer_x;
      rasTimer_r   <= rasTimer_x;
      wrTimer_r    <= wrTimer_x;
      nopCntr_r    <= nopCntr_x;
      rdPipeline_r <= rdPipeline_x;
      wrPipeline_r <= wrPipeline_x;
      cke_r        <= cke_x;
      cmd_r        <= cmd_x;
      ba_r         <= ba_x;
      sAddr_r      <= sAddr_x;
      sData_r      <= sData_x;
      sDataDir_r   <= sDataDir_x;
      hDOut_r      <= hDOut_x;
    end if;

  end process update;

end arch;
