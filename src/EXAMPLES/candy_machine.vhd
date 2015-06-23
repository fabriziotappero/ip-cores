library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.asci_types.all;

entity candy_machine is
  generic( one_sec_factor : INTEGER := 1e5/2-1;  -- 1e8/2-1 for 1s; change to 5
-- for synthesis (1 ms period)
           ok_factor : INTEGER := 6000;  --change to 5000 for synthesis
           period_factor : INTEGER := 300;  --50ms
           problem_factor : INTEGER := 1000);
  port( clk : in std_logic;
-- j_left=5cent, j_up=10cent, j_right=20cent, j_down=rst
        j_down, j_up, j_left, j_right : IN std_logic;
--        money_rest : out STD_LOGIC_VECTOR (2 DOWNTO 0);
-- if '1' the machine gives all the money in the temp. save out
--        money_error : OUT std_vector;
-- if '1' gives a candy out
--        candy : out std_logic;
-- "0001"=candy, "0010"=5cent, "0100"=10cent, "1000"=20cent, "1110"=error
        led : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        lcd_print  : OUT lcd_matrix );
end candy_machine;


architecture behavioral of candy_machine is
  TYPE state IS (s0, s5, s10, s15, s20, s25, s30, s35, s40, problem, wait_before_s5,
                 wait_before_s10, wait_before_s15, wait_before_s20);
  signal pr_state, nxt_state : state;
  signal money : STD_LOGIC_VECTOR (2 DOWNTO 0);  -- "100"=5cent "010"=10cent "001"=20cent
  signal one_sec, rst_int : STD_LOGIC := '0';
  signal counter : INTEGER RANGE 0 TO ok_factor; 
  SIGNAL rst : STD_LOGIC := '1';
begin

  
time_p: process(clk)  
  variable temp0 : integer RANGE 0 TO ok_factor;
  VARIABLE flag : STD_LOGIC := '0';
BEGIN
    IF clk'EVENT AND clk='1' THEN
      IF rst_int='0' THEN 
        temp0 := 0;
        flag := '1';                    -- because of the one_sec_p process
      else                
        IF one_sec='0' THEN
          flag := '0';
--this part is executed only on a
--positive transition of the one_sec signal, the counter factors multiply the
--period of the one_sec signal. If you need to speed up the execution change
--the on_sec_factor to a lower VALUE
        elsif flag='0' THEN
          flag := '1';
          IF
            temp0>=ok_factor THEN
            temp0 := 0;
          ELSE
            temp0 := temp0 + 1;
          end if;
        END if;
      END if;
    END if;
    counter <= temp0;
END process;

--------------------------------------------------------------------------------------
-- generates the one_sec signal. Period of the signal is 1s if one_sec_factor=1e8/2-1
-- for 100MHz oszillator
--------------------------------------------------------------------------------------
one_sec_p: process(clk)
  VARIABLE temp : integer RANGE 0 TO one_sec_factor;
  begin
    IF clk'event AND clk='1' THEN
      IF rst_int='0' THEN 
        temp := 0;
        one_sec <= '1';                 -- take a look at lcd1.vhd to see why
      else     
        iF temp>=one_sec_factor THEN
          temp := 0;
          one_sec <= NOT one_sec;
        else
          temp := temp + 1;
        END if;
      END if;
    END IF;
  END process;

