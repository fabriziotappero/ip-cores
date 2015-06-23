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
-- File        : tx_control_addr_width_is_1_muxed_fifos.vhdl
-- Description : Control the transmitting of data. Includes
--               the priority arbitration. Config mem gives
--               the start and end times and owners  of time slots.
--
--               This version assumes, muxed fifos, i.e. FSM does no
--               separation between messages and data, it sees only one fifo.
-- Author      : Erno Salminen
-- e-mail      : erno.salminen@tut.fi
-- Project      huuhaa
-- Design      : Do not use term design when you mean system
-- Date        : 11.02.2003
-- Modified    :
--
-- 07.01.03     ES:  Next state of Re_tx_data is always idle!
--              This way there are less problems with reading the fifo
-- 17.03.03     ES: Idle->Write won't work if new addr is coming. Cannot assert
--              fifo read enable in time. consequently, tha same is written
--              twice on the bus
-- 12.04.03     ES: Total_amount, Addr_Amount input ports and Fifo_Depth generic removed
-- 13.04.03     ES: Message stuff removed
--              Constant print_debug added, selects wheteher assertions are
--              used or not
-- 04.03.04     ES: two bugs with target_fifo_full
--              1) target_fifo_full=1 when next addr coming from fifo
--                      => addr stored in data_reg2 and sent as if it was data
--                      => add extra reg for that addr and valid_reg for it
--                      => values stored in them state 'write'
--                      => values read from them when retransfer completes
--                      
--              2) next addr comes from fifo before retransfer is complete
--                      => retransfer goes to 'next addr'
--                      => add one confition to if clause in state idle
--                      (inside else clause 'not own turn')
-- 28.07.2004   ES: cleaning, addr_reg type changed to regular std_logic_vector
-- 03.08.2004   ES: Renamed some states to shorter names. New if-branch inside cfg_d
--                  Added debug_level and Rst_Value for wave form debugging.
--                  Set dbg_level=0 for synthesis.    
-- 13.09.2004   ES: Bug found. When target_fifo_full=1 and addr on the bus, the
--                  addr will be retransferred as addr (ok) and as data also (not
--                  ok). Check addr_valid on state write and assign data_r1 and
--                  data_r2 accordingly
--
-- 15.12.2004   ES names changed
--
-- 03.01.2005   ES retx_addr: check fo full=1 added
-- 14.01.2005      when idle and going to own_slot_reservation, check re
-- 15.01.2005   ES idle->own slot res: lock_out must be 1-
-- 03.02.05     ES  addr_width_g is now in BITS!
-- 07.02.05     ES new generic cfg_re_g
-- 15.05.05     AK A bug when writing every other clock cycle, the data after
--                 the address vanishes. suspicious state: idle 2d. and write_data 4).
--                 corrected, hopefully.
--
-- 13.07.05     AK A bug which reads out an address but doesn't send it when
--                 retransmitting. suspicious state: 1 (under 0a). more
--                 explanation there.
-- ?????????
-- 25.02.2005 Design compiler ei välttämättä syntesoi a_ext-funktiota oikein?
-- 2007/04/18   AK/ES Arbitration type voidaan asettaa ajonaikana 4:ään eri arvoon
-- 2009/07/31   JN Cleanups + keep_slot_g (lock_out = '1' trough whole time slot)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity tx_control is

  generic (
    counter_width_g : integer := 8;
    id_width_g      : integer := 4;
    id_g            : integer := 1;     -- not neede?
    data_width_g    : integer := 32;    -- in bits
    addr_width_g    : integer := 32;    -- in BITS!
    comm_width_g    : integer := 3;
    n_agents_g      : integer := 0;      -- 2009-04-08
    cfg_re_g        : integer := 0;
    keep_slot_g     : integer := 1      -- 2009-07-31
    );
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    lock_in : in std_logic;
    full_in : in std_logic;  --nyk. data/osoite ei mennyt perille!

    cfg_ret_addr_in : in std_logic_vector (addr_width_g-1 downto 0);
    cfg_data_in     : in std_logic_vector (data_width_g-1 downto 0);
    cfg_re_in       : in std_logic;


    curr_slot_own_in    : in std_logic;
    curr_slot_ends_in   : in std_logic;
    next_slot_own_in    : in std_logic;
    next_slot_starts_in : in std_logic;
    max_send_in         : in std_logic_vector (counter_width_g-1 downto 0);
    n_agents_in         : in std_logic_vector (id_width_g-1 downto 0);
    prior_in            : in std_logic_vector (id_width_g-1 downto 0);
    -- *********************************************************
    -- new ports: Power_Mode and Competition_Type must be added!
    -- *********************************************************
    -- 0 round-robin, 1 priority, 2 combined, 3 dyn_arb (rand)
    arb_type_in         :    std_logic_vector(1 downto 0);

    av_in    : in std_logic;
    data_in  : in std_logic_vector (data_width_g-1 downto 0);
    comm_in  : in std_logic_vector (comm_width_g-1 downto 0);
    one_d_in : in std_logic;
    empty_in : in std_logic;

    av_out         : out std_logic;
    data_out       : out std_logic_vector (data_width_g-1 downto 0);
    comm_out       : out std_logic_vector (comm_width_g-1 downto 0);
    lock_out       : out std_logic;
    cfg_rd_rdy_out : out std_logic;
    re_out         : out std_logic
    );

end tx_control;






