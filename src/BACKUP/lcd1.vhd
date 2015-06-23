library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.asci_types.all;

ENTITY lcd1 IS
  generic( one_usec_factor : INTEGER := 1e2/2-1;  -- 1e8/2-1 for 1s at 100MHz
           max_factor : INTEGER := 100000;  -- the biggest delay needed
           init_factor : INTEGER := 100000; -- 100ms
           normal_factor : INTEGER := 50;  -- 50us
           extended_factor : INTEGER := 2000  -- 2ms
         );
  port( clk_400, clk, rst : IN std_logic;
        lcd_rs : OUT std_logic;         -- H=data L=command
        lcd_rw : OUT std_logic;         -- H=read L=write
        lcd_ena : OUT STD_LOGIC;        -- enable at H-L transition , put clock
-- signal with 1 or 4 us period here.
        lcd_data : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) );  -- 7th bit is MSB
END lcd1;


ARCHITECTURE behavioral OF lcd1 IS
  TYPE state IS ( init_start, wait_set1, set1, wait_eset, eset, wait_set2, set2, wait_lcd_on,
                  lcd_on, wait_lcd_clear, lcd_clear, wait_lcd_entr, lcd_entr, 
                  wait_l1s1, l1s1, wait_l1s2, l1s2, wait_l1s3, l1s3, wait_l1s4, l1s4, wait_l1s5, l1s5,
                  wait_l1s6, l1s6, wait_l1s7, l1s7, wait_l1s8, l1s8, wait_l1s9, l1s9, wait_l1s10, l1s10,
                  wait_l1s11, l1s11, wait_l1s12, l1s12, wait_l1s13, l1s13, wait_l1s14, l1s14, wait_l1s15, l1s15,
                  wait_l1s16, l1s16, wait_l1s17, l1s17, wait_l1s18, l1s18, wait_l1s19, l1s19, wait_l1s20, l1s20,
                  wait_l2s1, l2s1, wait_l2s2, l2s2, wait_l2s3, l2s3, wait_l2s4, l2s4, wait_l2s5, l2s5,
                  wait_l2s6, l2s6, wait_l2s7, l2s7, wait_l2s8, l2s8, wait_l2s9, l2s9, wait_l2s10, l2s10,
                  wait_l2s11, l2s11, wait_l2s12, l2s12, wait_l2s13, l2s13, wait_l2s14, l2s14, wait_l2s15, l2s15,
                  wait_l2s16, l2s16, wait_l2s17, l2s17, wait_l2s18, l2s18, wait_l2s19, l2s19, wait_l2s20, l2s20,
                  wait_l3s1, l3s1, wait_l3s2, l3s2, wait_l3s3, l3s3, wait_l3s4, l3s4, wait_l3s5, l3s5,
                  wait_l3s6, l3s6, wait_l3s7, l3s7, wait_l3s8, l3s8, wait_l3s9, l3s9, wait_l3s10, l3s10,
                  wait_l3s11, l3s11, wait_l3s12, l3s12, wait_l3s13, l3s13, wait_l3s14, l3s14, wait_l3s15, l3s15,
                  wait_l3s16, l3s16, wait_l3s17, l3s17, wait_l3s18, l3s18, wait_l3s19, l3s19, wait_l3s20, l3s20,
                  wait_l4s1, l4s1, wait_l4s2, l4s2, wait_l4s3, l4s3, wait_l4s4, l4s4, wait_l4s5, l4s5,
                  wait_l4s6, l4s6, wait_l4s7, l4s7, wait_l4s8, l4s8, wait_l4s9, l4s9, wait_l4s10, l4s10,
                  wait_l4s11, l4s11, wait_l4s12, l4s12, wait_l4s13, l4s13, wait_l4s14, l4s14, wait_l4s15, l4s15,
                  wait_l4s16, l4s16, wait_l4s17, l4s17, wait_l4s18, l4s18, wait_l4s19, l4s19, wait_l4s20, l4s20,
                  wait_new_line1, new_line1, wait_new_line2, new_line2, wait_new_line3, new_line3, wait_new_line4, new_line4,
                  wait_renew );
  signal pr_state, nxt_state : state;
  signal one_usec, rst_int : STD_LOGIC := '0';
  signal counter : INTEGER RANGE 0 TO max_factor; 
  SIGNAL lcd_data_int : STD_LOGIC_VECTOR (9 DOWNTO 0);
  signal str1, lcd_reg : lcd_matrix;
