-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: ethgen2.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/vhdl/ethernet_model/gen/ethgen2.vhd,v $
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
-- MII Interface Ethernet Traffic Generator
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

entity ETHGENERATOR2 is 

    generic (  THOLD  : time := 1 ns);

    port (

      reset         : in std_logic ;     -- active high

        -- GMII receive interface: To be connected to MAC RX

      rx_clk        : in std_logic ;
      rxd           : out std_logic_vector(7 downto 0);
      rx_dv         : out std_logic;
      rx_er         : out std_logic;
      
        -- Additional FIFO controls for FIFO test scenarios
                
      sop           : out std_logic;   -- pulse with first character
      eop           : out std_logic;   -- pulse with last  character

       -- Mode of Operation
      ethernet_speed: in std_logic; 
      mii_mode      : in std_logic;   -- 4-bit Nibbles (Fast Ethernet)
      rgmii_mode    : in std_logic;   -- 4-bit DDR (Reduced Gigabit)
      
       
        -- Frame Contents definitions

      mac_reverse   : in std_logic;                     -- 1: dst/src are sent MSB first
      dst           : in std_logic_vector(47 downto 0); -- destination address
      src           : in std_logic_vector(47 downto 0); -- source address
      
      prmble_len    : in integer range 0 to 40;         -- length of preamble
      pquant        : in std_logic_vector(15 downto 0); -- Pause Quanta value
      vlan_ctl      : in std_logic_vector(15 downto 0); -- VLAN control info
      len           : in std_logic_vector(15 downto 0); -- Length of payload
      frmtype       : in std_logic_vector(15 downto 0); -- if non-null: type field instead length
      
      cntstart      : in integer range 0 to 255;  -- payload data counter start (first byte of payload)
      cntstep       : in integer range 0 to 255;  -- payload counter step (2nd byte in paylaod)

      ipg_len       : in integer range 0 to 32768;  -- inter packet gap (delay after CRC)  
      wrong_pause_op: in std_logic ;                    -- Generate Pause Frame with Wrong Opcode       
      wrong_pause_lgth : in std_logic ;                    -- Generate Pause Frame with Wrong Opcode       
       
       -- Control
       
      payload_err   : in std_logic;  -- generate payload pattern error (last payload byte is wrong)
      prmbl_err     : in std_logic;
      crc_err       : in std_logic;
      vlan_en       : in std_logic;
      pause_gen     : in std_logic;
      pad_en        : in std_logic;
      phy_err       : in std_logic;
      end_err       : in std_logic;  -- keep rx_dv high one cycle after end of frame
      magic         : in std_logic;     
      stack_vlan    : in std_logic;   
                
      data_only     : in std_logic;  -- if set omits preamble, padding, CRC
            
      start         : in  std_logic;
      done          : out std_logic );
      
end ETHGENERATOR2 ;

