---------------------------------------------------------------------
----                                                             ----
----  OpenCores ATA/ATAPI-5 Host Controller                      ----
----  PIO Timing Controller (common for all OCIDEC cores)        ----
----                                                             ----
----  Author: Richard Herveille                                  ----
----          richard@asics.ws                                   ----
----          www.asics.ws                                       ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2001, 2002 Richard Herveille                  ----
----                          richard@asics.ws                   ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
----     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ----
---- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ----
---- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ----
---- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ----
---- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ----
---- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ----
---- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ----
---- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ----
---- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ----
---- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ----
---- POSSIBILITY OF SUCH DAMAGE.                                 ----
----                                                             ----
---------------------------------------------------------------------

-- rev.: 1.0 march  7th, 2001. Initial release
-- rev.: 1.1 July  11th, 2001. Changed 'igo' & 'hold_go' signal generation.
--
--
--  CVS Log
--
--  $Id: atahost_pio_tctrl.vhd,v 1.1 2002/02/18 14:32:12 rherveille Exp $
--
--  $Date: 2002/02/18 14:32:12 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: atahost_pio_tctrl.vhd,v $
--               Revision 1.1  2002/02/18 14:32:12  rherveille
--               renamed all files to 'atahost_***.vhd'
--               broke-up 'counter.vhd' into 'ud_cnt.vhd' and 'ro_cnt.vhd'
--               changed resD input to generic RESD in ud_cnt.vhd
--               changed ID input to generic ID in ro_cnt.vhd
--               changed core to reflect changes in ro_cnt.vhd
--               removed references to 'count' library
--               changed IO names
--               added disclaimer
--               added CVS log
--               moved registers and wishbone signals into 'atahost_wb_slave.vhd'
--
--
--

--
---------------------------
-- PIO Timing controller --
---------------------------
--

--
-- Timing	PIO mode transfers
----------------------------------------------
-- T0:	cycle time
-- T1:	address valid to DIOR-/DIOW-
-- T2:	DIOR-/DIOW- pulse width
-- T2i:	DIOR-/DIOW- recovery time
-- T3:	DIOW- data setup
-- T4:	DIOW- data hold
-- T5:	DIOR- data setup
-- T6:	DIOR- data hold
-- T9:	address hold from DIOR-/DIOW- negated
-- Trd:	Read data valid to IORDY asserted
-- Ta:	IORDY setup time
-- Tb:	IORDY pulse width
--
-- Transfer sequence
----------------------------------
-- 1)	set address (DA, CS0-, CS1-)
-- 2)	wait for T1
-- 3)	assert DIOR-/DIOW-
--	   when write action present Data (timing spec. T3 always honored), enable output enable-signal
-- 4)	wait for T2
-- 5)	check IORDY
--	   when not IORDY goto 5
-- 	  when IORDY negate DIOW-/DIOR-, latch data (if read action)
--    when write, hold data for T4, disable output-enable signal
-- 6)	wait end_of_cycle_time. This is T2i or T9 or (T0-T1-T2) whichever takes the longest
-- 7)	start new cycle

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;

entity atahost_pio_tctrl is
	generic(
		TWIDTH : natural := 8;                   -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;             -- 70ns
		PIO_mode0_T2 : natural := 28;            -- 290ns
		PIO_mode0_T4 : natural := 2;             -- 30ns
		PIO_mode0_Teoc : natural := 23           -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
	);
	port(
		clk    : in std_logic;                   -- master clock
		nReset : in std_logic;                   -- asynchronous active low reset
		rst    : in std_logic;                   -- synchronous active high reset

		-- timing/control register settings
		IORDY_en : in std_logic;                 -- use IORDY (or not)
		T1   : in std_logic_vector(TWIDTH -1 downto 0);  -- T1 time (in clk-ticks)
		T2   : in std_logic_vector(TWIDTH -1 downto 0);  -- T2 time (in clk-ticks)
		T4   : in std_logic_vector(TWIDTH -1 downto 0);  -- T4 time (in clk-ticks)
		Teoc : in std_logic_vector(TWIDTH -1 downto 0);  -- end of cycle time

		-- control signals
		go : in std_logic;                       -- PIO controller selected (strobe signal)
		we : in std_logic;                       -- write enable signal. '0'=read from device, '1'=write to device

		-- return signals
		oe    : out std_logic;                -- output enable signal
		done  : out std_logic;                   -- finished cycle
		dstrb : out std_logic;                   -- data strobe, latch data (during read)

		-- ATA signals
		DIOR,                                    -- IOread signal, active high
		DIOW  : out std_logic;                -- IOwrite signal, active high
		IORDY : in std_logic                     -- IORDY signal
	);
end entity atahost_pio_tctrl;

