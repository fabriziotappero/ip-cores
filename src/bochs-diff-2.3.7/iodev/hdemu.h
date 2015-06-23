#ifndef BX_IODEV_HDEMU_H
#define BX_IODEV_HDEMU_H

#define BX_USE_HDEMU_SMF      1

#if BX_USE_HDEMU_SMF
#  define BX_HDEMU_SMF  static
#  define BX_HDEMU_THIS theHdemuDevice->
#else
#  define BX_HDEMU_SMF
#  define BX_HDEMU_THIS this->
#endif

class bx_hdemu_c : public bx_devmodel_c {
public:
  bx_hdemu_c();
  virtual ~bx_hdemu_c();
  virtual void init(void);
  virtual void reset(unsigned type);
  virtual void register_state(void);

private:
  FILE *input;
  Bit16u base;

  static Bit32u read_handler(void *this_ptr, Bit32u address, unsigned io_len);
  static void   write_handler(void *this_ptr, Bit32u address, Bit32u value, unsigned io_len);
#if !BX_USE_HDEMU_SMF
  Bit32u read(Bit32u address, unsigned io_len);
  void   write(Bit32u address, Bit32u value, unsigned io_len);
#endif
};

#endif
