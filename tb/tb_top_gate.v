/* verilator lint_off UNUSED */
/* verilator lint_off CASEX */
/* verilator lint_off PINNOCONNECT */
/* verilator lint_off PINMISSING */
/* verilator lint_off IMPLICIT */
/* verilator lint_off WIDTH */
/* verilator lint_off COMBDLY */


`ifndef verilator
module tb_top_gate ();
wire  [1:0] Ae;
wire [15:0] DB;
wire [23:0] Ad;
wire        LB,UB;
reg         RXD,clk,rstn;
`else
module tb_top_gate (rstn,clk,RXD);
input rstn,clk,RXD;
wire  [1:0] Ae;
wire [15:0] DB;
wire [23:0] Ad;
wire        LB,UB;
`endif


TOP_SYS U_TOP (
.TXD(TXD),.rstn(rstn),.clk(clk), .RXD(RXD),
.extWEN(WEN),.extUB(UB),.extLB(LB),.extA(Ad),.extDB(DB), .extOE(OE),  .extCRE(), .extADV(), .extCLK(),
.gpio_in(7'b000_0011)
);

extram uextram(.clk(clk) , .DB(DB) , .A(Ad) , .WEN(WEN) ,.LB(LB), .UB(UB), .OE(OE) );

`ifndef verilator
initial
begin
RXD =1;
clk=0;
rstn =0;
#33;
rstn = 1;



$dumpfile("test.vcd");

$dumpvars (0,U_TOP.gpioA);

$dumpvars (0,U_TOP.uram_ctlr.fsm_ram);
$dumpvars (0,U_TOP.uram_ctlr.wb_dat_i);
$dumpvars (0,U_TOP.uram_ctlr.wb_dat_o);
$dumpvars (0,U_TOP.uram_ctlr.wb_adr_i);
$dumpvars (0,U_TOP.uram_ctlr.wb_sel_i);
$dumpvars (0,U_TOP.uram_ctlr.wb_we_i);
$dumpvars (0,U_TOP.uram_ctlr.wb_stb_i);
$dumpvars (0,U_TOP.uram_ctlr.wb_ack_o);
$dumpvars (0,U_TOP.uram_ctlr.wb_cti_i);


$dumpvars (0,U_TOP.v586.U8259.inter_input);
$dumpvars (0,U_TOP.v586.gpio_out);
$dumpvars (0,U_TOP.v586.int_pic);
$dumpvars (0,U_TOP.v586.ivect);
$dumpvars (0,U_TOP.v586.iack);
$dumpvars (0,U_TOP.v586.rtc_irq);
$dumpvars (0,U_TOP.v586.pit_irq);
$dumpvars (0,U_TOP.v586.rdio_spk);
$dumpvars (0,U_TOP.v586.rdio_pit);
$dumpvars (0,U_TOP.v586.csn_16750);
$dumpvars (0,U_TOP.v586.rdn_16750);
$dumpvars (0,U_TOP.v586.wrn_16750);
$dumpvars (0,U_TOP.v586.readio_data_f);
$dumpvars (0,U_TOP.v586.rdio_16750);
$dumpvars (0,U_TOP.v586.TXD);
$dumpvars (0,U_TOP.v586.RXD);
$dumpvars (0,U_TOP.v586.int4);
$dumpvars (0,U_TOP.v586.pit_irq);
$dumpvars (0,U_TOP.v586.rtc_irq);

$dumpvars(0,U_TOP.uextrom.A);
$dumpvars(0,U_TOP.uextrom.Q);


$dumpvars(0,uextram.A);
$dumpvars(0,uextram.DB);
$dumpvars(0,uextram.OE);
$dumpvars(0,uextram.WEN);
$dumpvars(0,uextram.LB);
$dumpvars(0,uextram.UB);

$dumpvars(0,U_TOP.extA);
$dumpvars(0,U_TOP.extDB);
$dumpvars(0,U_TOP.extOE);
$dumpvars(0,U_TOP.extWEN);
$dumpvars(0,U_TOP.extCSN);
$dumpvars(0,U_TOP.extUB);
$dumpvars(0,U_TOP.extLB);
$dumpvars(0,U_TOP.extDB);
$dumpvars(0,U_TOP.extADV);

$dumpvars(0,U_TOP.v586.ucore.code_addr);
$dumpvars(0,U_TOP.v586.ucore.code_data);
$dumpvars(0,U_TOP.v586.ucore.write_sz);
$dumpvars(0,U_TOP.v586.ucore.readio_data);
$dumpvars(0,U_TOP.v586.ucore.io_add);
$dumpvars(0,U_TOP.v586.ucore.writeio_data);
$dumpvars(0,U_TOP.v586.ucore.writeio_req);
$dumpvars(0,U_TOP.v586.ucore.Daddr);

