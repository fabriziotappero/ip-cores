--------------------------------------------------------------------------------
-- Company: 
--
-- File: tb_copyBlaze_ecoSystem_wb_gpio.vhd
--
-- Description:
--	projet copyblaze
--	copyBlaze_ecoSystem testbench
--
-- File history:
-- v1.0: 21/10/11: Creation
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- Entity: tb_copyBlaze_ecoSystem_wb_gpio
--
-- Description:
--	
--	REMARQUE:
--
--	
-- History:
-- 21/10/11 AM: Creation
-- ---------------------
-- xx/xx/xx AM: 
--				
--------------------------------------------------------------------------------
entity tb_copyBlaze_ecoSystem_wb_gpio is
end tb_copyBlaze_ecoSystem_wb_gpio;

--------------------------------------------------------------------------------
-- Architecture: behavior
-- of entity : tb_copyBlaze_ecoSystem_wb_gpio
--------------------------------------------------------------------------------
architecture behavior of tb_copyBlaze_ecoSystem_wb_gpio is 

	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------
	-- Constant for testbench
	constant	CST_RESET_LENGTH	: positive := 7;
	constant	CST_MAX_CYCLES		: positive := 500;

	constant	CST_FREQ			: integer	:= 4;	-- Mhz
	constant	CST_PERIOD			: time		:= 1 us/CST_FREQ;
	
	-- Constant for the cp_copyBlaze_ecoSystem generic
	constant	CST_WIDTH_DATA		: positive := 8;
	constant	CST_WIDTH_PC		: positive := 10;
	constant	CST_WIDTH_INST		: positive := 18;

	constant	CST_DEPTH_STACK		: positive := 31;
	constant	CST_DEPTH_BANC		: positive := 16;
	constant	CST_DEPTH_SCRATCH	: positive := 64;

	constant	CST_INT_VECTOR		: std_ulogic_vector(11 downto 0) := x"3FF";
	
	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------
	component cp_copyBlaze_ecoSystem
		generic
		(
			GEN_WIDTH_DATA		: positive := 8;
			GEN_WIDTH_PC		: positive := 10;
			GEN_WIDTH_INST		: positive := 18;
			
			GEN_DEPTH_STACK		: positive := 15;	-- Taille (en octet) de la Stack
			GEN_DEPTH_BANC		: positive := 16;	-- Taille (en octet) du Banc Register
			GEN_DEPTH_SCRATCH	: positive := 64;	-- Taille (en octet) du Scratch Pad
			
			GEN_INT_VECTOR		: std_ulogic_vector(11 downto 0) := x"3FF"
		);
		Port (
			--------------------------------------------------------------------------------
			-- Signaux Systeme
			--------------------------------------------------------------------------------
				Clk_i				: in std_ulogic;
				--Rst_i_n				: in std_ulogic;
		
			--------------------------------------------------------------------------------
			-- Signaux Fonctionels
			--------------------------------------------------------------------------------
				Interrupt_i			: in std_ulogic;
				Interrupt_Ack_o		: out std_ulogic;
				
				IN_PORT_i			: in std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
				OUT_PORT_o			: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
				PORT_ID_o			: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
				READ_STROBE_o		: out std_ulogic;
				WRITE_STROBE_o		: out std_ulogic;
			--------------------------------------------------------------------------------
			-- Signaux WishBone
			--------------------------------------------------------------------------------
				Freeze_i			: in std_ulogic;
			
			--------------------------------------------------------------------------------
			-- Signaux Wishbone Interface
			--------------------------------------------------------------------------------
				--RST_I   			: in    std_ulogic;
				--CLK_I   			: in    std_ulogic;
							
				ADR_O				: out	std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
				DAT_I				: in	std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
				DAT_O				: out	std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
				WE_O    			: out	std_ulogic;
				SEL_O				: out	std_ulogic_vector(1 downto 0);
							
				STB_O   			: out	std_ulogic;
				ACK_I   			: in	std_ulogic;
				CYC_O   			: out	std_ulogic
		);
	end component;

	component wb_gpio_08
	port (
			clk      : in  std_ulogic;
			reset    : in  std_ulogic;
			-- Wishbone bus
			wb_adr_i : in  std_ulogic_vector(7 downto 0);
			wb_dat_i : in  std_ulogic_vector(7 downto 0);
			wb_dat_o : out std_ulogic_vector(7 downto 0);
			wb_cyc_i : in  std_ulogic;
			wb_stb_i : in  std_ulogic;
			wb_ack_o : out std_ulogic;
			wb_we_i  : in  std_ulogic;
			-- I/O ports
			iport    : in  std_ulogic_vector(7 downto 0);
			oport    : out std_ulogic_vector(7 downto 0)
		);
	end component;

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	signal iClk				: std_ulogic := '0';
	signal iReset			: std_ulogic;
	signal iResetN			: std_ulogic;

	signal iInterrupt		: std_ulogic;
	signal iInterrupt_Ack	: std_ulogic;
	signal iIn_port			: std_ulogic_vector(CST_WIDTH_DATA-1 downto 0); 
	signal iOut_port		: std_ulogic_vector(CST_WIDTH_DATA-1 downto 0); 
	signal iPort_id			: std_ulogic_vector(CST_WIDTH_DATA-1 downto 0); 
	signal iRead_strobe		: std_ulogic;
	signal iWrite_strobe	: std_ulogic;

	signal iFreeze			: std_ulogic := '0'; -- Freeze the processor

	signal iReset_counter	: natural range 0 to CST_RESET_LENGTH := CST_RESET_LENGTH;	-- VERY BAD SOLUTION
	signal iCounter			: std_ulogic_vector(CST_WIDTH_DATA-1 downto 0);
	signal iWaveForms		: std_ulogic_vector(CST_WIDTH_DATA-1 downto 0);
	signal iExtIntEvent		: std_ulogic := '0';
	
	signal iWbSTB			: std_ulogic;
	signal iWbCYC			: std_ulogic;
	signal iWbACK			: std_ulogic;-- := '0';--'0';
	signal iWbWE			: std_ulogic;-- := '0';--'0';
	
	signal iWbDAT_I			: std_ulogic_vector(CST_WIDTH_DATA-1 downto 0); 
	signal iWbDAT_O			: std_ulogic_vector(CST_WIDTH_DATA-1 downto 0); 
	signal iWbADR			: std_ulogic_vector(CST_WIDTH_DATA-1 downto 0); 
	
