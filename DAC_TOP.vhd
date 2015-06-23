-----------------------------------------------------------------------------------------
-- Engineer: Tomas Daujotas (mailsoc@gmail.com www.scrts.net)
-- 
-- Create Date: 2010-07-21 
-- Design Name: Control of LTC2624 Quad 12 bit DAC on Spartan-3E Starter Kit (32bit mode)
-----------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DAC_TOP is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           DAC_MOSI : out  STD_LOGIC;
           DAC_CLR : out  STD_LOGIC;
           DAC_SCK : out  STD_LOGIC;
           DAC_CS : out  STD_LOGIC;
           SPI_SS_B : out  STD_LOGIC;		-- Serial Flash
           AMP_CS : out  STD_LOGIC;			-- Amplifier for ADC
           AD_CONV : out  STD_LOGIC;		-- ADC Conversion start
           SF_CE0 : out  STD_LOGIC;			-- StrataFlash 
           FPGA_INIT_B : out  STD_LOGIC);	-- Platform Flash
end DAC_TOP;

architecture DAC of DAC_TOP is

signal rdy,daccs,dacsck,dacmosi : std_logic;
signal command : std_logic_vector(3 downto 0);
signal address : std_logic_vector(3 downto 0);
signal dacdata : std_logic_vector(31 downto 0);
signal pattern : std_logic_vector(11 downto 0);

component DAC_Control
	 Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  DAC_DATA : in STD_LOGIC_VECTOR(31 downto 0);
           DAC_MOSI : out  STD_LOGIC;
           DAC_SCK : out  STD_LOGIC;
           DAC_CS : out  STD_LOGIC;
           RDY : out  STD_LOGIC);
end component;

begin
	U1 : DAC_Control
	Port map ( CLK => CLK,
				  RST => RST,
				  DAC_MOSI => dacmosi,
				  DAC_SCK => dacsck,
				  DAC_CS => daccs,
				  RDY => RDY,
				  DAC_DATA => dacdata);
	
process(RST,CLK,daccs,dacsck,dacmosi)
	begin
		if (RST='1') then
			DAC_MOSI <= '0';
			DAC_CLR <= '0';
			DAC_SCK <= '0';
			DAC_CS <= '1';
		elsif rising_edge(CLK) then
			if rdy = '1' then 					-- Check if first 32 bits is sent and proceed to the next
				command <= "0011";				-- Set the command register
				address <= "1111";				-- Set the address register 
				pattern <= "100000000000";		-- 12 bit value (refer to LTC2624 datasheet page 10 for Vout)
				dacdata(31 downto 24) <= (others => '0'); -- Don't care (refer to LTC2624 datasheet page 13)
				dacdata(23 downto 20) <= command;
				dacdata(19 downto 16) <= address;
				dacdata(15 downto 4) <= pattern;
				dacdata(3 downto 0) <= (others => '0');	-- Don't care
			end if;
			DAC_CLR <= '1';
		end if;
		DAC_CS <= daccs;
		DAC_SCK <= dacsck;
		DAC_MOSI <= dacmosi;
end process;

	----- Disabling not required devices -----
	SPI_SS_B <= '1';
	AMP_CS <= '1';
	AD_CONV <= '0';
	SF_CE0 <= '1';
	FPGA_INIT_B <= '1';

end DAC;

