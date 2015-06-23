--+------------------------------------------------------------------+
--|																						|
--|	PCI_TARGET -> Wishbone_MASTER interface (PCI_to_WB) v1.9			|
--|																						|
--|	The first, original PCI module is from:								|
--|	Ben Jackson, http://www.ben.com/minipci/verilog.php				|
--|																						|
--|	The second, modified module "pci_mini" is from:						|
--|	Istvan Nagy, buenos@freemail.hu											|
--|																						|
--|																						|
--|	DOWNLOADED FROM OPENCORES. License = LGPL.							|
--|																						|
--+------------------------------------------------------------------+
--|	I used the code of the original pci_mini module to create		|
--|	a PCI to WB interface with direct read accesses (not				|
--|	like before, where data would be available only on					|
--|	a second PCI read) because that didn't work in my system.		|
--|	Thanks to Ben Jackson and Istvan Nagy for their works!			|
--|	I would not have been able to design such a core without			|
--|	the provided code base.														|
--|	Nelson Scheja (Lord_Nelson@opencores.org).							|
--+------------------------------------------------------------------+----------------------------+
-- ########## General info ##########

-- The core implements a 16 MB memory image which is relocable on the WB bus:
-- WB_address = 4 * baseaddr + PCI_addr[23:2], where baseaddr is the WB image relocation
-- register (BAR0).
-- Only Dword aligned Dword accesses are allowed on the PCI. This way we can have access to the
-- full 32 bit WB address space through a 16 MB PCI window. The addressing on the WB bus is
-- Dword addressing, while on the PCI bus, it is byte addressing: PCI_addr / 4 = WB_address.
-- That means, when the PCI address is increasing by 4 ( = 4 Bytes = 1 Dword), the WB address
-- is increasing by 1 ( = 1 Dword, too).

-- Nearly full Wishbone compatible; single exception is master arbitration (through signals
-- wb_req and wb_gnt) which is not implemented.

-- (Remember, most PCI signals are active low, so I call them "asserted" when they are 0!
-- Only exceptions are clk, idsel and par, which are active high.)

-- The duration of a complete PCI cycle depends on the PCI command and the reaction time of the
-- PCI master and the addressed WB slave. Generally, Memory Reads need the most time to complete
-- (as the data path is the longest), and Config Writes are fastest.


-- ########## PCI bus support ##########

-- Intended PCI operation mode is 33 MHz, 32 bit.

-- Supported PCI commands are Config Read / Write, Memory Read / Write. Only single Dword
-- accesses are supported. (As the cbe bits are ignored for MemRead and MemWrite, a full DWord
-- is always transferred on these commands. Still, Byte or Word accesses are not recommended.)

-- The core supports only single reads / writes, that means only one data phase per PCI
-- cycle. Bursts are not allowed. In the first data phase, it asserts the stop signal
-- together with trdy to enforce a so-called "target initiated disconnect". This makes sure
-- that the PCI master will never try to extend a cycle past the first data phase.

-- When no WB response has been sent for WB_MAX_LAT clock cycles during a MemRead or MemWrite,
-- the core signals "Target-Abort" to the master. WB_MAX_LAT is user-definable in the range
-- from 0h to Fh.

-- DEVSEL timing is "fast". That means, devsel will be asserted the next clock edge after the
-- assertion of frame.

-- Parity of outgoing data is generated (one clock cycle after driving the ad lines). Parity
-- check of incoming address/data is not implemented. Thus, perr is held in high impedance the
-- whole time.

-- System Error indication is not implemented, thus serr is high impedance the whole time.


-- ########## Wishbone bus support ##########

-- Implemented Wishbone signals: wb_adr_o, wb_dat_o, wb_dat_i, wb_sel_o, wb_cyc_o, wb_stb_o,
-- 	wb_we_o, wb_ack_i, wb_err_i.
-- Not implemented Wishbone signals: clk, rst, rty, req, gnt, lock, stall, tag signals.

-- The signals wb_rst and wb_clk are not generated as this is actually the job of the Syscon
-- module and should be done outside this core. Still, it could come in handy to use the core
-- also as Syscon, so these two ports and their processes are only commented out and can be
-- quickly reactivated if necessary.

-- Attention! The core was intended for a Wishbone bus scenario where it is the only master.
-- Thus, no arbitration methods are supported, which actually is not 100% WB compatible. Do not
-- put another master on the same WB bus as this core! The advantage is fewer logic units and
-- faster bus cycles (because the core asserts wb_cyc and wb_stb at the same time and doesn't
-- have to wait for a grant in between).

