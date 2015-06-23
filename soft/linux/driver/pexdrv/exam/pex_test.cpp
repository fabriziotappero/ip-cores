
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <errno.h>
#include <limits.h>
#include <stdarg.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <fcntl.h>

#include "utypes_linux.h"
#include "brd_info.h"
#include "pexioctl.h"
#include "ambpexregs.h"

#define INSYS_VENDOR_ID         0x4953
#define AMBPEX8_DEVID		0x5503
#define ADP201X1AMB_DEVID	0x5504
#define ADP201X1DSP_DEVID	0x5505
#define AMBPEX5_DEVID		0x5507

//-----------------------------------------------------------------------------

void board_info(const struct board_info *bi);
void pld_info( uint32_t *base );
int board_init(uint32_t *base);
void ToPause(int ms);

//-----------------------------------------------------------------------------
uint32_t *bar0 = NULL;
uint32_t *bar1 = NULL;
//-----------------------------------------------------------------------------

int main(int argc, char *argv[])
{
    int error = 0;
    struct board_info bi;
    struct memory_descriptor md;
    struct memory_block *mb = NULL;
    int fd = -1;
    int N = 2;

    if(argc == 1) {
        fprintf(stderr, "usage: %s <device name>\n", argv[0]);
        goto do_out;
    }

    fprintf(stderr, "Start testing device %s\n", argv[1]);

    fd = open(argv[1], S_IROTH | S_IWOTH );
    if(fd < 0) {
        fprintf(stderr, "%s\n", strerror(errno));
        goto do_out;
    }

    error = ioctl(fd, IOCTL_PEX_BOARD_INFO, &bi);
    if(error < 0) {
        fprintf(stderr, "%s\n", strerror(errno));
        goto do_close;
    }

    board_info(&bi);

    mb = (struct memory_block*)malloc(N*sizeof(struct memory_block));
    if(!mb) {
        fprintf(stderr, "%s\n", strerror(errno));
        goto do_close;
    }

    memset(mb, 0, N*sizeof(struct memory_block));

    for(int i=0; i<N; i++) {
        mb[i].size = 0x100000;
    }

    md.blocks = mb;
    md.total_blocks = N;

    error = ioctl(fd, IOCTL_PEX_MEM_ALLOC, &md);
    if(error < 0) {
        fprintf(stderr, "%s\n", strerror(errno));
        goto do_free_mem;
    }

    for(int i=0; i<N; i++) {
        fprintf(stderr, "%d: PA = 0x%zx\n", i, mb[i].phys);
    }

    fprintf(stderr, "Press Enter to free memory...\n");
    getchar();

    error = ioctl(fd, IOCTL_PEX_MEM_FREE, &md);
    if(error < 0) {
        fprintf(stderr, "%s\n", strerror(errno));
        goto do_free_mem;
    }

    goto do_free_mem;

    bar0 = (uint32_t*)mmap(NULL, bi.Size[0], PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t)bi.PhysAddress[0]);
    if( bar0 == MAP_FAILED ) {
        fprintf(stderr, "%s\n", strerror(errno));
        error = -EINVAL;
        goto do_close;
    }

    bar1 = (uint32_t*)mmap(NULL, bi.Size[1], PROT_READ|PROT_WRITE, MAP_SHARED, fd, (off_t)bi.PhysAddress[1]);
    if( bar1== MAP_FAILED ) {
        fprintf(stderr, "%s\n", strerror(errno));
        error = -EINVAL;
        goto do_unmap_bar0;
    }

    fprintf(stderr, "Map BAR0 0x%zx -> %p\n", bi.PhysAddress[0], bar0);
    fprintf(stderr, "Map BAR1 0x%zx -> %p\n", bi.PhysAddress[1], bar1);

    for(int i=0; i<16; i++) {
        fprintf(stderr, "%d: 0x%x\n", i,  bar0[i]);
    }

    board_init(bar0);

    //pld_info(bar1);

    error = 0;

    //do_unmap_bar1:
    munmap(bar1, bi.Size[1]);

    do_unmap_bar0:
    munmap(bar0, bi.Size[0]);

    do_free_mem:
    free(mb);

    do_close:
    close(fd);

    do_out:
    return error;
}

