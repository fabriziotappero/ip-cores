
#include <linux/kernel.h>
#define __NO_VERSION__
#include <linux/module.h>
#include <linux/types.h>
#include <linux/ioport.h>
#include <linux/pci.h>
#include <linux/pagemap.h>
#include <linux/interrupt.h>
#include <linux/proc_fs.h>
#include <linux/delay.h>
#include <asm/io.h>

#include "pexmodule.h"
#include "hardware.h"
#include "ambpexregs.h"
#include "memory.h"


int g_isAdm=0;
//--------------------------------------------------------------------

int set_device_name(struct pex_device *brd, u16 dev_id, int index)
{
    if(!brd)
	return -1;

    switch(dev_id) {
    case AMBPEX5_DEVID: snprintf(brd->m_name, 128, "%s%d", "AMBPEX5", index); break;

    default:
        snprintf(brd->m_name, sizeof(brd->m_name), "%s%d", "Unknown", index); break;
    }

    return 0;
}

//--------------------------------------------------------------------

void read_memory32(u32 *src, u32 *dst, u32 cnt)
{
    int i=0;
    for(i=0; i<cnt; i++) {
        dst[i] = readl(src);
    }
}

//--------------------------------------------------------------------

void write_memory32(u32 *src, u32 *dst, u32 cnt)
{
    int i=0;
    for(i=0; i<cnt; i++) {
        writel(src[i], dst);
    }
}

//--------------------------------------------------------------------

