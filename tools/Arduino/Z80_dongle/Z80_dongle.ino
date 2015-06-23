//------------------------------------------------------------------------
// This Arduino sketch should be used with a Mega board connected to a
// dongle hosting a Z80 CPU. The Arduino fully controls and senses all
// Z80 CPU pins. This software runs physical Z80 CPU by providing clock
// ticks and setting various control pins.
//
// There is a limited RAM buffer simulated by this sketch. All Z80 memory
// accesses are directed to use that buffer.
//
// Address and data buses from Z80 are connected to analog Arduino pins.
// Along with a resistor network on the dongle, this allows the software
// to sense when Z80 tri-states those two buses.
//
// Notes:
//      - Use serial set to 115200
//      - In the Arduino serial monitor window, set line ending to "CR"
//      - Memory access is simulated using a 256-byte pseudo-RAM memory
//      - I/O map is _not_ implemented. Reads will return whatever happens
//        to be on the data bus
//
// Copyright 2014 by Goran Devic
// This source code is released under the GPL v2 software license.
//------------------------------------------------------------------------
#include <stdarg.h>
#include "WString.h"

// Define Arduino Mega pins that are connected to a Z80 dongle board.
// Pin numbers appear out-of-order, but they cleanly connect in complete
// blocks to sets of pins on Arduino Mega! This will become obvious once
// you start connecting them...
#define DB0         A9      // DB pin line-up on a Z80 is a bit swizzled...
#define DB1         A8
#define DB2         A11
#define DB3         A14
#define DB4         A15
#define DB5         A13
#define DB6         A12
#define DB7         A10
// Address bus pins from Z80 are connected to A0..A7 on Arduino.

#define INT         52      // This is a block of control signals from the
#define NMI         50      // bottom-left corner of Z80
#define HALT        48
#define MREQ        46
#define IORQ        44

#define RFSH        53      // This is a block of control signals from the
#define M1          51      // bottom-right corner of Z80
#define RESET       49
#define BUSRQ       47
#define WAIT        45
#define BUSAK       43
#define WR          41
#define RD          39

#define CLK         13      // Clock is also toggling Arduino LED (fast, though)

// Tri-state detection values: the values that are read on analog pins
// sensing the "high-Z" will differ based on the resistor values that make
// up your voltage divider. Print your particular readings and adjust these:
#define HI_Z_LOW    50      // Upper "0" value; low tri-state boundary
#define HI_Z_HIGH   600     // Low "1" value; upper tri-state boundary

// Control *output* pins of Z80, we read them into these variables
int  halt;
int  mreq;
int  iorq;
int  rfsh;
int  m1;
int  busak;
int  wr;
int  rd;

// Control *input* pins of Z80, we write them into the dongle
int zint = 1;
int nmi = 1;
int reset = 1;
int busrq = 1;
int wait = 1;

// Content of address and data wires
int ab;
byte db;

// Clock counter after reset
int clkCount;
int clkCountHi;

// T-cycle counter
int T;
int Mlast;

// M1-cycle counter
int m1Count;

// Detection if the address or data bus is tri-stated
bool abTristated = false;
bool dbTristated = false;

// Simulation control variables
bool running = 1;           // Simulation is running or is stopped
int traceShowBothPhases;    // Show both phases of a clock cycle
int traceRefresh;           // Trace refresh cycles
int tracePause;             // Pause for a key press every so many clocks
int tracePauseCount;        // Current clock count for tracePause
int stopAtClk;              // Stop the simulation after this many clocks
int stopAtM1;               // Stop at a specific M1 cycle number
int stopAtHalt;             // Stop when HALT signal gets active
int intAtClk;               // Issue INT signal at that clock number
int nmiAtClk;               // Issue NMI signal at that clock number
int busrqAtClk;             // Issue BUSRQ signal at that clock number
int resetAtClk;             // Issue RESET signal at that clock number
int waitAtClk;              // Issue WAIT signal at that clock number
int clearAtClk;             // Clear all control signals at that clock number
byte iorqVector;            // Push IORQ vector (default is FF)

// Buffer containing RAM memory for Z80 to access
byte ram[256];

// Temp buffer to store input line
#define TEMP_SIZE   512
char temp[TEMP_SIZE];

// Temp buffer to store extra dump information
char extraInfo[64] = { "" };

// Utility function to provide a meaningful printf to a serial port
void p(char *fmt, ... ){
    char tmp[256];          // resulting string limited to 256 chars
    va_list args;
    va_start (args, fmt );
    vsnprintf(tmp, 256, fmt, args);
    va_end (args);
    Serial.print(tmp);
}

