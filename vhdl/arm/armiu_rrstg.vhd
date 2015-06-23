-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.tech_map.all;
use work.int.all;
use work.armpmodel.all;
use work.armdebug.all;
use work.armdecode.all;
use work.armpctrl.all;
use work.arm_comp.all;

entity armiu_rrstg is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    clkn    : in  std_logic;
    i       : in  armiu_rrstg_typ_in;
    o       : out armiu_rrstg_typ_out
    );
end armiu_rrstg;

architecture rtl of armiu_rrstg is

  -- regfile generic map
  constant RRSTG_REGF_ABITS : integer := 5;
  constant RRSTG_REGF_COUNT : integer := 32;

  type armiu_fwddata_type_a is array (natural range <>) of std_logic_vector(31 downto 0);
  type armiu_rrstg_tmp_type is record
    o       : armiu_rrstg_typ_out;
    commit : std_logic;
    r1_v, r2_v: std_logic_vector(APM_RREAL_U downto APM_RREAL_D);
    nextinsn, lock : std_logic;
    lock_cpsr, lock_reg : std_logic;  -- dbg
    
    dr_v : apc_pctrl;
    rr : apc_pctrl;
    rs : apc_pctrl;
    ex : apc_pctrl;
    dm : apc_pctrl;
    me : apc_pctrl;
    wr : apc_pctrl;
    fwr1 , fwr2  : armiu_fwddata_type_a(3 downto 0);
    fwr1b, fwr2b : std_logic_vector(3 downto 0);
    fwr1i, fwr2i : std_logic_vector(1 downto 0);
    rfi  : rf_in_type;
    
    data1, data2 : std_logic_vector(31 downto 0);  -- ld reg lock
    locked : std_logic_vector(31 downto 0);  -- ld reg lock

  end record;
  type armiu_rrstg_reg_type is record
    micro : apc_micro;
  end record;
  type armiu_rrstg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_rrstg_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_rrstg_reg_type;
  signal rdbg, cdbg : armiu_rrstg_dbg_type;

  signal rfi  : rf_in_type;
  signal rfo  : rf_out_type;

