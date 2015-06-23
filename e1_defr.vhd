
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity e1_defr is
port(E1_in: in STD_LOGIC;--input serial stream
	 E1_CLK_in: in STD_LOGIC;--clock for input stream
	 reset: in STD_LOGIC; -- reset
	 frame_start,byte_ready,sync_ok: out STD_LOGIC;
	-- fr1,fr2: out STD_LOGIC;
	 data: out STD_LOGIC_VECTOR (0 to 7);
	-- erri: out integer range 0 to 3;
	 zero_frame: out STD_LOGIC_VECTOR (0 to 7)--;
	-- output: out STD_LOGIC_VECTOR (1 downto 0)
	);
end e1_defr ;

architecture BEHAVIOR of e1_defr is

constant BITS_IN_FRAME: integer :=255;--!!!!!!!!!!!!!!!!!!255


SIGNAL frame1_det,frame2_det: STD_LOGIC ;
signal prl_in:STD_LOGIC_VECTOR (0 to 7);
signal state: STD_LOGIC_VECTOR (1 downto 0);

begin
data<=prl_in;
-------------------------------------------------------------------------------------------------------
-- frame1 and frame2  detection
-------------------------------------------------------------------------------------------------------
frame2_det<=prl_in(1);
with prl_in select
	 frame1_det<='1' when "10011011",
		 		 '0' when others;
------------------------------------------------------------------------------------------------------
-- lower bits come first!!!
-- serial to parallel converter
------------------------------------------------------------------------------------------------------
process (E1_CLK_in)
begin
if (FALLING_EDGE(E1_CLK_in)) then
prl_in(0 to 6)<=prl_in(1 to 7);
prl_in(7)<=E1_in;
end if;
end process;

--------------------------------------------------------------------------------------------------------
-- state machine using GRAY CODE (or trying to use GRAY CODE :-) )
-- 00 - waiting for the first frame syncronization sygnal
-- 01 - skipping other frame bits + 8 bits of next syncro signal and trying to detect second frame sync.
-- signal, if all OK go to the 011 state, else to the 000 state
-- 11 - skipping other frame bits + 8 bits of next syncro signal and trying to detect first frame sync.
-- signal, if all OK go to the 010 state, else to the 000 state
-- 10 - start normal data receiving. Syncronizanion complete.
--------------------------------------------------------------------------------------------------------
process (E1_CLK_in,reset)
variable cnt : integer range 0 to 255;
variable s_err: integer range 0 to 3;
variable frame_flag: std_logic;-- determines type of the frame
begin
if (reset='1') then
    state<="00";
elsif (RISING_EDGE(E1_CLK_in)) then
CASE state IS
	WHEN "00" =>
		sync_ok<='0';-- no syncronization
		frame_start<='0';
	    state(0)<=frame1_det; -- waiting for the first frame alignment, if detected go to the next state
		cnt:=0;
		frame_flag:='0';
		s_err:=0;
	WHEN "01" =>
	    if (cnt = BITS_IN_FRAME) then 
			state(0)<=frame2_det;
			state(1)<=frame2_det;
			cnt:=0;
		else
			cnt:=cnt+1;
		end if;
	WHEN "11" =>
		if (cnt = BITS_IN_FRAME) then 
			state(0)<='0';
			state(1)<=frame1_det;
			cnt:=0;
		else
			cnt:=cnt+1;
		end if;
	WHEN "10" =>
		sync_ok<='1';-- syncronization established
		if (cnt = BITS_IN_FRAME) then 
			if(frame_flag='0') then -- detecting wrong syncro signal ?????? according to g704
				zero_frame<=prl_in;--store zero frame for future transmission
				if(frame2_det='0') then
					s_err:=s_err+1;
				else
					s_err:=0;
				end if;
			end if;
			cnt:=0;
			frame_start<='0';-- frame ended
			frame_flag:=not(frame_flag);-- change type of zero time-slot
		else
--byte_ready placed there to avoid byte_ready generation then time-slot 0 received (cnt = BITS_IN_RFAME)			
			frame_start<='1';--frame begins
			byte_ready<=CONV_STD_LOGIC_VECTOR(cnt,3)(0) and CONV_STD_LOGIC_VECTOR(cnt,3)(1) and CONV_STD_LOGIC_VECTOR(cnt,3)(2);
			cnt:=cnt+1;
		end if;
-- if received 3 consecutive wrong frame alignment signals system detect "loss of frame alignment" situation
		state(1)<=not(CONV_STD_LOGIC_VECTOR(s_err,2)(0) and CONV_STD_LOGIC_VECTOR(s_err,2)(1));
	when others=> state<="00";
END CASE;

end if;
end process;

end BEHAVIOR;