int InitializeBoard(struct pex_device *brd)
{
    u16 temp = 0;  // holds registers while we are modifying bits
    u16 blockId = 0;
    u16 blockVer = 0;
    u16 deviceID = 0;
    u16 deviceRev = 0;
    int iChan = 0;
    int iBlock = 0;
    int i = 0;
    FIFO_ID FifoId;

    blockId = ReadOperationWordReg(brd, PEMAINadr_BLOCK_ID);
    blockVer = ReadOperationWordReg(brd, PEMAINadr_BLOCK_VER);

    dbg_msg(dbg_trace, "%s(): BlockID = 0x%X, BlockVER = 0x%X.\n", __FUNCTION__, blockId, blockVer);

    deviceID = ReadOperationWordReg(brd, PEMAINadr_DEVICE_ID);
    deviceRev = ReadOperationWordReg(brd, PEMAINadr_DEVICE_REV);

    dbg_msg(dbg_trace, "%s(): DeviceID = 0x%X, DeviceRev = 0x%X.\n", __FUNCTION__, deviceID, deviceRev);



    temp = ReadOperationWordReg(brd, PEMAINadr_PLD_VER);

    dbg_msg(dbg_trace, "%s(): PldVER = 0x%X.\n", __FUNCTION__, temp);

    brd->m_BlockCnt = ReadOperationWordReg(brd, PEMAINadr_BLOCK_CNT);

    dbg_msg(dbg_trace, "%s(): Block count = %d.\n", __FUNCTION__, brd->m_BlockCnt);

    // начальное обнуление информации о каналах ПДП
    brd->m_DmaChanMask = 0;
    for(iChan = 0; iChan < MAX_NUMBER_OF_DMACHANNELS; iChan++)
    {
        brd->m_BlockFifoId[iChan] = 0;
        brd->m_DmaFifoSize[iChan] = 0;
        brd->m_DmaDir[iChan] = 0;
        brd->m_MaxDmaSize[iChan] = 0;
    }

    // определим какие каналы ПДП присутствуют и их характеристики:
    // направление передачи данных, размер FIFO, максимальный размер блока ПДП
    for(iBlock = 0; iBlock < brd->m_BlockCnt; iBlock++)
    {
        u32 FifoAddr = 0;
        u16 block_id = 0;
        FifoAddr = (iBlock + 1) * PE_FIFO_ADDR;
        temp = ReadOperationWordReg(brd, PEFIFOadr_BLOCK_ID + FifoAddr);
        block_id = (temp & 0x0FFF);
        if(block_id == PE_EXT_FIFO_ID)
        {
            u32 resource_id = 0;
            u16 iChan = ReadOperationWordReg(brd, PEFIFOadr_FIFO_NUM + FifoAddr);
            brd->m_FifoAddr[iChan] = FifoAddr;
            brd->m_BlockFifoId[iChan] = block_id;
            brd->m_DmaChanMask |= (1 << iChan);
            FifoId.AsWhole = ReadOperationWordReg(brd, PEFIFOadr_FIFO_ID + FifoAddr);
            brd->m_DmaFifoSize[iChan] = FifoId.ByBits.Size;
            brd->m_DmaDir[iChan] = FifoId.ByBits.Dir;
            brd->m_MaxDmaSize[iChan] = 0x40000000; // макс. размер ПДП пусть будет 1 Гбайт
            resource_id = ReadOperationWordReg(brd, PEFIFOadr_DMA_SIZE + FifoAddr); // RESOURCE
            dbg_msg(dbg_trace, "%s(): Channel(ID) = %d(0x%x), FIFO size = %d Bytes, DMA Dir = %d, Max DMA size = %d MBytes, resource = 0x%x.\n", __FUNCTION__,
                    iChan, block_id, brd->m_DmaFifoSize[iChan] * 4, brd->m_DmaDir[iChan], brd->m_MaxDmaSize[iChan] / 1024 / 1024, resource_id);
        }
    }

    dbg_msg(dbg_trace, "%s(): m_DmaChanMask = 0x%X\n", __FUNCTION__, brd->m_DmaChanMask);


    // подготовим к работе ПЛИС ADM
    dbg_msg(dbg_trace, "%s(): Prepare ADM PLD.\n", __FUNCTION__);
    WriteOperationWordReg(brd,PEMAINadr_BRD_MODE, 0);
    ToPause(100);	// pause ~ 100 msec
    for(i = 0; i < 10; i++)
    {
        WriteOperationWordReg(brd, PEMAINadr_BRD_MODE, 1);
        ToPause(100);	// pause ~ 100 msec
        WriteOperationWordReg(brd, PEMAINadr_BRD_MODE, 3);
        ToPause(100);	// pause ~ 100 msec
        WriteOperationWordReg(brd, PEMAINadr_BRD_MODE, 7);
        ToPause(100);	// pause ~ 100 msec
        temp = ReadOperationWordReg(brd, PEMAINadr_BRD_STATUS) & 0x01;
        if(temp)
            break;
    }
    WriteOperationWordReg(brd, PEMAINadr_BRD_MODE, 0x0F);
    ToPause(100);	// pause ~ 100 msec

    if(temp)
    {
        u32 idx = 0;
        BRD_STATUS brd_status;
        dbg_msg(dbg_trace, "%s(): ADM PLD is captured.\n", __FUNCTION__);
        brd_status.AsWhole = ReadOperationWordReg(brd, PEMAINadr_BRD_STATUS);
        if(AMBPEX8_DEVID == deviceID)
            brd_status.ByBits.InFlags &= 0x80; // 1 - ADM PLD in test mode
        else
            brd_status.ByBits.InFlags = 0x80; // 1 - ADM PLD in test mode
        if(brd_status.ByBits.InFlags)
        {
            BRD_MODE brd_mode;
            dbg_msg(dbg_trace, "%s(): ADM PLD in test mode.\n", __FUNCTION__);

            // проверка линий передачи флагов
            brd_mode.AsWhole = ReadOperationWordReg(brd, PEMAINadr_BRD_MODE);
            for(idx = 0; idx < 4; idx++)
            {
                brd_mode.ByBits.OutFlags = idx;
                WriteOperationWordReg(brd, PEMAINadr_BRD_MODE, brd_mode.AsWhole);
                ToPause(10);
                brd_status.AsWhole = ReadOperationWordReg(brd, PEMAINadr_BRD_STATUS);
                brd_status.ByBits.InFlags &= 0x03;
                if(brd_mode.ByBits.OutFlags != brd_status.ByBits.InFlags)
                {
                    temp = 0;
                    dbg_msg(dbg_trace, "%s(): FLG_IN (%d) NOT equ FLG_OUT (%d).\n", __FUNCTION__,
                            brd_status.ByBits.InFlags, brd_mode.ByBits.OutFlags);
                    break;
                }
            }
            if(temp)
                dbg_msg(dbg_trace, "%s(): FLG_IN equ FLG_OUT.\n", __FUNCTION__);
        }
        else
            temp = 0;
    }

    if(!temp)
    {
        WriteOperationWordReg(brd, PEMAINadr_BRD_MODE, 0);
        ToPause(100);	// pause ~ 100 msec
    }


    brd->m_PldStatus[0] = temp; // состояние ПЛИС ADM: 0 - не готова

    dbg_msg(dbg_trace, "%s(): ADM PLD[%d] status = 0x%X.\n", __FUNCTION__, i, temp);

    {
        BRD_MODE brd_mode;
        brd_mode.AsWhole = ReadOperationWordReg(brd, PEMAINadr_BRD_MODE);
        brd_mode.ByBits.OutFlags = 0;
        WriteOperationWordReg(brd, PEMAINadr_BRD_MODE, brd_mode.AsWhole);
        dbg_msg(dbg_trace, "%s(): BRD_MODE = 0x%X.\n", __FUNCTION__, brd_mode.AsWhole);
    }

    WriteOperationWordReg(brd, PEMAINadr_IRQ_MASK, 0x4000);

    //WriteAmbMainReg(brd, 0x0, 0x1);
    //WriteAmbMainReg(brd, 0x0, 0x1);

    return 0;
}

