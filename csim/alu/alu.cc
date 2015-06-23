class alu {
  public:
    alu();
    void operation(unsigned op,unsigned a, bool a_vld, unsigned b, bool b_vld);
    unsigned get_ya();
    bool get_ya_vld();
    unsigned get_yb();
    bool get_yb_vld();
    
    unsigned get_a_zflag();
    bool get_a_zflag_vld();
    unsigned get_a_nflag();
    bool get_a_nflag_vld();
    unsigned get_a_vflag();
    bool get_a_vflag_vld();
    unsigned get_a_cflag();
    bool get_a_cflag_vld();

    unsigned get_b_zflag();
    bool get_b_zflag_vld();
    unsigned get_b_nflag();
    bool get_b_nflag_vld();
    unsigned get_b_vflag();
    bool get_b_vflag_vld();
    unsigned get_b_cflag();
    bool get_b_cflag_vld();

  protected:
  
  private:
    void set_flags();
    unsigned ya;
    bool ya_vld;
    unsigned yb;
    bool yb_vld;

    typedef unsigned long long true_long;
    true_long result;
 
    bool a_c, a_c_vld;
    bool a_v, a_v_vld;
    bool a_n, a_n_vld;
    bool a_z, a_z_vld;
    
    bool b_c, b_c_vld;
    bool b_v, b_v_vld;
    bool b_n, b_n_vld;
    bool b_z, b_z_vld;
};

alu::alu()
{
  cout << "Init alu \n";
}

void alu::operation (unsigned op,unsigned a,bool a_vld,unsigned b,bool b_vld)
{
  unsigned b_se;	// sign extended b 
  unsigned b_n;		// two complement version of b

  switch (op) {
  case 0:	// Pass operation
    ya = a;
    ya_vld = a_vld;
    yb = b;
    yb_vld = b_vld;

    result = 0ULL;
    a_c = false;
    a_c_vld = true;
    b_c = false;
    b_c_vld = true;
    a_v = false;
    a_v_vld = true;
    b_v = false;
    b_v_vld = true;
    break;
  case 1:	// Add operation
    // Code for ya
    ya_vld = a_vld && b_vld;
    yb_vld = a_vld && b_vld;
    if (a_vld && b_vld) {
      result = (true_long)a + (true_long)b;
      ya = 0x00000000ffffffff & result;
      if ((result >> 32) > 0)
        a_c = true;
      else
        a_c = false;

      if (((a>>31) ^ (b>>31)) == 0) {
        if (((a>>31) ^ (ya>>31)) == 0)
          a_v = false;
        else
          a_v = true; 
      }
      else 
        a_v = false;

      // Code for yb here

      b_se = 0x0000ffff & b;
      if ((b_se>>15) == 1)
        b_se = 0xffff0000 | b_se;

      result = (true_long)a + (true_long)b_se;
      yb = 0x00000000ffffffff & result;
      if ((result >> 32) > 0)
        b_c = true;
      else
        b_c = false;

      if (((a>>31) ^ (b_se>>31)) == 0) {
        if (((a>>31) ^ (ya>>31)) == 0)
          b_v = false;
        else
          b_v = true; 
      }
      else 
        b_v = false;

      a_c_vld = true;
      b_c_vld = true;

      a_v_vld = true;
      b_v_vld = true;
    }
    else {
      a_c = false;
      a_c_vld = false;
      a_v = false;
      a_v_vld = false;

      b_c = false;
      b_c_vld = false;
      b_v = false;
      b_v_vld = false;
      result = 0ULL;
    }
    break;
  case 2:	// Sub operation
    ya_vld = a_vld && b_vld;
    yb_vld = a_vld && b_vld;
    if (a_vld && b_vld) {
      b_n = 1 + ~b; 
      result = (true_long)a + (true_long)b_n;
      ya = 0x00000000ffffffff & result;
      if ((result >> 32) > 0)
        a_c = true;
      else
        a_c = false;

      if (((a>>31) ^ (b_n>>31)) == 0) {
        if (((a>>31) ^ (ya>>31)) == 0)
          a_v = false;
        else
          a_v = true; 
      }
      else 
        a_v = false;

      // Code for yb here

      b_se = 0x0000ffff & b;
      if ((b_se>>15) == 1)
        b_se = 0xffff0000 | b_se;
      b_se = 1 + ~b_se;		// Two's complement

      result = (true_long)a + (true_long)b_se;
      yb = 0x00000000ffffffff & result;
      if ((result >> 32) > 0)
        b_c = true;
      else
        b_c = false;

      if (((a>>31) ^ (b_se>>31)) == 0) {
        if (((a>>31) ^ (ya>>31)) == 0)
          b_v = false;
        else
          b_v = true; 
      }
      else 
        b_v = false;

      a_c_vld = true;
      b_c_vld = true;

      a_v_vld = true;
      b_v_vld = true;

    }
    else {
      a_c = false;
      a_c_vld = false;
      a_v = false;
      a_v_vld = false;

      b_c = false;
      b_c_vld = false;
      b_v = false;
      b_v_vld = false;
      result = 0ULL;
    }
    break;
  case 3:	// Mult operation
    ya_vld = a_vld && b_vld;
    yb_vld = a_vld && b_vld;
    if (a_vld && b_vld) {
      result = (true_long)a * (true_long)b;
      ya = result >> 32;
      yb = 0x00000000ffffffff & result; 

      a_c = false;
      a_c_vld = true;
      b_c = false;
      b_c_vld = true;
      a_v = false;
      a_v_vld = true;
      b_v = false;
      b_v_vld = true;
    }
    else {
      a_c = false;
      a_c_vld = false;
      a_v = false;
      a_v_vld = false;

      b_c = false;
      b_c_vld = false;
      b_v = false;
      b_v_vld = false;
      result = 0ULL;
    }
    break;
  case 4:	// AND/OR operation
    ya_vld = a_vld && b_vld;
    yb_vld = a_vld && b_vld;
    if (a_vld && b_vld) {
      ya = a & b;
      yb = a | b;

      a_c = false;
      a_c_vld = true;
      b_c = false;
      b_c_vld = true;
      a_v = false;
      a_v_vld = true;
      b_v = false;
      b_v_vld = true;
    }
    else {
      a_c = false;
      a_c_vld = false;
      a_v = false;
      a_v_vld = false;

      b_c = false;
      b_c_vld = false;
      b_v = false;
      b_v_vld = false;
      result = 0ULL;
    }
    break;
  case 5:	// XOR / XNOR operation
    ya_vld = a_vld && b_vld;
    yb_vld = a_vld && b_vld;
    if (a_vld && b_vld) {
      ya = a ^ b;
      yb = ~ya;

      a_c = false;
      a_c_vld = true;
      b_c = false;
      b_c_vld = true;
      a_v = false;
      a_v_vld = true;
      b_v = false;
      b_v_vld = true;
    }
    else {
      a_c = false;
      a_c_vld = false;
      a_v = false;
      a_v_vld = false;

      b_c = false;
      b_c_vld = false;
      b_v = false;
      b_v_vld = false;
      result = 0ULL;
    }
    break;
  case 6:	// Reserved 
    ya_vld = false;
    yb_vld = false;

    a_c = false;
    a_c_vld = false;
    a_v = false;
    a_v_vld = false;

    b_c = false;
    b_c_vld = false;
    b_v = false;
    b_v_vld = false;
    result = 0ULL;
    break;
  case 7:	// Pass operation
    ya = (a<<16) | (a>>16);
    ya_vld = a_vld;
    yb = (b<<16) | (b>>16);
    yb_vld = b_vld;
    result = 0ULL;
    a_c = false;
    a_c_vld = true;
    b_c = false;
    b_c_vld = true;
    a_v = false;
    a_v_vld = true;
    b_v = false;
    b_v_vld = true;
    break;
  }
  set_flags();
}    
    
