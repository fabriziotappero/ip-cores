	/* Assembly source, with one of every instruction for the or1k
	instruction set */

  l.j 0x1234
  l.jal 0
  l.bnf 0
  l.bf 0
  l.nop 0
  l.movhi r0, 0
  l.macrc r3
  l.sys 4
  l.trap 54
  l.msync 
  l.psync
  l.csync
  l.rfe
/*	
  lv.all_eq.b r0, r1, r2
  lv.all_eq.h r0, r1, r2
  lv.all_ge.b r0, r1, r2
  lv.all_ge.h r0, r1, r2
  lv.all_gt.b r0, r1, r2
  lv.all_gt.h r0, r1, r2
  lv.all_le.b r0, r1, r2
  lv.all_le.h r0, r1, r2
  lv.all_lt.b r0, r1, r2
  lv.all_lt.h r0, r1, r2
  lv.all_ne.b r0, r1, r2
  lv.all_ne.h r0, r1, r2
  lv.any_eq.b r0, r1, r2
  lv.any_eq.h r0, r1, r2
  lv.any_ge.b r0, r1, r2
  lv.any_ge.h r0, r1, r2
  lv.any_gt.b r0, r1, r2
  lv.any_gt.h r0, r1, r2
  lv.any_le.b r0, r1, r2
  lv.any_le.h r0, r1, r2
  lv.any_lt.b r0, r1, r2
  lv.any_lt.h r0, r1, r2
  lv.any_ne.b r0, r1, r2
  lv.any_ne.h r0, r1, r2
  lv.add.b r0, r1, r2
  lv.add.h r0, r1, r2
  lv.adds.b r0, r1, r2
  lv.adds.h r0, r1, r2
  lv.addu.b r0, r1, r2
  lv.addu.h r0, r1, r2
  lv.addus.b r0, r1, r2
  lv.addus.h r0, r1, r2
  lv.and r0, r1, r2
  lv.avg.b r0, r1, r2
  lv.avg.h r0, r1, r2
  lv.cmp_eq.b r0, r1, r2
  lv.cmp_eq.h r0, r1, r2
  lv.cmp_ge.b r0, r1, r2
  lv.cmp_ge.h r0, r1, r2
  lv.cmp_gt.b r0, r1, r2
  lv.cmp_gt.h r0, r1, r2
  lv.cmp_le.b r0, r1, r2
  lv.cmp_le.h r0, r1, r2
  lv.cmp_lt.b r0, r1, r2
  lv.cmp_lt.h r0, r1, r2
  lv.cmp_ne.b r0, r1, r2
  lv.cmp_ne.h r0, r1, r2
  lv.madds.h r0, r1, r2
  lv.max.b r0, r1, r2
  lv.max.h r0, r1, r2
  lv.merge.b r0, r1, r2
  lv.merge.h r0, r1, r2
  lv.min.b r0, r1, r2
  lv.min.h r0, r1, r2
  lv.msubs.h r0, r1, r2
  lv.muls.h r0, r1, r2
  lv.nand r0, r1, r2
  lv.nor r0, r1, r2
  lv.or r0, r1, r2
  lv.pack.b r0, r1, r2
  lv.pack.h r0, r1, r2
  lv.packs.b r0, r1, r2
  lv.packs.h r0, r1, r2
  lv.packus.b r0, r1, r2
  lv.packus.h r0, r1, r2
  lv.perm.n r0, r1, r2
  lv.rl.b r0, r1, r2
  lv.rl.h r0, r1, r2
  lv.sll.b r0, r1, r2
  lv.sll.h r0, r1, r2
  lv.sll r0, r1, r2
  lv.srl.b r0, r1, r2
  lv.srl.h r0, r1, r2
  lv.sra.b r0, r1, r2
  lv.sra.h r0, r1, r2
  lv.srl r0, r1, r2
  lv.sub.b r0, r1, r2
  lv.sub.h r0, r1, r2
  lv.subs.b r0, r1, r2
  lv.subs.h r0, r1, r2
  lv.subu.b r0, r1, r2
  lv.subu.h r0, r1, r2
  lv.subus.b r0, r1, r2
  lv.subus.h r0, r1, r2
  lv.unpack.b r0, r1, r2
  lv.unpack.h r0, r1, r2
  lv.xor r0, r1, r2
  lv.cust1
  lv.cust2
  lv.cust3
  lv.cust4
*/
  l.jr r0
  l.jalr r0
  l.maci r0, 4
  l.cust1
  l.cust2
  l.cust3
  l.cust4

  l.ld r0, 0(r0)
  l.lwz r0, 0(r0)
  l.lws r0, 0(r0)
  l.lbz r0, 0(r0)
  l.lbs r0, 0(r0)
  l.lhz r0, 0(r0)
  l.lhs r0, 0(r0)

  l.addi r0, r1, 5
  l.addic r0, r1, 5
  l.andi r0, r1, 5
  l.ori r0, r1, 5
  l.xori r0, r1, 5
  l.muli r0, r1, 5
  l.mfspr r0, r1, 5
  l.slli r0, r1, 5
  l.srli r0, r1, 5
  l.srai r0, r1, 5
  l.rori r0, r1, 5

  l.sfeqi r0, 0
  l.sfnei r0, 0
  l.sfgtui r0, 0
  l.sfgeui r0, 0
  l.sfltui r0, 0
  l.sfleui r0, 0
  l.sfgtsi r0, 0
  l.sfgesi r0, 0
  l.sfltsi r0, 0
  l.sflesi r0, 0

  l.mtspr r0, r1, 4
  l.mac r0, r1
  l.msb r0, r1

  lf.add.s r0, r1, r2
  lf.sub.s r0, r1, r2
  lf.mul.s r0, r1, r2
  lf.div.s r0, r1, r2
  lf.itof.s r0, r1
  lf.ftoi.s r0, r1
  lf.rem.s r0, r1, r1
  lf.madd.s r0, r1, r1
  lf.sfeq.s r0, r1
  lf.sfne.s r0, r1
  lf.sfgt.s r0, r1
  lf.sfge.s r0, r1
  lf.sflt.s r0, r1
  lf.sfle.s r0, r1
  lf.cust1.s r0, r1

  lf.add.d r0, r1, r2
  lf.sub.d r0, r1, r2
  lf.mul.d r0, r1, r2
  lf.div.d r0, r1, r2
  lf.itof.d r0, r1
  lf.ftoi.d r0, r1
  lf.rem.d r0, r1, r2
  lf.madd.d r0, r1, r2
  lf.sfeq.d r0, r1
  lf.sfne.d r0, r1
  lf.sfgt.d r0, r1
  lf.sfge.d r0, r1
  lf.sflt.d r0, r1
  lf.sfle.d r0, r1
  lf.cust1.d r0, r1

  l.sd 0(r0), r1
  l.sw 0(r0), r1
  l.sb 0(r0), r1
  l.sh 0(r0), r1

  l.add r0, r1, r2
  l.addc r0, r1, r2
  l.sub r0, r1, r2
  l.and r0, r1, r2
  l.or r0, r1, r2
  l.xor r0, r1, r2
  l.mul r0, r1, r2

  l.sll r0, r1, r2
  l.srl r0, r1, r2
  l.sra r0, r1, r2
  l.ror r0, r1, r2
  l.div r0, r1, r2
  l.divu r0, r1, r2
  l.mulu r0, r1, r2
  l.extbs r0, r1
  l.exths r0, r1
  l.extws r0, r1
  l.extbz r0, r1
  l.exthz r0, r1
  l.extwz r0, r1
  l.cmov r0, r1, r2
  l.ff1 r0, r1
  l.fl1 r0, r1

  l.sfeq r0, r1
  l.sfne r0, r1
  l.sfgtu r0, r1
  l.sfgeu r0, r1
  l.sfltu r0, r1
  l.sfleu r0, r1
  l.sfgts r0, r1
  l.sfges r0, r1
  l.sflts r0, r1
  l.sfles r0, r1

