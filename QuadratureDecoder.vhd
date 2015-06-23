library ieee;
use ieee.std_logic_1164.all;

-- c2003 Franks Development, LLC
-- http://www.franks-development.com
-- !This source is distributed under the terms & conditions specified at opencores.org

--How we 'talk' to the outside world:
entity QuadratureDecoderPorts is
    port (
       	clock : 		in std_logic;
       	QuadA : 		in std_logic;
       	QuadB : 		in std_logic;
       	Direction : 	out std_logic;
	   	CountEnable :	out std_logic
    );
end QuadratureDecoderPorts;

--What we 'do':
architecture QuadratureDecoder of QuadratureDecoderPorts is

	--local 'variables' or 'registers'

	--this runs our state machine: where are we in the decoding process?
	--the following constants describe each state
	--note that every possible state is not listed.  the unused states
	--are physically unreachable in a functioning quadratre device, given that the 
	--clock is fast enough to 'catch' each transition on the quadrature inputs
	--LR means left-right, RL = left-right.  Of course the two are reversed
	--if the two quadratre inputs are switched.
	signal state : std_logic_vector(3 downto 0);
	constant Wait0 : std_logic_vector(3 downto 0) := "0000";
	constant Wait1 : std_logic_vector(3 downto 0) := "0001";
	constant Count0 : std_logic_vector(3 downto 0) := "0010";
	constant Count1 : std_logic_vector(3 downto 0) := "0011";
	constant LR1 : std_logic_vector(3 downto 0) := "1001";
	constant LR2 : std_logic_vector(3 downto 0) := "1101";
	constant LR3 : std_logic_vector(3 downto 0) := "0101";
	constant RL1 : std_logic_vector(3 downto 0) := "0100";
	constant RL2 : std_logic_vector(3 downto 0) := "1100";
	constant RL3 : std_logic_vector(3 downto 0) := "1000";
	
	--this is a temp where the two quadrature inputs are stored
	signal Quad : std_logic_vector(1 downto 0);

	--as a single quadrature count is made up of several states, and the decoder
	--can remain in a given state indefinately (if the quadrature input
	--device is not 'moving'), so we need these 'gate-ing' variables
	--to keep us from counting on every clock when we sit idle in the 
	--'count' state; thusly, we just count on the first clock 
	--upon entering a 'count' state.
	signal counted : std_logic;
	signal counting : std_logic;

begin   --architecture QuadratureDecoder

process (clock)
	
	begin --(clock)

	if ( (clock'event) and (clock = '1') ) 	then --every rising edge

		--convert inputs from asynch to synch by assigning once on each rising edge of clock
		Quad(0) <= QuadA;
		Quad(1) <= QuadB;	
		
		--we are not going to be counting on this clock by default
		CountEnable <= '0';

		--we are not in a 'count' state
		if (Counting = '0') then

			Counted <= '0';   --haven't counted when not in count state
			CountEnable <= '0';	 --are not outputing a count either

		end if;

		--we are in a count state
		if (Counting = '1') then

			if (Counted = '1') then	  --note that this is covered by default, but is included for clarity.
				CountEnable <= '0';	  --already counted this one, don't output a count
			end if;

			if (Counted = '0') then	   --we haven't counted it already
				Counted <= '1';	   --make sure we dont count it again on next clock
				CountEnable <= '1';	   --output a count!
			end if;

		end if;

		-- run our state machine
		-- the state transitions are governed by the nature of reality -
		-- vis-a-vis this is what quadratre is.
		-- the '--?' are the physically un-reachable states.
		-- note that it is imperative that the clock be at least (4 I recal)
		-- times faster than the maximum transition rate on each quadratre
		-- input, or else transitions will occur in between clocks, corrupting
		-- the state of the decoder.  Put differently, the quadratre device must
		-- physically remain in each state for at least a single clock
		-- or state changes will not be 'captured' and decoder output will be bogus.
		-- which is substancially the case with any clock-based logic.
		-- the difference is that a normal glitch is any change in input which
		-- has duration less than a single clock, but in quadrature, as single
		-- transition of the actual device cases 4 transitions in the state,
		-- by design of the quadrature encoding process.
		case state is

			when Wait0 =>
				if (Quad = "00") then state <= Wait0; end if;
				if (Quad = "01") then state <= RL1; end if;
				if (Quad = "10") then state <= LR1; end if;
				if (Quad = "11") then state <= Wait0; end if; --?
				Counting <= '0';
			
			when Wait1 =>
				if (Quad = "00") then state <= Wait0; end if;
				if (Quad = "01") then state <= RL1; end if;
				if (Quad = "10") then state <= LR1; end if;
				if (Quad = "11") then state <= Wait0; end if; --?
				Counting <= '0';
			
			when Count0 =>
				if (Quad = "00") then state <= Wait0; end if;
				if (Quad = "01") then state <= RL1; end if;
				if (Quad = "10") then state <= LR1; end if;
				if (Quad = "11") then state <= Count0; end if; --?
				Counting <= '1';
			
			when Count1 =>
				if (Quad = "00") then state <= Wait0; end if;
				if (Quad = "01") then state <= RL1; end if;
				if (Quad = "10") then state <= LR1; end if;
				if (Quad = "11") then state <= Count0; end if; --?
				Counting <= '1';
			
			when LR1 =>
				if (Quad = "00") then state <= Wait0; end if;
				if (Quad = "01") then state <= LR1; end if; --?
				if (Quad = "10") then state <= LR1; end if;
				if (Quad = "11") then state <= LR2; end if;
				Direction <= '0';
				Counting <= '0';
			
			when LR2 =>
				if (Quad = "00") then state <= LR2; end if; --?
				if (Quad = "01") then state <= LR3; end if;
				if (Quad = "10") then state <= LR1; end if;
				if (Quad = "11") then state <= LR2; end if; --?
				Direction <= '0';
				Counting <= '0';
			
			when LR3 =>
				if (Quad = "00") then state <= Count0; end if;
				if (Quad = "01") then state <= LR3; end if;
				if (Quad = "10") then state <= LR3; end if; --?
				if (Quad = "11") then state <= LR2; end if;
				Direction <= '0';
				Counting <= '0';
			
			when RL1 =>
				if (Quad = "00") then state <= Wait0; end if;
				if (Quad = "01") then state <= RL1; end if;
				if (Quad = "10") then state <= RL1; end if; --?
				if (Quad = "11") then state <= RL2; end if;
				Direction <= '1';
				Counting <= '0';
			
			when RL2 =>
				if (Quad = "00") then state <= RL2; end if; --?
				if (Quad = "01") then state <= RL1; end if;
				if (Quad = "10") then state <= RL3; end if;
				if (Quad = "11") then state <= RL2; end if; --?
				Direction <= '1';
				Counting <= '0';
			
			when RL3 =>
				if (Quad = "00") then state <= Count0; end if;
				if (Quad = "01") then state <= RL3; end if; --?
				if (Quad = "10") then state <= RL3; end if;
				if (Quad = "11") then state <= RL2; end if;
				Direction <= '1';
				Counting <= '0';
			
			when others => state <= Wait0; -- undefined state; just go back to wait so we don't get stuck here...

		end case; --state
    
	end if; --clock'event

	end process; --(clock)
      
end QuadratureDecoder;



