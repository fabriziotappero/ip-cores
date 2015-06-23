
#include <cstdio>
#include <cstdlib>

#include <dlfcn.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "shared_mem.h"

#include "bochs.h"
#include "plugin.h"
#include "extplugin.h"
#include "iodev/iodev.h"
#include "iodev/virt_timer.h"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

volatile shared_mem_t *shared_ptr = NULL;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

ioWriteHandler_t io_write_handlers[65537];
void *           io_write_this    [65537];
uint8            io_write_mask    [65537];
ioReadHandler_t  io_read_handlers [65537];
void *           io_read_this     [65537];
uint8            io_read_mask     [65537];

void  (*pluginRegisterIRQ)(unsigned irq, const char* name) = 0;

int (*pluginRegisterIOReadHandler)(void *thisPtr, ioReadHandler_t callback,
                            unsigned base, const char *name, Bit8u mask) = 0;
int (*pluginRegisterIOWriteHandler)(void *thisPtr, ioWriteHandler_t callback,
                             unsigned base, const char *name, Bit8u mask) = 0;
int (*pluginRegisterDefaultIOReadHandler)(void *thisPtr, ioReadHandler_t callback,
                            const char *name, Bit8u mask) = 0;
int (*pluginRegisterDefaultIOWriteHandler)(void *thisPtr, ioWriteHandler_t callback,
                             const char *name, Bit8u mask) = 0;

static void
builtinRegisterIRQ(unsigned irq, const char* name)
{
//bx_devices.register_irq(irq, name);
printf("builtinRegisterIRQ(%d, %s)\n", irq, name);
}

static int
builtinRegisterIOReadHandler(void *thisPtr, ioReadHandler_t callback,
                            unsigned base, const char *name, Bit8u mask)
{
//  int ret;
//  BX_ASSERT(mask<8);
//  ret = bx_devices.register_io_read_handler (thisPtr, callback, base, name, mask);
//  pluginlog->ldebug("plugin %s registered I/O read  address at %04x", name, base);
//  return ret;
    
printf("builtinRegisterIOReadHandler: %s %04x %d\n", name, base, mask);
    io_read_handlers[base] = callback;
    io_read_mask[base]     = mask;
    io_read_this[base]     = thisPtr;
    
    return 1;
}

static int
builtinRegisterIOWriteHandler(void *thisPtr, ioWriteHandler_t callback,
                             unsigned base, const char *name, Bit8u mask)
{
//  int ret;
//  BX_ASSERT(mask<8);
//  ret = bx_devices.register_io_write_handler (thisPtr, callback, base, name, mask);
//  pluginlog->ldebug("plugin %s registered I/O write address at %04x", name, base);
//  return ret;

printf("builtinRegisterIOWriteHandler: %s %04x %d\n", name, base, mask);
    io_write_handlers[base] = callback;
    io_write_mask[base]     = mask;
    io_write_this[base]     = thisPtr;
    
    return 1;
}

static int
builtinRegisterDefaultIOReadHandler(void *thisPtr, ioReadHandler_t callback,
                            const char *name, Bit8u mask)
{
//  BX_ASSERT(mask<8);
//  bx_devices.register_default_io_read_handler (thisPtr, callback, name, mask);
//  pluginlog->ldebug("plugin %s registered default I/O read ", name);
printf("builtinRegisterDefaultIOReadHandler: %s %x\n", name, mask);
    io_read_handlers[65536] = callback;
    io_read_mask[65536]     = mask;
    io_read_this[65536]     = thisPtr;
    
    return 1;
}

static int
builtinRegisterDefaultIOWriteHandler(void *thisPtr, ioWriteHandler_t callback,
                             const char *name, Bit8u mask)
{
//  BX_ASSERT(mask<8);
//  bx_devices.register_default_io_write_handler (thisPtr, callback, name, mask);
//  pluginlog->ldebug("plugin %s registered default I/O write ", name);
printf("builtinRegisterDefaultIOWriteHandler: %s %x\n", name, mask);
    io_write_handlers[65536] = callback;
    io_write_mask[65536]     = mask;
    io_write_this[65536]     = thisPtr;
    
    return 1;
}

