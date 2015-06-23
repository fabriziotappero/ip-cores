---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  DMA (single- and multiword) mode timing statemachine       ----
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

-- rev.: 1.0 march 7th, 2001. Initial release
--
--  CVS Log
--
--  $Id: atahost_dma_tctrl.vhd,v 1.1 2002-02-18 14:32:12 rherveille Exp $
--
--  $Date: 2002-02-18 14:32:12 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: not supported by cvs2svn $
--

--
---------------------------
-- DMA Timing Controller --
---------------------------
--

--
-- Timing	DMA mode transfers
----------------------------------------------
-- T0:	cycle time
-- Td:	DIOR-/DIOW- asserted pulse width
-- Te: DIOR- data access
-- Tf: DIOR- data hold
-- Tg: DIOR-/DIOW- data setup
-- Th: DIOW- data hold
-- Ti: DMACK to DIOR-/DIOW- setup
-- Tj: DIOR-/DIOW- to DMACK hold
-- Tkr: DIOR- negated pulse width
-- Tkw: DIOW- negated pulse width
-- Tm: CS(1:0) valid to DIOR-/DIOW-
-- Tn: CS(1:0) hold
--
--
-- Transfer sequence
----------------------------------
-- 1) wait for Tm
-- 2) assert DIOR-/DIOW-
--    when write action present data (Timing spec. Tg always honored)
--    output enable is controlled by DMA-direction and DMACK-
-- 3) wait for Td
-- 4) negate DIOR-/DIOW-
--    when read action, latch data
-- 5) wait for Teoc (T0 - Td - Tm) or Tkw, whichever is greater
--    Th, Tj, Tk, Tn always honored
-- 6) start new cycle
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity atahost_dma_tctrl is
	generic(
		TWIDTH : natural := 8;                        -- counter width

		-- DMA mode 0 settings (@100MHz clock)
		DMA_mode0_Tm : natural := 4;                  -- 50ns
		DMA_mode0_Td : natural := 21;                 -- 215ns
		DMA_mode0_Teoc : natural := 21                -- 215ns ==> T0 - Td - Tm = 480 - 50 - 215 = 215
	);
	port(
		clk : in std_logic;                           -- master clock
		nReset : in std_logic;                        -- asynchronous active low reset
		rst : in std_logic;                           -- synchronous active high reset

		-- timing register settings
		Tm : in unsigned(TWIDTH -1 downto 0);         -- Tm time (in clk-ticks)
		Td : in unsigned(TWIDTH -1 downto 0);         -- Td time (in clk-ticks)
		Teoc : in unsigned(TWIDTH -1 downto 0);       -- end of cycle time

		-- control signals
		go : in std_logic;                            -- DMA controller selected (strobe signal)
		we : in std_logic;                            -- DMA direction '1' = write, '0' = read

		-- return signals
		done : out std_logic;                         -- finished cycle
		dstrb : out std_logic;                        -- data strobe

		-- ATA signals
		DIOR,                                         -- IOread signal, active high
		DIOW : buffer std_logic                       -- IOwrite signal, active high
	);
end entity atahost_dma_tctrl;

architecture structural of atahost_dma_tctrl is
	component ro_cnt is
	generic(
		SIZE : natural := 8;
		UD   : std_logic := '0'; -- default count down
		ID   : natural := 0      -- initial data after reset
	);
	port(
		clk    : in  std_logic;                  -- master clock
		nReset : in  std_logic := '1';           -- asynchronous active low reset
		rst    : in  std_logic := '0';           -- synchronous active high reset

		cnt_en : in  std_logic := '1';           -- count enable
		go     : in  std_logic;                  -- load counter and start sequence
		done   : out std_logic;                  -- done counting
		d      : in  unsigned(SIZE -1 downto 0); -- load counter value
		q      : out unsigned(SIZE -1 downto 0)  -- current counter value
	);
	end component ro_cnt;

	signal Tmdone, Tddone : std_logic;
begin

	-- 1)	hookup Tm counter
	tm_cnt : ro_cnt 
		generic map (
			SIZE => TWIDTH,
			UD   => '0',
			ID   => DMA_mode0_Tm
		)
		port map (
			clk => clk,
			nReset => nReset,
			rst => rst,
			go => go,
			D => Tm,
			done => Tmdone
		);

	-- 2)	set (and reset) DIOR-/DIOW-
	T2proc: process(clk, nReset)
	begin
		if (nReset = '0') then
			DIOR <= '0';
			DIOW <= '0';
		elsif (clk'event and clk = '1') then
			if (rst = '1') then
				DIOR <= '0';
				DIOW <= '0';
			else
				DIOR <= (not we and Tmdone) or (DIOR and not Tddone);
				DIOW <= (    we and Tmdone) or (DIOW and not Tddone);
			end if;
		end if;
	end process T2proc;

	-- 3)	hookup Td counter
	td_cnt : ro_cnt
		generic map (
			SIZE => TWIDTH,
			UD   => '0',
			ID   => DMA_mode0_Td
		)
		port map (
			clk => clk,
			nReset => nReset,
			rst => rst,
			go => Tmdone,
			D => Td,
			done => Tddone
		);

	-- generate data_strobe
	gen_dstrb: process(clk)
	begin
		if (clk'event and clk = '1') then
			dstrb <= Tddone; -- capture data at rising edge of DIOR-
		end if;
	end process gen_dstrb;

	-- 4) negate DIOR-/DIOW- when Tddone
	-- 5)	hookup end_of_cycle counter
	eoc_cnt : ro_cnt 
		generic map (
			SIZE => TWIDTH,
			UD   => '0',
			ID   => DMA_mode0_Teoc
		)
		port map (
			clk => clk,
			nReset => nReset,
			rst => rst,
			go => Tddone,
			D => Teoc,
			done => done
		);
end architecture structural;
