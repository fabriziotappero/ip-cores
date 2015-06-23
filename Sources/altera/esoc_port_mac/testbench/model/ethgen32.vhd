-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: ethgen32.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/vhdl/ethernet_model/gen/ethgen32.vhd,v $
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
-- Ethernet Traffic Generator for 32 bit MAC Atlantic client interface
-- Instantiates VERILOG module: ETHGENERATOR (ethgen.vhd)
--
--  Output is presented in 32-bit words with 
--  a last word valid indication (tmod) which has the following meaning:
--  tmod = 1: dout( 7:0) are valid
--  tmod = 2: dout(15:0) are valid
--  tmod = 3: dout(24:0) are valid
--  tmod = 0: dout(31:0) are valid
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------



library ieee ;
use     ieee.std_logic_1164.all ;
use     ieee.std_logic_unsigned.all ;
use     ieee.std_logic_arith.all;

entity ETHGENERATOR32 is 

    generic (  THOLD           : time    := 1 ns; 
               BIG_ENDIAN      : integer := 1;  --0 for false, 1 for true
               ENABLE_SHIFT16  : integer := 0;  --0 for false, 1 for true
               ZERO_LATENCY    : integer := 0   --0 for NON-ZERO read latency, etc.

            );
    port (

      reset    : in std_logic ;     -- active high
      clk      : in std_logic ;
      enable   : in std_logic;

      -- 32-bit data output

      dout     : out std_logic_vector(31 downto 0);
      dval     : out std_logic;
      derror   : out std_logic;
      sop      : out std_logic;   -- pulse with first word
      eop      : out std_logic;   -- pulse with last word (tmod valid)
      tmod     : out std_logic_vector(1 downto 0);  -- last word modulo

        -- Frame Contents definitions

      mac_reverse   : in std_logic;                     -- 1: dst/src are sent MSB first (non-standard)
      dst           : in std_logic_vector(47 downto 0); -- destination address
      src           : in std_logic_vector(47 downto 0); -- source address
      prmble_len    : in integer range 0 to 15;         -- length of preamble
      pquant        : in std_logic_vector(15 downto 0); -- Pause Quanta value
      vlan_ctl      : in std_logic_vector(15 downto 0); -- VLAN control info
      len           : in std_logic_vector(15 downto 0); -- Length of payload
      frmtype       : in std_logic_vector(15 downto 0); -- if non-null: type field instead length
      
      cntstart      : in integer range 0 to 255;  -- payload data counter start (first byte of payload)
      cntstep       : in integer range 0 to 255;  -- payload counter step (2nd byte in paylaod)

      ipg_len       : in integer range 0 to 32768;
      payload_err   : in std_logic;  -- generate payload pattern error (last payload byte is wrong)
      prmbl_err     : in std_logic;  -- Send corrupt SFD in otherwise correct preamble
      crc_err       : in std_logic;
      vlan_en       : in std_logic;
      stack_vlan    : in std_logic;
      pause_gen     : in std_logic;
      pad_en        : in std_logic;
      phy_err       : in std_logic;  -- Generate the well known ERROR control character
      end_err       : in std_logic;  -- Send corrupt TERMINATE character (wrong code)
               
      data_only     : in std_logic;  -- if set omits preamble, padding, CRC
      start         : in  std_logic;
      done          : out std_logic );
      
end ETHGENERATOR32 ;