-- Supported commands are single read / write. Pipelined mode is not supported.

-- All bits of the signal wb_sel are always driven high during normal operation because all WB
-- accesses use 4 Bytes. Only when reset is asserted, wb_sel = 0000.


-- ########## Device Compatibility ##########

-- The core was tested and used on a Xilinx Spartan3 XC3S1000 FT256-4. The PCI master was a
-- MPC5200 microcontroller.

-- There are no Xilinx-specific components defined in the code, so theoretically it should be
-- compatible to FPGAs of all developers.

-- Utilization (extract from Xilinx ISE Map Report): Slices 183; Slice Reg 143; LUTs 194.

-- The IEEE library numeric_std is used.


-- ########## Change log ##########

-- Merged PCI state machine, WB state machine and Address decoder into a single big process to
-- 	allow faster PCI reaction and reduce amount of signals.
-- Made the interrupt asynchronously to clk to ensure fastest possible interrupt generation.
-- In Config cycles, it is now paid attention to the Byte Enable bits cbe.
-- Target-Abort is generated when no response (ack or err) has come from the Wishbone for
-- 	WB_MAX_LAT clock cycles.
-- Completely modified the internal structure of the config signals.
-- Made the interrupt port information configurable via generic.
-- Removed everything that's got to do with interrupts, as an INTA pin is not mandatory for PCI
-- 	and WB has no definition of an interrupt request protocol.
-- Realized main_state signal (formerly pci_state) as an enum type and let it also control all
-- 	the sub states (deleted former sub_state).


-- ########## ToDos / Problems ##########

-- Implement parity check?
-- Implement WB byte select?
-- Check WB Timeout counter accuracy! Don't know whether the cycle count is perfectly correct.
-- Assertion of trdy and stop lasts for about 10 clock cycles when scoped in reality! Reason
-- 	unclear, maybe an effect due to the slow pullups?
-- Uncorrect handling of wb_err assertion (it seems)! Stop isn't asserted sometimes.
--+-----------------------------------------------------------------------------------------------+

library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


entity pci_to_wb is
	port(
			--PCI signals
		reset			: in  std_logic;
		clk			: in  std_logic;
		frame			: in  std_logic;
		irdy			: in  std_logic;
		trdy			: out std_logic;
		devsel		: out std_logic;
		idsel			: in  std_logic;
		ad				: inout std_logic_vector(31 downto 0) := (others => 'Z');
		cbe			: in  std_logic_vector(3 downto 0);
		par			: inout std_logic := 'Z';
		stop			: out std_logic;
		serr			: out std_logic;
		perr			: out std_logic;
			--Wishbone signals
		-- wb_clk_o		: out std_logic;				--uncomment these two signals and their corresponding processes at the
		-- wb_rst_o		: out std_logic;				--beginning of the architecture body to achieve syscon functionality
		wb_adr_o		: out std_logic_vector(31 downto 0);
		wb_dat_o		: out std_logic_vector(31 downto 0);
		wb_dat_i		: in  std_logic_vector(31 downto 0);
		wb_sel_o		: out std_logic_vector(3 downto 0) := "0000";
		wb_cyc_o		: out std_logic := '0';
		wb_stb_o		: out std_logic := '0';
		wb_we_o		: out std_logic := '0';
		wb_ack_i		: in  std_logic;
		wb_err_i		: in  std_logic
	);
end pci_to_wb;


