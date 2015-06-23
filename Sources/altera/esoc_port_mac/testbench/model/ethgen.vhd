-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: ethgen.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/vhdl/ethernet_model/gen/ethgen.vhd,v $
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
-- GMII Interface Ethernet Traffic Generator
-- Ethernet Traffic Generator for 8 bit MAC Atlantic client interface
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

entity ETHGENERATOR is 

    generic (  THOLD          : time    := 1 ns;
			   ENABLE_SHIFT16 : integer := 0  --0 for false, 1 for true
			);
    port (

      reset       : in std_logic ;     -- active high

        -- GMII receive interface: To be connected to MAC RX
      rx_clk      : in std_logic ;
      enable      : in std_logic ;
      rxd         : out std_logic_vector(7 downto 0);
      rx_dv       : out std_logic;
      rx_er       : out std_logic;
      
        -- Additional FIFO controls for FIFO test scenarios
                
      sop         : out std_logic;   -- pulse with first character
      eop         : out std_logic;   -- pulse with last  character

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
      wrong_pause_op : in std_logic ;                    -- Generate Pause Frame with Wrong Opcode       
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
      
end ETHGENERATOR ;

architecture behave of ETHGENERATOR is

    -- local copied (registered) commands 
    -- ----------------------------------

    signal  imac_reverse   :  std_logic;                     -- 1: dst/src are sent MSB first
    signal  idst           :  std_logic_vector(47 downto 0); -- destination address
    signal  isrc           :  std_logic_vector(47 downto 0); -- source address
    signal  imagic         :  std_logic;                     -- generate magic packet
      
    signal  iprmble_len    :  integer range 0 to 40;  -- length of preamble
    signal  ipquant        :  std_logic_vector(15 downto 0); -- Pause Quanta value
    signal  ivlan_ctl      :  std_logic_vector(15 downto 0); -- VLAN control info
    signal  ilen           :  std_logic_vector(15 downto 0); -- Length of payload
    signal  ifrmtype          :  std_logic_vector(15 downto 0); -- if non-null: type field instead length
      
    signal  icntstart      :  integer range 0 to 255;  -- payload data counter start (first byte of payload)
    signal  icntstep       :  integer range 0 to 255;  -- payload counter step (2nd byte in paylaod)
    signal  iipg_len       :  integer range 0 to 32768; -- inter packet gap

    signal  ipayload_err     :  std_logic;
    signal  iprmbl_err     :  std_logic;
    signal  icrc_err       :  std_logic;
    signal  ivlan_en       :  std_logic;
    signal  istack_en      :  std_logic;
    signal  ipause_gen     :  std_logic;
    signal  ipad_en        :  std_logic;
    signal  iphy_err       :  std_logic;
    signal  iend_err       :  std_logic;
    
    signal  idata_only     :  std_logic;


    -- internal

    type  state_typ is (S_IDLE, S_PRMBL, S_SFD, S_STACK,
                                S_DST , S_SRC, S_PAUSE, S_TAG, S_LEN,
                                S_DATA, S_PAD, S_CRC, S_ENDERR, S_IPG, S_Dword32Aligned);
    
    signal state      : state_typ;
    signal last_state : state_typ;
    signal last_state_dly : state_typ;   -- delayed one again
    
    signal crc32 : std_logic_vector(31 downto 0);
    
    signal count : integer range 0 to 65535;
    signal poscnt: integer range 0 to 65535;       -- position in frame starts at first dst byte
    
    signal datacnt: integer range 0 to 255;
    signal rxdata: std_logic_vector(7 downto 0);   -- next data to put on the line

    signal sop_int: std_logic;

    signal rx_clk_gen: std_logic;
    signal enable_int: std_logic;
    signal dval_temp: std_logic;
    signal dout_temp: std_logic_vector (7 downto 0);
    signal sop_temp: std_logic;
    signal eop_temp: std_logic;
    signal derror_temp: std_logic;
    signal enable_reg: std_logic;
    signal done_temp: std_logic;

begin


    process (rx_clk, reset)
       begin
         if (reset = '1') then
           enable_reg <= '0';  
         elsif (rising_edge(rx_clk)) then
           enable_reg <= enable;
         end if;
    end	process;

    enable_int <= enable_reg;
    rxd        <= dout_temp; 
    rx_dv      <= dval_temp; 
    rx_er      <= derror_temp; 
    sop        <= sop_temp; 
    eop        <= eop_temp; 
    done       <= done_temp;    
    rx_clk_gen <= rx_clk and enable_int;


 -- -----------------------------------
 -- capture command when start asserted
 -- -----------------------------------

    process( rx_clk_gen, reset ) 
    begin
    
        if( reset='1') then
        
            imac_reverse   <= '0';               -- 1: dst/src are sent MSB first
        idst           <= (others => '0');   -- destination address
            isrc           <= (others => '0'); -- source address
            imagic         <= '0' ;
    
            iprmble_len    <= prmble_len;  -- length of preamble
            ipquant        <= (others => '0'); -- Pause Quanta value
            ivlan_ctl      <= (others => '0'); -- VLAN control info
            ilen           <= (others => '0'); -- Length of payload
            ifrmtype          <= (others => '0'); -- if non-null: type field instead length
    
            icntstart      <= 0;  -- payload data counter start (first byte of payload)
            icntstep       <= 0;  -- payload counter step (2nd byte in paylaod)
            iipg_len       <= 0;

            ipayload_err   <= '0';
            iprmbl_err     <= '0';
            icrc_err       <= '0';
            ivlan_en       <= '0';
            istack_en      <= '0';
            ipause_gen     <= '0';
            ipad_en        <= '0';
            iphy_err       <= '0';
            iend_err       <= '0';
            idata_only     <= '0';

        elsif( rx_clk_gen='1' and rx_clk_gen'event and start='1' and state=S_IDLE) then
          
            imac_reverse   <= mac_reverse;               -- 1: dst/src are sent MSB first
            idst           <= dst;   -- destination address
            isrc           <= src; -- source address
            imagic         <= magic;
    
            iprmble_len    <= prmble_len;  -- length of preamble
            ipquant        <= pquant; -- Pause Quanta value
            ivlan_ctl      <= vlan_ctl; -- VLAN control info
            
            if (magic='1') then
            
                ilen       <= conv_std_logic_vector(46, 16) ;
                
            else
            
                ilen       <= len; -- Length of payload
                
            end if ;
            
            ifrmtype       <= frmtype; -- if non-null: type field instead length
    
            icntstart      <= cntstart;  -- payload data counter start (first byte of payload)
            icntstep       <= cntstep;  -- payload counter step (2nd byte in paylaod)
            iipg_len       <= ipg_len;

            ipayload_err   <= payload_err;
            iprmbl_err     <= prmbl_err;
            icrc_err       <= crc_err;
            ivlan_en       <= vlan_en;
            istack_en      <= stack_vlan;
            ipause_gen     <= pause_gen;
            ipad_en        <= pad_en;
            iphy_err       <= phy_err;
            iend_err       <= end_err;
            idata_only     <= data_only;
            
        end if;      
    end process;    


 -- ----------------------------------------------
 -- CRC calculation over all bytes except preamble
 -- ----------------------------------------------
    
    process( rx_clk_gen, reset )
    
        variable crctmp : std_logic_vector(31 downto 0);
        variable i      : integer range 0 to 8;
    
    begin
        if( reset = '1' ) then
            
            crc32 <= (others => '1' );
        
        elsif( rx_clk_gen = '0' and rx_clk_gen'event ) then    -- need it ahead
        
            if( last_state=S_SFD ) then  
        
                crc32 <= (others => '1' );    -- RESET CRC at start of DST
        
            elsif( (state /= S_IDLE) and 
                   (state /= S_PRMBL) and
                   (last_state /= S_CRC ) ) then
            
                    crctmp := crc32;
            
                    for i in 0 to 7 loop      -- process all bits we have here
                   
                       if( (rxdata(i) xor crctmp(31)) = '1' ) then
                         crctmp := to_stdlogicvector((to_bitvector(crctmp)) sll 1);  -- shift in a 0, will be xor'ed to 1 by the polynom
                         crctmp := crctmp xor X"04C11DB7";
                       else
                         crctmp := to_stdlogicvector((to_bitvector(crctmp)) sll 1);  -- shift in a 0
                       end if;
                      
                   end loop;
                   
                   crc32 <= crctmp;
                   
            end if;

        end if;
        
    end process;

 -- ----------------------------------------------
 -- Push RX Data on GMII and 
 -- produce PHY error if requested during SRC address transmission
 -- ----------------------------------------------

    process( rx_clk_gen, reset )
    begin
        if( reset = '1' ) then
            
            dout_temp   <= (others => '0' );
            dval_temp <= '0';
            derror_temp <= '0';
        
        elsif( rx_clk_gen = '1' and rx_clk_gen'event ) then
        
            if( (last_state = S_IDLE) or (last_state=S_IPG)) then
            
                dout_temp   <= (others => '0') after THOLD;
                dval_temp <= '0' after THOLD;
                
            else
            
                -- Data and DV 
            
                dout_temp   <= rxdata after THOLD;
                dval_temp <= '1' after THOLD;
                
                -- PHY error in SRC field
                
                if( last_state=S_SRC and count=2 and iphy_err='1' and data_only='0') then
                
                    derror_temp <= '1' after THOLD;
                    
                elsif (data_only='1' and iphy_err='1' and ((last_state/=S_IDLE and state=S_IDLE) or
                      (last_state/=S_IPG and state=S_IPG )) ) then
            
                        if( not(last_state=S_IPG and state=S_IDLE) ) then  -- if from ipg to idle, eop has been pulsed already
                    
                                derror_temp <= '1' after THOLD;
                    
                        end if;
                    
                else
                
                    derror_temp <= '0' after THOLD;
                    
                end if;
                
            end if;
            
        end if;
        
    end process;

 -- ----------------------------------------------
 -- SOP and EOP generation (helper for FIFO testing)
 -- ----------------------------------------------

    process( rx_clk_gen, reset )
    begin
      if( reset = '1' ) then

            sop_temp     <= '0';
            sop_int <= '0'; 
            eop_temp     <= '0';
           
      elsif(rx_clk_gen='1' and rx_clk_gen'event ) then
    
            if(last_state=S_IDLE and state/=S_IDLE) then
            
                sop_int <= '1';
                
            else
            
                sop_int <= '0';
                
            end if;
            
            if((last_state/=S_IDLE and state=S_IDLE) or
               (last_state/=S_IPG and state=S_IPG ) ) then
            
                if( not(last_state=S_IPG and state=S_IDLE) ) then  -- if from ipg to idle, eop has been pulsed already
                    
                    eop_temp <= '1' after THOLD;
                    
                end if;
                
            else
            
                eop_temp <= '0' after THOLD;
                
            end if;
            
            sop_temp <= sop_int after THOLD; -- need 1 delay
    
      end if;
    end process;



 -- ----------------------------------------------
 -- Position Counter: Starts with first octet of destination address
 -- ----------------------------------------------

    process( rx_clk_gen, reset )
    begin
      if( reset = '1' ) then

            poscnt <= 0;
           
      elsif(rx_clk_gen='1' and rx_clk_gen'event ) then
      
            if( (state=S_SFD) or      
                (state=S_IDLE and start='1') ) then  -- in the data_only case necessary
            
                poscnt <= 0;                   -- is 1 with the first byte sent (prmbl or DST)
                
            else
            
                if( poscnt < 65535 ) then   
                       
                        poscnt <= poscnt +1;
                        
                end if;
                
            end if;
     end if;
    end process;

 -- ----------------------------------------------
 -- Done indication
 -- ----------------------------------------------
    process( rx_clk_gen, reset )
    begin
      if( reset = '1' ) then

            done_temp <= '1';
           
      elsif(rx_clk_gen='1' and rx_clk_gen'event ) then

            if( state=S_IDLE ) then 
            
                done_temp <= not start;
                
            else

                done_temp <= '0';

            end if;

      end if;
    end process;
    
      
 -- ----------------------------------------------
 -- Generator State Machine
 -- ----------------------------------------------

    process( rx_clk_gen, reset )
    
        variable hi,lo  : integer;
        variable cnttmp : integer range 0 to 65536;
        variable i      : integer;
    
    begin
      if( reset = '1' ) then

            state      <= S_IDLE;
            last_state <= S_IDLE;
            
            rxdata <= (others => 'X' );
            count  <= 0;
            
      elsif(rx_clk_gen='1' and rx_clk_gen'event ) then
      
          -- remember last state and increment internal counter
            
          last_state <= state;  
          last_state_dly <= last_state;  -- for viewing only

          if(count < 65535) then 
             cnttmp := count+1;  
          else
             cnttmp := count ;  
          end if;
     
      
          case state is
          
            when S_IDLE  => if( start='1' ) then
            
                                if( data_only='1' ) then    -- data only then skip preamble
                                   if (ENABLE_SHIFT16 = 0) then
                                     state <= S_DST;
                                   else
								     state <= S_Dword32Aligned;
								   end if;
                                    cnttmp  := 0;
                                    
                                elsif (iprmble_len=0) then
                                
                                    state <= S_SFD ; 
                                    
                                else
            
                                    state   <= S_PRMBL;
                                    cnttmp  := 1;
                                    
                                end if;

                            end if;
                            
                            rxdata  <= (others => 'X' );
                            
                                
                            
            when S_PRMBL => if( iprmble_len <= cnttmp ) then   -- one earlier
                                  state  <= S_SFD;
                            end if;
                            rxdata  <= X"55";
                            
                            
            when S_SFD   =>  state  <= S_DST;
                             cnttmp := 0;
           
                            if( iprmbl_err = '1' ) then
                                
                                rxdata <= X"F5";  -- preamble error
                                    
                            else 
                                
                                rxdata <= X"D5";
                                    
                            end if;


			when S_Dword32Aligned =>

                            if (count = 1) then
                            	state <= S_DST;
								cnttmp := 0;
							 end if;

							case count is
							 when 0|1    => rxdata <= X"00";
							 when others =>	null;
							end case; 

            when S_DST   => if( count = 5) then
            
                                state  <= S_SRC;
                                cnttmp := 0;
                               
                            end if;
                            
                            if( mac_reverse='1' ) then

                                hi := 47-(count*8);
                                lo := 40-(count*8);
                            
                            else 
                                                        
                                hi := (count*8)+7;
                                lo := (count*8);
                                
                            end if;
                                                        
                            rxdata(7 downto 0) <= idst(hi downto lo);
                            

            when S_SRC   => if( count = 5) then
            
                                if( ipause_gen='1' ) then

                                    state  <= S_PAUSE;

                                elsif( ivlan_en='1' ) then
                                
                                    state  <= S_TAG ;      -- VLAN follows
                                
                                else
                                
                                    state  <= S_LEN ;      -- normal frame
                                                                 
                                end if;
                                cnttmp := 0;
                               
                            end if;
                            
                            if( mac_reverse='1' ) then

                                hi := 47-(count*8);
                                lo := 40-(count*8);
                            
                            else 
                                                        
                                hi := (count*8)+7;
                                lo := (count*8);
                                
                            end if;
                                                        
                            rxdata(7 downto 0) <= isrc(hi downto lo);
                            
                             
            when S_PAUSE => 
                        
                            if(   count=0 ) then rxdata <= X"88";
                            elsif(count=1 ) then rxdata <= X"08";
                            elsif(count=2 ) then 
                            
                                if (wrong_pause_op='0') then
                            
                                        rxdata <= X"00";
                                        
                                else
                                
                                        rxdata <= X"03" ;
                                        
                                end if ;
                                
                            elsif(count=3 ) then rxdata <= X"01";
                            elsif(count=4 ) then rxdata <= pquant(15 downto 8);
                            elsif(count=5 ) then 
                            
                                    rxdata <= pquant(7 downto 0);
                                    
                                    if (wrong_pause_lgth='1') then
                                    
                                        state <= S_LEN ;
                                    
                                    elsif( ipad_en='1' ) then
                                    
                                        state <= S_PAD;
                                        
                                    else
                                    
                                        state <= S_CRC;     -- error non-padded pause frame
                                        
                                    end if;
                                   
                                    cnttmp := 0;
                                    
                            end if;                                           
                             
            when S_TAG  =>  if(   count=0 ) then   rxdata <= X"81";
                            elsif(count=1 ) then   rxdata <= X"00";
                            elsif(count=2 ) then   rxdata <= ivlan_ctl(15 downto 8);
                            elsif(count=3 ) then   
                            
                                    rxdata <= ivlan_ctl(7  downto 0);
                                    
                                    if (istack_en='0') then
                                    
                                        state  <= S_LEN;
                                        cnttmp := 0;
                                        
                                     else
                                     
                                        state  <= S_STACK;
                                        cnttmp := 0;   
                                        
                                     end if ;
                            
                            end if;
                            
            when S_STACK  =>  if(   count=0 ) then   rxdata <= X"81";
                              elsif(count=1 ) then   rxdata <= X"00";
                              elsif(count=2 ) then   rxdata <= ivlan_ctl(15 downto 8);
                              elsif(count=3 ) then   
                            
                                    rxdata <= ivlan_ctl(7  downto 0);
                                    
                                    state  <= S_LEN;
                                    cnttmp := 0;
                            
                            end if;                            
                            
            when S_LEN  =>  
            
                           if( count = 0) then

                                if ( frmtype /= 0 ) then
                                
                                    if (wrong_pause_lgth='1') then
                           
                                        rxdata <= (others=>'0') ;     
                           
                                    else
                                
                                        rxdata <= frmtype(15 downto 8); 
                                        
                                    end if ;     
                                    
                                else
                                
                                    if (wrong_pause_lgth='1') then
                           
                                        rxdata <= (others=>'0') ;     
                           
                                    else
                                
                                        rxdata <= ilen(15 downto 8);      -- MSB
                                        
                                    end if ;
                                    
                                end if;
                                
                            elsif( count=1 ) then
                            
                                if( frmtype /= 0 ) then
                                
                                    if (wrong_pause_lgth='1') then
                           
                                        rxdata <= (others=>'0') ;     
                           
                                    else
                                
                                        rxdata <= frmtype(7 downto 0);
                                        
                                    end if ;
                                    
                                else
                                
                                    if (wrong_pause_lgth='1') then
                           
                                        rxdata <= (others=>'0') ;     
                           
                                    else
                                    
                                        rxdata <= ilen(7 downto 0);       -- LSB
                                        
                                    end if ;
                                    
                                end if;
                                
                                -- if zero length frame go directly to pad
                                
                                if( ilen = 0 ) then
                                
                                    if( idata_only='1' and iend_err='1') then
                                    
                                        state <= S_ENDERR;
                                        
                                    elsif( idata_only='1' ) then
                                    
                                        state <= S_IDLE;           -- stop immediately
                                
                                    elsif( ipad_en = '1' ) then
                                    
                                        state <= S_PAD;
                                        
                                    else
                                    
                                        state <= S_CRC;
                                        
                                    end if;
                                else    
                                    
                                    state <= S_DATA;
                                    
                                end if;
                                
                                cnttmp := 0;
                                
                            end if;
                            
                              
                                
            when S_DATA   =>  
            
            
                if (imagic='0') then
            
                              if(   count = 0) then
            
                                    if (wrong_pause_lgth='1') then
                           
                                        rxdata <= (others=>'0') ;     
                           
                                    else                                

                                        rxdata  <= conv_std_logic_vector(icntstart,8);  -- first the init                                        
                                        
                                    end if ;
                                    
                                    datacnt <= icntstart;
                                
                              elsif(count = 1 ) then
                              
                                    if (wrong_pause_lgth='1') then
                           
                                        rxdata <= (others=>'0') ;     
                           
                                    else
                            
                                        rxdata  <= conv_std_logic_vector(icntstep,8);   -- then the step
                                        
                                    end if ;
                                                                                                      
                              else
                              
                                   if (wrong_pause_lgth='1') then
                           
                                        rxdata <= (others=>'0') ;     
                           
                                    else

                                        rxdata  <= conv_std_logic_vector(datacnt,8);    -- then data
                                        
                                    end if ;
                                
                                    datacnt <= (datacnt + icntstep) mod 256;
                                
                              end if;  

                              
                              -- check end of payload
                              
                              if( count >= (conv_integer(ilen)-1) ) then
                              
                                 if( idata_only='1') then
                                 
                                    if( iend_err='1' ) then
                                 
                                        state <= S_ENDERR;
                                        
                                    elsif( iipg_len /= 0 ) then
                                    
                                        state <= S_IPG;
                                        cnttmp := 0;
                                        
                                    else
                                    
                                        state <= S_IDLE;
                                        
                                    end if;
                                    
                                 elsif( (poscnt < (60-1)) and ipad_en='1' ) then  -- need to pad ?
                                    
                                    state <= S_PAD;
                                    
                                 else
                                
                                    state <= S_CRC;
                                    cnttmp := 0;
                                
                                 end if;

                                 -- modify last data byte if payload error was requested
                                 
                                 if( ipayload_err='1' ) then
                                 
                                    rxdata <= rxdata;  -- just keep the old value signals error
                                    
                                 end if;

                              end if;
                              
                else
                
                   -- Magic Packet Generation
                   -- -----------------------
                
                        if (count=0 or count=1 or count=2 or count=3 or count=4 or count=5) then
                        
                                rxdata <= X"55" ;
                                
                        elsif (count=6 or count=12 or count=18 or count=24 or count=30 or count=36) then
                        
                                rxdata <= idst(7 downto 0) ;
                                
                        elsif (count=7 or count=13 or count=19 or count=25 or count=31 or count=37) then
                        
                                rxdata <= idst(15 downto 8) ;   
                                
                        elsif (count=8 or count=14 or count=20 or count=26 or count=32 or count=38) then
                        
                                rxdata <= idst(23 downto 16) ; 
                                
                        elsif (count=9 or count=15 or count=21 or count=27 or count=33 or count=39) then
                        
                                rxdata <= idst(31 downto 24) ;    
                                
                        elsif (count=10 or count=16 or count=22 or count=28 or count=34 or count=40) then
                        
                                rxdata <= idst(39 downto 32) ; 
                                
                        elsif (count=11 or count=17 or count=23 or count=29 or count=35) then -- or count=41) then
                        
                                rxdata <= idst(47 downto 40) ;  
                                
                        elsif (count=41) then
                        
                                state  <= S_PAD;
                                cnttmp := 0;
                                rxdata <= idst(47 downto 40) ; 
                                
                        end if ;  
                        
                end if ;       
                                                                
             when S_PAD    => rxdata <= (others => '0');   -- PAD BYTE
                              
                              if( poscnt >= (60-1) ) then
             
                                  state <= S_CRC;
                                  cnttmp := 0;
                                  
                              end if;
                              
                              
             when S_CRC    => hi := 31-(count*8);
             
                              -- send CRC inverted, MSB of most significant byte first
             
                              for i in 0 to 7 loop 
             
                                  rxdata(i) <= crc32(hi-i) xor '1' ;  -- first LSB is CRC MSB
                                  
                              end loop;
                              
                              if( count=2 and icrc_err='1') then
                              
                                  rxdata <= rxdata xor X"FF";   -- produce some wrong number
                                  
                              end if;
                              
                              
                              if( count=3) then
                              
                                  if( iend_err='1' ) then
                                  
                                    state <= S_ENDERR;
                                    
                                  elsif( iipg_len > 0 ) then

                                    state <= S_IPG;
                                    cnttmp := 1;
                                    
                                  else
                                  
                                    state <= S_IDLE;
                                  
                                  end if;
                                  
                              end if;  
                              

            when S_ENDERR  =>  if( iipg_len = 0 ) then    -- delay dv going low by one cycle
                              
                                    state <= S_IDLE;
                                    
                               else
                                 
                                    state <= S_IPG;
                                    cnttmp := 1;
                                  
                               end if;
                              
                              
            when S_IPG     =>  if( count >= iipg_len ) then   -- wait after last
            
                                    state <= S_IDLE;
                                    
                               end if;
                              
             end case;                  
                                    
                                    
                            
             -- load the counter with the new value                   
      
             count <= cnttmp;
        
        
      end if;
   end process;



end behave;


