---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  PIO Access Controller (common for OCIDEC 2 and above)      ----
----                                                             ----
----  Author: Richard Herveille                                  ----
----          richard@asics.ws                                   ----
----          www.asics.ws                                       ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2001, 2002 Richard Herveille                  ----
----                          richard@asics.ws                   ---
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

-- rev.: 1.0 march 9th, 2001
-- rev.: 1.0a april 12th, 2001 Removed references to records.vhd
--
--
--  CVS Log
--
--  $Id: atahost_pio_actrl.vhd,v 1.1 2002/02/18 14:32:12 rherveille Exp $
--
--  $Date: 2002/02/18 14:32:12 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: atahost_pio_actrl.vhd,v $
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
---------------------------
-- PIO Access controller --
---------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity atahost_pio_actrl is
	generic(
		TWIDTH : natural := 8;                     -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;               -- 70ns
		PIO_mode0_T2 : natural := 28;              -- 290ns
		PIO_mode0_T4 : natural := 2;               -- 30ns
		PIO_mode0_Teoc : natural := 23             -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
	);
	port(
		clk    : in std_logic;                     -- master clock
		nReset : in std_logic;                     -- asynchronous active low reset
		rst    : in std_logic;                     -- synchronous active high reset

		IDEctrl_FATR0,
		IDEctrl_FATR1 : in std_logic;

		cmdport_T1,
		cmdport_T2,
		cmdport_T4,
		cmdport_Teoc : in std_logic_vector(7 downto 0);
		cmdport_IORDYen : in std_logic;            -- PIO command port / non-fast timing

		dport0_T1,
		dport0_T2,
		dport0_T4,
		dport0_Teoc : in std_logic_vector(7 downto 0);
		dport0_IORDYen : in std_logic;             -- PIO mode data-port / fast timing device 0

		dport1_T1,
		dport1_T2,
		dport1_T4,
		dport1_Teoc : in std_logic_vector(7 downto 0);
		dport1_IORDYen : in std_logic;             -- PIO mode data-port / fast timing device 1

		SelDev : in std_logic;                     -- Selected device	

		go   : in  std_logic;                      -- Start transfer sequence
		done : out std_logic;                      -- Transfer sequence done
		dir  : in  std_logic;                      -- Transfer direction '1'=write, '0'=read
		a    : in  std_logic_vector(3 downto 0):="0000";           -- PIO transfer address
		q    : out std_logic_vector(15 downto 0);  -- Data read from ATA devices

		DDi : in std_logic_vector(15 downto 0);    -- Data from ATA DD bus
		oe  : out std_logic;                    -- DDbus output-enable signal

		DIOR,
		DIOW  : out std_logic;
		IORDY : in std_logic 
	);
end entity atahost_pio_actrl;

architecture structural of atahost_pio_actrl is
	--
	-- Component declarations
	--
	component atahost_pio_tctrl is	
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
	end component atahost_pio_tctrl;

	signal dstrb : std_logic;
	signal T1, T2, T4, Teoc : std_logic_vector(TWIDTH -1 downto 0);
	signal IORDYen : std_logic;

begin
	--
	--------------------------
	-- PIO transfer control --
	--------------------------
	--
	-- capture ATA data for PIO access
	gen_PIOq: process(clk)
	begin
		if (clk'event and clk = '1') then
			if (dstrb = '1') then
				q <= DDi;
			end if;
		end if;
	end process gen_PIOq;

	--
	-- PIO timing controllers
	--

	-- select timing settings for the addressed port
	sel_port_t: process(clk)
		variable Asel : std_logic; -- address selected
		variable iT1, iT2, iT4, iTeoc : std_logic_vector(TWIDTH -1 downto 0);
		variable iIORDYen : std_logic;
	begin
	    if (clk'event and clk = '1') then
		-- initially set timing registers to compatible timing
		iT1      := cmdport_T1;
		iT2      := cmdport_T2;
		iT4      := cmdport_T4;
		iTeoc    := cmdport_Teoc;
		iIORDYen := cmdport_IORDYen;

		-- detect data-port access
		Asel := not a(3) and not a(2) and not a(1) and not a(0); -- data port
		if (Asel = '1') then                                     -- data port selected, 16bit transfers
			if ((SelDev = '1') and (IDEctrl_FATR1 = '1')) then    -- data port1 selected and enabled ?
				iT1      := dport1_T1;
				iT2      := dport1_T2;
				iT4      := dport1_T4;
				iTeoc    := dport1_Teoc;
				iIORDYen := dport1_IORDYen;
			elsif((SelDev = '0') and (IDEctrl_FATR0 = '1')) then       -- data port0 selected and enabled ?
				iT1      := dport0_T1;
				iT2      := dport0_T2;
				iT4      := dport0_T4;
				iTeoc    := dport0_Teoc;
				iIORDYen := dport0_IORDYen;
			end if;
		end if;

		T1      <= iT1;
		T2      <= iT2;
		T4      <= iT4;
		Teoc    <= iTeoc;
		IORDYen <= iIORDYen;
	    end if;
	end process sel_port_t;

	--
	-- hookup timing controller
	--
	PIO_timing_controller: atahost_pio_tctrl
		generic map (
			TWIDTH => TWIDTH,
			PIO_mode0_T1 => PIO_mode0_T1,
			PIO_mode0_T2 => PIO_mode0_T2,
			PIO_mode0_T4 => PIO_mode0_T4,
			PIO_mode0_Teoc => PIO_mode0_Teoc
		)
		port map (
			clk => clk,
			nReset => nReset,
			rst => rst,
			IORDY_en => IORDYen,
			T1 => T1,
			T2 => T2,
			T4 => T4,
			Teoc => Teoc, 
			go => go,
			we => dir,
			oe => oe,
			done => done,
			dstrb => dstrb,
			DIOR => dior,
			DIOW => diow,
			IORDY => IORDY
		);
end architecture structural;

