--------------------------------------------------------------------------------
-- Company: 
--
-- File: cp_copyBlaze_ecoSystem.vhd
--
-- Description:
--	projet copyblaze
--	copyBlaze processor + ROM => system
--
-- File history:
-- v1.0: 11/10/11: Creation
--
-- Targeted device: ProAsic A3P250 VQFP100
-- Author: AbdAllah Meziti
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use	work.Usefull_Pkg.all;		-- Usefull Package

--------------------------------------------------------------------------------
-- Entity: cp_copyBlaze_ecoSystem
--
-- Description:
--	
--	REMARQUE:
--
--	
-- History:
-- 11/10/11 AM: Creation
-- ---------------------
-- xx/xx/xx AM: 
--				
--------------------------------------------------------------------------------
entity cp_copyBlaze_ecoSystem is
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
--			RST_I   			: in    std_ulogic;
--			CLK_I   			: in    std_ulogic;
						
			ADR_O				: out	std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
			DAT_I				: in	std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
			DAT_O				: out	std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);
			WE_O    			: out	std_ulogic;
			SEL_O				: out	std_ulogic_vector(1 downto 0);
	
			STB_O   			: out	std_ulogic;
			ACK_I   			: in	std_ulogic;
			CYC_O   			: out	std_ulogic
	);
end cp_copyBlaze_ecoSystem;

--------------------------------------------------------------------------------
-- Architecture: RTL
-- of entity : cp_copyBlaze_ecoSystem
--------------------------------------------------------------------------------
architecture rtl of cp_copyBlaze_ecoSystem is

	--------------------------------------------------------------------------------
	-- Définition des constantes
	--------------------------------------------------------------------------------
	constant	RESET_LENGTH	: positive := 7;
	
	--------------------------------------------------------------------------------
	-- Déclaration des composants
	--------------------------------------------------------------------------------
	component cp_copyBlaze
		generic
		(
			GEN_WIDTH_DATA		: positive := 8;
			GEN_WIDTH_PC		: positive := 10;
			GEN_WIDTH_INST		: positive := 18;
			
			GEN_DEPTH_STACK		: positive := 15;	-- Taille (en octet) de la Stack
			GEN_DEPTH_BANC		: positive := 16;	-- Taille (en octet) du Banc Register
			GEN_DEPTH_SCRATCH	: positive := 64;	-- Taille (en octet) du Scratch Pad
			
			GEN_INT_VECTOR		: std_ulogic_vector(11 downto 0) := x"3FF" -- Interrupt Vector
		);
		port (
		--------------------------------------------------------------------------------
		-- Signaux Systeme
		--------------------------------------------------------------------------------
			Clk_i				: in std_ulogic;	--	signal d'horloge générale
			Rst_i_n				: in std_ulogic;	--	signal de iReset générale
	
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			Address_o			: out std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);
			Instruction_i		: in std_ulogic_vector(GEN_WIDTH_INST-1 downto 0);
			
			Interrupt_i			: in std_ulogic;	-- 
			Interrupt_Ack_o		: out std_ulogic;	-- 
			
			IN_PORT_i			: in std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
			OUT_PORT_o			: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
			PORT_ID_o			: out std_ulogic_vector(GEN_WIDTH_DATA-1 downto 0);	-- 
			READ_STROBE_o		: out std_ulogic;
			WRITE_STROBE_o		: out std_ulogic;
		--------------------------------------------------------------------------------
		-- Signaux Speciaux
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

	component cp_ROM_Code
		generic
		(
			GEN_WIDTH_PC		: positive := 10;
			GEN_WIDTH_INST		: positive := 18
		);
		port(
			Clk_i		: in std_ulogic;
			Address_i	: in std_ulogic_vector(GEN_WIDTH_PC-1 downto 0);
			Dout_o		: out std_ulogic_vector(GEN_WIDTH_INST-1 downto 0)
		);
	end component;

	--------------------------------------------------------------------------------
	-- Définition des signaux interne
	--------------------------------------------------------------------------------
	signal iAddress			: std_ulogic_vector(9 downto 0);
	signal iInstruction		: std_ulogic_vector(17 downto 0);
	
	signal iReset			: std_ulogic := '0';
	signal iReset_counter	: natural range 0 to RESET_LENGTH := RESET_LENGTH;	-- VERY BAD SOLUTION

begin

	-- ************************** --
	-- The copyBlaze CPU instance --
	-- ************************** --
	processor: cp_copyBlaze
		generic map
		(
			GEN_WIDTH_DATA		=> GEN_WIDTH_DATA,
			GEN_WIDTH_PC		=> GEN_WIDTH_PC,
			GEN_WIDTH_INST		=> GEN_WIDTH_INST,

			GEN_DEPTH_STACK		=> GEN_DEPTH_STACK,
			GEN_DEPTH_BANC		=> GEN_DEPTH_BANC,

			GEN_DEPTH_SCRATCH	=> GEN_DEPTH_SCRATCH,
			GEN_INT_VECTOR		=> GEN_INT_VECTOR
		)
		port map(
		--------------------------------------------------------------------------------
		-- Signaux Systeme
		--------------------------------------------------------------------------------
			Clk_i				=> Clk_i,
			Rst_i_n				=> iReset,
	
		--------------------------------------------------------------------------------
		-- Signaux Fonctionels
		--------------------------------------------------------------------------------
			Address_o			=> iAddress,
			Instruction_i		=> iInstruction,
			
			Interrupt_i			=> Interrupt_i,
			Interrupt_Ack_o		=> Interrupt_Ack_o,
			
			IN_PORT_i			=> IN_PORT_i,
			OUT_PORT_o			=> OUT_PORT_o,
			PORT_ID_o			=> PORT_ID_o,
			READ_STROBE_o		=> READ_STROBE_o,
			WRITE_STROBE_o		=> WRITE_STROBE_o,
		--------------------------------------------------------------------------------
		-- Signaux Speciaux
		--------------------------------------------------------------------------------
			Freeze_i			=> Freeze_i,
			
		--------------------------------------------------------------------------------
		-- Signaux Wishbone Interface
		--------------------------------------------------------------------------------
			--RST_I   			=> RST_I,
			--CLK_I   			=> CLK_I,

			ADR_O				=> ADR_O,
			DAT_I				=> DAT_I,
			DAT_O				=> DAT_O,
			WE_O    			=> WE_O,
			SEL_O				=> SEL_O,

			STB_O   			=> STB_O,
			ACK_I   			=> ACK_I,
			CYC_O   			=> CYC_O
		);

	-- *************** --
	-- ROM code memory --
	-- *************** --
	program : cp_ROM_Code
		generic map
		(
			GEN_WIDTH_PC		=>  GEN_WIDTH_PC,
			GEN_WIDTH_INST		=>  GEN_WIDTH_INST
		)
		port map
		(
			Clk_i		=> Clk_i,
			Address_i	=> iAddress,
			Dout_o		=> iInstruction
		);

	--------------------------------------------------------------------------------
	-- Process : ProcessorReset_Proc
	-- Description: Generate the reset of the processor
	--------------------------------------------------------------------------------
	ProcessorReset_Proc : process(Clk_i)
	begin
		if ( rising_edge(Clk_i) ) then
			if ( iReset_counter = 0 ) then
				iReset			<=	'1';
			else
				iReset			<=	'0';
				iReset_counter	<=	iReset_counter - 1;
			end if;
		end if;
	end process ProcessorReset_Proc;

end rtl;