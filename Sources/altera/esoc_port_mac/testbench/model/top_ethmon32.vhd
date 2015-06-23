-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: top_ethmon32.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/vhdl/ethernet_model/mon/top_ethmon32.vhd,v $
--
-- $Revision: #1 $
-- $Date: 2008/08/09 $
-- Check in by : $Author: sc-build $
-- Author      : SKNg/TTChong
--
-- Project     : Triple Speed Ethernet - 10/100/1000 MAC
--
-- Description : (Simulation only)
--
-- Ethernet Traffic Monitor/Decoder for 32 bit MAC Atlantic client interface
-- Instantiates ETHMONITOR_32 (ethmon_32.vhd)
--
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------



library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;
use std.textio.all ;

entity TOP_ETHMONITOR32 is 

    generic (
      BIG_ENDIAN      : integer := 1;  --0 for false, 1 for true
      ENABLE_SHIFT16  : integer := 0  --0 for false, 1 for true

    );

    port (

      reset       : in std_logic ;     -- active high
      clk         : in std_logic;

      -- Word Interface input

      din      : in  std_logic_vector(31 downto 0);
      dval     : in  std_logic;
      derror   : in  std_logic;
      sop      : in  std_logic;   -- pulse with first word
      eop      : in  std_logic;   -- pulse with last word (tmod valid)
      tmod     : in  std_logic_vector(1 downto 0);  -- last word modulo

        -- Frame Contents definitions

      dst           : out std_logic_vector(47 downto 0); -- destination address
      src           : out std_logic_vector(47 downto 0); -- source address
      
      prmble_len    : out integer range 0 to 10000;         -- length of preamble
      pquant        : out std_logic_vector(15 downto 0); -- Pause Quanta value
      vlan_ctl      : out std_logic_vector(15 downto 0); -- VLAN control info
      len           : out std_logic_vector(15 downto 0); -- Length of payload
      frmtype       : out std_logic_vector(15 downto 0); -- if non-null: type field instead length
      
      payload       : out std_logic_vector(7 downto 0);
      payload_vld   : out std_logic;

        -- Indicators
        
      is_vlan       : out std_logic;
      is_stack_vlan : out std_logic;
      is_pause      : out std_logic;
      crc_err       : out std_logic;
      prmbl_err     : out std_logic;
      len_err       : out std_logic;
      payload_err   : out std_logic;
      frame_err     : out std_logic;
      pause_op_err  : out std_logic;
      pause_dst_err : out std_logic;
      mac_err       : out std_logic;
      end_err       : out std_logic;

       -- Control
       
      jumbo_en      : in std_logic;
      data_only     : in std_logic;
             
        -- Receive indicator

      frm_rcvd     : out std_logic );

end TOP_ETHMONITOR32 ;

architecture behave of TOP_ETHMONITOR32 is