//--------------------------------------------------------------------

u32 ReadOperationReg(struct pex_device *brd, u32 RelativePort)
{
    return readl((u32*)((u8*)brd->m_BAR0.virtual_address + RelativePort));
}

//--------------------------------------------------------------------

void WriteOperationReg(struct pex_device *brd, u32 RelativePort, u32 Value)
{
    writel( Value, (u32*)((u8*)brd->m_BAR0.virtual_address + RelativePort));
}

//--------------------------------------------------------------------

u16 ReadOperationWordReg(struct pex_device *brd, u32 RelativePort)
{
    u32 tmpVal = readl((u32*)((u8*)brd->m_BAR0.virtual_address + RelativePort));
    return (tmpVal & 0xFFFF);
    //return readw((u16*)((u8*)brd->m_BAR0.virtual_address + RelativePort));
}

//--------------------------------------------------------------------

void WriteOperationWordReg(struct pex_device *brd, u32 RelativePort, u16 Value)
{
    u32 tmpVal = Value;
    //writew( Value, (u16*)((u8*)brd->m_BAR0.virtual_address + RelativePort));
    writel( tmpVal, (u32*)((u8*)brd->m_BAR0.virtual_address + RelativePort));
}

//--------------------------------------------------------------------

u32 ReadAmbReg(struct pex_device *brd, u32 AdmNumber, u32 RelativePort)
{
    u8* pBaseAddress = (u8*)brd->m_BAR1.virtual_address + AdmNumber * ADM_SIZE;
    return readl((u32*)(pBaseAddress + RelativePort));
}

//--------------------------------------------------------------------

u32 ReadAmbMainReg(struct pex_device *brd, u32 RelativePort)
{
    return readl((u32*)((u8*)brd->m_BAR1.virtual_address + RelativePort));
}

//--------------------------------------------------------------------

void WriteAmbReg(struct pex_device *brd, u32 AdmNumber, u32 RelativePort, u32 Value)
{
    u8* pBaseAddress = (u8*)brd->m_BAR1.virtual_address + AdmNumber * ADM_SIZE;
    writel( Value, (u32*)(pBaseAddress + RelativePort) );
}

//--------------------------------------------------------------------

void WriteAmbMainReg(struct pex_device *brd, u32 RelativePort, u32 Value)
{
    writel( Value, (u32*)((u8*)brd->m_BAR1.virtual_address + RelativePort));
}

//--------------------------------------------------------------------

void ReadBufAmbReg(struct pex_device *brd, u32 AdmNumber, u32 RelativePort, u32* VirtualAddress, u32 DwordsCount)
{
    u8* pBaseAddress = (u8*)brd->m_BAR1.virtual_address + AdmNumber * ADM_SIZE;
    read_memory32((u32*)(pBaseAddress + RelativePort),VirtualAddress,DwordsCount);
}

//--------------------------------------------------------------------

