---------------------------------------------------------------------
-- File :			Top_Modul_VHDL.vhd
-- Projekt :		Prj_12_DDR2
-- Zweck :			DDR2-SDRAM am Spartan-3A Board
-- DDR2-RAM :		MT47H32M16 (64 MByte)
-- Datum :			19.08.2011
-- Version :		7.0
-- Plattform :		XILINX Spartan-3A
-- FPGA :			XC3S700A-FGG484
-- Sprache :		VHDL
-- ISE :				ISE-Design-Suite V:13.1
-- IP-Core :		MIG V:3.6.1
-- Autor :			UB
-- Mail :			Becker_U(at)gmx.de
---------------------------------------------------------------------
--
-- Bitte auch die Hinweise in der "DDR2_liesmich.txt" beachten
--
-- please have a look at the "DDR2_readme.txt"
-- and sorry for my bad english :-)
--
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_Modul_VHDL is
	--------------------------------------------
	-- Port Deklerationen
	--------------------------------------------
	port(		
		CLK_AUX_IN : in std_logic;
		LED_OUT : out std_logic_vector(7 downto 0);
		LED_YELLOW_OUT : out std_logic;
		SW_IN : in std_logic_vector(3 downto 0);
		BTN_IN : in std_logic_vector(3 downto 0);
		----------------------------------------------------
		-- DDR2 SDRAM-Port-Pins
		----------------------------------------------------
		cntrl0_ddr2_a : out std_logic_vector(12 downto 0) := (others => '0');
		cntrl0_ddr2_ba : out std_logic_vector(1 downto 0) := (others => '0');
		cntrl0_ddr2_ck : out std_logic_vector(0 downto 0) := (others => '0');
		cntrl0_ddr2_ck_n : out std_logic_vector(0 downto 0) := (others => '0');
		cntrl0_ddr2_cke : out std_logic := '0';
		cntrl0_ddr2_cs_n : out std_logic := '0';
		cntrl0_ddr2_ras_n : out std_logic := '0';
		cntrl0_ddr2_cas_n : out std_logic := '0';
		cntrl0_ddr2_we_n : out std_logic := '0';
		cntrl0_ddr2_odt : out std_logic := '0';
		cntrl0_ddr2_dm : out std_logic_vector(1 downto 0) := (others => '0');
		cntrl0_ddr2_dqs_n : inout std_logic_vector(1 downto 0) := (others => '0');
		cntrl0_ddr2_dqs : inout std_logic_vector(1 downto 0) := (others => '0');
		cntrl0_ddr2_dq : inout std_logic_vector(15 downto 0) := (others => '0');
		cntrl0_rst_dqs_div_in : in std_logic;
		cntrl0_rst_dqs_div_out : out std_logic		
		----------------------------------------------------		
	);
	
end Top_Modul_VHDL;

