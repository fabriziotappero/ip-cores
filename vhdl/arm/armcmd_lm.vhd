-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armpctrl.all;
use work.armpmodel.all;
use work.armcmd.all;
use work.armldst.all;
use work.armdecode.all;
use work.arm_comp.all;
use work.armcmd_comp.all;

entity armcmd_lm is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_lm_typ_in;
    o       : out armcmd_lm_typ_out
    );
end armcmd_lm;

architecture rtl of armcmd_lm is

  type armcmd_lm_tmp_type is record
    o       : armcmd_lm_typ_out;
    ctrlmemo : acm_ctrlmemout;
    cnt : std_logic_vector(ACM_CNT_SZ-1 downto 0);
  end record;
  type armcmd_lm_reg_type is record
    cnt : std_logic_vector(ACM_CNT_SZ-1 downto 0);
  end record;
  type armcmd_lm_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcmd_lm_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcmd_lm_reg_type;
  signal rdbg, cdbg : armcmd_lm_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armcmd_lm_reg_type;
    variable t    : armcmd_lm_tmp_type;
    variable vdbg : armcmd_lm_dbg_type;
  begin 
    
    -- $(init(t:armcmd_lm_tmp_type))
    
    v := r;

    t.cnt := i.ctrli.cnt;
    
    t.o.ctrlo := i.ctrli.ctrlo;
    t.o.ctrlo.nextinsn := '0';
    
    t.ctrlmemo := i.ctrlmulti.ctrlmemo;
    