begin

	-- ***************************************** --
	-- UUT : Unit Under Test : cp_copyBlaze_ecoSystem --
	-- ***************************************** --
	uut: cp_copyBlaze_ecoSystem
		generic map
		(
			GEN_WIDTH_DATA		=> CST_WIDTH_DATA,
			GEN_WIDTH_PC		=> CST_WIDTH_PC,
			GEN_WIDTH_INST		=> CST_WIDTH_INST,

			GEN_DEPTH_STACK		=> CST_DEPTH_STACK,
			GEN_DEPTH_BANC		=> CST_DEPTH_BANC,
			GEN_DEPTH_SCRATCH	=> CST_DEPTH_SCRATCH,

			GEN_INT_VECTOR		=> CST_INT_VECTOR
		)
		Port map
		(
			--------------------------------------------------------------------------------
			-- Signaux Systeme
			--------------------------------------------------------------------------------
				Clk_i				=> iClk,
				--Rst_i_n				: in std_ulogic;
		
			--------------------------------------------------------------------------------
			-- Signaux Fonctionels
			--------------------------------------------------------------------------------
				Interrupt_i			=> iInterrupt,
				Interrupt_Ack_o		=> iInterrupt_Ack,
				
				IN_PORT_i			=> iIn_port,
				OUT_PORT_o			=> iOut_port,
				PORT_ID_o			=> iPort_id,
				READ_STROBE_o		=> iRead_strobe,
				WRITE_STROBE_o		=> iWrite_strobe,
			--------------------------------------------------------------------------------
			-- Signaux WishBone
			--------------------------------------------------------------------------------
				Freeze_i			=> iFreeze,
			
			--------------------------------------------------------------------------------
			-- Signaux Wishbone Interface
			--------------------------------------------------------------------------------
				--RST_I   			=> iReset,
				--CLK_I   			=> Clk_i,
	
				ADR_O				=> iWbADR,
				DAT_I				=> iWbDAT_I,--(others => '0'),
				DAT_O				=> iWbDAT_O,--open,
				WE_O    			=> iWbWE,--open,
				SEL_O				=> open,
	
				STB_O   			=> iWbSTB,
				ACK_I   			=> iWbACK,
				CYC_O   			=> iWbCYC
		);

	wb_gpio : wb_gpio_08
	port map (
			clk      => iClk, --: in  std_ulogic;
			reset    => iReset, --: in  std_ulogic;
			-- Wishbone bus
			wb_adr_i => iWbADR, --: in  std_ulogic_vector(7 downto 0);
			wb_dat_i => iWbDAT_O, --: in  std_ulogic_vector(7 downto 0);
			wb_dat_o => iWbDAT_I, --: out std_ulogic_vector(7 downto 0);
			wb_cyc_i => iWbCYC, --: in  std_ulogic;
			wb_stb_i => iWbSTB, --: in  std_ulogic;
			wb_ack_o => iWbACK, --: out std_ulogic;
			wb_we_i  => iWbWE, --: in  std_ulogic;
			-- I/O ports
			iport    => x"45", --: in  std_ulogic_vector(7 downto 0);
			oport    => open --: out std_ulogic_vector(7 downto 0)
		);

	--------------------------------------------------------------------------------
	-- Process : Interrupt_Proc
	-- Description: Interrupt Logic for cp_copyBlaze_ecoSystem
	--------------------------------------------------------------------------------
	Interrupt_Proc: process(iReset, iClk)
	begin
		if (iReset='0') then
			iInterrupt	<= '0';
		elsif ( rising_edge(iClk) ) then
			if (iExtIntEvent='1') then
				iInterrupt	<= '1';
			elsif (iInterrupt_Ack='1') then
				iInterrupt	<= '0';
			end if;
		end if;
	end process Interrupt_Proc;

	--------------------------------------------------------------------------------
	-- Process : Reset_Proc
	-- Description: Reset Logic for cp_copyBlaze_ecoSystem
	--------------------------------------------------------------------------------
	Reset_Proc: process(iClk)
	begin
		-- delayed iReset circuit
		if ( rising_edge(iClk) ) then
			if ( iReset_counter = 0 ) then
				iReset			<=	'1';
			else
				iReset			<=	'0';
				iReset_counter	<=	iReset_counter - 1;
			end if;
		end if;
	end process Reset_Proc;
	iResetN	<=	not(iReset);
	
	--------------------------------------------------------------------------------
	-- Process : IO_Proc
	-- Description: adding the output registers to the processor
	--------------------------------------------------------------------------------
	IO_Proc: process(iClk)
	begin
		-- waveform register at iAddress 02
		if ( rising_edge(iClk) ) then
			if (iPort_id(1)='1' and iWrite_strobe='1') then
				iWaveForms <= iOut_port;
			end if;
		end if; 

		-- Interrupt iCounter register at iAddress 04
		if ( rising_edge(iClk) ) then
			if (iPort_id(2)='1' and iWrite_strobe='1') then
				iCounter <= iOut_port;
			end if;
		end if;
 
	end process IO_Proc;

	-- ********************* --
	-- STIMULIS FOR THE TEST --
	-- ********************* --
	-- Unused inputs on processor
	iIn_port	<= x"28";

	--iClk <= not iClk after 0.5 * CST_PERIOD;
	--------------------------------------------------------------------------------
	-- Process : INT_Proc
	-- Description: Nominal 100MHz clock which also defines number of cycles in simulation 
	--------------------------------------------------------------------------------
	INT_Proc : process
		variable max_cycles		: integer :=	CST_MAX_CYCLES;
		variable cycle_count	: integer :=	0;
	begin
		-- Define the clock cycles and the clock cycle iCounter
		while cycle_count < max_cycles loop

