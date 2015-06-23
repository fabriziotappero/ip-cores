--------------------------------------------------------------------------------
-- MIPS™ I CPU                                                                --
--------------------------------------------------------------------------------
--                                                                            --
-- POSSIBLE FAULTS                                                            --
--                                                                            --
--  o The upper 4bits of a branch/jump instruction depend on the PC of the    --
--    branch delay slot. This special case has not been tested:               --
--                                                                            --
--                      PC           INSTRUCTION                              --
--                    +------------+-----------------+                        --
--                    | 0x0fffffff | some branch OP  |                        --
--                    | 0x10000000 | ADD $s1, $s1, 1 |                        --
--                    +------------+-----------------+                        --
--                                                                            --
--    Whenever the upper 4 PC bits of the jump instruction differs from the   --
--    delay slot instruction address, there might be a chance of incorrect    --
--    behavoir.                                                               --
--                                                                            --
--  o Interrupts are still experimental.                                      --
--                                                                            --
--------------------------------------------------------------------------------
-- Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mips1.all;
use work.tcpu.all;
use work.icpu.all;
use work.fcpu.all;


entity cpu is
   port(
      ci : in  cpu_in_t;
      co : out cpu_out_t
   );
end cpu;

architecture rtl of cpu is

   signal f, fin     : fe_t;        -- FE: [FETCH STAGE]
   signal d, din     : de_t;        -- DE: [DECODE STAGE]
   signal e, ein     : ex_t;        -- EX: [EXECUTION STAGE]
   signal m, min     : me_t;        -- ME: [MEMORY STAGE]
   signal cp, cpin   : cp0_t;       -- Coprocessor 0 registers

   -- Interrupt related signals.
   signal intr_bd    : boolean;              -- Branch delay flag.
   signal intr_bdd   : boolean;              -- Branch delay delay flag.
   signal intr_im    : std_logic_vector(7 downto 0);  -- Interrupt mask.
   signal intr_iec   : std_logic;            -- IEc: Interrupt enable current.
   signal intr_iep   : std_logic;            -- IEp: Interrupt enable previous.
   signal intr_ieo   : std_logic;            -- IEo: Interrupt enable old.

   -- Aliases for the instruction's GPR RS and RT addresses.
   alias rs_a : std_logic_vector(4 downto 0) is ci.ins(25 downto 21);
   alias rt_a : std_logic_vector(4 downto 0) is ci.ins(20 downto 16);

   signal rs_o, rt_o : std_logic_vector(31 downto 0);   -- GPR output data.