architecture structural of atahost_pio_tctrl is
	component ro_cnt is
	generic(
		SIZE : natural := 8;
		UD   : integer := 0; -- default count down
		ID   : natural := 0      -- initial data after reset
	);
	port(
		clk    : in  std_logic;                  -- master clock
		nReset : in  std_logic := '1';           -- asynchronous active low reset
		rst    : in  std_logic := '0';           -- synchronous active high reset

		cnt_en : in  std_logic := '1';           -- count enable
		go     : in  std_logic;                  -- load counter and start sequence
		done   : out std_logic;                  -- done counting
		d      : in  std_logic_vector(SIZE -1 downto 0); -- load counter value
		q      : out std_logic_vector(SIZE -1 downto 0)  -- current counter value
	);
	end component ro_cnt;

	signal T1done, T2done, T4done, Teoc_done, IORDY_done : std_logic;
	signal busy, hold_go, igo, hT2done : std_logic;
	signal iDIOR, iDIOW, ioe : std_logic;
begin

        DIOR <= iDIOR; DIOW <= iDIOW; oe <= ioe;
	-- generate internal go strobe
	-- strecht go until ready for new cycle
	process(clk, nReset)
	begin
		if (nReset = '0') then
			busy <= '0';
			hold_go <= '0';
		elsif (clk'event and clk = '1') then
			if (rst = '1') then
				busy <= '0';
				hold_go <= '0';
			else
				busy <= (igo or busy) and not Teoc_done;
				hold_go <= (go or (hold_go and busy)) and not igo;
			end if;
		end if;
	end process;
	igo <= (go or hold_go) and not busy;

	-- 1)	hookup T1 counter
	t1_cnt : ro_cnt 
		generic map (
			SIZE => TWIDTH,
			UD   => 0,
			ID   => PIO_mode0_T1
		)
		port map (
			clk => clk,
			nReset => nReset,
			rst => rst,
			go => igo,
			D => T1,
			done => T1done
		);

	-- 2)	set (and reset) DIOR-/DIOW-, set output-enable when writing to device
	T2proc: process(clk, nReset)
	begin
		if (nReset = '0') then
			iDIOR <= '0';
			iDIOW <= '0';
			ioe   <= '0';
		elsif (clk'event and clk = '1') then
			if (rst = '1') then
				iDIOR <= '0';
				iDIOW <= '0';
				ioe   <= '0';
			else
				iDIOR <= (not we and T1done) or (iDIOR and not IORDY_done);
				iDIOW <= (    we and T1done) or (iDIOW and not IORDY_done);
				ioe   <= ( (we and igo) or ioe) and not T4done; -- negate oe when t4-done
			end if;
		end if;
	end process T2proc;

	-- 3)	hookup T2 counter
	t2_cnt : ro_cnt 
		generic map (
			SIZE => TWIDTH,
			UD   => 0,
			ID   => PIO_mode0_T2
		)
		port map (
			clk => clk,
			nReset => nReset,
			rst => rst,
			go => T1done,
			D => T2,
			done => T2done
		);

	-- 4)	check IORDY (if used), generate release_DIOR-/DIOW- signal (ie negate DIOR-/DIOW-)
	-- hold T2done
	gen_hT2done: process(clk, nReset)
	begin
		if (nReset = '0') then
			hT2done <= '0';
		elsif (clk'event and clk = '1') then
			if (rst = '1') then
				hT2done <= '0';
			else
				hT2done <= (T2done or hT2done) and not IORDY_done;
			end if;
		end if;
	end process gen_hT2done;
	IORDY_done <= (T2done or hT2done) and (IORDY or not IORDY_en);

	-- generate datastrobe, capture data at rising DIOR- edge
	gen_dstrb: process(clk)
	begin
		if (clk'event and clk = '1') then
			dstrb <= IORDY_done;
		end if;
	end process gen_dstrb;

	-- hookup data hold counter
	dhold_cnt : ro_cnt 
		generic map (
			SIZE => TWIDTH,
			UD   => 0,
			ID   => PIO_mode0_T4
		)
		port map (
			clk => clk,
			nReset => nReset,
			rst => rst,
			go => IORDY_done,
			D => T4,
			done => T4done
		);
	done <= T4done; -- placing done here provides the fastest return possible, 
                      -- while still guaranteeing data and address hold-times

	-- 5)	hookup end_of_cycle counter
	eoc_cnt : ro_cnt 
		generic map (
			SIZE => TWIDTH,
			UD   => 0,
			ID   => PIO_mode0_Teoc
		)
		port map (
			clk => clk,
			nReset => nReset,
			rst => rst,
			go => IORDY_done,
			D => Teoc,
			done => Teoc_done
		);

end architecture structural;
