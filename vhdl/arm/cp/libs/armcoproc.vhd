library ieee;
use ieee.std_logic_1164.all;
use work.corelib.all;

-- PREFIX: aco_xxx
package armcoproc is
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

-------------------------------------------------------------------------------

type aco_in is record
                 
  hold_r : cli_hold;
                 
  -- PRDESTG ->CPFESTG
  fromPRDE_insn : std_logic_vector(31 downto 0);
  fromPRDE_valid : std_logic;
  -- PRDRSTG ->CPDESTG
  fromPRDR_nextinsn_v : std_logic;
  fromPRDR_valid : std_logic;
  -- PRRRSTG ->CPEXSTG
  fromPRRR_valid : std_logic;
  -- PRWRSTG ->CPWRSTG
  fromPRWR_data_v : std_logic_vector(31 downto 0);
  fromPRWR_valid : std_logic;
  
end record;

-------------------------------------------------------------------------------

type aco_CPDE_PRDR_out is record
  busy   : std_logic;              -- drive ctrlo.hold
  last   : std_logic;              -- drive cmd_cl/cmd_cs issue
  accept : std_logic;              -- udef trap
  active : std_logic;              -- udef trap
end record;

type aco_CPEX_PRRR_out is record
  data : std_logic_vector(31 downto 0);
  lock : std_logic;                -- lock regread
end record;

type aco_out is record
  -- PRDRSTG <- CPDESTG
  CPDE_PRDR : aco_CPDE_PRDR_out;
  -- PRRRSTG <- CPEXSTG
  CPEX_PRRR : aco_CPEX_PRRR_out;
end record;

-------------------------------------------------------------------------------

constant ACO_CREG_U : integer := 3;
constant ACO_CREG_D : integer := 0;
constant ACO_COPC_U : integer := 2;
constant ACO_COPC_D : integer := 0;
constant ACO_CPNUM_U : integer := 11;
constant ACO_CPNUM_D : integer := 8;

-- decode MCR
constant ACO_MCRMRC_CRN_U : integer := 19;
constant ACO_MCRMRC_CRN_D : integer := 16;
constant ACO_MCRMRC_CRM_U : integer := 3;
constant ACO_MCRMRC_CRM_D : integer := 0;
constant ACO_MCRMRC_OPCODE1_U : integer := 23;
constant ACO_MCRMRC_OPCODE1_D : integer := 21;
constant ACO_MCRMRC_OPCODE2_U : integer := 7;
constant ACO_MCRMRC_OPCODE2_D : integer := 5;
constant ACO_LDCSTC_CRD_U : integer := 15;
constant ACO_LDCSTC_CRD_D : integer := 12;

type aco_decinsn is (ACO_type_none, ACO_type_cdp, ACO_type_mrc, ACO_type_mcr, ACO_type_stc, ACO_type_ldc);
function aco_decodev4(
  insn : std_logic_vector(31 downto 0)
) return aco_decinsn;

-------------------------------------------------------------------------------

end armcoproc;

package body armcoproc is

function aco_decodev4(
  insn : std_logic_vector(31 downto 0)
) return aco_decinsn is
  variable tmp : aco_decinsn;
begin
  tmp := ACO_type_none;
  case insn(27 downto 25) is
    when "111" => 
      if insn(24) = '0' then
        if insn(1) = '0' then
          if insn(20) = '0' then
            tmp := ACO_type_mcr;
          else
            tmp := ACO_type_mrc;
          end if;
        else
          tmp := ACO_type_cdp;
        end if;
      end if;
    when "110" =>
      if insn(20) = '0' then
        tmp := ACO_type_ldc;
      else
        tmp := ACO_type_stc;
      end if;
    when others =>
  end case;
  return tmp;
end;

end armcoproc;