architecture rtl of tx_control is


  constant write_command_c : std_logic_vector (2 downto 0) := "010";  -- 03.02.05


  -- Selects if debug prints are used ('1') or not ('0')
  constant dbg_level : integer range 0 to 3 := 0;  -- 0= no debug, use 0 for synthesis

  -- Registers may be reset to 'Z' to 'X' so that reset state is clearly
  -- distinguished from active state. Using dbg_level+rst_Value array, the rst value may
  -- be easily set to '0' for synthesis.
  constant rst_value_arr : std_logic_vector (6 downto 0) := 'X' & 'Z' & 'X' & 'Z' & 'X' & 'Z' & '0';

  -- Combinatorial signals
  -- Own_turn_ends is high when own turn ends, i.e.
  --  * maximum amount of data sent
  --  * own slot ends
  --  * other slot starts
  --  09.01.04: This seems to be in critical path.
  --  If this was register, critical path could be shortened.
  --  On the other hand comparison must be changed to drive register one cycle
  --  earlier than combinatorial signal. 
  signal own_turn_ends  : std_logic;
  signal prior_match    : std_logic;
  signal max_send_limit : std_logic;


  -- Define type and signals for state machine
  type state_vector is (Idle,
                        Own_Slot_Reservation,
                        Cfg_A, Cfg_D, Cfg_D_Last,
                        Retransfer_Addr, Retransfer_data, Retransfer_Data_Last,
                        Write_Data, Write_Last_Data, Error_State);  
  signal curr_state_r : state_vector;

  -- Counters and signals denoting start and end of the competition reservation
  -- Counters do not have to be as wide as data! They generate huge delays
  -- and slow down the whole unit if they are unnecessarily wide!
  signal prior_counter_r : std_logic_vector (id_width_g -1 downto 0);
  signal send_counter_r  : std_logic_vector (counter_width_g -1 downto 0);


  -- Register, this way the state of the signal 'read enable' can be read
  signal fifo_re_r : std_logic;

  signal addr1_r   : std_logic_vector (addr_width_g -1 downto 0);  -- 03.02.05
  signal comm_a1_r : std_logic_vector (comm_width_g -1 downto 0);


  -- Registers needed to continue interrupted transfer
  -- When transfer is interrupted, addr and either 1 or 2 data has be trasferred
  -- again.
  -- (Actually, only one data is retransferered, but have another may already
  -- been read from fifo but not transferred. This is data referred as
  -- retransferred because it is handled in the sama way as the actually
  -- retransferred. It is stored in data_reg2 )
  -- When state is write_data
  --  * Regular data goes from fifo to output registers
  --  * At the same, it is copied ro register data_Reg2
  --  * At he same time, previously sent data is copied from data2_r to data1_r
  --  data1_r is retransferred after addr (and after that data2_r if needed)
  signal data1_r       : std_logic_vector (data_width_g -1 downto 0);
  signal data2_r       : std_logic_vector (data_width_g -1 downto 0);
  signal comm_d1_r     : std_logic_vector (comm_width_g -1 downto 0);
  signal comm_d2_r     : std_logic_vector (comm_width_g -1 downto 0);
  signal retx_amount_r : integer range 0 to 2;

  signal addr_valid_r : std_logic;      -- 13.09.04

  -- For storing new addr that comes at the same with full_in=1
  signal addr2_r       : std_logic_vector (addr_width_g -1 downto 0);  -- 03.02.05
  signal comm_a2_r     : std_logic_vector (comm_width_g -1 downto 0);
  signal addr2_valid_r : std_logic;

  -- Signals for configuration read operation
  signal cfg_ret_addr_r      : std_logic_vector (addr_width_g-1 downto 0);  -- 03.02.05
  signal cfg_read_value_r    : std_logic_vector (data_width_g-1 downto 0);
  signal cfg_read_complete_r : std_logic;



  -- Muutetaan vertailun tulos reksiteriksi
  -- =>  lyhyempi kriittinen polku (toivottavasti)
  signal max_send_limit_r : std_logic;


  -- Katsotaan paljonko tulee viivettï¿½tï¿½ï¿½ mennessï¿½
  signal own_turn_ends_r : std_logic;

  -- prior+round-robin countteri
  -- after this amount of clock cycles, change the arb type
  constant switch_arb_c    : integer := 4096;
  signal   switch_arb_r    : integer range 0 to switch_arb_c-1;
  signal   arb_type_r      : std_logic_vector(1 downto 0);
  signal   curr_arb_type_r : std_logic_vector(1 downto 0);

  -- dynamically adaptive arbitration, enable this for "random arb"
  signal   arb_agent_r      : std_logic_vector(id_width_g-1 downto 0);
--  constant dyn_arb_enable_c : integer := 0;
  constant dyn_arb_enable_c : integer := 1;  -- ES 2009-04-01



  signal dyn_arb_prior       : std_logic_vector(id_width_g-1 downto 0);
  signal prior_counter_arb_r : std_logic_vector(id_width_g-1 downto 0);

  component dyn_arb
    generic (
      id_width_g : integer;
      n_agents_g : integer
      );
    port (
      clk           : in  std_logic;
      rst_n         : in  std_logic;
      bus_lock_in   : in  std_logic;
      arb_agent_out : out std_logic_vector(id_width_g-1 downto 0));
  end component;

  
