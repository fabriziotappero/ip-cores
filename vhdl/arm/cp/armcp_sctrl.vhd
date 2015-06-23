-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.int.all;
use work.armcoproc.all;
use work.armsctrl.all;
use work.armcp_comp.all;

entity armcp_sctrl is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  aco_in;
    o       : out aco_out
    );
end armcp_sctrl;

architecture rtl of armcp_sctrl is
  
  type armcp_sctrl_insn_type is record
    decinsn : aco_decinsn;
    cr1, cr2 : std_logic_vector(ACO_CREG_U downto ACO_CREG_D);
    opc : std_logic_vector(ACO_COPC_U downto ACO_COPC_D);
    valid : std_logic;
  end record;
  type armcp_sctrl_dereg_type is record
    insn : armcp_sctrl_insn_type;
    CPDE_PRDR : aco_CPDE_PRDR_out;
  end record;
  type armcp_sctrl_exreg_type is record
    insn : armcp_sctrl_insn_type;
    CPEX_PRRR : aco_CPEX_PRRR_out;
  end record;
  type armcp_sctrl_wrreg_type is record
    insn : armcp_sctrl_insn_type;
  end record;  
  type armcp_sctrl_wrreg_type_a is array (natural range <>) of armcp_sctrl_wrreg_type;
  type armcp_sctrl_reg_type is record
    de : armcp_sctrl_dereg_type;
    ex : armcp_sctrl_exreg_type;
    wr : armcp_sctrl_wrreg_type_a(4 downto 0);
    regs : acpsc_regs;
    regslock : std_logic_vector (3 downto 0);
  end record;
  type armcp_sctrl_tmp_type is record
    fe_de : armcp_sctrl_dereg_type;
    de_de : armcp_sctrl_dereg_type;
    de_ex : armcp_sctrl_exreg_type;
    ex_wr : armcp_sctrl_wrreg_type;
    
    regs : acpsc_regs;
    o : aco_out;
  end record;

  type armcp_sctrl_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcp_sctrl_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcp_sctrl_reg_type;
  signal rdbg, cdbg : armcp_sctrl_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armcp_sctrl_reg_type;
    variable t    : armcp_sctrl_tmp_type;
    variable vdbg : armcp_sctrl_dbg_type;
  begin 

--                                            locking>|<
--  +---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
--  |IMSTG    |FESTG    |DESTG    |DRSTG    |RRSTG    |RSSTG    |EXSTG    |DMSTG    |MESTG    |WRSTG    |
--  |         |         |         |         |         |         |take     |         |         |         |
--  |         |         |         |[undef]  |         |         |[undef]  |         |         |         |
--  |         |         |         |         |         |         |         |         |         |         |
--  |         |         |[insn]   |         |         |         |         |         |         |         |
--  +---------+---------++--------++--------+-+-------+---------+---------+---------+---------+-------+-+
--                       V         /\         /\                                                      V   
--                      ++--------++--------+-+-------+---------+---------+---------+---------+-------+-+           
--                      |         | ldc/stc | reg/lock|                                       |ldc/mrc| |         
--                      |         | ctrl    | stc/mcr |                                       |[reg] <+ |         
--                      |         | busy    |         |                                       |commit   |                 
--                      |         |         |         |                                       |use id   | 
--                      +---------+---------+---------+                                       +---------+           
--                         CPFE      CPDEC     CPEX                                                                   
--                      |<  DRSTG.netxinsn controled >|
--
--

    -- $(init(t:armcp_sctrl_tmp_type))
    
    v := r;

    t.o.CPDE_PRDR := r.de.CPDE_PRDR;
    t.o.CPEX_PRRR := r.ex.CPEX_PRRR;

