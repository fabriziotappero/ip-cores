library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity e1_frm is
port(E1_out,nr: out STD_LOGIC;--output serial stream
	 E1_CLK_in: in STD_LOGIC;--clock for output stream
	 reset: in STD_LOGIC; -- reset
	 frame_start,RD: out STD_LOGIC;-- determines frame start, RD - read signal for "look forvard" memory
	 data: in STD_LOGIC_VECTOR (0 to 7);
	 zero_frame: in STD_LOGIC_VECTOR (0 to 7)-- zero frame data

	 --isEmpty : in STD_LOGIC
	);
end e1_frm;

architecture BEHAVIOR of e1_frm is

SIGNAL cnt: integer range 0 to 7;
signal ires,state,frame_type: STD_LOGIC;
signal iData: STD_LOGIC_VECTOR (0 to 7);

begin
nr<=ires;
------------------------------------------------------------------------------------------------------
-- lower bits come first!!!
-- parallel to serial converter
------------------------------------------------------------------------------------------------------
process (E1_CLK_in,ires)
begin
if (ires='1') then
    cnt<=0;
	E1_out<='0';
elsif (FALLING_EDGE(E1_CLK_in)) then
	E1_out<=iData(cnt);
	cnt<=cnt+1;
end if;
end process;

--------------------------------------------------------------------------------------------------------
--this trigger is used to eliminate "short reset" situation: when reset becomes low during "high" E1_CLK_in
--in this situation transmitter starts before state machine set up valid iData signal
--------------------------------------------------------------------------------------------------------
process (E1_CLK_in,reset)
begin
if (reset='1') then
    ires<='1';
elsif (FALLING_EDGE(E1_CLK_in)) then
	ires<='0';
end if;
end process;

--------------------------------------------------------------------------------------------------------
-- state machine 
-- 0 - zero time slot generation.
-- 1 - transmission
--------------------------------------------------------------------------------------------------------
process (E1_CLK_in,ires)
variable byte_cnt: integer range 0 to 31;
begin
if (ires='1') then
    state<='0';
	frame_type<='0';
elsif (RISING_EDGE(E1_CLK_in)) then
CASE state IS
	WHEN '0' =>
		byte_cnt:=0;
		frame_start<='1';
		if(frame_type='0') then
			iData<="10011011";
		else
			iData(0)<=zero_frame(0);
			iData(2 to 7)<=zero_frame(2 to 7);
			iData(1)<='1';--warranty of correct frame signal
		end if;
	    state<=CONV_STD_LOGIC_VECTOR(cnt,3)(0) and CONV_STD_LOGIC_VECTOR(cnt,3)(1) and CONV_STD_LOGIC_VECTOR(cnt,3)(2);
	WHEN '1' =>
	    frame_start<='0';
		if (cnt = 0) then 
			iData<=data;
			RD<='1';
		else
			RD<='0';
		end if;
		if(cnt=7)then
			if(byte_cnt=30) then 
				state<='0';-- frame trensmitted
				frame_type<=not(frame_type);
			else
				byte_cnt:=byte_cnt+1;
			end if;
		end if;
	when others=> state<='0';
END CASE;
end if;
end process;

end BEHAVIOR;