architecture behave of ETHGENERATOR2 is

        
        -- GMII Generator
        -- --------------

        component ETHGENERATOR is 

        generic (  THOLD  : time := 0.1 ns);

        port (

            reset         : in std_logic ;     -- active high
            rx_clk        : in std_logic ;
            enable        : in std_logic ;
	    rxd           : out std_logic_vector(7 downto 0);
            rx_dv         : out std_logic;
            rx_er         : out std_logic;
            sop           : out std_logic;   -- pulse with first character
            eop           : out std_logic;   -- pulse with last  character
            mac_reverse   : in std_logic;                     -- 1: dst/src are sent MSB first
            dst           : in std_logic_vector(47 downto 0); -- destination address
            src           : in std_logic_vector(47 downto 0); -- source address
            prmble_len    : in integer range 0 to 40;         -- length of preamble
            pquant        : in std_logic_vector(15 downto 0); -- Pause Quanta value
            vlan_ctl      : in std_logic_vector(15 downto 0); -- VLAN control info
            len           : in std_logic_vector(15 downto 0); -- Length of payload
            frmtype       : in std_logic_vector(15 downto 0); -- if non-null: type field instead length
            cntstart      : in integer range 0 to 255;  -- payload data counter start (first byte of payload)
            cntstep       : in integer range 0 to 255;  -- payload counter step (2nd byte in paylaod)
            ipg_len       : in integer range 0 to 32768;  -- inter packet gap (delay after CRC)  
            payload_err   : in std_logic;  -- generate payload pattern error (last payload byte is wrong)
            prmbl_err     : in std_logic;
            crc_err       : in std_logic;
            vlan_en       : in std_logic;
            wrong_pause_op: in std_logic ;                    -- Generate Pause Frame with Wrong Opcode       
            wrong_pause_lgth : in std_logic ;                    -- Generate Pause Frame with Wrong Opcode       
            pause_gen     : in std_logic;
            pad_en        : in std_logic;
            phy_err       : in std_logic;
            end_err       : in std_logic;  -- keep rx_dv high one cycle after end of frame
            magic         : in std_logic;     
            stack_vlan    : in std_logic;   
            data_only     : in std_logic;  -- if set omits preamble, padding, CRC
            start         : in  std_logic;
            done          : out std_logic );
      
        end component ;


            -- GMII Generator Clock input and Outputs
                
        signal gmii_clk      : std_logic ;
        signal gmii_d        : std_logic_vector(7 downto 0);
        signal gmii_en       : std_logic;
        signal gmii_en_d     : std_logic;
        signal gmii_er       : std_logic;
        signal sop_gen       : std_logic;   -- pulse with first character
        signal eop_gen       : std_logic;   -- pulse with last  character
        signal done_gen      : std_logic;

        signal eop_int       : std_logic;   -- pulse with last  character

        signal sop_m         : std_logic;
        signal eop_m         : std_logic;

        signal start_gen     : std_logic_vector(1 downto 0);

        signal clk_div2 : std_logic;
        
        signal nib1     : std_logic_vector(3 downto 0);
        
        signal rgmii_en_er : std_logic;
        signal rgmii_dat   : std_logic_vector(3 downto 0);
        signal rgmii_dat_f : std_logic_vector(3 downto 0);  -- save upper nibble for falling edge

        signal mii_en   : std_logic;
        signal mii_er   : std_logic;
        signal mii_dat  : std_logic_vector(3 downto 0);


        signal gmii_err_d			: std_logic;
        signal gmii_10_100_en_d		: std_logic;
        signal gmii_10_100_err_d	: std_logic;
        signal rgmii_10_100_en_er	: std_logic;
        signal rgmii_10_100_en_er_d	: std_logic;
        signal rgmii_10_100_en_er_d2: std_logic;
        signal rgmii_en_er_f		: std_logic; 
        signal rgmii_10_100_en_er_f	: std_logic;


