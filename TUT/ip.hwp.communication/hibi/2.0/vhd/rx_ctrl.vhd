-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- File        : rx_control_addr_width_is_1.vhdl
-- Description : Control of the receiver for only one cycle long addresses
--               Includes two state machines: one for configuration
--               one for regular data. No distinction made between data and messages.
--
--               Needs one_place signal from fifo. Probably this could be
--               avoided by having two addr registers. One for decoding and one
--               for storing. Store reg  would be used only fifo gets full
--
-- Author       : Erno Salminen
-- e-mail       : erno.salminen@tut.fi
-- Date         : 16.12.2002
-- Project      
-- Design       : Do not use term design when you mean system
-- Modified
--
-- 16.12.02     The earlier versions did not fully work when FIFO got full.
--              This is somewhat better.
-- 01.04.03     New state Two_Data_Full_New_Addr added
-- 13.04.03     message stuff removed, es
-- 16.05.03     Config receiving added
-- 24.07.03     Target_full logic changed, cleaning
-- 07.02.05     ES new generics
-- 04.03.05     ES new generics id_width_g and cfg_addr_width_g
-- 15.12.05     ES Commented out all (others => rst_valu_arra(dbg_level)
--                 => registers keep their old values
--                 => 16% reduction in area for 32b rx_ctrl (ST 0.13um)
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.hibiv2_pkg.all;

entity rx_control is
  generic (
    data_width_g     :    integer := 32;
    addr_width_g     :    integer := 25;  -- in bits!
    id_width_g       :    integer := 5;   -- 04.03.2005
    cfg_addr_width_g :    integer := 16;  -- in bits, smaller than addr_w,  04.03.2005
    cfg_re_g         :    integer := 1;   -- 07.02.05
    cfg_we_g         :    integer := 1    -- 07.02.05
    );
  port (
    clk              : in std_logic;
    rst_n            : in std_logic;

    av_in            : in  std_logic;
    data_in          : in  std_logic_vector ( data_width_g-1 downto 0);
    comm_in          : in  std_logic_vector ( comm_width_c-1 downto 0);
    full_in          : in  std_logic;
    one_p_in         : in  std_logic;
    cfg_rd_rdy_in    : in  std_logic;   --16.05

    addr_match_in   : in  std_logic;
    decode_addr_out : out std_logic_vector ( addr_width_g -1 downto 0);
    decode_comm_out : out std_logic_vector ( comm_width_c-1 downto 0);
    decode_en_out   : out std_logic;

    data_out         : out std_logic_vector ( data_width_g-1 downto 0);
    comm_out         : out std_logic_vector ( comm_width_c-1 downto 0);
    av_out           : out std_logic;
    we_out           : out std_logic;
    full_out         : out std_logic;

    cfg_we_out       : out std_logic;
    cfg_re_out       : out std_logic;
    cfg_addr_out     : out std_logic_vector ( cfg_addr_width_g -1 downto 0);
    cfg_data_out     : out std_logic_vector ( data_width_g -1 downto 0);
    cfg_ret_addr_out : out std_logic_vector ( addr_width_g -1 downto 0)
    );

end rx_control;


architecture rtl of rx_control is

  -- Selects if debug prints are used (1-3) or not ('0')
  constant dbg_level : integer range 0 to 3 := 0;  -- 0= no debug, use 0 for synthesis

  -- Registers may be reset to 'Z' to 'X' so that reset state is clearly
  -- distinguished from active state. Using dbg_level+rst_value_arr array, the rst value may
  -- be easily set to '0' for synthesis.
  -- 16.12.05 try if "don't care" could reduce area
  constant rst_value_arr : std_logic_vector ( 6 downto 0) := 'X' & 'Z' & 'X' & 'Z' & 'X' & 'Z' & '0';



  -- Controller has two state machines
  --  fsm1 receives redular data (and messages) and requests
  --  fsm2 receives configuration data and requests
  -- Fsm2 is simpler because confmemory cannot be full like fifo 
  type state_type is (Wait_Addr,
                      One_Addr, One_Data, One_Data_New_Addr, One_Addr_One_Data,
                      Two_Data, Two_Data_Full, Two_Data_Full_New_Addr,
                      Reconfiguration);
  signal curr_state_r, next_state       : state_type;

  -- attribute enum_encoding : string;
  -- attribute enum_encoding of state_type: type is "000000001 000000010 000000100 000001000 000010000 000100000 001000000 010000000 100000000";


  type conf_state_type is (Conf_Idle, Conf_One_Addr, Conf_Addr_Data);
  -- attribute enum_encoding : string;
  -- attribute enum_encoding of conf_state_type: type is "001 010 100";


  signal cfg_curr_state_r, cfg_next_state : conf_state_type;

  -- Registers for receiving data
  signal enable_decode_r : std_logic;   -- 04.08.2004
  signal addr_r          : std_logic_vector ( addr_width_g-1 downto 0);
  signal data_r          : std_logic_vector ( data_width_g-1 downto 0);
  signal data_to_fifo_r  : std_logic_vector ( data_width_g-1 downto 0);
  signal comm_to_fifo_r  : std_logic_vector ( comm_width_c-1 downto 0);
  signal comm_a_r        : std_logic_vector ( comm_width_c-1 downto 0);
  signal comm_d_r        : std_logic_vector ( comm_width_c-1 downto 0);
  signal av_to_fifo_r    : std_logic;
  signal we_to_fifo_r    : std_logic;

  -- Registers for receiving configuration
  signal cfg_write_enable_r : std_logic;
  signal cfg_read_enable_r  : std_logic;
  signal cfg_new_value_r    : std_logic_vector ( data_width_g -1 downto 0);
  -- cfg osoitteesta tarvitaan id osoitteen vertailua varten ja cfg_addr_w
  -- muistia varten. Addr_w lienee kuitenkin leveämpi kuin id_w + cfg_a_w
  -- yhteensä 04.03.05
  signal cfg_id_r           : std_logic_vector ( id_width_g -1 downto 0);  -- 04.03.05
  signal cfg_addr_r         : std_logic_vector ( cfg_addr_width_g -1 downto 0);  -- 04.03.05
  signal cfg_return_addr_r  : std_logic_vector ( addr_width_g -1 downto 0);
  signal cfg_comm_r         : std_logic_vector ( comm_width_c -1 downto 0);  -- 15.05

begin



  -- Continuous assignments             ---------------------------------------------------
  decode_en_out <= enable_decode_r;     -- 04.08.2004
  data_out      <= data_to_fifo_r;
  comm_out      <= comm_to_fifo_r;
  av_out        <= av_to_fifo_r;
  we_out        <= we_to_fifo_r;

  cfg_we_out       <= cfg_write_enable_r;
  cfg_re_out       <= cfg_read_enable_r;
  cfg_data_out     <= cfg_new_value_r;
  cfg_addr_out     <= cfg_addr_r;       -- 04.03.05
  cfg_ret_addr_out <= cfg_return_addr_r;


  -----------------------------------------------------------------------------
  -- PROCESSES ----------------------------------------------------------------
  -----------------------------------------------------------------------------

  -- 04.03.05
  assert cfg_addr_width_g < (addr_width_g+1) report "Cfg_addr_w must be smaller than addr_w" severity ERROR;
  
  -- 1) PROC
  -- Synchronous process for state transitions
  Sync : process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then
      curr_state_r     <= Wait_Addr;
      cfg_curr_state_r <= Conf_Idle;
    elsif clk'event and clk = '1' then
      curr_state_r     <= next_state;
      cfg_curr_state_r <= cfg_next_state;
    end if;
  end process;

  


  
  -- 2) PROC (ASYNC)
  -- Selects which address register is fed to addr decoder 
  Select_Decoded_Addr : process (addr_r, comm_a_r, -- cfg_addr_r,
                                 cfg_comm_r, cfg_curr_state_r, cfg_id_r)
  begin  -- process Select_Decoded_Addr
    assert addr_width_g < data_width_g+1 report "addr_width_g must be smaller than data_width_g" severity FAILURE;

    -- modified 2007/04/17
    if (cfg_re_g=1 
	or cfg_we_g=1) 
	and cfg_curr_state_r = Conf_One_Addr then

      -- Conf addr received
      decode_addr_out                                                     <= (others => '0');  --04.03.05
      decode_addr_out (addr_width_g -1 downto addr_width_g - id_width_g ) <= cfg_id_r;  -- 04.03.05;
      decode_comm_out                                                     <= cfg_comm_r;
    else
      -- Regular addr received
      decode_addr_out                                                     <= addr_r;
      decode_comm_out                                                     <= comm_a_r;
    end if;  --cfg_curr_state_r
  end process Select_Decoded_Addr;


  -- 3) PROC (ASYNC)
  -- Assign output full_out when needed
  ControlTargetFull : process (full_in, one_p_in,
                               addr_match_in, comm_in,
                               curr_state_r)
  begin  -- process ControlTargetFull

    -- New version 24.07.03 es
    if comm_in /= idle_c then
      -- Bus is reserved = some agent is transmitting

      
      if full_in = '1' then
        -- Fifo full
        
        if curr_state_r = Wait_Addr
          or curr_state_r = One_Data
          or curr_state_r = Two_Data_Full
        then
          -- Some other wrapper is the current receiver
          full_out <=  '0';
          
        elsif curr_state_r = One_Addr
          or curr_state_r = One_Data_New_Addr
          or curr_state_r = Two_Data_Full_New_Addr
        then
          -- Addr received and fifo is full
          -- Assert target_full only if this wrapper is the receiver (=addr matches)
          full_out <= addr_match_in;
          
        else
          -- This wrapper is receiving data and fifo is full
          full_out <= '1';
        end if;


      else
        if one_p_in = '1' then
          -- In some case, there has to be at least two fifo places empty

          
          if curr_state_r = One_Addr
            or curr_state_r = One_Data_New_Addr
            or curr_state_r = Two_Data_Full_New_Addr
          then 
            -- Addr received and only one place left in the fifo
            -- Assert target_full only if this wrapper is the receiver (=addr matches)
            full_out <=  addr_match_in;
            -- This ensures that fifo=1 cannot happen in these states
            -- (FSM stays only one cycle in this states)

          else
            -- In other FSM states, no need to do anything, one place is enough
            full_out <= '0';
          end if;                       -- curr_state_r
          
        elsif curr_state_r = Two_Data_Full_New_Addr then
          -- elsif added 2009-07-28, JN
          -- Before this fix, in cases where hibi frequency was lower than
          -- IP frequency, one_p_in went up and down again within one clk cycle
          -- causing full_out to be 0 (the else branch below). This made sender
          -- continue transferring even though we didn't have enough space to
          -- store the data. This lead to address not being written to the fifo
          -- at all. Now we reject the transfer until we have succesfully
          -- written old data from data_r to the fifo.
          full_out <= addr_match_in;
          
        else
          -- At least two places in the fifo
          full_out <= '0';      
        end if;                         -- one_p_in
      end if;                           -- full_in

    else
      -- Bus is idle
      full_out <= '0';      
    end if;                             -- comm_in

    
  end process ControlTargetFull;



  
  
  -- 4) PROC (ASYNC)
  -- Defines the next state of state machine for regular data
  -- 
  DefNextState : process (curr_state_r, addr_match_in,
                          av_in, comm_in,
                          full_in, one_p_in)
  begin  -- process DefNextState

    case curr_state_r is
      
      when  Wait_Addr =>       
        if comm_in /= idle_c and av_in = '1' then
          -- There is an addr on the bus

          if comm_in = w_cfg_c or comm_in = r_cfg_c then  --15.05
            -- New conf addr, handled elsewhere (see below)
            next_state <= curr_state_r; --Wait_Addr;
          else
            -- New data transfer begins
            next_state <= One_Addr;
          end if;                       --comm          
          
        else
          next_state <= Wait_Addr;
        end if;                         -- comm_in&av_in


        
      when One_Addr =>

        if comm_in /= idle_c
          and addr_match_in = '1'
          and full_in = '0'
          and one_p_in = '0'   -- 1_place added 23.07.03
        then
          -- Matching addr read on prev cycle.
          -- Corresponding data is read to register on this cycle
          -- If next_state will be 1a_1d, it is propably necessary to check 1_place_left
          -- ( to ensure that it is not possible to have fulll=1 in that state
          -- => addr register is freed to be used with next addr on the bus)
          next_state <= One_Addr_One_Data;

          -- 24.07 : If it is ensured that addr fits into fifo, it would be
          -- possible to have next_state= one_data.
          -- However, in other cases that state reached only when transfer has
          -- ended. Therefore, it seems safer to go state 1a_1d (if there are
          -- at least two places int he fifo) to keep state
          -- one_data untouched.

        else
          -- Addr does not match or no data after addr
          next_state <= Wait_Addr;
        end if;                         -- comm_in&full_in


        
      when One_Data =>
        if full_in = '1' then
          -- Data does not fit into fifo
          
          if av_in = '1' then
            -- New addr on the bus
              if comm_in = w_cfg_c or comm_in = r_cfg_c then  --15.05
                -- New conf addr, handled elsewhere (see below)
                next_state <= curr_state_r;
              else
                -- New data transfer begins
                next_state <= One_Data_New_Addr;
              end if;                       -- comm_in          

          else
            -- Data that is currently on the bus has to be retransferred by the
            -- tx_ctrl
            next_state <= One_Data;
          end if;                       -- AV

          
        else
          -- Data goes into fifo i.e. fifo not full          
          if av_in = '1'  then
            
            if comm_in = w_cfg_c or comm_in = r_cfg_c then  --15.05
              -- New conf addr, handled elsewhere (see below)
              next_state <= curr_state_r;
            else
              -- New data transfer begins
              next_state <= One_Addr;   -- ES 22.7.2003
            end if;                     -- comm_in          

          else
            next_state <= Wait_Addr;
          end if;                       -- AV
         end if;                        -- full_in



      when One_Addr_One_Data =>

        if full_in = '1' then
          -- 23.07.03 This branch should be impossible to reach
          -- Otherwise the addr register stays reserved and it is not possible
          -- to store next addr on the bus anywhere
          next_state <= One_Addr_One_Data;
          assert false report "Rec-1d1a Fifo full. Illegal condition, possible deadlock!" severity warning;
          
        else
          -- Addr goes to fifo
          
          if comm_in = idle_c then
            -- Tx ends after first data
            next_state <= One_Data;
          else
            if av_in = '1' then
              -- New addr on the bus
              
              if comm_in = w_cfg_c or comm_in = r_cfg_c then  --15.05
                -- New conf addr, handled elsewhere (see below)                
                next_state <= One_Data;
              else
                -- New data transfer begins
                next_state <= One_Data_New_Addr;
              end if;                       --comm          

            else
              -- New data
              next_state <= Two_Data;
            end if;                     -- AV
          end if;                       -- comm_in
        end if;                         -- full_in


        
      when One_Data_New_Addr =>
        if full_in = '1' then
          -- Fifof full, do not accept any new data
          -- Store addr so that target_full can be asserted if addr matches
          next_state <= One_Data;
          
        else
          -- Data goes into fifo
          
          if one_p_in = '1' then
            -- Only data fits into fifo, do not accept addr or
            -- data following it
            next_state <= Wait_Addr;

          elsif comm_in = idle_c or addr_match_in = '0' then
            -- Addr does not match or transfer ends after the addr
            next_state <= Wait_Addr;
            
          else
            
            if av_in = '1' then  
              -- Addr 
              
              if comm_in = w_cfg_c or comm_in = r_cfg_c then --15.05
                -- New conf addr, handled elsewhere (see below)
                next_state <= Wait_Addr;
              else
                -- New data transfer begins
                next_state <= One_Addr;
              end if;                       --comm          

            else
              -- New data
              next_state <= One_Addr_One_Data;
            end if;  -- AV
          end if;  -- comm_in
        end if;  -- full_in


        
      when Two_Data =>
        if full_in = '1' then
          next_state <= Two_Data_Full; 
        else
          -- Another data goes into fifo
          
          if comm_in = idle_c then
            -- Transfer ends
            next_state <= One_Data;

          else
            if av_in = '1' then
                            
              if comm_in = w_cfg_c or comm_in = r_cfg_c then  --15.05
                -- New conf addr, handled elsewhere (see below)
                next_state <= One_Data;
              else
                -- New data transfer begins
                next_state <= One_Data_New_Addr;
              end if;                       --comm          

            else
              -- More data
              next_state <= Two_Data;
            end if;                     -- AV
          end if;                       -- comm_in
        end if;                         -- full_in

        

      when Two_Data_Full =>
        -- updated 01.04.03
        if full_in = '1' then
          -- No data can be written to fifo
          
          if av_in = '1' then
            -- New addr = new transfer
            
            if comm_in = w_cfg_c or comm_in = r_cfg_c then  --15.05
              -- New conf addr, handled elsewhere (see below)
              next_state <= Two_Data_Full;
            else
              -- New data transger begins
              -- Addr is stored and compared so that target_full can be
              -- asserted if needed
              next_state <= Two_Data_Full_New_Addr;
            end if;                       -- comm_in          

          else
            -- Data that is currently on the bus has to be retransferred by the
            -- tx_ctrl
            next_state <= Two_Data_Full;
          end if;                       -- AV
          
        else
          -- Another data goes to fifo

          if av_in = '1' then
            -- New addr = new transfer
            if comm_in = w_cfg_c or comm_in = r_cfg_c then  --15.05
              -- New conf addr, handled elsewhere (see below)
              next_state <= curr_state_r;
            else
              -- Uusi siirto alkaa
              next_state <= One_Data_New_Addr;
            end if;  -- comm_in          

          else
            -- Data that is currently on the bus has to be retransferred by the
            -- tx_ctrl
            next_state <= One_Data;
          end if;                       -- AV
        end if;                         -- full_in


        
      when Two_Data_Full_New_Addr =>
        -- New state 01.04.03
        
        if full_in = '1' then
          -- Fifo is full, do not accept addr regardless if it matches or not
          next_state <= Two_Data_Full;
        else

          -- another data went into fifo
          -- (Earlier here were all kinds of if clauses, but they all led to
          -- state One_Data, so they are removed. In Two_Data_Full_New_Addr
          -- nothing can be read, so there is no other state to go.)
          next_state <= One_Data;

        end if;         -- full_in


      when others =>
        assert false report "Illegal curr state in rx fsm" severity warning;
        next_state <= Wait_Addr;        --12.-4.03
    end case;

    
  end process DefNextState;




  -- 5) PROC
  ControlRegisters : process (clk, rst_n)
  begin  -- process ControlRegisters
    if rst_n = '0' then                 -- asynchronous reset (active low)
      addr_r          <= (others => rst_value_arr (dbg_level* 1));
      data_r          <= (others => rst_value_arr (dbg_level* 1));
      data_to_fifo_r  <= (others => rst_value_arr (dbg_level* 1));
      comm_to_fifo_r  <= (others => rst_value_arr (dbg_level* 1));
      av_to_fifo_r    <= '0';
      comm_a_r        <= (others => rst_value_arr (dbg_level* 1));
      comm_d_r        <= (others => rst_value_arr (dbg_level* 1));
      we_to_fifo_r    <= '0';
      enable_decode_r <= '1';


    elsif clk'event and clk = '1' then          -- rising clock edge

      enable_decode_r <= '1';
      we_to_fifo_r    <= '0';


      case curr_state_r is


        when Wait_Addr              =>
          av_to_fifo_r   <= '0';
          we_to_fifo_r   <= '0';

          -- 15.05 es
          if next_state = One_Addr then
            addr_r   <= data_in ( addr_width_g -1 downto 0);  -- 31.01.05
            comm_a_r <= comm_in;
          end if;


        when One_Addr                 =>
          if next_state = Wait_Addr then
            av_to_fifo_r   <= '0';
            we_to_fifo_r   <= '0';

          else
            -- i.e. next_state = One_Addr_One_Data
            data_r                                  <= data_in;
            data_to_fifo_r                          <= (others => '0');  -- 31.01.05 jos osoite kapea, nollataan ylimmät bitit
            data_to_fifo_r(addr_width_g-1 downto 0) <= addr_r;  --osoite fifolle
            comm_to_fifo_r                          <= comm_a_r;
            av_to_fifo_r                            <= '1';
            comm_d_r                                <= comm_in;
            we_to_fifo_r                            <= '1';
          end if;

        when One_Data                 =>
          if next_state = One_Data then
            we_to_fifo_r   <= '1';

          elsif next_state = One_Data_New_Addr then
            -- 22.7.2003 : Registers going to fifo cannot reset to zero
            -- because fifo is full at the moment. ES
            addr_r         <= data_in ( addr_width_g -1 downto 0);  -- 31.01.05  --new addr on bus
            comm_a_r       <= comm_in;

            we_to_fifo_r   <= '1';


          elsif next_state = Wait_Addr then
            av_to_fifo_r   <= '0';
            we_to_fifo_r   <= '0';

          elsif next_state = One_Addr then
            addr_r         <= data_in ( addr_width_g -1 downto 0);  -- 31.01.05;  --new addr on bus
            av_to_fifo_r   <= '0';
            comm_a_r       <= comm_in;
            we_to_fifo_r   <= '0';
          else
            assert false report "Illegal next state in rx fsm (1D)" severity warning;
          end if;


        when One_Addr_One_Data =>
          data_to_fifo_r <= data_r;
          comm_to_fifo_r <= comm_d_r;
          av_to_fifo_r   <= '0';
          we_to_fifo_r <= '1';

          if next_state = One_Data_New_Addr then
            addr_r   <= data_in ( addr_width_g -1 downto 0);  -- 31.01.05;        --new addr on bus
            comm_a_r <= comm_in;

          elsif next_state = One_Addr_One_Data then
            -- Fifo full, cannot receive anything
            -- 23.07 This should be impossible branch
            assert false report "Rx : 1a1d - > 1a1d, Illegal?" severity warning;

          elsif next_state = Two_Data then
            data_r   <= data_in;
            comm_d_r <= comm_in;

          elsif next_state /= One_Data then
            assert false report "Illegal next state in rx fsm (1A_1D)" severity warning;             
          end if;



        when Two_Data =>
          we_to_fifo_r <= '1';

          if next_state = Two_Data then

            if full_in = '1' then
              -- 31.03.03 Is this branch ever reached??
              -- This may be the same as if the next state is 2d_full
              assert dbg_level < 1 report "huhuu? two_d - > two_d?" severity note;

            else
              data_r         <= data_in;
              data_to_fifo_r <= data_r;
              comm_to_fifo_r <= comm_d_r;
              av_to_fifo_r   <= '0';
              comm_d_r       <= comm_in;
            end if;

          elsif next_state = One_Data_New_Addr then
            addr_r         <= data_in (addr_width_g-1 downto 0);  -- 31.01.05 --new addr on bus
            data_to_fifo_r <= data_r;
            comm_to_fifo_r <= comm_d_r;
            av_to_fifo_r   <= '0';
            comm_a_r       <= comm_in;

          elsif next_state = One_Data then
            data_to_fifo_r <= data_r;
            comm_to_fifo_r <= comm_d_r;
            av_to_fifo_r   <= '0';

          elsif next_state /= Two_Data_Full then
            assert false report "Illegal next state in rx fsm (2D)" severity warning;
          end if;

          
        when One_Data_New_Addr =>

          if next_state = Wait_Addr then
            av_to_fifo_r   <= '0';
            we_to_fifo_r   <= '0';

          elsif next_state = One_Addr then
            addr_r         <= data_in (addr_width_g -1 downto 0); -- 31.01.05  --new addr on bus
            av_to_fifo_r   <= '0';
            comm_a_r       <= comm_in;
            we_to_fifo_r   <= '0';

          elsif next_state = One_Addr_One_Data then
            data_r         <= data_in;
            data_to_fifo_r <= (others => '0');  -- 31.01.05 jos osoite kapea, nollataan ylimmät bitit
            data_to_fifo_r(addr_width_g-1 downto 0) <= addr_r;    -- osoite fifolle
            comm_to_fifo_r <= comm_a_r;
            av_to_fifo_r   <= '1';
            comm_d_r       <= comm_in;
            we_to_fifo_r   <= '1';

          elsif next_state = One_Data then
            we_to_fifo_r   <= '1';

          else
            assert false report "Illegal next state in rx fsm (1D_nA)" severity warning;             
          end if;

          
       when Two_Data_Full =>

          if next_state = Two_Data_Full_New_Addr then
            addr_r   <= data_in (addr_width_g -1 downto 0);  -- 31.01.05  --new addr on bus
            comm_a_r <= comm_in;
            we_to_fifo_r   <= '1';

          elsif next_state = One_Data then
            data_to_fifo_r <= data_r;
            comm_to_fifo_r <= comm_d_r;
            we_to_fifo_r   <= '1';

          elsif next_state = One_Data_New_Addr then
            addr_r   <= data_in (addr_width_g -1 downto 0);  --31.01.05  --new addr on bus
            comm_a_r <= comm_in;

            data_to_fifo_r <= data_r;
            comm_to_fifo_r <= comm_d_r;
            we_to_fifo_r   <= '1';

          else
            we_to_fifo_r   <= '1';
          end if;


          

      when Two_Data_Full_New_Addr =>
        -- New state 01.04.03
          if next_state = Two_Data_Full then
            -- Fifo still full, everything stays the same
            addr_r   <= (others   => '0');  --'Z'); --addr_r;  -- reseting possible ?
            we_to_fifo_r   <= '1';

          elsif next_state = One_Data then
            -- Another data went into fifo, but the addr cannot be accepted yet
            -- due to lack of fifo space
            data_to_fifo_r <= data_r;
            comm_to_fifo_r <= comm_d_r;
            we_to_fifo_r   <= '1';

          else

            assert false report "TwoData -> ?? : Haloo?" severity note;
          end if;
          
          
        when others =>
          null;
      end case;
    end if;
  end process ControlRegisters;





  -- 6) PROC (ASYNC)
  Def_Conf_next_state : process (cfg_curr_state_r, av_in, comm_in, addr_match_in, cfg_rd_rdy_in)
  begin  -- process Def_Conf_next_state
      -- if modified 2007/04/17
      if cfg_re_g = 1 or cfg_we_g = 1 then

        case cfg_curr_state_r is

          when Conf_Idle =>
            
            if av_in = '1' then
              
              if  (comm_in = w_cfg_c or comm_in = r_cfg_c) then
                -- New conf addr
                cfg_next_state <= Conf_One_Addr;
                assert false report "New conf" severity note;
              else
                cfg_next_state <= Conf_Idle;
              end if;
            else
              cfg_next_state <= Conf_Idle;
            end if;                         -- av & comm

            
          when Conf_One_Addr =>
            if addr_match_in = '1'
              and (comm_in = w_cfg_c or comm_in = r_cfg_c) then
              -- Conf addr matches and conf transfer continues (either conf value
              -- or return addr)
              cfg_next_state <= Conf_Addr_Data;
            else
              -- ConfK addr does not match
              cfg_next_state <= Conf_Idle;
            end if;                         --am & comm


            
          when Conf_Addr_Data =>

            if cfg_rd_rdy_in = '1' then
              --  Current conf data goes into conf_mem/tx_ctrl

              if  (comm_in = w_cfg_c or comm_in = r_cfg_c) then
                -- Conf continues

                if av_in = '1' then
                  -- New confK addr
                  cfg_next_state <= Conf_One_Addr;
                else
                  -- new conf data
                  cfg_next_state <= Conf_Addr_Data;
                end if;                       --av

              else
                -- Conf ends
                cfg_next_state <= Conf_Idle;
              end if;                       --comm
              
            else
              -- Cannot forward current conf data
              if av_in = '1'
                and (comm_in = w_cfg_c or comm_in = r_cfg_c) then
                -- New confK addr
                cfg_next_state <= Conf_One_Addr;
              else
                -- Conf transfer ends, cannot forward current conf data
                cfg_next_state <= Conf_Addr_Data;
              end if;
              
            end if;                         --cfg_rd_rdy_in


          when others =>
            cfg_next_state <= Conf_Idle;
        end case;  --cfg_curr_state_r
      end if;                           -- cfg_we_g or cfg_re_g
      
  end process Def_conf_next_state;




  -- 7) PROC
  Control_Conf_registers : process (clk, rst_n)
  begin  -- process Control_Conf_registers
    if rst_n = '0' then                 -- asynchronous reset (active low)
      cfg_comm_r         <= (others => rst_value_arr (dbg_level* 1));
      cfg_id_r           <= (others => rst_value_arr (dbg_level* 1));
      cfg_addr_r         <= (others => rst_value_arr (dbg_level* 1));
      cfg_return_addr_r  <= (others => rst_value_arr (dbg_level* 1));
      cfg_new_value_r    <= (others => rst_value_arr (dbg_level* 1));
      cfg_read_enable_r  <= '0';
      cfg_write_enable_r <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      if cfg_re_g = 1 or cfg_we_g = 1 then
        
        
        case cfg_curr_state_r is

          when Conf_Idle                       =>
            -- Wait for conf addr

            if cfg_next_state = Conf_One_Addr then
              -- Conf addr on the bus
              cfg_id_r         <= data_in ( addr_width_g -1 downto addr_width_g - id_width_g );  -- 04.03.05;
              cfg_addr_r       <= data_in (cfg_addr_width_g -1 downto 0);  -- 04.03.05;
              cfg_comm_r       <= comm_in;
            end if;
            cfg_write_enable_r <= '0';
            cfg_read_enable_r  <= '0';

            
          when Conf_One_Addr =>
            -- Coonf addr received
            

            case cfg_next_state is
              when Conf_Idle                  =>
                -- Conf addr does not match
                cfg_write_enable_r <= '0';
                cfg_read_enable_r  <= '0';

              when Conf_One_Addr =>
                -- Illegal next state
                assert false report
                  "Illegal state transition conf_one_addr -> conf_one_addr" severity warning;
                

              when Conf_Addr_Data                   =>
                -- Conf addr matches
                -- Check whether the command is read or write

                if comm_in = w_cfg_c then
                  cfg_new_value_r    <= data_in;
                  cfg_write_enable_r <= '1';
                  cfg_read_enable_r  <= '0';
                else
                  cfg_return_addr_r  <= data_in(addr_width_g-1 downto 0);  -- 17.02
                  cfg_write_enable_r <= '0';
                  cfg_read_enable_r  <= '1';
                end if;

            end case;                     --cfg_next_state


          when Conf_Addr_Data =>
            -- Conf addr matched and conf data/return_addr also recieved

            case cfg_next_state is
              when Conf_Idle                  =>
                -- Conf ends
                cfg_write_enable_r <= '0';
                cfg_read_enable_r  <= '0';

              when Conf_One_Addr =>
                -- New conf immediatley following the previous
                -- Take new conf addr
                cfg_write_enable_r <= '0';
                cfg_read_enable_r  <= '0';
                cfg_id_r           <= data_in ( addr_width_g -1 downto addr_width_g - id_width_g );  -- 04.03.05;
                cfg_addr_r         <= data_in (cfg_addr_width_g -1 downto 0);  -- 04.03.05;
                cfg_comm_r         <= comm_in;

              when Conf_Addr_Data               =>
                -- More conf data immediatly, chekc command
                if comm_in = w_cfg_c then
                  -- Conf write
                  cfg_comm_r         <= comm_in;
                  cfg_new_value_r    <= data_in;
                  cfg_write_enable_r <= '1';
                  cfg_read_enable_r  <= '0';

                else
                  -- Conf read
                  cfg_comm_r         <= comm_in;
                  cfg_return_addr_r  <= data_in (addr_width_g -1 downto 0);  -- 31.01.05
                  cfg_write_enable_r <= '0';
                  cfg_read_enable_r  <= '1';
                end if;
                -- Increment conf addr
                -- NOTE: To make style "1 conf_addr + several conf_data"
                -- to work, also the tx_ctrl has to increment conf_addr
                -- so that it continues from correct addr if conf transmission is
                -- interrupted
                cfg_addr_r           <= cfg_addr_r+1;

                
            end case;                     -- cfg_next_state          
        end case;                         -- cfg_curr_state_r
      end if;
    end if;                             --rst / clk'event
  end process Control_Conf_registers;
end rtl;
