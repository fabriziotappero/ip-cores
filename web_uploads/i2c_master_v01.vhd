--
-- VHDL Architecture rada_comp_lib.i2c_master_v01.arc
--
-- Created:
--          by - elis@(ELIS-WXP)
--          at - 15:30:47 01/03/2009
--
-- using Mentor Graphics HDL Designer(TM) 2008.1 (Build 17)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY i2c_master_v01 IS
   GENERIC( 
      CLK_FREQ : natural := 25000000;
      BAUD     : natural := 100000
   );
   PORT( 
      --INPUTS
      sys_clk    : IN     std_logic;
      sys_rst    : IN     std_logic;
      start      : IN     std_logic;
      stop       : IN     std_logic;
      read       : IN     std_logic;
      write      : IN     std_logic;
      send_ack   : IN     std_logic;
      mstr_din   : IN     std_logic_vector (7 DOWNTO 0);
      --OUTPUTS
      sda        : INOUT  std_logic;
      scl        : INOUT  std_logic;
      free       : OUT    std_logic;
      rec_ack    : OUT    std_logic;
      ready      : OUT    std_logic;
      core_state : OUT    std_logic_vector (5 DOWNTO 0);  --for debug purpose
      mstr_dout  : OUT    std_logic_vector (7 DOWNTO 0)
   );

-- Declarations

END i2c_master_v01 ;

--
ARCHITECTURE arc OF i2c_master_v01 IS
  
  constant FRAME     : natural := 11; -- number of bits in frame: start, stop, 8 bits data, 1 bit acknoledge
 -- constant BAUD      : natural := 100000;
  constant FULL_BIT  : natural := ( CLK_FREQ / BAUD - 1 ) / 2;
  constant HALF_BIT  : natural := FULL_BIT / 2;
  constant GAP_WIDTH : natural := FULL_BIT * 4;  

  signal i_free     : std_logic;
  signal i_ready    : std_logic;
  signal i_sda_mstr : std_logic;
  signal i_scl_mstr : std_logic;
  signal i_scl_cntr : natural;
  signal i_bit_cntr_mstr : natural range 0 to 7;
  signal i_ack_mstr : std_logic;
  signal i_mstr_rd_data : std_logic_vector( 7 downto 0 );
  
  signal i_mstr_ad  : std_logic_vector( 7 downto 0 ); --latched address and data
  alias  fld_rd_wr  : std_logic is i_mstr_ad( 0 ); --1 - read, 0 - write

  type i2c_master_state is ( mstr_idle, mstr_start_cnt , mstr_active , mstr_wait_first_half , mstr_wait_second_half ,
                             mstr_wait_full , mstr_wait_ack , mstr_wait_ack_second_half , mstr_wait_ack_third_half ,
                             mstr_wait_ack_fourth_half , mstr_rd_wait_low , mstr_rd_wait_half , mstr_rd_read , mstr_stop ,
                             mstr_rd_wait_ack_bit , mstr_rd_wait_ack , mstr_rd_get_ack , mstr_restart , mstr_gap , mstr_stop_1 ,
                             mstr_rd_wait_last_half , mstr_restart_clk_high );
                             
  signal stm_mstr : i2c_master_state;
  
  signal i_in_state : natural;
    
