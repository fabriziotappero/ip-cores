-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armpctrl.all;
use work.armpmodel.all;
use work.armdecode.all;
use work.armshiefter.all;
use work.armcmd.all;
use work.gendc_lib.all;
use work.armcmd_comp.all;

entity armcmd_ld is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_ld_typ_in;
    o       : out armcmd_ld_typ_out
    );
end armcmd_ld;

architecture rtl of armcmd_ld is

  type armcmd_ld_tmp_type is record
    o       : armcmd_ld_typ_out;
    ctrlmemo : acm_ctrlmemout;
    off12 : std_logic_vector(31 downto 0);
    off8 : std_logic_vector(31 downto 0);
    am : ade_LDSTAMxLSV4AM;
  end record;
  type armcmd_ld_reg_type is record
    dummy      : std_logic;
  end record;
  type armcmd_ld_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcmd_ld_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcmd_ld_reg_type;
  signal rdbg, cdbg : armcmd_ld_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armcmd_ld_reg_type;
    variable t    : armcmd_ld_tmp_type;
    variable vdbg : armcmd_ld_dbg_type;
  begin 
    
    -- $(init(t:armcmd_ld_tmp_type))
    
    v := r;
    t.o.ctrlo    := i.ctrli.ctrlo;
    t.ctrlmemo := i.ctrlmemo;
    
    t.off8 := (others => '0');
    t.off12 := (others => '0');
    t.off8(7 downto 0) := i.ctrli.insn.insn(ADE_LSV4AM_OFF8_HU downto ADE_LSV4AM_OFF8_HD) & i.ctrli.insn.insn(ADE_LSV4AM_OFF8_LU downto ADE_LSV4AM_OFF8_LD);
    t.off12(11 downto 0) := i.ctrli.insn.insn(ADE_LDSTAM_OFF_U downto ADE_LDSTAM_OFF_D); -- LDSTAM <offset12>

    -- todo:
    -- load user access memory access :am.LDSTAMxLSV4AM_uacc
  
    -- switch ldr v1/v4
    t.am := i.ctrli.insn.am.LDSTAM_typ;
    t.ctrlmemo.data2 := t.off12; -- <offset12> 
    t.ctrlmemo := i.ctrlmemo;
    t.o.rsop_styp := ash_styp_none;
    t.o.rsop_sdir := i.ctrli.insn.am.DAPRAMxLDSTAM_sdir;
    case i.ctrli.insn.decinsn is
      when type_arm_ldr1 =>
        t.am := i.ctrli.insn.am.LDSTAM_typ;
        case t.am is
          when ade_LDSTAMxLSV4AM_reg => t.o.rsop_styp := ash_styp_simm;
          when others => null;
        end case;
        t.ctrlmemo.data2 := t.off12; -- <offset12>
      when type_arm_ldrhb =>
        t.am := i.ctrli.insn.am.LSV4AM_typ;
        t.ctrlmemo.data2 := t.off8; -- <offset12> 
      when others => null;
    end case;

    -- addressing modes
    case i.ctrli.cnt is
      when ACM_CNT_ZERO =>
        
        t.ctrlmemo.meop_param.read  := '1';   -- MESTG: dcache inputs (readdata)
        t.ctrlmemo.meop_param.addrin  := '1'; -- MESTG: dcache inputs (tag cmp)
        t.ctrlmemo.meop_enable := '1';        -- MESTG: dcache inputs
        
        case t.am is
          when ade_LDSTAMxLSV4AM_reg =>
            -- L/S W/UB: Register Offset                     : [<rn>, +/-<rm>]
            -- L/S W/UB: Register Offset pre-indexed         : [<rn>, +/-<rm>]!
            -- L/S W/UB: Register Offset post-indexed        : [<rn>], +/-<rm>
            -- L/S W/UB: Scaled Register Offset              : [<rn>, +/-<rm>, <LSAMscale>]
            -- L/S W/UB: Scaled Register Offset pre-indexed  : [<rn>, +/-<rm>, <LSAMscale>]!
            -- L/S W/UB: Scaled Register Offset post-indexed : [<rn>], +/-<rm>, <LSAMscale>
            -- <LSAMscale>: {LSL #<imm>}|{LSR #<imm>}|{ASR #<imm>}|{ROR #<imm>}|{RRX}
            -- am.LSV4AM_typ:
            -- - L/S MISC: Register offset            : [<rn>, #+/-<rm>]
            -- - L/S MISC: Register offset pre-index  : [<rn>, #+/-<rm>] !
            -- - L/S MISC: Register offset post-index : [<rn>], #+/-<rm>

            -- [ctrli.cnt = 0:] address calculation (rn+/-rm <LSAMscale>)
            --
            --             RRSTG      RSSTG       EXSTG       DMSTG       MESTG       WRSTG
            --      --+-----------+-----------+-----------+-----------+-----------+----------+
            -- <rn> ->+-----------+----------op1          |           |           |
            --        |           |           | \         |           |           |
            --        |  (regread)| <imm>+    | +(aluop)  |  +(trans) | +>(dcache)+-+>(write)
            --        |           |      V    | /   |     |  |   |    | |         | |
            -- <rm> ->+-----------+-(shift)--op2    |     |  |   |    | |         | |
            --      --+-----------+-----------+-----+-----+--+---+----+-+---------+-+--------+
            --                                      |        |   |      |           |
            --          pctrl.data1 (as address) :  +--------+   +------+           |
            --          pctrl.me.param:   o-----------------------------+           |                
            --          pctrl.wr.rd(<rd>):o-----------------------------------------+                           
            
            t.ctrlmemo.r1_src  := acm_rrn; -- fetch <rn> (addrbase)
            t.ctrlmemo.r2_src  := acm_rrm; -- fetch <rm> (roff)
            t.ctrlmemo.rd_src  := acm_rdrrd;
            t.ctrlmemo.rsop_op1_src := apc_opsrc_through; -- route <rn> to EXSTG op1
            t.ctrlmemo.rsop_op2_src := apc_opsrc_through; -- route <rm> to EXSTG op2
            
          when ade_LDSTAMxLSV4AM_imm =>
            -- L/S W/UB: Immediate Offset              : [<rn>, #+/-<offset12>]
            -- L/S W/UB: Immediate Offset pre-indexed  : [<rn>, #+/-<offset12>]!
            -- L/S W/UB: Immediate Offset post-indexed : [<rn>], #+/-<offset12>
            -- ade_atyp_LSV4AM.adm_LSV4AM_imm:
            -- - L/S MISC: Immediate offset            : [<rn>, #+/-<off>]
            -- - L/S MISC: Immediate offset pre-index  : [<rn>, #+/-<off>] !
            -- - L/S MISC: Immediate offset post-index : [<rn>], #+/-<off>

            -- [ctrli.cnt = 0:] address calculation (rn+/-off)
            --
            --            RRSTG       RSSTG       EXSTG       DMSTG       MESTG       WRSTG
            --      --+-----------+-----------+-----------+-----------+-----------+----------+
            -- <rn> ->+-----------+----------op1          |           |           |
            --        |           |           | \         |           |           |
            --        |  (regread)| (noshift) | +(aluop)  | +(trans)  | +>(dcache)+-+>(write)
            --        |           |           | /   |     | |   |     | |         | |
            --        |           |<offset12>op2    |     | |   |     | |         | |
            --      --+-----------+-----------+-----+-----+-+---+-----+-+---------+-+--------+
            --                                      |       |   |       |           |
            --        pctrl.data1 (as address)  :   +-------+   +-------+           |
            --         pctrl.me.param:   o------------------------------+           |                
            --         pctrl.wr.rd(<rd>):o------------------------------------------+                           

            t.ctrlmemo.r1_src  := acm_rrn; -- fetch <rn> (addrbase)
            t.ctrlmemo.rd_src  := acm_rdrrd;
            t.ctrlmemo.data2 := t.off12; -- <offset12> 
            t.ctrlmemo.rsop_op1_src := apc_opsrc_through; -- route <rn> to exestg op1
            t.ctrlmemo.rsop_op2_src := apc_opsrc_none;     -- route <offset12> to exestg op2
          when others => null;
        end case;

        if i.ctrli.insn.am.LDSTAMxLSV4AM_wb = '1' then
          t.o.ctrlo.nextinsn := '0';
        end if;
        
      when others  =>
        -- [ctrli.cnt = 1:] update baseregister
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
            
        
        t.ctrlmemo.rsop_op1_src := apc_opsrc_alures; -- route alulast to exestg op1
        t.ctrlmemo.data2 := (others => '0');                       -- imm 0
        t.ctrlmemo.rsop_op2_src := apc_opsrc_none;     -- route 0 to exestg op2
        t.ctrlmemo.exop_data_src := apc_datasrc_aluout; -- save aluresult as WRSTG_data
        t.ctrlmemo.rd_src := acm_rdrrn;                                      -- <rn>
        
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
