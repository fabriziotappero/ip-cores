library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


--This has been tested on a Xilinx XC2C256 (Coolrunner-II 256) with 
-- Cirrus CS5340 ADC's and CS4334 DAC's connected to an Atmel AVR AtMega128L uC.

entity I2SParalellPorts is
    port ( 	
	 			Xtal : in std_logic;
	 			
				--analog bus ports														
				AdcData : in std_logic;
				DacData : out std_logic;
				LRClk : out std_logic;
				SClk : out std_logic;
				MClk : out std_logic;
				
				--digital bus ports
				ADCSampleBus : out std_logic_vector(23 downto 0);
				DACSampleBus : in std_logic_vector(23 downto 0);
				LDataStrobe : out std_logic;				
				RDataStrobe : out std_logic;				

				--debug port
				nDebugLoopBack : in std_logic --;
		);
end I2SParalellPorts;

architecture I2SParalell of I2SParalellPorts is

	component ClocksPorts
	port ( 	
		Xtal :  in std_logic; --main system oscillator	 
		LRClk : out std_logic; --LR clock for analog serial bus
		SClk : out std_logic; --Serial Bit clock for analog serial bus
		MClk : out std_logic--; --Master clock for analog serial bus (runs DeltaSig hardware in converters)
	);
	end component;

	component AnalogBusPorts
	port ( 	
 		SClk : in std_logic;     --this whole schebang runs of the analog serial bus clock
		LRClk : in std_logic;    --which channel at the moment?
		AdcData : in std_logic;	 --data coming in from adc
		DacData : out std_logic;	 --data coming in from adc
		SampleStrobe : out std_logic;						 --dump the contents of FifoData into the fifo on next clock
		nSampleStrobe : out std_logic;						 --dump the contents of FifoData into the fifo on next clock
		LastAdcSample : out std_logic_vector(23 downto 0);    --buffer for fifo data		   
		NextDacSample : in std_logic_vector(23 downto 0)--;    --buffer for fifo data		   
	);
	end component;

	signal LRClk_i : std_logic;
	signal SClk_i  : std_logic;
	signal DacData_e  : std_logic;
	signal DacData_i  : std_logic;
																
	--signal count : std_logic_vector(24 downto 0);
			
begin
		  
	Clocks: ClocksPorts
	port map ( 	
	 		Xtal=>Xtal,
	 		LRClk=>LRClk_i,
			SClk=>SClk_i,
			MClk=>MClk--,
	);

	AnalogBus: AnalogBusPorts
	port map ( 	
	 		SClk=>SClk_i,		  				
			LRClk=>LRClk_i,				
			AdcData=>AdcData,
			DacData=>DacData_e,
			SampleStrobe=>LDataStrobe,
			nSampleStrobe=>RDataStrobe,
			LastAdcSample=>ADCSampleBus,
			NextDacSample=>DACSampleBus--,			   
	);		

	LRClk <= LRClk_i;
	SClk <= SClk_i;
	DacData <= DacData_i;

	process (Xtal)
	
	begin
 	
		if (Xtal'event and Xtal = '1') then

			if (nDebugLoopBack = '0') then 

				DacData_i <= AdcData;

			else 

				DacData_i <= DacData_e;

			end if;

		end if; --if (Xtal'event ...

	end process;
		
end I2SParalell;