// Read and return one ASCII hex value from a string
byte hex(char *s){
    byte nibbleH = (*s - '0') & ~(1<<5);
    byte nibbleL = (*(s+1) - '0') & ~(1<<5);
    if (nibbleH>9) nibbleH -= 7;
    if (nibbleL>9) nibbleL -= 7;
    return (nibbleH << 4) | nibbleL;
}

// Read and return one ASCII hex value from a temp buffer given the index
// of that hex number. This is used only to read Intel HEX format buffer.
byte hexFromTemp(char *pTemp, int index)
{
    int start = (index*2)+1;
    return hex(pTemp + start);
}

// -----------------------------------------------------------
// Arduino initialization entry point
// -----------------------------------------------------------
void setup()
{
    Serial.begin(115200);
    Serial.flush();
    Serial.setTimeout(1000*60*60);

    ResetSimulationVars();

    // By default, all Arduino pins are set as inputs
    // Configure all output pins, *inputs* into Z80
    pinMode(CLK, OUTPUT);
    digitalWrite(CLK, HIGH);
    pinMode(INT, OUTPUT);
    pinMode(NMI, OUTPUT);
    pinMode(RESET, OUTPUT);
    pinMode(BUSRQ, OUTPUT);
    pinMode(WAIT, OUTPUT);
    WriteControlPins();

    // Perform a Z80 CPU reset
    DoReset();
}

// Resets all simulation variables to their defaults
void ResetSimulationVars()
{
    traceShowBothPhases = 0;// Show both phases of a clock cycle
    traceRefresh = 1;       // Trace refresh cycles
    tracePause = -1;        // Pause for a keypress every so many clocks
    stopAtClk = 40;         // Stop the simulation after this many clocks
    stopAtM1 = -1;          // Stop at a specific M1 cycle number
    stopAtHalt = 1;         // Stop when HALT signal gets active
    intAtClk = -1;          // Issue INT signal at that clock number
    nmiAtClk = -1;          // Issue NMI signal at that clock number
    busrqAtClk = -1;        // Issue BUSRQ signal at that clock number
    resetAtClk = -1;        // Issue RESET signal at that clock number
    waitAtClk = -1;         // Issue WAIT signal at that clock number
    clearAtClk = -1;        // Clear all control signals at that clock number
    iorqVector = 0xFF;      // Push IORQ vector
}

// Issue a RESET sequence to Z80 and reset internal counters
void DoReset()
{
    p("\r\n:Starting the clock\r\n");
    digitalWrite(RESET, LOW);    delay(1);
    // Reset should be kept low for 3 full clock cycles
    for(int i=0; i<3; i++)
    {
        digitalWrite(CLK, HIGH); delay(1);
        digitalWrite(CLK, LOW);  delay(1);
    }
    p(":Releasing RESET\r\n");
    digitalWrite(RESET, HIGH);   delay(1);
    // Do not count initial 2 clocks after the reset
    clkCount = -2;
    T = 0;
    Mlast = 1;
    tracePauseCount = 0;
    m1Count = 0;
}

// Write all control pins into the Z80 dongle
void WriteControlPins()
{
    digitalWrite(INT, zint ? HIGH : LOW);
    digitalWrite(NMI, nmi ? HIGH : LOW);
    digitalWrite(RESET, reset ? HIGH : LOW);
    digitalWrite(BUSRQ, busrq ? HIGH : LOW);
    digitalWrite(WAIT,  wait ? HIGH : LOW);
}

// Set new data value into the Z80 data bus
void SetDataToDB(byte data)
{
    pinMode(DB0, OUTPUT);
    pinMode(DB1, OUTPUT);
    pinMode(DB2, OUTPUT);
    pinMode(DB3, OUTPUT);
    pinMode(DB4, OUTPUT);
    pinMode(DB5, OUTPUT);
    pinMode(DB6, OUTPUT);
    pinMode(DB7, OUTPUT);

    digitalWrite(DB0, (data & (1<<0)) ? HIGH : LOW);
    digitalWrite(DB1, (data & (1<<1)) ? HIGH : LOW);
    digitalWrite(DB2, (data & (1<<2)) ? HIGH : LOW);
    digitalWrite(DB3, (data & (1<<3)) ? HIGH : LOW);
    digitalWrite(DB4, (data & (1<<4)) ? HIGH : LOW);
    digitalWrite(DB5, (data & (1<<5)) ? HIGH : LOW);
    digitalWrite(DB6, (data & (1<<6)) ? HIGH : LOW);
    digitalWrite(DB7, (data & (1<<7)) ? HIGH : LOW);
    db = data;
    dbTristated = false;
}

