---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  ATA/ATAPI-5 Controller (OCIDEC-2)                          ----
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

-- rev.: 1.0  march 18th, 2001. Initial release
-- rev.: 1.0a april 12th, 2001. Removed references to records.vhd
-- rev.: 1.1  june  18th, 2001. Changed PIOack generation. Avoid asserting PIOack continuously when IDEen = '0'
-- rev.: 1.2  june  26th, 2001. Changed dPIOreq generation. Core did not support wishbone burst accesses to ATA-device.
-- rev.: 1.3  july  11th, 2001. Changed PIOreq & PIOack generation (made them synchronous). 
--
--  CVS Log
--
--  $Id: atahost_controller.vhd,v 1.2 2002/05/19 06:07:09 rherveille Exp $
--
--  $Date: 2002/05/19 06:07:09 $
--  $Revision: 1.2 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: atahost_controller.vhd,v $
--               Revision 1.2  2002/05/19 06:07:09  rherveille
--               Fixed a potential bug where the core was forced into an unknown state
--               when an asynchronous reset was given without a running clock.
--
--

--
-- OCIDEC2 supports:	
-- -Common Compatible timing access to all connected devices
--	-Separate timing accesses to data port
-- -No DMA support

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ocidec2_controller is
	generic(
		TWIDTH : natural := 8;                   -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;             -- 70ns
		PIO_mode0_T2 : natural := 28;            -- 290ns
		PIO_mode0_T4 : natural := 2;             -- 30ns
		PIO_mode0_Teoc : natural := 23           -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
	);
	port(
		clk    : in std_logic;  		                    	  -- master clock in
		nReset	: in std_logic := '1';                 -- asynchronous active low reset
		rst    : in std_logic := '0';                    -- synchronous active high reset
		
		irq : out std_logic;                          -- interrupt request signal

		-- control / registers
		IDEctrl_rst,
		IDEctrl_IDEen,
		IDEctrl_FATR0,
		IDEctrl_FATR1 : in std_logic;

		-- PIO registers
		cmdport_T1,
		cmdport_T2,
		cmdport_T4,
		cmdport_Teoc : in std_logic_vector(7 downto 0);
		cmdport_IORDYen : in std_logic;             -- PIO command port / non-fast timing

		dport0_T1,
		dport0_T2,
		dport0_T4,
		dport0_Teoc : in std_logic_vector(7 downto 0);
		dport0_IORDYen : in std_logic;              -- PIO mode data-port / fast timing device 0

		dport1_T1,
		dport1_T2,
		dport1_T4,
		dport1_Teoc : in std_logic_vector(7 downto 0);
		dport1_IORDYen : in std_logic;              -- PIO mode data-port / fast timing device 1

		PIOreq : in std_logic;                      -- PIO transfer request
		PIOack : out std_logic;                  -- PIO transfer ended
		PIOa   : in std_logic_vector(3 downto 0);           -- PIO address
		PIOd   : in std_logic_vector(15 downto 0);  -- PIO data in
		PIOq   : out std_logic_vector(15 downto 0); -- PIO data out
		PIOwe  : in std_logic;                      -- PIO direction bit '1'=write, '0'=read

		-- ATA signals
		RESETn	: out std_logic;
		DDi	 : in std_logic_vector(15 downto 0);
		DDo  : out std_logic_vector(15 downto 0);
		DDoe : out std_logic;
		DA	  : out std_logic_vector(2 downto 0);
		CS0n	: out std_logic;
		CS1n	: out std_logic;

		DIORn	: out std_logic;
		DIOWn	: out std_logic;
		IORDY	: in std_logic;
		INTRQ	: in std_logic
	);
end entity ocidec2_controller;

