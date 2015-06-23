-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.memdef.all;
use work.armdecode.all;
use work.armcmd.all;
use work.armpctrl.all;
use work.armpmodel.all;
use work.armcmd_comp.all;

entity armcmd_sw is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_sw_typ_in;
    o       : out armcmd_sw_typ_out
    );
end armcmd_sw;

architecture rtl of armcmd_sw is

  type armcmd_sw_tmp_type is record
    o       : armcmd_sw_typ_out;
    off : std_logic_vector(23 downto 0);
    ctrlmemo : acm_ctrlmemout;
  end record;
  type armcmd_sw_reg_type is record
    dummy      : std_logic;
  end record;
  type armcmd_sw_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcmd_sw_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcmd_sw_reg_type;
  signal rdbg, cdbg : armcmd_sw_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armcmd_sw_reg_type;
    variable t    : armcmd_sw_tmp_type;
    variable vdbg : armcmd_sw_dbg_type;
  begin 
    
    -- $(init(t:armcmd_sw_tmp_type))
    
    v := r;
    t.o.ctrlo := i.ctrli.ctrlo;
    t.o.ctrlo.nextinsn := '0';
    t.ctrlmemo := i.ctrlmemo;

    t.ctrlmemo.meop_param.writedata  := '0'; -- MESTG: dcache inputs (wr data)
    t.ctrlmemo.meop_param.addrin  := '0'; -- MESTG: dcache inputs (tag cmp)
    t.ctrlmemo.meop_param.read  := '0';   -- MESTG: dcache inputs (readdata)
    t.ctrlmemo.meop_param.signed  := '0';   -- MESTG: dcache inputs (readdata)
    t.ctrlmemo.meop_param.lock  := '0';   -- MESTG: dcache inputs (atomic)
    t.ctrlmemo.meop_enable := '0';        -- MESTG: dcache inputs
        
    -- swpb cmd
    if i.ctrli.insn.insn(ADE_SWPB_C) = '1' then
      t.ctrlmemo.meop_param.size  := lmd_byte;
    else
      t.ctrlmemo.meop_param.size  := lmd_word; 
    end if;
    
    -- swp{cond} <rd>,<rm>,[<rn>]
    case i.ctrli.cnt is
      when ACM_CNT_ZERO =>

        -- [frame: ctrli.cnt = 1] load address calculation (rn)
        --
        --            RRSTG       RSSTG       EXSTG       DMSTG       MESTG       WRSTG
        --      --+-----------+-----------+-----------+-----------+-----------+----------+
        -- <rn> ->+-----------+----------op1          |           |           |
        --        |           |           | \->[buf]  |           |           |
        --        |  (regread)| (noshift) | +---+     | +(trans)  | +>(dcache)+-+>(write)
        --        |           |           |     |     | |   |     | |         | |
        -- <rm> ->+-----------+->[buf]    |     |     | |   |     | |         | |
        --      --+-----------+-----------+-----+-----+-+---+-----+-+---------+-+--------+
        --                                      |       |   |       |           |
        --        pctrl.data1 (as address)  :   +-------+   +-------+           |
        --         pctrl.me.param:   o------------------------------+           |                
        --         pctrl.wr.rd(<rd>):o------------------------------------------+                           
        
        t.ctrlmemo.r1_src  := acm_rrn; -- fetch <rn> (addrbase)
        t.ctrlmemo.r2_src  := acm_rrm; -- fetch <rm> (swapreg)
        t.ctrlmemo.data2 := (others => '0'); -- <0> 
        t.ctrlmemo.rsop_op1_src := apc_opsrc_through; -- route <rn> to exestg op1
        t.ctrlmemo.rsop_op2_src := apc_opsrc_through;     -- route <offset12> to exestg op2
        t.ctrlmemo.rd_src  := acm_rdrrd;
        t.ctrlmemo.rsop_buf2_src := apc_bufsrc_through;
        t.ctrlmemo.exop_buf_src := apc_exbufsrc_op1;
        t.ctrlmemo.exop_data_src := apc_datasrc_none;     -- route <rn> to pctrl.data1 (waddr)
        
        t.ctrlmemo.meop_param.read  := '1';   -- MESTG: dcache inputs (readdata)
        t.ctrlmemo.meop_param.addrin  := '1'; -- MESTG: dcache inputs (tag cmp)
        t.ctrlmemo.meop_param.lock  := '1';   -- MESTG: dcache inputs (atomic)
        t.ctrlmemo.meop_enable := '1';        -- MESTG: dcache inputs

      when ACM_CNT_ONE =>

        -- [frame: ctrli.cnt = 2] store address calculation (rn) (will not block)
        --                lock barier
        --                   >|<
        --            RRSTG   |   RSSTG       EXSTG       DMSTG       MESTG       WRSTG
        --      --+-----------+-----------+-----------+-----------+-----------+----------+
        --        |           |           |           |           |
        --        |           |           |           |           |           |
        --        |  (regread)| (noshift) |  (aluop)  | +(trans)  | +>(dcache)|  (write)
        --        |           |           |   [buf]   | |   |     | |         | 
        --        |           |           |     |     | |   |     | |         | 
        --      --+-----------+-----------+-----+-----+-+---+-----+-+---------+----------+
        --                                      |       |   |       |           
        --        pctrl.data1 (as address)  :   +-------+   +-------+           
        --    cyc0:pctrl.me.param:   o------------------------------+                           
        
        t.ctrlmemo.r1_src  := acm_none; -- fetch <rn> (addrbase)
        t.ctrlmemo.r2_src  := acm_none; -- fetch <rn> (addrbase)
        t.ctrlmemo.rd_src  := acm_rdnone;
        t.ctrlmemo.exop_data_src := apc_datasrc_buf;     -- route <offset12> to exestg op2
        
        t.ctrlmemo.meop_param.read  := '0';   -- MESTG: dcache inputs (readdata)
        t.ctrlmemo.meop_param.addrin  := '1'; -- MESTG: dcache inputs (tag cmp)
        t.ctrlmemo.meop_enable := '1';        -- MESTG: dcache inputs
            
      when others =>
        
        -- [ctrli.cnt = 1:] send writedata (will not block )
        --  
        --                lock barier
        --                   >|<
        --            RRSTG   |   RSSTG       EXSTG       DMSTG       MESTG       WRSTG
        --      --+-----------+-----------+-----------+-----------+-----------+----------+
        --        |           +       <0>-op1         |           |           |
        --        |           |           | \         |           |           |
        --        |  (regread)| (noshift) | +(aluop)  |  (trans)  | +>(dcache)|  (write)
        --        |           |           | /   |     |           | |   /\    | 
        --        |           |    [buf]-op2    |     |           | |   |     | 
        --      --+-----------+-----------+-----+-----+-----------+-+---+-----+----------+
        --                                      |                   |   |         
        --       (as memwritedata) pctrl.data1: +-------------------+   |    
        --            cyc1:pctrl.me.param:   o----------------------+   |               
        --         cyc0:pctrl.data1(addr):   o--------------------------+                           
            
        
        t.ctrlmemo.r1_src  := acm_none;
        t.ctrlmemo.r2_src  := acm_none;
        t.ctrlmemo.data2 := (others => '0');
        t.ctrlmemo.rsop_op1_src := apc_opsrc_none;
        t.ctrlmemo.rsop_op2_src := apc_opsrc_buf;
        t.ctrlmemo.rd_src  := acm_rdnone;
        t.ctrlmemo.exop_data_src := apc_datasrc_aluout;     -- route <offset12> to exestg op2
        
        t.ctrlmemo.meop_param.read  := '0';      -- MESTG: dcache inputs
        t.ctrlmemo.meop_param.writedata  := '1'; -- MESTG: dcache inputs (wr data)
        t.ctrlmemo.meop_enable := '1';           -- MESTG: dcache inputs

        t.o.ctrlo.nextinsn := '1';
       
    end case;

    t.o.ctrlmemo := t.ctrlmemo;

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
