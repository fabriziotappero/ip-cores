
sfr at 0x80 sim_ctl_port;
sfr at 0x81 msg_port;
sfr at 0x82 timeout_port;

void nmi_isr() {}
void isr() {}

void print (char *string)
{
  char *iter;

  iter = string;
  while (*iter != 0) {
    msg_port = *iter++;
  }
}

int main ()
{
  print ("Hello, world!\n");

  sim_ctl_port = 0x01;
  return 0;
}