component ETHMONITOR_32

    generic (
        ENABLE_SHIFT16 : integer := 0  --0 for false, 1 for true

    );

    port (

      reset       : in std_logic ;     -- active high

        -- GMII transmit interface: To be connected to MAC TX

      tx_clk      : in std_logic ;
      txd         : in std_logic_vector(7 downto 0);
      tx_dv       : in std_logic;
      tx_er       : in std_logic;
      
        -- Frame Contents definitions

      dst           : out std_logic_vector(47 downto 0); -- destination address
      src           : out std_logic_vector(47 downto 0); -- source address
      
      prmble_len    : out integer range 0 to 10000;         -- length of preamble
      pquant        : out std_logic_vector(15 downto 0); -- Pause Quanta value
      vlan_ctl      : out std_logic_vector(15 downto 0); -- VLAN control info
      len           : out std_logic_vector(15 downto 0); -- Length of payload
      frmtype       : out std_logic_vector(15 downto 0); -- if non-null: type field instead length
      
      payload       : out std_logic_vector(7 downto 0);
      payload_vld   : out std_logic;

        -- Indicators
        
      is_vlan       : out std_logic;
      is_stack_vlan : out std_logic;
      is_pause      : out std_logic;
      crc_err       : out std_logic;
      prmbl_err     : out std_logic;
      len_err       : out std_logic;
      payload_err   : out std_logic;
      frame_err     : out std_logic;
      pause_op_err  : out std_logic;
      pause_dst_err : out std_logic;
      mac_err       : out std_logic;
      end_err       : out std_logic;

       -- Control
       
      jumbo_en      : in std_logic;
      data_only     : in std_logic;
             
        -- Receive indicator

      frm_rcvd     : out std_logic );

   end component ;

    -- Monitor port signals 
    -- ----------------------------------

    signal frm_rcvd_i : std_logic;   -- from gen
    signal frm_rcvd_d : std_logic;   -- delayed for handshake
    signal frm_rcvd_ex: std_logic;   -- external

    -- GMII Monitor signals
    
    signal tx_clk   : std_logic;                      -- 8 times the XGMII
    signal txd      : std_logic_vector(7 downto 0); 
    signal tx_dv    : std_logic;
    signal tx_er    : std_logic;

    -- internal

    signal fast_clk       : std_logic;
    signal fast_clk_cnt   : integer;
    signal fast_clk_gate  : std_logic;
    signal clk_d          : std_logic;

    -- captured word data 

    signal    din_int    : std_logic_vector(31 downto 0);                    
    signal    dval_int   : std_logic;                                        
    signal    derror_int : std_logic;                                        
    signal    sop_int    : std_logic;   -- pulse with first word             
    signal    eop_int    : std_logic;   -- pulse with last word (tmod valid) 
    signal    tmod_int   : std_logic_vector(1 downto 0);  -- last word modulo

    -- shift registers to feed GMII Monitor

    signal eop_int_d    : std_logic; 
    signal eop_done     : std_logic; 
    signal txd_shift    : std_logic_vector(31 downto 0);
    signal txdv_shift   : std_logic_vector(3 downto 0);


    -- internal 
            
    signal   l_dst           : std_logic_vector(47 downto 0); -- destination address
    signal   l_src           : std_logic_vector(47 downto 0); -- source address
    signal   l_prmble_len    : integer range 0 to 10000;         -- length of preamble
    signal   l_pquant        : std_logic_vector(15 downto 0); -- Pause Quanta value
    signal   l_vlan_ctl      : std_logic_vector(15 downto 0); -- VLAN control info
    signal   l_len           : std_logic_vector(15 downto 0); -- Length of payload
    signal   l_frmtype       : std_logic_vector(15 downto 0); -- if non-null: type field instead length
    signal   l_is_vlan       : std_logic;
    signal   l_is_stack_vlan : std_logic;
    signal   l_is_pause      : std_logic;
    signal   l_crc_err       : std_logic;
    signal   l_prmbl_err     : std_logic;
    signal   l_len_err       : std_logic;
    signal   l_payload_err   : std_logic;
    signal   l_frame_err     : std_logic;
    signal   l_pause_op_err  : std_logic;
    signal   l_pause_dst_err : std_logic;
    signal   l_mac_err       : std_logic;
    signal   l_end_err       : std_logic;

    signal din_reg            : std_logic_vector(31 downto 0);
    signal dval_reg           : std_logic;
    signal derror_reg         : std_logic;
    signal sop_reg            : std_logic;   -- pulse with first word
    signal eop_reg            : std_logic;   -- pulse with last word (tmod valid)
    signal tmod_reg           : std_logic_vector(1 downto 0);  -- last word modulo