void WriteBufAmbReg(struct pex_device *brd, u32 AdmNumber, u32 RelativePort, u32* VirtualAddress, u32 DwordsCount)
{
    u8* pBaseAddress = (u8*)brd->m_BAR1.virtual_address + AdmNumber * ADM_SIZE;
    write_memory32((u32*)(pBaseAddress + RelativePort), VirtualAddress, DwordsCount);
}

//--------------------------------------------------------------------

void WriteBufAmbMainReg(struct pex_device *brd, u32 RelativePort, u32* VirtualAddress, u32 DwordsCount)
{
    write_memory32( (u32*)((u8*)brd->m_BAR1.virtual_address + RelativePort), VirtualAddress, DwordsCount);
}

//--------------------------------------------------------------------

void TimeoutTimerCallback(unsigned long arg )
{
    struct pex_device *pDevice = (struct pex_device*) arg;
    atomic_set(&pDevice->m_IsTimeout, 1);
}

//--------------------------------------------------------------------

void SetRelativeTimer ( struct timer_list *timer, int timeout, void *data )
{
    struct pex_device *dev = (struct pex_device*)data;

    if (!dev)
        return;

    atomic_set( &dev->m_IsTimeout, 0 );

    timer->data = ( unsigned long ) data;
    timer->function = TimeoutTimerCallback;
    timer->expires = ( jiffies +  timeout * HZ / 1000);

    add_timer ( timer );
}

//--------------------------------------------------------------------

void CancelTimer ( struct timer_list *timer )
{
    del_timer( timer );
}

//--------------------------------------------------------------------

int WaitCmdReady(struct pex_device *brd, u32 AdmNumber, u32 StatusAddress)
{
    u32 cmd_rdy;

    atomic_set(&brd->m_IsTimeout, 0);

    SetRelativeTimer(&brd->m_TimeoutTimer, 1000, (void*)brd); // wait 1 sec

    do {
        cmd_rdy = ReadAmbReg(brd, AdmNumber, StatusAddress);
        cmd_rdy &= AMB_statCMDRDY; //HOST_statCMDRDY;
    } while(!atomic_read(&brd->m_IsTimeout) && !cmd_rdy);

    CancelTimer(&brd->m_TimeoutTimer);

    if (atomic_read(&brd->m_IsTimeout))
        return -1;

    return 0;
}

//--------------------------------------------------------------------

int WriteRegData(struct pex_device *brd, u32 AdmNumber, u32 TetrNumber, u32 RegNumber, u32 Value)
{
    int Status = 0;
    u32 Address = TetrNumber * TETRAD_SIZE;
    u32 CmdAddress = Address + TRDadr_CMD_ADR * REG_SIZE;
    u32 DataAddress = Address + TRDadr_CMD_DATA * REG_SIZE;
    u32 StatusAddress = Address + TRDadr_STATUS * REG_SIZE;

    WriteAmbReg(brd, AdmNumber, CmdAddress, RegNumber);
    Status = WaitCmdReady(brd, AdmNumber, StatusAddress); // wait CMD_RDY
    if(Status != 0) {
        err_msg(err_trace, "%s(): ERROR wait cmd ready.\n", __FUNCTION__);
        return Status;
    }
    WriteAmbReg(brd, AdmNumber, DataAddress, Value);

    return Status;
}

//--------------------------------------------------------------------

void ToPause(int time_out)
{
    msleep(time_out);
}

//--------------------------------------------------------------------

void ToTimeOut(int mctime_out)
{
    udelay ( mctime_out );
}

//--------------------------------------------------------------------

int ReadRegData(struct pex_device *brd, u32 AdmNumber, u32 TetrNumber, u32 RegNumber, u32 *Value)
{
    int Status = 0;
    u32 Address = TetrNumber * TETRAD_SIZE;
    u32 CmdAddress = Address + TRDadr_CMD_ADR * REG_SIZE;
    u32 StatusAddress = Address + TRDadr_STATUS * REG_SIZE;
    u32 DataAddress = Address + TRDadr_CMD_DATA * REG_SIZE;

    WriteAmbReg(brd, AdmNumber, CmdAddress, RegNumber);
    Status = WaitCmdReady(brd, AdmNumber, StatusAddress); // wait CMD_RDY
    if(Status != 0) {
        err_msg(err_trace,"%s(): ERROR wait cmd ready.\n", __FUNCTION__);
        return Status;
    }

    *Value = ReadAmbReg(brd, AdmNumber, DataAddress);

    dbg_msg(dbg_trace, "%s(): Adm = %d, Tetr = %d, Reg = %d, Val = %x\n",
            __FUNCTION__, AdmNumber, TetrNumber, RegNumber, (int)*Value);

    return Status;
}