begin  -- rtl



  -- Continous assignments to outputs
  cfg_rd_rdy_out <= cfg_read_complete_r;
  re_out         <= fifo_re_r;
  av_out         <= addr_valid_r;       --13.09.04

  -- Sendcounterin vertialu on omalla kellojaksollaan
  -- => ei ole enï¿½ kriittisellï¿½polulla
  -- Laskurin reset-arvosta riippuu mitkï¿½send_maxit on laillisia
  -- ja lï¿½etetï¿½nkï¿½tarkalleen se mï¿½rï¿½vai pari enemmï¿½, ao. mï¿½rï¿½ sisï¿½tï¿½
  -- ekan osoiteen
  -----------------------------------------------------------------------------
  --   Counterin arvot     Lï¿½. mï¿½rï¿½    Sallitus max-sendin arvot
  ------------------------------------------------------------------------------
  -- jos counter= 0,1,2  max_s+3 kpl      max_s= 2,3+
  -- jos counter= 1,2,3  max_s+2 kpl      max_s= 2,3+
  -- jos counter= 2,3,4  max_s+1 kpl      max_s= 3,4+
  -- jos counter= 3,4,5  max_s   kpl      max_s= 4,5+
  -- => ei kannata resetoida ainakaan nollaan!


  max_send_limit <= max_send_limit_r;

  check_max_send : process (clk, rst_n)
  begin  -- process check_max_send
    if rst_n = '0' then
      max_send_limit_r <= '0';

      own_turn_ends_r <= '0';
      
    elsif clk'event and clk = '1' then

      if (max_send_in (counter_width_g-1 downto 0) = send_counter_r
          or max_send_in = conv_std_logic_vector (0, data_width_g)
          or max_send_in = conv_std_logic_vector (1, data_width_g))
      then

        if (curr_slot_own_in = '1'
            or (next_slot_starts_in = '1' and next_slot_own_in = '1')) then
          max_send_limit_r <= '0';
        else
          max_send_limit_r <= '1';
        end if;
        
      else
        max_send_limit_r <= '0';
      end if;

      own_turn_ends_r <= own_turn_ends;

    end if;
  end process check_max_send;



  -- 2) COMB PROC
  -- Check if priority matches so that competition reservation may start
  Check_Prior : process (prior_in, prior_counter_r)
  begin  -- process Check_Send_Limit
    if prior_counter_r = prior_in (id_width_g-1 downto 0) then  --22.01.03
      prior_match <= '1';
    else
      prior_match <= '0';
    end if;
  end process Check_Prior;



  -- 3) PROC (ASYNC)
  -- Check if bus reservation must be ended
  -- Own turn ends, if
  -- * max amount data already transferred
  -- * or own slot ends
  -- * or some other wrapper's slot starts
  -- When Own_turn_ends=1, wrapper can transfer one value
  Check_Turn : process (max_send_limit,
                        curr_slot_own_in, curr_slot_ends_in,
                        next_slot_own_in, next_slot_starts_in)
  begin  -- process Check_Turn
    if max_send_limit = '1'
      or ((curr_slot_own_in = '1' and curr_slot_ends_in = '1')
          or (next_slot_own_in = '0' and next_slot_starts_in = '1'))then
      own_turn_ends <= '1';
    else
      own_turn_ends <= '0';
    end if;
  end process Check_Turn;



  -- 4) SEQ PROC
  -- Count how many data has been transferred
  -- Counter is not incremented, if
  -- * wrapper is not trasferring
  -- * wrapper has a time slot
  -- * wrapper is finishing transfer
  Count_Sent_Items : process (clk, rst_n)
  begin  -- process Count_Sent_Items
    if rst_n = '0' then                 -- asynchronous reset (active low)
      send_counter_r <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      if curr_state_r = Idle
        or curr_slot_own_in = '1'
        or curr_state_r = Write_Last_Data
        or curr_state_r = Retransfer_Data_Last
        or curr_state_r = Cfg_D_Last then

        send_counter_r <= (others => '0');

        send_counter_r(1) <= '1';       -- 12.12.05 reset to 0x002
        send_counter_r(0) <= '1';       -- 12.12.05 reset to 0x001


        -- Counter should be incremented already when moving from idle to
        -- some write state (Write_Data / Cfg_A / Retransfer_Addr)!
        -- At the moment, counter is started one clock cycle too late
        -- => send_max+1 data will be transferred
        -- 31.07 can this be fixed, if counter was reset to 1

        else

        if curr_slot_own_in = '1'
          or (next_slot_starts_in = '1' and next_slot_own_in = '1') then
          send_counter_r <= (others => '0');
        else
          send_counter_r <= send_counter_r +1;
        end if;  -- curr_slot_own_in
      end if;  -- Curr_State
    end if;  -- rst_n/clk'event
  end process Count_Sent_Items;





  -- 5) SEQ PROC
  Define_output : process (clk, rst_n)
    variable lock_v : std_logic;
  begin  -- process Define_output

    if rst_n = '0' then
      lock_out     <= '0';
      addr_valid_r <= '0';
      comm_out     <= (others => '0');
      data_out     <= (others => '0');

      data1_r       <= (others => rst_value_arr (dbg_level* 1));
      data2_r       <= (others => rst_value_arr (dbg_level* 1));
      comm_d1_r     <= (others => rst_value_arr (dbg_level* 1));
      comm_d2_r     <= (others => rst_value_arr (dbg_level* 1));
      addr1_r       <= (others => rst_value_arr (dbg_level* 1));
      addr2_r       <= (others => rst_value_arr (dbg_level* 1));
      comm_a1_r     <= (others => rst_value_arr (dbg_level* 1));
      comm_a2_r     <= (others => rst_value_arr (dbg_level* 1));
      addr2_valid_r <= '0';

      fifo_re_r           <= '0';
      cfg_read_complete_r <= '1';
      cfg_read_value_r    <= (others => rst_value_arr (dbg_level* 1));
      cfg_ret_addr_r      <= (others => rst_value_arr (dbg_level* 1));

      retx_amount_r <= 0;
      curr_state_r  <= Idle;

    elsif clk'event and clk = '1' then
      -- checks that the command is being fed with data.
      assert (empty_in = '1' or (empty_in = '0' and comm_in /= "000")) report "Comm warning! idle from FIFO" severity error;


      -- default value, just in case..
      lock_v := '0';

      -- Control the configuration registers
      -- Read conf value from conf mem to register

      if cfg_re_g = 1
        and cfg_re_in = '1' then

        cfg_ret_addr_r      <= cfg_ret_addr_in;
        cfg_read_value_r    <= cfg_data_in;
        cfg_read_complete_r <= '0';
      else

        if curr_state_r = Cfg_D_Last
          or curr_state_r = Cfg_D then

          if full_in = '0' then
            -- Answering to conf read succeeded
            cfg_read_complete_r <= '1';
          else
            -- Answering did not succeed
            cfg_read_complete_r <= '0';

            assert dbg_level < 2 report "Conf (Last) D : Ei onnistunut" severity note;
            
          end if;
        end if;
      end if;




      -- Control other registers
      -- Register values are updated when state changes
      -- (i.e. the assigment clause is in the previous state in the code)
      -- => e.g. addr is written when moving idle->Retransfer_Addr
      -- => when state=Retransfer_Addr :
      --    *  bus=addr and data_out_reg <= next data
      case curr_state_r is



        --++++++++++++++        
        when Idle =>


          -- (0a Something to transmit, own turn not ending
          --  0b Nothing to do)

          -- 1) Own time slot starts
          -- 2) Competition 
          --    2a) Re_transmit
          --    2b) Answer conf read
          --    2c) New addr+data
          --    2d) New addr but no data, stop. Remove this branch?
          --    2e) New data, use old addr
          --    2f) Illegal?
          -- 3) Not own turn
          --

          if own_turn_ends = '0'
            and (empty_in = '0'
                 or (cfg_re_g = 1 and cfg_read_complete_r = '0')
                 or retx_amount_r /= 0) then
            -- 0a)

            if next_slot_own_in = '1' and next_slot_starts_in = '1' then
              -- 1) Own time slot starts
              lock_v       := '1';
              addr_valid_r <= '0';
              addr_valid_r <= '0';
              data_out     <= (others => '0');
              comm_out     <= (others => '0');

              assert false report "????????????????????????????????????????" severity warning;
              assert false report "tx_ctrl/idle: Suspicious if-elsif branch (own slot starts)" severity warning;

              if (fifo_re_r = '0'
                  and retx_amount_r = 0
                  and empty_in = '0' and av_in = '1' and one_d_in = '1') then
                fifo_re_r    <= '1';            -- 02.06.06 es
                addr1_r      <= data_in (addr_width_g -1 downto 0);  -- 02.06.06 es
                comm_a1_r    <= comm_in;        -- 02.06.06 es
                curr_state_r <= idle;           -- 05.06.2006
                assert dbg_level < 1 report "idle : oma aikaslotti alkaa, mutta vain 1 osoite fifossa" severity note;

              elsif (fifo_re_r = '0'
                     and retx_amount_r = 0
                     and empty_in = '0' and av_in = '1' and one_d_in = '0') then
                -- 05.06.06 es
                fifo_re_r    <= '1';
                addr1_r      <= data_in (addr_width_g -1 downto 0);
                comm_a1_r    <= comm_in;
                curr_state_r <= Own_Slot_Reservation;
                assert dbg_level < 1 report "idle : oma aikaslotti alkaa, 05.06.2006 Brand new!" severity note;

              else
                fifo_re_r    <= '0';
                assert dbg_level < 1 report "idle : oma aikaslotti alkaa +re = 0" severity note;
                curr_state_r <= Own_Slot_Reservation;
              end if;

              -- Why did we read out the address? it wasn't even stored anywhere.
              -- It seems that address needs to be read in some cases, but in some
              -- it must not be! The bug can be seen in the tx control testbench.
              -- However, simply setting fifo_re_r <= '0'; doesn't solve the problems;
              -- it causes more.
              -- Bug was discovered with video system, where (erratically) n_time_slots
              -- was one although timeslots are not used.
              -- 13.7.05 AK
              assert false report "????????????????????????????????????????" severity warning;

              
            elsif (next_slot_starts_in = '0' and prior_match = '1'
              and (lock_in = '0')) or (keep_slot_g = 1 and curr_slot_own_in = '1')
            then
              -- 2) Competition
              -- Note: Order. 1) retx, 2) cfg and so on

              -- Note! 21.01.2003
              -- Comparison (lock_in = '1' and full_in = '1') caused
              -- problems, when receiver asserts full=1 during addr phase.
              -- (Receiver _should_ assert target_full only during data phase but
              -- you never know)
              -- Then trasmitter puts data on the bus but the next wrapper may
              -- put its own addr on the at same time => conflict

              assert dbg_level < 3 report "Kilpailuvuoro" severity note;



              if retx_amount_r /= 0 then
                -- 2a) Receiver got full last time
                curr_state_r                       <= Retransfer_Addr;
                addr_valid_r                       <= '1';
                data_out                           <= (others => '0');  -- 01.03.05
                data_out (addr_width_g-1 downto 0) <= addr1_r;  -- 01.03.05
                comm_out                           <= comm_a1_r;
                lock_v                             := '1';
                fifo_re_r                          <= '0';

                assert dbg_level < 3 report "Idle : uusiolahetys" severity note;



                -- 25.01.05 elsif cfg_read_complete_r = '0' then
              elsif cfg_re_g = 1 and cfg_read_complete_r = '0' then
                -- 2b) Conf read has not been yet answered
                -- Answered conf values don't have to be stored in addr_reg/data_reg
                curr_state_r                       <= Cfg_A;
                addr_valid_r                       <= '1';
                data_out                           <= (others => '0');  -- 01.03.05
                data_out (addr_width_g-1 downto 0) <= cfg_ret_addr_r;  -- 01.03.05
                comm_out                           <= write_command_c;  -- 03.02.05
                lock_v                             := '1';
                fifo_re_r                          <= '0';

                assert dbg_level < 3 report "idle : vastataan konf. lukuun" severity note;
                