begin  
    
  p0: process (clk, rst, r, i, rfo )
    variable v    : armiu_rrstg_reg_type;
    variable t    : armiu_rrstg_tmp_type;
    variable vdbg : armiu_rrstg_dbg_type;
  begin 
    
    -- $(init(t:armiu_rrstg_tmp_type))
    
    v := r;

    t.commit := not i.flush_v;
    t.lock_cpsr := '0';                 -- tmp for dbg
    
    v := r;
    t.dr_v := i.fromDR_micro_v.pctrl;
    t.rr := r.micro.pctrl;
    t.rs := i.pstate.fromRS_pctrl_r;
    t.ex := i.pstate.fromEX_pctrl_r;
    t.dm := i.pstate.fromDM_pctrl_r;
    t.me := i.pstate.fromME_pctrl_r;
    t.wr := i.pstate.fromWR_pctrl_r;

    -- pipeline propagation
    t.o.pctrl_r := r.micro.pctrl;
    t.o.toRS_pctrl_v := v.micro.pctrl;

    -- register locking
    t.lock := '0';
    if r.micro.r1_valid = '1' then
      
      if ( apc_is_rdlocked_by ( r.micro.r1, t.rs ) or
           apc_is_rdlocked_by ( r.micro.r1, t.ex ) or
           apc_is_rdlocked_by ( r.micro.r1, t.dm ) or
           apc_is_rdlocked_by ( r.micro.r1, t.me ) ) then
        t.lock := r.micro.pctrl.valid;
      end if;
      
      -- rsstg unused for data1  
      if (r.micro.r1 = t.rs.wr.wrop_rd) and apc_is_rdfromalu(t.rs) then
        t.o.toRS_pctrl_v.rs.rsop_op1_src := apc_opsrc_alures;
      end if;
      
    end if;
    if r.micro.r2_valid = '1' then
      
      if ( apc_is_rdlocked_by ( r.micro.r2, t.rs ) or
           apc_is_rdlocked_by ( r.micro.r2, t.ex ) or
           apc_is_rdlocked_by ( r.micro.r2, t.dm ) or
           apc_is_rdlocked_by ( r.micro.r2, t.me ) ) then
        t.lock := r.micro.pctrl.valid;
      end if;
      
      -- lock rsstg alu forward only on data2 shieft
      if (r.micro.r2 = t.rs.wr.wrop_rd) and apc_is_rdfromalu(t.rs) then
        if  apc_is_rswillshieft(t.rr) then
          t.lock := r.micro.pctrl.valid;
        else
          -- no shiefting, rsstg unused
          t.o.toRS_pctrl_v.rs.rsop_op2_src := apc_opsrc_alures;
        end if;
      end if;
    end if;

    t.lock_reg := t.lock;             -- tmp for dbg
    
    -- cpsr locking
    if apc_is_usecpsr(t.rr) then
      if apc_is_exwillsetcpsr(t.rs) then
        t.lock := r.micro.pctrl.valid;
        t.lock_cpsr := r.micro.pctrl.valid;             -- tmp for dbg
      end if;
    end if;
    
    if i.fromCPEX_lock = '1' then
      t.lock := '1';
    end if;
    
    -- forwarding r1
    t.fwr1b := (others => '0');
    if ( r.micro.r1 = t.ex.wr.wrop_rd ) and apc_is_rdfromalu (t.ex) then t.fwr1b(0) := '1'; end if;
    if ( r.micro.r1 = t.dm.wr.wrop_rd ) and apc_is_rdfromalu (t.dm) then t.fwr1b(1) := '1'; end if;
    if ( r.micro.r1 = t.me.wr.wrop_rd ) and apc_is_rdfromalu (t.me) then t.fwr1b(2) := '1'; end if;
    if ( r.micro.r1 = t.wr.wr.wrop_rd ) and apc_is_rdfromalu (t.wr) then t.fwr1b(3) := '1'; end if;
    
    t.fwr1(0) := i.fromEX_alures_v;
    t.fwr1(1) := t.dm.data1;
    t.fwr1(2) := t.me.data1;
    t.fwr1(3) := t.wr.data1;

    -- priority encoder r1
    t.fwr1i(0) := (t.fwr1b(3) and not ( t.fwr1b(2) or t.fwr1b(1) or t.fwr1b(0))) or 
                  (t.fwr1b(1) and not t.fwr1b(0));
    t.fwr1i(1) := (t.fwr1b(2) or t.fwr1b(3)) and not
                  (t.fwr1b(0) or t.fwr1b(1));
    
    if r.micro.r1 = APM_RREAL_PC then
      t.data1 := r.micro.pctrl.insn.pc_8;             -- pc + 8
    else
      if t.fwr1b = "0000" then
        t.data1 := rfo.data1;                      -- no forward
      else
        t.data1 := t.fwr1( lin_convint(t.fwr1i) ); -- forward
      end if;
    end if;

    -- forwarding r2
    t.fwr2b := (others => '0');
    if ( r.micro.r2 = t.ex.wr.wrop_rd ) and apc_is_rdfromalu (t.ex) then t.fwr2b(0) := '1'; end if;
    if ( r.micro.r2 = t.dm.wr.wrop_rd ) and apc_is_rdfromalu (t.dm) then t.fwr2b(1) := '1'; end if;
    if ( r.micro.r2 = t.me.wr.wrop_rd ) and apc_is_rdfromalu (t.me) then t.fwr2b(2) := '1'; end if;
    if ( r.micro.r2 = t.wr.wr.wrop_rd ) and apc_is_rdfromalu (t.wr) then t.fwr2b(3) := '1'; end if;
    
    t.fwr2(0) := i.fromEX_alures_v;
    t.fwr2(1) := t.dm.data1;
    t.fwr2(2) := t.me.data1;
    t.fwr2(3) := t.wr.data1;

    -- priority encoder r2
    t.fwr2i(0) := (t.fwr2b(3) and not ( t.fwr2b(2) or t.fwr2b(1) or t.fwr2b(0))) or 
                  (t.fwr2b(1) and not t.fwr2b(0));
    t.fwr2i(1) := (t.fwr2b(2) or t.fwr2b(3)) and not
                  (t.fwr2b(0) or t.fwr2b(1));
    
    if r.micro.r2 = APM_RREAL_PC then
      t.data2 := r.micro.pctrl.insn.pc_8;             -- pc + 8
    else
      if t.fwr2b = "0000" then
        t.data2 := rfo.data2;                      -- no forward
      else
        t.data2 := t.fwr2( lin_convint(t.fwr2i) ); -- forward
      end if;
    end if;

    -- pctrl.data1 and pctrl.data2
    case r.micro.pctrl.rs.rsop_op1_src is
      when apc_opsrc_through => t.o.toRS_pctrl_v.data1 := t.data1;
      when apc_opsrc_buf     => t.o.toRS_pctrl_v.data1 := t.data1;
      when apc_opsrc_alures  => t.o.toRS_pctrl_v.data1 := t.data1;
      when apc_opsrc_none    => 
      when others => null;
    end case;
    
    case r.micro.pctrl.rs.rsop_op2_src is
      when apc_opsrc_through => t.o.toRS_pctrl_v.data2 := t.data2;
      when apc_opsrc_buf     => t.o.toRS_pctrl_v.data2 := t.data2;
      when apc_opsrc_alures  => t.o.toRS_pctrl_v.data2 := t.data2;
      when apc_opsrc_none    => 
      when others => null;
    end case;

    case r.micro.pctrl.insn.decinsn is
      when type_arm_mrc => t.o.toRS_pctrl_v.data1 := i.fromCPEX_data;
                           t.lock := t.lock or i.fromCPEX_lock;
      when type_arm_stc => t.o.toRS_pctrl_v.data2 := i.fromCPEX_data;
                           t.lock := t.lock or i.fromCPEX_lock;
      when others => null;
    end case;
    
    -- pipeline flush
    if not (t.commit = '1') then
      t.o.toRS_pctrl_v.valid := '0';
      t.lock := '0';
    end if;
    
    if t.lock = '1' then
      t.o.toRS_pctrl_v.valid := '0';
    end if;
    
    -- reset
    if ( rst = '0' ) then
    end if;

    if t.lock = '1' then
      t.o.toDR_nextmicro_v := '0';
    else
      t.o.toDR_nextmicro_v := '1';
      if i.pstate.hold_r.hold = '0' then
        v.micro := i.fromDR_micro_v;
        v.micro.pctrl.valid := i.fromDR_micro_v.valid;
      end if;
    end if;
    
    -- regfile input
    t.rfi.rd1addr := (others => '0');
    t.rfi.rd1addr(APM_RREAL_U downto APM_RREAL_D) := r.micro.r1;
    t.rfi.rd2addr := (others => '0');
    t.rfi.rd2addr(APM_RREAL_U downto APM_RREAL_D) := r.micro.r2;
    t.rfi.wraddr  := (others => '0');
    t.rfi.wraddr(APM_RREAL_U downto APM_RREAL_D)  := i.fromWR_rd_v;
    t.rfi.wrdata  := i.fromWR_rd_data_v;
    t.rfi.ren1  := '1';
    t.rfi.ren2  := '1';
    t.rfi.wren  := i.fromWR_rd_valid_v;

    c <= v;
    
    o <= t.o;
    rfi <= t.rfi;

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

  rf0 : regfile_iu generic map (RFIMPTYPE, RRSTG_REGF_ABITS, 32, RRSTG_REGF_COUNT)
    port map (rst, clk, clkn, rfi, rfo);

end rtl;