$dumpvars(0,U_TOP.v586.ubiu.read_sz);
$dumpvars(0,U_TOP.v586.ubiu.write_sz);
$dumpvars(0,U_TOP.v586.ubiu.A);
$dumpvars(0,U_TOP.v586.ubiu.Ab);
$dumpvars(0,U_TOP.v586.ubiu.Am);
$dumpvars(0,U_TOP.v586.ubiu.busy);
$dumpvars(0,U_TOP.v586.ubiu.fsm);
$dumpvars(0,U_TOP.v586.ubiu.code_wreq);
$dumpvars(0,U_TOP.v586.ubiu.code_wack);
$dumpvars(0,U_TOP.v586.ubiu.code_req);
$dumpvars(0,U_TOP.v586.ubiu.code_ack);
$dumpvars(0,U_TOP.v586.ubiu.code_data);
$dumpvars(0,U_TOP.v586.ubiu.write_req);
$dumpvars(0,U_TOP.v586.ubiu.write_ack);
$dumpvars(0,U_TOP.v586.ubiu.read_req);
$dumpvars(0,U_TOP.v586.ubiu.read_ack);
$dumpvars(0,U_TOP.v586.ubiu.read_data);

$dumpvars(0,U_TOP.v586.ucore.i_acu.add_src);
$dumpvars(0,U_TOP.v586.ucore.i_acu.reg_index);
$dumpvars(0,U_TOP.v586.ucore.i_acu.reg_base);
$dumpvars(0,U_TOP.v586.ucore.i_acu.in128);
$dumpvars(0,U_TOP.v586.ucore.i_acu.to_regf);
$dumpvars(0,U_TOP.v586.ucore.i_acu.indrm);
$dumpvars(0,U_TOP.v586.ucore.i_acu.in128);
$dumpvars(0,U_TOP.v586.ucore.i_acu.mod_dec);
$dumpvars(0,U_TOP.v586.ucore.i_acu.db67);
$dumpvars(0,U_TOP.v586.ucore.from_acu);

$dumpvars(0,U_TOP.v586.ucore.i_useq.superhit);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagA1);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagA2);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagA3);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagA4);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagA5);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagA6);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagA7);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagA8);

$dumpvars(0,U_TOP.v586.ucore.i_useq.tagD1);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagD2);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagD3);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagD4);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagD5);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagD6);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagD7);
$dumpvars(0,U_TOP.v586.ucore.i_useq.tagD8);

$dumpvars(0,U_TOP.v586.ucore.i_useq.last1);
$dumpvars(0,U_TOP.v586.ucore.i_useq.last2);
$dumpvars(0,U_TOP.v586.ucore.i_useq.last3);
$dumpvars(0,U_TOP.v586.ucore.i_useq.last4);
$dumpvars(0,U_TOP.v586.ucore.i_useq.last5);
$dumpvars(0,U_TOP.v586.ucore.i_useq.last6);
$dumpvars(0,U_TOP.v586.ucore.i_useq.last7);
$dumpvars(0,U_TOP.v586.ucore.i_useq.last8);

$dumpvars(0,U_TOP.v586.ucore.i_useq.wen1);
$dumpvars(0,U_TOP.v586.ucore.i_useq.wen2);
$dumpvars(0,U_TOP.v586.ucore.i_useq.wen3);
$dumpvars(0,U_TOP.v586.ucore.i_useq.wen4);
$dumpvars(0,U_TOP.v586.ucore.i_useq.wen5);
$dumpvars(0,U_TOP.v586.ucore.i_useq.wen6);
$dumpvars(0,U_TOP.v586.ucore.i_useq.wen7);
$dumpvars(0,U_TOP.v586.ucore.i_useq.wen8);

$dumpvars(0,U_TOP.v586.ucore.i_useq.cout1);
$dumpvars(0,U_TOP.v586.ucore.i_useq.cout2);
$dumpvars(0,U_TOP.v586.ucore.i_useq.cout3);
$dumpvars(0,U_TOP.v586.ucore.i_useq.cout4);
$dumpvars(0,U_TOP.v586.ucore.i_useq.cout5);
$dumpvars(0,U_TOP.v586.ucore.i_useq.cout6);
$dumpvars(0,U_TOP.v586.ucore.i_useq.cout7);
$dumpvars(0,U_TOP.v586.ucore.i_useq.cout8);

$dumpvars(0,U_TOP.v586.ucore.i_useq.sel);
$dumpvars(0,U_TOP.v586.ucore.i_useq.selb);