// Read Z80 data bus and store into db variable
void GetDataFromDB()
{
    pinMode(DB0, INPUT);
    pinMode(DB1, INPUT);
    pinMode(DB2, INPUT);
    pinMode(DB3, INPUT);
    pinMode(DB4, INPUT);
    pinMode(DB5, INPUT);
    pinMode(DB6, INPUT);
    pinMode(DB7, INPUT);

    digitalWrite(DB0, LOW);
    digitalWrite(DB1, LOW);
    digitalWrite(DB2, LOW);
    digitalWrite(DB3, LOW);
    digitalWrite(DB4, LOW);
    digitalWrite(DB5, LOW);
    digitalWrite(DB6, LOW);
    digitalWrite(DB7, LOW);

    // Detect if the data bus is tri-stated
    delay(1);
    int test0 = analogRead(DB0);
    // These numbers might need to be adjusted for each Arduino board
    dbTristated = test0>HI_Z_LOW && test0<HI_Z_HIGH;

    byte d0 = digitalRead(DB0);
    byte d1 = digitalRead(DB1);
    byte d2 = digitalRead(DB2);
    byte d3 = digitalRead(DB3);
    byte d4 = digitalRead(DB4);
    byte d5 = digitalRead(DB5);
    byte d6 = digitalRead(DB6);
    byte d7 = digitalRead(DB7);
    db = (d7<<7)|(d6<<6)|(d5<<5)|(d4<<4)|(d3<<3)|(d2<<2)|(d1<<1)|d0;
}

// Read a value of Z80 address bus and store it into the ab variable.
// In addition, try to detect when a bus is tri-stated and write 0xFFF if so.
void GetAddressFromAB()
{
    // Detect if the address bus is tri-stated
    int test0 = analogRead(A0);
    // These numbers might need to be adjusted for each Arduino board
    abTristated = test0>HI_Z_LOW && test0<HI_Z_HIGH;

    int a0 = digitalRead(A0);
    int a1 = digitalRead(A1);
    int a2 = digitalRead(A2);
    int a3 = digitalRead(A3);
    int a4 = digitalRead(A4);
    int a5 = digitalRead(A5);
    int a6 = digitalRead(A6);
    int a7 = digitalRead(A7);
    ab = (a7<<7)|(a6<<6)|(a5<<5)|(a4<<4)|(a3<<3)|(a2<<2)|(a1<<1)|a0;
}

// Read all control pins on the Z80 and store them into internal variables
void ReadControlState()
{
    halt  = digitalRead(HALT);
    mreq  = digitalRead(MREQ);
    iorq  = digitalRead(IORQ);
    rfsh  = digitalRead(RFSH);
    m1    = digitalRead(M1);
    busak = digitalRead(BUSAK);
    wr    = digitalRead(WR);
    rd    = digitalRead(RD);
}

// Dump the Z80 state as stored in internal variables
void DumpState(bool suppress)
{
    if (!suppress)
    {
        // Select your character for tri-stated bus
        char abStr[4] = { "---" };
        char dbStr[3] = { "--" };
        if (!abTristated) sprintf(abStr, "%03X", ab);
        if (!dbTristated) sprintf(dbStr, "%02X", db);
        if (T==1 && clkCountHi)
            p("-----------------------------------------------------------+\r\n");
        p("#%03d%c T%-2d AB:%s DB:%s  %s %s %s %s %s %s %s %s |%s%s%s%s %s\r\n",
        clkCount<0? 0 : clkCount, clkCountHi ? 'H' : 'L', T,
        abStr, dbStr,
        m1?"  ":"M1", rfsh?"    ":"RFSH", mreq?"    ":"MREQ", rd?"  ":"RD", wr?"  ":"WR", iorq?"    ":"IORQ", busak?"     ":"BUSAK",halt?"    ":"HALT",
        zint?"":"[INT]", nmi?"":"[NMI]", busrq?"":"[BUSRQ]", wait?"":"[WAIT]",
        extraInfo);
    }
    extraInfo[0] = 0;
}

