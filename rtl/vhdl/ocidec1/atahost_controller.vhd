---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller (OCIDEC-1)                        ----
----  PIO Contoller                                              ----
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

-- rev.: 1.0  march 18th, 2001
-- rev.: 1.0a april 12th, 2001. Removed references to records.vhd to make it compatible with freely available VHDL to Verilog converter tools
-- rev.: 1.1  june  18th, 2001. Changed PIOack generation. Avoid asserting PIOack continuously when IDEen = '0'
-- rev.: 1.2  june  26th, 2001. Changed dPIOreq generation. Core did not support wishbone burst accesses to ATA-device.
-- rev.: 1.3  july  11th, 2001. Changed PIOreq & PIOack generation (made them synchronous). 
--
--
--  CVS Log
--
--  $Id: atahost_controller.vhd,v 1.2 2002-05-19 06:06:48 rherveille Exp $
--
--  $Date: 2002-05-19 06:06:48 $
--  $Revision: 1.2 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: not supported by cvs2svn $
--


-- OCIDEC1 supports:	
-- -Common Compatible timing access to all connected devices
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity atahost_controller is
	generic(
		TWIDTH : natural := 8;                        -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;                  -- 70ns
		PIO_mode0_T2 : natural := 28;                 -- 290ns
		PIO_mode0_T4 : natural := 2;                  -- 30ns
		PIO_mode0_Teoc : natural := 23                -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
	);
	port(
		clk : in std_logic;                           -- master clock in
		nReset : in std_logic := '1';                 -- asynchronous active low reset
		rst : in std_logic := '0';                    -- synchronous active high reset
		
		irq : out std_logic;                          -- interrupt request signal

		-- control / registers
		IDEctrl_rst,
		IDEctrl_IDEen : in std_logic;

		-- PIO registers
		PIO_cmdport_T1,
		PIO_cmdport_T2,
		PIO_cmdport_T4,
		PIO_cmdport_Teoc : in unsigned(7 downto 0);   -- PIO command timing
		PIO_cmdport_IORDYen : in std_logic;

		PIOreq : in std_logic;                        -- PIO transfer request
		PIOack : buffer std_logic;                    -- PIO transfer ended
		PIOa   : in unsigned(3 downto 0);             -- PIO address
		PIOd   : in std_logic_vector(15 downto 0);    -- PIO data in
		PIOq   : out std_logic_vector(15 downto 0);   -- PIO data out
		PIOwe  : in std_logic;                        -- PIO direction bit '1'=write, '0'=read

		-- ATA signals
		RESETn : out std_logic;
		DDi  	 : in std_logic_vector(15 downto 0);
		DDo    : out std_logic_vector(15 downto 0);
		DDoe   : out std_logic;
		DA     : out unsigned(2 downto 0);
		CS0n   : out std_logic;
		CS1n   : out std_logic;

		DIORn	: out std_logic;
		DIOWn	: out std_logic;
		IORDY	: in std_logic;
		INTRQ	: in std_logic
	);
end entity atahost_controller;

architecture structural of atahost_controller is
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
		clk : in std_logic;                      -- master clock
		nReset : in std_logic;                   -- asynchronous active low reset
		rst : in std_logic;                      -- synchronous active high reset

		-- timing/control register settings
		IORDY_en : in std_logic;                 -- use IORDY (or not)
		T1 : in unsigned(TWIDTH -1 downto 0);    -- T1 time (in clk-ticks)
		T2 : in unsigned(TWIDTH -1 downto 0);    -- T2 time (in clk-ticks)
		T4 : in unsigned(TWIDTH -1 downto 0);    -- T4 time (in clk-ticks)
		Teoc : in unsigned(TWIDTH -1 downto 0);  -- end of cycle time

		-- control signals
		go : in std_logic;                       -- PIO controller selected (strobe signal)
		we : in std_logic;                       -- write enable signal. '0'=read from device, '1'=write to device

		-- return signals
		oe :  buffer std_logic;                  -- output enable signal
		done : out std_logic;                    -- finished cycle
		dstrb : out std_logic;                   -- data strobe, latch data (during read)

		-- ATA signals
		DIOR,                                    -- IOread signal, active high
		DIOW : buffer std_logic;                 -- IOwrite signal, active high
		IORDY : in std_logic                     -- IORDY signal
	);
	end component atahost_pio_tctrl;

	--
	-- signals
	--
	signal dPIOreq, PIOgo : std_logic;              -- start PIO timing controller
	signal PIOdone : std_logic;                     -- PIO timing controller done

	-- PIO signals
	signal PIOdior, PIOdiow : std_logic;
	signal PIOoe : std_logic;

	-- Timing settings
	signal dstrb : std_logic;
	signal T1, T2, T4, Teoc : unsigned(TWIDTH -1 downto 0);
	signal IORDYen : std_logic;

	-- synchronized ATA inputs
	signal sIORDY : std_logic;