architecture Verhalten of Top_Modul_VHDL is

	--------------------------------------------
	-- Interne Signale
	--------------------------------------------	
	signal v_reset_n : std_logic;
	signal v_reset_p : std_logic;
	signal v_debounce : std_logic_vector(7 downto 0) := (others => '0');
	signal v_risingedge : std_logic_vector(3 downto 0) := (others => '0');
	
	-- DDR2 SDRAM-Leitungen -----------------------------------------
	signal clk_tb : std_logic;
	signal clk90_tb : std_logic;
	signal burst_done : std_logic;
	signal user_command_register : std_logic_vector(2 downto 0) := (others => '0');
	signal user_data_mask : std_logic_vector(3 downto 0):= (others => '0');
	signal user_input_data : std_logic_vector(31 downto 0);
	signal user_input_address : std_logic_vector(24 downto 0);
	signal v_init_done : std_logic;
	signal ar_done : std_logic;
	signal auto_ref_req : std_logic;
	signal user_cmd_ack : std_logic;
	signal user_data_valid : std_logic;
	signal user_output_data	: std_logic_vector(31 downto 0);
	---------------------------------------------------------------------

	--------------------------------------------
	-- Einbinden einer Componente
	-- Clock_VHDL : für die Clockerzeugung
	--------------------------------------------	
	COMPONENT Clock_VHDL is
	PORT (
		clk_in_133MHz : in std_logic;
		clk_out_1Hz : out std_logic
	);
	END COMPONENT Clock_VHDL;
	
	--------------------------------------------
	-- Einbinden einer Componente
	-- Buttons_VHDL : für die Buttons und Schalter
	--------------------------------------------	
	COMPONENT Buttons_VHDL is
	PORT (
		clk_in : in std_logic;
		button_in : in std_logic_vector(3 downto 0);
		switch_in : in std_logic_vector(3 downto 0);
		debounce_out : out std_logic_vector(7 downto 0);
		risingedge_out : out std_logic_vector(3 downto 0)	
	);
	END COMPONENT Buttons_VHDL;

	--------------------------------------------
	-- Einbinden einer Componente
	-- VHDL um das DDR2 zu steuern
	--------------------------------------------
	COMPONENT DDR2_Control_VHDL is
	PORT (
		reset_in : in std_logic;
		clk_in : in std_logic;
		clk90_in : in std_logic;
		init_done : in std_logic;
		command_register : out std_logic_vector(2 downto 0);
		input_adress : out std_logic_vector(24 downto 0);
		input_data : out std_logic_vector(31 downto 0);
		output_data : in std_logic_vector(31 downto 0);
		cmd_ack : in std_logic;
		data_valid : in std_logic;
		burst_done : out std_logic;
		auto_ref_req : in std_logic;
		debounce_in : in std_logic_vector(7 downto 0);
		risingedge_in : in std_logic_vector(3 downto 0);
		data_out : out std_logic_vector(7 downto 0)
	);
	END COMPONENT DDR2_Control_VHDL;

	--------------------------------------------
	-- Einbinden einer Componente
	-- DDR2_RAM_Modul (vom MIG generiert)
	--------------------------------------------	
	COMPONENT DDR2_Ram_Core is
	PORT (
		cntrl0_ddr2_dq : inout std_logic_vector(15 downto 0);
		cntrl0_ddr2_a : out std_logic_vector(12 downto 0);
		cntrl0_ddr2_ba : out std_logic_vector(1 downto 0);
		cntrl0_ddr2_cke : out std_logic;
		cntrl0_ddr2_cs_n : out std_logic;
		cntrl0_ddr2_ras_n : out std_logic;
		cntrl0_ddr2_cas_n : out std_logic;
		cntrl0_ddr2_we_n : out std_logic;
		cntrl0_ddr2_odt : out std_logic;
		cntrl0_ddr2_dm : out std_logic_vector(1 downto 0);
		cntrl0_rst_dqs_div_in : in std_logic;
		cntrl0_rst_dqs_div_out : out std_logic;		
		sys_clk_in : in std_logic;
		reset_in_n : in std_logic;
		cntrl0_burst_done : in std_logic;
		cntrl0_init_done : out std_logic;
		cntrl0_ar_done : out std_logic;
		cntrl0_user_data_valid : out std_logic;
		cntrl0_auto_ref_req : out std_logic;
		cntrl0_user_cmd_ack : out std_logic;
		cntrl0_user_command_register : in std_logic_vector(2 downto 0);
		cntrl0_clk_tb : out std_logic;
		cntrl0_clk90_tb : out std_logic;
		cntrl0_sys_rst_tb : out std_logic;
		cntrl0_sys_rst90_tb : out std_logic;
		cntrl0_sys_rst180_tb : out std_logic;
		cntrl0_user_output_data : out std_logic_vector(31 downto 0);
		cntrl0_user_input_data : in std_logic_vector(31 downto 0);
		cntrl0_user_data_mask : in std_logic_vector(3 downto 0);
		cntrl0_user_input_address : in std_logic_vector(24 downto 0);
		cntrl0_ddr2_dqs : inout std_logic_vector(1 downto 0);
		cntrl0_ddr2_dqs_n : inout std_logic_vector(1 downto 0);
		cntrl0_ddr2_ck : out std_logic_vector(0 downto 0);
		cntrl0_ddr2_ck_n : out std_logic_vector(0 downto 0)
	);
	END COMPONENT DDR2_Ram_Core;	