BEGIN
  lcd_reg <= str1;            
  str1 <= ( ' ',' ',' ',' ',' ',' ','T','U',' ','C','h','e','m','n','i','t','z',' ',' ',' ',
            ' ',' ',' ',' ',' ',' ',' ',' ','S','S','E',' ',' ',' ',' ',' ',' ',' ',' ',' ', 
            ' ',' ',' ','D','i','m','o',' ','P','e','p','e','l','y','a','s','h','e','v',' ', 
            ' ',' ',' ',' ',' ',' ',' ',' ',' ','-','-','-',' ',' ',' ',' ',' ',' ',' ',' ' );
  lcd_rw <= '0';                        -- only writing to the LCD needed, lcd_data_int(8) is never used
  lcd_rs <= lcd_data_int(9);
  lcd_data <= lcd_data_int(7 downto 0);
  lcd_ena <= clk_400;
  
--------------------------------------------------------------------------------------
-- generates a signal with 1us period 
--------------------------------------------------------------------------------------
one_sec_p: process(clk)
  VARIABLE temp : integer RANGE 0 TO one_usec_factor;
  begin
    IF clk'event AND clk='1' THEN
      IF rst_int='0' THEN 
        temp := 0;
        one_usec <= '0';
      else     
        iF temp>=one_usec_factor THEN
          temp := 0;
          one_usec <= NOT one_usec;
        else
          temp := temp + 1;
        END if;
      END if;
    END IF;
  END process;


--------------------------------------------------------------------------------------
-- delays generetor
--------------------------------------------------------------------------------------
delay_p: process(clk)  
  variable temp0 : integer RANGE 0 TO max_factor;
  VARIABLE flag : STD_LOGIC := '0';
BEGIN
    IF clk'EVENT AND clk='1' THEN
      IF rst_int='0' THEN 
        temp0 := 0; 
      else                
        IF one_usec='0' AND flag='1' THEN
          flag := '0';
        END IF;
--this part is executed only on a positive transition of the one_usec signal
        IF one_usec='1' AND  flag='0' THEN
          flag := '1';
          IF
            temp0>=max_factor THEN
            temp0 := 0;
          ELSE
            temp0 := temp0 + 1;
          end if;
        END if;
      END if;
    END if;
    counter <= temp0;
END process;

---------------------------------------------------------------------------------
-- MORE automat, in order to save some registers, you can use MAELY too
---------------------------------------------------------------------------------
main_s_p: process(clk)
  begin
    if clk'event and clk='1' then
      IF rst='0' THEN
        pr_state <= init_start;
      else
        pr_state <= nxt_state;
      end if;
    END if;
  end process;


main_c_p: process(pr_state,counter)
begin
  case pr_state is
      WHEN init_start =>
        nxt_state <= wait_set1;
        rst_int <= '0';
        lcd_data_int <= (OTHERS => '0');
      WHEN wait_set1 =>
        IF counter>=init_factor THEN
          nxt_state <= set1;
        ELSE
          nxt_state <= wait_set1;
        END IF;
        lcd_data_int <= (OTHERS => '0');
        rst_int <= '1';
      WHEN set1 =>
        nxt_state <= wait_eset;
        rst_int <= '0';
        lcd_data_int <= "0000110100";      
      WHEN wait_eset =>
        IF counter>=normal_factor THEN
          nxt_state <= eset;
        ELSE
          nxt_state <= wait_eset;
        END IF;
        lcd_data_int <= "0000110100";
        rst_int <= '1';
      WHEN eset =>
        nxt_state <= wait_set2;
        rst_int <= '0';
        lcd_data_int <= "0000001001";
      WHEN wait_set2 =>
        IF counter>=normal_factor THEN
          nxt_state <= set2;
        ELSE
          nxt_state <= wait_set2;
        END IF;
        lcd_data_int <= "0000001001";
        rst_int <= '1';        
      WHEN set2 =>
        nxt_state <= wait_lcd_on;
        rst_int <= '0';
        lcd_data_int <= "0000110000";
      WHEN wait_lcd_on =>
        IF counter>=normal_factor THEN
          nxt_state <= lcd_on;
        ELSE
          nxt_state <= wait_lcd_on;
        END IF;
        lcd_data_int <= "0000110000";
        rst_int <= '1';        
      WHEN lcd_on =>
        nxt_state <= wait_lcd_clear;
        rst_int <= '0';
        lcd_data_int <= "0000001111";
      WHEN wait_lcd_clear =>
        IF counter>=normal_factor THEN
          nxt_state <= lcd_clear;
        ELSE
          nxt_state <= wait_lcd_clear;
        END IF;
        lcd_data_int <= "0000001111";
        rst_int <= '1';
      WHEN lcd_clear =>
        nxt_state <= wait_lcd_entr;
        rst_int <= '0';
        lcd_data_int <= "0000000001";
      WHEN wait_lcd_entr =>
        IF counter>=extended_factor THEN
          nxt_state <= lcd_entr;
        ELSE
          nxt_state <= wait_lcd_clear;
        END IF;
        lcd_data_int <= "0000000001";
        rst_int <= '1';
      WHEN lcd_entr =>
        nxt_state <= wait_l1s1;
        rst_int <= '0';
        lcd_data_int <= "0000000110";
      WHEN wait_l1s1 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s1;
        ELSE
          nxt_state <= wait_l1s1;
        END IF;
        lcd_data_int <= "0000000110";
        rst_int <= '1';        
