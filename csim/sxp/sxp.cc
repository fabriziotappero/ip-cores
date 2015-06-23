class sxp
{
  public:
    sxp();
    void run_cycle ();
    void print_regs ();
    void interupt (unsigned int_num);
    bool end_sim;
  protected:

  private:
    reg_file rgfile;
    memory   sp_mem;
    memory   inst_mem;
    fetch    sxp_fetch;
    ext      sxp_ext;
    alu      sxp_alu;

    void src_select();
    void wb_select();
    void dest_write();

    unsigned inst;
    unsigned pc;
    unsigned pcn;

    unsigned dest_cfg, src_cfg, alu_cfg, wb_cfg;

    unsigned addra, addrb, addrc;
    unsigned immediate;

    unsigned jump_cond, jz, jal;

    unsigned qra, qrb;
    bool qra_vld, qrb_vld;

    unsigned alu_a, alu_b;
    bool alu_a_vld, alu_b_vld;
  
    unsigned wb_data;
    bool wb_data_vld;
};

sxp::sxp() : rgfile(16), sp_mem(64), inst_mem(64), sxp_fetch(), sxp_ext(), sxp_alu()
{
  cout << "loading memory data\n";
  inst_mem.load_data("test.sxp");
  end_sim = false;
  cout << "finished loading memory data\n";
}

void sxp::run_cycle()
{
   pc = sxp_fetch.get_pc();
   pcn = pc + 1;
   inst = inst_mem.read_mem(pc);
   printf ("pc:%.8x - inst:%.8x\n",pc,inst);
   dest_cfg = (inst & 0xc0000000) >> 30;
   src_cfg = (inst & 0x38000000) >> 27;
   alu_cfg = (inst & 0x07000000) >> 24;
   wb_cfg = (inst & 0x00f00000) >> 20;

   printf ("dest_cfg = %x, src_cfg = %x, alu_cfg = %x, wb_cfg = %x\n",dest_cfg,src_cfg,alu_cfg,wb_cfg);

   addrc = (inst & 0x000f0000) >> 16;
   if (src_cfg == 1)
     addra = addrc;
   else
     addra = (inst & 0x0000f000) >> 12;
   addrb = (inst & 0x00000f00) >> 8;
   immediate = (inst & 0x0000ffff);

   switch (src_cfg) {
   case 0 :	// reg , reg 
   case 2 :	// pc  , reg
   case 5 :	// ext , reg
     jump_cond = (inst & 0x00000001);
     break;
   default: 	// All other cases
     jump_cond = 0;
   }

   jz = (inst & 0x00000002) >> 1;

   switch (src_cfg) {
   case 0 :	// reg , reg 
   case 2 :	// pc  , reg
     jal = (inst & 0x00000004) >> 2;
     break;
   default: 	// All other cases
     jal = 0;
   }

 
   qra = rgfile.read_reg(addra);
   qra_vld = rgfile.valid_reg(addra);
   qrb = rgfile.read_reg(addrb);
   qrb_vld = rgfile.valid_reg(addrb);

   src_select();
   sxp_alu.operation(alu_cfg, alu_a, alu_a_vld, alu_b, alu_b_vld);
   // Use get functions to get value wanted (cvnz_a,cvnz_b,ya,yb)
   wb_select();
   dest_write();		// do necessary writebacks to dest
   sxp_fetch.next_pc();
}

void sxp::src_select ()
{
   switch (src_cfg) {
     case 0: 
       alu_a = qra;
       alu_a_vld = qra_vld;
       alu_b = qrb;
       alu_b_vld = qrb_vld;
       break;
     case 1:
       alu_a = qra;
       alu_a_vld = qra_vld;
       alu_b = immediate;
       alu_b_vld = true;
       break;
     case 2:
       alu_a = pcn; 
       alu_a_vld = true;
       alu_b = qrb;
       alu_b_vld = qrb_vld;
       break;
     case 3:
       alu_a = pcn; 
       alu_a_vld = true;
       alu_b = immediate;
       alu_b_vld = true;
       break;
     case 4:
       alu_a = qra; 
       alu_a_vld = qra_vld;
       alu_b = sxp_ext.get_rb(inst);
       alu_b_vld = sxp_ext.get_rb_vld(inst);
       break;
     case 5:
       alu_a = sxp_ext.get_ra(inst); 
       alu_a_vld = sxp_ext.get_ra_vld(inst);
       alu_b = qrb;
       alu_b_vld = qrb_vld;
       break;
     case 6:
       alu_a = sxp_ext.get_ra(inst); 
       alu_a_vld = sxp_ext.get_ra_vld(inst);
       alu_b = immediate;
       alu_b_vld = true;
       break;
     case 7:
       alu_a = sxp_ext.get_ra(inst); 
       alu_a_vld = sxp_ext.get_ra_vld(inst);
       alu_b = sxp_ext.get_rb(inst);
       alu_b_vld = sxp_ext.get_rb_vld(inst);
       break;
   }
}        