begin

	--------------------------------------------------
	-- Instantz einer Componente erzeugen und verbinden
	-- Clock_VHDL : für die Clockerzeugung
	--------------------------------------------------
	INST_Clock_VHDL : Clock_VHDL
	PORT MAP (	
		clk_in_133MHz => clk_tb,		
		clk_out_1Hz => LED_YELLOW_OUT
	);
	
	--------------------------------------------------
	-- Instantz einer Componente erzeugen und verbinden
	-- VHDL um die Buttons/Schalter zu bearbeiten
	--------------------------------------------------
	INST_Buttons_VHDL : Buttons_VHDL
	PORT MAP (	
		clk_in => clk_tb,
		button_in => BTN_IN,
		switch_in => SW_IN,
		debounce_out => v_debounce,
		risingedge_out => v_risingedge
	);
	
	--------------------------------------------------
	-- Instantz einer Componente erzeugen und verbinden
	-- VHDL um das DDR2 zu steuern
	--------------------------------------------------
	INST_DDR2_Control_VHDL : DDR2_Control_VHDL
	PORT MAP (
		reset_in => v_reset_p,
		clk_in => clk_tb,
		clk90_in => clk90_tb,
		init_done => v_init_done,
		command_register => user_command_register,
		input_adress => user_input_address,
		input_data => user_input_data,
		output_data => user_output_data,
		cmd_ack => user_cmd_ack,
		data_valid => user_data_valid,
		burst_done => burst_done,
		auto_ref_req => auto_ref_req,
		debounce_in => v_debounce,
		risingedge_in => v_risingedge,
		data_out => LED_OUT
	);

	--------------------------------------------------
	-- Instantz einer Componente erzeugen und verbinden
	-- DDR2_RAM_Modul (vom MIG generiert)
	--------------------------------------------------
	INST_DDR2_RAM_CORE : DDR2_Ram_Core
	PORT MAP (
		sys_clk_in => CLK_AUX_IN,
		reset_in_n => v_reset_n,
		cntrl0_burst_done => burst_done,
		cntrl0_user_command_register => user_command_register,
		cntrl0_user_data_mask => user_data_mask,
		cntrl0_user_input_data => user_input_data,
		cntrl0_user_input_address => user_input_address,
		cntrl0_init_done => v_init_done,
		cntrl0_ar_done => ar_done,
		cntrl0_auto_ref_req => auto_ref_req,
		cntrl0_user_cmd_ack => user_cmd_ack,
		cntrl0_clk_tb => clk_tb,
		cntrl0_clk90_tb => clk90_tb,
		cntrl0_sys_rst_tb => open,
		cntrl0_sys_rst90_tb => open,
		cntrl0_sys_rst180_tb => open,
		cntrl0_user_data_valid => user_data_valid,
		cntrl0_user_output_data => user_output_data,			
		cntrl0_ddr2_ras_n => cntrl0_ddr2_ras_n,
		cntrl0_ddr2_cas_n => cntrl0_ddr2_cas_n,
		cntrl0_ddr2_we_n => cntrl0_ddr2_we_n,
		cntrl0_ddr2_cs_n => cntrl0_ddr2_cs_n,
		cntrl0_ddr2_cke => cntrl0_ddr2_cke,
		cntrl0_ddr2_dm => cntrl0_ddr2_dm,
		cntrl0_ddr2_ba => cntrl0_ddr2_ba,
		cntrl0_ddr2_a => cntrl0_ddr2_a,
		cntrl0_ddr2_ck => cntrl0_ddr2_ck,
		cntrl0_ddr2_ck_n => cntrl0_ddr2_ck_n,
		cntrl0_ddr2_dqs => cntrl0_ddr2_dqs,
		cntrl0_ddr2_dqs_n => cntrl0_ddr2_dqs_n,
		cntrl0_ddr2_dq => cntrl0_ddr2_dq,
		cntrl0_ddr2_odt => cntrl0_ddr2_odt,		
		cntrl0_rst_dqs_div_in => cntrl0_rst_dqs_div_in,
		cntrl0_rst_dqs_div_out => cntrl0_rst_dqs_div_out	
	);


	-----------------------------------------
	-- Reset-Signal aus einem Schalter generieren
	-----------------------------------------	
	v_reset_p <= SW_IN(0);
	v_reset_n <= not v_reset_p;		
	


end Verhalten;