-------------------------------------------------------------------------------
-- line 1
-------------------------------------------------------------------------------
      WHEN l1s1 =>
        nxt_state <= wait_l1s2;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' &  char2std(lcd_reg(1));
      WHEN wait_l1s2 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s2;
        ELSE
          nxt_state <= wait_l1s2;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(1));
        rst_int <= '1';        
      WHEN l1s2 =>
        nxt_state <= wait_l1s3;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(2));
      WHEN wait_l1s3 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s3;
        ELSE
          nxt_state <= wait_l1s3;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(2));
        rst_int <= '1';        
      WHEN l1s3 =>
        nxt_state <= wait_l1s4;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(3));
      WHEN wait_l1s4 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s4;
        ELSE
          nxt_state <= wait_l1s4;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(3));
        rst_int <= '1';        
      WHEN l1s4 =>
        nxt_state <= wait_l1s5;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(4));
      WHEN wait_l1s5 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s5;
        ELSE
          nxt_state <= wait_l1s5;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(4));
        rst_int <= '1';        
      WHEN l1s5 =>
        nxt_state <= wait_l1s6;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(5));
      WHEN wait_l1s6 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s6;
        ELSE
          nxt_state <= wait_l1s6;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(5));
        rst_int <= '1';        
      WHEN l1s6 =>
        nxt_state <= wait_l1s7;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(6));
      WHEN wait_l1s7 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s7;
        ELSE
          nxt_state <= wait_l1s7;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(6));
        rst_int <= '1';        
      WHEN l1s7 =>
        nxt_state <= wait_l1s8;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(7));
      WHEN wait_l1s8 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s8;
        ELSE
          nxt_state <= wait_l1s8;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(7));
        rst_int <= '1';        
      WHEN l1s8 =>
        nxt_state <= wait_l1s9;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(8));
      WHEN wait_l1s9 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s9;
        ELSE
          nxt_state <= wait_l1s9;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(8));
        rst_int <= '1';        
      WHEN l1s9 =>
        nxt_state <= wait_l1s10;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(9));
      WHEN wait_l1s10 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s10;
        ELSE
          nxt_state <= wait_l1s10;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(9));
        rst_int <= '1';        
      WHEN l1s10 =>
        nxt_state <= wait_l1s11;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(10));
      WHEN wait_l1s11 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s11;
        ELSE
          nxt_state <= wait_l1s11;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(10));
        rst_int <= '1';        
      WHEN l1s11 =>
        nxt_state <= wait_l1s12;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(11));
      WHEN wait_l1s12 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s12;
        ELSE
          nxt_state <= wait_l1s12;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(11));
        rst_int <= '1';        
      WHEN l1s12 =>
        nxt_state <= wait_l1s13;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(12));
      WHEN wait_l1s13 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s13;
        ELSE
          nxt_state <= wait_l1s13;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(12));
        rst_int <= '1';        
      WHEN l1s13 =>
        nxt_state <= wait_l1s14;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(13));
      WHEN wait_l1s14 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s14;
        ELSE
          nxt_state <= wait_l1s14;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(13));
        rst_int <= '1';        
      WHEN l1s14 =>
        nxt_state <= wait_l1s15;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(14));
      WHEN wait_l1s15 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s15;
        ELSE
          nxt_state <= wait_l1s15;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(14));
        rst_int <= '1';        
      WHEN l1s15 =>
        nxt_state <= wait_l1s16;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(15));
      WHEN wait_l1s16 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s16;
        ELSE
          nxt_state <= wait_l1s16;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(15));
        rst_int <= '1';        
      WHEN l1s16 =>
        nxt_state <= wait_l1s17;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(16));
      WHEN wait_l1s17 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s17;
        ELSE
          nxt_state <= wait_l1s17;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(16));
        rst_int <= '1';        
      WHEN l1s17 =>
        nxt_state <= wait_l1s18;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(17));
      WHEN wait_l1s18 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s18;
        ELSE
          nxt_state <= wait_l1s18;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(17));
        rst_int <= '1';        
      WHEN l1s18 =>
        nxt_state <= wait_l1s19;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(18));
      WHEN wait_l1s19 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s19;
        ELSE
          nxt_state <= wait_l1s19;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(18));
        rst_int <= '1';        
      WHEN l1s19 =>
        nxt_state <= wait_l1s20;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(19));
      WHEN wait_l1s20 =>
        IF counter>=normal_factor THEN
          nxt_state <= l1s20;
        ELSE
          nxt_state <= wait_l1s20;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(19));
        rst_int <= '1';        
      WHEN l1s20 =>
        nxt_state <= wait_new_line1;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(20));
      WHEN wait_new_line1 =>
        IF counter>=normal_factor THEN
          nxt_state <= new_line1;
        ELSE
          nxt_state <= wait_new_line1;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(20));
        rst_int <= '1';        
      WHEN new_line1 =>
        nxt_state <= wait_l2s1;
        rst_int <= '0';
        lcd_data_int <= "0010100000";
      WHEN wait_l2s1 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s1;
        ELSE
          nxt_state <= wait_l2s1;
        END IF;
        lcd_data_int <= "0010100000";
        rst_int <= '1';        