//--------------------------------------------------------------------

int SetDmaMode(struct pex_device *brd, u32 NumberOfChannel, u32 AdmNumber, u32 TetrNumber)
{
    int Status = -EINVAL;
    MAIN_SELX sel_reg = {0};
    Status = ReadRegData(brd, AdmNumber, 0, 16 + NumberOfChannel, &sel_reg.AsWhole);
    sel_reg.ByBits.DmaTetr = TetrNumber;
    sel_reg.ByBits.DrqEnbl = 1;
    Status = WriteRegData(brd, AdmNumber, 0, 16 + NumberOfChannel, sel_reg.AsWhole);
    //err_msg(err_trace,"%s(): MAIN_SELX = 0x%X\n", __FUNCTION__, sel_reg.AsWhole);
    return Status;
}

//--------------------------------------------------------------------

int SetDrqFlag(struct pex_device *brd, u32 AdmNumber, u32 TetrNumber, u32 DrqFlag)
{
    int Status = 0;
    u32 Value = 0;
    Status = ReadRegData(brd, AdmNumber, TetrNumber, 0, &Value);
    if(Status != 0) return Status;
    Value |= (DrqFlag << 12);
    Status = WriteRegData(brd, AdmNumber, TetrNumber, 0, Value);
    return Status;
}

//--------------------------------------------------------------------

int DmaEnable(struct pex_device *brd, u32 AdmNumber, u32 TetrNumber)
{
    int Status = 0;
    //u32 Value = 0;
    //Status = ReadRegData(brd, AdmNumber, TetrNumber, 0, &Value);
    //if(Status != 0) return Status;
    //Value |= 0x8; // DRQ enable
    //Status = WriteRegData(brd, AdmNumber, TetrNumber, 0, Value);
    //err_msg(err_trace, "%s: MODE0 = 0x%X.\n", __FUNCTION__, Value);
    return Status;
}

//--------------------------------------------------------------------

int DmaDisable(struct pex_device *brd, u32 AdmNumber, u32 TetrNumber)
{
    int Status = 0;
    //u32 Value = 0;
    //Status = ReadRegData(brd, AdmNumber, TetrNumber, 0, &Value);
    //if(Status != 0) return Status;
    //Value &= 0xfff7; // DRQ disable
    //Status = WriteRegData(brd, AdmNumber, TetrNumber, 0, Value);
    return Status;
}

//--------------------------------------------------------------------

int ResetFifo(struct pex_device *brd, u32 NumberOfChannel)
{
    int Status = 0;
    u32 FifoAddr = brd->m_FifoAddr[NumberOfChannel];

    if(brd->m_BlockFifoId[NumberOfChannel] == PE_EXT_FIFO_ID)
    {
        DMA_CTRL_EXT CtrlExt;
        CtrlExt.AsWhole = 0;//ReadOperationWordReg(PEFIFOadr_DMA_CTRL + FifoAddr);
        WriteOperationWordReg(brd,PEFIFOadr_DMA_CTRL + FifoAddr, CtrlExt.AsWhole);
        ToPause(1);
        dbg_msg(dbg_trace, "%s(): channel = %d, DMA_CTRL_EXT = 0x%X.\n", __FUNCTION__, NumberOfChannel, CtrlExt.AsWhole);
        CtrlExt.ByBits.ResetFIFO = 1;
        WriteOperationWordReg(brd,PEFIFOadr_DMA_CTRL + FifoAddr, CtrlExt.AsWhole);
        ToPause(1);
        dbg_msg(dbg_trace, "%s(): channel = %d, DMA_CTRL_EXT = 0x%X.\n", __FUNCTION__, NumberOfChannel, CtrlExt.AsWhole);
        CtrlExt.ByBits.ResetFIFO = 0;
        WriteOperationWordReg(brd,PEFIFOadr_DMA_CTRL + FifoAddr, CtrlExt.AsWhole);
        //ToPause(200);
        ToPause(10);
        dbg_msg(dbg_trace, "%s(): channel = %d, DMA_CTRL_EXT = 0x%X.\n", __FUNCTION__, NumberOfChannel, CtrlExt.AsWhole);
    }
    return Status;
}

