---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  ATA/ATAPI-5 PIO controller with write PingPong             ----
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

-- rev.: 1.0 march 8th, 2001. Initial release
--
--  CVS Log
--
--  $Id: atahost_pio_controller.vhd,v 1.1 2002/02/18 14:32:12 rherveille Exp $
--
--  $Date: 2002/02/18 14:32:12 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: atahost_pio_controller.vhd,v $
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity atahost_pio_controller is
	generic(
		TWIDTH : natural := 8;                        -- counter width

		-- PIO mode 0 settings (@100MHz clock)
		PIO_mode0_T1 : natural := 6;                  -- 70ns
		PIO_mode0_T2 : natural := 28;                 -- 290ns
		PIO_mode0_T4 : natural := 2;                  -- 30ns
		PIO_mode0_Teoc : natural := 23                -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
	);
	port(
		clk    : in std_logic;  		                 	  -- master clock in
		nReset	: in std_logic;                 -- asynchronous active low reset
		rst    : in std_logic;                 -- synchronous active high reset
		
		-- control / registers
		IDEctrl_IDEen,
		IDEctrl_ppen,
		IDEctrl_FATR0,
		IDEctrl_FATR1 : in std_logic;

		-- PIO registers
		cmdport_T1,
		cmdport_T2,
		cmdport_T4,
		cmdport_Teoc : in std_logic_vector(7 downto 0);
		cmdport_IORDYen : in std_logic;               -- PIO command port / non-fast timing

		dport0_T1,
		dport0_T2,
		dport0_T4,
		dport0_Teoc : in std_logic_vector(7 downto 0);
		dport0_IORDYen : in std_logic;                -- PIO mode data-port / fast timing device 0

		dport1_T1,
		dport1_T2,
		dport1_T4,
		dport1_Teoc : in std_logic_vector(7 downto 0);
		dport1_IORDYen : in std_logic;                -- PIO mode data-port / fast timing device 1

		sel : in  std_logic;                          -- PIO controller selected
		ack : out std_logic;                          -- PIO controller acknowledge
		a   : in  std_logic_vector(3 downto 0);               -- lower address bits
		we  : in  std_logic;                          -- write enable input
		d   : in  std_logic_vector(15 downto 0);
		q   : out std_logic_vector(15 downto 0);

		PIOreq : out std_logic;                       -- PIO transfer request
		PPFull : out std_logic;                       -- PIO Write PingPong Full
		go     : in std_logic;                        -- start PIO transfer
		done   : out std_logic;                    -- done with PIO transfer

		PIOa : out std_logic_vector(3 downto 0);              -- PIO address, address lines towards ATA devices
		PIOd : out std_logic_vector(15 downto 0);     -- PIO data, data towards ATA devices

		SelDev : out std_logic;                    -- Selected Device, Dev-bit in ATA Device/Head register

		DDi	 : in std_logic_vector(15 downto 0);
		DDoe : out std_logic;

		DIOR	 : out std_logic;
		DIOW	 : out std_logic;
		IORDY	: in std_logic
	);
end entity atahost_pio_controller;

architecture structural of atahost_pio_controller is
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
	end component atahost_pio_actrl;

	--
	-- signals
	--

	-- PIO pingpong signals
	signal pp_d : std_logic_vector(15 downto 0);
	signal pp_a : std_logic_vector(3 downto 0);
	signal pp_we : std_logic;
	signal idone : std_logic;
	signal iSelDev : std_logic;