-------------------------------------------------------------------------------
-- line 2
-------------------------------------------------------------------------------
      WHEN l2s1 =>
        nxt_state <= wait_l2s2;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(21));
      WHEN wait_l2s2 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s2;
        ELSE
          nxt_state <= wait_l2s2;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(21));
        rst_int <= '1';        
      WHEN l2s2 =>
        nxt_state <= wait_l2s3;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(22));
      WHEN wait_l2s3 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s3;
        ELSE
          nxt_state <= wait_l2s3;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(22));
        rst_int <= '1';        
      WHEN l2s3 =>
        nxt_state <= wait_l2s4;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(23));
      WHEN wait_l2s4 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s4;
        ELSE
          nxt_state <= wait_l2s4;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(23));
        rst_int <= '1';        
      WHEN l2s4 =>
        nxt_state <= wait_l2s5;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(24));
      WHEN wait_l2s5 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s5;
        ELSE
          nxt_state <= wait_l2s5;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(24));
        rst_int <= '1';        
      WHEN l2s5 =>
        nxt_state <= wait_l2s6;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(25));
      WHEN wait_l2s6 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s6;
        ELSE
          nxt_state <= wait_l2s6;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(25));
        rst_int <= '1';        
      WHEN l2s6 =>
        nxt_state <= wait_l2s7;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(26));
      WHEN wait_l2s7 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s7;
        ELSE
          nxt_state <= wait_l2s7;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(26));
        rst_int <= '1';        
      WHEN l2s7 =>
        nxt_state <= wait_l2s8;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(27));
      WHEN wait_l2s8 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s8;
        ELSE
          nxt_state <= wait_l2s8;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(27));
        rst_int <= '1';        
      WHEN l2s8 =>
        nxt_state <= wait_l2s9;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(28));
      WHEN wait_l2s9 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s9;
        ELSE
          nxt_state <= wait_l2s9;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(28));
        rst_int <= '1';        
      WHEN l2s9 =>
        nxt_state <= wait_l2s10;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(29));
      WHEN wait_l2s10 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s10;
        ELSE
          nxt_state <= wait_l2s10;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(29));
        rst_int <= '1';        
      WHEN l2s10 =>
        nxt_state <= wait_l2s11;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(30));
      WHEN wait_l2s11 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s11;
        ELSE
          nxt_state <= wait_l2s11;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(30));
        rst_int <= '1';        
      WHEN l2s11 =>
        nxt_state <= wait_l2s12;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(31));
      WHEN wait_l2s12 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s12;
        ELSE
          nxt_state <= wait_l2s12;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(31));
        rst_int <= '1';        
      WHEN l2s12 =>
        nxt_state <= wait_l2s13;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(32));
      WHEN wait_l2s13 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s13;
        ELSE
          nxt_state <= wait_l2s13;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(32));
        rst_int <= '1';        
      WHEN l2s13 =>
        nxt_state <= wait_l2s14;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(33));
      WHEN wait_l2s14 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s14;
        ELSE
          nxt_state <= wait_l2s14;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(33));
        rst_int <= '1';        
      WHEN l2s14 =>
        nxt_state <= wait_l2s15;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(34));
      WHEN wait_l2s15 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s15;
        ELSE
          nxt_state <= wait_l2s15;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(34));
        rst_int <= '1';        
      WHEN l2s15 =>
        nxt_state <= wait_l2s16;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(35));
      WHEN wait_l2s16 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s16;
        ELSE
          nxt_state <= wait_l2s16;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(35));
        rst_int <= '1';        
      WHEN l2s16 =>
        nxt_state <= wait_l2s17;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(36));
      WHEN wait_l2s17 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s17;
        ELSE
          nxt_state <= wait_l2s17;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(36));
        rst_int <= '1';        
      WHEN l2s17 =>
        nxt_state <= wait_l2s18;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(37));
      WHEN wait_l2s18 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s18;
        ELSE
          nxt_state <= wait_l2s18;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(37));
        rst_int <= '1';        
      WHEN l2s18 =>
        nxt_state <= wait_l2s19;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(38));
      WHEN wait_l2s19 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s19;
        ELSE
          nxt_state <= wait_l2s19;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(38));
        rst_int <= '1';        
      WHEN l2s19 =>
        nxt_state <= wait_l2s20;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(39));
      WHEN wait_l2s20 =>
        IF counter>=normal_factor THEN
          nxt_state <= l2s20;
        ELSE
          nxt_state <= wait_l2s20;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(39));
        rst_int <= '1';        
      WHEN l2s20 =>
        nxt_state <= wait_new_line2;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(40));
      WHEN wait_new_line2 =>
        IF counter>=normal_factor THEN
          nxt_state <= new_line2;
        ELSE
          nxt_state <= wait_new_line2;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(40));
        rst_int <= '1';        
      WHEN new_line2 =>
        nxt_state <= wait_l3s1;
        rst_int <= '0';
        lcd_data_int <= "0011000000";
      WHEN wait_l3s1 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s1;
        ELSE
          nxt_state <= wait_l3s1;
        END IF;
        lcd_data_int <= "0011000000";
        rst_int <= '1';

