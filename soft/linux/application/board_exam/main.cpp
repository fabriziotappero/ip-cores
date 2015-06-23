
#ifndef __BOARD_H__
#include "board.h"
#endif

#include <cassert>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <iomanip>
#include <climits>
#include <cstdio>
#include <dlfcn.h>

//-----------------------------------------------------------------------------

using namespace std;

//-----------------------------------------------------------------------------
#define NUM_BLOCK   8
#define BLOCK_SIZE  0x10000
//-----------------------------------------------------------------------------

int main(int argc, char *argv[])
{
    if(argc != 3) {
        std::cerr << "usage: " << argv[0] << " <libname.so> </dev/devname>" << endl;
        return -1;
    }

    char *libname = argv[1];
    char *devname = argv[2];
    int dmaChan = 0;
    void* pBuffers[NUM_BLOCK] = {NULL,NULL,NULL,NULL};
    void *hlib = NULL;
    board_factory factory = NULL;
    board *brd = NULL;
    u32 *buffer = NULL;

    std ::cout << "Loading library: " << libname << endl;

    hlib = dlopen(libname, RTLD_LAZY);
    if(!hlib) {
        fprintf(stderr, "%s\n", dlerror());
        return -1;
    }

    factory = (board_factory)dlsym(hlib, "create_board");
    if(!factory) {
        fprintf(stderr, "%s\n", dlerror());
        dlclose(hlib);
        return -1;
    }

    std ::cout << "Start testing device " << devname << endl;

    brd = factory();
    if(!brd) {
        dlclose(hlib);
        return -1;
    }

    if(brd->brd_open(devname) < 0) {

        delete brd;

        if(hlib) {
            int res = dlclose(hlib);
            if(res < 0) {
                fprintf(stderr, "%s\n", dlerror());
                return -1;
            }
        }

        return -1;
    }

    brd->brd_init();
    brd->brd_pld_info();

    std::cout << "Reset FPGA..." << std::endl;
    brd->brd_reg_poke_ind(0,0,1);
    brd->brd_delay(100);
    brd->brd_reg_poke_ind(0,0,0);
    brd->brd_delay(100);

    std::cout << "Init FPGA..." << std::endl;
    for( int trd=0; trd<8; trd++ ) {
        brd->brd_reg_poke_ind( trd, 0, 1 );
    }
    for( int trd=0; trd<8; trd++ ) {
        for( int ii=1; ii<32; ii++ ) {
            brd->brd_reg_poke_ind( trd, ii, 0 );
        }
    }
    for( int trd=0; trd<8; trd++ ) {
        brd->brd_reg_poke_ind( trd, 0, 0 );
    }

    std ::cout << "Press enter to allocate DMA memory..." << endl;
    getchar();

    int DmaChan = 1;

    // Check BRDSHELL DMA interface
    BRDctrl_StreamCBufAlloc sSCA = {
        1,	//dir
        1,
        NUM_BLOCK,
        BLOCK_SIZE,
        pBuffers,
        NULL,
    };

    brd->dma_alloc(dmaChan, &sSCA);

    brd->dma_set_local_addr(DmaChan, 0x1000);
    brd->dma_stop(DmaChan);
    brd->dma_reset_fifo(DmaChan);
    brd->dma_reset_fifo(DmaChan);

    std ::cout << "Press enter to start DMA channel..." << endl;
    getchar();

    // fill data buffers
    for(int j=0; j<NUM_BLOCK; j++) {
        buffer = (u32*)pBuffers[j];
        for(unsigned i=0; i<32; i++) {
            buffer[i] = 0xAA556677;
        }
    }

    brd->dma_start(dmaChan, 0);

    std ::cout << "Press enter to stop DMA channel..." << endl;
    getchar();


    brd->dma_stop(dmaChan);

    // show data buffers
    for(int j=0; j<NUM_BLOCK; j++) {

        std ::cout << "DMA data buffer " << j << ":" << endl;
        buffer = (u32*)pBuffers[j];
        for(unsigned i=0; i<32; i++) {
            std::cout << hex << buffer[i] << " ";
        }
        std ::cout << endl;
    }
    std::cout << dec << endl;

    std ::cout << "Press enter to free DMA memory..." << endl;
    getchar();

    brd->dma_free_memory(dmaChan);

    brd->brd_close();

    delete brd;

    if(hlib) {
        int res = dlclose(hlib);
        if(res < 0) {
            fprintf(stderr, "%s\n", dlerror());
            return -1;
        }
    }

    return 0;
}
