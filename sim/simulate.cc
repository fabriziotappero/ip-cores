
#include <stdio.h>
#include <assert.h>
#include <conio.h>

const bool do_log = false;

typedef   signed char  sc;
typedef   signed short ss;
typedef unsigned char  uc;
typedef unsigned short us;

int  simulate();
void print_txt(const char * txt, int imm, us op, us l, us h);

enum { SIZE = 0x10000 };

uc mem[SIZE];
const char * labels[SIZE];

FILE * out = 0;
FILE * log = 0;

int clock = 4;

//-----------------------------------------------------------------------------
int main(int argc, char *argv[])
{
   for (int i = 0; i < sizeof(mem); i++)
       {
         mem[i] = 0x00;
         labels[i] = 0;
       }

   assert(argc == 3 && "Too few arguments");

   fprintf(stderr, "Input file is %s\n", argv[1]);
FILE * in = fopen(argv[1], "rb");
   assert(in && "No binary input file");

   fprintf(stderr, "Symbol file is %s\n", argv[2]);
FILE * sym = fopen(argv[2], "r");
   assert(in && "No symbol file");

   log = fopen("..\\simulate.log", "w");
   assert(log);
   // out = fopen("..\\simulate.out", "w");
   out = stdout;
   assert(out);

unsigned int  sval;
char snam[256];
   while (2 == fscanf(sym, "%X %s", &sval, snam))
      {
        fprintf(log, "Symbol %4.4X = %s\n", sval, snam);

        if (labels[sval])    continue;

        char * cp = new char[strlen(snam) + 1];
        strcpy(cp, snam);
        labels[sval] = cp;
      }

const int l = fread(mem, 1, sizeof(mem), in);
   fprintf(stderr, "%d bytes read\n", l);
   assert(l > 0 && "Empty binary input file");
   assert(l < sizeof(mem) && "Binary input file too big");

   fclose(in);

   fprintf(stderr, "Simulation started\n");

const int steps = simulate();
   fprintf(stderr,
           "\nSimulation done (processor halted) after %d steps\n",
           steps);
   fclose(log);
}
//-----------------------------------------------------------------------------
class CPU
{
public:
   CPU()
   : PC(0), SP(0), LL(0), RR(0)
   {};

   bool Step();

private:
   static us _16(us h, us l)   { return (h << 8) | l;  };

   uc u8()           { imm++;   return mem[PC++];                  };
   sc s8()           { return u8();                                };
   us u16()          { uc l = u8();   return _16(u8(), l);         };
   ss s16()          { return u16();                               }
   void push8(uc v)  { mem[--SP] = v;                              };
   void push16(us v) { mem[--SP] = v>>8;   mem[--SP] = v;          };
   us pop16()        { us l = mem[SP++]; return _16(mem[SP++], l); };
   us pop8u()        { return (us)(uc)mem[SP++];                   };
   ss pop8s()        { return (ss)(sc)mem[SP++];                   };
   us mem16(us a)    { return _16(mem[a + 1], mem[a]);             };
   void mem16(us a, us v)   { mem[a] = v; mem[a+1] = v >> 8;       };
   static us yes(us x) { if (x) return 0xFFFF;   return 0;         };

   bool input(uc port);
   bool output(uc port);
   bool serout(uc c);

   us   PC;
   us   SP;
   us   RR;
   us   LL;
   uc   opc;
   us   prq;
   us   rem;
   uc   imm;
};
//-----------------------------------------------------------------------------
bool CPU::input(uc port)
{
   switch(port)
      {
        case 0x00: RR = _getch() & 0xFF;
                   return false;   // serial in
        case 0x01: RR = 0x01;
                   return false;   // serial status: !TxBusy | RxRdy
        case 0x02: RR = 37;
                   return false;   // temperature
      }

   return true;   // error
}
//-----------------------------------------------------------------------------
bool CPU::output(uc port)
{
   switch(port)
      {
        case 0x00: return serout(RR);   ;   // serial out
        case 0x02: return false;
        case 0x03: return false;
        case 0x04: return false;
      }

   return true;   // error
}
//-----------------------------------------------------------------------------
bool CPU::serout(uc c)
{
char cc[20];

   if      (c == '\n')   sprintf(cc, "\n");
   else if (c == '\r')   sprintf(cc, "\\r");
   else if (c <  ' ')    sprintf(cc, "\\x%2.2X", c);
   else if (c > 0x7E)    sprintf(cc, "\\x%2.2X", c);
   else                  sprintf(cc, "%c", c);

   fprintf(out, "%s", cc);
   fprintf(log, "-> %s (0x%2.2X)\n", cc, c);

   return false;   // no error
}
//-----------------------------------------------------------------------------
int simulate()
{
CPU cpu;
int steps = 1;

   for (;;steps++)   if (cpu.Step())   return steps;
}
//-----------------------------------------------------------------------------

