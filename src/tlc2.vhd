library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tlc2 is
  generic( freq : integer := 1e8; -- 100 MHz, use 100 Hz (1e2) for simulation and run 5 ms
           max_period_factor : INTEGER := 45;  --the period of the longest signal (green)
           idle_period_factor : integer := 1;  -- 1 sec blinking interval
           green_period_factor : integer := 45;	-- 45 sec green interval
           orange_period_factor : integer := 5; -- 5 sec orange interval 
           red_period_factor : integer := 30; -- 30 sec red interval
           red_orange_period_factor : integer := 5); -- 5 sec red_orange interval
  port( clk, rst : in std_logic;        -- low - active reset
        j_left, j_right : IN std_logic; -- j_right turns normal mode, j_left turns test mode, both signals are low active
        led : out std_logic_vector (2 downto 0) ); -- {RED|ORANGE|GREEN}, RED is MSB
end tlc2;

architecture behavioral of tlc2 is
  type state is (idle0, idle1, green, orange, red, red_orange, rst_before_idle1, rst_before_idle0, rst_before_green, rst_before_orange, rst_before_red, rst_before_red_orange);
  signal pr_state, nxt_state : state;
  signal pr_state_mode, nxt_state_mode : std_logic :='0';  -- state signals for the joystick encoder
  signal led_int : std_logic_vector (2 downto 0); -- internal led signal used to invert the output if neccessary 
  SIGNAL one_sec : std_logic := '0'; -- signal with 1s period used as time basis
  SIGNAL mode : std_logic := '0'; -- changes between test end normal mode, triggered by the joystick decoder
  SIGNAL rst_int : STD_LOGIC := '1';  --used to reset the period-signals after state transition
  SIGNAL counter : INTEGER RANGE 0 TO max_period_factor := 0;
  constant one_sec_factor : integer := freq-1;
begin

-------------------------------------------------------------------------------
-- Simple FSM for the joystick encoder. Generats the mode - signal.
-------------------------------------------------------------------------------
mode_s_p: process(clk)      
begin
  if clk'event and clk='1' then
    IF rst='0' THEN
      pr_state_mode <= '0';
    else
      pr_state_mode <= nxt_state_mode;
    END if;
  end if;
end process;

mode_c_p: process(pr_state_mode,j_right,j_left)
begin
  CASE pr_state_mode IS
    WHEN '0' => IF j_right='0' and j_left='1' THEN
                  nxt_state_mode <= '1';
                ELSE
                  nxt_state_mode <= '0';
                END if;
                mode <= '0';
    WHEN OTHERS => IF j_left='0' THEN
                     nxt_state_mode <= '0';
                   ELSE
                     nxt_state_mode <= '1';
                   END if;
                   mode <= '1';
  END CASE;
END process;

-------------------------------------------------------------------------------
-- period-signal generator
-------------------------------------------------------------------------------
time_p: process(clk)      
  variable temp0 : integer RANGE 0 TO max_period_factor;
  VARIABLE flag : STD_LOGIC := '0';
BEGIN
  IF clk'EVENT AND clk='1' THEN
    IF rst_int='0' THEN -- a 0 level signal is needed by the current state of the main fsm
      temp0 := 0; 
    else                   
      IF one_sec='0' THEN
        flag := '0';
      END IF;
      IF one_sec='1' AND  flag='0' THEN  --this part is executed only on a
--positive transition of the one_sec signal. The counter factors multiply the
--period of the one_sec signal. If you need to speed up the execution change
--the on_sec_factor to a lower value. This us usefull for simulation purposes
        flag := '1';
        IF
          temp0=max_period_factor THEN
          temp0 := 0;
        ELSE
          temp0 := temp0 + 1;
        end if;
      END if;
    END if;
  END if;
  counter <= temp0;
END process;

