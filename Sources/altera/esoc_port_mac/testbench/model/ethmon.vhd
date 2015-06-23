-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: ethmon.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/vhdl/ethernet_model/mon/ethmon.vhd,v $
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
-- GMII Interface Ethernet Traffic Monitor/Decoder
-- Ethernet Traffic Monitor for 8 bit MAC Atlantic client interface
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

entity ETHMONITOR is 

    generic (  ENABLE_SHIFT16 : integer := 0  --0 for false, 1 for true
			);

    port (

      reset       : in std_logic ;     -- active high

        -- GMII transmit interface: To be connected to MAC TX

      tx_clk      : in std_logic ;
      txd         : in std_logic_vector(7 downto 0);
      tx_dv       : in std_logic;
      tx_er       : in std_logic;
      tx_sop      : in std_logic;
      tx_eop      : in std_logic;
      
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

end ETHMONITOR ;

architecture behave of ETHMONITOR is

        signal frm_in     : std_logic := '0' ;
        signal tx_clk_int : std_logic ;
        signal tx_eop_reg : std_logic ;

    -- port signals internally reused
    
    signal iprmble_len    : integer range 0 to 10000;         -- length of preamble
    signal ifrmtype       : std_logic_vector(15 downto 0);
    signal ilen           : std_logic_vector(15 downto 0);
    signal idst           : std_logic_vector(47 downto 0);

    signal iis_vlan       : std_logic;
    signal iis_stack_vlan : std_logic;
    signal iis_pause      : std_logic;

    -- internal

    type  state_typ is (S_IDLE, S_PRMBL, 
                                S_DST , S_SRC, S_TYPELEN, S_PAUSE, S_TAG, S_LEN,
                                S_DATA, S_PAD, S_CRC, S_ABORT, S_UTYPE, S_Dword32Aligned);
    
    signal state      : state_typ;
    signal last_state : state_typ;
    
    
    signal last_tx_dv : std_logic;     -- follows tx_dv with one cycle delay
    
    
    signal crc32 : std_logic_vector(31 downto 0);
    
    signal count : integer range 0 to 65535;
    signal poscnt: integer range 0 to 65535;       -- position in frame starts at first dst byte
    
    signal datacnt: integer range 0 to 255;   -- counter to verify payload
    signal datainc: integer range 0 to 255;   -- counter increment
        
    signal tx_sof  :  std_logic;   -- start of frame indicator for 1 clk cycle with 1st byte
    signal tx_dst  :  std_logic;   -- start of frame indicator for 1 clk cycle with 1st byte
    
    
begin

        process(reset, tx_clk)
        begin
        
                if (reset='1') then
                
                        tx_eop_reg <= '0' ;
                        
                elsif (tx_clk='1') and (tx_clk'event) then
                
                        tx_eop_reg <= tx_eop ;
                        
                end if ;
                
        end process ;

        process(tx_sop, tx_eop)
        begin
        
                if (tx_sop='1' and data_only='1') then
                
                        frm_in <= '1' ;
                        
                elsif (tx_eop_reg='1') then
                
                        frm_in <= '0' ;
                        
                end if ;
                                        
        end process ;   
        
        process(frm_in, tx_dv, tx_clk)
        begin
        
                if (frm_in='1' and tx_dv='1') then
                
                        tx_clk_int <= tx_clk after 1 ns ;
                        
                elsif (frm_in='1' and tx_dv='0') then
                
                        tx_clk_int <= '0' after 1 ns  ;
                        
                else
                        
                        tx_clk_int <= tx_clk after 1 ns ;
                        
                end if ;
                
        end process ;                                   

    -- connect permanent port signals
    -- ------------------------------

    prmble_len    <= iprmble_len;
    frmtype       <= ifrmtype;
    len           <= ilen;
    dst           <= idst;
    is_vlan       <= iis_vlan;
    is_stack_vlan <= iis_stack_vlan;
    is_pause      <= iis_pause;

    
    -- generate tx start pulse
    -- ----------------------

    tx_sof <= (not(last_tx_dv) and tx_dv) when (data_only='0') else tx_sop;     -- pulse with first byte 0 to 1 change

    
    -- generate pulse start of destination address
    -- --------------------
    
    process( last_state, state ) 
    begin
    
        if( (last_state/=S_DST) and (state=S_DST)) then
        
            tx_dst <= '1';
            
        else
            
            tx_dst <= '0';

        end if;
   end process;


    -- ------------------------------------------
    -- capture tx_er indicator
    -- ------------------------------------------

    process( tx_clk_int, reset ) 
    begin
    
        if( reset='1') then
        
            mac_err    <= '0';
            last_tx_dv <= '0';
            
        elsif( tx_clk_int='1' and tx_clk_int'event ) then
            
            if( tx_sof='1' ) then
            
                mac_err <= '0';            -- reset indicator at start of new receive
                
            elsif( tx_er = '1' ) then
                
                mac_err <= '1';        -- capture one or many
                    
            end if;

            last_tx_dv <= tx_dv;

        end if;
    end process;


    -- ----------------------------------------------
    -- CRC calculation over all bytes except preamble
    -- ----------------------------------------------
    
    process( tx_clk_int, reset )
    
        variable crctmp : std_logic_vector(31 downto 0);
        variable i      : integer range 0 to 8;
    
    begin
        if( reset = '1' ) then
            
            crc32    <= (others => '1' );
            crc_err  <= '0';
        
        elsif( tx_clk_int = '1' and tx_clk_int'event ) then    -- need it ahead
        
            if( (tx_dst='1') or 
                ((state /= S_IDLE) and (state /= S_PRMBL) and (state /= S_UTYPE)) or
                ((state = S_UTYPE) and tx_dv='1') ) then  -- push all inclusive CRC bytes
    
                    -- preset CRC or load current value
    
                    if( tx_dst='1' ) then   -- first data, preset CRC
                    
                        crctmp := (others => '1' );
                    
                    else
            
                        crctmp := crc32;
                        
                    end if;
                    
                    -- calculate next step
            
                    for i in 0 to 7 loop      -- process all bits we have here
                   
                       if( (txd(i) xor crctmp(31)) = '1' ) then
                         crctmp := to_stdlogicvector((to_bitvector(crctmp)) sll 1);  -- shift in a 0, will be xor'ed to 1 by the polynom
                         crctmp := crctmp xor X"04C11DB7";
                       else
                         crctmp := to_stdlogicvector((to_bitvector(crctmp)) sll 1);  -- shift in a 0
                       end if;
                      
                   end loop;
                   
                   crc32 <= crctmp; -- remember current value
                   
                   
                   -- check if CRC is valid
                   
                   if( crctmp = X"C704DD7B" ) then
                   
                        crc_err <= '0';
                        
                   else 
                   
                        crc_err <= '1';
                        
                   end if;
                   
            end if;

        end if;
        
    end process;

    -- ----------------------------------------------
    -- Extract RX Payload on payload bus and check payload errors:
    -- * first byte is counter initialization
    -- * second byte is counter increment
    -- * data begins from 3rd byte on 
    -- ----------------------------------------------

    process( tx_clk_int, reset )
    begin
        if( reset = '1' ) then
            
            payload     <= (others => '0' );
            payload_vld <= '0';
            payload_err <= '0';
            datacnt     <= 0;
        
        elsif( tx_clk_int='1' and tx_clk_int'event ) then
        
            if( state = S_TYPELEN ) then
            
                payload_err <= '0';        -- reset as a frame of length 0 will not get into S_DATA.
                
            end if;
        
            if( state = S_DATA) then
            
                payload     <= txd;
                payload_vld <= '1';
                
                if( count=0 ) then
                
                    datacnt <= conv_integer('0' & txd);   -- load counter
                    payload_err <= '0';
                    
                elsif( count=1) then
                
                    datainc <= conv_integer('0' & txd);   -- load increment
                    
                else

                        -- verify payload contents
                
                    datacnt <= (datacnt+datainc) mod 256;
                    
                    if( datacnt /= conv_integer('0' & txd ) ) then
                    
                         payload_err <= '1';
                         
                    end if;

                end if;
                
            else
            
                payload       <= (others => '0' );
                payload_vld   <= '0';
                
            end if;
        end if;
    end process;

    -- ----------------------------------------------
    -- Position Counter: Starts with first octet of destination address
    -- ----------------------------------------------

    process( tx_clk_int, reset )
    begin
      if( reset = '1' ) then

            poscnt <= 0;
           
      elsif(tx_clk_int='1' and tx_clk_int'event ) then
      
            if( tx_dst='1' ) then  -- reset at start of DST 
            
                poscnt <= 1;
                
            else
            
                if( poscnt < 65535 ) then
            
                        poscnt <= poscnt +1;
                        
                end if;
                
            end if;
     end if;
    end process;


    -- ----------------------------------------------
    -- End of Frame:
    -- change from non-idle to idle indicates something was received
    -- if dv is still asserted this is an end error
    -- ----------------------------------------------
    process( tx_clk_int, reset )
    begin
      if( reset = '1' ) then

            frm_rcvd <= '0';
            end_err  <= '0';
           
      elsif(tx_clk_int='1' and tx_clk_int'event ) then

            if( last_state/=S_IDLE and state=S_IDLE ) then
            
                frm_rcvd <= '1';
                
            else
            
                frm_rcvd <= '0';
                
            end if;
            
            
            if( tx_sof='1' ) then
            
                end_err <= '0';
                
            elsif(last_state/=S_IDLE and state=S_IDLE and tx_dv='1') then
            
                end_err <= '1';  -- dv still asserted even after nothing more expected
                
            end if;
            
      end if;
    end process;
    
    -- ----------------------------------------------
    -- Preamble check
    -- ----------------------------------------------
    process( tx_clk_int, reset )
    begin
      if( reset = '1' ) then

            prmbl_err <= '0';
            iprmble_len <= 0;
           
      elsif(tx_clk_int='1' and tx_clk_int'event ) then
    
            if( tx_sof='1' ) then
            
                if( txd /= X"55" ) then
                
                    prmbl_err <= '1';
                    
                else
                
                    prmbl_err <= '0';      -- reset usually
                    
                end if;
                
                if( data_only='1' ) then
                
                    iprmble_len <= 0;
                    
                else
                
                    iprmble_len <= 1;
                    
                end if;
                
                
            elsif( state=S_PRMBL ) then
            
                if( txd /= X"55" and txd /= X"D5" ) then
                
                    prmbl_err <= '1';
                    
                end if;
                
                iprmble_len <= iprmble_len + 1;
                
            end if;
      end if;
    end process;
      
      
    -- ----------------------------------------------
    -- Extract Source and Destination addresses
    -- ----------------------------------------------
    process( tx_clk_int, reset )
    
        variable ix: integer;
    
    begin
      if( reset = '1' ) then

            idst <= (others => '0');
            src <= (others => '0');
           
      elsif(tx_clk_int='1' and tx_clk_int'event ) then

            ix := (count*8);

            if( tx_sof='1' ) then       
                ix := 0;
            end if;

            if (tx_sof = '1' and data_only = '1' and state = S_Dword32Aligned and ENABLE_SHIFT16 = 1) then
                   case (count)	is
                    when 0|1   => null ;
                    when others=> null ; 
                   end case ;        
            end if;

            if (tx_sof = '0' and data_only = '1' and ENABLE_SHIFT16 = 1 and state = S_DST) then
              idst(ix+7 downto ix) <= txd(7 downto 0);      -- first received is LSByte
            end if;

            if( (tx_sof='1' and data_only='1' and ENABLE_SHIFT16 = 0) or     -- very first byte and not preamble
                (state=S_DST) ) then
                
                idst(ix+7 downto ix) <= txd(7 downto 0);      -- first received is LSByte
                
            end if;
            
            if( state=S_SRC ) then
                
                src(ix+7 downto ix) <= txd(7 downto 0);      -- first received is LSByte
            
            end if;

      end if;
      
    end process;

    -- ----------------------------------------------
    -- Extract Length/Type field and VLAN Tag identifier
    -- ----------------------------------------------
    process( tx_clk_int, reset )
        
        variable ix: integer;
        variable ln: line;
    
    begin
      if( reset = '1' ) then

            ilen           <= (others => '0');
            ifrmtype       <= (others => '0');
            vlan_ctl       <= (others => '0');
            iis_vlan       <= '0';
            len_err        <= '0';
            iis_stack_vlan <= '0' ;
            
      elsif(tx_clk_int='1' and tx_clk_int'event ) then

            ix := 8-(count*8);

            --if( tx_sof_d = '1' ) then              -- clear all on start of every frame
            --
            --    ilen     <= (others => '0');
            --    ifrmtype <= (others => '0');
            --    vlan_ctl <= (others => '0');
            --    iis_vlan  <= '0';
            --    
            --end if;

            if( state=S_TYPELEN ) then            -- if in type/len set both

                ifrmtype(ix+7 downto ix) <= txd;
                ilen(ix+7 downto ix)     <= txd;
                vlan_ctl <= (others => '0');      -- clear at start of new frame (at SOF it is too early)
                iis_vlan  <= '0';
                len_err  <= '0';
                
            elsif( state=S_LEN ) then             -- in len again, set len independently
            
                ilen(ix+7 downto ix)     <= txd;
            
            elsif( state=S_TAG ) then
            
                iis_vlan  <= '1';
                vlan_ctl(ix+7 downto ix) <= txd;
                
            end if;
            
            if( state=S_TYPELEN ) then
            
                iis_stack_vlan <= '0' ;
                
            elsif (last_state=S_LEN and state=S_TAG) then
            
                iis_stack_vlan <= '1' ;
                
            end if ;
            
            -- verify length at end of frame for normal frames (length 46... max and not a type)
            
            if( (last_state=S_CRC) and (state=S_IDLE) and iis_pause='0' and
                ( (iis_vlan='0' and (ilen > 45)) or 
                  (iis_vlan='1' and (ilen > 41))) ) then

                        -- verify integrity of length field 
                        
                        if( tx_dv='1' or                                 -- state machine did not expect more
                            (iis_stack_vlan='1' and (ilen /= (poscnt-26))) or
                            ((iis_vlan='1' and iis_stack_vlan='0') and (ilen /= (poscnt-22))) or
                            (iis_vlan='0'       and (ilen /= (poscnt-18))) ) then
                                
                                len_err <= '1';
                                
                        else
                                
                                len_err <= '0';
                                
                        end if;
                        
            end if;
            
      end if;
   end process;
          
          
    -- ----------------------------------------------
    -- Extract Pause frame indication,
    --               opcode error,
    --               destination address error,
    --               and Pause Quanta
    -- ----------------------------------------------
    process( tx_clk_int, reset )
        
        variable ix: integer;
    
    begin
      if( reset = '1' ) then

            pquant       <= (others => '0');
            iis_pause     <= '0';
            pause_op_err <= '0';
            pause_dst_err<= '0';
           
      elsif(tx_clk_int='1' and tx_clk_int'event ) then

        if( tx_sof='1' ) then
        
            iis_pause     <= '0';     -- clear at start of frame
            pause_op_err <= '0';
            pause_dst_err<= '0';
            
        end if;

        if( state=S_PAUSE ) then
        
            iis_pause <= '1';

            if( count>=2 ) then  -- pick octets after opcode
            
                ix := 8-((count-2)*8);        -- MSB comes first
                pquant(ix+7 downto ix) <= txd;
                
            elsif( ((count=0) and (txd/=X"00")) or       -- verify 00-01 opcode
                   ((count=1) and (txd/=X"01")) ) then
                   
                   pause_op_err <= '1';
                   
            end if;
            
            if( idst /= X"010000c28001" ) then   -- 01-80-c2-00-00-01 is standard !
            
                   pause_dst_err <= '1';
                   
            end if;
            
        end if;
      end if;
    end process;



      
    -- ----------------------------------------------
    -- Monitor State Machine
    -- ----------------------------------------------

    process( tx_clk_int, reset )
    
        variable hi,lo  : integer;
        variable cnttmp : integer range 0 to 65536;
        variable i      : integer;
        variable flen   : integer;
    
    begin
      if( reset = '1' ) then

            state      <= S_IDLE;
            last_state <= S_IDLE;
            
            count          <= 0;
            frame_err      <= '0';   -- state machine abort indicator
            
      elsif(tx_clk_int='1' and tx_clk_int'event ) then
      
          -- remember last state and increment internal counter
            
          last_state <= state;  

          if(count < 65535) then 
             cnttmp := count+1;  
          else
             cnttmp := count ;  
          end if;
     
          
          -- Abort detection: If enable goes low in middle of frame
          
          if( (state/=S_IDLE) and (state/=S_ABORT) and (state /= S_UTYPE) and tx_dv='0' ) then
          
              state     <= S_ABORT;
          
          else
      
            case state is
          
            when S_ABORT => if( tx_dv='1' ) then
            
                                if( last_tx_dv='0' and data_only='1' ) then  -- only 1 clock cycle inbetween
                                   if (ENABLE_SHIFT16 = 0) then
                                    state <= S_DST;
                                   else
									state <= S_Dword32Aligned;
                                   end if;

                                    cnttmp := 1;
                                    frame_err  <= '0';       
                                    
                                else 
                                    
                                    state <= S_ABORT;    -- wait til tx stops transmission
                                    
                                end if;
                                
                            else
            
                                state <= S_IDLE;
                                
                            end if;
                            
                            frame_err <= '1'; 
          
          
            when S_IDLE  => if( tx_sof='1' ) then       -- we miss the very first !
                                cnttmp      := 1;       -- therefore need to count to 1 immediately
                                frame_err  <= '0';       
            
                                if( data_only='1' ) then     -- no preamble checking ?
                                    
                                  if (ENABLE_SHIFT16 = 0) then
                                   state <= S_DST;
                                  else
                                   state <= S_Dword32Aligned;
                                  end if;
                                    
                                else    
                                                    
                                    state <= S_PRMBL;
                                    
                                end if;

                            else
                            
                                cnttmp      := 0;  -- keep it to zero always 
                                
                            end if;
                            
                            
            when S_PRMBL => if( txd=X"D5" ) then
            
                                state   <= S_DST;
                                cnttmp  := 0;
                            end if;
                            
                                
            when S_Dword32Aligned   
                         => if( count = 1) then
            
                                state  <= S_DST;
                                cnttmp := 0;
                            end if;

            when S_DST   => if( count = 5) then
            
                                state  <= S_SRC;
                                cnttmp := 0;
                            end if;


            when S_SRC   => if( count = 5) then

                                state  <= S_TYPELEN;
                                cnttmp := 0;
                            end if;
                            

          when S_TYPELEN => if( count/=0 ) then    -- second half of 2-octet field
                            
                                cnttmp := 0;
                                
                                flen := conv_integer('0' & ilen(15 downto 8) & txd );  -- need it NOW
                                
                                if( (jumbo_en='1' and (flen <= 9000)) or (flen <= 1500)) then
                                
                                    -- ok normal user frame. check if data or 0 length
                                
                                    if( flen /= 0 ) then
                                
                                        state <= S_DATA;
                                    
                                    else                     -- no data, PAD or finished
                                
                                        if( data_only='1' ) then
                                    
                                            state <= S_IDLE; -- Ok, we are done dont expect anything more
                                            
                                        else
                                        
                                            state <= S_PAD;  -- zero-length frame needs padding
                                
                                        end if;
                            
                                    end if;
                                    
                                else -- not normal frame
                                
                                    if( flen = 16#8808# ) then
                                    
                                        state <= S_PAUSE;
                                        
                                    elsif( flen = 16#8100# ) then
                                    
                                        state <= S_TAG;
                                        
                                    else
                                    
                                        state   <= S_UTYPE; -- S_ABORT;    -- unknown type
                                        
                                    end if;
                                end if;
                            end if;

                             
            when S_PAUSE => if(   count>=3 ) then -- need to overread opcode
            
                                state <= S_PAD;
                                cnttmp := 0;

                            end if;

                             
            when S_TAG  =>  if( count>=1 ) then
                        
                                state <= S_LEN;
                                cnttmp := 0;
                                                                        
                            end if;

            when S_LEN  =>  if( count >= 1) then   -- Length after VLAN TAG

                                cnttmp := 0;

                                flen := conv_integer('0' & ilen(15 downto 8) & txd );  -- need it NOW

                                if ( flen = 16#8100# ) then
                                    
                                        state <= S_TAG;
                                
                                elsif( flen /= 0 ) then
                                
                                    state <= S_DATA;
                                    
                                else                     -- no data, PAD or finished
                                
                                    if( data_only='1' ) then
                                
                                        state <= S_IDLE; -- Ok, we are done dont expect CRC

                                    else
                                    
                                        state <= S_PAD;
                                
                                    end if;
                                end if;
                            end if;
                                                              
            when S_DATA  => if( count >= (conv_integer(ilen)-1)) then                                

                                cnttmp := 0;
            
                                if( data_only='1' ) then      -- no PAD and no CRC ?
                                
                                    state <= S_IDLE; 
                                                
                                elsif( poscnt < 60-1 ) then   -- expect padding ?
                                
                                    state <= S_PAD;
                                    
                                else
                                
                                    state <= S_CRC;
                                 
                                end if;
                             end if;       

                                                                
             when S_PAD    => if( poscnt >= (60-1) ) then
             
                                  state <= S_CRC;
                                  cnttmp := 0;
                                  
                              end if;
                              
                              
             when S_CRC    => if( count >= 3 ) then
             
                                  state <= S_IDLE;
                                  cnttmp := 0;
                                                                    
                              end if;
                              
             when S_UTYPE  => if( tx_dv='0' ) then   -- unknown type... wait for end of frame
                
                                  state <= S_IDLE;
                                  cnttmp := 0;
                                  
                                
                              end if;
                              
             end case;                  
            
           end if;  -- abort                    
                                    
                            
           -- load the counter with the new value                   
      
           count <= cnttmp;
        
        
      end if;
   end process;

end behave;