--t.cmdldmo.ctrlo.usermode_nc := t.usermode_nc;

    -- LRM/STM: Increment after  (regorder [0-15],start:+0,end(onwb):+4) :ldmia|stmia <rn>,{<reglist>}
    -- LRM/STM: Increment before (regorder [0-15],start:+4,end(onwb):+0) :ldmib|stmib <rn>,{<reglist>}
    -- LRM/STM: Decrement after  (regorder [15-0],start:-0,end(onwb):-4) :ldmda|stmda <rn>,{<reglist>}
    -- LRM/STM: Decrement before (regorder [15-0],start:-4,end(onwb):-0) :ldmdb|stmdb <rn>,{<reglist>}
    case i.ctrli.cnt is
      when ACM_CNT_ZERO =>
        -- [frame: ctrli.cnt=0] start address issue 
        --
        --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG     WRSTG          
        --      --+-----------+-----------+-----------+-----------+-----------+---------+          
        --  <rn>->+-----------+-+--------op1          |           |           |                   
        --        |           | +>[buf1]  | \         |           |           |                   
        --        | (regread) |           | +(aluop)+ |  +(trans) | +>(dcache-+-+->(write)       
        --        |           |           | /   |     |  |   |    | |         | |                   
        --        |           | startoff-op2    |     |  |   |    | |         | |                   
        --      --+-----------+-----------+-----+-----+--+---+----+-+---------+-+-------+
        --                                      |        |   |      |           |                   
        --         pctrl.data1 (as address)  :  +--------+   +------+           |                             
        --  cyceven:pctrl.me.param: o-------------------------------+           |                      
        --          pctrl.wr.rd(<nxtreg>):o-------------------------------------+
                  
        
        t.ctrlmemo.rsop_op1_src := apc_opsrc_through;      -- route <rn> to exestg op1
        t.ctrlmemo.r1_src := acm_rrn;                      -- fetch <rn> (address base)
        t.ctrlmemo.rsop_op2_src := apc_opsrc_none;         -- route 0|4 to exestg op2
        t.ctrlmemo.data2 := i.ctrlmulti.soff;         -- dep. LDSTM amode: 0|(-)4
        t.ctrlmemo.rsop_buf1_src := apc_bufsrc_through;    -- save <rn> for writeback
        t.ctrlmemo.exop_data_src := apc_datasrc_aluout;    -- save aluresult (address in(de)cerement) as MESTG_address
        t.ctrlmemo.rd_src := acm_rdlocal;                  -- write to rnext (MESTG result)
        
        t.ctrlmemo.meop_param.read  := '1';                -- MESTG: dcache inputs (readdata)
        t.ctrlmemo.meop_param.addrin  := '1';              -- MESTG: dcache inputs (tag cmp)
        t.ctrlmemo.meop_enable := '1';                     -- MESTG: dcache inputs
        
        if i.ctrlmulti.mem = '1' then
          t.o.ctrlo.hold := '1';                      -- wait for all mem cmd to finish first
        end if;
        
      when others       =>
        
        -- [frame: ctrli.cnt!=0] address issue 
        --
        --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG           
        --      --+-----------+-----------+-----------+-----------+-----------+----------+           
        --        |           | (lastalu)op1          |           |           |
        --        |           |           | \         |           |           |
        --        | (regread) |           | +(aluop)  |  +(trans) | +>(dcache)+-+->(write)
        --        |           |           | /   |     |  |   |    | |         | |
        --        |           | in/Decr--op2    |     |  |   |    | |         | |           
        --      --+-----------+-----------+-----+-----+--+---+----+-+---------+-+--------+           
        --                                      |        |   |      |           |                      
        --         pctrl.data1 (as address)  :  +--------+   +------+           |                      
        --  cyceven:pctrl.me.param: o-------------------------------+           |                      
        --          pctrl.wr.rd(<nxtreg>):o-------------------------------------+
        
        t.ctrlmemo.rsop_op1_src := apc_opsrc_alures;       -- route <lastalu> to exestg op1
        t.ctrlmemo.rsop_op2_src := apc_opsrc_none;         -- route 0|(-)4 to exestg op2
        t.ctrlmemo.data2 := i.ctrlmulti.ival;         -- dep. LDSTM amode: 0|(-)4
        t.ctrlmemo.exop_data_src := apc_datasrc_aluout;    -- save aluresult (address in(de)cerement) as MESTG_address
        t.ctrlmemo.rd_src := acm_rdlocal;                  -- write to rnext (MESTG result)
        
        t.ctrlmemo.meop_param.read  := '1';                -- MESTG: dcache inputs (readdata)
        t.ctrlmemo.meop_param.addrin  := '1';              -- MESTG: dcache inputs (tag cmp)
        t.ctrlmemo.meop_enable := '1';                     -- MESTG: dcache inputs
                
    end case;
    
    -- finish - update <rn>
    if i.ctrlmulti.reglist = ALS_REGLIST_ZERO then

      t.ctrlmemo.meop_enable := '0';                  -- MESTG: dcache inputs
      t.ctrlmemo.rd_src := acm_rdnone;                  -- no rdwrite 
        
      if v.cnt(0) = i.ctrli.cnt(0) then
        
        if i.ctrlmulti.mem = '1' then
          t.o.ctrlo.hold := '1'; -- wait for all mem cmd to finish
        else
          t.o.ctrlo.nextinsn := '1';
        end if;
        
      else
        
          -- [frame:] update <rn>
          --
          --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
          --      --+-----------+-----------+-----------+-----------+-----------+----------+
          --        |           |(lastalu)-op1          |           |           |
          --        |           |           | \         |           |           |
          --        | (regread) |           | +(aluop)  |   (trans) | (dcache)  | +->(write)
          --        |           |           | /   |     |           |           | | 
          --        |           |  in/Decr-op2    |     |           |           | |
          --      --+-----------+-----------+-----+-----+-----------+-----------+-+--------+
          --                                      |                               |                 
          --         pctrl.data1 (as wrdata):     +-------------------------------+
        
          t.ctrlmemo.rsop_op1_src := apc_opsrc_alures;       -- route <lastalu> to exestg op1
          t.ctrlmemo.rsop_op2_src := apc_opsrc_none;         -- route 0|(-)4 to exestg op2
          t.ctrlmemo.data1 := i.ctrlmulti.eoff;       -- dep. LDSTM amode: 0|(-)4
          if i.ctrli.insn.insn(ADE_WB_C) = '1' then
            t.ctrlmemo.rd_src := acm_rdrrn;
          end if;
          
      end if;
          
    else
      v.cnt := i.ctrli.cnt;
    end if;
    
    -- dabort
    if not (i.ctrli.cnt = ACM_CNT_ZERO) then
      if i.ctrlmulti.dabort = '1' then

        t.o.ctrlo.nextinsn := '1';

        -- dabort frame, writeback <rn>
        --
        --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
        --      --+-----------+-----------+-----------+-----------+-----------+----------+
        --        |           |  [buf1] -op1          |           |           |
        --        |           |           | \         |           |           |
        --        | (regread) |           | +(aluop)  |   (trans) | (dcache)  | +->(write)
        --        |           |           | /   |     |           |           | | 
        --        |           |   0     -op2    |     |           |           | |
        --      --+-----------+-----------+-----+-----+-----------+-----------+-+--------+
        --                                      |                               |                 
        --         pctrl.data1 (as wrdata):     +-------------------------------+   
        
        t.ctrlmemo.rd_src := acm_rdrrn;
        t.ctrlmemo.rsop_op1_src := apc_opsrc_buf;        -- route old <rn> to exestg op1 (saved in cycle zero)
        t.ctrlmemo.rsop_op2_src := apc_opsrc_none;       -- route 0 to exestg op2
        t.ctrlmemo.data2 := (others => '0');
        
        t.ctrlmemo.meop_enable := '0';                   -- MESTG: dcache inputs
      end if;
    end if;

    -- reset
    if ( rst = '0' ) then
    end if;

    t.o.ctrlmemo := t.ctrlmemo;

    
    c <= v;

    o <= t.o;

    -- reset
    if ( rst = '0' ) then
    end if;
    
    c <= v;
    
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
