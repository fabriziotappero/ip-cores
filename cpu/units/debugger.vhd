------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      debugger
--
-- PURPOSE:     debugger for clvp
--              controls cpu via rs232
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity debugger is
    port ( 
        clk_in: in std_logic;           -- use 50mhz for rs232 timing
        
        clk_cpu: out std_logic;         
        clk_mem: out std_logic;
        
        reset_out: out std_logic;
                
        rs232_txd: out std_logic; 
        rs232_rxd: in std_logic;
        
        a: in std_logic_vector(31 downto 0);
        x: in std_logic_vector(31 downto 0);
        y: in std_logic_vector(31 downto 0);
        
        ir: in std_logic_vector(31 downto 0);
        ic: in std_logic_vector(31 downto 0);
        
        mem_switch: out std_logic;
        mem_ready: in std_logic;
        
        mem_access: in std_logic_vector(2 downto 0);
        mem_access_dbg: out std_logic_vector(2 downto 0);
        
        mem_addr: in std_logic_vector(31 downto 0);
        mem_addr_dbg: out std_logic_vector(31 downto 0);
        
        mem_data: in std_logic_vector(31 downto 0);
        mem_data_dbg: out std_logic_vector(31 downto 0);
        
        carry: in std_logic;
        zero: in std_logic;
        ir_ready: in std_logic;
        halted: in std_logic
    );
end debugger;

architecture rtl of debugger is 
    component rs232 -- code from michael schäferling
        generic(	 DATABITS:  integer:= 8;
                     STARTBITS: integer:= 1;
                     STOPBITS:  integer:= 1
        );
        port(	CLK_50MHZ	 : in  std_logic;
                RS232_RXD	 : in  std_logic;
                RS232_TXD	 : out std_logic;
    
                DATA_TX		 : in  std_logic_vector(DATABITS-1 downto 0);
                TX_SEND_DATA : in  std_logic;
                TX_BUSY		 : out std_logic;
    
                DATA_RX		 : out std_logic_vector(DATABITS-1 downto 0);
                RX_DATA_RCVD : out std_logic;
                RX_BUSY		 : out std_logic
        );
    end component;
    
    component bufg 
        port (
            i: in  std_logic;  
            o: out std_logic
        ); 
    end component; 
    
    
    for rs232_impl: rs232 use entity work.rs232(Behavioral);
    
    signal data_tx: std_logic_vector(7 downto 0);
    signal data_rx: std_logic_vector(7 downto 0);
    signal tx_busy: std_logic;
    signal rx_busy: std_logic;
    signal data_received: std_logic;
    signal send_data: std_logic;
    
    signal clk_buffer_cpu, clk_buffer_mem: std_logic;
    
    -- statemachine debugger
    type statetype is (waiting, decode, clock, reset1, reset2, flags, rega, regx,
                       regy, regir, regic, busy8, init8, sending8, busy32, init32, sending32, inc32, echo,
                       ma, md, go, pause, to_fetch_address, to_fetch_data, fetch_address, fetch_data, to_normal,
                       mem_read1, mem_read2, mem_read3,mem_read4, mem_write1, mem_write2, mem_write3, mem_write4,
                       mem_restore1, mem_restore2, mem_restore3, mem_restore4, send_checksum, startcc, stopcc,
                       ccstatus, getcc);
    
    signal state : statetype := waiting;
    signal nextstate : statetype := waiting;   
    
    -- statemachine clock logic
    type clocktype is (high, low, freehigh, freelow, memorylow, memoryhigh, ccountstart, ccountlow, ccounthigh);
    signal clockstate : clocktype := low;
    signal nextclockstate : clocktype := low;

    signal counter : std_logic_vector(1 downto 0) := "00";
    signal inc: std_logic;
    
    signal clockcounter : std_logic_vector(31 downto 0) := (others => '0');
    signal clockcounter_inc, clockcounter_res : std_logic;
    
    signal in_buffer: std_logic_vector(31 downto 0);
    signal out_buffer: std_logic_vector(31 downto 0) := (others => '0');
    
    signal ar: std_logic_vector(31 downto 0) := (others => '0');
    signal ar_shift: std_logic;
    
    signal dr: std_logic_vector(31 downto 0) := (others => '0'); 
    signal dr_shift: std_logic;
    
    signal load, load_mem_data: std_logic;
    signal tofree, todebug, tomemory, clocktick : std_logic;
    signal startclockcount, stopclockcount, clockcountstatus : std_logic;
    
    signal status: std_logic_vector(1 downto 0) := (others => '0');
    signal st_input: std_logic_vector(1 downto 0);
    signal st_set: std_logic;
    
    signal checksum : std_logic_vector(7 downto 0);
  