void pluginRegisterDeviceDevmodel(plugin_t *plugin, plugintype_t type, bx_devmodel_c *devmodel, const char *name) {
printf("pluginRegisterDeviceDevmodel() for %s\n", name);

devmodel->init();
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ SIM

const char *enum_choices[] = { "0_choice", "1_choice", NULL };

#define BOCHS_DEVS_IPS 480000

BxEvent *callback(void *theclass, BxEvent *event) {
printf("bochsDevs::callback()\n");
    return event;
}

bxevent_handler bxevent_callback      = callback;
void *          bxevent_callback_data = NULL;

class bochsDevs_sim : public bx_simulator_interface_c {

    bx_param_bool_c *get_param_bool(const char *pname, bx_param_c *base) {
printf("bochsDevs_sim::get_param_bool(%s, base=%s)\n", pname, (base==NULL)? "(nil)" : (base->get_name() == NULL)? "(nill name)" : base->get_name());
        
        if(base != NULL) {
            bx_param_c *param = ((bx_list_c *)base)->get_by_name(pname);
            return (bx_param_bool_c *)param;
        }

        if(strcmp(pname, BXPN_PORT_E9_HACK) == 0)           return new bx_param_bool_c(NULL, "port_e9_hack", "", "", 0);
        if(strcmp(pname, BXPN_CMOSIMAGE_ENABLED) == 0)      return new bx_param_bool_c(NULL, "enabled",      "", "", 0);
        
        if(strcmp(pname, BXPN_FLOPPYSIGCHECK) == 0)         return new bx_param_bool_c(NULL, "floppy_sig_check", "", "", 0);
        if(strcmp(pname, BXPN_PCI_ENABLED) == 0)            return new bx_param_bool_c(NULL, "enabled",          "", "", 0);
        
        if(strcmp(pname, BXPN_PRIVATE_COLORMAP) == 0)       return new bx_param_bool_c(NULL, "private_colormap", "", "", 0);
        
        if(strcmp(pname, BXPN_KBD_USEMAPPING) == 0)         return new bx_param_bool_c(NULL, "use_mapping", "", "", 0);
        
        if(strcmp(pname, BXPN_MOUSE_ENABLED) == 0)          return new bx_param_bool_c(NULL, "enabled", "", "", 0);
        
        return NULL;
    }
    bx_param_string_c *get_param_string(const char *pname, bx_param_c *base) {
printf("bochsDevs_sim::get_param_string(%s, base=%s)\n", pname, (base==NULL)? "(nil)" : (base->get_name() == NULL)? "(nill name)" : base->get_name());
        
        if(base != NULL) {
            bx_param_c *param = ((bx_list_c *)base)->get_by_name(pname);
            return (bx_param_string_c *)param;
        }
        
        if(strcmp(pname, BXPN_VGA_EXTENSION) == 0)          return new bx_param_string_c(NULL, "vga_extension",      "", "", "none");
        if(strcmp(pname, BXPN_DISPLAYLIB_OPTIONS) == 0)     return new bx_param_string_c(NULL, "displaylib_options", "", "", "");
        
        if(strcmp(pname, BXPN_VGA_ROM_PATH) == 0)     return new bx_param_string_c(NULL, "path", "", "", "");
        
        return NULL;
    }
    bx_param_enum_c *get_param_enum(const char *pname, bx_param_c *base) {
printf("bochsDevs_sim::get_param_enum(%s, base=%s)\n", pname, (base==NULL)? "(nil)" : (base->get_name() == NULL)? "(nill name)" : base->get_name());

        if(base != NULL) {
            bx_param_c *param = ((bx_list_c *)base)->get_by_name(pname);
            return (bx_param_enum_c *)param;
        }

        if(strcmp(pname, BXPN_CLOCK_SYNC) == 0)       return new bx_param_enum_c(NULL, "clock_sync", "", "", enum_choices, 0);
        
        if(strcmp(pname, BXPN_FLOPPYA_DEVTYPE) == 0)  return new bx_param_enum_c(NULL, "devtype", "", "", enum_choices, 0);
        if(strcmp(pname, BXPN_FLOPPYA_TYPE) == 0)     return new bx_param_enum_c(NULL, "type",    "", "", enum_choices, 0);
        if(strcmp(pname, BXPN_FLOPPYA_STATUS) == 0)   return new bx_param_enum_c(NULL, "status",  "", "", enum_choices, 0);
        
        if(strcmp(pname, BXPN_FLOPPYB_DEVTYPE) == 0)  return new bx_param_enum_c(NULL, "devtype", "", "", enum_choices, 0);
        if(strcmp(pname, BXPN_FLOPPYB_TYPE) == 0)     return new bx_param_enum_c(NULL, "type",    "", "", enum_choices, 0);
        if(strcmp(pname, BXPN_FLOPPYB_STATUS) == 0)   return new bx_param_enum_c(NULL, "status",  "", "", enum_choices, 0);
        
        if(strcmp(pname, BXPN_BOOTDRIVE1) == 0)       return new bx_param_enum_c(NULL, "boot_drive1", "", "", enum_choices, BX_BOOT_FLOPPYA);
        if(strcmp(pname, BXPN_BOOTDRIVE2) == 0)       return new bx_param_enum_c(NULL, "boot_drive2", "", "", enum_choices, BX_BOOT_FLOPPYA);
        if(strcmp(pname, BXPN_BOOTDRIVE3) == 0)       return new bx_param_enum_c(NULL, "boot_drive3", "", "", enum_choices, BX_BOOT_FLOPPYA);
        
        if(strcmp(pname, BXPN_MOUSE_TYPE) == 0)       return new bx_param_enum_c(NULL, "type", "", "", enum_choices, BX_MOUSE_TYPE_PS2);
        
        if(strcmp(pname, BXPN_MOUSE_TOGGLE) == 0)      return new bx_param_enum_c(NULL, "toggle", "", "", enum_choices, BX_MOUSE_TOGGLE_CTRL_F10);
        
        if(strcmp(pname, BXPN_KBD_TYPE) == 0)         return new bx_param_enum_c(NULL, "type", "", "", enum_choices, BX_KBD_AT_TYPE);
        
        return NULL;
    }
    bx_param_num_c *get_param_num(const char *pname, bx_param_c *base) {
printf("bochsDevs_sim::get_param_num(%s, base=%s)\n", pname, (base==NULL)? "(nil)" : (base->get_name() == NULL)? "(nill name)" : base->get_name());
        
        if(base != NULL) {
            bx_param_c *param = ((bx_list_c *)base)->get_by_name(pname);
            return (bx_param_num_c *)param;
        }

        if(strcmp(pname, BXPN_CLOCK_TIME0) == 0)  return new bx_param_num_c(NULL, "time0",   "", "", 100,100,100);
        
        if(strcmp(pname, BXPN_KBD_SERIAL_DELAY) == 0) return new bx_param_num_c(NULL, "serial_delay",   "", "", 100,100,100);
        if(strcmp(pname, BXPN_KBD_PASTE_DELAY) == 0)  return new bx_param_num_c(NULL, "paste_delay",   "", "", 100,100,100);
        if(strcmp(pname, BXPN_MOUSE_ENABLED) == 0)    return new bx_param_num_c(NULL, "enabled",   "", "", 1,1,1);
        
        if(strcmp(pname, BXPN_VGA_UPDATE_FREQUENCY) == 0)   return new bx_param_num_c(NULL, "vga_update_frequency",   "", "", 500000,500000,500000);
        
        if(strcmp(pname, BXPN_IPS) == 0)   return new bx_param_num_c(NULL, "ips",   "", "", BOCHS_DEVS_IPS, BOCHS_DEVS_IPS, BOCHS_DEVS_IPS);
        return NULL;
    }
    bx_param_c *get_param(const char *pname, bx_param_c *base=NULL) {
        if(strcmp(pname, BXPN_ATA0_RES) == 0) {
            bx_list_c *list = new bx_list_c(NULL);
            list->add(new bx_param_bool_c(NULL, "enabled", "", "", 1));
            list->add(new bx_param_num_c(NULL,  "ioaddr1", "", "", 0x1f0,0x1f0,0x1f0));
            list->add(new bx_param_num_c(NULL,  "ioaddr2", "", "", 0x3f0,0x3f0,0x3f0));
            list->add(new bx_param_num_c(NULL,  "irq",     "", "", 14,14,14));
            return list;
        }
        if(strcmp(pname, BXPN_ATA1_RES) == 0 || strcmp(pname, BXPN_ATA2_RES) == 0 || strcmp(pname, BXPN_ATA3_RES) == 0) {
            bx_list_c *list = new bx_list_c(NULL);
            list->add(new bx_param_bool_c(NULL, "enabled", "", "", 0));
            return list;
        }
        if(strcmp(pname, BXPN_FLOPPYA) == 0 || strcmp(pname, BXPN_FLOPPYB) == 0) {
            bx_list_c *list = new bx_list_c(NULL);
            list->add(new bx_param_enum_c(NULL,   "status",   "", "", enum_choices, 0));
            list->add(new bx_param_bool_c(NULL,   "readonly", "", "", 1));
            list->add(new bx_param_string_c(NULL, "path",     "", "", "none"));
            return list;
        }
        if(strcmp(pname, BXPN_ATA0_MASTER) == 0) {
            bx_list_c *list = new bx_list_c(NULL);
            list->add(new bx_param_enum_c(NULL,   "type",        "", "", enum_choices, BX_ATA_DEVICE_DISK));
            list->add(new bx_param_string_c(NULL, "model",       "", "", "HDmodel"));
            list->add(new bx_param_num_c(NULL,    "cylinders",   "", "", 1024,1024,1024));
            list->add(new bx_param_num_c(NULL,    "heads",       "", "", 16,16,16));
            list->add(new bx_param_num_c(NULL,    "spt",         "", "", 63,63,63));
            list->add(new bx_param_enum_c(NULL,   "mode",        "", "", enum_choices, BX_HDIMAGE_MODE_FLAT));
            list->add(new bx_param_string_c(NULL, "path",        "", "", "/home/alek/temp/bochs-run/hd.img"));
            list->add(new bx_param_string_c(NULL, "journal",     "", "", ""));
            list->add(new bx_param_enum_c(NULL,   "translation", "", "", enum_choices, BX_ATA_TRANSLATION_NONE));
            return list;
        }
        if(strcmp(pname, BXPN_ATA1_MASTER) == 0 || strcmp(pname, BXPN_ATA2_MASTER) == 0 || strcmp(pname, BXPN_ATA3_MASTER) == 0 ||
           strcmp(pname, BXPN_ATA0_SLAVE) == 0  || strcmp(pname, BXPN_ATA1_SLAVE) == 0  || strcmp(pname, BXPN_ATA2_SLAVE) == 0  || strcmp(pname, BXPN_ATA3_SLAVE) == 0)
        {
            bx_list_c *list = new bx_list_c(NULL);
            list->add(new bx_param_enum_c(NULL, "type", "", "", enum_choices, BX_ATA_DEVICE_NONE));
            return list;
        }
        return NULL;
    }
    void set_notify_callback(bxevent_handler func, void *arg) {
        bxevent_callback = func;
        bxevent_callback_data = arg;
    }

    void get_notify_callback(bxevent_handler *func, void **arg) {
        *func = bxevent_callback;
        *arg = bxevent_callback_data;
    }  
};

bx_simulator_interface_c *SIM;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ logfunctions

void logfunctions::panic(const char *fmt, ...) {
    printf("#bochsDevs::logfunctions::panic(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);
    
    printf("\n");
    fflush(stdout);
    
    if(strstr(fmt, "exception with no resolution") != NULL) {
        printf("start_shutdown: 0\n");
        printf("\n");
        fflush(stdout);
        exit(0);
    }
    else {
        exit(-1);
    }
}
void logfunctions::error(const char *fmt, ...) {
    printf("#bochsDevs::logfunctions::error(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);
    
    printf("\n");
    fflush(stdout);
}
void logfunctions::ldebug(const char *fmt, ...) {
    printf("#bochsDevs::logfunctions::debug(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);   
    
    printf("\n");
    fflush(stdout);
}
void logfunctions::info(const char *fmt, ...) {
    printf("#bochsDevs::logfunctions::info(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);   
    
    printf("\n");
    fflush(stdout);
}
void logfunctions::put(const char *n, const char *p) {
}
void logfunctions::put(const char *p) {
}
logfunctions::logfunctions() {
}
logfunctions::~logfunctions() {
}

static logfunctions theLog;
logfunctions *pluginlog         = &theLog;
logfunctions *siminterface_log  = &theLog;
logfunctions *genlog            = &theLog;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ menu

void bx_param_string_c::text_print(FILE *fp) {
printf("#bochsDevs::bx_param_string_c::text_print()\n");
}
void bx_param_enum_c::text_print(FILE *fp) {
printf("bochsDevs::bx_param_enum_c::text_print()\n");
}
void bx_param_bool_c::text_print(FILE *fp) {
printf("bochsDevs::bx_param_bool_c::text_print()\n");
}
void bx_param_num_c::text_print(FILE *fp) {
printf("bochsDevs::bx_param_num_c::text_print()\n");
}
void bx_list_c::text_print(FILE *fp) {
printf("bochsDevs::bx_list_c::text_print()\n");
}
int bx_param_enum_c::text_ask(FILE *fpin, FILE *fpout) {
printf("bochsDevs::bx_param_enum_c::text_ask()\n");
    return 0;
}
int bx_param_bool_c::text_ask(FILE *fpin, FILE *fpout) {
printf("bochsDevs::bx_param_bool_c::text_ask()\n");
    return 0;
}
int bx_param_num_c::text_ask(FILE *fpin, FILE *fpout) {
printf("bochsDevs::bx_param_num_c::text_ask()\n");
    return 0;
}
int bx_param_string_c::text_ask(FILE *fpin, FILE *fpout) {
printf("bochsDevs::bx_param_string_c::text_ask()\n");
    return 0;
}
int bx_list_c::text_ask(FILE *fpin, FILE *fpout) {
printf("bochsDevs::bx_list_c::text_ask()\n");
    return 0;
}

bx_list_c *root_param = NULL;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ memory

memory_handler_t vga_read_memory  = NULL;
memory_handler_t vga_write_memory = NULL;
void *           vga_param        = NULL;

BX_MEM_C::BX_MEM_C() {
}
BX_MEM_C::~BX_MEM_C() {
}

void BX_MEM_C::dmaReadPhysicalPage(bx_phy_address addr, unsigned len, Bit8u *data)  {
printf("bochsDevs::BX_MEM_C::dmaReadPhysicalPage()\n");

    memcpy(data, (void *)(shared_ptr->mem.bytes + addr), len);
}

void BX_MEM_C::dmaWritePhysicalPage(bx_phy_address addr, unsigned len, Bit8u *data) {
printf("bochsDevs::BX_MEM_C::dmaWritePhysicalPage()\n");

    memcpy((void *)(shared_ptr->mem.bytes + addr), data, len);
}

bx_bool
BX_MEM_C::registerMemoryHandlers(void *param, memory_handler_t read_handler,
                memory_handler_t write_handler, memory_direct_access_handler_t da_handler,
                bx_phy_address begin_addr, bx_phy_address end_addr)
{
printf("bochsDevs::BX_MEM_C::registerMemoryHandlers(): %llx %llx\n", begin_addr, end_addr);
    if(da_handler != NULL) {
        printf("bochsDevs::da_handler != NULL\n");
        exit(-1);
    }
    if(begin_addr != 0xA0000 || end_addr != 0xBFFFF) {
        printf("bochsDevs::invalid address\n");
        exit(-1);
    }
    
    vga_read_memory = read_handler;
    vga_write_memory= write_handler;
    vga_param       = param;

return 1;
}

void BX_MEM_C::load_ROM(const char *path, bx_phy_address romaddress, Bit8u type) {
printf("bochsDevs::BX_MEM_C::load_ROM()\n");
}

BX_MEM_C bx_mem;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

bx_bool bx_dbg_register_debug_info(const char *devname, void *dev) {
printf("bochsDevs::bx_dbg_register_debug_info() %s\n", devname);
return true;
}

void dbg_printf(const char *fmt, ...) {
printf("bochsDevs::dbg_printf(%s)\n", fmt);
}

void bx_dbg_dma_report(bx_phy_address addr, unsigned len, unsigned what, Bit32u val) {
printf("bochsDevs::bx_dbg_dma_report()\n");
}

void bx_dbg_iac_report(unsigned vector, unsigned irq) {
printf("bochsDevs::bx_dbg_iac_report()\n");
}

void bx_debug_break() {
printf("bochsDevs::bx_debug_break()\n");
}

bx_guard_t bx_guard;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

#define MinAllowableTimerPeriod 1

const Bit64u bx_pc_system_c::NullTimerInterval = 0xffffffff;

bx_pc_system_c::bx_pc_system_c() {
  this->put("pc_system", "SYS");

  BX_ASSERT(numTimers == 0);

  // Timer[0] is the null timer.  It is initialized as a special
  // case here.  It should never be turned off or modified, and its
  // duration should always remain the same.
  ticksTotal = 0; // Reset ticks since emulator started.
  timer[0].inUse      = 1;
  timer[0].period     = NullTimerInterval;
  timer[0].active     = 1;
  timer[0].continuous = 1;
  timer[0].funct      = nullTimer;
  timer[0].this_ptr   = this;
  numTimers = 1; // So far, only the nullTimer.
  
  //initialize()
  ticksTotal = 0;
  timer[0].timeToFire = NullTimerInterval;
  currCountdown       = NullTimerInterval;
  currCountdownPeriod = NullTimerInterval;
  lastTimeUsec = 0;
  usecSinceLast = 0;
  triggeredTimer = 0;
  HRQ = 0;
  kill_bochs_request = 0;

  // parameter 'ips' is the processor speed in Instructions-Per-Second
  m_ips = BOCHS_DEVS_IPS / 1000000.0L;
}

void bx_pc_system_c::nullTimer(void* this_ptr) {
}

int bx_pc_system_c::register_timer_ticks(void* this_ptr, bx_timer_handler_t funct,
    Bit64u ticks, bx_bool continuous, bx_bool active, const char *id)
{
  unsigned i;

  // If the timer frequency is rediculously low, make it more sane.
  // This happens when 'ips' is too low.
  if (ticks < MinAllowableTimerPeriod) {
    //BX_INFO(("register_timer_ticks: adjusting ticks of %llu to min of %u",
    //          ticks, MinAllowableTimerPeriod));
    ticks = MinAllowableTimerPeriod;
  }

  // search for new timer for i=1, i=0 is reserved for NullTimer
  for (i=1; i < numTimers; i++) {
    if (timer[i].inUse == 0)
      break;
  }

  timer[i].inUse      = 1;
  timer[i].period     = ticks;
  timer[i].timeToFire = (ticksTotal + Bit64u(currCountdownPeriod-currCountdown)) + ticks;
  timer[i].active     = active;
  timer[i].continuous = continuous;
  timer[i].funct      = funct;
  timer[i].this_ptr   = this_ptr;
  strncpy(timer[i].id, id, BxMaxTimerIDLen);
  timer[i].id[BxMaxTimerIDLen-1] = 0; // Null terminate if not already.

  if (active) {
    if (ticks < Bit64u(currCountdown)) {
      // This new timer needs to fire before the current countdown.
      // Skew the current countdown and countdown period to be smaller
      // by the delta.
      currCountdownPeriod -= (currCountdown - Bit32u(ticks));
      currCountdown = Bit32u(ticks);
    }
  }

printf("bochsDevs::timer id %d registered for '%s'", i, id);
  // If we didn't find a free slot, increment the bound, numTimers.
  if (i==numTimers)
    numTimers++; // One new timer installed.

  // Return timer id.
  return(i);
}

int bx_pc_system_c::register_timer(void *this_ptr, void (*funct)(void *),
  Bit32u useconds, bx_bool continuous, bx_bool active, const char *id)
{
printf("bochsDevs::bx_pc_system_c::register_timer()\n");
    
    // Convert useconds to number of ticks.
  Bit64u ticks = (Bit64u) (double(useconds) * m_ips);

  return register_timer_ticks(this_ptr, funct, ticks, continuous, active, id);
}

void bx_pc_system_c::activate_timer_ticks(unsigned i, Bit64u ticks, bx_bool continuous)
{
  // If the timer frequency is rediculously low, make it more sane.
  // This happens when 'ips' is too low.
  if (ticks < MinAllowableTimerPeriod) {
    //BX_INFO(("activate_timer_ticks: adjusting ticks of %llu to min of %u",
    //          ticks, MinAllowableTimerPeriod));
    ticks = MinAllowableTimerPeriod;
  }

  timer[i].period = ticks;
  timer[i].timeToFire = (ticksTotal + Bit64u(currCountdownPeriod-currCountdown)) + ticks;
  timer[i].active     = 1;
  timer[i].continuous = continuous;

  if (ticks < Bit64u(currCountdown)) {
    // This new timer needs to fire before the current countdown.
    // Skew the current countdown and countdown period to be smaller
    // by the delta.
    currCountdownPeriod -= (currCountdown - Bit32u(ticks));
    currCountdown = Bit32u(ticks);
  }
}

void bx_pc_system_c::activate_timer(unsigned i, Bit32u useconds, bx_bool continuous)
{
//printf("bochsDevs::bx_pc_system_c::activate_timer(%d, %d, %d)\n", i, useconds, continuous);

  Bit64u ticks;

  // if useconds = 0, use default stored in period field
  // else set new period from useconds
  if (useconds==0) {
    ticks = timer[i].period;
  }
  else {
    // convert useconds to number of ticks
    ticks = (Bit64u) (double(useconds) * m_ips);

    // If the timer frequency is rediculously low, make it more sane.
    // This happens when 'ips' is too low.
    if (ticks < MinAllowableTimerPeriod) {
      //BX_INFO(("activate_timer: adjusting ticks of %llu to min of %u",
      //          ticks, MinAllowableTimerPeriod));
      ticks = MinAllowableTimerPeriod;
    }

    timer[i].period = ticks;
  }

  activate_timer_ticks(i, ticks, continuous);
}

void bx_pc_system_c::deactivate_timer(unsigned i) {
//printf("bochsDevs::bx_pc_system_c::deactivate_timer(%d)\n", i);

    timer[i].active = 0;
}

Bit64u bx_pc_system_c::time_usec() {
  return (Bit64u) (((double)(Bit64s)time_ticks()) / m_ips);
}

void bx_pc_system_c::countdownEvent(void) {
  unsigned i;
  Bit64u   minTimeToFire;
  bx_bool  triggered[BX_MAX_TIMERS];

  // Increment global ticks counter by number of ticks which have
  // elapsed since the last update.
  ticksTotal += Bit64u(currCountdownPeriod);
  minTimeToFire = (Bit64u) -1;

  for (i=0; i < numTimers; i++) {
    triggered[i] = 0; // Reset triggered flag.
    if (timer[i].active) {
      if (ticksTotal == timer[i].timeToFire) {
        // This timer is ready to fire.
        triggered[i] = 1;

        if (timer[i].continuous==0) {
          // If triggered timer is one-shot, deactive.
          timer[i].active = 0;
        }
        else {
          // Continuous timer, increment time-to-fire by period.
          timer[i].timeToFire += timer[i].period;
          if (timer[i].timeToFire < minTimeToFire)
            minTimeToFire = timer[i].timeToFire;
        }
      }
      else {
        // This timer is not ready to fire yet.
        if (timer[i].timeToFire < minTimeToFire)
          minTimeToFire = timer[i].timeToFire;
      }
    }
  }

  // Calculate next countdown period.  We need to do this before calling
  // any of the callbacks, as they may call timer features, which need
  // to be advanced to the next countdown cycle.
  currCountdown = currCountdownPeriod =
      Bit32u(minTimeToFire - ticksTotal);

  for (i=0; i < numTimers; i++) {
    // Call requested timer function.  It may request a different
    // timer period or deactivate etc.
    if (triggered[i]) {
      triggeredTimer = i;
      timer[i].funct(timer[i].this_ptr);
      triggeredTimer = 0;
    }
  }
}

//------------------------------------------------------------------------------

bool a20_state = true;

void bx_pc_system_c::set_HRQ(bx_bool val) {
printf("bochsDevs::bx_pc_system_c::set_HRQ() %d\n", val);
    
    if(val) {
        bx_devices.pluginDmaDevice->raise_HLDA();
    }
}

int bx_pc_system_c::Reset(unsigned type) {
printf("bochsDevs::bx_pc_system_c::Reset() %d\n", type);
std::exit(-1);
    return 0;
}

bx_bool bx_pc_system_c::get_enable_a20(void) {
printf("bochsDevs::bx_pc_system_c::get_enable_a20() %d\n", a20_state);
  return a20_state;
}

void bx_pc_system_c::set_enable_a20(bx_bool value) {
printf("bochsDevs::bx_pc_system_c::set_enable_a20(%d) %d\n", value, a20_state);
    a20_state = value;
}

void bx_pc_system_c::clear_INTR(void) {
printf("bochsDevs::bx_pc_system_c::clear_INTR()\n");
    shared_ptr->interrupt_at_counter = 0;
}

void bx_pc_system_c::raise_INTR(void) {
printf("bochsDevs::bx_pc_system_c::raise_INTR()\n");

    uint32 last = shared_ptr->interrupt_at_counter;
    
    shared_ptr->interrupt_vector = bx_devices.pluginPicDevice->IAC();
    
    uint32 v1 = shared_ptr->bochs486_pc.instr_counter + 5;
    uint32 v2 = shared_ptr->ao486.instr_counter + 5;
    
    shared_ptr->interrupt_at_counter = (v1 > v2)? v1 : v2;
    
printf("interrupt: %02x\n", shared_ptr->interrupt_vector);

    FILE *interrupt_fp = fopen("interrupt.txt", "a");
    fprintf(interrupt_fp, "irq %02x at %d (%d %d) %d\n", shared_ptr->interrupt_vector, shared_ptr->interrupt_at_counter, v1, v2, shared_ptr->interrupt_at_counter - last);
    fclose(interrupt_fp);
}

class capture_pic_stub_c : public bx_pic_stub_c {
public:
    capture_pic_stub_c(bx_pic_stub_c *orig) {
        this->orig = orig;
    }
    
    virtual void raise_irq(unsigned irq_no) {
        FILE *fp = fopen("track.txt", "a");
        fprintf(fp, "raise_irq %d\n", irq_no);
        fclose(fp);
        
        orig->raise_irq(irq_no);
    }
    
    virtual void lower_irq(unsigned irq_no) {
        FILE *fp = fopen("track.txt", "a");
        fprintf(fp, "lower_irq %d\n", irq_no);
        fclose(fp);
        
        orig->lower_irq(irq_no);
    }
    
    virtual void set_mode(bx_bool ma_sl, Bit8u mode) {
        FILE *fp = fopen("track.txt", "a");
        fprintf(fp, "set_mode %d %d\n", ma_sl, mode);
        fclose(fp);
        
        orig->set_mode(ma_sl, mode);
    }
    
    virtual Bit8u IAC(void) {
        Bit8u ret = orig->IAC();
        
        FILE *fp = fopen("track.txt", "a");
        fprintf(fp, "IAC %d\n", ret);
        fclose(fp);
        
        return ret;
    }
    
private:
    bx_pic_stub_c *orig;
};

bx_pc_system_c bx_pc_system;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

Bit64u bx_get_realtime64_usec(void)
{
  timeval thetime;
  gettimeofday(&thetime,0);
  Bit64u mytime;
  mytime=(Bit64u)thetime.tv_sec*(Bit64u)1000000+(Bit64u)thetime.tv_usec;
  return mytime;
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

bx_devices_c::bx_devices_c() {
}
bx_devices_c::~bx_devices_c() {
}

void bx_devices_c::mouse_motion(int delta_x, int delta_y, int delta_z, unsigned button_state, bx_bool absxy) {
printf("bochsDevs::bx_devices_c::mouse_motion()\n");
  // If mouse events are disabled on the GUI headerbar, don't
  // generate any mouse data
  if (!mouse_captured)
    return;

  // if a removable mouse is connected, redirect mouse data to the device
  if (bx_mouse[1].dev != NULL) {
    bx_mouse[1].enq_event(bx_mouse[1].dev, delta_x, delta_y, delta_z, button_state, absxy);
    return;
  }

  // if a mouse is connected, direct mouse data to the device
  if (bx_mouse[0].dev != NULL) {
    bx_mouse[0].enq_event(bx_mouse[0].dev, delta_x, delta_y, delta_z, button_state, absxy);
  }
}

bx_bool bx_devices_c::optional_key_enq(Bit8u *scan_code) {
printf("bochsDevs::bx_devices_c::optional_key_enq()\n");
  if (bx_keyboard.dev != NULL) {
    return bx_keyboard.enq_event(bx_keyboard.dev, scan_code);
  }
  return 0;
}

void bx_devices_c::mouse_enabled_changed(bx_bool enabled) {
printf("bochsDevs::bx_devices_c::mouse_enabled_changed()\n");
  mouse_captured = enabled;

  if ((bx_mouse[1].dev != NULL) && (bx_mouse[1].enabled_changed != NULL)) {
    bx_mouse[1].enabled_changed(bx_mouse[1].dev, enabled);
    return;
  }

  if ((bx_mouse[0].dev != NULL) && (bx_mouse[0].enabled_changed != NULL)) {
    bx_mouse[0].enabled_changed(bx_mouse[0].dev, enabled);
  }
}

void bx_devices_c::register_default_mouse(void *dev, bx_mouse_enq_t mouse_enq,
                                          bx_mouse_enabled_changed_t mouse_enabled_changed)
{
printf("bochsDevs::bx_devices_c::register_default_mouse()\n");
  if (bx_mouse[0].dev == NULL) {
    bx_mouse[0].dev = dev;
    bx_mouse[0].enq_event = mouse_enq;
    bx_mouse[0].enabled_changed = mouse_enabled_changed;
  }
}

bx_devices_c bx_devices;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

const char *hdimage_mode_names[] = { 
  "flat",
  "concat",
  "external",
  "dll",
  "sparse",
  "vmware3",
  "vmware4",
  "undoable",
  "growing",
  "volatile",
  "vvfat",
  "vpc",
  NULL
};

void bx_stop_simulation() {
printf("bochsDevs::bx_stop_simulation()\n");
}

class BX_CPU_C : public logfunctions {
};

BX_CPU_C bx_cpu;

bx_bool bx_user_quit;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

void register_plugin(const char *libname, const char *initname) {

    void *handle;
    
    handle = dlopen(libname, RTLD_NOW | RTLD_GLOBAL);
    
    if(handle == NULL) {
        char *error = dlerror();
        
        printf("dlopen() error: %s\n", error);
        exit(-1);
    }
    
    
    plugin_init_t plugin_init = (plugin_init_t)dlsym(handle, initname);
    if(plugin_init == NULL) {
        char *error = dlerror();
        
        printf("dlsym() error: %s\n", error);
        
        dlclose(handle);
        exit(-2);
    }
    
    plugin_init(NULL, PLUGTYPE_CORE, 0,NULL);
    
    //dlclose(handle);
}

int main(int argc, char **argv) {
    
    //map shared memory
    int fd = open("./../sim/sim_pc/shared_mem.dat", O_RDWR, S_IRUSR | S_IWUSR);
    
    if(fd == -1) {
        perror("open() failed for shared_mem.dat");
        return -1;
    }
    
    shared_ptr = (shared_mem_t *)mmap(NULL, sizeof(shared_mem_t), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    
    if(shared_ptr == MAP_FAILED) {
        perror("mmap() failed");
        close(fd);
        return -2;
    }
    
    //wait for ack

    shared_ptr->bochsDevs_starting = STEP_REQ;
    printf("Waiting for startup ack...");
    fflush(stdout);
    while(shared_ptr->bochsDevs_starting != STEP_ACK) {
        usleep(100000);
    }
    printf("done.\n");
    
    //--------------------------------------------------------------------------
    
    printf("bochsDevs\n");
    
    FILE *debug_fp = fopen("output.txt", "w");
    
    pluginRegisterIRQ = builtinRegisterIRQ;
    
    pluginRegisterIOReadHandler = builtinRegisterIOReadHandler;
    pluginRegisterIOWriteHandler = builtinRegisterIOWriteHandler;

    pluginRegisterDefaultIOReadHandler = builtinRegisterDefaultIOReadHandler;
    pluginRegisterDefaultIOWriteHandler = builtinRegisterDefaultIOWriteHandler;
    
    
    SIM = new bochsDevs_sim();
    
    bx_virt_timer.init();
    
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_unmapped.so.0.0.0",   "libunmapped_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_biosdev.so.0.0.0",    "libbiosdev_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_cmos.so.0.0.0",       "libcmos_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_dma.so.0.0.0",        "libdma_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_x.so.0.0.0",          "libx_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_floppy.so.0.0.0",     "libfloppy_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_hdimage.so.0.0.0",    "libhdimage_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_harddrv.so.0.0.0",    "libharddrv_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_iodebug.so.0.0.0",    "libiodebug_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_keyboard.so.0.0.0",   "libkeyboard_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_pic.so.0.0.0",        "libpic_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_pit.so.0.0.0",        "libpit_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_speaker.so.0.0.0",    "libspeaker_LTX_plugin_init");
    register_plugin("/opt/bochs-2.6.2/lib/bochs/plugins/libbx_vga.so.0.0.0",        "libvga_LTX_plugin_init");
    
    // misc. CMOS
    Bit64u memory_in_bytes = sizeof(shared_ptr->mem.bytes);
    Bit64u BASE_MEMORY_IN_K = 640;
    
    Bit64u memory_in_k = memory_in_bytes / 1024;
    Bit64u extended_memory_in_k = memory_in_k > 1024 ? (memory_in_k - 1024) : 0;
    if (extended_memory_in_k > 0xfc00) extended_memory_in_k = 0xfc00;

    DEV_cmos_set_reg(0x15, (Bit8u) BASE_MEMORY_IN_K);
    DEV_cmos_set_reg(0x16, (Bit8u) (BASE_MEMORY_IN_K >> 8));
    DEV_cmos_set_reg(0x17, (Bit8u) (extended_memory_in_k & 0xff));
    DEV_cmos_set_reg(0x18, (Bit8u) ((extended_memory_in_k >> 8) & 0xff));
    DEV_cmos_set_reg(0x30, (Bit8u) (extended_memory_in_k & 0xff));
    DEV_cmos_set_reg(0x31, (Bit8u) ((extended_memory_in_k >> 8) & 0xff));

    Bit64u extended_memory_in_64k = memory_in_k > 16384 ? (memory_in_k - 16384) / 64 : 0;
    // Limit to 3 GB - 16 MB. PCI Memory Address Space starts at 3 GB.
    if (extended_memory_in_64k > 0xbf00) extended_memory_in_64k = 0xbf00;

    DEV_cmos_set_reg(0x34, (Bit8u) (extended_memory_in_64k & 0xff));
    DEV_cmos_set_reg(0x35, (Bit8u) ((extended_memory_in_64k >> 8) & 0xff));

    Bit64u memory_above_4gb = (memory_in_bytes > BX_CONST64(0x100000000)) ?
                                (memory_in_bytes - BX_CONST64(0x100000000)) : 0;
    if (memory_above_4gb) {
        DEV_cmos_set_reg(0x5b, (Bit8u)(memory_above_4gb >> 16));
        DEV_cmos_set_reg(0x5c, (Bit8u)(memory_above_4gb >> 24));
        DEV_cmos_set_reg(0x5d, memory_above_4gb >> 32);
    }

    /* now perform checksum of CMOS memory */
    DEV_cmos_checksum();
    
    //replace pic with capture
    capture_pic_stub_c *capture = new capture_pic_stub_c(bx_devices.pluginPicDevice);
    bx_devices.pluginPicDevice = capture;
    
    uint32 last_instr_counter = 0;
    while(true) {
        
        //---------------------------------------------------------------------- stop
        
        if(shared_ptr->bochsDevs_stop == STEP_REQ) {
            shared_ptr->bochsDevs_stop = STEP_ACK;
            while(shared_ptr->bochsDevs_stop != STEP_IDLE) {
                usleep(500);
            }
        }
        
        //---------------------------------------------------------------------- irq
        
        static step_t last_pit_irq_step = STEP_IDLE;
        
        if(last_pit_irq_step == STEP_IDLE && shared_ptr->pit_irq_step == STEP_REQ) {
            bx_devices.pluginPicDevice->raise_irq(0);
            last_pit_irq_step = STEP_REQ;
        }
        else if(last_pit_irq_step == STEP_REQ && shared_ptr->pit_irq_step == STEP_IDLE) {
            bx_devices.pluginPicDevice->lower_irq(0);
            last_pit_irq_step = STEP_IDLE;
        }
        
        static step_t last_rtc_irq_step = STEP_IDLE;
        
        if(last_rtc_irq_step == STEP_IDLE && shared_ptr->rtc_irq_step == STEP_REQ) {
            bx_devices.pluginPicDevice->raise_irq(8);
            last_rtc_irq_step = STEP_REQ;
        }
        else if(last_rtc_irq_step == STEP_REQ && shared_ptr->rtc_irq_step == STEP_IDLE) {
            bx_devices.pluginPicDevice->lower_irq(8);
            last_rtc_irq_step = STEP_IDLE;
        }
        
        static step_t last_floppy_irq_step = STEP_IDLE;
        
        if(last_floppy_irq_step == STEP_IDLE && shared_ptr->floppy_irq_step == STEP_REQ) {
            bx_devices.pluginPicDevice->raise_irq(6);
            last_floppy_irq_step = STEP_REQ;
        }
        else if(last_floppy_irq_step == STEP_REQ && shared_ptr->floppy_irq_step == STEP_IDLE) {
            bx_devices.pluginPicDevice->lower_irq(6);
            last_floppy_irq_step = STEP_IDLE;
        }
        
        static step_t last_keyboard_irq_step = STEP_IDLE;
        
        if(last_keyboard_irq_step == STEP_IDLE && shared_ptr->keyboard_irq_step == STEP_REQ) {
            bx_devices.pluginPicDevice->raise_irq(1);
            last_keyboard_irq_step = STEP_REQ;
        }
        else if(last_keyboard_irq_step == STEP_REQ && shared_ptr->keyboard_irq_step == STEP_IDLE) {
            bx_devices.pluginPicDevice->lower_irq(1);
            last_keyboard_irq_step = STEP_IDLE;
        }
        
        static step_t last_mouse_irq_step = STEP_IDLE;
        
        if(last_mouse_irq_step == STEP_IDLE && shared_ptr->mouse_irq_step == STEP_REQ) {
            bx_devices.pluginPicDevice->raise_irq(12);
            last_mouse_irq_step = STEP_REQ;
        }
        else if(last_mouse_irq_step == STEP_REQ && shared_ptr->mouse_irq_step == STEP_IDLE) {
            bx_devices.pluginPicDevice->lower_irq(12);
            last_mouse_irq_step = STEP_IDLE;
        }
        
        //---------------------------------------------------------------------- service io
        
        if(shared_ptr->combined.io_step == STEP_REQ) {
            
            uint32 address = shared_ptr->combined.io_address & 0xFFFF;
            uint32 byteena = shared_ptr->combined.io_byteenable;
            uint32 value   = shared_ptr->combined.io_data;
            uint32 shifted = 0;
            
            if(address == 0x01F0 || address == 0x01F4 || (address == 0x03F4 && byteena == 0x4) || address == 0x0040 || (address == 0x0060 && byteena == 0x2) ||
               (address == 0x0070 && (byteena == 0x1 || byteena == 0x02)) || (address == 0x03F4 && ((byteena >> 2) & 1) == 0) || address == 0x03F0 ||
               address == 0x0000 || address == 0x0004 || address == 0x0008 || address == 0x000C ||
               address == 0x0080 || address == 0x0084 || address == 0x0088 || address == 0x008C ||
               address == 0x00C0 || address == 0x00C4 || address == 0x00C8 || address == 0x00CC ||
               address == 0x00D0 || address == 0x00D4 || address == 0x00D8 || address == 0x00DC ||
               address == 0x03B0 || address == 0x03B4 || address == 0x03B8 || address == 0x03BC ||
               address == 0x03C0 || address == 0x03C4 || address == 0x03C8 || address == 0x03CC ||
               address == 0x03D0 || address == 0x03D4 || address == 0x03D8 || address == 0x03DC ||
               (address == 0x0060 && ((byteena >> 1) & 1) == 0) || address == 0x0064 ||
               address == 0x0090 || address == 0x0094 || address == 0x0098 || address == 0x009C ||
               (address == 0x0020 && ((byteena >> 2) & 3) == 0) || (address == 0x00A0 && ((byteena >> 2) & 3) == 0) ||
               address == 0x8888 || address == 0x888C)
            {
                //
            }
            else {
                if(shared_ptr->combined.io_is_write) {
                    FILE *fp = fopen("track.txt", "a");
                    fprintf(fp, "io wr %04x %x %08x\n", address, byteena, value);
                    fclose(fp);
                }
            
                for(uint32 i=0; i<4; i++) {
                    if(byteena & 1) break;
                    
                    shifted++;
                    address++;
                    byteena >>= 1;
                    value >>= 8;
                }
                uint32 length = 0;
                for(uint32 i=0; i<4; i++) {
                    if(byteena & 1) length++;
                    
                    byteena >>= 1;
                }
                
                if(shared_ptr->combined.io_is_write) {
                    ioWriteHandler_t handler = io_write_handlers[address];
                    uint8 mask = io_write_mask[address];
                    void *this_ptr = io_write_this[address];
                    
                    if(handler == NULL) {
                        handler = io_write_handlers[65536];
                        mask = io_write_mask[65536];
                    }
                    
                    if(mask & length) {
                        ((bx_write_handler_t)handler)(this_ptr, address, value, length);
                    }
                    else {
                        printf("bochsDevs::io write mismatch: mask=%d, length=%d, address=%04x\n", mask, length, address);
                    }
                    
                    if(address == 0x92) {
                        a20_state = (value & 2)? 1 : 0;
                    }
                    
                    /*
                    if(address == 0x8888) {
                        fprintf(debug_fp, "%c", value & 0xFF);
                        fflush(debug_fp);
                    }
                    */
                }
                else {
                    ioReadHandler_t handler = io_read_handlers[address];
                    uint8 mask = io_read_mask[address];
                    void *this_ptr = io_read_this[address];
                    
                    if(handler == NULL) {
                        handler = io_read_handlers[65536];
                        mask = io_read_mask[65536];
                    }
                    
                    uint32 ret = 0xFFFFFF;
                    
                    if(mask & length) {
                        ret = ((bx_read_handler_t)handler)(this_ptr, address, length);
                    }
                    else {
                        printf("bochsDevs::io read mismatch: mask=%d, length=%d, address=%04x\n", mask, length, address);
                        ret = (length == 1)? 0xFF : (length == 2)? 0xFFFF : 0xFFFFFFFF;
                    }
                    
                    if(address == 0x92) {
                        ret = (a20_state)? 0x02 : 0x00;
                    }
                    
                    ret &= (length == 1)? 0xFF : (length == 2)? 0xFFFF : (length == 3)? 0xFFFFFF : 0xFFFFFFFF;
                    shared_ptr->combined.io_data = ret << (8*shifted);
                    
                    FILE *fp = fopen("track.txt", "a");
                    fprintf(fp, "io rd %04x %x %08x\n", shared_ptr->combined.io_address & 0xFFFF, shared_ptr->combined.io_byteenable, shared_ptr->combined.io_data);
                    fclose(fp);
                }
                shared_ptr->combined.io_step = STEP_ACK;
            }
        }
        
        //---------------------------------------------------------------------- service vga memory
        
        /*
        if(shared_ptr->combined.mem_step == STEP_REQ) {
            uint32 address = shared_ptr->combined.mem_address;
            uint32 byteena = shared_ptr->combined.mem_byteenable;
            uint32 value   = shared_ptr->combined.mem_data;
            uint32 shifted = 0;
            
            for(uint32 i=0; i<4; i++) {
                if(byteena & 1) break;
                
                shifted++;
                address++;
                byteena >>= 1;
                value >>= 8;
            }
            uint32 length = 0;
            for(uint32 i=0; i<4; i++) {
                if(byteena & 1) length++;
                
                byteena >>= 1;
            }
            
            if(address >= 0xA0000 && address < 0xC0000) {
                if(shared_ptr->combined.mem_is_write) {
                    (vga_write_memory)(address, length, &value, vga_param);
                    
                    FILE *fp = fopen("track.txt", "a");
                    fprintf(fp, "vga wr %08x %x %08x\n", address, byteena, value);
                    fclose(fp);
                }
                else {
                    uint32 ret = 0xFFFFFF;
                    (vga_read_memory)(address, length, &ret, vga_param);
                    
                    ret &= (length == 1)? 0xFF : (length == 2)? 0xFFFF : (length == 3)? 0xFFFFFF : 0xFFFFFFFF;
                    shared_ptr->combined.mem_data = ret << (8*shifted);
                    
                    FILE *fp = fopen("track.txt", "a");
                    fprintf(fp, "vga rd %08x %x %08x\n", shared_ptr->combined.mem_address, shared_ptr->combined.mem_byteenable, shared_ptr->combined.mem_data);
                    fclose(fp);
                }
                shared_ptr->combined.mem_step = STEP_ACK;
            }
        }
        */
        
        //----------------------------------------------------------------------
        
        bx_gui->handle_events();
        
        //bx_pc_system.tickn(1);
        //usleep(100);
        uint32 snapshot = shared_ptr->bochs486_pc.instr_counter;
        if(snapshot > last_instr_counter) {
            bx_pc_system.tickn(snapshot - last_instr_counter); //500 -- hang (too fast interrupt), 100 -- ok
            last_instr_counter = snapshot;
        }
        usleep(10);
    }
    
    return 0;
}