-------------------------------------------------------------------------------
    -- CPFESTG
    t.fe_de.insn.decinsn := aco_decodev4(i.fromPRDE_insn);
    t.fe_de.CPDE_PRDR.active := '1';              -- udef trap
    t.fe_de.CPDE_PRDR.busy := '0';              -- drive ctrlo.hold
    t.fe_de.CPDE_PRDR.last := '1';              -- drive cmd_cl/cmd_cs issue
    t.fe_de.CPDE_PRDR.accept := '1';              -- udef trap
    t.fe_de.insn.cr1 := i.fromPRDE_insn(ACO_MCRMRC_CRN_U downto ACO_MCRMRC_CRN_D);
    t.fe_de.insn.cr2 := i.fromPRDE_insn(ACO_MCRMRC_CRM_U downto ACO_MCRMRC_CRM_D);
    t.fe_de.insn.opc := i.fromPRDE_insn(ACO_MCRMRC_OPCODE1_U downto ACO_MCRMRC_OPCODE1_D);
    t.fe_de.insn.valid := i.fromPRDE_valid;
    case t.fe_de.insn.decinsn is
      when ACO_type_none => 
      when ACO_type_cdp =>
      when ACO_type_mrc =>
      when ACO_type_mcr =>
      when ACO_type_stc => 
      when ACO_type_ldc =>
      when others => 
    end case;
    
-------------------------------------------------------------------------------
    -- CPDESTG
    t.de_de := r.de;
    t.de_ex.insn := r.de.insn;
    t.de_ex.insn.valid := t.de_ex.insn.valid and i.fromPRDR_valid;
    t.de_ex.CPEX_PRRR.lock := '0';
    t.de_ex.CPEX_PRRR.data := (others => '0');
    case r.de.insn.decinsn is
      when ACO_type_none => 
      when ACO_type_cdp =>
      when ACO_type_mrc |
           ACO_type_stc =>
      when ACO_type_mcr |
           ACO_type_ldc =>
        v.regslock(lin_convint(r.de.insn.cr1(1 downto 0))) := '1';
      when others => 
    end case;
    
-------------------------------------------------------------------------------
    -- CPEXSTG
    t.ex_wr.insn := r.ex.insn;
    t.ex_wr.insn.valid := t.ex_wr.insn.valid and i.fromPRRR_valid;
    case r.ex.insn.decinsn is
      when ACO_type_mrc =>
        t.o.CPEX_PRRR.lock := r.regslock(lin_convint(r.ex.insn.cr1(1 downto 0)));
        case r.ex.insn.cr1  is
          when "0000" =>
            case r.ex.insn.opc is
              when "000" => t.o.CPEX_PRRR.data := ACPSC_R0_OP0;
              when "001" => t.o.CPEX_PRRR.data := ACPSC_R0_OP1;
              when others => null;
            end case;
          when "0001" =>
            t.o.CPEX_PRRR.data := acpsc_r1tostd(r.regs.r1);
          when "0010" =>
            t.o.CPEX_PRRR.data := r.regs.r2;
          when others => 
        end case;
      when others => 
    end case;
        
-------------------------------------------------------------------------------
    -- CPWRSTG
    t.regs := r.regs; 
    if r.wr(0).insn.valid = '1' and i.fromPRWR_valid = '1' then 
      case r.wr(0).insn.decinsn is 
        when ACO_type_none => 
        when ACO_type_cdp => 
        when ACO_type_mrc => 
        when ACO_type_mcr |
             ACO_type_ldc => 
          v.regslock(lin_convint(r.wr(0).insn.cr1(1 downto 0))) := '0';
          case r.wr(0).insn.cr1  is 
            when "0001" => 
              acpsc_stdtor1( i.fromPRWR_data_v, t.regs.r1);
            when "0010" =>
              t.regs.r2 := i.fromPRWR_data_v;
            when others => 
          end case; 
        when ACO_type_stc => 
        when others => 
      end case; 
    end if; 
    
-------------------------------------------------------------------------------
    
    t.ex_wr.insn.valid := i.fromPRDR_nextinsn_v;
    if i.hold_r.hold = '0' then
      if i.fromPRDR_nextinsn_v = '1' then
        -- CPFESTG -> CPDESTG
        v.de := t.fe_de;
        -- CPDESTG -> CPEXSTG
        v.ex := t.de_ex;
      end if;
      
      -- CPEXSTG ->...-> CPWRSTG
      for i in 3 downto 0 loop
        v.wr(i) := r.wr(i+1);
      end loop;
      v.wr(4) := t.ex_wr;

      v.regs := t.regs;
    end if;
    
    -- reset
    if ( rst = '0' ) then
      v.regs.r1.mmu := '0';
      v.regslock := (others => '0');
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
