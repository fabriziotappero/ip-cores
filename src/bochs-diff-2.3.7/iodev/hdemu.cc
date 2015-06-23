// Define BX_PLUGGABLE in files that can be compiled into plugins.  For
// platforms that require a special tag on exported symbols, BX_PLUGGABLE
// is used to know when we are exporting symbols and when we are importing.
#define BX_PLUGGABLE

#include "iodev.h"
#define LOG_THIS theHdemuDevice->

bx_hdemu_c *theHdemuDevice = NULL;

int libhdemu_LTX_plugin_init(plugin_t *plugin, plugintype_t type, int argc, char *argv[])
{
  theHdemuDevice = new bx_hdemu_c();
  bx_devices.pluginHdemuDevice = theHdemuDevice;
  BX_REGISTER_DEVICE_DEVMODEL(plugin, type, theHdemuDevice, "hdemu");
  return(0); // Success
}

void libhdemu_LTX_plugin_fini(void)
{
  delete theHdemuDevice;
}

bx_hdemu_c::bx_hdemu_c()
{
  put("HDEMU");
  settype(HDEMULOG);
  input = NULL;
}

bx_hdemu_c::~bx_hdemu_c()
{
  if (input != NULL) fclose(input);
  BX_DEBUG(("Exit"));
}

void bx_hdemu_c::init(void)
{
  char name[16];

  BX_DEBUG(("Init $Id: hdemu.cc,v 1.34 2008/01/26 22:24:02 sshwarts Exp $"));

  sprintf(name, "Hd emu");
  /* hdemu i/o ports */
  DEV_register_ioread_handler_range(this, read_handler, 0xe000, 0xe1fe, name, 2);
  DEV_register_iowrite_handler(this, write_handler, 0xe000, name, 2);

  /* internal state */
  BX_HDEMU_THIS base = 0x0;

  /* input file */
  input = fopen("hd.img", "rb");
    if (!input)
      BX_PANIC(("Could not open 'hd.img' to read hard disk contents"));
}

void bx_hdemu_c::reset(unsigned type)
{
}

void bx_hdemu_c::register_state(void)
{
  unsigned i;
  char name[4], pname[20];
  bx_list_c *base, *port;

  bx_list_c *list = new bx_list_c(SIM->get_bochs_root(), "hdemu", "Hard disk emulator", 1);

  sprintf(name, "0", i);
  port = new bx_list_c(list, name, 1);
  new bx_shadow_num_c(port, "base", &BX_HDEMU_THIS base, BASE_HEX);
}

// static IO port read callback handler
// redirects to non-static class handler to avoid virtual functions

Bit32u bx_hdemu_c::read_handler(void *this_ptr, Bit32u address, unsigned io_len)
{
#if !BX_USE_PAR_SMF
  bx_hdemu_c *class_ptr = (bx_hdemu_c *) this_ptr;
  return class_ptr->read(address, io_len);
}

Bit32u bx_hdemu_c::read(Bit32u address, unsigned io_len)
{
#else
  UNUSED(this_ptr);
#endif  // !BX_USE_PAR_SMF

  Bit16u retval;
  size_t result;
  address = address & 0x01ff;

  fseek (BX_HDEMU_THIS input, address+(BX_HDEMU_THIS base)*512, SEEK_SET );
  result = fread (&retval, 2, 1, BX_HDEMU_THIS input);

  return(retval);
}

// static IO port write callback handler
// redirects to non-static class handler to avoid virtual functions

void bx_hdemu_c::write_handler(void *this_ptr, Bit32u address, Bit32u value, unsigned io_len)
{
#if !BX_USE_PAR_SMF
  bx_hdemu_c *class_ptr = (bx_hdemu_c *) this_ptr;

  class_ptr->write(address, value, io_len);
}

void bx_hdemu_c::write(Bit32u address, Bit32u value, unsigned io_len)
{
#else
  UNUSED(this_ptr);
#endif  // !BX_USE_PAR_SMF

  BX_HDEMU_THIS base = value;
}