// -----------------------------------------------------------
// Main loop routine runs over and over again forever
// -----------------------------------------------------------
void loop()
{
    //--------------------------------------------------------
    // Clock goes high
    //--------------------------------------------------------
    delay(1); digitalWrite(CLK, HIGH); delay(1);

    clkCountHi = 1;
    clkCount++;
    T++;
    tracePauseCount++;
    ReadControlState();
    GetAddressFromAB();
    if (Mlast==1 && m1==0)
        T = 1, m1Count++;
    Mlast = m1;
    bool suppressDump = false;
    if (!traceRefresh & !rfsh) suppressDump = true;

    // If the number of M1 cycles has been reached, skip the rest since we dont
    // want to execute this M1 phase
    if (m1Count==stopAtM1)
    {
        sprintf(extraInfo, "Number of M1 cycles reached"), running = false;
        p("-----------------------------------------------------------+\r\n");
        goto control;
    }

    // If the address is tri-stated, skip checking various combinations of
    // control signals since they may also be floating and we can't detect that
    if (!abTristated)
    {
        // Simulate read from RAM
        if (!mreq && !rd)
        {
            SetDataToDB(ram[ab & 0xFF]);
            if (!m1)
                sprintf(extraInfo, "Opcode read from %03X -> %02X", ab, ram[ab & 0xFF]);
            else
                sprintf(extraInfo, "Memory read from %03X -> %02X", ab, ram[ab & 0xFF]);
        }
        else
        // Simulate interrupt requesting a vector
        if (!m1 && !iorq)
        {
            SetDataToDB(iorqVector);
            sprintf(extraInfo, "Pushing vector %02X", iorqVector);
        }
        else
            GetDataFromDB();

        // Simulate write to RAM
        if (!mreq && !wr)
        {
            ram[ab & 0xFF] = db;
            sprintf(extraInfo, "Memory write to  %03X <- %02X", ab, db);
        }

        // Detect I/O read: We don't place anything on the bus
        if (!iorq && !rd)
        {
            sprintf(extraInfo, "I/O read from %03X", ab);
        }

        // Detect I/O write
        if (!iorq && !wr)
        {
            sprintf(extraInfo, "I/O write to %03X <- %02X", ab, db);
        }

        // Capture memory refresh cycle
        if (!mreq && !rfsh)
        {
            sprintf(extraInfo, "Refresh address  %03X", ab);
        }
    }
    else
        GetDataFromDB();

    DumpState(suppressDump);

    // If the user wanted to pause simulation after a certain number of
    // clocks, handle it here. If the key pressed to continue was not Enter,
    // stop the simulation to issue that command
    if (tracePause==tracePauseCount)
    {
        while(Serial.available()==0) ;
        if (Serial.peek()!='\r')
            sprintf(extraInfo, "Continue keypress was not Enter"), running = false;
        else
            Serial.read();
        tracePauseCount = 0;
    }

    //--------------------------------------------------------
    // Clock goes low
    //--------------------------------------------------------
    delay(1); digitalWrite(CLK, LOW); delay(1);

    clkCountHi = 0;
    if (traceShowBothPhases)
    {
        ReadControlState();
        GetAddressFromAB();
        DumpState(suppressDump);
    }

    // Perform various actions at the requested clock number
    // if the count is positive (we start it at -2 to skip initial 2T)
    if (clkCount>=0)
    {
        if (clkCount==intAtClk) zint = 0;
        if (clkCount==nmiAtClk) nmi = 0;
        if (clkCount==busrqAtClk) busrq = 0;
        if (clkCount==resetAtClk) reset = 0;
        if (clkCount==waitAtClk) wait = 0;
        // De-assert all control pins at this clock number
        if (clkCount==clearAtClk)
            zint = nmi = busrq = reset = wait = 1;
        WriteControlPins();

        // Stop the simulation under some conditions
        if (clkCount==stopAtClk)
            sprintf(extraInfo, "Number of clocks reached"), running = false;
        if (stopAtHalt&!halt)
            sprintf(extraInfo, "HALT instruction"), running = false;
    }

    //--------------------------------------------------------
    // Trace/simulation control handler
    //--------------------------------------------------------
control:
    if (!running)
    {
        p(":Simulation stopped: %s\r\n", extraInfo);
        extraInfo[0] = 0;
        digitalWrite(CLK, HIGH);
        zint = nmi = busrq = wait = 1;
        WriteControlPins();

        while(!running)
        {
            // Expect a command from the serial port
            if (Serial.available()>0)
            {
                memset(temp, 0, TEMP_SIZE);
                Serial.readBytesUntil('\r', temp, TEMP_SIZE-1);

                // Option ":"  : this is not really a user option. This is used to
                //               Intel HEX format values into the RAM buffer
                // Multiple lines may be pasted. They are separated by a space character.
                char *pTemp = temp;
                while (*pTemp==':')
                {
                    byte bytes = hexFromTemp(pTemp, 0);
                    if (bytes>0)
                    {
                        int address = (hexFromTemp(pTemp, 1)<<8) + hexFromTemp(pTemp, 2);
                        byte recordType = hexFromTemp(pTemp, 3);
                        p("%04X:", address);
                        for (int i=0; i<bytes; i++)
                        {
                            ram[(address + i) & 0xFF] = hexFromTemp(pTemp, 4+i);
                            p(" %02X", hexFromTemp(pTemp, 4+i));
                        }
                        p("\r\n");
                    }
                    pTemp += bytes*2 + 12;  // Skip to the next possible line of hex entry
                }
                // Option "r"  : reset and run the simulation
                if (temp[0]=='r')
                {
                    // If the variable 9 (Issue RESET) is not set, perform a RESET and run the simulation.
                    // If the variable was set, skip reset sequence since we might be testing it.
                    if (resetAtClk<0)
                        DoReset();
                    running = true;
                }
                // Option "sc" : clear simulation variables to their default values
                if (temp[0]=='s' && temp[1]=='c')
                {
                    ResetSimulationVars();
                    temp[1] = 0;            // Proceed to dump all variables...
                }
                // Option "s"  : show and set internal control variables
                if (temp[0]=='s' && temp[1]!='c')
                {
                    // Show or set the simulation parameters
                    int var = 0, value;
                    int args = sscanf(&temp[1], "%d %d\r\n", &var, &value);
                    // Parameter for the option #12 is read in as a hex; others are decimal by default
                    if (var==12)
                        args = sscanf(&temp[1], "%d %x\r\n", &var, &value);
                    if (args==2)
                    {
                        if (var==0) traceShowBothPhases = value;
                        if (var==1) traceRefresh = value;
                        if (var==2) tracePause = value;
                        if (var==3) stopAtClk = value;
                        if (var==4) stopAtM1 = value;
                        if (var==5) stopAtHalt = value;
                        if (var==6) intAtClk = value;
                        if (var==7) nmiAtClk = value;
                        if (var==8) busrqAtClk = value;
                        if (var==9) resetAtClk = value;
                        if (var==10) waitAtClk = value;
                        if (var==11) clearAtClk = value;
                        if (var==12) iorqVector = value & 0xFF;
                    }
                    p("------ Simulation variables ------\r\n");
                    p("#0  Trace both clock phases  = %d\r\n", traceShowBothPhases);
                    p("#1  Trace refresh cycles     = %d\r\n", traceRefresh);
                    p("#2  Pause for keypress every = %d\r\n", tracePause);
                    p("#3  Stop after clock #       = %d\r\n", stopAtClk);
                    p("#4  Stop after # M1 cycles   = %d\r\n", stopAtM1);
                    p("#5  Stop at HALT             = %d\r\n", stopAtHalt);
                    p("#6  Issue INT at clock #     = %d\r\n", intAtClk);
                    p("#7  Issue NMI at clock #     = %d\r\n", nmiAtClk);
                    p("#8  Issue BUSRQ at clock #   = %d\r\n", busrqAtClk);
                    p("#9  Issue RESET at clock #   = %d\r\n", resetAtClk);
                    p("#10 Issue WAIT at clock #    = %d\r\n", waitAtClk);
                    p("#11 Clear all at clock #     = %d\r\n", clearAtClk);
                    p("#12 Push IORQ vector #(hex)  = %2X\r\n", iorqVector);
                }
                // Option "m"  : dump RAM memory
                if (temp[0]=='m' && temp[1]!='c')
                {
                    // Dump the content of a RAM buffer
                    p("    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F\r\n");
                    p("   +-----------------------------------------------\r\n");
                    for(int i=0; i<16; i++)
                    {
                        p("%02X |", i);
                        for(int j=0; j<16; j++)
                        {
                            p("%02X ", ram[i*16+j]);
                        }
                        p("\r\n");
                    }
                }
                // Option "mc"  : clear RAM memory
                if (temp[0]=='m' && temp[1]=='c')
                {
                    memset(ram, 0, sizeof(ram));
                    p("RAM cleared\r\n");
                }
                // Option "?"  : print help
                if (temp[0]=='?' || temp[0]=='h')
                {
                    p("s            - show simulation variables\r\n");
                    p("s #var value - set simulation variable number to a value\r\n");
                    p("sc           - clear simulation variables to their default values\r\n");
                    p("r            - restart the simulation\r\n");
                    p(":INTEL-HEX   - reload RAM buffer with a given data stream\r\n");
                    p("m            - dump the content of the RAM buffer\r\n");
                    p("mc           - clear the RAM buffer\r\n");
                }
            }
        }
    }
}