//--------------------------------------------------------------------

int Done(struct pex_device *brd, u32 NumberOfChannel)
{
    DMA_CTRL_EXT CtrlExt;
    int Status = 0;
    u32 FifoAddr = brd->m_FifoAddr[NumberOfChannel];
    CtrlExt.AsWhole = ReadOperationWordReg(brd, PEFIFOadr_DMA_CTRL + FifoAddr);
    CtrlExt.ByBits.Pause = 0;

    //printk("<0>%s(): CtrlExt.AsWhole = 0x%x\n", __FUNCTION__, CtrlExt.AsWhole);

    WriteOperationWordReg(brd, PEFIFOadr_DMA_CTRL + FifoAddr, CtrlExt.AsWhole);

    return Status;
}

//--------------------------------------------------------------------
int HwStartDmaTransfer(struct pex_device *brd, u32 NumberOfChannel)
{
    int Status = 0;
    DMA_CTRL DmaCtrl;
    u64 SGTableAddress;
    u32 LocalAddress, DmaDirection;
    u32 adm_num, tetr_num;
    u32 FifoAddr = brd->m_FifoAddr[NumberOfChannel];

    dbg_msg(dbg_trace, "%s(): channel = %d, FifoAddr = 0x%04X.\n",__FUNCTION__,  NumberOfChannel, FifoAddr);

    DmaCtrl.AsWhole = 0;
    WriteOperationWordReg(brd, PEFIFOadr_DMA_CTRL + FifoAddr, DmaCtrl.AsWhole);
    if(brd->m_BlockFifoId[NumberOfChannel] == PE_EXT_FIFO_ID)
    {
        DMA_MODE_EXT ModeExt;
        ModeExt.AsWhole = 0;
        WriteOperationWordReg(brd, PEFIFOadr_FIFO_CTRL + FifoAddr, ModeExt.AsWhole);
        WriteOperationWordReg(brd, PEFIFOadr_FLAG_CLR + FifoAddr, 0x10);
    }
    GetSGStartParams(brd->m_DmaChannel[NumberOfChannel], &SGTableAddress, &LocalAddress, &DmaDirection); // SG

    WriteOperationReg(brd, PEFIFOadr_PCI_ADDRL + FifoAddr, SGTableAddress); // SG
    WriteOperationReg(brd, PEFIFOadr_PCI_ADDRH + FifoAddr, 0);

    WriteOperationReg(brd, PEFIFOadr_PCI_SIZE + FifoAddr, 0); // SG
    dbg_msg(dbg_trace, "%s(): SG Table Address = 0x%llX, Local Address = 0x%X.\n", __FUNCTION__, SGTableAddress, LocalAddress);

    WriteOperationReg(brd, PEFIFOadr_LOCAL_ADR + FifoAddr, LocalAddress);

    brd->m_DmaChanEnbl[NumberOfChannel] = 1;
    brd->m_DmaIrqEnbl = 1;

    if(brd->m_BlockFifoId[NumberOfChannel] == PE_EXT_FIFO_ID)
    {
        DMA_MODE_EXT ModeExt;
        DMA_CTRL_EXT CtrlExt;

        ModeExt.AsWhole = ReadOperationWordReg(brd, PEFIFOadr_FIFO_CTRL + FifoAddr);
        ModeExt.ByBits.SGModeEnbl = 1;
        ModeExt.ByBits.DemandMode = 1;
        //ModeExt.ByBits.DemandMode = 0;
        ModeExt.ByBits.IntEnbl = 1;
        ModeExt.ByBits.Dir = DmaDirection;
        WriteOperationWordReg(brd, PEFIFOadr_FIFO_CTRL + FifoAddr, ModeExt.AsWhole);
        dbg_msg(dbg_trace, "%s(): channel = %d, DMA_MODE_EXT = 0x%X.\n", __FUNCTION__, NumberOfChannel, ModeExt.AsWhole);

        CtrlExt.AsWhole = 0;
        CtrlExt.ByBits.Start = 1;
        WriteOperationWordReg(brd, PEFIFOadr_DMA_CTRL + FifoAddr, CtrlExt.AsWhole);
        dbg_msg(dbg_trace, "%s(): channel = %d, DMA_CTRL_EXT = 0x%04X.\n", __FUNCTION__, NumberOfChannel, CtrlExt.AsWhole);
    }

    adm_num = GetAdmNum(brd->m_DmaChannel[NumberOfChannel]);
    tetr_num = GetTetrNum(brd->m_DmaChannel[NumberOfChannel]);
    //Status = DmaEnable(brd, adm_num, tetr_num);

    return Status;
}