-------------------------------------------------------------------------------
-- line 3
-------------------------------------------------------------------------------
      WHEN l3s1 =>
        nxt_state <= wait_l3s2;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(41));
      WHEN wait_l3s2 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s2;
        ELSE
          nxt_state <= wait_l3s2;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(41));
        rst_int <= '1';        
      WHEN l3s2 =>
        nxt_state <= wait_l3s3;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(42));
      WHEN wait_l3s3 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s3;
        ELSE
          nxt_state <= wait_l3s3;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(42));
        rst_int <= '1';        
      WHEN l3s3 =>
        nxt_state <= wait_l3s4;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(43));
      WHEN wait_l3s4 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s4;
        ELSE
          nxt_state <= wait_l3s4;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(43));
        rst_int <= '1';        
      WHEN l3s4 =>
        nxt_state <= wait_l3s5;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(44));
      WHEN wait_l3s5 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s5;
        ELSE
          nxt_state <= wait_l3s5;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(44));
        rst_int <= '1';        
      WHEN l3s5 =>
        nxt_state <= wait_l3s6;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(45));
      WHEN wait_l3s6 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s6;
        ELSE
          nxt_state <= wait_l3s6;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(45));
        rst_int <= '1';        
      WHEN l3s6 =>
        nxt_state <= wait_l3s7;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(46));
      WHEN wait_l3s7 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s7;
        ELSE
          nxt_state <= wait_l3s7;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(46));
        rst_int <= '1';        
      WHEN l3s7 =>
        nxt_state <= wait_l3s8;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(47));
      WHEN wait_l3s8 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s8;
        ELSE
          nxt_state <= wait_l3s8;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(47));
        rst_int <= '1';        
      WHEN l3s8 =>
        nxt_state <= wait_l3s9;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(48));
      WHEN wait_l3s9 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s9;
        ELSE
          nxt_state <= wait_l3s9;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(48));
        rst_int <= '1';        
      WHEN l3s9 =>
        nxt_state <= wait_l3s10;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(49));
      WHEN wait_l3s10 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s10;
        ELSE
          nxt_state <= wait_l3s10;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(49));
        rst_int <= '1';        
      WHEN l3s10 =>
        nxt_state <= wait_l3s11;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(50));
      WHEN wait_l3s11 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s11;
        ELSE
          nxt_state <= wait_l3s11;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(50));
        rst_int <= '1';        
      WHEN l3s11 =>
        nxt_state <= wait_l3s12;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(51));
      WHEN wait_l3s12 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s12;
        ELSE
          nxt_state <= wait_l3s12;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(51));
        rst_int <= '1';        
      WHEN l3s12 =>
        nxt_state <= wait_l3s13;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(52));
      WHEN wait_l3s13 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s13;
        ELSE
          nxt_state <= wait_l3s13;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(52));
        rst_int <= '1';        
      WHEN l3s13 =>
        nxt_state <= wait_l3s14;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(53));
      WHEN wait_l3s14 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s14;
        ELSE
          nxt_state <= wait_l3s14;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(53));
        rst_int <= '1';        
      WHEN l3s14 =>
        nxt_state <= wait_l3s15;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(54));
      WHEN wait_l3s15 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s15;
        ELSE
          nxt_state <= wait_l3s15;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(54));
        rst_int <= '1';        
      WHEN l3s15 =>
        nxt_state <= wait_l3s16;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(55));
      WHEN wait_l3s16 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s16;
        ELSE
          nxt_state <= wait_l3s16;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(55));
        rst_int <= '1';        
      WHEN l3s16 =>
        nxt_state <= wait_l3s17;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(56));
      WHEN wait_l3s17 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s17;
        ELSE
          nxt_state <= wait_l3s17;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(56));
        rst_int <= '1';        
      WHEN l3s17 =>
        nxt_state <= wait_l3s18;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(57));
      WHEN wait_l3s18 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s18;
        ELSE
          nxt_state <= wait_l3s18;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(57));
        rst_int <= '1';        
      WHEN l3s18 =>
        nxt_state <= wait_l3s19;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(58));
      WHEN wait_l3s19 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s19;
        ELSE
          nxt_state <= wait_l3s19;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(58));
        rst_int <= '1';        
      WHEN l3s19 =>
        nxt_state <= wait_l3s20;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(59));
      WHEN wait_l3s20 =>
        IF counter>=normal_factor THEN
          nxt_state <= l3s20;
        ELSE
          nxt_state <= wait_l3s20;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(59));
        rst_int <= '1';        
      WHEN l3s20 =>
        nxt_state <= wait_new_line3;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(60));
      WHEN wait_new_line3 =>
        IF counter>=normal_factor THEN
          nxt_state <= new_line3;
        ELSE
          nxt_state <= wait_new_line3;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(60));
        rst_int <= '1';        
      WHEN new_line3 =>
        nxt_state <= wait_l4s1;
        rst_int <= '0';
        lcd_data_int <= "0011100000";
      WHEN wait_l4s1 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s1;
        ELSE
          nxt_state <= wait_l4s1;
        END IF;
        lcd_data_int <= "0011100000";
        rst_int <= '1';