begin

   -----------------------------------------------------------------------------
   -- FETCH STAGE                                                             --
   -----------------------------------------------------------------------------
   fe : process(f.pc, ci.irq, e.f, d.cc, cp.epc, cp.sr, intr_bd, intr_im,
                intr_iec, intr_iep, intr_ieo)

      --------------------------------------------------------------------------
      -- EPC Address                                                          --
      --------------------------------------------------------------------------
      -- SETTING: Interrupt handler routine address.
      constant INTR_ADR : unsigned(31 downto 0) := x"200000c0";

      variable v : fe_t;
      variable c : cp0_t;
      
      variable intr : boolean;
   begin
      v := f;
      c := cp;

      -- Address of the next instruction to be fetched.
      co.iadr <= std_logic_vector(f.pc) & "00";

      -- Program Counter
      -- if e.f.jmp = '1' then
         -- v.pc := e.f.j;
      -- else if d.f.jmp = '1' then
         -- v.pc := d.f.j;
      -- else
         -- v.pc := f.pc + 1;
      -- end if;

      -- Program Counter
      if e.f.jmp = '1' then v.pc := e.f.j; else v.pc := f.pc + 1; end if;

      --------------------------------------------------------------------------
      -- INTR Interrupt                                                       --
      --------------------------------------------------------------------------
      -- The interrupt mechanism consists of several tasks:                   --
      --  o Push a '0' onto the IE stack to avoid further interrupt triggers. --
      --  o Set the EPC to the instruction following the current instruction. --
      --  o Jump to EPC_ADR, which is the hardcoded address of the interrupt  --
      --    dispatch routine.                                                 --
      --------------------------------------------------------------------------

      -- Restore from exception.
      -- Do before interrupt handling, or else we might push the IE stack twice.
      if d.cc.rfe then c := pop_ie(c); end if;

      -- Set SR of CP0. [DE]
      -- Set (Disable) SR before interrupt handling.
      if d.cc.mtsr then
         c.sr.im  := intr_im;
         c.sr.iec := intr_iec;
         c.sr.iep := intr_iep;
         c.sr.ieo := intr_ieo;
      end if;
               
      -- Delay interrupt if we are in one of the to delay slots. 
      -- Push the IE stack, Save return address and jump to the interrupt
      -- handler. 
      intr := ( (cp.sr.im and ci.irq) /= x"00" ) and (cp.sr.iec = '1');  
      
      if (not intr_bd) and (not intr_bdd) and intr then
         c     := push_ie(c);
         -- Save PC weather it is from a jump or just incremented.
         c.epc := v.pc; -- e.f.j or f.pc + 1.
         v.pc  := INTR_ADR(31 downto 2); 
      end if;     
      
      fin  <= v;
      cpin <= c;
   end process;



   -----------------------------------------------------------------------------
   -- DECODE STAGE                                                            --
   -----------------------------------------------------------------------------
   de : process(ci.ins, d, m, m.wc, d.cc, d.dc, d.ec, d.ec.alu, d.ec.alu.src,
                d.ec.jmp, d.mc, d.mc.mem, d.wc)

      variable v : de_t;

      alias rgcp0 : std_logic_vector(4 downto 0)  is ci.ins(15 downto 11);
   begin
      v := d;

      -- synthesis translate_off
         co.op   <= op(ci.ins);
         co.alu  <= aluop(ci.ins);
         co.rimm <= rimmop(ci.ins);
         co.cp0op <= cp0op(ci.ins);
         co.cp0reg <= cp0reg(ci.ins(4 downto 0));
      -- synthesis translate_on

      --------------------------------------------------------------------------
      -- Decode                                                               --
      --------------------------------------------------------------------------
      -- Default values emulate a NOP [SLL $0, $0, 0] operation.

      v.cc.mtsr      := false;   -- Move To Status Register. [INTR]
      v.cc.rfe       := false;   -- Restore from Exception.  [INTR]
      --v.f.jmp        := '0';
      --v.f.j          := (others => '-');
      v.ec.wbr       := RD;      -- Write back register.
      v.ec.alu.op    := SLL0;    -- ALU operation.          [ALU]
      v.ec.alu.src.a := REG;     -- Source for ALU input A. [ALU Source Choice]
      v.ec.alu.src.b := REG;     -- Source for ALU input B. [ALU Source Choice]
      v.ec.jmp.src   := REG;     -- Jump source.            [Branch/Jump]
      v.ec.jmp.op    := NOP;     -- Jump type.              [Branch/Jump]
      v.mc.mem.we    := '0';     -- Memory write enable.
      v.mc.mem.ext   := ZERO;    -- Memory data extension.  [Data Extension]
      v.mc.mem.byt   := NONE;    -- Number of data bytes.   [MEMORY STAGE]
      v.mc.src       := ALU;     -- ALU or MEM to GPR.      [MEMORY STAGE]
      v.wc.we        := '0';     -- GPR write enable.

      intr_bd        <= false;     -- Marks a branch delay slot. [INTR]

      case op(ci.ins) is
         when AD =>
            case aluop(ci.ins) is
               when JALR =>
                  v              := link(v);
                  v.ec.jmp.op    := JMP;
                  intr_bd        <= true;
               when JR =>
                  v.ec.jmp.op    := JMP;
                  intr_bd        <= true;
               when SLL0 | SRA0 | SRL0 =>
                  v.ec.alu.op    := aluop(ci.ins);
                  v.ec.alu.src.a := SH_CONST;
                  v.wc.we        := '1';
               when others =>
                  v.ec.alu.op    := aluop(ci.ins);
                  v.wc.we        := '1';
            end case;

         -----------------------------------------------------------------------
         -- Immediate Branches                                                --
         -----------------------------------------------------------------------
         when RI =>
            case rimmop(ci.ins) is
               when BGEZ =>
                  v.ec.jmp.src   := BRA;
                  v.ec.jmp.op    := GEZ;
                  intr_bd        <= true;
               when BGEZAL =>
                  v              := link(v);
                  v.ec.wbr       := RA;
                  v.ec.jmp.src   := BRA;
                  v.ec.jmp.op    := GEZ;
                  intr_bd        <= true;
               when BLTZ =>
                  v.ec.jmp.src   := BRA;
                  v.ec.jmp.op    := LTZ;
                  intr_bd        <= true;
               when BLTZAL =>
                  v              := link(v);
                  v.ec.wbr       := RA;
                  v.ec.jmp.src   := BRA;
                  v.ec.jmp.op    := LTZ;
                  intr_bd        <= true;
               when ERR =>
            end case;

         -----------------------------------------------------------------------
         -- Normal Jumps/Branches                                             --
         -----------------------------------------------------------------------
         when J =>
         -- v.f.jmp        := '1';
         -- v.f.j          := f.pc(31 downto 28) & unsigned(ci.ins);
            v.ec.jmp.src   := JMP;
            v.ec.jmp.op    := JMP;
            intr_bd        <= true;
         when JAL =>
            v              := link(v);
            v.ec.wbr       := RA;
         -- v.f.jmp        := '1';
         -- v.f.j          := f.pc(31 downto 28) & unsigned(ci.ins);
            v.ec.jmp.src   := JMP;
            v.ec.jmp.op    := JMP;
            intr_bd        <= true;
         when BEQ =>
            v.ec.jmp.src   := BRA;
            v.ec.jmp.op    := EQ;
            intr_bd        <= true;
         when BNE =>
            v.ec.jmp.src   := BRA;
            v.ec.jmp.op    := NEQ;
            intr_bd        <= true;
         when BLEZ =>
            v.ec.jmp.src   := BRA;
            v.ec.jmp.op    := LEZ;
            intr_bd        <= true;
         when BGTZ =>
            v.ec.jmp.src   := BRA;
            v.ec.jmp.op    := GTZ;
            intr_bd        <= true;

         -----------------------------------------------------------------------
         -- Immediate Operations                                              --
         -----------------------------------------------------------------------
         when ADDI =>
            v              := simm(v);
            v.ec.alu.op    := ADD;
         when ADDIU =>
            v              := simm(v);
            v.ec.alu.op    := ADDU;
         when SLTI =>
            v              := simm(v);
            v.ec.alu.op    := SLT;
         when SLTIU =>
            v              := simm(v);
            v.ec.alu.op    := SLTU;
         when ANDI =>
            v              := zimm(v);
            v.ec.alu.op    := AND0;
         when ORI =>
            v              := zimm(v);
            v.ec.alu.op    := OR0;
         when XORI =>
            v              := zimm(v);
            v.ec.alu.op    := XOR0;
         when LUI =>
            v              := zimm(v);
            v.ec.alu.src.a := SH_16;

         -----------------------------------------------------------------------
         -- Load And Store Data                                               --
         -----------------------------------------------------------------------
         when LB =>
            v              := load(v);
            v.mc.mem.ext   := SIGN;
            v.mc.mem.byt   := BYTE;
         when LH =>
            v              := load(v);
            v.mc.mem.ext   := SIGN;
            v.mc.mem.byt   := HALF;
         when LW =>
            v              := load(v);
            v.mc.mem.byt   := WORD;
         when LBU =>
            v              := load(v);
            v.mc.mem.byt   := BYTE;
         when LHU =>
            v              := load(v);
            v.mc.mem.byt   := HALF;
         when SB =>
            v              := store(v);
            v.mc.mem.byt   := BYTE;
         when SH =>
            v              := store(v);
            v.mc.mem.byt   := HALF;
         when SW =>
            v              := store(v);
            v.mc.mem.byt   := WORD;

         -----------------------------------------------------------------------
         -- Co-Processor 0                                                    --
         -----------------------------------------------------------------------
         when CP0 =>
            case cp0op(ci.ins) is
               when MFCP0 =>
                  v.ec.wbr    := RT;
                  v.ec.alu.op := MFCP0;
                  v.wc.we     := '1';
               when MTCP0 =>
                  v.ec.alu.op := MTCP0;
                  if cp0reg(rgcp0) = SR then v.cc.mtsr := true; end if;
               when RFE   =>
                  v.ec.alu.op := RFE;
                  v.cc.rfe    := true;
               when ERR   =>
            end case;
         when ERR =>
      end case;

      v.i     := ci.ins(25 downto 0);
      v.dc.we := m.wc.we;              -- Forward write enable.
      v.rd    := m.rd;                 -- Forward destination register.
      v.res   := m.res;                -- Forward data.
      din <= v;
   end process;

   -----------------------------------------------------------------------------
   -- GPR General Purpose Registers                                           --
   -----------------------------------------------------------------------------
   gp : gpr port map(
      clk_i => ci.clk,        -- Clock.
      hld_i => ci.hld,        -- Hold register data.
      rs_a  => rs_a,          -- RS register address.
      rt_a  => rt_a,          -- RT register address.
      rd_a  => m.rd,          -- Write back register address.
      rd_we => m.wc.we,       -- Write back enable.
      rd_i  => m.res,         -- Write back register data.
      rs_o  => rs_o,          -- RS register data.
      rt_o  => rt_o           -- RT register data.
   );



   -----------------------------------------------------------------------------
   -- EXECUTION STAGE                                                         --
   -----------------------------------------------------------------------------
   ex : process(ci.irq, rs_o, rt_o, cp, cp.sr, f, d, d.dc, d.ec, d.ec.alu,
                d.ec.alu.src, d.ec.jmp, d.mc, d.mc.mem, d.wc, e, e.f, e.mc,
                e.mc.mem, e.wc, m, m.wc)

      variable v        : ex_t;
      variable a, b     : std_logic_vector(31 downto 0);    -- ALU input.
      variable fa, fb   : std_logic_vector(31 downto 0);    -- Forwarded data.
      variable equ, eqz : std_logic;                        -- fa=fb, fa=0
      variable atmp     : std_logic_vector(31 downto 0);    -- Temporary result.

      --------------------------------------------------------------------------
      --   R-Type Register                                                    --
      --   +--------------------------------------------------------------+   --
      --   |              |   rgs   |   rgt   |   rgd   |  smt  |         |   --
      --   +--------------------------------------------------------------+   --
      --   I-Type Register                                                    --
      --   +--------------------------------------------------------------+   --
      --   |                             |             imm                |   --
      --   +--------------------------------------------------------------+   --
      --------------------------------------------------------------------------
      alias rgs : std_logic_vector(4 downto 0)  is d.i(25 downto 21);
      alias rgt : std_logic_vector(4 downto 0)  is d.i(20 downto 16);
      alias rgd : std_logic_vector(4 downto 0)  is d.i(15 downto 11);
      alias imm : std_logic_vector(15 downto 0) is d.i(15 downto 0);
      alias smt : std_logic_vector(4 downto 0)  is d.i(10 downto 6);
   begin
      v := e;

      -- Choose the write back register.
      case d.ec.wbr is
         when RD => v.rd := rgd;
         when RT => v.rd := rgt;
         when RA => v.rd := b"11111";
      end case;

      --------------------------------------------------------------------------
      -- Forwarding                                                           --
      --------------------------------------------------------------------------
      -- In a pipeline there can be data that has not been written into the   --
      -- GPR registers yet. For example see:                                  --
      --                                                                      --
      --          addu $t0, $t1, $t2 -+                                       --
      --          sll  $t3, $t0, 4   -+- $t0                                  --
      --                                                                      --
      -- Here GPR $t0 is not up to date, since the instruction addu           --
      -- manipulates $t0, but is available after EX, so we choose the newer   --
      -- data from after the EX stage instead of the GPR data.                --
      -- However, if we load data and use it in the next instruction, we get  --
      -- the wrong result. Loaded data is available two cycles after the load --
      -- instruction. The compiler solves this problem, since it inserts an   --
      -- independend instruction or a NOP operation.                          --
      -- Other problems arise when:                                           --
      --                                                                      --
      --          ori  $t0, $s1, 3   -+                                       --
      --          sw   $s2, 4($sp)    |                                       --
      --          subu $s2, $t0, $s3 -+- $t0                                  --
      --                                                                      --
      -- In the second example, the updated data is available after the ME    --
      -- stage. Up untill now we considered the situation from the viewpoint  --
      -- of the EX stage.                                                     --
      --                                                                      --
      --          andi $t0, $t0, 1   -+                                       --
      --          lui  $s1, 0xf4      |                                       --
      --          lw   $s2, 0($sp)    |                                       --
      --          sra  $t1, $t0, 3   -+- $t0                                  --
      --                                                                      --
      -- The third example shows a problem that arrises one cycle earlier.    --
      -- When we read the register contents. The data to be written is        --
      -- present as well but not available yet. One solution might be, to     --
      -- prefer write before read operations. the other way suggests to store --
      -- the write back data, address and write enable flag one more cycle.   --
      -- We can then decide in the EX stage again if the data is more recent. --
      --------------------------------------------------------------------------
      fa := rs_o;
      fb := rt_o;

      -- Forward from Write Back Stage (Data stored in DE Stage).
      if (d.rd /= "00000") and (d.dc.we = '1') then
         if rgs = d.rd then fa := d.res; end if;
         if rgt = d.rd then fb := d.res; end if;
      end if;

      -- Forward from Memory Stage.
      if (m.rd /= "00000") and (m.wc.we = '1') then
            if rgs = m.rd then fa := m.res; end if;
            if rgt = m.rd then fb := m.res; end if;
      end if;

      -- Forward from Execution Stage.
      if (e.rd /= "00000") and (e.wc.we = '1') then
            if rgs = e.rd then fa := e.res; end if;
            if rgt = e.rd then fb := e.res; end if;
      end if;

      --------------------------------------------------------------------------
      -- ALU Source Choice                                                    --
      --------------------------------------------------------------------------
      -- SH_CONST: Constant shift amount (SLL, SRL, SRA).                     --
      -- SH_16:    Shift 16-bit (LUI).                                        --
      -- ADD_4:    Plus 4.                                                    --
      -- REG:      Forwarded RS register value. [Forwarding]                  --
      --------------------------------------------------------------------------
      case d.ec.alu.src.a is
         when SH_CONST => a := zext(smt, 32);
         when SH_16    => a := zext(b"10000", 32);
         when ADD_4    => a := zext(b"00100", 32);
         when REG      => a := fa;
      end case;

      --------------------------------------------------------------------------
      -- SIGN: Sign extend 16-bit immediate value according to MSB.           --
      -- ZERO: Zero extend 16-bit immediate value.                            --
      -- PC:   Current PC value.                                              --
      -- REG:  Forwarded RT register value. [Forwarding]                      --
      --------------------------------------------------------------------------
      case d.ec.alu.src.b is
         when SIGN => b := sext(imm, 32);
         when ZERO => b := zext(imm, 32);
         when PC   => b := std_logic_vector(f.pc) & "00";
         when REG  => b := fb;
      end case;

      --------------------------------------------------------------------------
      -- ALU                                                                  --
      --------------------------------------------------------------------------
      -- IMPROVE: optimze SLT,SLTU.
      intr_iec <= b(0);            -- IEc: Interrupt enable current.   [INTR]
      intr_iep <= b(2);            -- IEp: Interrupt enable previous.  [INTR]
      intr_ieo <= b(4);            -- IEo: Interrupt enable old.       [INTR]
      intr_im  <= b(15 downto 8);  -- Interrupt mask.                  [INTR]

      atmp  := addsub(a, b, d.ec.alu.op);
      v.res := (others => '0');

      case d.ec.alu.op is
         when ADD  | ADDU |
              SUB  | SUBU => v.res := atmp;
         when SLT         => v.res := fslt(a, b);
         when SLTU        => v.res := fsltu(a, b);
         when SLL0 | SLLV => v.res := fsll(b, a(4 downto 0));
         when SRA0 | SRAV => v.res := fsra(b, a(4 downto 0));
         when SRL0 | SRLV => v.res := fsrl(b, a(4 downto 0));
         when AND0        => v.res := a and b;
         when OR0         => v.res := a or  b;
         when NOR0        => v.res := a nor b;
         when XOR0        => v.res := a xor b;
         when JALR | JR   =>
         when MFCP0       =>
            case cp0reg(rgd) is
               when SR    => v.res := get_sr(cp);
               when CAUSE => v.res(15 downto 8) := ci.irq;
               when EPC   => v.res := std_logic_vector(cp.epc) & "00";
               when ERR   =>
            end case;
         when MTCP0       =>     -- MTCP0 and RFE operations are handled at the
         when RFE         =>     -- IF stage.
         when ERR         =>
      end case;

      --------------------------------------------------------------------------
      -- Branch/Jump                                                          --
      --------------------------------------------------------------------------
      -- IMPROVE: move jump to DE stage.
      if fa = fb then equ := '1'; else equ := '0'; end if;
      if fa = x"00000000" then eqz := '1'; else eqz := '0'; end if;

      case d.ec.jmp.op is
         when NOP => v.f.jmp := '0';
         when JMP => v.f.jmp := '1';
         when EQ  => v.f.jmp := equ;
         when NEQ => v.f.jmp := not equ;
         when LTZ => v.f.jmp := fa(31);
         when GTZ => v.f.jmp := not (fa(31) or eqz);
         when LEZ => v.f.jmp := fa(31) or eqz;
         when GEZ => v.f.jmp := not fa(31);
      end case;

      case d.ec.jmp.src is
         when REG => v.f.j := unsigned(fa(31 downto 2));
         when JMP => v.f.j := f.pc(31 downto 28) & unsigned(d.i);
         when BRA => v.f.j := unsigned(to_integer(f.pc) + signed(sext(imm,30)));
      end case;

      v.mc  := d.mc;
      v.wc  := d.wc;
      v.str := fb;
      ein   <= v;
   end process;



   -----------------------------------------------------------------------------
   -- MEMORY STAGE                                                            --
   -----------------------------------------------------------------------------
   me : process(ci.dat, e, e.mc, e.mc.mem, e.wc, m, m.wc)
      variable v   : me_t;
      variable dat : std_logic_vector(31 downto 0);   -- Fetched memory data
   begin
      v := m;

      co.we   <= e.mc.mem.we;
      co.dadr <= e.res;
      co.dat  <= e.str;

      --------------------------------------------------------------------------
      -- Address Decode                                                       --
      --------------------------------------------------------------------------
      -- Translate lower address bits to Wishbone Bus selection scheme.       --
      --------------------------------------------------------------------------
      case e.mc.mem.byt is
         when NONE => co.sel <= "0000";
         when BYTE =>
            case e.res(1 downto 0) is
               when "00"   => co.sel <= "1000";
               when "01"   => co.sel <= "0100";
               when "10"   => co.sel <= "0010";
               when "11"   => co.sel <= "0001";
               when others => co.sel <= "0000";
            end case;
         when HALF =>
            case e.res(1) is
               when '0'    => co.sel <= "1100";
               when '1'    => co.sel <= "0011";
               when others => co.sel <= "0000";
            end case;
         when WORD => co.sel <= "1111";
      end case;

      --------------------------------------------------------------------------
      -- Data Extension                                                       --
      --------------------------------------------------------------------------
      -- Fetched data can be extended with zeros or according to its MSB.     --
      --------------------------------------------------------------------------
      case e.mc.mem.byt is
         when NONE => dat := (others => '0');   -- AREA: (others => '-');
         when BYTE =>
            case e.mc.mem.ext is
               when ZERO => dat := zext(ci.dat(7 downto 0), 32);
               when SIGN => dat := sext(ci.dat(7 downto 0), 32);
            end case;
         when HALF =>
            case e.mc.mem.ext is
               when ZERO => dat := zext(ci.dat(15 downto 0), 32);
               when SIGN => dat := sext(ci.dat(15 downto 0), 32);
            end case;
         when WORD => dat := ci.dat;
      end case;

      case e.mc.src is
         when ALU => v.res := e.res;      -- Take either the result of the ALU
         when MEM => v.res := dat;        -- or the loaded data from memory.
      end case;

      v.wc := e.wc;
      v.rd := e.rd;
      min  <= v;
   end process;



   -----------------------------------------------------------------------------
   -- REGISTERS                                                               --
   -----------------------------------------------------------------------------
   reg : process(ci.clk)
   begin
      if rising_edge(ci.clk) then
         if ci.hld = '0' then
            f  <= fin;     -- IF
            d  <= din;     -- DE
            e  <= ein;     -- EX
            m  <= min;     -- ME
            cp <= cpin;    -- CP0

            --------------------------------------------------------------------
            -- Branch Correction                                              --
            --------------------------------------------------------------------
            -- The simplest way one can think of, is to consider every branch --
            -- or jump to be NOT taken and to load instructions in sequence.  --
            -- If we actually do jump, we already loaded an incorrect         --
            -- instruction in the IF stage. To anihilate the effects of this  --
            -- instruction, we will clear the DE stage one cycle later.       --
            -- [fcpu.clear(v_i : de_t)]                                       --
            --------------------------------------------------------------------
            if e.f.jmp = '1' then d <= clear(d); end if;

            -- Set Branch Delay Delay slot flag.
            intr_bdd <= intr_bd;
         end if;

         -- On reset clear all relevant control signals.
         if ci.rst = '1' then
            f  <= clear(f);   -- IF
            d  <= clear(d);   -- DE
            e  <= clear(e);   -- EX
            m  <= clear(m);   -- ME
            cp <= clear(cp);  -- CP0
         end if;
      end if;
   end process;
end rtl;