void alu::set_flags()
{ 
  if (ya_vld) {
    if ((ya>>31) == 1) 
      a_n = true;
    else 
      a_n = false;

    if (ya == 0) 
      a_z = true;
    else
      a_z = false;

    a_n_vld = true;
    a_z_vld = true;
  }
  else {
    a_n = false;
    a_n_vld = false;
    a_z = false;
    a_z_vld = false;
  }

  if (yb_vld) {
    if ((yb>>31) == 1) 
      b_n = true;
    else
      b_n = false;

    if (yb == 0) 
      b_z = true;
    else
      b_z = false;

    b_n_vld = true;
    b_z_vld = true;
  }
  else {
    b_n = false;
    b_n_vld = false;
    b_z = false;
    b_z_vld = false;
  }
}

unsigned alu::get_ya()
{
  return (ya);
}

bool alu::get_ya_vld()
{
  return (ya_vld);
}

unsigned alu::get_yb()
{
  return (yb);
}

bool alu::get_yb_vld()
{
  return (yb_vld);
}
    
unsigned alu::get_a_zflag()
{
  if (a_z)
    return (0x00000001);
  else
    return (0x00000000);
}

bool alu::get_a_zflag_vld()
{
  return (a_z_vld);
}

unsigned alu::get_a_nflag()
{
  if (a_n)
    return (0x00000001);
  else
    return (0x00000000);
}

bool alu::get_a_nflag_vld()
{
  return (a_n_vld);
}

unsigned alu::get_a_vflag()
{
  if (a_v)
    return (0x00000001);
  else
    return (0x00000000);
}

bool alu::get_a_vflag_vld()
{
  return(a_v_vld);
}

unsigned alu::get_a_cflag()
{
  if (a_c)
    return (0x00000001);
  else
    return (0x00000000);
}

bool alu::get_a_cflag_vld()
{
  return (a_c_vld);
}


unsigned alu::get_b_zflag()
{
  if (b_z)
    return (0x00000001);
  else
    return (0x00000000);
}

bool alu::get_b_zflag_vld()
{
  return (b_z_vld);
}

unsigned alu::get_b_nflag()
{
  if (b_n)
    return (0x00000001);
  else
    return (0x00000000);
}

bool alu::get_b_nflag_vld()
{
  return (b_n_vld);
}

unsigned alu::get_b_vflag()
{
  if (b_v)
    return (0x00000001);
  else
    return (0x00000000);
}

bool alu::get_b_vflag_vld()
{
  return(b_v_vld);
}

unsigned alu::get_b_cflag()
{
  if (b_c)
    return (0x00000001);
  else
    return (0x00000000);
}

bool alu::get_b_cflag_vld()
{
  return (b_c_vld);
}

 
/*
 *  $Id: alu.cc,v 1.1 2001-10-28 03:27:21 samg Exp $ 
 *  Program  : alu.cc 
 *  Author   : Sam Gladstone
 *  Function : alu behavioral class for SXP 
 *  $Log: not supported by cvs2svn $
 */

