
#ifndef _HARDWARE_H_
#define _HARDWARE_H_

//-----------------------------------------------------------------------------

#define INSYS_VENDOR_ID     0x4953
#define AMBPEX8_DEVID		0x5503
#define AMBPEX5_DEVID		0x5507

//-----------------------------------------------------------------------------

#define MAX_PEXDEVICE_SUPPORT   4

//-----------------------------------------------------------------------------
struct pex_device;
//-----------------------------------------------------------------------------

int set_device_name(struct pex_device *brd, u16 dev_id, int index);
int InitializeBoard(struct pex_device *brd);
u32 ReadOperationReg(struct pex_device *brd, u32 RelativePort);
void WriteOperationReg(struct pex_device *brd, u32 RelativePort, u32 Value);
u16 ReadOperationWordReg(struct pex_device *brd, u32 RelativePort);
void WriteOperationWordReg(struct pex_device *brd, u32 RelativePort, u16 Value);
u32 ReadAmbReg(struct pex_device *brd, u32 AdmNumber, u32 RelativePort);
u32 ReadAmbMainReg(struct pex_device *brd, u32 RelativePort);
void WriteAmbReg(struct pex_device *brd, u32 AdmNumber, u32 RelativePort, u32 Value);
void WriteAmbMainReg(struct pex_device *brd, u32 RelativePort, u32 Value);
void ReadBufAmbReg(struct pex_device *brd, u32 AdmNumber, u32 RelativePort, u32* VirtualAddress, u32 DwordsCount);
void WriteBufAmbReg(struct pex_device *brd, u32 AdmNumber, u32 RelativePort, u32* VirtualAddress, u32 DwordsCount);
void WriteBufAmbMainReg(struct pex_device *brd, u32 RelativePort, u32* VirtualAddress, u32 DwordsCount);
void TimeoutTimerCallback(unsigned long arg );
void SetRelativeTimer ( struct timer_list *timer, int timeout, void *data );
void CancelTimer ( struct timer_list *timer );
int WaitCmdReady(struct pex_device *brd, u32 AdmNumber, u32 StatusAddress);
int WriteRegData(struct pex_device *brd, u32 AdmNumber, u32 TetrNumber, u32 RegNumber, u32 Value);
void ToPause(int time_out);
void ToTimeOut(int mctime_out);
int ReadRegData(struct pex_device *brd, u32 AdmNumber, u32 TetrNumber, u32 RegNumber, u32 *Value);
int SetDmaMode(struct pex_device *brd, u32 NumberOfChannel, u32 AdmNumber, u32 TetrNumber);
int SetDrqFlag(struct pex_device *brd, u32 AdmNumber, u32 TetrNumber, u32 DrqFlag);
int DmaEnable(struct pex_device *brd, u32 AdmNumber, u32 TetrNumber);
int DmaDisable(struct pex_device *brd, u32 AdmNumber, u32 TetrNumber);
int ResetFifo(struct pex_device *brd, u32 NumberOfChannel);
int Done(struct pex_device *brd, u32 NumberOfChannel);
int HwStartDmaTransfer(struct pex_device *brd, u32 NumberOfChannel);
int HwCompleteDmaTransfer(struct pex_device *brd, u32 NumberOfChannel);

//-----------------------------------------------------------------------------

int lock_pages( void *va, u32 size );
int unlock_pages( void *va, u32 size );

//-----------------------------------------------------------------------------

#endif //_HARDWARE_H_