architecture Behavioral of pci_to_wb is
	
	--+------------------------------------------------------------------------------------+
	--|												Constants													|
	--+------------------------------------------------------------------------------------+
	
		--user specific constants. Change them at your will.
	constant DEVICE_ID				: std_logic_vector := x"1337";	--It's leet. Yo.
	constant VENDOR_ID				: std_logic_vector := x"1234";
	constant DEVICE_CLASS			: std_logic_vector := x"118000";	--(068000=bridge/other, 078000=simple_comm_contr/other, 118000=data_acquisition/other)
	constant DEVICE_REV				: std_logic_vector := x"09";		--version of the PCI to WB module
	constant SUBSYSTEM_ID			: std_logic_vector := x"0001";	--card identifier
	constant SUBSYSTEM_VENDOR_ID	: std_logic_vector := x"9876";
	constant WB_MAX_LAT				: unsigned := x"4";					--defines how many clock cycles the WB has time to answer to wb_stb before Target-Abort is activated
	
		-- supported PCI commands
	constant CFGREAD					: std_logic_vector := "1010";
	constant CFGWRITE					: std_logic_vector := "1011";
	constant MEMREAD					: std_logic_vector := "0110";
	constant MEMWRITE					: std_logic_vector := "0111";
	
	
	--+------------------------------------------------------------------------------------+
	--|										Internal signals													|
	--+------------------------------------------------------------------------------------+
	
		-- state machine flow
	type main_state_type is (Idle, Cfg_read_1, Cfg_read_2, Cfg_write_1, Cfg_write_2,
									Mem_read_1, Mem_read_2, Mem_read_3, Mem_write_1, Mem_write_2, Mem_write_3);
	signal main_state		: main_state_type := Idle;
	signal wait_count		: unsigned(3 downto 0) := x"0";						--counts up to WB_MAX_LAT while waiting on WB response
	signal par_create		: std_logic := '0';										--controls the parity generator: when 1, parity is generated, else not
	
	signal pci_address	: std_logic_vector(23 downto 2);						--latch of AD lines during the address phase (upper 8 and lower 2 of the 32 bits are never used)
	
		-- configuration registers
	signal cfg_reg_0x00	: std_logic_vector(31 downto 0) := DEVICE_ID & VENDOR_ID;
	
	signal cfg_reg_0x04	: std_logic_vector(31 downto 0) := x"00000000";
	alias target_abort	: std_logic is cfg_reg_0x04(27);						--Target-Abort status bit (status register)
	alias mem_ena			: std_logic is cfg_reg_0x04(1);						--memory space enable bit (command register)
	
	signal cfg_reg_0x08	: std_logic_vector(31 downto 0) := DEVICE_CLASS & DEVICE_REV;
	
	signal cfg_reg_0x10	: std_logic_vector(31 downto 0) := x"00000000";
	alias baseaddr			: std_logic_vector(7 downto 0) is cfg_reg_0x10(31 downto 24);	--used for relocating the WB address space
	
	signal cfg_reg_0x2c	: std_logic_vector(31 downto 0) := SUBSYSTEM_ID & SUBSYSTEM_VENDOR_ID;
	
	