//--------------------------------------------------------------------

int HwCompleteDmaTransfer(struct pex_device *brd, u32 NumberOfChannel)
{
    int Status = 0;
    u32 FifoAddr = brd->m_FifoAddr[NumberOfChannel];
    int enbl = 0;
    int i = 0;
    u32 tetr_num;

    if(brd->m_BlockFifoId[NumberOfChannel] == PE_EXT_FIFO_ID)
    {
        DMA_CTRL_EXT CtrlExt;
        DMA_MODE_EXT ModeExt;

        CtrlExt.AsWhole = 0;
        WriteOperationWordReg(brd, PEFIFOadr_DMA_CTRL + FifoAddr, CtrlExt.AsWhole);
        dbg_msg(dbg_trace, "%s(): DMA_CTRL_EXT = 0x%04X.\n", __FUNCTION__, CtrlExt.AsWhole);

        ModeExt.AsWhole = 0;
        WriteOperationWordReg(brd, PEFIFOadr_FIFO_CTRL + FifoAddr, ModeExt.AsWhole);
        dbg_msg(dbg_trace, "%s(): channel = %d, DMA_MODE_EXT = 0x%X.\n", __FUNCTION__, NumberOfChannel, ModeExt.AsWhole);
    }

    brd->m_DmaChanEnbl[NumberOfChannel] = 0;
    for(i = 0; i < MAX_NUMBER_OF_DMACHANNELS; i++)
        if(brd->m_DmaChanEnbl[i])
            enbl = 1;
    brd->m_DmaIrqEnbl = enbl;

    tetr_num = GetTetrNum(brd->m_DmaChannel[NumberOfChannel]);
    //Status = DmaDisable(brd, 0, tetr_num);
    CompleteDmaTransfer(brd->m_DmaChannel[NumberOfChannel]);

    return Status;
}

