//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------
#ifndef __OR32_H__
#define __OR32_H__

#include "or32_isa.h"
#include "peripheral.h"

//--------------------------------------------------------------------
// Defines:
//--------------------------------------------------------------------
#define LOG_OR1K        (1 << 0)
#define LOG_INST        (1 << 1)
#define LOG_REGISTERS   (1 << 2)
#define LOG_MEM         (1 << 3)

#define MAX_MEM_REGIONS     4

#define MAX_PERIPHERALS     10

//--------------------------------------------------------------------
// Class
//--------------------------------------------------------------------
class OR32
{
public:
                        OR32(bool delay_slot = true);    
                        OR32(unsigned int baseAddr, unsigned int len, bool delay_slot = true);
    virtual             ~OR32();

    bool                CreateMemory(unsigned int baseAddr, unsigned int len);

    bool                Load(unsigned int startAddr, unsigned char *data, int len);
    bool                WriteMem(TAddress addr, unsigned char *data, int len);
    bool                ReadMem(TAddress addr, unsigned char *data, int len);

    void                Reset(TRegister start_addr = VECTOR_RESET);
    bool                Clock(void);
    bool                Step(void);

    int                 GetFault(void) { return Fault; }
    int                 GetBreak(void) { return Break; }
    TRegister           GetRegister(int r) { return (r < REGISTERS) ? r_gpr[r] : 0; }
    TRegister           GetPC(void) { return !DelaySlotEnabled ? r_pc : r_pc_next; }
    TRegister           GetOpcode(TRegister address);

    void                EnableTrace(unsigned mask)  { Trace = mask; }
    void                EnableOutput(bool en)  { EnablePutc = en; }
    void                EnableMemoryTrace(void);

    void                ResetStats(void);
    void                DumpStats(void);

protected:  
    void                Decode(void);
    void                Execute(void);
    void                WriteBack(void);

protected:

    // Peripheral access
    void PeripheralReset(void) 
    {
        int i;
        for (i=0;i<MAX_PERIPHERALS;i++)
            if (periperhals[i].instance)
                periperhals[i].instance->Reset();
    }

    void PeripheralClock(void)
    {
        int i;
        for (i=0;i<MAX_PERIPHERALS;i++)
            if (periperhals[i].instance)
                periperhals[i].instance->Clock();
    }    
    
    TRegister PeripheralAccess(TAddress addr, TRegister data_in, TRegister wr, TRegister rd)
    {
        int i;
        for (i=0;i<MAX_PERIPHERALS;i++)
            if (periperhals[i].instance)
                if (addr >= periperhals[i].start_address && addr <= periperhals[i].end_address)
                    return periperhals[i].instance->Access(addr, data_in, wr, rd);

        return 0;
    }
    
    bool PeripheralInterrupt(void)
    {
        int i;
        bool interrupt = false;

        for (i=0;i<MAX_PERIPHERALS;i++)
            if (periperhals[i].instance)
                interrupt |= periperhals[i].instance->Interrupt();

        return interrupt;
    }   

public:

    void AttachPeripheral(Peripheral *instance)
    {
        int i;
        for (i=0;i<MAX_PERIPHERALS;i++)
            if (!periperhals[i].instance)
            {
                periperhals[i].instance = instance;
                periperhals[i].start_address = instance->GetStartAddress();
                periperhals[i].end_address = instance->GetStopAddress();

                break;
            }
    }

protected:  
    // Execution monitoring
    virtual void        MonInstructionExecute(TAddress addr, TRegister instr) { }
    virtual void        MonDataLoad(TAddress addr, TRegister mask, TAddress value) { }
    virtual void        MonDataStore(TAddress addr, TRegister mask, TAddress value) { }
    virtual void        MonFault(TAddress addr, TRegister instr) { }
    virtual void        MonExit(void) { }
    virtual void        MonNop(TRegister imm);
    
private:

    // CPU Registers
    TRegister           r_gpr[REGISTERS];
    TRegister           r_pc;
    TRegister           r_pc_next;
    TRegister           r_pc_last;
    TRegister           r_sr;
    TRegister           r_epc;
    TRegister           r_esr;

    // Register file access
    TRegister           r_ra;
    TRegister           r_rd;
    TRegister           r_rd_wb;
    TRegister           r_rb;
    TRegister           r_reg_ra;
    TRegister           r_reg_rb;
    TRegister           r_reg_result;
    TRegister           r_reg_rd_out;
    int                 r_writeback;
    TInstruction        r_opcode;

    // Memory
    TMemory             *Mem[MAX_MEM_REGIONS];
    TAddress            MemBase[MAX_MEM_REGIONS];
    unsigned int        MemSize[MAX_MEM_REGIONS];
    int                 MemRegions;
    TAddress            MemVectorBase;
    TRegister           *MemInstHits[MAX_MEM_REGIONS];
    TRegister           *MemReadHits[MAX_MEM_REGIONS];
    TRegister           *MemWriteHits[MAX_MEM_REGIONS];

    // Peripherals
    PeripheralInstance periperhals[MAX_PERIPHERALS];

    // Memory access
    TAddress            mem_addr;
    TRegister           mem_data_out;
    TRegister           mem_data_in;
    TRegister           mem_offset;
    TRegister           mem_wr;
    TRegister           mem_rd;
    TRegister           mem_ifetch;

    // Status
    int                 Fault;
    int                 Break;
    TRegister           BreakValue;
    unsigned            Trace;
    int                 Cycle;
    bool                DelaySlotEnabled;
    bool                TraceMemory;
    bool                EnablePutc;

    // Stats
    int                 StatsMem;
    int                 StatsMemWrites;
    int                 StatsMulu;
    int                 StatsMul;
    int                 StatsMarkers;
    int                 StatsInstructions;
    int                 StatsNop;
    int                 StatsBranches;
    int                 StatsExceptions;
};

#endif