void sxp::wb_select ()
{
   switch (wb_cfg) {
     case 0: 
       wb_data = sxp_alu.get_ya();
       wb_data_vld = sxp_alu.get_ya_vld();
       break;
     case 1:
       wb_data = sxp_alu.get_yb();
       wb_data_vld = sxp_alu.get_yb_vld();
       break;
     case 2:
       wb_data = sp_mem.read_mem(qra);
       wb_data_vld = sp_mem.valid_mem(qra);
       break;
     case 3:
       wb_data = sxp_ext.read_data(alu_cfg,qra);
       wb_data_vld = sxp_ext.read_data_vld(alu_cfg,qra);
       break;
     case 4:
       wb_data = sxp_alu.get_a_zflag();
       wb_data_vld = sxp_alu.get_a_zflag_vld();
       break;
     case 5:
       wb_data = sxp_alu.get_a_nflag();
       wb_data_vld = sxp_alu.get_a_nflag_vld();
       break;
     case 6:
       wb_data = sxp_alu.get_a_vflag();
       wb_data_vld = sxp_alu.get_a_vflag_vld();
       break;
     case 7:
       wb_data = sxp_alu.get_a_cflag();
       wb_data_vld = sxp_alu.get_a_cflag_vld();
       break;
     case 8:
       wb_data = sxp_alu.get_b_zflag();
       wb_data_vld = sxp_alu.get_b_zflag_vld();
       break;
     case 9:
       wb_data = sxp_alu.get_b_nflag();
       wb_data_vld = sxp_alu.get_b_nflag_vld();
       break;
     case 10:
       wb_data = sxp_alu.get_b_vflag();
       wb_data_vld = sxp_alu.get_b_vflag_vld();
       break;
     case 11:
       wb_data = sxp_alu.get_b_cflag();
       wb_data_vld = sxp_alu.get_b_cflag_vld();
       break;
     case 12:
       wb_data = sxp_ext.get_zflag(inst);
       wb_data_vld = sxp_ext.get_zflag_vld(inst);
       break;
     case 13:
       wb_data = sxp_ext.get_nflag(inst);
       wb_data_vld = sxp_ext.get_nflag_vld(inst);
       break;
     case 14:
       wb_data = sxp_ext.get_vflag(inst);
       wb_data_vld = sxp_ext.get_vflag_vld(inst);
       break;
     case 15:
       wb_data = sxp_ext.get_cflag(inst);
       wb_data_vld = sxp_ext.get_cflag_vld(inst);
       break;
   }
}        

void sxp::dest_write ()
{
   unsigned temp;
   bool jump;
   switch (dest_cfg) {
     case 0: 	// Reg write
       rgfile.write_reg(addrc,wb_data,wb_data_vld);
       break;
     case 1:	// Jump and Jump and Link
       temp = (sxp_alu.get_yb() & 0x00000001) ^ jz;
       jump = true;
       if ((jump_cond == 1) && (temp == 0)) 
         jump = false;
       if (jump)
         sxp_fetch.set_pc(wb_data,wb_data_vld);
       if (jump && (jal==1))
         rgfile.write_reg(addrc,pcn,true);
       break;
     case 2:	// Memory write
       sp_mem.write_mem(sxp_alu.get_yb(),wb_data,wb_data_vld);
       break;
     case 3:	// Ext bus write
       sxp_ext.write_data(sxp_alu.get_yb(),wb_data,wb_data_vld);
       end_sim = true;
       break;
   }
}        
 
void sxp::print_regs()
{
  rgfile.print_regs();
} 

void sxp::interupt (unsigned int_num)
{
  cout << " ------------------------------------------- " << endl;
  cout << "Interupt " << int_num << " issued." <<  endl;
  cout << " ------------------------------------------- " << endl;
  rgfile.write_reg(15,pcn,true);   
  sxp_fetch.set_pc(int_num,true);
  sxp_fetch.next_pc();
  return;
}

/*  $Id: sxp.cc,v 1.1 2001-10-28 23:14:58 samg Exp $ 
 *  Program  : sxp.cc 
 *  Author   : Sam Gladstone
 *  Function : Top level SXP processor class model 
 *  $Log: not supported by cvs2svn $
 */