$dumpvars(0,U_TOP.v586.ucore.i_useq.lastjmp);
$dumpvars(0,U_TOP.v586.ucore.i_useq.evershifted);
$dumpvars(0,U_TOP.v586.ucore.i_useq.everfilled);


$dumpvars(0,U_TOP.v586.ucore.i_useq.pc_pg_fault);
$dumpvars(0,U_TOP.v586.ucore.i_useq.pg_fault);
$dumpvars(0,U_TOP.v586.ucore.i_useq.fault_cnt);
$dumpvars(0,U_TOP.v586.ucore.i_useq.fault_wptr);
$dumpvars(0,U_TOP.v586.ucore.i_useq.fault_wptr_en);
$dumpvars(0,U_TOP.v586.ucore.i_useq.wptr);
$dumpvars(0,U_TOP.v586.ucore.i_useq.addr);
$dumpvars(0,U_TOP.v586.ucore.i_useq.waddr);
$dumpvars(0,U_TOP.v586.ucore.i_useq.idata);
$dumpvars(0,U_TOP.v586.ucore.i_useq.addrshft);
$dumpvars(0,U_TOP.v586.ucore.i_useq.useq_ptr);
$dumpvars(0,U_TOP.v586.ucore.i_useq.queue);
$dumpvars(0,U_TOP.v586.ucore.i_useq.squeue);
$dumpvars(0,U_TOP.v586.ucore.i_useq.pc_in);
$dumpvars(0,U_TOP.v586.ucore.i_useq.pc_req);
$dumpvars(0,U_TOP.v586.ucore.i_useq.useq_ptr);
$dumpvars(0,U_TOP.v586.ucore.i_useq.useq_ptr_dly);
$dumpvars(0,U_TOP.v586.ucore.i_useq.useq_gnt);
$dumpvars(0,U_TOP.v586.ucore.i_useq.code_req);
$dumpvars(0,U_TOP.v586.ucore.i_useq.code_ack);
$dumpvars(0,U_TOP.v586.ucore.i_useq.stall_queue); 
$dumpvars(0,U_TOP.v586.ucore.i_useq.hit_ack); 
 
$dumpvars(0,U_TOP.v586.ucore.i_deco.int_main);
$dumpvars(0,U_TOP.v586.ucore.i_deco.ivect);
$dumpvars(0,U_TOP.v586.ucore.i_deco.iack);
$dumpvars(0,U_TOP.v586.ucore.i_deco.imm);
$dumpvars(0,U_TOP.v586.ucore.i_deco.imm_sz);
$dumpvars(0,U_TOP.v586.ucore.i_deco.mod_dec);
$dumpvars(0,U_TOP.v586.ucore.i_deco.in128);
$dumpvars(0,U_TOP.v586.ucore.i_deco.r128);
$dumpvars(0,U_TOP.v586.ucore.i_deco.fsm);
$dumpvars(0,U_TOP.v586.ucore.i_deco.fsmf);
$dumpvars(0,U_TOP.v586.ucore.i_deco.op);
$dumpvars(0,U_TOP.v586.ucore.i_deco.useq_ptr);
$dumpvars(0,U_TOP.v586.ucore.i_deco.to_vliw);
$dumpvars(0,U_TOP.v586.ucore.i_deco.term);
$dumpvars(0,U_TOP.v586.ucore.i_deco.start);
$dumpvars(0,U_TOP.v586.ucore.i_deco.opz);
$dumpvars(0,U_TOP.v586.ucore.i_deco.rep);
$dumpvars(0,U_TOP.v586.ucore.i_deco.repz);
$dumpvars(0,U_TOP.v586.ucore.i_deco.pfx_sz);
$dumpvars(0,U_TOP.v586.ucore.i_deco.twobyte);
$dumpvars(0,U_TOP.v586.ucore.i_deco.sib_dec);
$dumpvars(0,U_TOP.v586.ucore.i_deco.displc);
$dumpvars(0,U_TOP.v586.ucore.i_deco.lenpc);
$dumpvars(0,U_TOP.v586.ucore.i_deco.over_seg);
$dumpvars(0,U_TOP.v586.ucore.i_deco.modrm);
$dumpvars(0,U_TOP.v586.ucore.i_deco.indic);
$dumpvars(0,U_TOP.v586.ucore.i_deco.predec);
$dumpvars(0,U_TOP.v586.ucore.i_deco.preindic);
$dumpvars(0,U_TOP.v586.ucore.i_deco.undf);
$dumpvars(0,U_TOP.v586.ucore.i_deco.inter_dly);
$dumpvars(0,U_TOP.v586.ucore.i_deco.trig_it);
$dumpvars(0,U_TOP.v586.ucore.i_deco.re_dec);
$dumpvars(0,U_TOP.v586.ucore.i_deco.re_decf);