begin

   -- Capture word data input
   -- ----------------------------------
   
   process( clk, reset )
   begin
   
        if( reset='1' ) then
        
                din_int   <= (others => '0'); 
                dval_int  <= '0'; 
                derror_int<= '0'; 
                sop_int   <= '0'; 
                eop_int   <= '0';
                tmod_int  <= (others => '0');
                
                frm_rcvd_ex <= '0';
                eop_int_d <= '0';
            
        elsif(clk='1' and clk'event ) then
        
                din_int    <= din_reg;   
                dval_int   <= dval_reg;  
                derror_int <= derror_reg;
                sop_int    <= sop_reg;   
                eop_int    <= eop_reg;
                tmod_int   <= tmod_reg;
                
                frm_rcvd_ex <= frm_rcvd_d;
                
                eop_int_d <= eop_int and dval_int;
                
        end if;
        
   end process;   

   -- Results in word clock domain
   -- ----------------------------------

   frm_rcvd <= frm_rcvd_ex;
   
   process( clk, reset )
   begin
   
        if( reset='1' ) then
        
                dst          <= (others => '0');
                src          <= (others => '0');
                prmble_len   <= 0;
                pquant       <= (others => '0'); 
                vlan_ctl     <= (others => '0');
                len          <= (others => '0');
                frmtype      <= (others => '0');
                is_vlan      <= '0';
                is_stack_vlan<= '0';
                is_pause     <= '0';
                crc_err      <= '0';
                prmbl_err    <= '0';
                len_err      <= '0';
                payload_err  <= '0';
                frame_err    <= '0';
                pause_op_err <= '0';
                pause_dst_err<= '0';
                mac_err      <= '0';
                end_err      <= '0';
        
        elsif(clk='1' and clk'event ) then

                dst           <= l_dst ;         
                src           <= l_src ;         
                prmble_len    <= l_prmble_len ;  
                pquant        <= l_pquant ;      
                vlan_ctl      <= l_vlan_ctl;     
                len           <= l_len    ;      
                frmtype       <= l_frmtype ;     
                is_vlan       <= l_is_vlan ; 
                is_stack_vlan <= l_is_stack_vlan ;    
                is_pause      <= l_is_pause;     
                crc_err       <= l_crc_err ;     
                prmbl_err     <= l_prmbl_err ;   
                len_err       <= l_len_err   ;   
                payload_err   <= l_payload_err;  
                frame_err     <= l_frame_err   ; 
                pause_op_err  <= l_pause_op_err; 
                pause_dst_err <= l_pause_dst_err;
                mac_err       <= l_mac_err      ;
                end_err       <= l_end_err    ;  

        end if;

   end process;
   

   -- create fast clock synchronized to clk rising edge
   -- -------------------------------------------------

   process
   begin
        fast_clk <= '0';
        wait for 0.5 ns;
        fast_clk <= '1';
        wait for 0.5 ns;
   end process;
   
   process( fast_clk, reset )
   begin
   
        if( reset='1' ) then
        
                fast_clk_gate <= '0';
                fast_clk_cnt  <= 3;
                clk_d         <= '0';
                frm_rcvd_d    <= '0';
                txd_shift     <= (others => '0');
                txdv_shift    <= (others => '0');
                eop_done      <= '0'; -- remember when we added 2 extra cycles after EOP
                
        elsif( fast_clk'event and fast_clk='0' ) then   -- work on neg edge
        
                clk_d <= clk;
                
                if(clk_d='1' and clk='0' and fast_clk_cnt > 2 and dval_int='1') then  -- wait for neg edge
                
                        fast_clk_cnt  <= 0;
                        fast_clk_gate <= '1';

                        -- load shift registers
                        
                        txd_shift <= din_int;
                
                        if( eop_int='1' and dval_int='1' ) then
                        
                                case tmod_int is
                                
                                when "00" => txdv_shift <= "1111";
                                when "01" => txdv_shift <= "0001";
                                when "10" => txdv_shift <= "0011";
                                when "11" => txdv_shift <= "0111";
                                when others => txdv_shift <= "0000";
                                
                                end case;
                        
                        elsif( dval_int='1' ) then
                        
                                txdv_shift <= "1111";
                                
                        end if;
                        

                elsif( fast_clk_cnt < 3 ) then

                        fast_clk_cnt <= fast_clk_cnt+1;
                        
                        txd_shift  <= X"00" & txd_shift(31 downto 8);  -- LSByte first
                        txdv_shift <= '0'   & txdv_shift(3 downto 1);

                        fast_clk_gate <= '1';

                elsif( fast_clk_cnt < 5 and eop_int_d='1' and eop_done='0') then  -- give 2 more at end of frame to generate the frm_rcvd
                
                        txdv_shift   <= "0000";
                        fast_clk_cnt <= fast_clk_cnt+1;
                        fast_clk_gate <= '1';
                
                else
                
                        fast_clk_gate <= '0';
                        
                end if;
        
                -- indicate when we finished the old frame (giving extra cycles after last bytes) 
                -- to block eop_int_d indication in case b2b frames are received

                if( fast_clk_cnt=4 and eop_int_d='1' ) then
                        
                        eop_done <= '1';
                
                elsif( eop_int_d='0' ) then
                
                        eop_done <= '0';
                
                end if;
                


                -- capture frame received indication and sync it to word clock (handshake)
                
                if( frm_rcvd_i='1' ) then
                        
                        frm_rcvd_d <= '1';
                        
                elsif( frm_rcvd_ex='1' ) then
                        
                        frm_rcvd_d <= '0';
                end if;
                
        
        end if;
        
   end process;

   -- DDR process to generate gated clock
           
   process( fast_clk, reset )
   begin
   
        if( reset='1' ) then
        
                tx_clk <= '0';
                
        elsif( fast_clk'event and fast_clk='1' ) then
                
                if( fast_clk_gate = '1' ) then
                        
                        tx_clk <= '1';
                        
                end if;
                
        elsif( fast_clk'event and fast_clk='0' ) then
                
                tx_clk <= '0';

        end if;

    end process;

   --tx_clk <= fast_clk and fast_clk_gate;        

   
   -- Use shifted word data to generate GMII signals
   -- ----------------------------------------------------------
 
   txd   <= txd_shift(7 downto 0);
   tx_dv <= txdv_shift(0);
   tx_er <= derror_int;


-- endian adapter from Little endian to Big endian
--       din      : in  std_logic_vector(31 downto 0);
--       dval     : in  std_logic;
--       derror   : in  std_logic;
--       sop      : in  std_logic;   -- pulse with first word
--       eop      : in  std_logic;   -- pulse with last word (tmod valid)
--       tmod     : in  std_logic_vector(1 downto 0);  -- last word modulo

 process (clk, reset)
  begin 
   if( reset = '1' ) then
       din_reg   <= (others => '0'); 
       dval_reg  <= '0'; 
       derror_reg<= '0'; 
       sop_reg   <= '0'; 
       eop_reg   <= '0'; 
       tmod_reg  <= (others => '0'); 

   elsif( clk'event and clk='1' ) then

     if (BIG_ENDIAN = 1) then

          din_reg   <= (din(7 downto 0) & din(15 downto 8) & din(23 downto 16) & din(31 downto 24)); 
          dval_reg  <= dval_reg ; 
          derror_reg<= derror_reg; 
          sop_reg   <= sop; 
          eop_reg   <= eop; 

          case (tmod) is 
            when "00"   => tmod_reg <= "00";
            when "01"   => tmod_reg <= "11";
            when "10"   => tmod_reg <= "10";
            when "11"   => tmod_reg <= "01";
            when others => tmod_reg <= "00";     
          end case;          
     else
          din_reg            <= din ; 
          dval_reg           <= dval ; 
          derror_reg         <= derror; 
          sop_reg            <= sop; 
          eop_reg            <= eop; 
          tmod_reg           <= tmod; 
     end if;
   end if;      

  end process;


   -- Monitor
   -- ---------
   
   MON1G: ETHMONITOR_32 
   
   generic map (
     ENABLE_SHIFT16 => ENABLE_SHIFT16
   )
   
   port map (

      reset         =>  reset,         -- active high
      tx_clk        =>  tx_clk,
      txd           =>  txd,
      tx_dv         =>  tx_dv,  
      tx_er         =>  tx_er,
      dst           =>  l_dst,           
      src           =>  l_src,                  
      prmble_len    =>  l_prmble_len,    
      pquant        =>  l_pquant,
      vlan_ctl      =>  l_vlan_ctl,
      len           =>  l_len,     
      frmtype       =>  l_frmtype,              
      payload       =>  payload,      
      payload_vld   =>  payload_vld,              
      is_vlan       =>  l_is_vlan,  
      is_stack_vlan =>  l_is_stack_vlan,
      is_pause      =>  l_is_pause,                          
      crc_err       =>  l_crc_err,     
      prmbl_err     =>  l_prmbl_err,
      len_err       =>  l_len_err,      
      payload_err   =>  l_payload_err,
      frame_err     =>  l_frame_err,  
      pause_op_err  =>  l_pause_op_err,
      pause_dst_err =>  l_pause_dst_err,
      mac_err       =>  l_mac_err, 
      end_err       =>  l_end_err,              
      jumbo_en      =>  jumbo_en,      
      data_only     =>  data_only,                   
      frm_rcvd      =>  frm_rcvd_i );     

end behave;


