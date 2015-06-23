library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity lightshow is
   port(
      led1     : out std_logic_vector(9 downto 0);   -- LED1 on debug board
      led2     : out std_logic_vector(19 downto 0);  -- LED2 + LED3 on debug board
      sw       : in std_logic_vector(3 downto 0);
      fxclk    : in std_logic
   );
end lightshow;

--signal declaration
architecture RTL of lightshow is

type tPattern1 is array(9 downto 0) of integer range 0 to 255;
type tPattern2 is array(19 downto 0) of integer range 0 to 255;

signal pattern1  : tPattern1 := (0, 10, 41, 92, 163, 255, 163, 92, 41, 10);   					-- pattern for LED1
signal pattern20 : tPattern2 := (0, 1, 2, 9, 16, 25, 36, 49, 64, 81, 64, 49, 36, 25, 16, 9, 2, 1, 0, 0);	-- 1st pattern for LED2
signal pattern21 : tPattern2 := (0, 19, 77, 174, 77, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);		-- 2nd pattern for LED2
signal pattern2  : tPattern2; 											-- pattern20 + pattern21

signal cnt1,cnt20, cnt21  : std_logic_vector(22 downto 0);
signal pwm_cnt            : std_logic_vector(19 downto 0);
signal pwm_cnt8           : std_logic_vector(7 downto 0);

begin
    pwm_cnt8 <= pwm_cnt(19 downto 12);
    
    dp_fxclk: process(fxclk)
    begin
         if fxclk' event and fxclk = '1' then
	    
	    -- pattern for led 1
	    if ( cnt1 >= conv_std_logic_vector(7200000,23) )  -- 1/1.5 Hz
	    then
		if ( sw(0) = '1' )
		then
		    pattern1(8 downto 0) <= pattern1(9 downto 1);
		    pattern1(9) <= pattern1(0);
		else
		    pattern1(9 downto 1) <= pattern1(8 downto 0);
		    pattern1(0) <= pattern1(9);
		end if;
    		cnt1  <= (others => '0');
    	    else
		cnt1 <= cnt1  + 1;
	    end if;

	    -- pattern for led 2
	    if ( ( cnt20 >= conv_std_logic_vector(4800000,23) ) or ( (sw(2)= '1') and (cnt20 >= conv_std_logic_vector(1600000,23)) ) )  -- SW1 off: 1/3Hz, SW1 on: 1Hz
	    then
		pattern20(18 downto 0) <= pattern20(19 downto 1);
		pattern20(19) <= pattern20(0);
		cnt20 <= (others => '0');
	    else
		cnt20 <= cnt20 + 1;
	    end if;

	    if ( ( cnt21 >= conv_std_logic_vector(2000000,23) ) or ( (sw(3)= '1') and (cnt21 >= conv_std_logic_vector(500000,23)) ) )
	    then
		if ( sw(1) = '1' )
		then
		    pattern21(18 downto 0) <= pattern21(19 downto 1);
		    pattern21(19) <= pattern21(0);
		else
		    pattern21(19 downto 1) <= pattern21(18 downto 0);
		    pattern21(0) <= pattern21(19);
		end if;
		cnt21 <= (others => '0');
	    else
		cnt21 <= cnt21 + 1;
	    end if;

	    for i in 0 to 19 loop
		pattern2(i) <= pattern20(i) + pattern21(i);
	    end loop;
	    
	    -- pwm
	    if ( pwm_cnt8 = conv_std_logic_vector(255,8) )
	    then
		pwm_cnt <= ( others => '0' );
	    else
		pwm_cnt <= pwm_cnt + 1;
	    end if;
	    -- led1
	    for i in 0 to 9 loop
		if ( pwm_cnt8 < pattern1(i) ) 
		then
		    led1(i) <= '1';
		else
		    led1(i) <= '0';
		end if;
	    end loop;
	    for i in 0 to 19 loop
		if (pwm_cnt8 < pattern2(i) ) 
		then
		    led2(i) <= '1';
		else
		    led2(i) <= '0';
		end if;
	    end loop;

	end if;
    end process dp_fxclk;
    
end RTL;
