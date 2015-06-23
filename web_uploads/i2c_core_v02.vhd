--
-- VHDL Architecture i2c.i2c_core_v02.arc
--
-- Created:
--          by - Eli&Natalie.UNKNOWN (ELI)
--          at - 20:01:49 06/11/2008
--
-- using Mentor Graphics HDL Designer(TM) 2007.1 (Build 19)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY i2c_core_v02 IS
  generic
    (
     CLK_FREQ : natural := 25000000
    ); 
  PORT
    ( 
     --INPUTS
     sys_clk  : IN     std_logic;
     sys_rst  : IN     std_logic;
     start    : IN     std_logic;
     stop     : IN     std_logic;
     read     : IN     std_logic;
     write    : IN     std_logic;
     send_ack : IN     std_logic;
     mstr_din : IN     std_logic_vector ( 7 DOWNTO 0 );
     slv_din  : IN     std_logic_vector ( 7 DOWNTO 0 );      
     slv_a0   : IN     std_logic;
     slv_a1   : IN     std_logic;
     slv_a2   : IN     std_logic;      
     slv_a3   : IN     std_logic;
     slv_a4   : IN     std_logic;
     slv_a5   : IN     std_logic;
     slv_a6   : IN     std_logic;
     reg_exist: IN     std_logic;            
     --OUTPUTS
     sda      : INOUT  std_logic;
     scl      : INOUT  std_logic;
     slv_read : OUT    std_logic;
     slv_write: OUT    std_logic;     
     slv_busy : OUT    std_logic; --slave is busy
     slv_int  : OUT    std_logic; --interrupt from the slave to its interface
     free     : OUT    std_logic;
     rec_ack  : OUT    std_logic;
     ready    : OUT    std_logic;
     mstr_slv : OUT    std_logic;
     mstr_dout: OUT    std_logic_vector( 7 downto 0 );
     slv_dout : OUT    std_logic_vector( 7 DOWNTO 0 )
    );
END ENTITY i2c_core_v02;

--
ARCHITECTURE arc OF i2c_core_v02 IS
  
  constant FRAME     : natural := 11; -- number of bits in frame: start, stop, 8 bits data, 1 bit acknoledge
  constant BAUD      : natural := 200000;
--  constant CLK_FREQ  : natural := 25000000;
  constant FULL_BIT  : natural := CLK_FREQ / BAUD;
  constant HALF_BIT  : natural := FULL_BIT / 2;
  constant GAP_WIDTH : natural := FULL_BIT * 2;
  
  signal i_mstr_slv : std_logic; --for master-slave arbitration 1 - master, 0 - slave
  signal i_free     : std_logic;
  signal i_ready    : std_logic;
  signal i_sda_mstr : std_logic;
  signal i_scl_mstr : std_logic;
  signal i_scl_cntr : natural range 0 to 511;
  signal i_bit_cntr_mstr : natural range 0 to 7;
  signal i_ack_mstr : std_logic;
  signal i_mstr_rd_data : std_logic_vector( 7 downto 0 );
  
  signal i_mstr_ad  : std_logic_vector( 7 downto 0 ); --latched address and data
  alias  fld_rd_wr  : std_logic is i_mstr_ad( 0 ); --1 - read, 0 - write
  
  -- slave signals 
  
  signal i_slv_sda_fall : std_logic;
  signal i_slv_sda_rise : std_logic;
  signal i_slv_scl_fall : std_logic;
  signal i_slv_scl_rise : std_logic;
  
  signal i_sda_sam : std_logic_vector( 1 downto 0 );
  signal i_scl_sam : std_logic_vector( 1 downto 0 );
  
  signal i_sda_slv : std_logic;
  
  signal i_slv_data     : std_logic_vector( 7 downto 0 );
  signal i_slv_addr     : std_logic_vector( 7 downto 0 );
  signal i_slv_reg_addr : std_logic_vector( 7 downto 0 );
  signal i_slv_bit_cnt  : natural range 0 to 10;
  signal i_slv_stop_bit : std_logic;
  signal i_slv_strt_bit : std_logic;
  signal i_slv_dout     : std_logic_vector( 7 downto 0 );  
  
  --address "1111111" not legal
  signal SLAVE_ADDR : std_logic_vector( 6 downto 0 );  
  
  type i2c_master_state is ( mstr_idle, mstr_start_cnt , mstr_active , mstr_wait_first_half , mstr_wait_second_half ,
                             mstr_wait_full , mstr_wait_ack , mstr_wait_ack_second_half , mstr_wait_ack_third_half ,
                             mstr_wait_ack_fourth_half , mstr_rd_wait_low , mstr_rd_wait_half , mstr_rd_read , mstr_stop ,
                             mstr_rd_wait_last_half , mstr_rd_wait_ack , mstr_rd_get_ack , mstr_restart , mstr_gap );
                             
  signal stm_mstr : i2c_master_state;
  
  type i2c_slave_state is ( slv_idle , slv_get_addr , slv_rd_wr , slv_read_reg_addr , slv_write_data , slv_send_addr_ack, slv_wait_ack , slv_send_data_ack ,
                            slv_wait_data_ack , slv_read_data , slv_get_data_ack , slv_get_wait_data_ack );
  signal stm_slv : i2c_slave_state;
  
