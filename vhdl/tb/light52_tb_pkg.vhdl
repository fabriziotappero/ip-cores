
library ieee,modelsim_lib;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.light52_pkg.all;

use modelsim_lib.util.all;
use std.textio.all;
use work.txt_util.all;

package light52_tb_pkg is

-- Maximum line size of for console output log. Lines longer than this will be
-- truncated.
constant CONSOLE_LOG_LINE_SIZE : integer := 1024*4;

type t_addr_array is array(0 to 1) of t_address;
constant BRAM_ADDR_LEN : integer := log2(BRAM_SIZE);
subtype t_bram_addr is unsigned(BRAM_ADDR_LEN-1 downto 0);


type t_opcode_cycle_count is record
    min :                   natural;    -- Minimum observed cycle count
    max :                   natural;    -- Maximum observed cycle count
    exe :                   natural;    -- No. times the opcode was executed
end record t_opcode_cycle_count;

type t_cycle_count is array(0 to 255) of t_opcode_cycle_count;

type t_log_info is record
    acc_input :             t_byte;
    load_acc :              std_logic;
    a_reg_prev :            t_byte;
    update_sp :             std_logic;
    sp_reg_prev :           t_byte;
    sp :                    t_byte;
    rom_size :              natural;
    
    update_psw_flags :      std_logic_vector(1 downto 0);
    psw :                   t_byte;
    psw_prev :              t_byte;
    psw_update_addr :       t_address;
    
    inc_dptr :              std_logic;
    inc_dptr_prev :         std_logic;
    dptr :                  t_address;
    
    xdata_we :              std_logic;
    xdata_vma :             std_logic;
    xdata_addr :            t_address;
    xdata_wr :              t_byte;
    xdata_rd :              t_byte;
    
    code_addr :             t_address;
    pc :                    t_address;
    pc_prev :               t_address;
    next_pc :               t_address;
    pc_z :                  t_addr_array;
    ps :                    t_cpu_state;
    jump_condition :        std_logic;
    rel_jump_target :       t_address;
    
    bram_we :               std_logic;
    bram_wr_addr :          t_bram_addr;
    bram_wr_data_p0 :       t_byte;
    
    sfr_we :                std_logic;
    sfr_wr :                t_byte;
    sfr_addr :              t_byte;
    delayed_acc_log :       boolean;
    delayed_acc_value :     t_byte;
    
    -- Observed cycle count for all executed opcodes.
    cycles :                t_cycle_count;
    last_opcode :           std_logic_vector(7 downto 0);
    opcode :                std_logic_vector(7 downto 0);
    code_rd :               std_logic_vector(7 downto 0);
    cycle_count :           natural;
    
    -- Console log line buffer --------------------------------------
    con_line_buf :         string(1 to CONSOLE_LOG_LINE_SIZE);
    con_line_ix :          integer;
    
    -- Log trigger --------------------------------------------------
    -- Enable logging after fetching from a given address -----------
    log_trigger_address :   t_address;
    log_triggered :         boolean;

end record t_log_info;

function hstr(slv: unsigned) return string;

procedure log_cpu_status(
                signal info :   inout t_log_info;
                file l_file :   TEXT;
                file con_file : TEXT);

procedure log_cpu_activity(
                signal clk :    in std_logic;
                signal reset :  in std_logic;
                signal done :   in std_logic;   
                mcu :           string;
                signal info :   inout t_log_info; 
                rom_size :      natural;
                iname :         string;
                trigger_addr :  in t_address;
                file l_file :   TEXT;
                file con_file : TEXT);

-- Flush console output to log console file (in case the end of the
-- simulation caught an unterminated line in the buffer)
procedure log_flush_console(
                signal info :   in t_log_info;
                file con_file : TEXT);

-- Log cycle count data to file.
procedure log_cycle_counts(
                signal info :   in t_log_info);
                
end package;

package body light52_tb_pkg is

function hstr(slv: unsigned) return string is
begin
    return hstr(std_logic_vector(slv));
end function hstr;


procedure log_cpu_status(
                signal info :   inout t_log_info;
                file l_file :   TEXT;
                file con_file : TEXT) is
