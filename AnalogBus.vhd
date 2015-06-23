library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AnalogBusPorts is
	port ( 	
		SClk : in std_logic;     --this whole schebang runs of the analog serial bus clock
		LRClk : in std_logic;    --which channel at the moment?
		AdcData : in std_logic;	 --data coming in from adc
		DacData : out std_logic;	 --
		SampleStrobe : out std_logic;						 --dump the contents of FifoData into the fifo on next clock
		nSampleStrobe : out std_logic;						 --dump the contents of FifoData into the fifo on next clock
		LastAdcSample : out std_logic_vector(23 downto 0);    --buffer for fifo data		   
		NextDacSample : in std_logic_vector(23 downto 0)--;    --buffer for fifo data		   
	);
end AnalogBusPorts;

architecture AnalogBus of AnalogBusPorts is
																				
	signal LastLRClk  : std_logic;  --to keep track of edges
	
	--sample buffers
	signal CurrentAdcSample : std_logic_vector(23 downto 0);
	signal CurrentDacSample : std_logic_vector(23 downto 0);
	signal AdcBitIndex  : std_logic_vector(5 downto 0);
	signal DacBitIndex  : std_logic_vector(5 downto 0);
	
begin	

		 
	process (SClk)		
		begin

		if (SClk'event and SClk = '1') then		

			--move to next bit on each clock of the serial
			AdcBitIndex <= AdcBitIndex + "000001";
			DacBitIndex <= DacBitIndex + "000001";
						
			--Just moved to the MSB of the other channel
			if ( LRClk = (not(LastLRClk)) ) then	
				LastLRClk <= LRClk; --reset for next edge
				if (LRClk = '1') then
					AdcBitIndex <= "000000"; --reset at MSB of sample
					DacBitIndex <= "000001"; --reset at MSB of sample
				end if;
			end if;

		end if;
		

		if (SClk'event and SClk = '0') then
					
			--if we just finished a sample, better stick it in the adc fifo

			--Left ADC Channel
			if ( (AdcBitIndex = "111100") ) then --idx=60, which is in the middle of the 8 unused clocks for the R channel.
				LastAdcSample <= CurrentAdcSample(23 downto 0);	
				CurrentDacSample(23 downto 0) <= NextDacSample;				
			end if;

			--Right ADC Channel
			if ( (AdcBitIndex = "011100") ) then --idx=28, which is in the middle of the 8 unused clocks for the L channel.
				LastAdcSample <= CurrentAdcSample(23 downto 0);	
				CurrentDacSample(23 downto 0) <= NextDacSample;				
			end if;

			if ( (AdcBitIndex = "000000") ) then
				SampleStrobe <= '1';					
				nSampleStrobe <= '0';
			end if;

			if ( (AdcBitIndex = "100000") ) then
				SampleStrobe <= '0'; --50% duty approx
				nSampleStrobe <= '1';					
			end if;

			--put each bit into/from the appropriate location in the sample buffer
			
			if (AdcBitIndex(4 downto 0) < "11000") then --ignore the top 8 MSB's (24 bits of data in 32 bit transaction)
			
				CurrentAdcSample(Conv_INTEGER(AdcBitIndex(4 downto 0))) <= AdcData;
			
			end if;

			if (DacBitIndex(4 downto 0) < "11000") then --ignore the top 8 MSB's (24 bits of data in 32 bit transaction)
			
				DacData <= CurrentDacSample(Conv_INTEGER(DacBitIndex(4 downto 0)));
			
			end if;

		end if; --if (SClk'event and SClk = '1') then

	end process; --process (SClk)

end AnalogBus;
