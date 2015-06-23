class ext {
  public:
    ext();
    unsigned get_ra(unsigned inst);
    bool get_ra_vld(unsigned inst);
    unsigned get_rb(unsigned inst);
    bool get_rb_vld(unsigned inst);

    unsigned get_zflag(unsigned inst);
    bool get_zflag_vld(unsigned inst);
    unsigned get_nflag(unsigned inst);
    bool get_nflag_vld(unsigned inst);
    unsigned get_vflag(unsigned inst);
    bool get_vflag_vld(unsigned inst);
    unsigned get_cflag(unsigned inst);
    bool get_cflag_vld(unsigned inst);

    void write_data(unsigned addr,unsigned wb_data,bool wb_data_vld); 
    unsigned read_data(unsigned alu_op, unsigned addr);
    bool read_data_vld(unsigned alu_op, unsigned addr); 
  protected:

  private:
};

ext::ext() {
  cout << "Init ext\n";
}

unsigned ext::get_ra(unsigned inst)
{
  return (0);
}

bool ext::get_ra_vld(unsigned inst)
{
  return(false);
}

unsigned ext::get_rb(unsigned inst)
{
  return(0);
}

bool ext::get_rb_vld(unsigned inst)
{
  return(false);
}

unsigned ext::get_zflag(unsigned inst)
{
  return(0);
}

bool ext::get_zflag_vld(unsigned inst)
{ 
  return(false);
}

unsigned ext::get_nflag(unsigned inst)
{
  return(0);
}

bool ext::get_nflag_vld(unsigned inst)
{ 
  return(false);
}

unsigned ext::get_vflag(unsigned inst)
{
  return(0);
}

bool ext::get_vflag_vld(unsigned inst)
{ 
  return(false);
}

unsigned ext::get_cflag(unsigned inst)
{
  return(0);
}

bool ext::get_cflag_vld(unsigned inst)
{ 
  return(false);
}

unsigned ext::read_data(unsigned alu_op,unsigned addr) 
{
  return(0);
}

bool ext::read_data_vld(unsigned alu_op,unsigned addr) 
{
  return(false);
}

void ext::write_data(unsigned addr,unsigned wb_data,bool wb_data_vld) 
{
  return;
}

/*
 *  $Id: ext.cc,v 1.1 2001-10-28 00:56:38 samg Exp $ 
 *  Program  : ext.cc 
 *  Author   : Sam Gladstone
 *  Function : extension behavioral class for SXP processor 
 *  $Log: not supported by cvs2svn $
 */