variable bram_wr_addr : unsigned(7 downto 0);
variable opc : natural;
variable num_cycles : natural;
variable jump_logged : boolean := false;
begin
    
    jump_logged := false;

    -- Update the opcode observed cycle counters.
    -- For every opcode, we count the cycles from its decode_0 state to the 
    -- next fetch_1 state. To this we have to add 2 (one each for states 
    -- decode_0 and fetch_1) and we have the cycle count.
    -- we store the min and the max because of conditional jumps.
    if (info.ps=decode_0) then
        info.opcode <= info.last_opcode;
        info.cycle_count <= 0;
    else
        if (info.ps=fetch_1) then
            -- In state fetch_1, get the opcode from the bus
            info.last_opcode <= info.code_rd;
            
            if info.opcode/="UUUUUUUU" then
                opc := to_integer(unsigned(info.opcode));
                num_cycles := info.cycle_count + 2;
                if info.cycles(opc).min > num_cycles then
                    info.cycles(opc).min <= num_cycles;
                end if;
                if info.cycles(opc).max < num_cycles then
                    info.cycles(opc).max <= num_cycles;
                end if;
                info.cycles(opc).exe <= info.cycles(opc).exe + 1;
            end if;
        end if;
        info.cycle_count <= info.cycle_count + 1;
    end if;
    
    
    bram_wr_addr := info.bram_wr_addr(7 downto 0);

    -- Log writes to IDATA BRAM
    if info.bram_we='1' then
        print(l_file, "("& hstr(info.pc)& ") ["& hstr(bram_wr_addr) & "] = "&
              hstr(info.bram_wr_data_p0) );
    end if;
    
    -- Log writes to SFRs
    if info.sfr_we = '1' then
        print(l_file, "("& hstr(info.pc)& ") SFR["& 
              hstr(info.sfr_addr)& "] = "& hstr(info.sfr_wr));
    end if;
     
    -- Log jumps 
    -- FIXME remove internal state dependency
    --if info.ps = jrb_bit_3 and info.jump_condition='1' then
        -- Catch attempts to jump to addresses out of the ROM bounds -- assume
        -- mirroring is not expected to be useful in this case.
        -- Note it remains possible to just run into uninitialized ROM areas
        -- or out of ROM bounds, we're not checking any of that.
        --assert info.next_pc < info.rom_size
        --report "Jump to unmapped code address "& hstr(info.next_pc)& 
        --       "h at "& hstr(info.pc)& "h. Simulation stopped."
        --severity failure;
        
    --    print(l_file, "("& hstr(info.pc)& ") PC = "& 
    --        hstr(info.rel_jump_target) );
    --end if;
     
    -- Log ACC updates.
    -- Note we exclude the 'intermediate update' of ACC in DA instruction, and
    -- we have to deal with another tricky special case: 
    -- the JBC instruction needs the ACC change log delayed so that it appears 
    -- after the PC change log -- a nasty hack meant to avoid a nastier hack
    -- in the SW simulator logging code.
    if (info.load_acc='1' and info.ps/=alu_daa_0) then
        if info.a_reg_prev /= info.acc_input then
            if info.ps = jrb_bit_2 then -- this state is only used in JBC
                info.delayed_acc_log <= true;
                info.delayed_acc_value <= info.acc_input;
            else
                print(l_file, "("& hstr(info.pc)& ") A = "& 
                    hstr(info.acc_input) );
            end if;
         end if;
        info.a_reg_prev <= info.acc_input;
    end if;

    -- Log XRAM writes
    if (info.xdata_we='1') then
         print(l_file, "("& hstr(info.pc)& ") <"&
                hstr(info.xdata_addr)& "> = "& 
                hstr(info.xdata_wr) );
    end if;    
    
    -- Log SP explicit and implicit updates.
    -- At the beginning of each instruction we log the SP change if there is 
    -- any. SP changes at different times for different instructions. This way,
    -- the log is always done at the end of the instruction execution, as is
    -- done in B51.
    if (info.ps=fetch_1) then
        if info.sp_reg_prev /= info.sp then
            print(l_file, "("& hstr(info.pc)& ") SP = "& 
                hstr(info.sp) );
         end if;
        info.sp_reg_prev <= info.sp;
    end if;
    
    -- Log DPTR increments
    if (info.inc_dptr_prev='1') then
         print(l_file, "("& hstr(info.pc)& ") DPTR = "& 
               hstr(info.dptr) );
    end if;    
    info.inc_dptr_prev <= info.inc_dptr;
   
    -- Console logging ---------------------------------------------------------
    -- TX data may come from the high or low byte (opcodes.s
    -- uses high byte, no_op.c uses low)
    if info.sfr_we = '1' and info.sfr_addr = X"99" then
    
        -- UART TX data goes to output after a bit of line-buffering
        -- and editing
        if info.sfr_wr = X"0A" then
            -- CR received: print output string and clear it
            print(con_file, info.con_line_buf(1 to info.con_line_ix));
            info.con_line_ix <= 1;
            info.con_line_buf <= (others => ' ');
        elsif info.sfr_wr = X"0D" then
            -- ignore LF
        else
            -- append char to output string
            if info.con_line_ix < info.con_line_buf'high then
                info.con_line_buf(info.con_line_ix) <= 
                        character'val(to_integer(info.sfr_wr));
                info.con_line_ix <= info.con_line_ix + 1;
                --print(str(info.con_line_ix));
            end if;
        end if;
    end if;    
    
    -- Log jumps 
    -- FIXME remove internal state dependency
    if info.ps = long_jump or 
       info.ps = lcall_4 or 
       info.ps = jmp_adptr_0 or
       info.ps = ret_3 or
       info.ps = rel_jump or 
       info.ps = cjne_a_imm_2 or
       info.ps = cjne_rn_imm_3 or
       info.ps = cjne_ri_imm_5 or
       info.ps = cjne_a_dir_3 or
       info.ps = jrb_bit_4 or
       info.ps = djnz_dir_4
       then
        -- Catch attempts to jump to addresses out of the ROM bounds -- assume
        -- mirroring is not expected to be useful in this case.
        -- Note it remains possible to just run into uninitialized ROM areas
        -- or out of ROM bounds, we're not checking any of that.
        assert info.next_pc < info.rom_size
        report "Jump to unmapped code address "& hstr(info.next_pc)& 
               "h at "& hstr(info.pc)& "h. Simulation stopped."
        severity failure;
        
        print(l_file, "("& hstr(info.pc)& ") PC = "& 
            hstr(info.next_pc) );
        jump_logged := true;
    end if;

    -- If this instruction needs the ACC change log delayed, display it now 
    -- but only if the PC change has been already logged.
    -- This only happens in instructions that jump AND can modify ACC: JBC.
    -- The PSW change, if any, is delayed too, see below.
    if info.delayed_acc_log and jump_logged then
        print(l_file, "("& hstr(info.pc)& ") A = "& 
            hstr(info.delayed_acc_value) );
        info.delayed_acc_log <= false;
    end if;
    
    -- Log PSW implicit updates: first, whenever the PSW is updated, save the PC
    -- for later reference...
    if (info.update_psw_flags(0)='1' or info.load_acc='1') then
        info.psw_update_addr <= info.pc;
    end if;    
    -- ...then, when the PSW change is actually detected, log it along with the
    -- PC value we saved before.
    -- The PSW changes late in the instruction cycle and we need this trick to
    -- keep the logs ordered.
    -- Note that if the ACC log is delayed, the PSW log is delayed too!
    if (info.psw) /= (info.psw_prev) and not info.delayed_acc_log then
        print(l_file, "("& hstr(info.psw_update_addr)& ") PSW = "& hstr(info.psw) );
        info.psw_prev <= info.psw;
    end if;
   
    -- Stop the simulation if we find an unconditional, one-instruction endless
    -- loop. This will not catch multi-instruction endless loops and is only
    -- intended to replicate the behavior of B51 and give the SW a means to 
    -- cleanly end the simulation.
    -- FIXME use some jump signal, not a single state
    if info.ps = long_jump and (info.pc = info.next_pc) then
        -- Before quitting, optionally log cycle count table to separate file.
        log_cycle_counts(info);
        
        assert false
        report "NONE. Endless loop encountered. Simulation terminated."
        severity failure;
    end if;
   
    -- Update the address of the current instruction.
    -- The easiest way to know the address of the current instruction is to look
    -- at the state machine; when in state decode_0, we know that the opcode
    -- address was on code_addr bus two cycles earlier.
    -- We don't need to track the PC value cycle by cycle, we only need info.pc
    -- to be valid when the logs above are executed, and that's always after
    -- state decode_0.
    info.pc_z(1) <= info.pc_z(0);
    info.pc_z(0) <= info.code_addr;
    if info.ps = decode_0 then
        info.pc_prev <= info.pc;
        info.pc <= info.pc_z(1);
    end if;

