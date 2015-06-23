/*
 ****************** File ctrlstrm.h *************************
 *
 *  Definitions of user application interface
 *	structures and constants
 *	for BRD_ctrl : STREAM section
 *
 * (C) Instrumental Systems 
 *
 * Created: by Ekkore Feb, 2003
 * Modified:
 * 19.09.2005 - added ATTACH/DETACH, waiting & special command (Ekkore & Dorokhin A.)
 *
 ************************************************************
*/

#ifndef _CTRL_STREAM_H
#define _CTRL_STREAM_H

//
// Stub Structure
//
typedef struct
{
    s32		lastBlock;				// Number of Block which was filled last Time
    u32		totalCounter;			// Total Counter of all filled Block
    u32		offset;					// First Unfilled Byte
    u32		state;					// CBUF local state
} BRDstrm_Stub, *PBRDstrm_Stub, BRDctrl_StreamStub, *PBRDctrl_StreamStub;

//
// For BRDctrl_STREAM_CBUF_ALLOC
// For BRDctrl_STREAM_CBUF_REALLOC
//
typedef struct  
{
    u32				dir;		// IN, Stream Direction (1-to Host, 2-from Host)
    u32				isCont;		// IN, Allocation Method: 0-FileMapping, 1-System Pool (Ring 0)
    u32				blkNum;		// IN, Number of Blocks
    u32				blkSize;	// IN, Size of Blocks (bytes)
    void**			ppBlk;		// OUT,Block Pointers
    BRDstrm_Stub*               pStub;		// OUT,Stub Pointer
} BRDctrl_StreamCBufAlloc,   *PBRDctrl_StreamCBufAlloc,
BRDctrl_StreamCBufRealloc, *PBRDctrl_StreamCBufRealloc;

//
// For BRDctrl_STREAM_CBUF_START
//
typedef struct  
{
    u32		isCycle;			// IN,  Cycle Mode (1-on, 0-off)
} BRDctrl_StreamCBufStart, *PBRDctrl_StreamCBufStart;

//
// For BRDctrl_STREAM_CBUF_STOP
//
typedef struct  
{
    u32		dummy;				// Not used
} BRDctrl_StreamCBufStop, *PBRDctrl_StreamCBufStop;

//
// For BRDctrl_STREAM_CBUF_STATE
//
typedef struct  
{
    s32		blkNum;			// OUT, Last Filled Block Number
    u32		blkNumTotal;	// OUT, Total Filled Block Counter
    u32		offset;			// OUT, First Unfilled Byte
    u32		state;			// OUT, State of CBuf (1-start, 2-stop, 3-destroied)
    u32		timeout;		// IN,  Timeout (msec) (0xFFFFFFFFL - INFINITE)
} BRDctrl_StreamCBufState, *PBRDctrl_StreamCBufState;

//
// For BRDctrl_STREAM_CBUF_ATTACH
//
typedef struct  
{
    u32				dir;		// OUT, Stream Direction (1-to Host, 2-from Host)
    u32				isCont;		//      Reserved
    u32				blkNum;		// I/O, Size of ppBlk[], Number of Blocks
    u32				blkSize;	// OUT, Size of Blocks (bytes)
    void**			ppBlk;		// OUT, Block Pointers
    BRDstrm_Stub*	pStub;		// OUT, Stub Pointer
} BRDctrl_StreamCBufAttach, *PBRDctrl_StreamCBufAttach;

//
// For BRDctrl_STREAM_CBUF_WAITBLOCK
//
typedef struct  
{
    u32		timeout;		// IN,  Timeout (msec) (0xFFFFFFFFL - INFINITE)
} BRDctrl_StreamCBufWaitBlock, *PBRDctrl_StreamCBufWaitBlock;


//
// For BRDctrl_STREAM_CBUF_WAITBUF
//
typedef struct  
{
    u32		timeout;		// IN,  Timeout (msec) (0xFFFFFFFFL - INFINITE)
} BRDctrl_StreamCBufWaitBuf, *PBRDctrl_StreamCBufWaitBuf;

//
// For BRDctrl_STREAM_SETDIR, BRDctrl_STREAM_GETDIR
//
typedef struct  
{
    u32		dir;			// IN, Stream Direction (1-to Host, 2-from Host)
} BRDctrl_StreamSetDir, *PBRDctrl_StreamSetDir, 
BRDctrl_StreamGetDir, *PBRDctrl_StreamGetDir;

//
// For BRDctrl_STREAM_SETSRC
//
typedef struct  
{
    u32		src;			// IN
} BRDctrl_StreamSetSrc, *PBRDctrl_StreamSetSrc;

//
// For BRDctrl_STREAM_SETDRQ
//
typedef struct  
{
    u32		drq;			// IN, Flag for DMA request
} BRDctrl_StreamSetDrq, *PBRDctrl_StreamSetDrq;

//
// For BRDctrl_STREAM_RESETFIFO
//
typedef struct  
{
    u32		dummy;			// Not used
} BRDctrl_StreamResetFifo, *PBRDctrl_StreamResetFifo;

//
// For BRDctrl_STREAM_CBUF_ADJUST
//
typedef struct  
{
    s32		isAdjust;			// IN, Select mode: 1-adjusted, 0-unadjusted
} BRDctrl_StreamCBufAdjust, *PBRDctrl_StreamCBufAdjust;

//
// For BRDctrl_STREAM_CBUF_DONE
//
typedef struct  
{
    s32		blkNo;			// IN,  Number of processed Block
} BRDctrl_StreamCBufDone, *PBRDctrl_StreamCBufDone;

//
// For BRDctrl_STREAM_VERSION
//
typedef struct  
{
    s32		major;			// OUT,  Major Number of Version
    s32		minor;			// OUT,  Minor Number of Version
} BRDctrl_StreamVersion, *PBRDctrl_StreamVersion;

//=********************************************************
//
// Constants
//
//=********************************************************

enum
{
    BRDstrm_STAT_RUN = 1,
    BRDstrm_STAT_STOP = 2,
    BRDstrm_STAT_DESTROY = 3,
    BRDstrm_STAT_BREAK = 4
                     };

//
// Constants: Direction of CBUF
//
/*
enum
{
 BRDstrm_DIR_IN = 0x1,				// To HOST
 BRDstrm_DIR_OUT = 0x2,				// From HOST
 BRDstrm_DIR_INOUT = 0x3				// Both Directions
};
*/
//
// Constants: flag for BRDctrl_STREAM_SETDRQ
//

enum
{
    BRDstrm_DRQ_ALMOST	= 0x0,			// Almost empty = 1 for input FIFO, Almost full = 1 for output FIFO
    BRDstrm_DRQ_READY	= 0x1,			// Ready = 1
    BRDstrm_DRQ_HALF	= 0x2			// Half full = 0 for input FIFO, Half full = 1 for output FIFO
                      };

#endif // _CTRL_STREAM_H
