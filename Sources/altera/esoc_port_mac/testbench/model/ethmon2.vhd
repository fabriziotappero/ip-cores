-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: ethmon2.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/vhdl/ethernet_model/mon/ethmon2.vhd,v $
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
-- MII Interface Ethernet Traffic Monitor/Decoder
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

entity ETHMONITOR2 is 

    port (

      reset         : in  std_logic ;     -- active high

        -- GMII transmit interface: To be connected to MAC TX

      tx_clk        : in  std_logic ;
      txd           : in  std_logic_vector(7 downto 0);
      tx_dv         : in  std_logic;
      tx_er         : in  std_logic;
      tx_sop        : in  std_logic;
      tx_eop        : in  std_logic;
            
       -- Mode of Operation
      ethernet_speed: in  std_logic;    
      mii_mode      : in  std_logic;   -- 4-bit Nibbles (Fast Ethernet)
      rgmii_mode    : in  std_logic;   -- 4-bit DDR (Reduced Gigabit)

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

end ETHMONITOR2 ;

architecture behave of ETHMONITOR2 is

        -- GMII Monitor

        component ETHMONITOR port (

              reset         : in std_logic ;     -- active high
              tx_clk        : in std_logic ;
              txd           : in std_logic_vector(7 downto 0);
              tx_dv     : in std_logic;
              tx_er         : in std_logic;
              tx_sop        : in std_logic;
              tx_eop        : in std_logic;             
              dst           : out std_logic_vector(47 downto 0); -- destination address
              src           : out std_logic_vector(47 downto 0); -- source address
              prmble_len    : out integer range 0 to 10000;         -- length of preamble
              pquant        : out std_logic_vector(15 downto 0); -- Pause Quanta value
              vlan_ctl      : out std_logic_vector(15 downto 0); -- VLAN control info
              len           : out std_logic_vector(15 downto 0); -- Length of payload
              frmtype       : out std_logic_vector(15 downto 0); -- if non-null: type field instead length
              payload       : out std_logic_vector(7 downto 0);
              payload_vld   : out std_logic;
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
              jumbo_en      : in std_logic;
              data_only     : in std_logic;
              frm_rcvd      : out std_logic );
        
        end component;

        signal clk_div2 : std_logic;

        -- Signals for GMII Monitor
    
        signal gmii_clk      : std_logic ;
        signal gmii_d        : std_logic_vector(7 downto 0);
        signal gmii_en       : std_logic;
        signal gmii_er       : std_logic;
        
        -- RGMII demultiplexed

        signal rgmii_d_f     : std_logic_vector(3 downto 0);
        signal rgmii_d       : std_logic_vector(7 downto 0);
        signal rgmii_en_int  : std_logic;
        signal rgmii_en      : std_logic;
        signal rgmii_er      : std_logic;
        signal rgmii_10_100_d   : std_logic_vector(7 downto 0);  
        signal rgmii_10_100_d_lo: std_logic_vector(3 downto 0);
        signal rgmii_hi         : std_logic;
		signal rgmii_en_10_100_d: std_logic;

        -- MII demultiplexed

        signal mii_d_lo    : std_logic_vector(3 downto 0);  -- low nibble
        signal mii_d       : std_logic_vector(7 downto 0);
        signal mii_en      : std_logic;
        signal mii_er      : std_logic;
        signal mii_hi      : std_logic; -- hi nibble is on bus
        
        signal frm_rcvd_mon : std_logic;
        signal frm_rcvd_i   : std_logic;
        
        
begin

        -- demultiplex RGMII 
        
        process(reset, tx_clk )
        begin
                if(reset='1') then
                        
                        rgmii_d_f     <= (others => '0');  -- falling edge
                        rgmii_d       <= (others => '0');  -- rising edge
                        rgmii_en      <= '0';
                        rgmii_en_int  <= '0';
                        rgmii_er      <= '0';
                        
                elsif(tx_clk'event) then -- DDR
                
                        if( tx_clk='0') then
                                
                                rgmii_d_f    <= txd(3 downto 0);     -- low nibble 
                                rgmii_en_int <= tx_dv;               -- dv in 1st half of clock
                                
                        else
                                
                                rgmii_d(7 downto 0) <= txd(3 downto 0) & rgmii_d_f;  -- high nibble on rising edge
                                rgmii_er  <= tx_dv xor rgmii_en_int;
                                rgmii_en  <= rgmii_en_int;            -- produce all on rising edge only
                                
                        end if;
                        
                end if;
                
        end process;
 
        --demultiplex rgmii 10/100  
        process(reset, tx_clk )
        begin
                if(reset='1') then
                        
                        rgmii_10_100_d     <= (others => '0');  -- falling edge
                        rgmii_10_100_d_lo  <= (others => '0');  -- rising edge
                        rgmii_hi           <= '0'; 
                		rgmii_en_10_100_d  <= '0';
                elsif(tx_clk'event and tx_clk='1') then -- DDR
                   -- prepare that we can have a start at any clock cycle.
				   rgmii_en_10_100_d <= rgmii_en;

                   if( tx_dv='0' and rgmii_en='0' ) then
                           
                          rgmii_hi <= '0';
                           
                   else
                          rgmii_hi <= not(rgmii_hi);
                          
                   end if;
                   
                   -- read two nibbles

                   if( rgmii_hi='0') then
                           
                           rgmii_10_100_d_lo <= txd(3 downto 0);   -- low nibble first

                   else
                          
                           rgmii_10_100_d(7 downto 0) <= (txd(3 downto 0) & rgmii_10_100_d_lo);-- after 0.5 ns;   -- hi nibble and all internal dv
                           
                   end if;
                end if;
                
        end process;
       
        -- demultiplex MII 
        
        process(reset, tx_clk )
        begin
                if(reset='1') then
                        
                        mii_d   <= (others => '0');  
                        mii_d_lo<= (others => '0');  -- low nibble
                        mii_en  <= '0';
                        mii_er  <= '0';
                        mii_hi  <= '0';
                        
                        frm_rcvd_i <= '0';
                        clk_div2   <= '0';
                        
                elsif(tx_clk'event and tx_clk='1') then

                        clk_div2 <= not(clk_div2);


                        -- prepare that we can have a start at any clock cycle.

                        if( tx_dv='0' and mii_en='0' ) then
                                
                               mii_hi <= '0';
                                
                        else
                               mii_hi <= not(mii_hi);
                               
                        end if;
                        
                        -- read two nibbles

                        if( mii_hi='0') then
                                
                                mii_d_lo <= txd(3 downto 0);   -- low nibble first

                        else
                               
                                mii_d(7 downto 0) <= (txd(3 downto 0) & mii_d_lo) after 0.5 ns;   -- hi nibble and all internal dv
                                
                                mii_en <= tx_dv after 0.5 ns;
                                mii_er <= tx_er after 0.5 ns;
                                
                        end if;
                
                        -- frame received indication only for 1 clock cycle
                
                        if( frm_rcvd_mon='1' and frm_rcvd_i='0') then
                
                                frm_rcvd_i <= '1';
                                
                        else
                        
                                frm_rcvd_i <= '0';
                        
                        end if;
                        
                
                end if;                                
               
        end process;

    -- connect Model Signals
    
--    gmii_clk <= tx_clk  when mii_mode='0' else clk_div2;

	process (rgmii_mode, mii_mode,ethernet_speed,clk_div2, tx_clk )
	  begin
	  	
	  if( ethernet_speed ='0') then
		  if (rgmii_mode ='1'or mii_mode ='1') then
	          gmii_clk <= clk_div2;
	          end if;
	  else
	      if (rgmii_mode ='1' and  mii_mode ='0') then
	          gmii_clk <= tx_clk;
	  	  end if;
	  end if;

    end process;

    
    gmii_d   <= rgmii_d when (rgmii_mode='1' and ethernet_speed ='1') else
                rgmii_10_100_d when (rgmii_mode='1' and ethernet_speed ='0') else
                mii_d   when mii_mode='1' else
                txd;
    
    gmii_en  <= rgmii_en when (rgmii_mode='1' and ethernet_speed ='1') else
                rgmii_en_10_100_d when (rgmii_mode='1' and ethernet_speed ='0') else
                mii_en   when (mii_mode='1' and ethernet_speed ='0') else
                tx_dv;
    
    gmii_er  <= rgmii_er when rgmii_mode='1' else
                mii_er   when mii_mode='1' else
                tx_er;
    

    frm_rcvd <= frm_rcvd_i when (mii_mode='1' or ethernet_speed ='0') else frm_rcvd_mon;
                
    -- connect GMII Monitor
    -- --------------------
   
   GMII_MON: ETHMONITOR port map (

      reset        => reset,         -- active high
      tx_clk       => gmii_clk,
      txd          => gmii_d,
      tx_dv        => gmii_en,
      tx_er        => gmii_er,
      tx_sop       => tx_sop,
      tx_eop       => tx_eop,
      dst          => dst  ,        
      src          => src  ,        
      prmble_len   => prmble_len,
      pquant       => pquant ,      
      vlan_ctl     => vlan_ctl ,    
      len          => len,          
      frmtype      => frmtype,      
      payload      => payload,      
      payload_vld  => payload_vld,  
      is_vlan      => is_vlan,
      is_stack_vlan=> is_stack_vlan,      
      is_pause     => is_pause,     
      crc_err      => crc_err,      
      prmbl_err    => prmbl_err,    
      len_err      => len_err,      
      payload_err  => payload_err,  
      frame_err    => frame_err,    
      pause_op_err => pause_op_err, 
      pause_dst_err=> pause_dst_err,
      mac_err      => mac_err,      
      end_err      => end_err,      
      jumbo_en     => jumbo_en,     
      data_only    => data_only,    
      frm_rcvd     => frm_rcvd_mon );      

end behave;