//--------------------------------------------------------------------
#if 0
static irqreturn_t pex_device_isr( int irq, void *pContext )
{
    FIFO_STATUS FifoStatus;  //

    struct pex_device* pDevice = (struct pex_device*)pContext;            // our device

    if(!pDevice->m_DmaIrqEnbl && !pDevice->m_FlgIrqEnbl)
        return IRQ_NONE;	// we did not interrupt
    if(pDevice->m_FlgIrqEnbl)
    {  // прерывание от флагов состояния
        /*
            u32 status = ReadOperationWordReg(pDevice, PEMAINadr_BRD_STATUS);
            err_msg(err_trace, "%s(): BRD_STATUS = 0x%X.\n", __FUNCTION__, status);
            if(status & 0x4000)
            {
                    for(int i = 0; i < NUM_TETR_IRQ; i++)
                            if(pDevice->m_TetrIrq[i] != 0)
                            {
                                    u32 status = ReadAmbMainReg(pDevice, pDevice->m_TetrIrq[i].Address);
                                    KdPrint(("CWambpex::WambpexIsr: TetrIrq = %d, Address = 0x%X, IrqInv = 0x%X, IrqMask = 0x%X, Status = 0x%X.\n",
                                                            i, pDevice->m_TetrIrq[i].Address, pDevice->m_TetrIrq[i].IrqInv, pDevice->m_TetrIrq[i].IrqMask, status));
                                    status ^= pDevice->m_TetrIrq[i].IrqInv;
                                    status &= pDevice->m_TetrIrq[i].IrqMask;
                                    KdPrint(("CWambpex::WambpexIsr: TetrIrq = %d, Address = 0x%X, IrqInv = 0x%X, IrqMask = 0x%X, Status = 0x%X.\n",
                                                            i, pDevice->m_TetrIrq[i].Address, pDevice->m_TetrIrq[i].IrqInv, pDevice->m_TetrIrq[i].IrqMask, status));
                                    if(status)
                                    {
                                            KeInsertQueueDpc(&pDevice->m_TetrIrq[i].Dpc, NULL, NULL);
                                            KdPrint(("CWambpex::WambpexIsr - Tetrad IRQ address = %d\n", pDevice->m_TetrIrq[i].Address));
                                            // сброс статусного бита, вызвавшего прерывание
                                            //pDevice->WriteAmbMainReg(pDevice->m_TetrIrq[i].Address + 0x200);
                                            ULONG CmdAddress = pDevice->m_TetrIrq[i].Address + TRDadr_CMD_ADR * REG_SIZE;
                                            pDevice->WriteAmbMainReg(CmdAddress, 0);
                                            ULONG DataAddress = pDevice->m_TetrIrq[i].Address + TRDadr_CMD_DATA * REG_SIZE;
                                            ULONG Mode0Value = pDevice->ReadAmbMainReg(DataAddress);
                                            Mode0Value &= 0xFFFB;
                                            //pDevice->WriteAmbMainReg(CmdAddress, 0);
                                            pDevice->WriteAmbMainReg(DataAddress, Mode0Value);
                                            break;
                                    }
                            }
                return IRQ_HANDLED;
            }
            else // вообще не наше прерывание !!!
                    return IRQ_NONE;	// we did not interrupt
            */
    }

    if(pDevice->m_DmaIrqEnbl)
    {	// прерывание от каналов ПДП
        long NumberOfChannel = -1;
        u32 FifoAddr;
        long iChan = pDevice->m_primChan;
        for(LONG i = 0; i < MAX_NUMBER_OF_DMACHANNELS; i++)
        {
            if(pDevice->m_DmaChanMask & (1 << iChan))
            {
                FifoAddr = pDevice->m_FifoAddr[iChan];
                FifoStatus.AsWhole = ReadOperationWordReg(pDevice, PEFIFOadr_FIFO_STATUS + FifoAddr);
                if(FifoStatus.ByBits.IntRql)
                {
                    err_msg(err_trace, "%s(): - Channel = %d, Fifo Status = 0x%X\n", __FUNCTION__, iChan, FifoStatus.AsWhole);
                    NumberOfChannel = iChan;
                    pDevice->m_primChan = ((pDevice->m_primChan+1) >= MAX_NUMBER_OF_DMACHANNELS) ? 0 : pDevice->m_primChan+1;
                    break;
                }
            }
            iChan = ((iChan+1) >= MAX_NUMBER_OF_DMACHANNELS) ? 0 : iChan+1;
        }

        if(NumberOfChannel != -1)
        {
            u32 flag = NextDmaTransfer(pDevice->m_DmaChannel[NumberOfChannel]);

            if(!flag)
            {
                DMA_CTRL_EXT CtrlExt;
                CtrlExt.AsWhole = 0;
                CtrlExt.ByBits.Pause = 1;
                CtrlExt.ByBits.Start = 1;
                WriteOperationWordReg(pDevice, PEFIFOadr_DMA_CTRL + FifoAddr, CtrlExt.AsWhole);
                err_msg(err_trace, "%s(): - Pause\n", __FUNCTION__);
            }

            err_msg(err_trace, "%s(): - Flag Clear\n", __FUNCTION__);
            WriteOperationWordReg(pDevice, PEFIFOadr_FLAG_CLR + FifoAddr, 0x10);
            WriteOperationWordReg(pDevice, PEFIFOadr_FLAG_CLR + FifoAddr, 0x00);
            err_msg(err_trace, "%s(): - Complete\n", __FUNCTION__);

            return IRQ_HANDLED;
        }
    }
    return IRQ_NONE;	// we did not interrupt
}
#endif