begin
        
        -- divide clock for nibble transfers 8-bit pathes
        
        process(reset, rx_clk)
        begin
                if(reset='1') then
                        
                        clk_div2  <= '0';
                        start_gen <= "00";
                        
                elsif( rx_clk'event and rx_clk='1') then
                        
                        clk_div2 <= not(clk_div2);
                        
                        if( start='1' ) then
                                
                                start_gen <= (others => '1');
                                
                        else
                                
                                start_gen(1 downto 0) <= '0' & start_gen(1);  -- make it longer for MII mode
                                
                        end if;
                        
                                
                end if;

        end process;
        
        -- multiplex GMII into RGMII/MII
        
        process(reset, gmii_clk)
        begin
                if(reset='1' ) then
                        
                        rgmii_en_er <= '0';
						rgmii_en_er_f <= '0';
                        rgmii_dat   <= (others => '0');
                        rgmii_dat_f <= (others => '0');
                        
                        sop_m <= '0';
                        eop_m <= '0';
                        gmii_en_d  <= '0';
                        gmii_err_d  <= '0';

                elsif( gmii_clk'event ) then   -- DDR
                        
                        if( gmii_clk='1') then
                                
                                gmii_en_d <= gmii_en;
                                done      <= done_gen and not(gmii_en);
                                
                                -- FIFO signaling in right clock edge
                                
                                sop_m   <= sop_gen;
                                eop_int <= eop_gen;
                                
                                if( (mii_mode='1' or rgmii_mode = '1') and ethernet_speed ='0') then       -- not in MII, then EOP is 1 clock cycle already
                                        
                                        eop_m <= '0';
                                
                                else
                                
                                        eop_m <= eop_gen;
                                        
                                end if;
                                
                                -- Data and Control
                                
                                rgmii_en_er <= gmii_en after THOLD;
                                rgmii_dat   <= gmii_d(3 downto 0) after THOLD;
                                rgmii_dat_f <= gmii_d(7 downto 4);

                                mii_en      <= gmii_en after THOLD;
                                mii_er      <= gmii_er after THOLD;
                                
                        else
                                rgmii_en_er <= (gmii_er xor gmii_en_d) after THOLD; 
                                rgmii_dat   <= rgmii_dat_f after THOLD;   -- produce upper nibble 

                                if( (mii_mode='1' or rgmii_mode = '1') and ethernet_speed ='0') then

                                        sop_m     <= '0';
                                        eop_m     <= eop_int;

                                end if;
                                
                                
                        end if;
                end if;
                
        end process;
        
        -- connect clock
        
--        gmii_clk <= rx_clk when mii_mode='0' else clk_div2;
        
        process (rgmii_mode, mii_mode,ethernet_speed,clk_div2, rx_clk )
          begin
          	
          if( ethernet_speed ='0') then
        	  if (rgmii_mode ='1'or mii_mode ='1') then
                  gmii_clk <= clk_div2;
                  end if;
          else
          
                  gmii_clk <= rx_clk;
          
          end if;
    
        end process;
        -- connect output ports
        
        rxd(7 downto 4) <= "0000"      when (rgmii_mode='1' or mii_mode='1' or reset='1') else gmii_d(7 downto 4) after THOLD;
        rxd(3 downto 0) <= rgmii_dat   when (rgmii_mode='1' or mii_mode='1' or reset='1') else gmii_d(3 downto 0) after THOLD;
        
        rx_dv           <= '0' when reset='1' else
                           rgmii_en_er when rgmii_mode='1' else
                           mii_en      when mii_mode='1' else
                           gmii_en after THOLD;
        
        rx_er           <= '0' when reset='1' else 
                           '0'         when rgmii_mode='1' else
                           mii_er      when mii_mode='1' else
                           gmii_er after THOLD;
             
             
        sop <= sop_m after THOLD when (rgmii_mode='1' or mii_mode='1') else sop_gen after THOLD;
        eop <= eop_m after THOLD when (rgmii_mode='1' or mii_mode='1') else eop_gen after THOLD;
                           

 GMII_GEN: ETHGENERATOR   generic map (  THOLD => 0.1 ns )
   
        port map (
   
        reset          => reset,         -- active high
        rx_clk         => gmii_clk, 
        enable         => '1',
	rxd            => gmii_d,    
        rx_dv          => gmii_en,
        rx_er          => gmii_er,
        sop            => sop_gen,
        eop            => eop_gen,
        
        mac_reverse    => mac_reverse,
        dst            => dst,        
        src            => src,        
        prmble_len     => prmble_len, 
        pquant         => pquant,     
        vlan_ctl       => vlan_ctl,   
        len            => len,        
        frmtype        => frmtype,       
        cntstart       => cntstart,   
        cntstep        => cntstep,   
        ipg_len        => ipg_len,
        payload_err    =>  payload_err,  
        prmbl_err      =>  prmbl_err,  
        crc_err        =>  crc_err, 
        wrong_pause_op => wrong_pause_op ,  
        wrong_pause_lgth=>wrong_pause_lgth , 
        vlan_en        =>  vlan_en,    
        pause_gen      =>  pause_gen,  
        pad_en         =>  pad_en,     
        phy_err        =>  phy_err,    
        end_err        =>  end_err,
        magic          =>  magic ,
        stack_vlan     =>  stack_vlan,
        data_only      =>  data_only,    
        start          =>  start_gen(0),      
        done           =>  done_gen  );

end behave;