--              elsif (empty_in = '0' and av_in = '1' and one_d_in = '0') then
                -- 2c) New addr and data

--                assert dbg_level < 3 report "idle : uusi osoite" severity note;

                -- Take the safe way, stay in idle until addr is read from the
                -- fifo 17.03.03
--                curr_state_r <= Idle;
--                addr_valid_r <= '0';
--                data_out     <= (others => '0');
--                comm_out     <= (others => '0');
--                lock_v       := '0';
                
--                fifo_re_r    <= '0';

                -- AK 12.05.05
              elsif (empty_in = '0' and av_in = '1') then -- and one_d_in = '1') then
                -- 2d) Only new addr but no data
                curr_state_r <= Idle;
                addr_valid_r <= '0';
                comm_out     <= (others => '0');
                data_out     <= (others => '0');
                lock_v       := '0';

                -- 13.05.2005 ES
                if fifo_re_r = '0' then
                  addr1_r   <= data_in (addr_width_g -1 downto 0);  -- 03.02.05
                  comm_a1_r <= comm_in;
                  fifo_re_r <= '1';
                else
                  fifo_re_r <= '0';
                end if;



                assert dbg_level < 3 report "idle : pelkastaan uusi osoite (ei laheteta)" severity note;
                

              elsif (empty_in = '0' and av_in = '0') then
                -- 2e) Data coming from fifo
                -- Transfer previous addr again
                curr_state_r                       <= Retransfer_Addr;
                addr_valid_r                       <= '1';
                data_out                           <= (others => '0');  -- 01.03.05
                data_out (addr_width_g-1 downto 0) <= addr1_r;  -- 01.03.05
                comm_out                           <= comm_a1_r;
                lock_v                             := '1';
                fifo_re_r                          <= '1';  
                assert dbg_level < 3 report "idle : ed data jatkuu" severity note;


              else
                -- 2f) Illegal (?) branch
                curr_state_r <= Error_State;
                -- 22.07 Actually this branch may be reached if fifo has one addr
                -- but no data
                addr_valid_r <= '0';
                data_out     <= (others => '0');
                comm_out     <= (others => '0');
                lock_v       := '0';

                assert false report "Idle => Error_state" severity error;
                assert av_in = '1' report "AV on 0" severity note;
                assert av_in = '0' report "AV on 1" severity note;
                assert empty_in = '1' report "empty_in on 0" severity note;
                assert empty_in = '0' report "empty_in on 1" severity note;
                assert one_d_in = '1' report "one_d_in on 0" severity note;
                assert one_d_in = '0' report "one_d_in on 1" severity note;

                
              end if;  -- re_tx_amount

            else
              -- 3) Not own turn
              curr_state_r <= Idle;
              addr_valid_r <= '0';
              data_out     <= (others => '0');
              comm_out     <= (others => '0');
              lock_v       := '0';
              assert dbg_level < 3 report "Idle : Odotetaan omaa vuoroa" severity note;


              -- Read addr already before own turn  19.07 es
              -- Keep RE=1 only for one cycle
              -- Assure that addr_reg is not reserved, i.e. retransfer is completed
              if empty_in = '0'
                and retx_amount_r = 0   -- 04.03.04
                and av_in = '1'
                and fifo_re_r = '0' then

                assert dbg_level < 3 report "Idle : luetaan datafifosta osoite valmiiksi" severity note;


                fifo_re_r <= '1';
                addr1_r   <= data_in (addr_width_g-1 downto 0);  -- 03.02.05
                comm_a1_r <= comm_in;
              else
                fifo_re_r <= '0';
              end if;
            end if;  --next_slot_own_in etc.


          else
            -- 0b) Nothing to do :
            -- * target did not get on previous transfer
            -- * conf read has been answered
            -- * no data to send
            -- * not possible to start on turn (e.g. send_max = 0)

            curr_state_r <= Idle;
            addr_valid_r <= '0';
            comm_out     <= (others => '0');
            data_out     <= (others => '0');
            fifo_re_r    <= '0';
            lock_v       := '0';

            assert dbg_level < 3 report "Ei ole mitaan sanottavaa kenellekaan" severity note;
            
          end if;  --own_turn & (empty_in or Cfg_Read or Re_tx_Amount)





          --++++++++++++++
        when Own_Slot_Reservation =>
          -- Always move forward from this state. This state lasts only for one cycle
          -- By default, reserve bus and write addr
          lock_v       := '1';
          addr_valid_r <= '1';

          -- Note: Order
          -- 0. Own turn ends before it starts. Aargh.
          -- 1. retransfer
          -- 2. answering conf read
          -- 3. data
          --  3a) New addr and data
          --  3b) New data, use old addr
          -- 4) 

          if own_turn_ends = '1' then
            -- 0) Own turn ends before it starts. Aargh.
            curr_state_r <= Idle;
            addr_valid_r <= '0';
            data_out     <= (others => '0');
            comm_out     <= (others => '0');
            lock_v       := '0';
            fifo_re_r    <= '0';

            assert dbg_level < 1 report "Own slot : VUORO LOPPUU ENNEN KUIN ALKAAKAAN!" severity note;

          elsif retx_amount_r /= 0 then
            -- 1) Receiver got full on previous transfer, try again
            curr_state_r                       <= Retransfer_Addr;
            data_out                           <= (others => '0');  -- 01.03.05
            data_out (addr_width_g-1 downto 0) <= addr1_r;          -- 01.03.05
            comm_out                           <= comm_a1_r;
            fifo_re_r                          <= '0';
            assert dbg_level < 3 report "Own slot : uusiolahetys" severity note;


          elsif cfg_re_g = 1 and cfg_read_complete_r = '0' then
            -- 2) Not yet answered to conf read 
            curr_state_r                       <= Cfg_A;
            data_out                           <= (others => '0');  -- 01.03.05
            data_out (addr_width_g-1 downto 0) <= cfg_ret_addr_r;   -- 01.03.05
            comm_out                           <= write_command_c;  -- 03.02.05 
            fifo_re_r                          <= '0';
            assert dbg_level < 3 report "Own slot : conf return addr" severity note;

          elsif (empty_in = '0' and av_in = '1' and one_d_in = '0') then
            -- 3a) New addr and data
            curr_state_r <= Write_Data;
            data_out     <= data_in;
            comm_out     <= comm_in;
            addr1_r      <= data_in(addr_width_g-1 downto 0);  -- 17.02
            comm_a1_r    <= comm_in;
            fifo_re_r    <= '1';

            assert dbg_level < 1 report "Own slot : uusi osoite+dataa." severity note;
            

          elsif av_in = '0' and empty_in = '0' then
            -- 3b) New data, use old addr
            curr_state_r                       <= Retransfer_Addr;
            data_out                           <= (others => '0');  -- 01.03.05
            data_out (addr_width_g-1 downto 0) <= addr1_r;          -- 01.03.05
            comm_out                           <= comm_a1_r;
            fifo_re_r                          <= '1';

            assert dbg_level < 1 report "Own slot : Ed data jatkuu" severity note;
            

          else
            -- 4) Illegal branch
            assert false report "Own slot => Error_state" severity error;


            curr_state_r <= Error_State;
            addr_valid_r <= '0';
            data_out     <= (others => '0');
            comm_out     <= (others => '0');
            lock_v       := '0';
            fifo_re_r    <= '0';
          end if;  --retx_amount_r /= 0



          --++++++++++++++

        when Cfg_A =>
          -- Return addr of conf read already transferred, write conf value now
          -- It is not possible to have Target_Full=1, is it?
          -- HUOM! 25.11.04 TK: ainakin mina sain alla olevan tulostuksen
          -- tb_tx_rx -testipenkilla aikaiseksi... 

          if cfg_re_g = 1 then
            -- if added 25.01.05

            assert not(dbg_level > 0 and full_in = '1') report "tx_ctrl:cfg_a TargetFull=1 unexpectedly" severity warning;


            if own_turn_ends = '1' or empty_in = '1' then
              curr_state_r <= Cfg_D_Last;
              lock_v       := '0';
              assert dbg_level < 3 report "Conf A : Lopetellaan, (seur Last Conf D)" severity note;
            else
              curr_state_r <= Cfg_D;
              lock_v       := '1';
              assert dbg_level < 3 report "Conf A : Jatketaan, (seur Conf D)" severity note;
            end if;

            --!!!!!!!!!
            -- 19.12.2005
            -- Data_out comes from cfg_mem
            --!!!!!!!!!


            addr_valid_r <= '0';
            data_out     <= cfg_read_value_r;  -- 19.12.2005 
            comm_out     <= write_command_c;
            fifo_re_r    <= '0';

            if (empty_in = '0' and av_in = '1') then  -- and one_d_in = '0') then
              fifo_re_r <= '1';
              addr1_r   <= data_in (addr_width_g -1 downto 0);
              comm_a1_r <= comm_in;
            else
              fifo_re_r <= '0';
            end if;
            -- else not needed ?            
          end if;  --cfg_re_g = 1
          --++++++++++++++

          
        when Cfg_D =>
          -- Conf read answered
          -- 1) Not success
          -- 2) Success but own turn ends
          -- 3) Success + own turn continues
          --  3a) New addr+data
          --  3b) Only new addr, no data, This added 03.08.2004
          --  3c) New data (use old addr)
          -- 4)

          if cfg_re_g = 1 then
            -- if added 25.01.05
            

            if full_in = '1' then
              -- 1) Answering to conf read did not succeed because receiver got full
              -- Config registers are controlled outside of "switch Curr_State"
              -- so nothing has to be done here
              curr_state_r <= Idle;
              lock_v       := '0';
              addr_valid_r <= '0';
              data_out     <= (others => '0');
              comm_out     <= (others => '0');
              fifo_re_r    <= '0';
              assert dbg_level < 3 report "Conf D : Lopetellaan koska kohde taysi, (seur idle)" severity note;


            elsif own_turn_ends = '1' then
              -- 2) Cannot continue transferring data after conf value
              curr_state_r <= Idle;
              lock_v       := '0';
              addr_valid_r <= '0';
              data_out     <= (others => '0');
              comm_out     <= (others => '0');
              fifo_re_r    <= '0';
              assert dbg_level < 3 report "Conf D : Oma vuoro loppuu, (seur idle)" severity note;

            else
              -- 3) Answering conf read succeeded and own turn continues


              -- If-structure totally new 03.08.2004
              if empty_in = '0' then
                if av_in = '1' then
                  -- New addr
                  if one_d_in = '0' then
                    -- 3a) Also new data                  
                    curr_state_r <= Write_Data;
                    addr_valid_r <= '1';
                    data_out     <= data_in;
                    comm_out     <= comm_in;
                    lock_v       := '1';
                    addr1_r      <= data_in (addr_width_g -1 downto 0);
                    comm_a1_r    <= comm_in;
                    fifo_re_r    <= '1';
                    assert dbg_level < 1 report "Conf D   : Valmis. Seur uuden datan osoite" severity note;
                    assert dbg_level < 2 report "31.03.03 : Tuleeko osoite yhden kerran vai kahdesti vaylalle??" severity note;

                  else
                    -- 3b) Addr only, stop tx                  
                    curr_state_r <= Idle;
                    addr_valid_r <= '0';
                    data_out     <= (others => '0');
                    comm_out     <= (others => '0');
                    lock_v       := '0';
                    fifo_re_r    <= '0';
                  end if;  -- one_d

                else
                  -- 3c) New data, use old addr
                  -- i.e. empty=0 and av=0 
                  curr_state_r                       <= Retransfer_Addr;
                  addr_valid_r                       <= '1';
                  data_out                           <= (others => '0');  -- 01.03.05
                  data_out (addr_width_g-1 downto 0) <= addr1_r;  -- 01.03.05
                  comm_out                           <= comm_a1_r;
                  lock_v                             := '1';
                  fifo_re_r                          <= '1';
                  assert dbg_level < 3 report "Conf D                : Valmis. Ed datan osoite uudestaan" severity note;
                  assert dbg_level < 0 report "Conf D - > retx_a     : re = 1. Correct? " severity note;
                  assert retx_amount_r < 1 report "Conf D - > retx_a : retx_amount_r > 0 " severity note;


                end if;  -- av

              else
                -- 4) No data, stop tx
                curr_state_r <= Idle;
                addr_valid_r <= '0';
                data_out     <= (others => '0');
                comm_out     <= (others => '0');
                lock_v       := '0';
                fifo_re_r    <= '0';
              end if;  -- empty
            end if;  -- target_Fifo_Full
          end if;  -- cfg_re_g=1?           



          --++++++++++++++
        when Cfg_D_Last =>
          -- Last cycle of own turn.
          -- Checking whether the conf read answer succeeded is
          -- done elsewhere

          if cfg_re_g = 1 then
            

            curr_state_r <= Idle;
            addr_valid_r <= '0';
            data_out     <= (others => '0');
            comm_out     <= (others => '0');
            lock_v       := '0';
            addr1_r      <= addr1_r;
            comm_a1_r    <= comm_a1_r;
            fifo_re_r    <= '0';
          end if;  -- cfg_re_g=1?           




          --++++++++++++++
        when Retransfer_Addr =>
          -- At the moment, retransferred addr is on the bus
          -- write data now

          -- 1) Addr retransferrred, next data comes from fifo
          --    1a) Own turn ends, write one data
          --    1b) Own turn continues
          --        1ba) Only data in fifo
          --        1bb) ??? 
          -- 2) At least 1 data must be retransferred
          --    2a) Own turn ends, write r1 and stop
          --    2b) Own turn continues, write r1

          addr_valid_r <= '0';

          -- Check for full=1 added 03.01.2005, ES
          -- This probably caused the Stratix problem with 2*Nios+Sdram
          if full_in = '1' then

            curr_state_r <= Idle;
            data_out     <= (others => '0');
            comm_out     <= (others => '0');
            lock_v       := '0';
            fifo_re_r    <= '0';

            if fifo_re_r = '1' then
              -- better condition would be retx_amount_r /= 0, perhaps, 28.02.2006
              retx_amount_r <= 1;
              data1_r       <= data_in;
              comm_d1_r     <= comm_in;
            end if;  -- fifo_re_r


            
            
          else
            -- code inside thi else-branch is the original code (before 03.01.2005)
            
            if retx_amount_r = 0 then
              -- 1) No data has to be retransferred, next data comes from fifo
              retx_amount_r <= 0;
              addr_valid_r  <= '0';

              if own_turn_ends = '1' then
                -- 1a) Own turn ends, write one data and then stop
                curr_state_r <= Write_Last_Data;
                data_out     <= data_in;
                comm_out     <= comm_in;
                lock_v       := '0';
                fifo_re_r    <= '0';
                assert dbg_level < 3 report "re tx A : 1 data ja lopetetaan" severity note;

                data2_r   <= data_in;
                comm_d2_r <= comm_in;

              else
                -- 1b) Own turn continues
                data_out  <= data_in;
                comm_out  <= comm_in;
                data2_r   <= data_in;
                comm_d2_r <= comm_in;
                assert dbg_level < 3 report "re tx A : Jatketaan datalla" severity note;

                if one_d_in = '1' and av_in = '0' then
                  -- 1ba) One data left in the fifo, write that and stop
                  curr_state_r <= Write_Last_Data;
                  lock_v       := '0';
                  fifo_re_r    <= '0';  --'1' 31.03.03

                  assert dbg_level < 3 report "ReTx_A => Write_last_Data, re <= 0" severity note;
                  

                else
                  -- 1bb) More than one data (or data+addr etc) in fifo
                  curr_state_r <= Write_Data;
                  lock_v       := '1';
                  fifo_re_r    <= '1';

                  assert empty_in = '0' report "ReTx_A : fifossa ei lahetettavaa! APUVA" severity error;
                end if;  -- end 1_d && av

              end if;  --own_turn_ends =1

            else
              -- 2) At the moment retx_amount_r /= 0
              -- Has to transfer at least one data again
              -- retx_amount_r = 1 or 2

              -- send data from reg1 first
              addr_valid_r <= '0';
              data_out     <= data1_r;
              comm_out     <= comm_d1_r;
              fifo_re_r    <= '0';

              -- 'Decrement' retx_amount_r
              if retx_amount_r = 1 then
                retx_amount_r <= 0;
              else
                retx_amount_r <= 1;
              end if;


              if own_turn_ends = '1' then
                -- 2a) Write one data and stop
                curr_state_r <= Retransfer_Data_Last;
                lock_v       := '0';
                assert dbg_level < 3 report "re tx A => re tx D last" severity note;
              else
                -- 2b) Own turn continues
                curr_state_r <= Retransfer_Data;
                lock_v       := '1';
                assert dbg_level < 3 report "re tx A => re tx D" severity note;
              end if;

            end if;  --retx_amount_r



          end if;


          -- State Retransfer_Addr ends ------------------------------------





          --++++++++++++++
        when Retransfer_Data =>
          -- At the moment, bus data equals to
          --  * reg1, if prev state was ReTx_Addr
          --  * reg2, if prev state was ReTx_Data

          -- If writing succeeded, then
          -- max. 1 data (=reg2) has to be retransferred


          -- 1) target_Full
          -- 2) target not full
          --   2a) Own turn ends
          --       2aa) Retransfer complete, end turn
          --       2ab) Still r2 to retransfer and then end turn
          --   2b) Own turn continues
          --       2ba) Retransfer complete
          --            2baa) Answer cfg read
          --            2bab) Safe way: go to idle
          --       2bb) Retransfer r2    

          if full_in = '1' then
            -- 2) Retransfer did not succeed
            curr_state_r <= Idle;
            addr_valid_r <= '0';
            data_out     <= (others => '0');
            comm_out     <= (others => '0');
            lock_v       := '0';
            fifo_re_r    <= '0';

            -- 'increment' retx_amount_r back to previous value
            -- No other action is needed, because re_transfer registers
            -- keep their values
            if retx_amount_r = 1 then
              retx_amount_r <= 2;
              assert dbg_level < 2 report "ReTxD : Target full. Retransmit 2" severity note;
            else
              retx_amount_r <= 1;
              assert dbg_level < 2 report "ReTxD : Target full. Retransmit 1" severity note;
            end if;


          else
            -- Retransfer success
            -- => data2_r has be retransferred if anything
            retx_amount_r <= 0;

            if own_turn_ends = '1' then
              -- 2a) Retransfer succes but cannot continue
              lock_v := '0';

              if retx_amount_r = 0 then
                -- 2aa) Data currently on the bus was the last one to retransfer
                -- Cannot do anything because own turn ends
                curr_state_r <= Idle;
                addr_valid_r <= '0';
                data_out     <= (others => '0');
                comm_out     <= (others => '0');

                assert dbg_level < 3 report "ReTxD =>  idle: Turn ends" severity note;


                -- 04.03.04             --------------------------------------------------
                if addr2_valid_r = '1' then
                  -- Take addr from extrapextra register into use
                  addr1_r       <= addr2_r;
                  comm_a1_r     <= comm_a2_r;
                  addr2_valid_r <= '0';
                end if;
                -- 04.03.04 ends        ----------------------------------------------

              else
                -- 2ab) Still data2_r to retransfer and after that own turn is ends
                curr_state_r <= Retransfer_Data_Last;
                addr_valid_r <= '0';
                data_out     <= data2_r;
                comm_out     <= comm_d2_r;
                data1_r      <= data2_r;
                comm_d1_r    <= comm_d2_r;


                assert dbg_level < 3 report "ReTxD => ReTx_D_Last : Turn ends" severity note;

              end if;  --retx_amount_r

              
            else
              -- 2b) This else branch Belongs to "if own_turn_ends = '1'"
              -- Retransfer success and own turn continues

              if retx_amount_r = 0 then
                -- 2ba) Data currently on the bus was the last one to retransfer

                -- Orig     : Select next state: either Write_D or Conf_A
                -- 07.01.03 : Always go to idle because it simplifies things.
                --            Performance loss is considered negligible (es) 


                -- 04.03.04             ---------------------------------------------------
                if addr2_valid_r = '1' then
                  -- Take addr from extrapextra register into use
                  addr1_r       <= addr2_r;
                  comm_a1_r     <= comm_a2_r;
                  addr2_valid_r <= '0';
                end if;

                -- 04.03.04 ends        ----------------------------------------------


                -- 25.01.05 if cfg_read_complete_r = '0' then
                if cfg_re_g = 1 and cfg_read_complete_r = '0' then
                  -- 2baa) Nothing to retransfer, but conf read is not yet answered

                  -- 07.01.03 Take the safe way, go to Idle
                  curr_state_r <= Idle;
                  lock_v       := '0';
                  fifo_re_r    <= '0';
                  addr_valid_r <= '0';
                  data_out     <= (others => '0');
                  comm_out     <= (others => '0');

                  assert dbg_level < 3 report "ReTxD =>  (Conf_Read_A) _idle_" severity note;
                  

                else
                  -- 2bab) nothing to retransfer and conf read is answered

                  -- 07.01.03  Take the safe way, go to Idle
                  curr_state_r <= Idle;
                  lock_v       := '0';
                  data_out     <= (others => '0');
                  comm_out     <= (others => '0');
                  fifo_re_r    <= '0';

                  assert dbg_level < 3 report "ReTxD => (write) _idle_" severity note;

                end if;  -- cfg_read_complete_r

              else
                -- 2bb) Else branch to "if retx_amount_r = 0 then"
                -- means that retx_amount_r > 0
                -- => data2_r has to be retransferred
                -- 31.03.03
                curr_state_r <= Retransfer_Data;  --keep this state for one more cycle
                addr_valid_r <= '0';
                data_out     <= data2_r;
                comm_out     <= comm_d2_r;
                lock_v       := '1';

                data1_r   <= data2_r;
                comm_d1_r <= comm_d2_r;
                fifo_re_r <= '0';       -- vaihdettu 07.01.03 oli '1';

                assert dbg_level < 3 report "ReTxD => ReTx_D, write reg2 to bus" severity note;
                
                
              end if;  -- retx_amount_r = 0
            end if;  -- own_turn_ends
          end if;  -- full_in
          -- State Retransfer_Data ends --------------------------------------




          --++++++++++++++
        when Retransfer_Data_Last =>
          -- Last cycle of own turn
          -- Currently, bus data = retransferred data
          --  a) data1_r, (amount=1)
          --  b) data2_r, (amount=0)

          curr_state_r <= Idle;
          addr_valid_r <= '0';
          data_out     <= (others => '0');
          comm_out     <= (others => '0');
          lock_v       := '0';

          -- Check if the receiver accepted data
          if full_in = '1' then
            -- 'increment' retx_amount_r back to prev values
            -- No other action needed, because of separate retx registers
            if retx_amount_r = 1 then
              retx_amount_r <= 2;
            else
              retx_amount_r <= 1;
            end if;

          else
            -- Retransfer success

            -- data1_register succesfully transmitted,
            -- still, value of data2 has to be retrasmitted later
            data1_r   <= data2_r;
            comm_d1_r <= comm_d2_r;

            -- Take addr from extrapextra register into use
            -- NOTE: additional condition for amount
            if addr2_valid_r = '1' and retx_amount_r = 0 then
              addr1_r       <= addr2_r;
              comm_a1_r     <= comm_a2_r;
              addr2_valid_r <= '0';
            end if;



          end if;
          -- State Retransfer_Data_Last ends --------------------------------------







          --++++++++++++++  
        when Write_Data =>
          -- Regular data goes from fifo to output registers
          -- At the same, the data is copied to register data2_r
          -- At the same, time, previously sent data is copied from data2_r to data1_r
          -- If target got full, the data that was on the bus can be returned
          -- from reg1 and the next data taken away from fifo is in reg2.

          -- 1) Receiver got full
          --    1a) tx was reading fifo
          --        1aa) addr coming from fifo, re_tx 1 data
          --        1ab) data coming from fifo, re_tx 2 data
          --    1b) tx was not reading fifo, re_tx 1 data
          --    
          -- 2) Tx success but own turn ends
          --    2a) One can be written, then stop tx
          --    2b) New addr canot be written, stop tx
          --    
          -- 3) Tx success and own turn continues
          --    3a) Finish regular write before conf
          --    3b) Answer conf read
          -- 4)
          --    4a) New addr but no data, stop tx
          --    4b) One data, write it and stop tx
          --    4c) At least one data, continue
          -- 


          -- Default assignments
          data1_r   <= data2_r;         -- equals to current bus data
          comm_d1_r <= comm_d2_r;
          data2_r   <= data_in;         -- equals to data on the bus on next cycle
          comm_d2_r <= comm_in;



          if full_in = '1' then
            -- 1) Receiver got full, stop
            curr_state_r <= Idle;
            lock_v       := '0';
            addr_valid_r <= '0';
            data_out     <= (others => '0');
            comm_out     <= (others => '0');
            fifo_re_r    <= '0';

            -- Transfer did not succeed
            if fifo_re_r = '1' then
              -- 1a) FSM was reading fifo
              -- => has to retransfer data on the bus and the data that came
              -- from fifo

              -- 04.03.04 contents 'if fifo_re_r = '1" changed
              -- Originally addr and data from fifo were treated in a same
              -- manner
              -- Now if-else clause is added to make a distinction
              -- Original behavior is now locates inside else-branch

              if av_in = '1' then
                -- 1aa) New addr from fifo, that goes to addr_2r
                retx_amount_r <= 1;
                data1_r       <= data2_r;
                comm_d1_r     <= comm_d2_r;
                addr2_r       <= data_in (addr_width_g -1 downto 0);  -- 03.02.05;
                comm_a2_r     <= comm_in;
                addr2_valid_r <= '1';
                assert dbg_level < 2 report "Write_D : target full, re = 1, av_f = 1, av_hibi = ?, retransmit 1" severity note;

              else
                -- 1ab) New data from fifo

                -- 13.09.04 If clause added to check if addr is currently on the bus
                if addr_valid_r = '0' then
                  -- Data on the bus. 'normal' case
                  retx_amount_r <= 2;
                  data1_r       <= data2_r;
                  comm_d1_r     <= comm_d2_r;
                  data2_r       <= data_in;
                  comm_d2_r     <= comm_in;
                  assert dbg_level < 2 report "Write_D : target full, re = 1, av_f = ?, av_hibi = 0, retransmit 2" severity note;
                else
                  -- Addr on the bus
                  retx_amount_r <= 1;
                  data1_r       <= data_in;
                  comm_d1_r     <= comm_in;
                  assert dbg_level < 2 report "Write_D : target full, re = 1, av_f = ?, av_hibi = 1, retransmit 1" severity note;
                end if;  --addr_valid_r

              end if;  -- av_from_fifo



            else
              -- 1b) FSM was not reading fifo
              -- => only one data (=data on the bus) has to retransferred
              retx_amount_r <= 1;
              assert dbg_level < 1 report "Write_D     : target full, retransmit 1. Correct??" severity note;
              assert addr_valid_r = '0' report "WriteD : Propably not correct, av_hibi = 1 - > re_tx_amount should be 0" severity warning;

            end if;  -- fifo_re

            
            
          elsif own_turn_ends = '1' then
            -- 2) Previous transfer success, but own turn ends
            -- One data can still be written but no new addr

            curr_state_r <= Write_Last_Data;
            addr_valid_r <= '0';
            lock_v       := '0';
            fifo_re_r    <= '0';
            assert dbg_level < 3 report "Write : Oma vuoro loppuu" severity note;

            -- Siirretaan viim data. Jos fifossa osoite seur, ei siirreta mit'n
            if av_in = '0' and empty_in = '0' then
              -- 2a) Data from coming fifo => write it to bus
              data_out <= data_in;
              comm_out <= comm_in;
            else
              -- 2b) Addr coming from fifo => write nothing
              data_out <= (others => '0');
              comm_out <= (others => '0');
            end if;

            --  Addr coming from fifo => store it into register
            if empty_in = '0' and av_in = '1' then
              addr1_r   <= data_in (addr_width_g -1 downto 0);  --03.02.05 
              comm_a1_r <= comm_in;
            end if;



          elsif cfg_re_g = 1 and cfg_read_complete_r = '0' then
            -- 3) Own turn continues, answer conf read. Finish the reading of fifo first.

            if (fifo_re_r = '1' and av_in = '0' and empty_in = '0') then
              -- 3a) FSM is reading fifo and data coming from fifo
              -- Transfer that data before answering conf read
              curr_state_r <= Write_Data;
              addr_valid_r <= '0';
              data_out     <= data_in;
              comm_out     <= comm_in;
              lock_v       := '1';
              fifo_re_r    <= '0';
              assert dbg_level < 3 report "Write : viim data ennen kuin => conf return addr" severity note;

            else
              -- 3b) Answer conf read
              curr_state_r                       <= Cfg_A;
              addr_valid_r                       <= '1';
              data_out                           <= (others => '0');  -- 01.03.05
              data_out (addr_width_g-1 downto 0) <= cfg_ret_addr_r;  -- 01.03.05
              -- data_out     <= a_ext (cfg_ret_addr_r, data_width_g);  --03.02.05cfg_ret_addr_r;
              comm_out                           <= write_command_c;  -- 03.02.05 "010";
              lock_v                             := '1';
              fifo_re_r                          <= '0';

              -- Store addr
              if empty_in = '0' and av_in = '1' then
                addr1_r   <= data_in (addr_width_g-1 downto 0);  -- 03.02.05
                comm_a1_r <= comm_in;
              end if;

              assert dbg_level < 3 report "Write => conf return addr" severity note;
            end if;  --(re=1&av=0) || (msg_Re=1&msg_av=0)

            

            
            
          else
            -- 4) Retransfer ready
            -- Answering conf read complete
            -- Own turn continues
            -- => Transfer data

            if empty_in = '0' and av_in = '1' and one_d_in = '1' then
              -- 4a) Stop writing, because only one addr left but no data
              curr_state_r <= Idle;
              lock_v       := '0';
              addr_valid_r <= '0';
              data_out     <= (others => '0');
              comm_out     <= (others => '0');
              fifo_re_r    <= '0';
              assert dbg_level < 3 report "Write (d) : Data loppu" severity note;
              -- 13.05.05 AK The read address have to be stored here! if re = '1'
              if fifo_re_r = '1' then
                addr1_r   <= data_in (addr_width_g -1 downto 0);
                comm_a1_r <= comm_in;  -- 25.02.2006 AK comm has to be stored also..
              end if;
              
            elsif av_in = '0' and one_d_in = '1' then
              -- 4b) One data left in the fifo, write it and stop
              curr_state_r <= Write_Last_Data;
              lock_v       := '0';
              addr_valid_r <= '0';
              data_out     <= data_in;
              comm_out     <= comm_in;
              fifo_re_r    <= '0';
              assert dbg_level < 3 report "Write (d) : Data loppumassa. Viim data kirj" severity note;
              

            else
              -- 4c)Continue writing data
              curr_state_r <= Write_Data;
              lock_v       := '1';
              data_out     <= data_in;
              comm_out     <= comm_in;
              fifo_re_r    <= '1';

              assert empty_in = '0' report "WriteD -> WriteD: empty_in=1. How can this continue?" severity warning;

              if empty_in = '0' and av_in = '1' then
                -- New addr coming from fifo
                -- Store it into addr_reg
                addr1_r      <= data_in (addr_width_g -1 downto 0);  -- 03.02.05
                comm_a1_r    <= comm_in;
                addr_valid_r <= '1';
              else
                -- Data coming from fifo, addr_reg keeps its old value
                addr_valid_r <= '0';
              end if;
            end if;  -- empty & av & one_d            

          end if;  -- full_in
          -- State Write_Data ends here----------------------------------------











          --++++++++++++++
        when Write_Last_Data =>
          -- Last cycle of own turn
          curr_state_r <= Idle;
          data_out     <= (others => '0');
          comm_out     <= (others => '0');
          addr_valid_r <= '0';
          lock_v       := '0';
          fifo_re_r    <= '0';


          if full_in = '0' then
            -- Last tranfer succeeded, nothing has to be retransferred
            retx_amount_r <= 0;

            assert dbg_level < 3 report "Write_D_Last : OK" severity note;
          else
            -- Last transfer did not succeed, have to try again on next turn
            -- Re=0 when coming here => only one data has to be retransferred
            retx_amount_r <= 1;         -- 17.01.03 oli 2;
            data1_r       <= data2_r;
            comm_d1_r     <= comm_d2_r;

            assert dbg_level < 2 report "Write_D_Last        : target full, retransmit 1" severity note;
            assert fifo_re_r = '0' report "W_last_D : re should be 0" severity warning;
          end if;


          --++++++++++++++
        when Error_State =>
          assert false report "INVALid STATE IN TX_CONTROL" severity error;
          curr_state_r <= Error_State;
          

        when others =>
          -- Do not write to bus
          lock_v       := '0';
          addr_valid_r <= '0';
          comm_out     <= (others => '0');
          data_out     <= (others => '0');
          fifo_re_r    <= '0';

      end case;

      if keep_slot_g = 1 then
        -- we keep the slot even if we have nothing to send
        lock_out <= lock_v or (curr_slot_own_in and not curr_slot_ends_in) or next_slot_own_in;
      else
        lock_out <= lock_v;
      end if;
      

    end if;  --rst_n
  end process Define_output;



  -- 5) PROC
  Count_Priorities : process (clk, rst_n)
  begin  -- process Count_Priorities
    if rst_n = '0' then                 -- asynchronous reset (active low)
      prior_counter_arb_r <= (others => '0');
      switch_arb_r        <= 0;
      arb_type_r          <= (others => '0');

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- Assign internal arb_type-register according to ctrl-signal coming from cfg_mem
      if arb_type_in = "00" then
        -- round-robin
        arb_type_r <= "00";
        
      elsif arb_type_in = "01" then
        -- priority, actually 01
        arb_type_r <= "01";

      elsif arb_type_in = "10" then
        -- prior+roundrob, "10"
        if switch_arb_r = switch_arb_c-1 then
          switch_arb_r <= 0;
          arb_type_r   <= "0" & not arb_type_r(0);  -- !!!! only when 2 types

          else
            switch_arb_r <= switch_arb_r+1;
          arb_type_r <= arb_type_r;
        end if;
        
      else
        arb_type_r <= "11";        
      end if;                           -- arb_type_in


      -- Update priority_counter according to current arb_type
      if lock_in = '0' and arb_type_r /= "11" then
        -- Bus is idle
        
        if prior_counter_arb_r = n_agents_in (id_width_g-1 downto 0) then
          -- Priorities start from 1 (zero is not allowed)
          prior_counter_arb_r <= conv_std_logic_vector (1, id_width_g);
        else
          -- Bus idle, increase current priority
          prior_counter_arb_r <= prior_counter_arb_r +1;
        end if;

        
      else
        -- real arbitration types. now only prior + round rob
        if arb_type_r = "00" then
          -- round-robin
          -- Bus reserved, priority remains the same
          prior_counter_arb_r <= prior_counter_arb_r;

        elsif arb_type_r = "01" then
          -- priority, actually 01
          prior_counter_arb_r <= conv_std_logic_vector (1, id_width_g);

        else
          -- "lottery"
          -- counter is assigned below in separate process (inside if-generate)
          --          prior_counter_arb_r <= arb_agent_r;
        end if;
        
      end if;                           -- lock & arb_type
    end if;  --rst_n      

  end process Count_Priorities;

  dyn : if dyn_arb_enable_c = 1 generate
    dyn_arb_1 : dyn_arb
      generic map (
        id_width_g => id_width_g,
--        n_agents_g => 22 --6
        n_agents_g => n_agents_g        -- 2009-04-08
        )                --signaali!
      port map (
        clk           => clk,
        rst_n         => rst_n,
        bus_lock_in   => lock_in,
        arb_agent_out => dyn_arb_prior
        );
    
    assign_priocount: process (dyn_arb_prior, arb_type_in, prior_counter_arb_r)
    begin  -- process assign priocount
      if arb_type_in = "11" then
        prior_counter_r <= dyn_arb_prior;
      else
        prior_counter_r <= prior_counter_arb_r;                
      end if;  
    end process assign_priocount;    
  end generate dyn;
  
  notdyn: if dyn_arb_enable_c /= 1 generate
    assert arb_type_in /= "11" report "ERROR! ARB TYPE RANDOM BUT DYN ARB ENABLE = 0" severity failure;
    prior_counter_r <= prior_counter_arb_r;
  end generate notdyn;

end rtl;