begin

	--
	-- synchronize incoming signals
	--
	synch_incoming: block
		signal cIORDY : std_logic;                   -- capture IORDY
		signal cINTRQ : std_logic;                   -- capture INTRQ
	begin
		process(clk)
		begin
			if (clk'event and clk = '1') then
				cIORDY <= IORDY;
				cINTRQ <= INTRQ;

				sIORDY <= cIORDY;
				irq <= cINTRQ;
			end if;
		end process;
	end block synch_incoming;

	--
	-- generate ATA signals
	--
	gen_ata_sigs: block
	begin
		-- generate registers for ATA signals
		gen_regs: process(clk, nReset)
		begin
			if (nReset = '0') then
				RESETn <= '0';
				DIORn  <= '1';
				DIOWn  <= '1';
				DA     <= (others => '0');
				CS0n  	<= '1';
				CS1n	  <= '1';
				DDo    <= (others => '0');
				DDoe   <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					RESETn <= '0';
					DIORn  <= '1';
					DIOWn  <= '1';
					DA     <= (others => '0');
					CS0n	  <= '1';
					CS1n	  <= '1';
					DDo    <= (others => '0');
					DDoe   <= '0';
				else
					RESETn <= not IDEctrl_rst;
					DA     <= PIOa(2 downto 0);
					CS0n	  <= not (not PIOa(3) and PIOreq); -- CS0 asserted when A(3) = '0'
					CS1n	  <= not (    PIOa(3) and PIOreq); -- CS1 asserted when A(3) = '1'

					DDo    <= PIOd;
					DDoe   <= PIOoe;
					DIORn  <= not PIOdior;
					DIOWn  <= not PIOdiow;
				end if;
			end if;
		end process gen_regs;
	end block gen_ata_sigs;


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
				PIOq <= DDi;
			end if;
		end if;
	end process gen_PIOq;

	-- generate PIOgo signal
	gen_PIOgo: process(clk, nReset)
	begin
		if (nReset = '0') then
			dPIOreq <= '0';
			PIOgo   <= '0';
		elsif (clk'event and clk = '1') then
			if (rst = '1') then
				dPIOreq <= '0';
				PIOgo   <= '0';
			else
				dPIOreq <= PIOreq and not PIOack;
				PIOgo   <= (PIOreq and not dPIOreq) and IDEctrl_IDEen;
			end if;
	end
	end process gen_PIOgo;

	-- set Timing signals
	T1      <= PIO_cmdport_T1;
	T2      <= PIO_cmdport_T2;
	T4      <= PIO_cmdport_T4;
	Teoc    <= PIO_cmdport_Teoc;
	IORDYen <= PIO_cmdport_IORDYen;

	--
	-- hookup timing controller
	--
	PIO_timing_controller: atahost_pio_tctrl
		generic map (
			TWIDTH         => TWIDTH,
			PIO_mode0_T1   => PIO_mode0_T1,
			PIO_mode0_T2   => PIO_mode0_T2,
			PIO_mode0_T4   => PIO_mode0_T4,
			PIO_mode0_Teoc => PIO_mode0_Teoc
		)
		port map (
			clk      => clk,
			nReset   => nReset,
			rst      => rst,
			IORDY_en => IORDYen,
			T1       => T1,
			T2       => T2,
			T4       => T4,
			Teoc     => Teoc, 
			go       => PIOgo,
			we       => PIOwe,
			oe       => PIOoe,
			done     => PIOdone,
			dstrb    => dstrb,
			DIOR     => PIOdior,
			DIOW     => PIOdiow,
			IORDY    => sIORDY
		);

	-- generate acknowledge
	gen_ack: process(clk)
	begin
		if (clk'event and clk = '1') then
			PIOack <= PIOdone or (PIOreq and not IDEctrl_IDEen); -- acknowledge when done or when IDE not enabled (discard request)
		end if;
	end process gen_ack;
end architecture structural;