end procedure log_cpu_status;

procedure log_cpu_activity(
                signal clk :    in std_logic;
                signal reset :  in std_logic;
                signal done :   in std_logic;   
                mcu :           string;
                signal info :   inout t_log_info; 
                rom_size :      natural;
                iname :         string;
                trigger_addr :  in t_address;
                file l_file :   TEXT;
                file con_file : TEXT) is

begin
    
    -- 'Connect' all the internal signals we want to watch to members of 
    -- the info record.
    init_signal_spy(mcu& "/cpu/alu/"&"acc_input",iname&".acc_input", 0);
    init_signal_spy(mcu& "/cpu/alu/"&"load_acc", iname&".load_acc", 0);
    init_signal_spy(mcu& "/cpu/update_sp",       iname&".update_sp", 0);
    init_signal_spy(mcu& "/cpu/SP_reg",          iname&".sp", 0);
    init_signal_spy(mcu& "/cpu/"&"psw",          iname&".psw", 0);
    init_signal_spy(mcu& "/cpu/"&"update_psw_flags",iname&".update_psw_flags(0)", 0);
    init_signal_spy(mcu& "/cpu/"&"code_addr",    iname&".code_addr", 0);
    init_signal_spy(mcu& "/cpu/"&"ps",           iname&".ps", 0);
    init_signal_spy(mcu& "/cpu/"&"jump_condition", iname&".jump_condition", 0);
    init_signal_spy(mcu& "/cpu/"&"rel_jump_target", iname&".rel_jump_target", 0);
    init_signal_spy(mcu& "/cpu/"&"bram_we",      iname&".bram_we", 0);
    init_signal_spy(mcu& "/cpu/"&"bram_addr_p0", iname&".bram_wr_addr", 0);
    init_signal_spy(mcu& "/cpu/"&"bram_wr_data_p0",  iname&".bram_wr_data_p0", 0);
    init_signal_spy(mcu& "/cpu/"&"next_pc",      iname&".next_pc", 0);
    init_signal_spy(mcu& "/cpu/"&"sfr_we",       iname&".sfr_we", 0);
    init_signal_spy(mcu& "/cpu/"&"sfr_wr",       iname&".sfr_wr", 0);
    init_signal_spy(mcu& "/cpu/"&"sfr_addr",     iname&".sfr_addr", 0);
    init_signal_spy(mcu& "/cpu/"&"inc_dptr",     iname&".inc_dptr", 0);
    init_signal_spy(mcu& "/cpu/"&"DPTR_reg",     iname&".dptr", 0);
    init_signal_spy(mcu& "/"&"xdata_we",         iname&".xdata_we", 0);
    init_signal_spy(mcu& "/"&"xdata_vma",        iname&".xdata_vma", 0);
    init_signal_spy(mcu& "/"&"xdata_addr",       iname&".xdata_addr", 0);
    init_signal_spy(mcu& "/"&"xdata_wr",         iname&".xdata_wr", 0);
    init_signal_spy(mcu& "/cpu/"&"code_rd",      iname&".code_rd", 0);
    
    -- We force both 'rdy' uart outputs to speed up the simulation (since the
    -- UART operation is not simulated by B51, just logged).
    signal_force(mcu&"/uart/rx_rdy_flag", "1", 0 ms, freeze, -1 ms, 0);
    signal_force(mcu&"/uart/tx_busy", "0", 0 ms, freeze, -1 ms, 0);
    -- And we force the UART RX data to a predictable value until we implement
    -- UART RX simulation in the B51 simulator, eventually.
    signal_force(mcu&"/uart/rx_buffer", "00000000", 0 ms, freeze, -1 ms, 0);

    
    -- Initialize the console log line buffer...
    info.con_line_buf <= (others => ' ');
    -- ...and take note of the ROM size 
    -- FIXME this should not be necessary, we know the array size already.
    info.rom_size <= rom_size;

    -- Initialize the observed cycle counting logic...
    info.cycles <= (others => (999,0,0));
    info.cycle_count <= 0;
    info.last_opcode <= "UUUUUUUU";
    info.delayed_acc_log <= false;
    
    -- ...and we're ready to start monitoring the system
    while done='0' loop
        wait until clk'event and clk='1';
        if reset='1' then
            -- Initialize some aux vars so as to avoid spurious 'diffs' upon
            -- reset.
            info.pc <= X"0000";
            info.psw_prev <= X"00";
            info.sp_reg_prev <= X"07";
            info.a_reg_prev <= X"00";
            
            -- Logging must be enabled from outside by setting 
            -- log_trigger_address to a suitable value.
            info.log_trigger_address <= trigger_addr;
            info.log_triggered <= false;
            
            info.con_line_ix <= 1; -- uart log line buffer is empty
        else
            log_cpu_status(info, l_file, con_file);
        end if;
    end loop;
    
    -- Once finished, optionally log the cycle count table to a separate file.
    log_cycle_counts(info);

end procedure log_cpu_activity;



procedure log_flush_console(
                signal info :   in t_log_info;
                file con_file : TEXT) is
variable l : line;
begin
    -- If there's any character in the line buffer...
    if info.con_line_ix > 1 then
        -- ...then write the line buffer to the console log file.
        write(l, info.con_line_buf(1 to info.con_line_ix));
        writeline(con_file, l);
    end if;    
end procedure log_flush_console;

procedure log_cycle_counts(
                signal info :   in t_log_info) is
variable cc : t_opcode_cycle_count;
variable opc : natural;
file log_cycles_file: TEXT open write_mode is "cycle_count_log.csv";
begin
    
    for row in 0 to 15 loop
        for col in 0 to 15 loop 
            opc := col*16 + row;
            cc := info.cycles(opc);
            print(log_cycles_file,
                  ""& hstr(to_unsigned(opc,8))& ","& 
                  str(cc.min)& ","& str(cc.max)& ","& str(cc.exe));
        end loop;
    end loop;

end procedure log_cycle_counts;


end package body;