//-----------------------------------------------------------------------------

void board_info(const struct board_info *bi)
{
    if(!bi) return;

    fprintf(stderr, "VENDOR ID: 0x%X\n", bi->vendor_id);
    fprintf(stderr, "DEVICE ID: 0x%X\n", bi->device_id);
    fprintf(stderr, "BAR0: 0x%zX\n", bi->PhysAddress[0]);
    fprintf(stderr, "SIZE: 0x%zX\n", bi->Size[0]);
    fprintf(stderr, "BAR1 0x%zX\n", bi->PhysAddress[1]);
    fprintf(stderr, "SIZE: 0x%zX\n", bi->Size[1]);
    fprintf(stderr, "IRQ: 0x%zX\n", bi->InterruptVector);
}

//-----------------------------------------------------------------------------

void memory_info(const struct memory_descriptor *md)
{
    if(!md) return;
    if(!md->blocks) return;

    for(unsigned i=0; i<md->total_blocks; i++) {

        struct memory_block *b = &md->blocks[i];
        fprintf(stderr, "%d - kernel virtual: %p, kernel physical: %p \n", i, b->virt, (void*)b->phys);
    }
}

//-----------------------------------------------------------------------------

uint16_t ReadOperationWordReg(uint32_t *base, uint32_t port)
{
    return *((uint16_t*)((uint8_t*)base + port));
}

//-----------------------------------------------------------------------------

void WriteOperationWordReg(uint32_t *base, uint32_t port, uint16_t value)
{
    *((uint16_t*)((uint8_t*)base + port)) = value;
}

//-----------------------------------------------------------------------------

uint32_t ReadAmbReg(uint32_t *base, uint32_t AdmNumber, uint32_t RelativePort)
{
    uint8_t* pBaseAddress = (uint8_t*)base + AdmNumber * ADM_SIZE;
    return *((uint32_t*)(pBaseAddress + RelativePort));
}

//-----------------------------------------------------------------------------

uint32_t ReadAmbMainReg(uint32_t *base, uint32_t RelativePort)
{
    return *((uint32_t*)((uint8_t*)base + RelativePort));
}

//-----------------------------------------------------------------------------

void WriteAmbReg(uint32_t *base, uint32_t AdmNumber, uint32_t RelativePort, uint32_t value)
{
    uint8_t* pBaseAddress = (uint8_t*)base + AdmNumber * ADM_SIZE;
    *((uint32_t*)(pBaseAddress + RelativePort)) = value;
}

//-----------------------------------------------------------------------------

void WriteAmbMainReg(uint32_t *base, uint32_t RelativePort, uint32_t value)
{
    *((uint32_t*)((uint8_t*)base + RelativePort)) = value;
}

//-----------------------------------------------------------------------------

int WaitCmdReady(uint32_t *base, uint32_t AdmNumber, uint32_t StatusAddress)
{
    int pass_count = 0;
    uint32_t cmd_rdy;

    //fprintf(stderr,"%s()\n", __FUNCTION__);

    do {

        cmd_rdy = ReadAmbReg(base, AdmNumber, StatusAddress);
        cmd_rdy &= AMB_statCMDRDY; //HOST_statCMDRDY;

        if(pass_count < 10) {

            pass_count++;
            ToPause(1);

        } else {
            return -1;
        }

    } while(!cmd_rdy);

    return 0;
}

//-----------------------------------------------------------------------------

int WriteRegData(uint32_t *base, uint32_t AdmNumber, uint32_t TetrNumber, uint32_t RegNumber, uint32_t value)
{
    int Status = 0;
    uint32_t Address = TetrNumber * TETRAD_SIZE;
    uint32_t CmdAddress = Address + TRDadr_CMD_ADR * REG_SIZE;
    uint32_t DataAddress = Address + TRDadr_CMD_DATA * REG_SIZE;
    uint32_t StatusAddress = Address + TRDadr_STATUS * REG_SIZE;

    WriteAmbReg(base, AdmNumber, CmdAddress, RegNumber);

    Status = WaitCmdReady(base, AdmNumber, StatusAddress); // wait CMD_RDY
    if(Status != 0) {
        fprintf(stderr,"%s(): ERROR wait cmd ready.\n", __FUNCTION__);
        return Status;
    }

    WriteAmbReg(base, AdmNumber, DataAddress, value);

    //fprintf(stderr,"%s(): Adm = %d, Tetr = %d, Reg = %d\n", __FUNCTION__,
    //		AdmNumber, TetrNumber, RegNumber);

    return Status;
}

