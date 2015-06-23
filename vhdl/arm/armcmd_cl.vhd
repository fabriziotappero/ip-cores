-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.int.all;
use work.memdef.all;
use work.armdecode.all;
use work.armpctrl.all;
use work.armpmodel.all;
use work.armcmd.all;
use work.armcmd_comp.all;

entity armcmd_cl is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_cl_typ_in;
    o       : out armcmd_cl_typ_out
    );
end armcmd_cl;

architecture rtl of armcmd_cl is

  type armcmd_cl_state is (armcmd_cl_process,armcmd_cl_finish);
  type armcmd_cl_tmp_type is record
    o       : armcmd_cl_typ_out;
    off : std_logic_vector(23 downto 0);
    ctrlmemo : acm_ctrlmemout;
  end record;
  type armcmd_cl_reg_type is record
    state : armcmd_cl_state;
  end record;
  type armcmd_cl_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcmd_cl_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcmd_cl_reg_type;
  signal rdbg, cdbg : armcmd_cl_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armcmd_cl_reg_type;
    variable t    : armcmd_cl_tmp_type;
    variable vdbg : armcmd_cl_dbg_type;
  begin 
    
    -- $(init(t:armcmd_cl_tmp_type))
    
    v := r;
    t.o.ctrlo := i.ctrli.ctrlo;
    t.o.ctrlo.nextinsn := '0';

    case i.ctrli.cnt is
      
      when ACM_CNT_ZERO =>
        
        t.ctrlmemo.exop_data_src := apc_datasrc_aluout;
        if i.ctrli.insn.insn(ADE_LDC_STC_P_C) = '0' then
          t.ctrlmemo.exop_data_src := apc_datasrc_aluout;
        else
          t.ctrlmemo.exop_data_src := apc_datasrc_none;
        end if;
        
        -- [frame: ctrli.cnt=0] start address issue 
        --
        --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG     WRSTG          
        --      --+-----------+-----------+-----------+-----------+-----------+---------+          
        --  <rn>->+-----------+----------op1          |           |           |                   
        --        |           |           | \         |           |           |                   
        --        | (regread) |           | +(aluop)+ |  +(trans) | +>(dcache-+-++ (write)       
        --        |           |           | /   |     |  |   |    | |         | ||                
        --        |           | startoff-op2    |     |  |   |    | |         | |+->[copro]            
        --      --+-----------+-----------+-----+-----+--+---+----+-+---------+-+-------+
        --                                      |        |   |      |           |                   
        --          pctrl.data1 (as address):   +--------+   +------+           |                             
        --  cyceven:pctrl.me.param: o-------------------------------+           |                      
        --          pctrl.wr.rd(<nxtreg>):o-------------------------------------+

        t.ctrlmemo.rsop_op1_src := apc_opsrc_through;      -- route <rn> to exestg op1
        t.ctrlmemo.r1_src := acm_rrn;                      -- fetch <rn> (address base)
        t.ctrlmemo.rsop_op2_src := apc_opsrc_none;         -- route 0 to exestg op2
        t.ctrlmemo.data2 := (others => '0');               -- 0
        t.ctrlmemo.exop_data_src := apc_datasrc_aluout;    -- save aluresult (address in(de)cerement) as MESTG_address
        t.ctrlmemo.rd_src := acm_rdnone;

        t.ctrlmemo.meop_param.read  := '1';                -- MESTG: dcache inputs (readdata)
        t.ctrlmemo.meop_param.addrin  := '1';              -- MESTG: dcache inputs (tag cmp)
        t.ctrlmemo.meop_enable := '1';                     -- MESTG: dcache inputs
        
        if i.fromCP_busy = '1' then
          t.o.ctrlo.hold := '1';
        else
          if i.fromCP_last = '0' then
            v.state := armcmd_cl_process;
          else
            if i.ctrli.insn.insn(ADE_LDC_STC_WB_C) = '0' then
              t.o.ctrlo.nextinsn := '1';
            else
              v.state := armcmd_cl_finish;
            end if;
          end if;
        end if;

      when others =>

        if i.ctrli.cnt = ACM_CNT_ONE then
          t.ctrlmemo.rsop_buf1_src := apc_bufsrc_alures;    -- save <addr> for writeback
        end if;

        case r.state is
          when armcmd_cl_process => 
    
            -- [frame: ctrli.cnt!=0] address inc 
            --
            --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG           
            --      --+-----------+-----------+-----------+-----------+-----------+----------+           
            --        |           | (lastalu)op1          |           |           |
            --        |           |(alu)>[buf]| \         |           |           |
            --        | (regread) |           | +(aluop)  |  +(trans) | +>(dcache)+-++ (write)
            --        |           |           | /   |     |  |   |    | |         | ||
            --        |           |     inc--op2    |     |  |   |    | |         | |+->[copro]           
            --      --+-----------+-----------+-----+-----+--+---+----+-+---------+-+--------+           
            --                                      |        |   |      |           |                      
            --         pctrl.data1 (as address)  :  +--------+   +------+           |                      
            --  cyceven:pctrl.me.param: o-------------------------------+           |                      
            --          pctrl.wr.rd(<nxtreg>):o-------------------------------------+


            t.ctrlmemo.rsop_op1_src := apc_opsrc_alures;       -- route <lastalu> to exestg op1
            t.ctrlmemo.rsop_op2_src := apc_opsrc_none;         -- route 4 to exestg op2
            t.ctrlmemo.data2 := LIN_FOUR;                      -- 4
            t.ctrlmemo.exop_data_src := apc_datasrc_aluout;    -- save aluresult (address in(de)cerement) as MESTG_address
            t.ctrlmemo.rd_src := acm_rdlocal;                  -- write to rnext (MESTG result)
        
            t.ctrlmemo.meop_param.read  := '1';                -- MESTG: dcache inputs (readdata)
            t.ctrlmemo.meop_param.addrin  := '1';              -- MESTG: dcache inputs (tag cmp)
            t.ctrlmemo.meop_enable := '1';                     -- MESTG: dcache inputs
          
            if i.fromCP_last = '1' then
              if i.ctrli.insn.insn(ADE_LDC_STC_WB_C) = '0' then
                t.o.ctrlo.nextinsn := '1';
              else
                v.state := armcmd_cl_finish;
              end if;
            end if;
            
          when armcmd_cl_finish  =>
            
            t.o.ctrlo.nextinsn := '1';

            -- [frame:] update baseregister
            --  
            --            RRSTG       RSSTG       EXSTG       DMSTG       MESTG        WRSTG
            --      --+-----------+-----------+-----------+-----------+-----------+-----------
            --        |           | (lastalu)-+           |           |           |
            --        |           |           | \         |           |           |
            --        |           |           | +(aluop)  |           |  (dcache) | +>(write)
            --        |           |           | /   |     |           |           | |
            --        |           |      (0) -+     |     |           |           | |
            --      --+-----------+-----------+-----+-----+-----------+-----------+-+---------
            --                                      |                               |
            --        pctrl.data1 (as rddata):      +-------------------------------+
            --         pctrl.wr.rd (<rn>): o----------------------------------------+                           
            
            if i.ctrli.cnt = ACM_CNT_ONE then
              t.ctrlmemo.rsop_op1_src := apc_opsrc_alures;    -- route <lastalu> to exestg op1
            else
              t.ctrlmemo.rsop_op1_src := apc_opsrc_buf;       -- route <lastalu> to exestg op1
            end if;

            t.ctrlmemo.data2 := (others => '0');                       -- imm 0
            t.ctrlmemo.rsop_op2_src := apc_opsrc_none;     -- route 0 to exestg op2
            t.ctrlmemo.exop_data_src := apc_datasrc_aluout; -- save aluresult as WRSTG_data
            t.ctrlmemo.rd_src := acm_rdrrn;                                      -- <rn>
            
          when others => 
        end case;
                
    end case;
    
    -- reset
    if ( rst = '0' ) then
    end if;

    o <= t.o;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.dbg := t;
    cdbg <= vdbg;
    -- pragma translate_on  
    
  end process p0;
    
  pregs : process (clk, c)
  begin
    if rising_edge(clk) then
      r <= c;
      -- pragma translate_off
      rdbg <= cdbg;
      -- pragma translate_on
    end if;
  end process;
  
end rtl;