begin
	
	--+------------------------------------------------------------------------------------+
	--|									Small signal processes												|
	--+------------------------------------------------------------------------------------+
		--Wishbone clock and (asynchronous) reset:
	-- wb_clk_o		<= clk;								--uncomment these two processes and their corresponding
	-- wb_rst_o		<= not reset;						--signals in the entity to achieve syscon functionality
	
		--these are not used:
	serr				<= 'Z';
	perr				<= 'Z';
	
		--only dword accesses, so wb_sel can always be high (except during reset):
	process(reset)
	begin
		if reset = '0' then
			wb_sel_o			<= "0000";
		else
			wb_sel_o			<= "1111";
		end if;
	end process;
	
	
	--+------------------------------------------------------------------------------------+
	--|										MAIN STATE MACHINE												|
	--+------------------------------------------------------------------------------------+
	-- This process controls the translation from PCI protocol to Wishbone protocol.
	-- It is realized as a state machine with five main states (defined with main_state).
	-- Most main states are further divided into sub states (defined with sub_state)
	-- to control the flow of execution during a PCI cycle.
	process(reset, clk)
	begin
		if reset = '0' then
			main_state	<= Idle;
			
			ad				<= (others => 'Z');
			devsel		<= 'Z';
			trdy			<= 'Z';
			stop			<= 'Z';
			par_create	<= '0';
			wait_count	<= (others => '0');
			
			target_abort<= '0';
			mem_ena		<= '0';
			baseaddr		<= (others => '0');
			
			wb_adr_o		<= (others => '0');
			wb_dat_o		<= (others => '0');
			wb_cyc_o		<= '0';
			wb_stb_o		<= '0';
			wb_we_o		<= '0';
		elsif rising_edge(clk) then
			case main_state is
				
		-- ########## IDLE STATE ##########
		-- State for between PCI cycles and during the address phase (which is identified by the
		-- assertion of frame). While here, all signals to PCI, WB and internals are in deasserted
		-- state. When the core is being addressed correctly by the PCI master, it asserts devsel
		-- as response and changes to the state defined by the command bits (cbe).
				when Idle =>
					trdy				<= 'Z';
					stop				<= 'Z';
					devsel			<= 'Z';
					
					if frame = '0' then
						pci_address		<= ad(23 downto 2);
						if idsel = '1' and ad(10 downto 8) = "000" and ad(1 downto 0) = "00" then	--correct config space access
							if cbe = CFGREAD then
								devsel		<= '0';
								main_state	<= Cfg_read_1;
							elsif cbe = CFGWRITE then
								devsel		<= '0';
								main_state	<= Cfg_write_1;
							end if;
						elsif mem_ena = '1' and ad(31 downto 24) = baseaddr then							--correct memory space access
							if cbe = MEMREAD then
								devsel		<= '0';
								main_state	<= Mem_read_1;
							elsif cbe = MEMWRITE then
								devsel		<= '0';
								main_state	<= Mem_write_1;
							end if;
						end if;
					end if;
					
					
		-- ########## CFG READ STATE ##########
		-- The config register at the DWord address pci_address is read. Depending on the Byte Enables
		-- cbe, the data is provided on ad When cbe(0) = 0, then byte 0 is all zeroes, etc. One
		-- clock cycle later, the parity is provided and the PCI cycle is terminated.
				
				--STAGE 1: gather register data internally in the first clock cycle where irdy is asserted
				when Cfg_read_1 =>
					if irdy = '0' then
						case pci_address(7 downto 2) is
							when "000000" =>									--0d*4 = 00h. Device ID (31 - 16), Vendor ID (15 - 0).
								if cbe(3) = '0' then
									ad(31 downto 24)	<= cfg_reg_0x00(31 downto 24);
								else
									ad(31 downto 24)	<= (others => '0');
								end if;
								if cbe(2) = '0' then
									ad(23 downto 16)	<= cfg_reg_0x00(23 downto 16);
								else
									ad(23 downto 16)	<= (others => '0');
								end if;
								if cbe(1) = '0' then
									ad(15 downto 8)	<= cfg_reg_0x00(15 downto 8);
								else
									ad(15 downto 8)	<= (others => '0');
								end if;
								if cbe(0) = '0' then
									ad(7 downto 0)		<= cfg_reg_0x00(7 downto 0);
								else
									ad(7 downto 0)		<= (others => '0');
								end if;
							when "000001" =>									--1d*4 = 04h. Status (31 - 16), Command (15 - 0).
								if cbe(3) = '0' then
									ad(31 downto 24)	<= cfg_reg_0x04(31 downto 24);
								else
									ad(31 downto 24)	<= (others => '0');
								end if;
								ad(23 downto 8)		<= (others => '0');
								if cbe(0) = '0' then
									ad(7 downto 0)		<= cfg_reg_0x04(7 downto 0);
								else
									ad(7 downto 0)		<= (others => '0');
								end if;
							when "000010" =>									--2d*4 = 08h. Class Code (31 - 8), Revision ID (7 - 0).
								if cbe(3) = '0' then
									ad(31 downto 24)	<= cfg_reg_0x08(31 downto 24);
								else
									ad(31 downto 24)	<= (others => '0');
								end if;
								if cbe(2) = '0' then
									ad(23 downto 16)	<= cfg_reg_0x08(23 downto 16);
								else
									ad(23 downto 16)	<= (others => '0');
								end if;
								if cbe(1) = '0' then
									ad(15 downto 8)	<= cfg_reg_0x08(15 downto 8);
								else
									ad(15 downto 8)	<= (others => '0');
								end if;
								if cbe(0) = '0' then
									ad(7 downto 0)		<= cfg_reg_0x08(7 downto 0);
								else
									ad(7 downto 0)		<= (others => '0');
								end if;
							when "000100" =>									--4d*4 = 10h. Base Address Register 0, = baseaddr.
								if cbe(3) = '0' then
									ad(31 downto 24)	<= cfg_reg_0x10(31 downto 24);
								else
									ad(31 downto 24)	<= (others => '0');
								end if;
								ad(23 downto 0)		<= (others => '0');
							when "001011" =>									--11d*4 = 2Ch. Subsystem ID (31 - 16), Subsystem Vendor ID (15 - 0).
								if cbe(3) = '0' then
									ad(31 downto 24)	<= cfg_reg_0x2c(31 downto 24);
								else
									ad(31 downto 24)	<= (others => '0');
								end if;
								if cbe(2) = '0' then
									ad(23 downto 16)	<= cfg_reg_0x2c(23 downto 16);
								else
									ad(23 downto 16)	<= (others => '0');
								end if;
								if cbe(1) = '0' then
									ad(15 downto 8)	<= cfg_reg_0x2c(15 downto 8);
								else
									ad(15 downto 8)	<= (others => '0');
								end if;
								if cbe(0) = '0' then
									ad(7 downto 0)		<= cfg_reg_0x2c(7 downto 0);
								else
									ad(7 downto 0)		<= (others => '0');
								end if;
							when others =>					--unsupported or reserved config registers.
								ad							<= (others => '0');
						end case;
						
						trdy			<= '0';
						stop			<= '0';
						par_create	<= '1';
						main_state	<= Cfg_read_2;
					end if;
						
				--STAGE 2: one clock cycle later, end the PCI cycle
				when Cfg_read_2 =>
					ad				<= (others => 'Z');
					devsel		<= '1';
					trdy			<= '1';
					stop			<= '1';
					par_create	<= '0';
					main_state	<= Idle;
					
					
		-- ########## CFG WRITE STATE ##########
		-- The config register at the DWord address pci_address is written, depending on the Byte Enables
		-- cbe. Some bits are not writable, so nothing will be changed then. The status register
		-- is special: When writing a 1 onto a bit, this bit is cleared; writing a 0 will have no
		-- effect. One clock cycle later, the PCI cycle is terminated.
					
				-- STAGE 1: return config values in the first clock cycle where irdy is asserted
				when Cfg_write_1 =>
					trdy				<= '0';
					stop				<= '0';
					if irdy = '0' then
						case pci_address(7 downto 2) is
							when "000001" =>									--1d*4 = 04h. Status (31 - 16), Command (15 - 0).
								if cbe(3) = '0' and ad(27) = '1' then
									target_abort<= '0';						--reset status bit Target-Abort when writing a 1 there
								end if;
								if cbe(0) = '0' then
									mem_ena		<= ad(1);
								end if;
							when "000100" =>									--4d*4 = 10h. Base Address Register 0 (BAR0).
								if cbe(3) = '0' then
									baseaddr		<= ad(31 downto 24);
								end if;
							when others =>										--config registers that are reserved, unsupported or don't support writes.
								null;
						end case;
						main_state	<= Cfg_write_2;
					end if;
						
				--STAGE 2: one clock cycle later, end the PCI cycle
				when Cfg_write_2 =>
					devsel		<= '1';
					trdy			<= '1';
					stop			<= '1';
					main_state	<= Idle;
					
					
		-- ########## MEM READ STATE ##########
		-- The data to be written and the address is provided for the Wishbone bus. Then,
		-- wait for Wishbone response:
		-- When ack_i is asserted (= data ready), signal "Disconnect with data" to PCI master,
		-- 	provide the data and one clock cycle later the parity.
		-- When err_i is asserted (= access error), signal "Target-Abort". In this case, no
		-- 	data is provided and the third stage is not activated.
		-- When neither ack_i nor err_i were asserted for WB_MAX_LAT clock cycles, signal
		-- 	"Target-Abort". The third stage is not activated then, too.
				
				--STAGE 1: save address for Wishbone in the first clock cycle where irdy is asserted and initiate WB action
				when Mem_read_1 =>
					if irdy = '0' then
						wb_adr_o		<= "0000000000" & pci_address;
						wb_cyc_o		<= '1';							--set the Wishbone master signals for a read cycle
						wb_stb_o		<= '1';
						wait_count	<= x"0";							--reset timeout counter
						main_state	<= Mem_read_2;
					end if;
						
				--STAGE 2: wait for Wishbone response, react accordingly to the PCI bus and end the WB cycle
				when Mem_read_2 =>
					if wb_ack_i = '1' then							--WB transaction completed
						wb_adr_o			<= (others => '0');
						wb_cyc_o			<= '0';
						wb_stb_o			<= '0';
						ad					<= wb_dat_i;
						trdy				<= '0';						--trdy and stop asserted at the same time -> Disconnect
						stop				<= '0';
						par_create		<= '1';
						main_state		<= Mem_read_3;
					elsif wb_err_i = '1' or wait_count = WB_MAX_LAT then	--WB transaction aborted, or no WB answer for WB_MAX_LAT clock cycles
						wb_adr_o			<= (others => '0');
						wb_cyc_o			<= '0';
						wb_stb_o			<= '0';
						devsel			<= '1';						--stop asserted and devsel deasserted at the same time -> Target-Abort
						stop				<= '0';
						target_abort	<= '1';						--status register entry
						main_state		<= Idle;
					end if;
					wait_count		<= wait_count + 1;			--count the wait cycles
						
				--STAGE 3: one clock cycle later, end the PCI cycle (only after Disconnect)
				when Mem_read_3 =>
					ad					<= (others => 'Z');
					devsel			<= '1';
					trdy				<= '1';
					stop				<= '1';
					par_create		<= '0';
					main_state		<= Idle;
					
					
		-- ########## MEM WRITE STATE ##########
		-- The data to be written and the address is provided for the Wishbone bus. Then,
		-- wait for Wishbone response:
		-- When ack_i is asserted (= data was stored), signal "Disconnect with data" to PCI
		-- 	master and end the PCI cycle on the next clock edge.
		-- When err_i is asserted (= access error, no transaction), signal "Target-Abort". In
		-- 	this case, no data was changed and the third stage is not activated.
		-- When neither ack_i nor err_i were asserted for WB_MAX_LAT clock cycles, signal
		-- 	"Target-Abort". The third stage is not activated then, too.
				
				--STAGE 1: save write data for WB in the first clock cycle where irdy is asserted and initiate WB action
				when Mem_write_1 =>
					if irdy = '0' then
						wb_adr_o		<= x"00" & "00" & pci_address;
						wb_dat_o		<= ad;
						wb_cyc_o		<= '1';							--set the Wishbone master signals for a write cycle
						wb_stb_o		<= '1';
						wb_we_o		<= '1';
						wait_count	<= x"0";							--reset timeout counter
						main_state	<= Mem_write_2;
					end if;
						
				--STAGE 2: wait for Wishbone response, react accordingly to the PCI bus and end the WB cycle
				when Mem_write_2 =>
					if wb_ack_i = '1' then							--WB transaction completed
						wb_adr_o		<= (others => '0');
						wb_dat_o		<= (others => '0');
						wb_cyc_o		<= '0';
						wb_stb_o		<= '0';
						wb_we_o		<= '0';
						trdy			<= '0';							--trdy and stop asserted at the same time -> Disconnect
						stop			<= '0';
						main_state	<= Mem_write_3;
					elsif wb_err_i = '1' or wait_count = WB_MAX_LAT then	--WB transaction aborted, or no WB answer for WB_MAX_LAT clock cycles
						wb_adr_o		<= (others => '0');
						wb_dat_o		<= (others => '0');
						wb_cyc_o		<= '0';
						wb_stb_o		<= '0';
						wb_we_o		<= '0';
						devsel		<= '1';							--stop asserted and devsel deasserted at the same time -> Target-Abort
						stop			<= '0';
						target_abort<= '1';							--status register entry
						main_state	<= Idle;
					end if;
					wait_count		<= wait_count + 1;			--count the wait cycles
						
				--STAGE 3: one clock cycle later, end the PCI cycle (only after Disconnect)
				when Mem_write_3 =>
					devsel			<= '1';
					trdy				<= '1';
					stop				<= '1';
					main_state		<= Idle;
					
					
		-- ########## undefined state ##########
		-- This state normally should never occur. Just for completion.
				when others =>
					main_state			<= Idle;
				
			end case;
		end if;
	end process;
	
	
	--+------------------------------------------------------------------------------------+
	--|										Parity generation													|
	--+------------------------------------------------------------------------------------+
	-- This process calcutates the even parity of the ad and cbe lines when par_create is
	-- asserted. The main state machine asserts par_create exactly when trdy is asserted
	-- in a Read cycle (both Config and Memory). Because this process sees the assertion
	-- of par_create only on the following clock edge, parity for the master is always
	-- provided one clock cycle delayed to ad (which is required by PCI).
	process(reset, clk)
	begin
		if reset = '0' then
			par		<= 'Z';
		elsif rising_edge(clk) then
			if par_create = '1' then
				par	<=	( ad(31) xor ad(30) xor ad(29) xor ad(28) ) xor
							( ad(27) xor ad(26) xor ad(25) xor ad(24) ) xor
							( ad(23) xor ad(22) xor ad(21) xor ad(20) ) xor
							( ad(19) xor ad(18) xor ad(17) xor ad(16) ) xor
							( ad(15) xor ad(14) xor ad(13) xor ad(12) ) xor
							( ad(11) xor ad(10) xor ad(9)  xor ad(8)  ) xor
							( ad(7)  xor ad(6)  xor ad(5)  xor ad(4)  ) xor
							( ad(3)  xor ad(2)  xor ad(1)  xor ad(0)  ) xor
							( cbe(3) xor cbe(2) xor cbe(1) xor cbe(0) );
			else
				par	<= 'Z';
			end if;
		end if;
	end process;
	
	
end Behavioral;