begin
    rs232_impl: rs232
        generic map (DATABITS => 8, STARTBITS => 1, STOPBITS => 1)
        port map (
            CLK_50MHZ => clk_in, RS232_RXD => rs232_rxd, RS232_TXD => rs232_txd,
            DATA_TX => data_tx, TX_SEND_DATA => send_data, TX_BUSY => tx_busy,
            DATA_RX => data_rx, RX_DATA_RCVD => data_received, RX_BUSY => rx_busy
        );
    
    gbuf_for_clk_cpu: bufg
        port map (
            i => clk_buffer_cpu,
            o => clk_cpu
        ); 
    
    gbuf_for_clk_mem: bufg
        port map (
            i => clk_buffer_mem,
            o => clk_mem
        ); 
    
    
    -- counter
    process
    begin
        wait until clk_in='1' and clk_in'event;
        counter <= counter;
        clockcounter <= clockcounter;
        
        if inc = '1' then
            counter <= counter + '1';
        end if;
        
        if clockcounter_inc = '1' then
            clockcounter <= clockcounter +1;
        else
            if clockcounter_res = '1' then
                clockcounter <= (others => '0');
            end if;
        end if;

    end process;
        
    -- register
    process 
    begin
        wait until clk_in='1' and clk_in'event;
        
        out_buffer <= out_buffer;
        status <= status;
        
        ar <= ar;
        dr <= dr;
        
        
        if load = '1' then
            out_buffer <= in_buffer;
        else
            if load_mem_data = '1' then
                out_buffer <= mem_data;
            end if;
        end if;
        
        if ar_shift = '1' then
            ar(31 downto 8) <= ar(23 downto 0);
            ar(7 downto 0) <= data_rx;
        end if;
        
        if dr_shift = '1' then
            dr(31 downto 8) <= dr(23 downto 0);
            dr(7 downto 0) <= data_rx;
        end if;
        
        if st_set = '1' then
            status <= st_input;
        end if;
        
    end process;
    
    mem_addr_dbg <= ar;
    mem_data_dbg <= dr;
    checksum <= out_buffer(31 downto 24) xor out_buffer(23 downto 16) 
                xor out_buffer(15 downto 8) xor out_buffer(7 downto 0);
    
    -- state register
    process
    begin
        wait until clk_in='1' and clk_in'event;
        state <= nextstate;
        clockstate <= nextclockstate;
    
    end process;
    
    -- clock state machine
    process (clockstate, tofree, todebug, tomemory, clocktick, clockcounter_inc, clockcounter_res, clockcounter, ic,
             startclockcount, stopclockcount, ar)
    begin
        -- avoid latches
        clk_buffer_cpu <= '0';
        clk_buffer_mem <= '0';
        clockcountstatus <= '1';
        clockcounter_inc <= '0';
        clockcounter_res <= '0';
        
        case clockstate is
            -- CLOCK COUNTING STATES --
            when ccountstart =>             -- start clock counting
                clockcounter_inc <= '0';
                clockcounter_res <= '1';
                clockcountstatus <= '0';
                nextclockstate <= ccountlow;
        
            when ccountlow =>               -- generate clock low signal
                clockcountstatus <= '0';
                clk_buffer_cpu <= '0';
                clk_buffer_mem <= '0';
                
                if stopclockcount = '1' then 
                    nextclockstate <= low;
                else
                    if ic = ar then -- stop when instruction counter value matches given address
                        nextclockstate <= low;
                    else
                        nextclockstate <= ccounthigh;
                    end if;
                end if;
 
        
            when ccounthigh =>              -- generate clock high signal
                clockcountstatus <= '0';
                clockcounter_inc <= '1';
                clk_buffer_cpu <= '1';
                clk_buffer_mem <= '1';
                
                if stopclockcount = '1' then 
                    nextclockstate <= low;
                else
                    nextclockstate <= ccountlow;
                end if;
            
            -- DEBUG MODE STATES --
            when low =>                     -- generate clock low signal
                clk_buffer_cpu <= '0';
                clk_buffer_mem <= '0';
                
                 if startclockcount = '1' then -- only allow to start clockcount from debug mode
                    nextclockstate <= ccountstart;
                 else
                    if tomemory = '1' then
                        nextclockstate <= memorylow;
                    else
                        if tofree = '1' then
                            nextclockstate <= freelow;
                        else
                            if clocktick = '1' then
                                nextclockstate <= high;
                            else
                                nextclockstate <= low;
                            end if;
                        end if;
                    end if;
                 end if;
            
            when high =>                    -- generate clock high signal
                clk_buffer_cpu <= '1';
                clk_buffer_mem <= '1';
                
                if tomemory = '1' then
                    nextclockstate <= memorylow;
                else
                    if tofree = '1' then
                        nextclockstate <= freelow;
                    else
                        nextclockstate <= low;
                    end if;
                end if;
                
            
            -- FREE RUNNING MODE STATES --
            when freelow =>                 -- generate clock low signal
                clk_buffer_cpu <= '0';  
                clk_buffer_mem <= '0';
                
                if tomemory = '1' then
                    nextclockstate <= memorylow;
                else
                    if todebug = '1' then
                        nextclockstate <= low;
                    else
                        nextclockstate <= freehigh;
                    end if;    
                end if;
                
                     
            when freehigh =>                -- generate clock high signal
                clk_buffer_cpu <= '1';
                clk_buffer_mem <= '1';
                
                if tomemory = '1' then
                    nextclockstate <= memorylow;
                else
                    if todebug = '1' then
                        nextclockstate <= low;
                    else
                        nextclockstate <= freelow;
                    end if;       
                end if;
            
            
            -- CLOCK MEMORY ONLY STATES --
            when memorylow =>               -- generate memory clock low signal
                clk_buffer_mem <= '0';
                
                if todebug = '1' then
                    nextclockstate <= low;
                else
                    nextclockstate <= memoryhigh;
                end if; 
            
            when memoryhigh =>              -- generate memory clock high signal
                clk_buffer_mem <= '1';
                
                if todebug = '1' then
                    nextclockstate <= low;
                else
                    nextclockstate <= memorylow;
                end if; 
            
        end case;
    end process;
    
    -- debugger state machine
    process (clk_in, data_rx, a, x, y, ir, ic, carry, zero, ir_ready, tx_busy, data_received, counter,
             state, out_buffer, mem_addr, mem_data, mem_access, mem_ready, halted, status, checksum,
             clockcountstatus, clockcounter )
    begin
        -- avoid latches 
        reset_out <= '0';
        send_data <= '0';
        data_tx <= (others => '0');
        in_buffer <= (others => '0');
        nextstate <= waiting;
        inc <= '0';
        load <= '0';
        
        tofree <= '0';     
        todebug <= '0';
        tomemory <= '0';
        clocktick <= '0';
        
        ar_shift <= '0';
        dr_shift <= '0';
        
        st_input <= (others => '0');
        st_set <= '0';
        
        mem_switch <= '0';
        mem_access_dbg <= "000";
        load_mem_data <= '0';
        
        startclockcount <= '0';
        stopclockcount <= '0';
        
        case state is
            -- WAIT FOR COMMANDS / DATA --
            when waiting =>
                if data_received = '1' then 
                    nextstate <= decode;
                else
                    nextstate <= waiting;
                end if;
            
            -- DECODE STATE --
            when decode =>
                case status is
                    when "00" =>  -- normal modus
                        case data_rx is
                            when "01100011" | "01000011" => -- c/C = clock
                                nextstate <= clock;
                            
                            when "01110010" | "01010010" => -- r/R = reset
                                nextstate <= reset1;
                                
                            when "01100110" | "01000110" => -- f/F = flags
                                nextstate <= flags;
                                
                            when "01100001" | "01000001" => -- a/A = register a
                                nextstate <= rega;
                                
                            when "01111000" | "01011000" => -- x/X = register x
                                nextstate <= regx;
                            
                            when "01111001" | "01011001" => -- y/Y = register y
                                nextstate <= regy;
                            
                            when "01101001" | "01001001" => -- i/I = instruction register
                                nextstate <= regir;
                                
                            when "01101010" | "01001010" => -- j/J = instruction counter
                                nextstate <= regic;
                            
                            when "01101101" | "01001101" => -- m/M = memory data
                                nextstate <= md;
                                
                            when "01101110" | "01001110" => -- n/N = memory address
                                nextstate <= ma;
                                        
                            when "01100111" | "01000111" => -- g/G = enter free-running-mode
                                nextstate <= go;
                                  
                            when "01110000" | "01010000" => -- p/P = leave free-running-mode
                                nextstate <= pause;
                                
                            when "00110000" =>              -- 0 = fetch address
                                nextstate <= to_fetch_address;
                                
                            when "00110001" =>              -- 1 = fetch data
                                nextstate <= to_fetch_data;
                            
                            when "00110010" =>              -- 2 = read from memory
                                nextstate <= mem_read1;
                            
                            when "00110011" =>              -- 3 = write to memory
                                nextstate <= mem_write1;
                                
                            when "00110100" =>              -- 4 = enter clock count mode
                                nextstate <= startcc;
                            
                            when "00110101" =>              -- 5 = stop clock count mode
                                nextstate <= stopcc;
                                
                            when "00110110" =>              -- 6 = clock count status
                                nextstate <= ccstatus;
                                
                            when "00110111" =>              -- 7 = get clock counter
                                nextstate <= getcc;
                            
                            when others =>                  -- unknown command, echo
                                nextstate <= echo;
                        end case;
                    
                    when "01" =>  -- receiving memory write command
                        nextstate <= fetch_address;
                    
                    when "10" =>  -- receiving memory read command
                        nextstate <= fetch_data;
                        
                    when others =>
                        nextstate <= to_normal;
                        
                end case;
            
            -- CLOCKCOUNTER STATS --
            when startcc =>                     -- start clock counter
                startclockcount <= '1';
                nextstate <= echo;
            
            when stopcc =>                      -- stop clock counter
                stopclockcount <= '1';
                nextstate <= echo;
                
            when ccstatus =>                    -- get status of clock counter
                in_buffer(7 downto 1) <= (others => '0');
                in_buffer(0) <= clockcountstatus;
                load <= '1';
                nextstate <= busy8;
                
            when getcc =>                       -- get clockcounter value
                in_buffer(31 downto 0) <= clockcounter;  
                load <= '1';
                nextstate <= busy32;
            
            
            -- READ MEMORY STATES --
            when mem_read1 =>                   -- complete operation from cpu
                tomemory <= '1';
                if mem_ready = '0' then
                    nextstate <= mem_read1;
                else
                    nextstate <= mem_read2;
                end if;
                
            when mem_read2 =>                   -- switch from cpu to debugger control
                mem_switch <= '1';
                nextstate <= mem_read3; 
            
            when mem_read3 =>                   -- start operation
                mem_switch <= '1';
                mem_access_dbg <= "010";
                
                if mem_ready = '1' then
                    nextstate <= mem_read3;
                else
                    nextstate <= mem_read4;
                end if;
            
            when mem_read4 =>                   -- finish operation
                mem_switch <= '1';
                mem_access_dbg <= "010";
 
                load_mem_data <= '1';
                
                if mem_ready = '1' then
                    nextstate <= mem_restore1;
                else
                    nextstate <= mem_read4;
                end if;
                
                
            -- WRITE MEMORY STATES --
            when mem_write1 =>                   -- complete operation from cpu
                tomemory <= '1';
                
                if mem_ready = '0' then
                    nextstate <= mem_write1;
                else
                    nextstate <= mem_write2;
                end if;
                
            when mem_write2 =>                  -- switch from cpu to debugger control
                mem_switch <= '1';
                nextstate <= mem_write3;
                
                
            when mem_write3 =>                  -- start operation
                mem_switch <= '1';
                mem_access_dbg <= "100";
                
                if mem_ready = '0' then
                    nextstate <= mem_write4;
                else
                    nextstate <= mem_write3;
                end if;
                    
            when mem_write4 =>                  -- finish operation
                mem_switch <= '1';
                mem_access_dbg <= "100";
                
                if mem_ready = '1' then
                    nextstate <= mem_restore1;
                else
                    nextstate <= mem_write4;
                end if;
                
                
            --  RESTORE PREVIOUS MEMORY STATES --
            when mem_restore1 =>                -- switch from debugger to cpu control
                mem_switch <= '1';
                nextstate <= mem_restore2;
            
            when mem_restore2 =>
                nextstate <= mem_restore3;
            
            when mem_restore3 =>                -- wait for completition
                if mem_ready = '0' then
                    nextstate <= mem_restore3;
                else
                    nextstate <= mem_restore4;
                end if;

            when mem_restore4 =>                -- send back answer via rs232
                todebug <= '1';
                
                if data_rx = "00110010" then   
                    nextstate <= busy32;  -- read (send 32 bit data back)
                else
                    nextstate <= echo;  -- write (send ok back)      
                end if;
                
           
            -- FETCH ADDRESS VALUE --
            when fetch_address =>
                inc <= '1';
                ar_shift <= '1';
                
                if counter = "11" then
                    nextstate <= to_normal;
                else                
                    nextstate <= echo;
                end if;
                
            -- FETCH DATA VALUE --
            when fetch_data =>
                inc <= '1';
                dr_shift <= '1';
                
                if counter = "11" then
                    nextstate <= to_normal;
                else                
                    nextstate <= echo;
                end if;  
            
            -- SWITCH TO FETCH ADDRESS MODE --
            when to_fetch_address =>
                st_input <= "01";
                st_set <= '1';
                nextstate <= echo;
            
            -- SWITCH TO FETCH DATA MODE --
            when to_fetch_data =>
                st_input <= "10";
                st_set <= '1';
                nextstate <= echo;
            
            -- SWITCH TO NORMAL ADDRESS MODE --
            when to_normal =>
                st_input <= "00";
                st_set <= '1';
                nextstate <= echo;
                
            -- SWITCH OT FREE RUNNING MODE --
            when go =>
                tofree <= '1';
                nextstate <= echo;
            
            -- END FREE RUNNING MODE --
            when pause =>
                todebug <= '1';
                nextstate <= echo;
				
			-- GENERATE ONE CLOCKTICK --
            when clock =>
                clocktick <= '1';
                nextstate <= echo;
           
            -- RESET CPU --
            when reset1 =>
                reset_out <= '1';
                clocktick <= '1';
                nextstate <= reset2;
            
            when reset2 =>
                reset_out <= '1';
                nextstate <= echo;
                            
            -- SEND FLAGS --
            when flags =>
                in_buffer(7 downto 0) <= ir_ready & mem_ready & mem_access & halted & zero & carry;
                load <= '1';
                nextstate <= busy8;
                
            -- SEND AKKUMULATOR --
            when rega =>
                in_buffer(31 downto 0) <= a;
                load <= '1';
                nextstate <= busy32;
            
            -- SEND REGISTER X --
            when regx =>
                in_buffer(31 downto 0) <= x;  
                load <= '1';
                nextstate <= busy32;
            
            -- SEND REGISTER > --
            when regy =>
                in_buffer(31 downto 0) <= y;
                load <= '1';
                nextstate <= busy32;
            
            -- SEND INSTRUCTION REGISTER --
            when regir =>
                in_buffer(31 downto 0) <= ir;
                load <= '1';
                nextstate <= busy32;
            
            -- SEND INSTRUCTION COUNTER --
            when regic =>
                in_buffer(31 downto 0) <= ic;
                load <= '1';
                nextstate <= busy32;
            
            -- SEND MEMORY ADDRESS -- 
            when ma =>
                in_buffer(31 downto 0) <= mem_addr;
                load <= '1';
                nextstate <= busy32;
            
            -- SEND MEMORY DATA --
            when md =>
                in_buffer(31 downto 0) <= mem_data;
                load <= '1';
                nextstate <= busy32;
                
            -- SEND RECEIVED COMMAND BACK --
            when echo =>
                in_buffer(7 downto 0) <= data_rx;
                load <= '1';
                nextstate <= busy8;

            
            -- COMMON SENDING ROUTINES --
            when busy8 => 
                if tx_busy = '0' then
                    nextstate <= init8;
                else
                    nextstate <= busy8;
                end if;
            
            when init8 =>
                data_tx <= out_buffer(7 downto 0);
                send_data <= '1';
                
                if tx_busy = '1' then
                    nextstate <= sending8;
                else
                    nextstate <= init8;    
                end if;
            
            when sending8 =>
                if tx_busy = '0' then
                    nextstate <= waiting;
                else
                    nextstate <= sending8;
                end if;
                
            when busy32 => 
                if tx_busy = '0' then
                    nextstate <= init32;
                else
                    nextstate <= busy32;
                end if;
                
            when init32 =>
                case counter is
                    when "00" =>
                        data_tx <= out_buffer(7 downto 0);
                    when "01" =>
                        data_tx <= out_buffer(15 downto 8);
                    when "10" =>
                        data_tx <= out_buffer(23 downto 16);
                    when "11" =>
                        data_tx <= out_buffer(31 downto 24);
                    when others =>
                        data_tx <= (others => '0');
                end case;
                
                send_data <= '1';
                
                if tx_busy = '1' then
                    nextstate <= sending32;
                else
                    nextstate <= init32;    
                end if;
            
            when sending32 =>
                if tx_busy = '0' then
                    nextstate <= inc32;
                else
                    nextstate <= sending32;
                end if;
                
            when inc32 =>
                inc <= '1';
                
                if counter = "11" then
                    nextstate <= send_checksum;
                else
                    nextstate <= busy32;
                end if;
                
            -- send checksum for 32 bit data
            when send_checksum =>
                data_tx <= checksum;
                send_data <= '1';
                
                if tx_busy = '1' then
                    nextstate <= sending8;
                else
                    nextstate <= send_checksum;    
                end if;
                
        end case;
    end process;
end rtl;