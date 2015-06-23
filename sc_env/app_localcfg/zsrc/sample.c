sfr at 0x00 addr0;
sfr at 0x01 addr1;
sfr at 0x02 data0;
sfr at 0x03 data1;
sfr at 0x04 data2;
sfr at 0x05 data3;

void nmi_isr() {}
void isr() {}

void cfgo_write (int addr, long data)
{
  addr0 = addr & 0xff;
  addr1 = addr >> 8;
  data0 = addr & 0xff;
  data1 = (addr >> 8) & 0xff;
  data2 = (addr >> 16) & 0xff;
  data3 = (addr >> 24) & 0xff;
}

long cfgo_read (int addr)
{
  long data = 0;
  addr0 = addr & 0xff;
  addr1 = addr >> 8;
  data = data0;
  data = data | (data1 << 8);
  data = data | (data2 << 16);
  data = data | (data3 << 24);

  return data;
}

int main ()
{
  int i;
  long d;

  for (i=0; i<20; i=i+1) {
    d = i+1;
    cfgo_write (i, d);
    d = cfgo_read (i);
  }
    
  return 0;
}