--			wait until rising_edge(iClk) ;
				iClk <= '0';
			wait for CST_PERIOD;
				iClk <= '1';
				cycle_count := cycle_count + 1;
			wait for CST_PERIOD;
	

			--Now define stimulus relative to a given clock cycle
			case cycle_count is
				-- *************** --
				-- INTERRUPT EVENT --
				-- *************** --
				--when 30 =>	iExtIntEvent <= '1'; 
				--when 34 =>	iExtIntEvent <= '0'; 
                --
				--when 67 =>	iExtIntEvent <= '1'; -- Take care when the "iIE" bit is not set. In this case how to manage Interrupt_Ack_o
				--when 71 =>	iExtIntEvent <= '0'; 
				
				when 300 =>		iExtIntEvent <= '1'; 
				when 304 =>		iExtIntEvent <= '0'; 
				
				-- ************ --
				-- FREEZE EVENT --
				-- ************ --
				when 130 =>		iFreeze	<= '1';
				when 150 =>		iFreeze	<= '0';
				
				-- ****** --
				-- WB ACK --
				-- ****** --
				--when 420	=>		iWbACK	<= '1';
				--when 420+1	=>		iWbACK	<= '0';

				when others =>	iExtIntEvent <= iExtIntEvent;   -- hold last defined value
			
			end case;
		
		end loop;
		
		wait; -- end of simulation.
	
	end process INT_Proc;

end behavior;