//-----------------------------------------------------------------------------

int ReadRegData(uint32_t *base, uint32_t AdmNumber, uint32_t TetrNumber, uint32_t RegNumber, uint32_t *Value)
{
    int Status = 0;
    uint32_t Address = TetrNumber * TETRAD_SIZE;
    uint32_t CmdAddress = Address + TRDadr_CMD_ADR * REG_SIZE;
    uint32_t StatusAddress = Address + TRDadr_STATUS * REG_SIZE;
    uint32_t DataAddress = Address + TRDadr_CMD_DATA * REG_SIZE;

    WriteAmbReg(base, AdmNumber, CmdAddress, RegNumber);

    Status = WaitCmdReady(base, AdmNumber, StatusAddress); // wait CMD_RDY
    if(Status != 0) {
        fprintf(stderr,"%s(): ERROR wait cmd ready.\n", __FUNCTION__);
        return Status;
    }

    *Value = ReadAmbReg(base, AdmNumber, DataAddress);

    //fprintf(stderr,"%s(): Adm = %d, Tetr = %d, Reg = %d, Val = %x\n", __FUNCTION__,
    //		AdmNumber, TetrNumber, RegNumber, (int)*Value);

    return Status;
}

//-----------------------------------------------------------------------------

uint32_t RegPeekInd(uint32_t *base, uint32_t trdNo, uint32_t rgnum)
{
    uint32_t Value = 0;

    ReadRegData(base, 0, trdNo, rgnum, &Value);

    return Value;
}

//-----------------------------------------------------------------------------

int RegPokeDir( uint32_t *base, uint32_t TetrNumber, uint32_t RegNumber, uint32_t Value )
{
    uint32_t Address;

    Address = TetrNumber * TETRAD_SIZE;
    RegNumber = RegNumber & 0x3;

    Address += RegNumber * REG_SIZE;

    WriteAmbReg(base, 0, Address, Value);

    return 0;
}

//-----------------------------------------------------------------------------

void ToPause(int ms)
{
    struct timeval tv = {0, 0};
    tv.tv_usec = 1000*ms;

    select(0,NULL,NULL,NULL,&tv);
}

//-----------------------------------------------------------------------------