architecture behave of ETHGENERATOR32 is

        -- underlying GMII generator

        component ethgenerator 

                generic (  
                
                
                        THOLD  : time) ;

                port (

                        reset           : in std_logic ;                        -- active high
                        rx_clk          : in std_logic ;
                        enable          : in std_logic ;
			rxd             : out std_logic_vector(7 downto 0);
                        rx_dv           : out std_logic;
                        rx_er           : out std_logic;                
                        sop             : out std_logic;                        -- pulse with first character
                        eop             : out std_logic;                        -- pulse with last  character
                        mac_reverse     : in std_logic;                         -- 1: dst/src are sent MSB first
                        dst             : in std_logic_vector(47 downto 0);     -- destination address
                        src             : in std_logic_vector(47 downto 0);     -- source address     
                        prmble_len      : in integer range 0 to 15;             -- length of preamble
                        pquant          : in std_logic_vector(15 downto 0);     -- Pause Quanta value
                        vlan_ctl        : in std_logic_vector(15 downto 0);     -- VLAN control info
                        len             : in std_logic_vector(15 downto 0);     -- Length of payload
                        frmtype         : in std_logic_vector(15 downto 0);     -- if non-null: type field instead length      
                        cntstart        : in integer range 0 to 255;            -- payload data counter start (first byte of payload)
                        cntstep         : in integer range 0 to 255;            -- payload counter step (2nd byte in paylaod)
                        ipg_len         : in integer range 0 to 32768;          -- inter packet gap (delay after CRC)         
                        payload_err     : in std_logic;                         -- generate payload pattern error (last payload byte is wrong)
                        prmbl_err       : in std_logic;
                        crc_err         : in std_logic;
                        vlan_en         : in std_logic;
                        stack_vlan      : in std_logic;
                        pause_gen       : in std_logic;
                        wrong_pause_op  : in std_logic ;                        -- Generate Pause Frame with Wrong Opcode       
                        wrong_pause_lgth: in std_logic ;                        -- Generate Pause Frame with Wrong Opcode       
                        pad_en          : in std_logic;
                        phy_err         : in std_logic;
                        end_err         : in std_logic;                         -- keep rx_dv high one cycle after end of frame
                        magic           : in std_logic;                             
                        data_only       : in std_logic;                         -- if set omits preamble, padding, CRC            
                        start           : in  std_logic;
                        done            : out std_logic );
      
        end component ;

        component  timing_adapter_32  
            port 
            ( 
                -- Interface: clk
                clk                :   IN      STD_LOGIC;
                reset              :   IN      STD_LOGIC;
       
                -- Interface: in
                in_ready           :   OUT     STD_LOGIC;
                in_valid           :   IN      STD_LOGIC;
                in_data            :   IN      STD_LOGIC_VECTOR (31 DOWNTO 0);
                in_startofpacket   :   IN      STD_LOGIC;
                in_endofpacket     :   IN      STD_LOGIC;
                in_empty           :   IN      STD_LOGIC_VECTOR (1 DOWNTO 0);
                in_error           :   IN      STD_LOGIC;
                -- Interface: in
                out_ready          :   IN      STD_LOGIC;
                out_valid          :   OUT     STD_LOGIC;
                out_data           :   OUT     STD_LOGIC_VECTOR (31 DOWNTO 0);
                out_startofpacket  :   OUT     STD_LOGIC;
                out_endofpacket    :   OUT     STD_LOGIC;
                out_empty          :   OUT     STD_LOGIC_VECTOR (1 DOWNTO 0);
                out_error          :   OUT     STD_LOGIC
            ); 
        end component;


    -- internal GMII from generator
    
    signal rxd            : std_logic_vector(7 downto 0); 
    signal rx_dv          : std_logic;
    signal rx_er          : std_logic;
    
    signal sop_gen        : std_logic;
    signal eop_gen        : std_logic;
    
    signal start_gen      : std_logic;
    signal done_gen       : std_logic;

    -- captured signals from generator (lasting 1 word clock cycle)
    
    signal sop_int        : std_logic := '0';  -- captured sop_gen
    signal sop_int_d      : std_logic := '0';  -- captured sop_gen
    signal eop_int        : std_logic := '0';  -- captured eop_gen
    signal eop_i          : std_logic := '0';  -- captured eop_gen
    signal rx_er_int      : std_logic;  -- captured rx_er

    -- external signals
    
    signal sop_ex         : std_logic;
    signal eop_ex         : std_logic;

    -- captured command signals 
    
    signal ipg_len_i      : integer range 0 to 32768; 

    -- internal

    signal data32         : std_logic_vector(31 downto 0);

    signal clkcnt         : integer range 0 to 7 ;
    signal bytecnt_eop    : integer range 0 to 3 ;   -- captured count for last word
    
    signal count          : integer;
    
    type  stm_typ is (S_IDLE, S_DATA, S_IPG, S_IPG0);
    
    signal state          : stm_typ;
    signal last_state     : stm_typ;
    
    signal clk_d          : std_logic;
    signal fast_clk       : std_logic;
    signal fast_clk_gate  : std_logic;
    signal fast_clk_cnt   : integer;
    signal bytecnt        : integer range 0 to 3 ;
    signal tx_clk         : std_logic;

    signal dout_reg       : std_logic_vector(31 downto 0);
    signal dval_reg       : std_logic;
    signal derror_reg     : std_logic;
    signal tmod_reg       : std_logic_vector(1 downto 0);  -- last word modulo
    signal done_reg       : std_logic;

    signal dout_temp      : std_logic_vector(31 downto 0);
    signal dval_temp      : std_logic;
    signal derror_temp    : std_logic;
    signal sop_temp       : std_logic;   -- pulse with first word
    signal eop_temp       : std_logic;   -- pulse with last word (tmod valid)
    signal tmod_temp      : std_logic_vector(1 downto 0);  -- last word modulo
    signal done_temp      : std_logic;

   	signal enable_int     : std_logic;