-------------------------------------------------------------------------------
-- LCD matrix
-------------------------------------------------------------------------------
lcd_m: process(clk)
  BEGIN
    IF clk'EVENT AND clk='1' THEN
      CASE pr_state IS
        WHEN s0 =>
          lcd_print <=  ( '-','-','-','C','o','f','f','e','e',' ','A','u','t','o','m','a','t','-','-','-',
                      ' ',' ',' ',' ',' ',' ',' ',' ','-','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ', 
                      ' ','P','l','e','a','s','e',' ','i','n','s','e','r','t',':',' ','2','5','c',' ', 
                      ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' );
        WHEN s5 | wait_before_s5 =>
          lcd_print <=  ( '-','-','-','C','o','f','f','e','e',' ','A','u','t','o','m','a','t','-','-','-',
                      ' ',' ',' ',' ',' ',' ',' ',' ','-','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ', 
                      ' ','P','l','e','a','s','e',' ','i','n','s','e','r','t',':',' ','2','0','c',' ', 
                      ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' );
        WHEN s10 | wait_before_s10 =>
          lcd_print <=  ( '-','-','-','C','o','f','f','e','e',' ','A','u','t','o','m','a','t','-','-','-',
                      ' ',' ',' ',' ',' ',' ',' ',' ','-','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ', 
                      ' ','P','l','e','a','s','e',' ','i','n','s','e','r','t',':',' ','1','5','c',' ', 
                      ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' );
        WHEN s15 | wait_before_s15 =>
          lcd_print <=  ( '-','-','-','C','o','f','f','e','e',' ','A','u','t','o','m','a','t','-','-','-',
                      ' ',' ',' ',' ',' ',' ',' ',' ','-','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ', 
                      ' ','P','l','e','a','s','e',' ','i','n','s','e','r','t',':',' ','1','0','c',' ', 
                      ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' );          
        WHEN s20 | wait_before_s20 =>
          lcd_print <=  ( '-','-','-','C','o','f','f','e','e',' ','A','u','t','o','m','a','t','-','-','-',
                      ' ',' ',' ',' ',' ',' ',' ',' ','-','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ', 
                      ' ','P','l','e','a','s','e',' ','i','n','s','e','r','t',':',' ',' ','5','c',' ', 
                      ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' );
        WHEN s25 =>
          lcd_print <=  ( '-','-','-','C','o','f','f','e','e',' ','A','u','t','o','m','a','t','-','-','-',
                      ' ',' ',' ',' ',' ',' ',' ',' ','-','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ', 
                      'Y','o','u','r',' ','c','o','f','f','e',' ','i','s',' ','r','e','a','d','y','!', 
                      ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' );          
        WHEN s30 =>
          lcd_print <=  ( '-','-','-','C','o','f','f','e','e',' ','A','u','t','o','m','a','t','-','-','-',
                      ' ',' ',' ',' ',' ',' ',' ',' ','-','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ', 
                      'Y','o','u','r',' ','c','o','f','f','e',' ','i','s',' ','r','e','a','d','y','!', 
                      'Y','o','u',' ','h','a','v','e',':',' ','5','c',' ',' ','c','h','a','n','g','e' );          
        WHEN s35 =>
          lcd_print <=  ( '-','-','-','C','o','f','f','e','e',' ','A','u','t','o','m','a','t','-','-','-',
                      ' ',' ',' ',' ',' ',' ',' ',' ','-','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ', 
                      'Y','o','u','r',' ','c','o','f','f','e',' ','i','s',' ','r','e','a','d','y','!', 
                      'Y','o','u',' ','h','a','v','e',':',' ','1','0','c',' ','c','h','a','n','g','e' );          
        WHEN s40 =>
          lcd_print <=  ( '-','-','-','C','o','f','f','e','e',' ','A','u','t','o','m','a','t','-','-','-',
                      ' ',' ',' ',' ',' ',' ',' ',' ','-','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ', 
                      'Y','o','u','r',' ','c','o','f','f','e',' ','i','s',' ','r','e','a','d','y','!', 
                      'Y','o','u',' ','h','a','v','e',':',' ','1','5','c',' ','c','h','a','n','g','e' );          
        WHEN OTHERS =>
          lcd_print <=  ( '-','-','-','C','o','f','f','e','e',' ','A','u','t','o','m','a','t','-','-','-',
                      ' ',' ',' ',' ',' ',' ',' ',' ','-','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ', 
                      ' ',' ',' ',' ',' ',' ',' ','E','r','r','o','r','!',' ',' ',' ',' ',' ',' ',' ', 
                      ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' );          
      END CASE;
    END IF;
  END process;
  
---------------------------------------------------------------------------------
-- this is a MORE automat, in order to save some registers, you can use MAELY too
---------------------------------------------------------------------------------
main_s_p: process(clk)
  begin
    if clk'event and clk='1' then
      IF rst='0' THEN
        pr_state <= s0;
      else
        pr_state <= nxt_state;
      end if;
    END if;
  end process;


main_c_p: process(pr_state,money,counter)
begin
  case pr_state is
      WHEN s0 =>
        CASE money IS
          WHEN "000" => nxt_state <= s0;
          WHEN "100" => nxt_state <= wait_before_s5;  
          WHEN "010" => nxt_state <= wait_before_s10;  
          WHEN "001" => nxt_state <= wait_before_s20;  
          WHEN OTHERS => nxt_state <= problem;
        END CASE;
        rst_int <= '0';
        led <= "0000";
      WHEN s5 =>
        CASE money IS
          WHEN "000" => nxt_state <= s5;
          WHEN "100" => nxt_state <= wait_before_s10;  
          WHEN "010" => nxt_state <= wait_before_s15;  
          WHEN "001" => nxt_state <= s25;
          WHEN OTHERS => nxt_state <= problem;
        END CASE;
        rst_int <= '0';
        led <= "1000";
      WHEN s10 =>
        CASE money IS
          WHEN "000" => nxt_state <= s10;
          WHEN "100" => nxt_state <= wait_before_s15;
          WHEN "010" => nxt_state <= wait_before_s20;
          WHEN "001" => nxt_state <= s30;
          WHEN OTHERS => nxt_state <= problem;
        END CASE;
        rst_int <= '0';
        led <= "0100";
      WHEN s15 =>
        CASE money IS
          WHEN "000" => nxt_state <= s15;
          WHEN "100" => nxt_state <= wait_before_s20;  
          WHEN "010" => nxt_state <= s25;
          WHEN "001" => nxt_state <= s35;  
          WHEN OTHERS => nxt_state <= problem;
        END CASE;
        rst_int <= '0';
        led <= "1100";
      WHEN s20 =>
        CASE money IS
          WHEN "000" => nxt_state <= s20;
          WHEN "100" => nxt_state <= s25;
          WHEN "010" => nxt_state <= s30;  
          WHEN "001" => nxt_state <= s40;  
          WHEN OTHERS => nxt_state <= problem;
        END CASE;
        led <= "0010";
        rst_int <= '0';
      WHEN s25 =>
        IF counter>=ok_factor THEN
          nxt_state <= s0;
        ELSE
          nxt_state <= s25;
        END IF;
        led <= "0001";
        rst_int <= '1';
      WHEN s30 =>
        IF counter>=ok_factor THEN
          nxt_state <= s0;
        ELSE
          nxt_state <= s30;
        END IF;
        led <= "1001";
        rst_int <= '1';
      WHEN s35 =>
        IF counter>=ok_factor THEN
          nxt_state <= s0;
        ELSE
          nxt_state <= s35;
        END IF;
        led <= "0101";
        rst_int <= '1';
      WHEN s40 =>
        IF counter>=ok_factor THEN
          nxt_state <= s0;
        ELSE
          nxt_state <= s40;
        END IF;
        led <= "1101";
        rst_int <= '1';
--      WHEN rst_before_s5 =>
--        nxt_state <= wait_before_s5;
--        led <= "0000";
--        rst_int <= '0';
--      WHEN rst_before_s10 =>
--        nxt_state <= wait_before_s10;
--        led <= "0000";
--        rst_int <= '0';
--      WHEN rst_before_s15 =>
--        nxt_state <= wait_before_s15;
--        led <= "0000";
--        rst_int <= '0';
--      WHEN rst_before_s20 =>
--        nxt_state <= wait_before_s20;
--        led <= "0000";
--        rst_int <= '0';
      WHEN wait_before_s5 =>
        IF counter>=period_factor THEN
          nxt_state <= s5;
        ELSE
          nxt_state <= wait_before_s5;
        END IF;
        led <= "1000";
        rst_int <= '1';
      WHEN wait_before_s10 =>
        IF counter>=period_factor THEN
          nxt_state <= s10;
        ELSE
          nxt_state <= wait_before_s10;
        END IF;
        led <= "0100";
        rst_int <= '1';
      WHEN wait_before_s15 =>
        IF counter>=period_factor THEN
          nxt_state <= s15;
        ELSE
          nxt_state <= wait_before_s15;
        END IF;
        led <= "1100";
        rst_int <= '1';
      WHEN wait_before_s20 =>
        IF counter>=period_factor THEN
          nxt_state <= s20;
        ELSE
          nxt_state <= wait_before_s20;
        END IF;
        led <= "0010";        
        rst_int <= '1';
      WHEN problem =>
        IF counter>=problem_factor THEN
          nxt_state <= s0;
        ELSE
          nxt_state <= problem;
        END IF;
        led <= "1110";
        rst_int <= '1';
      WHEN OTHERS =>
        nxt_state <= problem;
        led <= "1110";
        rst_int <= '0';
    END case;
  END process;

  rst <= j_down;
  money(2) <= NOT j_left;
  money(1) <= NOT j_up;
  money(0) <= NOT j_right;

END behavioral;