architecture structural of ocidec2_controller is
	--
	-- component declarations
	--
	component atahost_pio_actrl is
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
		a    : in  std_logic_vector(3 downto 0);           -- PIO transfer address
		q    : out std_logic_vector(15 downto 0);  -- Data read from ATA devices

		DDi : in std_logic_vector(15 downto 0);    -- Data from ATA DD bus
		oe  : out std_logic;                    -- DDbus output-enable signal

		DIOR,
		DIOW  : out std_logic;
		IORDY : in std_logic 
	);
	end component;

	--
	-- signals
	--
	signal SelDev : std_logic;                      -- selected device

	signal dPIOreq, PIOgo : std_logic;              -- start PIO timing controller
	signal PIOdone : std_logic;                     -- PIO timing controller done

	-- PIO signals
	signal PIOdior, PIOdiow : std_logic;
	signal PIOoe   : std_logic;
   	signal rPIOack : std_logic; 
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
				irq    <= cINTRQ;
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
				CS0n	  <= '1';
				CS1n	  <= '1';
				DDo    <= (others => '0');
				DDoe   <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					RESETn <= '0';
					DIORn  <= '1';
					DIOWn  <= '1';
					DA     <= (others => '0');
					CS0n   <= '1';
					CS1n  	<= '1';
					DDo    <= (others => '0');
					DDoe   <= '0';
				else
					RESETn <= not IDEctrl_rst;
					DA   <= PIOa(2 downto 0);
					CS0n	<= not (not PIOa(3) and PIOreq); -- CS0 asserted when A(3) = '0'
					CS1n	<= not (    PIOa(3) and PIOreq); -- CS1 asserted when A(3) = '1'

					DDo   <= PIOd;
					DDoe  <= PIOoe;
					DIORn <= not PIOdior;
					DIOWn <= not PIOdiow;
				end if;
			end if;
		end process gen_regs;
	end block gen_ata_sigs;

	--
	-- generate selected device
	--
	gen_seldev: process(clk)
		variable Asel : std_logic; -- address selected
	begin
		if (clk'event and clk = '1') then
			Asel := not PIOa(3) and PIOa(2) and PIOa(1) and not PIOa(0); -- header/device register
			if ( (PIOdone = '1') and (Asel = '1') and (PIOwe = '1') ) then
				SelDev <= PIOd(4);
			end if;
		end if;
	end process gen_seldev;

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
				dPIOreq <= PIOreq and not rPIOack;
				PIOgo   <= (PIOreq and not dPIOreq) and IDEctrl_IDEen;
			end if;
	end if;
	end process gen_PIOgo;
	--
	-- Hookup PIO access controller
	--
	pio_access_control: atahost_pio_actrl
		generic map(
			TWIDTH => TWIDTH,
			PIO_mode0_T1 => PIO_mode0_T1,
			PIO_mode0_T2 => PIO_mode0_T2,
			PIO_mode0_T4 => PIO_mode0_T4,
			PIO_mode0_Teoc => PIO_mode0_Teoc
		)
		port map(
			clk    => clk,
			nReset => nReset,
			rst    => rst,
			IDEctrl_FATR0 => IDEctrl_FATR0,
			IDEctrl_FATR1 => IDEctrl_FATR1,
			cmdport_T1    => cmdport_T1,
			cmdport_T2    => cmdport_T2,
			cmdport_T4    => cmdport_T4,
			cmdport_Teoc  => cmdport_Teoc,
			cmdport_IORDYen => cmdport_IORDYen,
			dport0_T1     => dport0_T1,
			dport0_T2     => dport0_T2,
			dport0_T4     => dport0_T4,
			dport0_Teoc   => dport0_Teoc,
			dport0_IORDYen => dport0_IORDYen,
			dport1_T1     => dport1_T1,
			dport1_T2     => dport1_T2,
			dport1_T4     => dport1_T4,
			dport1_Teoc   => dport1_Teoc,
			dport1_IORDYen => dport1_IORDYen, 
			SelDev => SelDev,
			go     => PIOgo,
			done   => PIOdone,
			dir    => PIOwe,
			a      => PIOa,
			q      => PIOq,
			DDi    => DDi,
			oe     => PIOoe,
			DIOR   => PIOdior,
			DIOW   => PIOdiow,
			IORDY  => sIORDY
		);

	-- generate acknowledge
	gen_ack: process(clk)
	begin
		if (clk'event and clk = '1') then
			rPIOack <= PIOdone or (PIOreq and not IDEctrl_IDEen); -- acknowledge when done or when IDE not enabled (discard request)
		end if;
	   PIOack <= rPIOack;
   end process gen_ack;
end architecture structural;