begin


 -- ---------------------------------------
 -- Generate internal fast clock synchronized to external input clock
 -- ---------------------------------------

   process
   begin
        fast_clk <= '0' after 0.1 ns;
        wait for 0.4 ns;
        fast_clk <= '1' after 0.1 ns;
        wait for 0.4 ns;
   end process;
   
   process( fast_clk, reset )
   begin
   
        if( reset='1' ) then
        
                fast_clk_gate <= '0';
                clk_d         <= '0';
                
        elsif( fast_clk'event and fast_clk='0' ) then   -- work on neg edge
        
                clk_d <= clk;
                
                if( (rx_dv='0' or done_gen='1') and enable_int='1') then -- generator not running, enable it permanently
                        
                        fast_clk_gate <= '1';
                        
                elsif((clk_d='0' and clk='1') and enable_int='1') then  -- wait for rising edge
                
                        fast_clk_gate <= '1';
                
                elsif( bytecnt<3 ) then                -- after 4 octets have been processed, wait for next clk rising edge

                        fast_clk_gate <= '1';
                        
                else
                
                        fast_clk_gate <= '0';
                        
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

    -- capture generator signals with word clock domain handshake
    -- ----------------------------------------------------------

    process( tx_clk, reset )
    begin
        if( reset='1' ) then
        
                eop_int  <= '0';
                sop_int  <= '0';
              rx_er_int  <= '0';
            
        elsif( tx_clk'event and tx_clk='1' ) then 

                if( sop_gen = '1' ) then
                        
                        sop_int <= '1';
                        
                elsif( sop_ex='1' ) then
                        
                        sop_int <= '0';
                        
                end if;

                if( eop_gen = '1' ) then
                
                        eop_int <= '1';
                
                elsif( eop_ex='1') then
                
                        eop_int <= '0';
                
                end if;

                if( rx_er='1' ) then
            
                        rx_er_int <= '1' ;
                
                elsif( eop_ex='1') then
                
                        rx_er_int <= '0';
                        
                end if;
                                        
        end if;
    end process;

    -- word clock, external signal generation
    -- --------------------------------------

    --sop <= sop_ex after THOLD;
    --eop <= eop_ex after THOLD;

    process( clk, reset )
    begin
        if( reset='1' ) then
        
                eop_ex      <= '0';
                sop_ex      <= '0';
                dval_reg    <= '0';
                dout_reg    <= (others => '0');
                tmod_reg    <= (others => '0');
                derror_reg  <= '0';
                start_gen   <= '0';
                ipg_len_i   <= 0;
                done_reg    <= '0';
            
        elsif( clk'event and clk='1' ) then 
    
                eop_ex      <= eop_int;
                sop_ex      <= sop_int;
                dout_reg    <= data32 after THOLD;
                derror_reg  <= rx_er_int after THOLD;
                
                if( done_gen='1' and ((state=S_IDLE or state=S_IPG0) or
                                      (state=S_DATA and eop_int='1' and ipg_len_i<4 and start='1')) ) then  -- nextstate=S_IPG0
            
                        start_gen <= start;
                else
                        start_gen <= '0';
                end if;

                if( (state = S_DATA or state=S_IPG0 or sop_int='1') and enable_int='1') then
        
                        dval_reg <= '1' after THOLD;
                else
                        dval_reg <= '0' after THOLD;        
                end if;

                -- store input variables that could change until end of frame
                
                if( sop_int='1' ) then

                        ipg_len_i   <= ipg_len;
                
                end if;
                
                -- output last word modulo during eop
                
                if( eop_int='1' ) then
                
                        tmod_reg <= conv_std_logic_vector(bytecnt_eop,2) after THOLD;
                        
                elsif( eop_ex='0' ) then
                        
                        tmod_reg <= (others => '0') after THOLD;
                        
                end if;
                
                done_reg <= done_gen;
            
        end if;
    end process;


   -- ------------------------
   -- capture GMII data bytes
   -- ------------------------
   
    process( tx_clk, reset )   
    begin
        if( reset='1' ) then
        
            data32      <= (others => '0');
            bytecnt_eop <= 0;
            bytecnt     <= 0;
            
        elsif(tx_clk='1' and tx_clk'event) then
    
            if(eop_gen = '1' ) then
            
                bytecnt_eop <= (bytecnt+2) mod 4;     -- remember where the last byte was
                
            end if;

            if( sop_gen='1' and rx_dv='1') then                 -- first byte
                
                if(ENABLE_SHIFT16 = 1 ) then

                        data32  <= rxd(7 downto 0) & X"000000";
                        bytecnt <= 2;

                elsif(ENABLE_SHIFT16 = 0) then
        
                    data32  <= rxd(7 downto 0) & X"000000";
                    bytecnt <= 0;
                
                end if;
                
            elsif( rx_dv='1' ) then                             -- during frame
                
                    data32(31 downto 0) <= rxd(7 downto 0) & data32(31 downto 8);  
            
                    bytecnt <= (bytecnt+1) mod 4;
                                
            elsif( rx_dv='0' and bytecnt < 3 and eop_int='1') then     -- shift last bytes to LSBs as necessary
                
                    data32(31 downto 0) <= X"00" & data32(31 downto 8);
                    bytecnt <= (bytecnt+1) mod 4;

            elsif( rx_dv='0' and eop_int='0') then  -- stopped and after eop => reset
                
                    bytecnt <= 0;
                    
            end if;
                

        end if;
    end process;


   -- ------------------------
   -- state machine
   -- ------------------------
   
    process( clk, reset )   -- synchronize external to xgmii
    begin
        if( reset='1' ) then
        
            state          <= S_IDLE;
            count          <= 8;
            
        elsif( clk'event and clk='1' ) then 

                if(state = S_IPG ) then
                
                        count <= count +4;
        
                else
                
                        count <= 8;
                        
                end if;
                
            case state is
          
                when S_IDLE  => if( done_gen = '0' ) then       -- has the generator been triggered ?
                
                                        state <= S_DATA;
                                
                                else
                             
                                        state <= S_IDLE;
                             
                                end if;
                                
                when S_DATA  => if( eop_int='0' ) then
                        
                                        state <= S_DATA;
                                
                                else
                                
                                        if( ipg_len_i < 4 and start='1') then
                                        
                                                state <= S_IPG0;        -- no IPG
                                                --state <= S_IDLE;   
                                        
                                        elsif( ipg_len_i < 8 ) then
                                        
                                                state <= S_IDLE;
                                        
                                        else
                                        
                                                state <= S_IPG;
                                
                                        end if;
                             
                                end if;
                        
                when S_IPG   => if( count < ipg_len_i ) then
                        
                                        state <= S_IPG;
                                
                                else
                             
                                        state <= S_IDLE;                                
                             
                                end if;
                           
                when S_IPG0  => state <= S_DATA;
                                           
                                
                when others => state <= S_IDLE;
                                
            end case;

        end if;
    end process;



-- endian adapter from Little endian to Big endian
-- 
--       dout     : out std_logic_vector(31 downto 0);
--       dval     : out std_logic;
--       derror   : out std_logic;
--       sop      : out std_logic;   -- pulse with first word
--       eop      : out std_logic;   -- pulse with last word (tmod valid)
--       tmod     : out std_logic_vector(1 downto 0);  -- last word modulo

 process (clk, reset)
  begin 
   if( reset = '1' ) then
       dout_temp  <= (others => '0'); 
       dval_temp  <= '0'; 
       derror_temp<= '0'; 
       sop_temp   <= '0'; 
       eop_temp   <= '0'; 
       tmod_temp  <= (others => '0'); 
       done_temp  <= '0';    
   elsif( clk'event and clk='1' ) then
     if (BIG_ENDIAN = 1) then

          dout_temp  <= (dout_reg(7 downto 0) & dout_reg(15 downto 8) & dout_reg(23 downto 16) & dout_reg(31 downto 24)) after THOLD; 
          dval_temp  <= dval_reg after THOLD ; 
          derror_temp<= derror_reg after THOLD; 
          sop_temp   <= sop_ex after THOLD; 
          eop_temp   <= eop_ex after THOLD; 
          done_temp  <= done_reg after THOLD;    

          case (tmod_reg) is 
            when "00"   => tmod_temp <= "00";
            when "01"   => tmod_temp <= "11";
            when "10"   => tmod_temp <= "10";
            when "11"   => tmod_temp <= "01";
            when others => tmod_temp <= "00";     
          end case;          
     else
          dout_temp           <= dout_reg after THOLD; 
          dval_temp           <= dval_reg after THOLD; 
          derror_temp         <= derror_reg after THOLD; 
          sop_temp            <= sop_ex after THOLD; 
          eop_temp            <= eop_ex after THOLD; 
          tmod_temp           <= tmod_reg after THOLD; 
          done_temp           <= done_reg after THOLD;    
     end if;
   end if;      

  end process;


   -- timing adapter
   GMII_ADAPTER_BLOCK: if ( ZERO_LATENCY=1) generate  
   timing_adapter: timing_adapter_32
         
       port map
       ( 
           -- Interface: clk
           clk               => clk, 
           reset             => reset,
  
           -- Interface: in
           in_ready          => enable_int,
           in_valid          => dval_temp,
           in_data           => dout_temp,
           in_startofpacket  => sop_temp,
           in_endofpacket    => eop_temp,
           in_empty          => tmod_temp,
           in_error          => derror_temp,
           -- Interface: in
           out_ready         => enable,
           out_valid         => dval,
           out_data          => dout,
           out_startofpacket => sop,
           out_endofpacket   => eop,
           out_empty         => tmod,
           out_error         => derror
       ); 

       done <= done_temp;
   end generate;


   NO_ADAPTER_BLOCK: if ( ZERO_LATENCY /= 1) generate  
       enable_int <= enable;  
       dval       <= dval_temp;
       dout       <= dout_temp;
       sop        <= sop_temp;
       eop        <= eop_temp;
       tmod       <= tmod_temp;
       derror     <= derror_temp;
       done       <= done_temp;
       
   end generate;

                                     

   -- Generator
   -- ---------
   
   GEN1G: ETHGENERATOR 
   
   generic map (  THOLD => 0.1 ns )
   
   port map (
   
      reset   => reset,         -- active high

        -- GMII receive interface: To be connected to MAC RX

      rx_clk  =>   tx_clk, 
      enable  =>   '1',
      rxd     =>   rxd,    
      rx_dv   =>   rx_dv,
      rx_er   =>   rx_er,
      
        -- FIFO testing 
        
      sop    => sop_gen,
      eop    => eop_gen,
      
        -- Frame Contents definitions

      mac_reverse  => mac_reverse,
      dst          => dst,        
      src          => src,        
                                 
      prmble_len   => prmble_len, 
      pquant       => pquant,     
      vlan_ctl     => vlan_ctl,   
      len          => len,        
      frmtype         => frmtype,       
                                 
      cntstart      =>cntstart,   
      cntstep       =>cntstep,   
      ipg_len       => 4,

       -- Control   
       
      wrong_pause_op => '0' ,
      wrong_pause_lgth => '0' ,
      payload_err  =>  payload_err,  
      prmbl_err    =>  prmbl_err,  
      crc_err      =>  crc_err,    
      vlan_en      =>  vlan_en, 
      stack_vlan   =>  stack_vlan, 
      pause_gen    =>  pause_gen,  
      pad_en       =>  pad_en,     
      phy_err      =>  phy_err,    
      end_err      =>  end_err, 
      magic        => '0' ,
      
      data_only    =>  data_only,    
                               
      start        =>  start_gen,      
      done         =>  done_gen  );

end behave;