int board_init(uint32_t *base)
{
    u16 temp = 0;
    u16 blockId = 0;
    u16 blockVer = 0;
    u16 deviceID = 0;
    u16 deviceRev = 0;
    int i = 0;

    blockId = ReadOperationWordReg(base, PEMAINadr_BLOCK_ID);
    blockVer = ReadOperationWordReg(base, PEMAINadr_BLOCK_VER);

    fprintf(stderr,"%s(): BlockID = 0x%X, BlockVER = 0x%X.\n", __FUNCTION__, blockId, blockVer);

    deviceID = ReadOperationWordReg(base, PEMAINadr_DEVICE_ID);
    deviceRev = ReadOperationWordReg(base, PEMAINadr_DEVICE_REV);

    fprintf(stderr,"%s(): DeviceID = 0x%X, DeviceRev = 0x%X.\n", __FUNCTION__, deviceID, deviceRev);

    if((AMBPEX8_DEVID != deviceID) &&
       (ADP201X1AMB_DEVID != deviceID) &&
       (AMBPEX5_DEVID != deviceID))
        return -ENODEV;

    temp = ReadOperationWordReg(base, PEMAINadr_PLD_VER);
    int m_BlockCnt = ReadOperationWordReg(base, PEMAINadr_BLOCK_CNT);

    fprintf(stderr,"%s(): PldVER = 0x%X.\n", __FUNCTION__, temp);
    fprintf(stderr,"%s(): Block count = %d.\n", __FUNCTION__, m_BlockCnt);

    // определим какие каналы ПДП присутствуют и их характеристики:
    // направление передачи данных, размер FIFO, максимальный размер блока ПДП

    FIFO_ID FifoId;
    int m_DmaFifoSize[4] = {0};
    int m_MaxDmaSize[4] = {0};
    //int m_FifoAddr[4] = {0};
    //int m_BlockFifoId[4] = {0};
    int m_DmaDir[4] = {0};
    int m_DmaChanMask = 0;

    for(int iBlock = 0; iBlock < m_BlockCnt; iBlock++)
    {
        uint32_t FifoAddr = 0;
        u16 block_id = 0;
        FifoAddr = (iBlock + 1) * PE_FIFO_ADDR;
        temp = ReadOperationWordReg(base, PEFIFOadr_BLOCK_ID + FifoAddr);
        block_id = (temp & 0x0FFF);
        if(block_id == PE_FIFO_ID)
        {
            u64 one = 0;
            u64 maxdmasize = 0;
            u16 iChan = ReadOperationWordReg(base, PEFIFOadr_FIFO_NUM + FifoAddr);
            //m_FifoAddr[iChan] = FifoAddr;
            //m_BlockFifoId[iChan] = block_id;
            m_DmaChanMask |= (1 << iChan);
            FifoId.AsWhole = ReadOperationWordReg(base, PEFIFOadr_FIFO_ID + FifoAddr);
            m_DmaFifoSize[iChan] = FifoId.ByBits.Size;
            m_DmaDir[iChan] = FifoId.ByBits.Dir;
            temp = ReadOperationWordReg(base, PEFIFOadr_DMA_SIZE + FifoAddr);

            one = 1;
            maxdmasize = one << temp;
            // если макс. размер ПДП может быть больше или равен 4 Гбайт, то снижаем его до 1 Гбайта
            if(temp >= 32)
                m_MaxDmaSize[iChan] = 0x40000000;
            else
                m_MaxDmaSize[iChan] = (uint32_t)maxdmasize;

            fprintf(stderr,"%s(): Channel(ID) = %d(0x%x), FIFO size = %d Bytes, DMA Dir = %d,\n", __FUNCTION__,
                    iChan, block_id, m_DmaFifoSize[iChan] * 4, m_DmaDir[iChan]);
            fprintf(stderr,"%s(): Max DMA size (hard) = %d MBytes,  Max DMA size (soft) = %d MBytes.\n", __FUNCTION__,
                    (uint32_t)(maxdmasize / 1024 / 1024), m_MaxDmaSize[iChan] / 1024 / 1024);
        }
        if(block_id == PE_EXT_FIFO_ID)
        {
            uint32_t resource_id = 0;
            u16 iChan = ReadOperationWordReg(base, PEFIFOadr_FIFO_NUM + FifoAddr);
            //m_FifoAddr[iChan] = FifoAddr;
            //m_BlockFifoId[iChan] = block_id;
            m_DmaChanMask |= (1 << iChan);
            FifoId.AsWhole = ReadOperationWordReg(base, PEFIFOadr_FIFO_ID + FifoAddr);
            m_DmaFifoSize[iChan] = FifoId.ByBits.Size;
            m_DmaDir[iChan] = FifoId.ByBits.Dir;
            m_MaxDmaSize[iChan] = 0x40000000; // макс. размер ПДП пусть будет 1 Гбайт
            resource_id = ReadOperationWordReg(base, PEFIFOadr_DMA_SIZE + FifoAddr); // RESOURCE
            fprintf(stderr,"%s(): Channel(ID) = %d(0x%x), FIFO size = %d Bytes, DMA Dir = %d, Max DMA size = %d MBytes, resource = 0x%x.\n", __FUNCTION__,
                    iChan, block_id, m_DmaFifoSize[iChan] * 4, m_DmaDir[iChan], m_MaxDmaSize[iChan] / 1024 / 1024, resource_id);
        }
    }

    // подготовим к работе ПЛИС ADM
    fprintf(stderr,"%s(): Prepare ADM PLD.\n", __FUNCTION__);
    WriteOperationWordReg(base,PEMAINadr_BRD_MODE, 0);
    ToPause(100);	// pause ~ 100 msec
    for(i = 0; i < 10; i++)
    {
        WriteOperationWordReg(base, PEMAINadr_BRD_MODE, 1);
        ToPause(100);	// pause ~ 100 msec
        WriteOperationWordReg(base, PEMAINadr_BRD_MODE, 3);
        ToPause(100);	// pause ~ 100 msec
        WriteOperationWordReg(base, PEMAINadr_BRD_MODE, 7);
        ToPause(100);	// pause ~ 100 msec
        temp = ReadOperationWordReg(base, PEMAINadr_BRD_STATUS) & 0x01;
        if(temp)
            break;
    }
    WriteOperationWordReg(base, PEMAINadr_BRD_MODE, 0x0F);
    ToPause(100);	// pause ~ 100 msec

    if(temp)
    {
        uint32_t idx = 0;
        BRD_STATUS brd_status;
        fprintf(stderr,"%s(): ADM PLD is captured.\n", __FUNCTION__);
        brd_status.AsWhole = ReadOperationWordReg(base, PEMAINadr_BRD_STATUS);
        brd_status.ByBits.InFlags &= 0x80; // 1 - ADM PLD in test mode
        if(brd_status.ByBits.InFlags)
        {
            BRD_MODE brd_mode;
            fprintf(stderr,"%s(): ADM PLD in test mode.\n", __FUNCTION__);

            // проверка линий передачи флагов
            brd_mode.AsWhole = ReadOperationWordReg(base, PEMAINadr_BRD_MODE);
            for(idx = 0; idx < 4; idx++)
            {
                brd_mode.ByBits.OutFlags = idx;
                WriteOperationWordReg(base, PEMAINadr_BRD_MODE, brd_mode.AsWhole);
                ToPause(10);
                brd_status.AsWhole = ReadOperationWordReg(base, PEMAINadr_BRD_STATUS);
                brd_status.ByBits.InFlags &= 0x03;
                if(brd_mode.ByBits.OutFlags != brd_status.ByBits.InFlags)
                {
                    temp = 0;
                    fprintf(stderr,"%s(): FLG_IN (%d) NOT equ FLG_OUT (%d).\n", __FUNCTION__,
                            brd_status.ByBits.InFlags, brd_mode.ByBits.OutFlags);
                    break;
                }
            }
            if(temp)
                fprintf(stderr,"%s(): FLG_IN equ FLG_OUT.\n", __FUNCTION__);
        }
        else
            temp = 0;
    }

    if(!temp)
    {
        WriteOperationWordReg(base, PEMAINadr_BRD_MODE, 0);
        ToPause(100);	// pause ~ 100 msec
    }


    // состояние ПЛИС ADM: 0 - не готова
    fprintf(stderr,"%s(): ADM PLD[%d] status = 0x%X.\n", __FUNCTION__, i, temp);

    {
        BRD_MODE brd_mode;
        brd_mode.AsWhole = ReadOperationWordReg(base, PEMAINadr_BRD_MODE);
        brd_mode.ByBits.OutFlags = 0;
        WriteOperationWordReg(base, PEMAINadr_BRD_MODE, brd_mode.AsWhole);
        fprintf(stderr,"%s(): BRD_MODE = 0x%X.\n", __FUNCTION__, brd_mode.AsWhole);
    }

    WriteOperationWordReg(base, PEMAINadr_IRQ_MASK, 0x4000);

    //WriteAmbMainReg(base, 0x0, 0x1);
    //WriteAmbMainReg(base, 0x0, 0x1);

    return 0;
}

