library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

-- c2003 Franks Development, LLC
-- http://www.franks-development.com
-- !This source is distributed under the terms & conditions specified at opencores.org

--resource or companion to this code: 
	-- Xilinx Application note 12 - "Quadrature Phase Decoder" - xapp012.pdf
	-- no longer appears on xilinx website (to best of my knowledge), perhaps it has been superceeded?

--this code was origonally intended for use on Xilinx XPLA3 'coolrunner' CPLD devices
--origonally compiled/synthesized with Xilinx 'Webpack' 5.2 software

--How we 'talk' to the outside world:
entity QuadratureCounterPorts is
    Port ( clock : in std_logic;	--system clock, i.e. 10MHz oscillator
		 QuadA : in std_logic;	--first input from quadrature device  (i.e. optical disk encoder)
		 QuadB : in std_logic;	--second input from quadrature device (i.e. optical disk encoder)
		 CounterValue : out std_logic_vector(15 downto 0) --just an example debuggin output
		);
end QuadratureCounterPorts;

--What we 'do':
architecture QuadratureCounter of QuadratureCounterPorts is

	-- local 'variables' or 'registers'
	
	--This is the counter for how many quadrature ticks have gone past.
	--the size of this counter is dependant on how far you need to count
	--it was origonally used with a circular disk encoder having 2048 ticks/revolution
	--thus this 16-bit count could hold 2^15 ticks in either direction, or a total
	--of 32768/2048 = 16 revolutions in either direction.  if the disk
	--was turned more than 16 times in a given direction, the counter overflows
	--and the origonal location is lost.  If you had a linear instead of 
	--circular encoder that physically could not move more than 2048 ticks,
	--then Count would only need to be 11 downto 0, and you could count
	--2048 ticks in either direction, regardless of the position of the 
	--encoder at system bootup.
	signal Count : std_logic_vector(15 downto 0);
	
	--this is the signal from the quadrature logic that it is time to change
	--the value of the counter on this clock signal (either + or -)
	signal CountEnable : std_logic;
	
	--should we increment or decrement count?
	signal CountDirection : std_logic;

	--where all the 'work' is done: quadraturedecoder.vhd
	component QuadratureDecoderPorts
    		Port (
        			clock     : in    std_logic;
        			QuadA     : in    std_logic;
        			QuadB     : in    std_logic;
        			Direction : out std_logic;
	   			CountEnable : out std_logic
    			);
	end component;

	begin --architecture QuadratureCounter		 

	--instanciate the decoder
	iQuadratureDecoder: QuadratureDecoderPorts 
	port map	( 
 				clock => clock,
	      		QuadA => QuadA,
 	   			QuadB => QuadB,
    				Direction => CountDirection,
	       		CountEnable => CountEnable
			);


	-- do our actual work every clock cycle
	process(clock)
	begin

		--keep track of the counter
		if ( (clock'event) and (clock = '1') ) then
		
			if (CountEnable = '1') then

				if (CountDirection = '1') then Count <= Count + "0000000000000001"; end if;
				if (CountDirection = '0') then Count <= Count - "0000000000000001"; end if;

			end if;

		end if; --clock'event

		--!!!!!!!!!!!INSERT SOMETHING USEFULL HERE!!!!!!!!!!!
		--This is where you do actual work based on the value of the counter
		--for instance, I will just output the value of the counter
		--led's on an output like this are very useful - you can see the top
		--bits light when moved backwards from initial position (count goes negative)
		CounterValue <= Count;

	end process; --(clock)
				   			  					
end QuadratureCounter;