#define OP(_op, _act, _txt) case  _op:   _act   txt = _txt;   break;

bool CPU::Step()
{
   clock++;
   if (labels[PC])   fprintf(log, "%s:\n", labels[PC]);

const unsigned short lpc = PC;
const char * txt = "???";
bool done = false;

   imm = 0;
   opc = u8();

us tmp;
us uquick = opc & 0x0F;
us squick = opc & 0x0F;   if (squick & 0x08)   squick |= 0xFFF0;

   switch(opc)
      {
OP(0x00, { done = true;                         }, "HALT"             )
OP(0x01, {                                      }, "NOP"              )
OP(0x02, { PC = u16();                          }, "JMP  j"           )
OP(0x03, { tmp = u16(); if ( RR) PC = tmp;      }, "JMP  RRNZ, j"     )
OP(0x04, { tmp = u16(); if (!RR) PC = tmp;      }, "JMP  RRZ, j"      )
OP(0x05, { push16(lpc + 3);   PC = u16();       }, "CALL j"           )
OP(0x06, { push16(lpc + 3);   PC = RR;          }, "CALL (RR)"        )
OP(0x07, { PC = pop16();                        }, "RET"              )
OP(0x08, { RR = pop16();                        }, "MOVE (SP)+, RR"   )
OP(0x09, { RR = pop8s();                        }, "MOVE (SP)+, RS"   )
OP(0x0A, { RR = pop8u();                        }, "MOVE (SP)+, RU"   )
OP(0x0B, { LL = pop16();                        }, "MOVE (SP)+, LL"   )
OP(0x0C, { LL = pop8s();                        }, "MOVE (SP)+, LS"   )
OP(0x0D, { LL = pop8u();                        }, "MOVE (SP)+, LU"   )
OP(0x0E, { push16(RR);                          }, "MOVE RR, -(SP)"   )
OP(0x0F, { push8(RR);                           }, "MOVE R, -(SP)"    )

OP(0x10, { RR = RR & u16();                     }, "AND  RR, #u"      )
OP(0x11, { RR = RR & u8();                      }, "AND  RR, #u"      )
OP(0x12, { RR = RR | u16();                     }, "OR   RR, #u"      )
OP(0x13, { RR = RR | u8();                      }, "OR   RR, #u"      )
OP(0x14, { RR = RR ^ u16();                     }, "XOR  RR, #u"      )
OP(0x15, { RR = RR ^ u8();                      }, "XOR  RR, #u"      )
OP(0x16, { RR = yes((ss)RR == s16());           }, "SEQ  RR, #s"      )
OP(0x17, { RR = yes((ss)RR == s8() );           }, "SEQ  RR, #s"      )
OP(0x18, { RR = yes((ss)RR != s16());           }, "SNE  RR, #s"      )
OP(0x19, { RR = yes((ss)RR != s8() );           }, "SNE  RR, #s"      )
OP(0x1A, { RR = yes((ss)RR >= s16());           }, "SGE  RR, #s"      )
OP(0x1B, { RR = yes((ss)RR >= s8() );           }, "SGE  RR, #s"      )
OP(0x1C, { RR = yes((ss)RR >  s16());           }, "SGT  RR, #s"      )
OP(0x1D, { RR = yes((ss)RR >  s8() );           }, "SGT  RR, #s"      )
OP(0x1E, { RR = yes((ss)RR <= s16());           }, "SLE  RR, #s"      )
OP(0x1F, { RR = yes((ss)RR <= s8() );           }, "SLE  RR, #s"      )

OP(0x20, { RR = yes((ss)RR <  s16());           }, "SLT  RR, #s"      )
OP(0x21, { RR = yes((ss)RR <  s8() );           }, "SLT  RR, #s"      )
OP(0x22, { RR = yes((us)RR >= u16());           }, "SHS  RR, #u"      )
OP(0x23, { RR = yes((us)RR >= u8() );           }, "SHS  RR, #u"      )
OP(0x24, { RR = yes((us)RR >  u16());           }, "SHI  RR, #u"      )
OP(0x25, { RR = yes((us)RR >  u8() );           }, "SHI  RR, #u"      )
OP(0x26, { RR = yes((us)RR <= u16());           }, "SLS  RR, #u"      )
OP(0x27, { RR = yes((us)RR <= u8() );           }, "SLS  RR, #u"      )
OP(0x28, { RR = yes((us)RR <  u16());           }, "SLO  RR, #u"      )
OP(0x29, { RR = yes((us)RR <  u8() );           }, "SLO  RR, #u"      )
OP(0x2A, { SP = SP + u16();                     }, "ADD  SP, #u"      )
OP(0x2B, { SP = SP + u8();                      }, "ADD  SP, #u"      )
OP(0x2C, { push16(0);                           }, "CLRW -(SP)"       )
OP(0x2D, { push8(0);                            }, "CLRB -(SP)"       )
OP(0x2E, { done = input(u8());                  }, "IN   (u), RU"     )
OP(0x2F, { done = output(u8());                 }, "OUT  R, (u)"      )

OP(0x30, { RR = LL & RR;                        }, "AND  LL, RR"      )
OP(0x31, { RR = LL | RR;                        }, "OR   LL, RR"      )
OP(0x32, { RR = LL ^ RR;                        }, "XOR  LL, RR"      )
OP(0x33, { RR = yes((ss)LL == (ss)RR);          }, "SEQ  LL, RR"      )
OP(0x34, { RR = yes((ss)LL != (ss)RR);          }, "SNE  LL, RR"      )
OP(0x35, { RR = yes((ss)LL >= (ss)RR);          }, "SGE  LL, RR"      )
OP(0x36, { RR = yes((ss)LL >  (ss)RR);          }, "SGT  LL, RR"      )
OP(0x37, { RR = yes((ss)LL <= (ss)RR);          }, "SLE  LL, RR"      )
OP(0x38, { RR = yes((ss)LL <  (ss)RR);          }, "SLT  LL, RR"      )
OP(0x39, { RR = yes((us)LL >= (us)RR);          }, "SHS  LL, RR"      )
OP(0x3A, { RR = yes((us)LL >  (us)RR);          }, "SHI  LL, RR"      )
OP(0x3B, { RR = yes((us)LL <= (us)RR);          }, "SLS  LL, RR"      )
OP(0x3C, { RR = yes((us)LL <  (us)RR);          }, "SLO  LL, RR"      )
OP(0x3D, { RR = yes(! RR);                      }, "LNOT RR"          )
OP(0x3E, { RR = - RR;                           }, "NEG  RR"          )
OP(0x3F, { RR = ~ RR;                           }, "NOT  RR"          )

OP(0x40, { RR = LL;                             }, "MOVE LL, RR"      )
OP(0x41, { mem[RR] = LL; mem[RR+1] = LL>>8;     }, "MOVE LL, (RR)"    )
OP(0x42, { mem[RR] = LL;                        }, "MOVE L, (RR)"     )
OP(0x43, { LL = RR;                             }, "MOVE RR, LL"      )
OP(0x44, { mem[LL] = RR; mem[LL+1] = RR>>8;     }, "MOVE RR, (LL)"    )
OP(0x45, { mem[LL] = RR;                        }, "MOVE R, (LL)"     )
OP(0x46, { RR = mem16(RR);                      }, "MOVE (RR), RR"    )
OP(0x47, { RR = (ss)(sc)mem[RR];                }, "MOVE (RR), RS"    )
OP(0x48, { RR = (us)(uc)mem[RR];                }, "MOVE (RR), RU"    )
OP(0x49, { RR = mem16(u16());                   }, "MOVE (u), RR"     )
OP(0x4A, { RR = (ss)(sc)mem[u16()];             }, "MOVE (u), RS"     )
OP(0x4B, { RR = (us)(us)mem[u16()];             }, "MOVE (u), RU"     )
OP(0x4C, { LL = mem16(u16());                   }, "MOVE (u), LL"     )
OP(0x4D, { LL = (ss)(sc)mem[u16()];             }, "MOVE (u), LS"     )
OP(0x4E, { LL = (us)(us)mem[u16()];             }, "MOVE (u), LU"     )
OP(0x4F, { SP = RR;                             }, "MOVE RR, SP"      )

OP(0x52, { RR = RR       << u8();               }, "LSL  RR, #u"      )
OP(0x53, { RR = ((ss)RR) >> u8();               }, "ASR  RR, #u"      )
OP(0x54, { RR = ((us)RR) >> u8();               }, "LSR  RR, #u"      )
OP(0x55, { RR = LL       << RR;                 }, "LSL  LL, RR"      )
OP(0x56, { RR = ((ss)LL) >> RR;                 }, "ASR  LL, RR"      )
OP(0x57, { RR = ((us)LL) >> RR;                 }, "LSR  LL, RR"      )
OP(0x58, { RR = LL +  RR;                       }, "ADD  LL, RR"      )
OP(0x59, { RR = LL -  RR;                       }, "SUB  LL, RR"      )
OP(0x5A, { mem[tmp = u16()] = RR;
           mem[tmp + 1] = RR >> 8;              }, "MOVE  RR, (u)"    )
OP(0x5B, { mem[u16()] = RR;                     }, "MOVE  R, (u)"     )
OP(0x5C, { mem16(SP + u16(), RR);               }, "MOVE  RR, u(SP)"  )
OP(0x5D, { mem16(SP + u8(), RR);                }, "MOVE  RR, u(SP)"  )
OP(0x5E, { mem[SP + u16()] = RR;                }, "MOVE  R, u(SP)"   )
OP(0x5F, { mem[SP + u8()] = RR;                 }, "MOVE  R, u(SP)"   )

OP(0x60, { RR = mem16(SP + u16());              }, "MOVE u(SP), RR"   )
OP(0x61, { RR = mem16(SP + u8());               }, "MOVE u(SP), RR"   )
OP(0x62, { RR = (ss)(sc)mem[SP + u16()];        }, "MOVE u(SP), RS"   )
OP(0x63, { RR = (ss)(sc)mem[SP + u8()];         }, "MOVE u(SP), RS"   )
OP(0x64, { RR = (us)(uc)mem[SP + u16()];        }, "MOVE u(SP), RU"   )
OP(0x65, { RR = (us)(uc)mem[SP + u8()];         }, "MOVE u(SP), RU"   )
OP(0x66, { LL = mem16(SP + u16());              }, "MOVE u(SP), LL"   )
OP(0x67, { LL = mem16(SP + u8());               }, "MOVE u(SP), LL"   )
OP(0x68, { LL = (ss)(sc)mem[SP + u16()];        }, "MOVE u(SP), LS"   )
OP(0x69, { LL = (ss)(sc)mem[SP + u8() ];        }, "MOVE u(SP), LS"   )
OP(0x6A, { LL = (us)(uc)mem[SP + u16()];        }, "MOVE u(SP), LU"   )
OP(0x6B, { LL = (us)(uc)mem[SP + u8() ];        }, "MOVE u(SP), LU"   )
OP(0x6C, { RR = SP + u16();                     }, "LEA  u(SP), RR"   )
OP(0x6D, { RR = SP + u8();                      }, "LEA  u(SP), RR"   )
OP(0x6E, { mem[--LL] = mem[--RR];               }, "MOVE -(RR), -(LL)")
OP(0x6F, { mem[LL++] = mem[RR++];               }, "MOVE (RR)+, (LL)+")

OP(0x70, { prq = (ss)LL * (ss)RR;               }, "MUL_IS"           )
OP(0x71, { prq = (us)LL * (us)RR;               }, "MUL_IU"           )
OP(0x72, { prq = (ss)LL / (ss)RR;
           rem = (ss)LL % (ss)RR;               }, "DIV_IS"           )
OP(0x73, { prq = (us)LL / (us)RR;
           rem = (us)LL % (us)RR;               }, "DIV_IU"           )
OP(0x74, {                                      }, "MD_STP"           )
OP(0x75, { RR = prq;                            }, "MD_FIN"           )
OP(0x76, { RR = rem;                            }, "MOD_FIN"          )
OP(0x77, {                                      }, "EI"               )
OP(0x78, { PC = pop16();                        }, "RETI"             )
OP(0x79, {                                      }, "DI"               )

OP(0xA0 ... 0xAF, { RR = RR +      uquick;      }, "ADD  RR, #u"      )
OP(0xB0 ... 0xBF, { RR = RR -      uquick;      }, "SUB  RR, #u"      )
OP(0xC0 ... 0xCF, { RR =           squick;      }, "MOVE #s, RR"      )
OP(0xD0 ... 0xDF, { RR = yes(LL == squick);     }, "SEQ  LL, #s"      )
OP(0xE0 ... 0xEF, { LL =           squick;      }, "MOVE #s, LL"      )

OP(0xF4, { RR =  RR + u16();                    }, "ADD  RR, #u"      )
OP(0xF5, { RR =  RR + u8();                     }, "ADD  RU, #u"      )
OP(0xF6, { RR =  RR - u16();                    }, "SUB  RR, #u"      )
OP(0xF7, { RR =  RR - u8();                     }, "SUB  RU, #u"      )
OP(0xF8, { RR  =  s16();                        }, "MOVE #s, RR"      )
OP(0xF9, { RR  =  s8();                         }, "MOVE #s, RS"      )
OP(0xFA, { RR  =  yes(LL == s16());             }, "SEQ  LL, #s"      )
OP(0xFB, { RR  =  yes(LL == s8());              }, "SEQ  LL, #s"      )
OP(0xFC, { LL  =  s16();                        }, "MOVE #s, LL"      )
OP(0xFD, { LL  =  s8();                         }, "MOVE #s, LL"      )

default:   fprintf(log, "%4.4X: Bad Opcode 0x%2.2X\n", lpc, opc);
	   txt = "???";   done = true;
      }

   if (do_log)
      {
        fprintf(log, "%4.4X    %4.4X : ", clock, lpc);

        fprintf(log, "%2.2X ", mem[lpc]);
        if      (imm == 1)   fprintf(log, "    ");
        else if (imm == 2)   fprintf(log, "%2.2X  ", mem[lpc + 1]);
        else if (imm == 3)   fprintf(log, "%2.2X%2.2X",
                                     mem[lpc + 2], mem[lpc + 1]);
        else                 assert(0);

        fprintf(log, "   ");
        print_txt(txt, imm, mem[lpc], mem[lpc + 1], mem[lpc + 2]);

        fprintf(log, "-> SP=%4.4X (%4.4X) ", SP, _16(mem[SP+1], mem[SP]));

        fprintf(log, "LL=%4.4X ", LL);
        fprintf(log, "RR=%4.4X\n", RR);

        if (PC != lpc + imm)   fprintf(log, "\n");
      }

   if (PC > 0xA000)
      {
        fprintf(log, "Bad PC %d\n", PC);
        fclose(log);
        assert(0 && "Bad PC");
      }

   if (SP > 0xA000)
      {
        fprintf(log, "Bad SP %d\n", SP);
        fclose(log);
        assert(0 && "Bad SP");
      }

   return done;
}
//-----------------------------------------------------------------------------
void print_txt(const char * txt, int imm, us op, us l, us h)
{
int len = 0;
us hl = (h << 8) | l;

   for (; *txt; txt++)
       {
         if (*txt == 'u')
            {
              if      (imm == 1)   len += fprintf(log, "%d", op & 0x0F);
              else if (imm == 2)   len += fprintf(log, "%d", l);
              else if (imm == 3)   len += fprintf(log, "%d", hl);
              else                 assert(0);
            }
         else if (*txt == 's')
            {
              if      (imm == 1)
                 {

                   if (imm & 0x08)   len += fprintf(log, "%d", op | 0xFFFFFFF8);
                   else              len += fprintf(log, "%d", op & 0x00000007);
                 }
              else if (imm == 2)
                 {
                   if (imm & 0x80)   len += fprintf(log, "%d", l | 0xFFFFFF80);
                   else              len += fprintf(log, "%d", l & 0x0000007F);
                 }
              else if (imm == 3)   len += fprintf(log, "%d", (ss)hl);
              else                 assert(0);
            }
         else if (*txt == 'j')
            {
              if (labels[hl])   len += fprintf(log, "%s", labels[hl]);
              else              len += fprintf(log, "%X", hl);
            }
         else                    len += fprintf(log, "%c", *txt);
       }

   while (len < 28)   len += fprintf(log, " ");
}
//-----------------------------------------------------------------------------