$dumpvars(0,U_TOP.v586.ucore.i_vliw.opas);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.opbs);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.nOF);

$dumpvars(0,U_TOP.v586.ucore.i_vliw.over_seg);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.lenpc);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.terminate);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.vliw_pc);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.instrc);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.cr2);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.icr2);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.pg_fault);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.ipg_fault);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.opcode);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.opa);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.opb);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.opc);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.opd);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.imm);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.sav_ecx);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.sav_edi);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.sav_esi);


$dumpvars(0,U_TOP.v586.ucore.i_vliw.eax);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.ebx);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.ecx);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.edx);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.esp);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.ebp);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.esi);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.edi);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.epc);


$dumpvars(0,U_TOP.v586.ucore.i_vliw.fecx);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.ldtr);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.gdtr);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.idtr);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.desc);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.over_seg);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.add_src);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.fsm);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.cond);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.nCF);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.nZF);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.es);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.cs);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.ss);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.ds);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.fs);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.gs);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.seg_src);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.pc_out);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.eflags);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.loopcond);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.overr);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.divq);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.divr);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.cr0);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.cr3);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.had_lgjmp);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.opz);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.jsz);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.tr);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.all_cnt);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.errco);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.tsc);
$dumpvars(0,U_TOP.v586.ucore.i_vliw.flush_tlb);

$dumpvars(0,U_TOP.v586.ucore.Dtlb.cr2);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.pg_fault);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.pg_en);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit_dir1);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit_dir2);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.oread_ack);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.oread_req);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.iread_ack);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.iread_req);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.owrite_ack);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.owrite_req);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.iwrite_ack);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.iwrite_req);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.addr_phys);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.cr3);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.cr0);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.dir1);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.dir2);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.data_miss);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.iDaddr);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.dir_mux);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.fsm);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.iread_req);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit_tab11);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit_tab12);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit_tab13);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit_tab14);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit_tab21);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit_tab22);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit_tab23);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.hit_tab24);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.tab11);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.tab12);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.tab13);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.tab14);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.tab21);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.tab22);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.tab23);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.tab24);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.wr_fault);
$dumpvars(0,U_TOP.v586.ucore.Dtlb.flush_tlb);

$dumpvars(0,U_TOP.v586.ucore.Itlb.pg_en);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit_dir1);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit_dir2);
$dumpvars(0,U_TOP.v586.ucore.Itlb.oread_ack);
$dumpvars(0,U_TOP.v586.ucore.Itlb.oread_req);
$dumpvars(0,U_TOP.v586.ucore.Itlb.iread_ack);
$dumpvars(0,U_TOP.v586.ucore.Itlb.iread_req);
$dumpvars(0,U_TOP.v586.ucore.Itlb.owrite_ack);
$dumpvars(0,U_TOP.v586.ucore.Itlb.owrite_req);
$dumpvars(0,U_TOP.v586.ucore.Itlb.iwrite_ack);
$dumpvars(0,U_TOP.v586.ucore.Itlb.iwrite_req);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit);
$dumpvars(0,U_TOP.v586.ucore.Itlb.addr_phys);
$dumpvars(0,U_TOP.v586.ucore.Itlb.cr3);
$dumpvars(0,U_TOP.v586.ucore.Itlb.cr0);
$dumpvars(0,U_TOP.v586.ucore.Itlb.dir1);
$dumpvars(0,U_TOP.v586.ucore.Itlb.dir2);
$dumpvars(0,U_TOP.v586.ucore.Itlb.data_miss);
$dumpvars(0,U_TOP.v586.ucore.Itlb.iDaddr);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit);
$dumpvars(0,U_TOP.v586.ucore.Itlb.dir_mux);
$dumpvars(0,U_TOP.v586.ucore.Itlb.fsm);
$dumpvars(0,U_TOP.v586.ucore.Itlb.iread_req);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit_tab11);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit_tab12);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit_tab13);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit_tab14);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit_tab21);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit_tab22);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit_tab23);
$dumpvars(0,U_TOP.v586.ucore.Itlb.hit_tab24);
$dumpvars(0,U_TOP.v586.ucore.Itlb.tab21);
$dumpvars(0,U_TOP.v586.ucore.Itlb.tab11);
$dumpvars(0,U_TOP.v586.ucore.Itlb.flush_tlb);

#95000;


$finish;


end

always #10 clk<=~clk;

`endif


endmodule
