library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Constants.all;
 
entity FSM is
    port (reset, clk : in  std_logic;
		strobe : out std_logic;
		sample : out std_logic;
		analyse : out std_logic;
		store : out std_logic;
		produce : out std_logic;
		release : out std_logic;
		debounced : in std_logic;
		keychanged : in std_logic; --keychange found
		keyreleased : in std_logic
	);
end FSM;

architecture FSM_arc of FSM is
    signal nState, cState : states;
begin

    process
    begin
    wait until rising_edge(clk);
	   if( reset = '1' ) then 
	    cState <= idle;
	   else
	    cState <= nState;
	   end if;
    end process;

    process(cState, debounced, keychanged, keyreleased) 
        
    begin
		case cState is

		when idle =>						nState <= strobing;

		when strobing =>					nState <= sampling;
		
		when sampling =>					nState <= analysing;
		
		when analysing =>					if (debounced='1') then
													nState <= storing;
												else
													nState <= analysing;
												end if;

		when storing =>		 	 	 nState <= storing_stage2;	
		
		when storing_stage2 => if (keychanged='1' and keyreleased='0') then
													nState <= producenormal;
												elsif(keychanged='1' and keyreleased='1') then
													nState <= producerelease;
												elsif (keychanged='0') then 	
													nState <= strobing;
												end if;
  
		when producenormal =>			nState <= strobing;
		                           
		when producerelease =>			nState <= strobing;
	
		when others => 					nState <= idle;
            
      end case;

	end process;

	strobe <= cState(6);
	sample <= cState(5);
	analyse <= cState(4);
	store <= cState(3);
	produce <= cState(2);
	release <= cState(1);
	
	end FSM_arc;    