-------------------------------------------------------------------------------
-- line 4
-------------------------------------------------------------------------------
      WHEN l4s1 =>
        nxt_state <= wait_l4s2;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(61));
      WHEN wait_l4s2 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s2;
        ELSE
          nxt_state <= wait_l4s2;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(61));
        rst_int <= '1';        
      WHEN l4s2 =>
        nxt_state <= wait_l4s3;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(62));
      WHEN wait_l4s3 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s3;
        ELSE
          nxt_state <= wait_l4s3;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(62));
        rst_int <= '1';        
      WHEN l4s3 =>
        nxt_state <= wait_l4s4;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(63));
      WHEN wait_l4s4 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s4;
        ELSE
          nxt_state <= wait_l4s4;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(63));
        rst_int <= '1';        
      WHEN l4s4 =>
        nxt_state <= wait_l4s5;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(64));
      WHEN wait_l4s5 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s5;
        ELSE
          nxt_state <= wait_l4s5;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(64));
        rst_int <= '1';        
      WHEN l4s5 =>
        nxt_state <= wait_l4s6;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(65));
      WHEN wait_l4s6 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s6;
        ELSE
          nxt_state <= wait_l4s6;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(65));
        rst_int <= '1';        
      WHEN l4s6 =>
        nxt_state <= wait_l4s7;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(66));
      WHEN wait_l4s7 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s7;
        ELSE
          nxt_state <= wait_l4s7;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(66));
        rst_int <= '1';        
      WHEN l4s7 =>
        nxt_state <= wait_l4s8;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(67));
      WHEN wait_l4s8 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s8;
        ELSE
          nxt_state <= wait_l4s8;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(67));
        rst_int <= '1';        
      WHEN l4s8 =>
        nxt_state <= wait_l4s9;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(68));
      WHEN wait_l4s9 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s9;
        ELSE
          nxt_state <= wait_l4s9;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(68));
        rst_int <= '1';        
      WHEN l4s9 =>
        nxt_state <= wait_l4s10;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(69));
      WHEN wait_l4s10 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s10;
        ELSE
          nxt_state <= wait_l4s10;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(69));
        rst_int <= '1';        
      WHEN l4s10 =>
        nxt_state <= wait_l4s11;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(70));
      WHEN wait_l4s11 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s11;
        ELSE
          nxt_state <= wait_l4s11;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(70));
        rst_int <= '1';        
      WHEN l4s11 =>
        nxt_state <= wait_l4s12;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(71));
      WHEN wait_l4s12 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s12;
        ELSE
          nxt_state <= wait_l4s12;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(71));
        rst_int <= '1';        
      WHEN l4s12 =>
        nxt_state <= wait_l4s13;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(72));
      WHEN wait_l4s13 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s13;
        ELSE
          nxt_state <= wait_l4s13;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(72));
        rst_int <= '1';        
      WHEN l4s13 =>
        nxt_state <= wait_l4s14;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(73));
      WHEN wait_l4s14 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s14;
        ELSE
          nxt_state <= wait_l4s14;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(73));
        rst_int <= '1';        
      WHEN l4s14 =>
        nxt_state <= wait_l4s15;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(74));
      WHEN wait_l4s15 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s15;
        ELSE
          nxt_state <= wait_l4s15;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(74));
        rst_int <= '1';        
      WHEN l4s15 =>
        nxt_state <= wait_l4s16;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(75));
      WHEN wait_l4s16 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s16;
        ELSE
          nxt_state <= wait_l4s16;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(75));
        rst_int <= '1';        
      WHEN l4s16 =>
        nxt_state <= wait_l4s17;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(76));
      WHEN wait_l4s17 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s17;
        ELSE
          nxt_state <= wait_l4s17;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(76));
        rst_int <= '1';        
      WHEN l4s17 =>
        nxt_state <= wait_l4s18;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(77));
      WHEN wait_l4s18 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s18;
        ELSE
          nxt_state <= wait_l4s18;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(77));
        rst_int <= '1';        
      WHEN l4s18 =>
        nxt_state <= wait_l4s19;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(78));
      WHEN wait_l4s19 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s19;
        ELSE
          nxt_state <= wait_l4s19;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(78));
        rst_int <= '1';        
      WHEN l4s19 =>
        nxt_state <= wait_l4s20;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(79));
      WHEN wait_l4s20 =>
        IF counter>=normal_factor THEN
          nxt_state <= l4s20;
        ELSE
          nxt_state <= wait_l4s20;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(79));
        rst_int <= '1';        
      WHEN l4s20 =>
        nxt_state <= wait_new_line4;
        rst_int <= '0';
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(80));
      WHEN wait_new_line4 =>
        IF counter>=normal_factor THEN
          nxt_state <= new_line4;
        ELSE
          nxt_state <= wait_new_line4;
        END IF;
        lcd_data_int <= '1' & '0' & char2std(lcd_reg(80));
        rst_int <= '1';        
      WHEN new_line4 =>
        nxt_state <= wait_renew;
        rst_int <= '0';
        lcd_data_int <= "0000000010";
      WHEN wait_renew =>
        IF counter>=extended_factor THEN
          nxt_state <= l1s1;
        ELSE
          nxt_state <= wait_renew;
        END IF;
        lcd_data_int <= "0000000010";
        rst_int <= '1';
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
      WHEN OTHERS =>
        nxt_state <= init_start;
        rst_int <= '0';
        lcd_data_int <= (OTHERS => '0');
    END case;
  END process;


END behavioral;