-------------------------------------------------------------------------------
-- 1 sec time basis signal generator. Generate a signal with 2 sec period.
-------------------------------------------------------------------------------
one_sec_p: process(clk)
  VARIABLE temp : integer RANGE 0 TO one_sec_factor;
begin
  IF clk'event AND clk='1' THEN
    IF rst_int='0' THEN 
      temp := 0;
      one_sec <= '0';
    else
      iF temp>=one_sec_factor THEN
        temp := 0;
        one_sec <= '1';
      else
        temp := temp + 1;
        one_sec <= '0';
      END if;
    END if;
  END IF;
END process;

-------------------------------------------------------------------------------
-- main FSM
-------------------------------------------------------------------------------
main_s_p: process(clk)         
  begin
    if clk'event and clk='1' then
      IF rst='0' THEN
        pr_state <= idle0;
      else
        pr_state <= nxt_state;
      end if;
    END if;
  end process;

main_c_p: process(pr_state,mode,counter)
begin
    case pr_state is
      WHEN idle0 =>     	IF mode='0' then
                                  IF counter>=idle_period_factor THEN
                                    nxt_state <= rst_before_idle1;
                                  ELSE
                                    nxt_state <= idle0;
                                  END IF;
                                ELSE
                                  nxt_state <= rst_before_green;
                                END if;
                                led_int <= "010";
                                rst_int <= '1';
      when idle1 =>     	if mode='0' then
                                  IF counter>=idle_period_factor THEN
                                    nxt_state <= rst_before_idle0;
                                  ELSE
                                    nxt_state <= idle1;
                                  END IF;
                                ELSE
                                  nxt_state <= rst_before_green;
                                END if;
                                led_int <= "000";
                                rst_int <= '1';
      when green =>		if mode='1' then 
                                  if counter>=green_period_factor THEN
                                    nxt_state <= rst_before_orange;
                                  ELSE
                                    nxt_state <= green;
                                  END if;
                                ELSE
                                  nxt_state <= rst_before_idle0;
                                end if;
                                led_int <= "001";
                                rst_int <= '1';
      WHEN orange =>            if mode='1'then
                                  if counter>=orange_period_factor THEN
                                    nxt_state <= rst_before_red;
                                  ELSE
                                    nxt_state <= orange;
                                  END if;
                                ELSE
                                  nxt_state <= rst_before_idle0;
                                END if;
                                led_int <= "010";
                                rst_int <= '1';
      WHEN red =>               if mode='1' THEN
                                  if counter>=red_period_factor THEN
                                    nxt_state <= rst_before_red_orange;
                                  ELSE
                                    nxt_state <= red;
                                  END if;
                                ELSE
                                  nxt_state <= rst_before_idle0;
                                END if;
                                led_int <= "100";
                                rst_int <= '1';
      WHEN red_orange =>        if mode='1' THEN
                                  if counter>=red_orange_period_factor THEN
                                    nxt_state <= rst_before_green;
                                  ELSE
                                    nxt_state <= red_orange;
                                  END if;
                                ELSE
                                  nxt_state <= rst_before_idle0;
                                END if;
                                led_int <= "110";
                                rst_int <= '1';
      WHEN rst_before_idle1 =>  nxt_state <= idle1;
                                led_int <= "000";
                                rst_int <= '0';
      WHEN rst_before_green =>  nxt_state <= green;
                                led_int <= "001";
                                rst_int <= '0';
      WHEN rst_before_orange => nxt_state <= orange;
                                led_int <= "010";
                                rst_int <= '0';
      WHEN rst_before_red =>    nxt_state <= red;
                                led_int <= "100";
                                rst_int <= '0';
      WHEN rst_before_red_orange => nxt_state <= red_orange;
                                    led_int <= "110";
                                    rst_int <= '0';
      WHEN OTHERS =>            nxt_state <= idle0;
                                led_int <= "010";
                                rst_int <= '0';
    END case;
  END process;
  led <= led_int;
END behavioral;