begin
	--
	-- generate selected device
	--
	gen_seldev: process(clk, pp_a)
		variable Asel : std_logic; -- address selected
	begin
		Asel := not pp_a(3) and pp_a(2) and pp_a(1) and not pp_a(0); -- header/device register

		if (clk'event and clk = '1') then
			if ( (idone = '1') and (Asel = '1') and (pp_we = '1') ) then
				iSelDev <= pp_d(4);
			end if;
		end if;
	end process gen_seldev;

	--
	-- generate PIO write pingpong system
	--
	gen_pingpong: block
		signal ping_d, pong_d : std_logic_vector(15 downto 0);
		signal ping_a, pong_a : std_logic_vector(3 downto 0);
		signal ping_we, pong_we : std_logic;
		signal ping_valid, pong_valid : std_logic;
		signal dping_valid, dpong_valid : std_logic;
		signal wpp, rpp : std_logic;

		signal dsel, sel_strb : std_logic;

		signal iack : std_logic;
	begin
		-- generate PIO acknowledge
		gen_ack: process(clk, ping_valid, dping_valid, pong_valid, dpong_valid, we)
			variable ping_re, ping_fe, pong_re, pong_fe : std_logic;
		begin
			-- detect rising edge of ping_valid and pong_valid
			ping_re := ping_valid and not dping_valid and we;
			pong_re := pong_valid and not dpong_valid and we;

			-- detect falling edge of ping_valid and pong_valid
			ping_fe := not ping_valid and dping_valid;
			pong_fe := not pong_valid and dpong_valid;

			if (clk'event and clk = '1') then
				if ((pp_we = '1') and (IDEctrl_ppen = '1')) then -- write sequence
					if (wpp = '1') then
						iack <= ping_re;
					else
						iack <= pong_re;
					end if;
				else                                           -- read sequence
					if (rpp = '1') then
						iack <= ping_fe;
					else
						iack <= pong_fe;
					end if;
				end if;
			end if;
		end process gen_ack;
		ack <= (iack or not IDEctrl_IDEen) and sel; -- acknowledge access when not enabled (discard access)

		-- generate select-strobe, hold sel_strb until pingpong system ready for new data
		gen_sel_strb: process(clk, nReset)
		begin
			if (nReset = '0') then
				dsel <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					dsel <= '0';
				else
					dsel <= sel_strb or (dsel and sel);
				end if;
			end if;
		end process gen_sel_strb;
		sel_strb <= sel and not dsel and IDEctrl_IDEen and ((wpp and not ping_valid) or (not wpp and not pong_valid));

		-- generate pingpong control
		gen_pp : process(clk, nReset)
		begin
			if (nReset = '0') then
				wpp <= '0';
				rpp <= '0';
				ping_valid <= '0';
				pong_valid <= '0';
				dping_valid <= '0';
				dpong_valid <= '0';
			elsif (clk'event and clk = '1') then
				if (rst = '1') then
					wpp <= '0';
					rpp <= '0';
					ping_valid <= '0';
					pong_valid <= '0';
					dping_valid <= '0';
					dpong_valid <= '0';
				else
					wpp <= (wpp xor (iack and we)) and IDEctrl_ppen;
					rpp <= (rpp xor (idone and pp_we)) and IDEctrl_ppen;
					ping_valid <= ((    wpp and sel_strb) or ping_valid) and not (    rpp and idone);
					pong_valid <= ((not wpp and sel_strb) or pong_valid) and not (not rpp and idone);
					dping_valid <= ping_valid;
					dpong_valid <= pong_valid;
				end if;
			end if;
		end process gen_pp;
		
		-- generate pingpong full signal
		PPFull <= (ping_valid and pong_valid) when (IDEctrl_ppen = '1') else pong_valid;

		-- fill ping/pong registers
		fill_pp: process(clk)
		begin
			if (clk'event and clk = '1') then
				if (sel = '1') then
					if (wpp = '1') then
						if (ping_valid = '0') then
							ping_d <= d;
							ping_a <= a;
							ping_we <= we;
						end if;
					else
						if (pong_valid = '0') then
							pong_d <= d;
							pong_a <= a;
							pong_we <= we;
						end if;
					end if;
				end if;
			end if;
		end process fill_pp;

		-- multiplex pingpong data to pp_d, pp_a, pp_we
		pp_d <= d;
		pp_a <= a;
		pp_we <= we;

--edit by erik (no pp)
--		pp_d <= ping_d when (rpp = '1') else pong_d;
--		pp_a <= ping_a when (rpp = '1') else pong_a;
--		pp_we <= ping_we when (rpp = '1') else pong_we;
		-- generate PIOreq
		PIOreq <= (ping_valid and not idone) when (rpp = '1') else (pong_valid and not idone);
	end block gen_pingpong;

	--
	-- Hookup PIO access controller
	--
	PIO_access_control: atahost_pio_actrl
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
			cmdport_T1   => cmdport_T1,
			cmdport_T2   => cmdport_T2,
			cmdport_T4   => cmdport_T4,
			cmdport_Teoc => cmdport_Teoc,
			cmdport_IORDYen => cmdport_IORDYen,
			dport0_T1   => dport0_T1,
			dport0_T2   => dport0_T2,
			dport0_T4   => dport0_T4,
			dport0_Teoc => dport0_Teoc,
			dport0_IORDYen => dport0_IORDYen,
			dport1_T1   => dport1_T1,
			dport1_T2   => dport1_T2,
			dport1_T4   => dport1_T4,
			dport1_Teoc => dport1_Teoc,
			dport1_IORDYen => dport1_IORDYen,
			SelDev => iSelDev,
			go     => go,
			done   => idone,
			dir    => pp_we,
			a      => pp_a,
			q      => Q,
			DDi    => DDi,
			oe     => DDoe,
			DIOR   => dior,
			DIOW   => diow,
			IORDY  => IORDY
		);

	--
	-- assign outputs
	--
	PIOa <= pp_a;
	PIOd <= pp_d;
	Done <= idone;
	SelDev <= iSelDev;
end architecture structural;

