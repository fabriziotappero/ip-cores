
#ifndef _IOCTLRW_H_
#define _IOCTLRW_H_

//-----------------------------------------------------------------------------

int ioctl_board_info(struct pex_device *brd, unsigned long arg);
int ioctl_memory_alloc(struct pex_device *brd, unsigned long arg);
int ioctl_memory_free(struct pex_device *brd, unsigned long arg);
int ioctl_stub_alloc(struct pex_device *brd, unsigned long arg);
int ioctl_stub_free(struct pex_device *brd, unsigned long arg);
int ioctl_set_mem(struct pex_device *brd, unsigned long arg);
int ioctl_free_mem(struct pex_device *brd, size_t arg);
int ioctl_start_mem(struct pex_device *brd, size_t arg);
int ioctl_stop_mem(struct pex_device *brd, size_t arg);
int ioctl_state_mem(struct pex_device *brd, size_t arg);
int ioctl_set_dir_mem(struct pex_device *brd, size_t arg);
int ioctl_set_src_mem(struct pex_device *brd, size_t arg);
int ioctl_set_drq_mem(struct pex_device *brd, size_t arg);
int ioctl_adjust(struct pex_device *brd, size_t arg);
int ioctl_done(struct pex_device *brd, size_t arg);
int ioctl_reset_fifo(struct pex_device *brd, size_t arg);
int ioctl_get_dma_channel_info(struct pex_device *brd, size_t arg);
int ioctl_wait_dma_buffer(struct pex_device *brd, size_t arg);
int ioctl_wait_dma_block(struct pex_device *brd, size_t arg);

//-----------------------------------------------------------------------------

#endif //_IOCTLRW_H_