BEGIN
  sda   <= i_sda_mstr when ( i_mstr_slv = '1' ) else i_sda_slv;
  scl   <= i_scl_mstr;
  free  <= i_free;
  ready <= i_ready;
  mstr_slv <= i_mstr_slv;
  
  arbitration:
  process( sys_clk , sys_rst )
    begin
      if ( sys_rst = '1' ) then
        i_mstr_slv <= '1';
       -- i_slv_stop_bit <= '0';
      elsif rising_edge( sys_clk ) then
        
        SLAVE_ADDR <= slv_a6 & slv_a5 & slv_a4 & slv_a3 & slv_a2 & slv_a1 & slv_a0;
        
        i_scl_sam( 0 ) <= scl;
        i_scl_sam( 1 ) <= i_scl_sam( 0 );
        
        i_sda_sam( 0 ) <= sda;
        i_sda_sam( 1 ) <= i_sda_sam( 0 );
        
        if ( sda = '0' ) and ( scl = '1' ) and ( stm_mstr = mstr_idle ) then
          i_mstr_slv <= '0'; --slave
        elsif ( i_slv_sda_rise = '1' ) and ( to_X01( scl ) = '1' ) then
          i_mstr_slv <= '1'; --master
        end if;
      end if;
    end process arbitration;
    
  i_slv_sda_fall <= not i_sda_sam( 0 ) and i_sda_sam( 1 );
  i_slv_sda_rise <= i_sda_sam( 0 ) and not i_sda_sam( 1 );    
  
  i_slv_scl_fall <= not i_scl_sam( 0 ) and i_scl_sam( 1 );
  i_slv_scl_rise <= i_scl_sam( 0 ) and not i_scl_sam( 1 );
  
  i_slv_stop_bit <= '1' when ( i_slv_sda_rise = '1' ) and ( to_X01( scl ) = '1' ) else '0'; 
  i_slv_strt_bit <= '1' when ( i_slv_sda_fall = '1' ) and ( to_X01( scl ) = '1' ) else '0';
  
  rec_ack <= not i_ack_mstr;
  
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
        mstr_dout <= ( others => '0' ); 
        i_mstr_ad <= ( others => '0' );      
      elsif rising_edge( sys_clk ) then
        if ( i_mstr_slv = '1' ) then
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
            if ( read = '1' ) then 
              stm_mstr <= mstr_rd_wait_low;
              i_ready <= '0';
            elsif ( write = '1' ) then
              i_mstr_ad <= mstr_din;
              i_ready <= '0';
              stm_mstr <= mstr_wait_first_half; 
            elsif ( stop = '1' ) then
              stm_mstr <= mstr_stop;
            elsif ( start = '1' ) then
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
              i_ack_mstr <= sda;
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
              i_mstr_rd_data <= i_mstr_rd_data( 6 downto 0 ) & sda;
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
              stm_mstr <= mstr_rd_wait_last_half;
            end if;
          ----------------------
          when mstr_rd_wait_last_half =>
            i_scl_mstr <= '1';
            if ( i_scl_cntr < FULL_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_rd_wait_last_half;
            else              
              i_scl_cntr <= 0;
              stm_mstr <= mstr_active;
            end if;
          ---------------------- 
          --######################
          --######## STOP ########
          --######################                                        
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
              stm_mstr <= mstr_idle;
            end if;
          --#####################
          --###### RESTART ######        
          --#####################
          when mstr_restart =>
            i_scl_mstr <= '1';
            i_sda_mstr <= '0';
            if ( i_scl_cntr < HALF_BIT ) then
              i_scl_cntr <= i_scl_cntr + 1;
              stm_mstr <= mstr_restart;
            else
              i_scl_cntr <= 0;
              i_sda_mstr <= '1';
              stm_mstr <= mstr_start_cnt;
            end if;                                                  
          when others => stm_mstr <= mstr_idle;
          end case;
        end if;
      end if;
    end process i2c_master; 
 --##############################################    
 --##############################################
 --##############################################
 --##############################################
 --##############################################
 --##############################################     
     slv_dout <= i_slv_dout;
     i2c_slave:
     process( sys_clk , sys_rst )
       begin
         if ( sys_rst = '1' ) then
           stm_slv <= slv_idle;
           slv_busy <= '0';
           i_slv_bit_cnt <= 0;
           i_slv_addr <= ( others => '0' );
           i_sda_slv <= 'Z';
           i_slv_reg_addr <= ( others => '0' );
           i_slv_data <= ( others => '0' );
           slv_read <= '0';
           slv_write <= '0';
           i_slv_dout <=  ( others => '0' );
         elsif rising_edge( sys_clk ) then
           case stm_slv is
           ----------------------
           when slv_idle =>
             slv_busy <= '0';
             i_sda_slv <= 'Z';
             i_slv_bit_cnt <= 0;
             if ( i_mstr_slv = '0' ) and ( i_slv_strt_bit = '1' ) then
               stm_slv <= slv_get_addr;
               slv_busy <= '1';
             else
               stm_slv <= slv_idle;
             end if;
           ----------------------
           when slv_get_addr =>
             i_sda_slv <= 'Z';
             if ( i_slv_stop_bit = '0' ) then
               if ( i_slv_scl_rise = '1' ) then
                 if ( i_slv_bit_cnt < 8 ) then               
                   i_slv_addr <= i_slv_addr( 6 downto 0 ) & sda;
                   i_slv_bit_cnt <= i_slv_bit_cnt + 1;  
                   stm_slv <= slv_get_addr;
                 elsif( i_slv_bit_cnt = 8 ) then
                   i_slv_addr <= i_slv_addr( 6 downto 0 ) & sda;
                   i_slv_bit_cnt <= 0; 
                   stm_slv <= slv_send_addr_ack;                 
                 end if;
               elsif ( i_slv_scl_fall = '1' ) and ( i_slv_bit_cnt = 8 ) then
                 stm_slv <= slv_send_addr_ack;
                 i_slv_bit_cnt <= 0;               
               else
                 stm_slv <= slv_get_addr;
               end if;
             else
               stm_slv <= slv_idle;
             end if;
           -----------------------      
           when slv_send_addr_ack =>
             if ( i_slv_addr( 7 downto 1 ) = SLAVE_ADDR ) then  
               if ( i_slv_scl_rise = '1' ) then
                 i_sda_slv <= '0';
                 stm_slv <= slv_wait_ack;
               end if;
             else
               stm_slv <= slv_idle;
             end if;        
           -----------------------     
           when slv_wait_ack =>
             if ( i_slv_scl_fall = '1' ) then
               if ( reg_exist = '1' ) then
                 stm_slv <= slv_read_reg_addr;
               elsif ( i_slv_addr( 0 ) = '0' ) then
                 stm_slv <= slv_write_data;
                 slv_read <= '1';
               elsif ( i_slv_addr( 0 ) = '1' ) then
                 stm_slv <= slv_read_reg_addr;                 
               end if;
             else
               stm_slv <= slv_wait_ack;
             end if;
           -----------------------             
           when slv_rd_wr =>  
             i_sda_slv <= 'Z';
             i_slv_data <= slv_din; 
             i_slv_dout <= i_slv_reg_addr;                                                                  
             if ( i_slv_addr( 0 ) = '1' ) then
               slv_write <= '1';                       
               stm_slv <= slv_read_data;
             else
               stm_slv <= slv_write_data;                              
               slv_read <= '1';
             end if;             
           -----------------------
           when slv_read_reg_addr =>  
             slv_write <= '0';   
             i_sda_slv <= 'Z';
             if ( i_slv_stop_bit = '0' ) then
               if ( i_slv_scl_rise = '1' ) then
                 if ( i_slv_bit_cnt < 7 ) then               
                   i_slv_reg_addr <= i_slv_reg_addr( 6 downto 0 ) & sda;
                   i_slv_bit_cnt <= i_slv_bit_cnt + 1; 
                   stm_slv <= slv_read_reg_addr;  
                 elsif ( i_slv_bit_cnt = 7 ) then
                   i_slv_reg_addr <= i_slv_reg_addr( 6 downto 0 ) & sda;                                                    
                   i_slv_bit_cnt <= 0;
                   stm_slv <= slv_send_data_ack;
                 end if;       
               else
                 stm_slv <= slv_read_reg_addr;
               end if;
             else
               stm_slv <= slv_idle;
             end if;
           -----------------------  
           when slv_send_data_ack =>  
             if ( i_slv_scl_rise = '1' ) then
               i_sda_slv <= '0';
               stm_slv <= slv_wait_data_ack;
             end if;                  
           -----------------------
           when slv_wait_data_ack =>
             if ( i_slv_scl_fall = '1' ) then
               stm_slv <= slv_rd_wr;
             else
               stm_slv <= slv_wait_data_ack;
             end if;  
           -----------------------  
           when slv_write_data =>
             slv_read <= '0';
             if ( i_slv_stop_bit = '0' ) then
               i_sda_slv <= i_slv_data( 7 );               
               if ( i_slv_scl_fall = '1' ) then
                 if ( i_slv_bit_cnt < 7 ) then
                  -- i_sda_slv <= i_slv_data( 7 );
                   i_slv_data <= i_slv_data( 6 downto 0 ) & '0';
                   i_slv_bit_cnt <= i_slv_bit_cnt + 1;
                   stm_slv <= slv_write_data;
                 elsif ( i_slv_bit_cnt = 7 ) then
                   i_sda_slv <= i_slv_data( 7 );
                   i_slv_bit_cnt <= 0;
                   stm_slv <= slv_get_wait_data_ack;
                 end if;
               end if;
             else
               stm_slv <= slv_idle;
             end if;
           ----------------------- 
           when slv_get_wait_data_ack =>
             i_sda_slv <= 'Z';
             if ( i_slv_scl_rise = '1' ) then
               stm_slv <= slv_get_data_ack;
             else
               stm_slv <= slv_get_wait_data_ack;
             end if;
           -----------------------
           when slv_get_data_ack =>
             i_sda_slv <= 'Z';
             if ( i_slv_scl_fall = '1' ) then
               if ( sda = '0' ) and ( i_slv_sda_fall = '0' ) then
                 stm_slv <= slv_rd_wr;
               else
                 stm_slv <= slv_idle;
               end if;
             else
               stm_slv <= slv_get_data_ack;
             end if;
           ------------------------  
           when slv_read_data =>
             slv_write <= '0';
             if ( i_slv_stop_bit = '1' ) then
               stm_slv <= slv_idle;
             else
               if ( i_slv_scl_rise = '1' ) then
                 if ( i_slv_bit_cnt < 7 ) then               
                   i_slv_reg_addr <= i_slv_reg_addr( 6 downto 0 ) & sda;
                   i_slv_bit_cnt <= i_slv_bit_cnt + 1; 
                   stm_slv <= slv_read_data;  
                 elsif ( i_slv_bit_cnt = 7 ) then
                   i_slv_reg_addr <= i_slv_reg_addr( 6 downto 0 ) & sda;                                                    
                   i_slv_bit_cnt <= 0;
                   stm_slv <= slv_send_data_ack;
                 end if;       
               else
                 stm_slv <= slv_read_data;
               end if;             
             end if;
           -------------------------  
           when others => stm_slv <= slv_idle;
           end case;  
         end if;
       end process i2c_slave;
END ARCHITECTURE arc;