//-----------------------------------------------------------------------------

void pld_info( uint32_t *base )
{
        uint32_t d = 0;
        uint32_t d1 = 0;
        uint32_t d2 = 0;
        uint32_t d3 = 0;
        uint32_t d4 = 0;
        uint32_t d5 = 0;
        int ii = 0;

        if(!base) return;

        fprintf(stderr,"Прошивка ПЛИС ADM\n" );

        RegPokeDir( base, 0, 1, 1 );

        d=RegPeekInd( base, 0, 0x108 );
        if( d==0x4953 ) {
            fprintf(stderr, "  SIG= 0x%.4X - Ok	\n", d );
        } else {
            fprintf(stderr, "  SIG= 0x%.4X - Ошибка, ожидается 0x4953	\n", d );
            return;
        }

        d=RegPeekInd( base,  0, 0x109 );  fprintf(stderr, "   Версия интерфейса ADM:  %d.%d\n", d>>8, d&0xFF );
        d=RegPeekInd( base,  0, 0x110 ); d1=RegPeekInd( base,  0, 0x111 );
        fprintf(stderr,  "   Базовый модуль: 0x%.4X  v%d.%d\n", d, d1>>8, d1&0xFF );

        d=RegPeekInd( base,  0, 0x112 ); d1=RegPeekInd( base,  0, 0x113 );
        fprintf(stderr,  "   Субмодуль:      0x%.4X  v%d.%d\n", d, d1>>8, d1&0xFF );

        d=RegPeekInd( base,  0, 0x10B );  fprintf(stderr,  "   Модификация прошивки ПЛИС:  %d \n", d );
        d=RegPeekInd( base,  0, 0x10A );  fprintf(stderr,  "   Версия прошивки ПЛИС:       %d.%d\n", d>>8, d&0xFF );
        d=RegPeekInd( base,  0, 0x114 );  fprintf(stderr,  "   Номер сборки прошивки ПЛИС: 0x%.4X\n", d );

        fprintf(stderr,  "\nИнформация о тетрадах:\n\n" );
        for( ii=0; ii<8; ii++ ) {

            const char *str;

            d=RegPeekInd( base,  ii, 0x100 );
            d1=RegPeekInd( base,  ii, 0x101 );
            d2=RegPeekInd( base,  ii, 0x102 );
            d3=RegPeekInd( base,  ii, 0x103 );
            d4=RegPeekInd( base,  ii, 0x104 );
            d5=RegPeekInd( base,  ii, 0x105 );

            switch( d ) {
            case 1: str="TRD_MAIN      "; break;
            case 2: str="TRD_BASE_DAC  "; break;
            case 3: str="TRD_PIO_STD   "; break;
            case 0:    str=" -            "; break;
            case 0x47: str="SBSRAM_IN     "; break;
            case 0x48: str="SBSRAM_OUT    "; break;
            case 0x12: str="DIO64_OUT     "; break;
            case 0x13: str="DIO64_IN      "; break;
            case 0x14: str="ADM212x200M   "; break;
            case 0x5D: str="ADM212x500M   "; break;
            case 0x41: str="DDS9956       "; break;
            case 0x4F: str="TEST_CTRL     "; break;
            case 0x3F: str="ADM214x200M   "; break;
            case 0x40: str="ADM216x100    "; break;
            case 0x2F: str="ADM28x1G      "; break;
            case 0x2D: str="TRD128_OUT    "; break;
            case 0x4C: str="TRD128_IN     "; break;
            case 0x30: str="ADMDDC5016    "; break;
            case 0x2E: str="ADMFOTR2G     "; break;
            case 0x49: str="ADMFOTR3G     "; break;
            case 0x67: str="DDS9912       "; break;
            case 0x70: str="AMBPEX5_SDRAM "; break;
            case 0x71: str="TRD_MSG       "; break;
            case 0x72: str="TRD_TS201     "; break;
            case 0x73: str="TRD_STREAM_IN "; break;
            case 0x74: str="TRD_STREAM_OUT"; break;


            default: str="UNKNOW        "; break;
            }
            fprintf(stderr,  " %d  0x%.4X %s ", ii, d, str );
            if( d>0 ) {
                fprintf(stderr,  " MOD: %-2d VER: %d.%d ", d1, d2>>8, d2&0xFF );
                if( d3 & 0x10 ) {
                    fprintf(stderr,  "FIFO IN   %dx%d\n", d4, d5 );
                } else if( d3 & 0x20 ) {
                    fprintf(stderr,  "FIFO OUT  %dx%d\n", d4, d5 );
                } else {
                    fprintf(stderr,  "\n" );
                }
            } else {
                fprintf(stderr,  "\n" );
            }

        }
}

//-----------------------------------------------------------------------------