BEGIN
  sda     <= i_sda_mstr;
  scl     <= i_scl_mstr;
  free    <= i_free;
  ready   <= i_ready;
  rec_ack <= not i_ack_mstr;
  
  core_state <= conv_std_logic_vector( i_in_state , 6 );
  
  i2c_master: 
  process( sys_clk , sys_rst )
    begin
      if ( sys_rst = '1' ) then
        stm_mstr   <= mstr_idle;
        i_free     <= '0';
        i_ready    <= '0';  
        i_sda_mstr <= 'Z';
        i_scl_mstr <= 'Z';
        i_scl_cntr <= 0;
        i_bit_cntr_mstr <= 7;
        i_ack_mstr <= '1';
        i_mstr_rd_data <= ( others => '0' ); 
        mstr_dout  <= ( others => '0' ); 
        i_mstr_ad  <= ( others => '0' );   
        i_in_state <= 0;   
      elsif rising_edge( sys_clk ) then      
          case stm_mstr is
          -------------------  
          when mstr_idle =>
            i_free <= '1';
            i_ready <= '0';
            i_sda_mstr <= 'Z';
            i_scl_mstr <= 'Z';                                      
            if ( start = '1' ) then
              stm_mstr <= mstr_start_cnt;
              i_free <= '0';          
            else
              stm_mstr <= mstr_idle;
            end if;
          -------------------
          when mstr_start_cnt =>
            i_sda_mstr <= '0';
            i_scl_mstr <= '1';
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_start_cnt;
            else  
              i_scl_cntr <= 0;
              stm_mstr <= mstr_active;
              i_scl_mstr <= '0';
            end if;
          -------------------
          when mstr_active =>
            i_ready <= '1';   
            i_scl_mstr <= '0';
            i_sda_mstr <= '0';
            i_bit_cntr_mstr <= 7;
            i_in_state <= 1;
            if ( read = '1' ) then 
              stm_mstr <= mstr_rd_wait_low;
              i_ready <= '0';
              i_in_state <= 3;
            elsif ( write = '1' ) then
              i_in_state <= 2;
              i_mstr_ad <= mstr_din;
              i_ready <= '0';
              stm_mstr <= mstr_wait_first_half; 
            elsif ( stop = '1' ) then
              i_in_state <= 4;
              i_ready <= '0';
              stm_mstr <= mstr_stop_1;
            elsif ( start = '1' ) then
              i_in_state <= 5;
              i_ready <= '0';
              stm_mstr <= mstr_restart;
            end if;
          --------------------
          --####################
          --##### WRITE ########
          --####################
          when mstr_wait_first_half =>
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_mstr <= '0';
              i_scl_cntr <= i_scl_cntr + 1;
            else
              i_scl_cntr <= 0;
              stm_mstr <= mstr_wait_second_half;
              i_sda_mstr <= i_mstr_ad( i_bit_cntr_mstr );                     
            end if;
          --------------------
          when mstr_wait_second_half =>
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_wait_second_half;
            else            
              i_scl_cntr <= 0;              
              stm_mstr <= mstr_wait_full;              
            end if;
          ---------------------
          when mstr_wait_full =>
            if ( i_scl_cntr < FULL_BIT ) then 
              i_scl_mstr <= '1';
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_wait_full;
            else  
              i_scl_cntr <= 0;              
              if ( i_bit_cntr_mstr >= 1 ) then
                i_bit_cntr_mstr <= i_bit_cntr_mstr - 1;
                stm_mstr <= mstr_wait_first_half;
              elsif ( i_bit_cntr_mstr = 0 ) then
                --i_sda_mstr <= 'Z';              
                stm_mstr <= mstr_wait_ack;                
              end if;                                          
            end if;
          --------------------
          --####################
          --#### ACKNOWLEDGE ###
          --####################
          when mstr_wait_ack =>
            i_scl_mstr <= '0';
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
            else
              i_scl_cntr <= 0;
              i_sda_mstr <= 'Z';
              stm_mstr <= mstr_wait_ack_second_half;
            end if;
          --------------------
          when mstr_wait_ack_second_half => 
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
            else
              i_scl_cntr <= 0;
              i_sda_mstr <= 'Z';
              stm_mstr <= mstr_wait_ack_third_half;
            end if;               
          --------------------  
          when mstr_wait_ack_third_half =>
            i_scl_mstr <= '1';
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
            else
              i_scl_cntr <= 0;
              i_sda_mstr <= 'Z';
              i_ack_mstr <= to_x01( sda );
              stm_mstr <= mstr_wait_ack_fourth_half;
            end if;        
          --------------------
          when mstr_wait_ack_fourth_half =>
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
            else
              i_scl_cntr <= 0;
              i_sda_mstr <= 'Z';
              stm_mstr <= mstr_active;
            end if;     
          --------------------
          --####################
          --###### READ ########
          --####################
          when mstr_rd_wait_low =>
            i_scl_mstr <= '0';
            i_sda_mstr <= 'Z';
            if ( i_scl_cntr < FULL_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_rd_wait_low;
            else                           
              i_scl_cntr <= 0;
              stm_mstr <= mstr_rd_wait_half;  
            end if;
          --------------------
          when mstr_rd_wait_half =>
            i_scl_mstr <= '1';
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_rd_wait_half;
            else                           
              i_scl_cntr <= 0;
              i_mstr_rd_data <= i_mstr_rd_data( 6 downto 0 ) & to_x01( sda );
              stm_mstr <= mstr_rd_read;               
            end if;  
          --------------------- 
          when mstr_rd_read =>
            i_scl_mstr <= '1';
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_rd_read;
            else                           
              i_scl_cntr <= 0;               
              if ( i_bit_cntr_mstr > 0 ) then
                i_bit_cntr_mstr <= i_bit_cntr_mstr - 1;
                i_scl_mstr <= '0';              
                stm_mstr <= mstr_rd_wait_low;  
              else
                i_mstr_ad <= ( others => '0' );  
                mstr_dout <= i_mstr_rd_data;               
                stm_mstr <= mstr_rd_wait_ack;
              end if;
            end if;      
          ---------------------
          --#######################
          --### SEND ACKNOWELEDGE #
          --#######################
          when mstr_rd_wait_ack =>
            i_scl_mstr <= '0';
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_rd_wait_ack;
            else                           
              i_scl_cntr <= 0;
              i_sda_mstr <= not send_ack;
              stm_mstr <= mstr_rd_get_ack;
            end if;
          ----------------------              
          when mstr_rd_get_ack =>
            i_scl_mstr <= '0';
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_rd_get_ack;
            else
              i_scl_cntr <= 0;
              --i_ack_mstr <= sda;
              stm_mstr <= mstr_rd_wait_ack_bit;
            end if;
          ----------------------
          when mstr_rd_wait_ack_bit =>
            i_scl_mstr <= '1';
            if ( i_scl_cntr < FULL_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_rd_wait_ack_bit;
            else              
              i_scl_cntr <= 0;
              stm_mstr <= mstr_rd_wait_last_half;
            end if;
          ---------------------- 
          when mstr_rd_wait_last_half =>
            i_scl_mstr <= '0';            
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_rd_wait_last_half;
            else
              i_scl_cntr <= 0;
              i_sda_mstr <= 'Z';              
              stm_mstr <= mstr_active;
            end if;
          --######################
          --######## STOP ########
          --###################### 
          when mstr_stop_1 =>
            i_scl_mstr <= '0';
            i_sda_mstr <= '0';
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_stop_1;
            else
              i_scl_cntr <= 0;
              stm_mstr <= mstr_stop;
            end if;
          ----------------------                                     
          when mstr_stop =>
            i_scl_mstr <= '1';
            i_sda_mstr <= '0';
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_stop;
            else
              i_scl_cntr <= 0;
              i_sda_mstr <= '1';
              stm_mstr <= mstr_gap;
            end if;                                                  
          ---------------------  
          when mstr_gap =>
            if ( i_scl_cntr < GAP_WIDTH ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_gap;
            else
              i_scl_cntr <= 0;
              i_in_state <= 0;
              stm_mstr <= mstr_idle;
            end if;
          --#####################
          --###### RESTART ######        
          --#####################
          when mstr_restart =>
            i_scl_mstr <= '0';
            i_sda_mstr <= '1';
            i_ready <= '0';
            if ( i_scl_cntr < FULL_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_restart;
            else
              i_scl_cntr <= 0;
              i_sda_mstr <= '1';
              stm_mstr <= mstr_restart_clk_high;
            end if;                      
          ----------------------
          when mstr_restart_clk_high =>
            i_scl_mstr <= '1';
            i_sda_mstr <= '1';
            i_ready <= '0';
            if ( i_scl_cntr < HALF_BIT ) then
              stm_mstr <= mstr_restart_clk_high;
              i_scl_cntr <= i_scl_cntr + 1;
            else
              i_scl_cntr <= 0;
              stm_mstr <= mstr_start_cnt;
            end if;                              
          when others => stm_mstr <= mstr_idle;
          end case;       
      end if;
    end process i2c_master;
END ARCHITECTURE arc;
