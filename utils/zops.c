#include "common.h"
#include "file.h"
#include "mem.h"
#include "random.h"
#include "stack.h"
#include <ctype.h>
#include "SDL.h"

#define MAX_TOKEN_LEN 256
#define USE_BIOS 1

u16 randomseed=1;

enum
{
	SrcImmediate,
	SrcVariable
};

enum
{
	Form0OP,
	Form1OP,
	Form2OP,
	FormVAR
};

static int zeroOpStoreInstructions[]={};
static int oneOpStoreInstructions[]={0x01,0x02,0x03,0x04,0x08,0x0E,0x0F};
static int twoOpStoreInstructions[]={0x08,0x09,0x0F,0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19};
static int varOpStoreInstructions[]={0x00,0x07,0x0C,0x16,0x17,0x18,0x1E};

static int zeroOpBranchInstructions[]={0x05,0x06,0x0D};
static int oneOpBranchInstructions[]={0x00,0x01,0x02};
static int twoOpBranchInstructions[]={0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x0A};
static int varOpBranchInstructions[]={0x17};
	
static char alphabetLookup[3][27]={
	{ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' },
	{ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' },
	{ ' ', '\n','0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', ',', '!', '?', '_', '#', '\'','"', '/', '\\','-', ':', '(', ')' },
};

typedef struct ZOperand_s
{
	int value;
	int src;
} ZOperand;

typedef struct ZBranch_s
{
	int offset;
	int negate;
} ZBranch;

typedef struct ZInstruction_s
{
	int op;
	int form;
	int store;
	int numOps;
	ZBranch branch;
	ZOperand operands[4];
} ZInstruction;

typedef struct ZCallStack_s
{
	int returnAddr;
	int returnStore;
	int locals[16];
	int depth;
} ZCallStack;

typedef struct ZObject_s
{
	int addr;
	int propTable;
} ZObject;

typedef struct ZProperty_s
{
	int addr;
	int size;
	int bDefault;
} ZProperty;

typedef struct ZToken_s
{
	char token[MAX_TOKEN_LEN];
	int offset;
} ZToken;
	
typedef struct ZDictEntry_s
{
	int coded[4];
	int current;
} ZDictEntry;

typedef char byte;

static ZInstruction m_ins;
static int m_pc;
static int m_globalVariables;
static int m_abbrevTable;
static int m_objectTable;
static int m_dictionaryTable;
static int m_memSize;
static int m_memOffset;
static byte *rom;
static byte *memory;
static byte *biosRAM;
static u16 *screen;
static int m_numberstack[1024];
static stack m_stack;
static ZCallStack m_callstackcontents[1024];
static stack m_callStack;

int forceDynamic=0;
int curIdx=0;
int curX=0;
int curY=0;
int winXMin=0;
int winXMax=240-1;
int winYMin=0;
int winYMax=320-1;
SDL_Window *window;
SDL_Renderer *ren;
SDL_Texture *tex;
int mouseDown=0;
int mouseX=0;
int mouseY=0;

byte ReadMem(int addr)
{
	return memory[addr+m_memOffset];
}

void WriteMem(int addr, byte val)
{
	memory[addr+m_memOffset]=val;
}

byte ReadMemDyn(int addr)
{
	if (addr>=0x10000 && forceDynamic)
		return biosRAM[addr-0x10000];
	return memory[addr+m_memOffset];
}

void displayState();

void WriteMemDyn(int addr, byte val)
{
	if (addr>=0x10000)
	{
		if (1)//forceDynamic)
			biosRAM[addr-0x10000]=val;
		else
		{
			printf("Bad write:%x (PC:%x)\n", addr, m_pc);
			displayState();
		}
	}
	else
	{
		memory[addr+m_memOffset]=val;
	}
}

int makeS16(int msb, int lsb)
{
	int ret=(msb<<8)+lsb;
	if ((ret&0x8000)!=0)
	{
		ret+=-0x10000;
	}
	return ret;
}

int makeU16(int msb, int lsb)
{
	return (msb<<8)+lsb;
}

int readBytePC()
{
	return ReadMem(m_pc++)&0xFF;
}

int readS16PC()
{
	int msb=readBytePC();
	int lsb=readBytePC();
	return makeS16(msb, lsb);
}

int readVariable(int var)
{
	if (var==0)
	{
		return *(int*)stackPop(&m_stack);
	}
	if (var<16)
	{
		return ((ZCallStack*)stackPeek(&m_callStack))->locals[var-1];
	}
	int off=2*(var-16);
	off+=m_globalVariables;
	return makeS16(ReadMem(off)&0xFF, ReadMem(off+1)&0xFF); 
}

void setVariable(int var, int value)
{
	value&=0xFFFF;
	if ((value&0x8000)!=0)
	{
		value+=-0x10000;
	}
	if (var==0)
	{
		*(int*)stackPush(&m_stack)=value;
		return;
	}
	if (var<16)
	{
		((ZCallStack*)stackPeek(&m_callStack))->locals[var-1]=value;
		return;
	}
	int off=2*(var-16);
	off+=m_globalVariables;
	WriteMem(off+0,(byte)((value&0xFF00)>>8));
	WriteMem(off+1,(byte)((value&0x00FF)>>0)); 
}

void setVariableIndirect(int var, int value)
{
	if (var==0)
	{
		stackPop(&m_stack);
	}
	setVariable(var, value);
}

int readVariableIndirect(int var)
{
	int ret=readVariable(var);
	if (var==0)
	{
		setVariable(var, ret);
	}
	return ret;
}

ZObject getObject(int id)
{
	ZObject ret;
	ret.addr=m_objectTable+2*31+9*(id-1);
	ret.propTable=makeU16(ReadMem(ret.addr+7)&0xFF, ReadMem(ret.addr+8)&0xFF);
	return ret;
}

ZProperty getProperty(ZObject obj, int id)
{
	ZProperty ret;
	int address=obj.propTable;
	int textLen=ReadMem(address++)&0xFF;
	address+=textLen*2;
	while (ReadMem(address)!=0)
	{
		int sizeId=ReadMem(address++)&0xFF;
		int size=1+(sizeId>>5);
		int propId=sizeId&31;
		if (propId==id)
		{
			ret.addr=address;
			ret.size=size;
			ret.bDefault=FALSE;
			return ret;
		}
		address+=size;
	}
	ret.addr=(m_objectTable+(id-1)*2)&0xFFFF;
	ret.size=2;
	ret.bDefault=TRUE;
	return ret;
}

void returnRoutine(int value)
{
	ZCallStack *cs=stackPop(&m_callStack);
	while (cs->depth<stackDepth(&m_stack))
	{
		readVariable(0);
	}
	if (cs->returnStore>=0)
	{
		setVariable(cs->returnStore, value);
	}
	m_pc=cs->returnAddr;
	if (cs->returnStore==-2)
	{
		returnRoutine(1);
	}
}

void doBranch(int cond, ZBranch branch)
{
	if (branch.negate)
	{
		cond=!cond;
	}
	if (cond)
	{
		if (branch.offset==0)
			returnRoutine(0);
		else if (branch.offset==1)
			returnRoutine(1);
		else
			m_pc+=branch.offset-2;
	}
}

void readOperand(int operandType)
{
	if (operandType==3) //omitted
	{
		return;
	}
	ZOperand *operand = &m_ins.operands[m_ins.numOps++];
	switch (operandType)
	{
		case 0: // long constant
			operand->value = readS16PC();
			operand->src = SrcImmediate;
			break;
		case 1: // small constant
			operand->value = readBytePC();
			operand->src = SrcImmediate;
			break;
		case 2: // variable
			operand->value = readVariable(readBytePC());
			operand->src = SrcVariable;
			break;
	}
}

void readShortForm(int opcode)
{
	int operand=(opcode>>4)&3;
	int op=opcode&15;
	m_ins.op=op;
	if (operand==3)
		m_ins.form=Form0OP;
	else
		m_ins.form=Form1OP;
	readOperand(operand);
}

void readLongForm(int opcode)
{
	int op=opcode&31;
	m_ins.op=op;
	m_ins.form=Form2OP;
	readOperand(((opcode&(1<<6))!=0)?2:1);
	readOperand(((opcode&(1<<5))!=0)?2:1);
}

void readVariableForm(int opcode)
{
	int op=opcode&31;
	int operandTypes=readBytePC();
	int i;
	m_ins.op=op;
	if ((opcode&0xF0)>=0xE0)
		m_ins.form=FormVAR;
	else
		m_ins.form=Form2OP;
	for (i=3; i>=0; i--)
	{
		readOperand((operandTypes>>(2*i))&3);
	}
}

int readStoreInstruction(int *match, int length, int op)
{
	int i;
	for (i=0; i<length; i++)
	{
		if (op==match[i])
		{
			return readBytePC();
		}
	}
	return -1;
}

ZBranch readBranchInstruction(int *match, int length, int op)
{
	ZBranch ret;
	int i;
	for (i=0; i<length; i++)
	{
		if (op==match[i])
		{
			int branch1=readBytePC();
			if ((branch1&(1<<6))==0)
			{
				int branch2=readBytePC();
				int offset=((branch1&63)<<8)+branch2;
				if ((offset&(1<<13))!=0)
				{
					offset+=-(1<<14);
				}
				ret.offset=offset;
				ret.negate=((branch1&0x80)==0);
				return ret;
			}
			else
			{
				ret.offset=branch1&63;
				ret.negate=((branch1&0x80)==0);
				return ret;
			}
		}
	}
	ret.offset=0;
	ret.negate=FALSE;
	return ret;
}

void callRoutine(int address, int returnStore, int setOperands)
{
	if (address==0)
	{
		setVariable(returnStore, 0);
	}
	else
	{
		int numLocals=ReadMem(address++)%0xFF;
		int i;
		ZCallStack cs;
		cs.returnAddr=m_pc;
		cs.returnStore=returnStore;
		for (i=0; i<numLocals; i++)
		{
			cs.locals[i]=makeS16(ReadMem(address)&0xFF, ReadMem(address+1)&0xFF);
			address+=2;
		}
		if (setOperands)
		{
			for (i=0; i<m_ins.numOps-1; i++)
			{
				cs.locals[i]=m_ins.operands[i+1].value;
			}
		}
		cs.depth=stackDepth(&m_stack);
		m_pc=address;
		*(ZCallStack*)stackPush(&m_callStack)=cs;
	}
}

void callBIOS(int id, int doubleReturn)
{
	int addr=0x1E58B+5*id;
	callRoutine(2*makeU16(ReadMem(addr)&0xFF,ReadMem(addr+1)&0xFF), doubleReturn?-2:-1, TRUE);
}

void displayState()
{
	int i;
	printf("Next PC:%x\n", m_pc);
	printf("Form:%d Opcode:%d\n", m_ins.form, m_ins.op);
	printf("Num operands: %d\n", m_ins.numOps);
	for (i=0; i<m_ins.numOps; i++)
	{
		printf("Value:%d Src:%d\n", m_ins.operands[i].value, m_ins.operands[i].src); 
	}
	printf("Store:%d Branch:%d %s\n", m_ins.store, m_ins.branch.offset, (m_ins.branch.negate?" Negated":" Normal"));
}

void dumpCurrentInstruction()
{
	int i;
	for (i=0; i<m_ins.numOps; i++)
	{ 
		printf("Arg:%d Value:%d\n", i, (m_ins.operands[i].value&0xFFFF));
	}
}

void haltInstruction()
{
	printf("\n\nUnimplemented instruction!\n");
	displayState();
	exit(1);
}

void illegalInstruction()
{
	printf("\n\nIllegal instruction!\n");
	displayState();
	exit(1);
}

int printText(int address)
{
	int pair1=0, pair2=0;
	int alphabet=0;
	int characters[3];
	int abbrNext=FALSE;
	int longNext=0;
	int longChar=0;
	int abbrChar=0;
	while ((pair1&0x80)==0)
	{
		int i;
		pair1=ReadMem(address++)&0xFF;
		pair2=ReadMem(address++)&0xFF;
		characters[0]=(pair1&0x7C)>>2;
		characters[1]=((pair1&3)<<3) + ((pair2&0xE0)>>5);
		characters[2]=pair2&0x1F;
		for (i=0; i<3; i++)
		{
			if (longNext>0)
			{
				longChar<<=5;
				longChar&=0x3FF;
				longChar|=characters[i];
				longNext--;
				if (longNext==0)
				{
					printf("%c", (char)longChar);
				}
			}
			else if (!abbrNext)
			{
				if (characters[i]==6 && alphabet==2)
				{
					longNext=2;
				}
				else if (characters[i]>=6)
				{
					characters[i]-=6;
					printf("%c", alphabetLookup[alphabet][characters[i]]);
					alphabet=0;
				}
				else if (characters[i]==4)
				{
					alphabet=1;
				}
				else if (characters[i]==5)
				{
					alphabet=2;
				}
				else if (characters[i]==0)
				{
					printf(" ");
				}
				else
				{
					abbrChar=characters[i];
					abbrNext=TRUE;
				}
			}
			else
			{
				int idx=32*(abbrChar-1)+characters[i];
				int abbrevTable=m_abbrevTable+2*idx;
				int abbrevAddress=makeU16(ReadMem(abbrevTable)&0xFF, ReadMem(abbrevTable+1)&0xFF);
				printText(2*abbrevAddress);
				abbrNext=FALSE;
			}
		}
	}
	return address;
}

void removeObject(int childId)
{
	ZObject child=getObject(childId);
	int parentId=ReadMem(child.addr+4)&0xFF;
	if (parentId!=0)
	{
		ZObject parent=getObject(parentId);
		if ((ReadMem(parent.addr+6)&0xFF)==childId)
		{
			WriteMem(parent.addr+6,ReadMem(child.addr+5)); // parent.child=child.sibling
		}
		else
		{
			int siblingId=ReadMem(parent.addr+6)&0xFF;
			while (siblingId!=0)
			{
				ZObject sibling=getObject(siblingId);
				int nextSiblingId=ReadMem(sibling.addr+5)&0xFF;
				if (nextSiblingId==childId)
				{
					WriteMem(sibling.addr+5,ReadMem(child.addr+5)); // sibling.sibling=child.sibling
					break;
				}
				siblingId=nextSiblingId;
			}
			if (siblingId==0)
			{
				illegalInstruction();
			}
		}
		WriteMem(child.addr+4,0);
		WriteMem(child.addr+5,0);
	}
}

void addChild(int parentId, int childId)
{
	ZObject child=getObject(childId);
	ZObject parent=getObject(parentId);
	WriteMem(child.addr+5,ReadMem(parent.addr+6)); // child.sibling=parent.child
	WriteMem(child.addr+4,(byte)parentId); // child.parent=parent
	WriteMem(parent.addr+6,(byte)childId); // parent.child=child
}

void zDictInit(ZDictEntry *entry)
{
	entry->current=0;
	entry->coded[0]=0;
	entry->coded[1]=0;
	entry->coded[2]=0x80;
	entry->coded[3]=0;
}

void zDictAddCharacter(ZDictEntry *entry, int code)
{
	code&=31;
	switch (entry->current)
	{
		case 0: entry->coded[0]|=code<<2; break;
		case 1: entry->coded[0]|=code>>3; entry->coded[1]|=(code<<5)&0xFF; break;
		case 2: entry->coded[1]|=code; break;
		case 3: entry->coded[2]|=code<<2; break;
		case 4: entry->coded[2]|=code>>3; entry->coded[3]|=(code<<5)&0xFF; break;
		case 5: entry->coded[3]|=code; break;
	}
	entry->current++;
}

ZDictEntry encodeToken(char* token)
{
	ZDictEntry ret;
	int tokenLen=strlen(token);
	int t;
	zDictInit(&ret);
	for (t=0; t<tokenLen; t++)
	{
		char curChar = token[t];
		int alphabet=-1;
		int code=-1;
		int a;
		for (a=0; a<3 && alphabet==-1; a++)
		{
			int i;
			for (i=0; i<27; i++)
			{
				if (curChar == alphabetLookup[a][i])
				{
					alphabet=a;
					code=i;
					break;
				}
			}
		}
		if (alphabet==-1)
		{
			zDictAddCharacter(&ret, 5);
			zDictAddCharacter(&ret, 6);
			zDictAddCharacter(&ret, curChar>>5);
			zDictAddCharacter(&ret, curChar&31);
		}
		else
		{
			if (alphabet>0)
			{
				int shift=alphabet+3;
				zDictAddCharacter(&ret, shift);
			}
			zDictAddCharacter(&ret, code+6);
		}
	}
	for (t=0; t<6; t++) // pad
	{
		zDictAddCharacter(&ret, 5);
	}
	return ret;
}

int getDictionaryAddress(char* token, int dictionary)
{
	int entryLength = ReadMem(dictionary++)&0xFF;
	int numEntries = makeU16(ReadMem(dictionary+0)&0xFF, ReadMem(dictionary+1)&0xFF);
	ZDictEntry zde = encodeToken(token);
	int i;
	dictionary+=2;
	for (i=0; i<numEntries; i++)
	{
		if (zde.coded[0]==(ReadMem(dictionary+0)&0xFF) && zde.coded[1]==(ReadMem(dictionary+1)&0xFF)
				&& zde.coded[2]==(ReadMem(dictionary+2)&0xFF) && zde.coded[3]==(ReadMem(dictionary+3)&0xFF))
		{
			return dictionary;
		}
		dictionary+=entryLength;
	}
	return 0;
}

int lexicalAnalysis(char* input, int parseBuffer, int maxEntries)
{
	static ZToken tokens[256];
	static char seps[256];
	int numTokens=0;
	int dictionaryAddress=m_dictionaryTable;
	int numSeperators=ReadMem(dictionaryAddress++);
	char *current=input;
	char *end=input+strlen(current);
	int i;
	for (i=0; i<numSeperators; i++)
	{
		seps[i]=(char)ReadMem(dictionaryAddress++);
	}
	while (current!=end)
	{
		char *space=strchr(current, ' ');
		char *min=end;
		int sepFound=FALSE;
		int tokLen;
		if (space==current)
		{
			current++;
			continue;
		}
		else if (space)
		{
			min=space;
		}
		for (i=0; i<numSeperators; i++)
		{
			char *sep=strchr(current, seps[i]);
			if (sep==current)
			{
				tokens[numTokens].offset=current-input;
				tokens[numTokens].token[0]=*current;
				tokens[numTokens].token[1]='\0';
				numTokens++;
				current++;
				sepFound=TRUE;
				break;
			}
			else if (sep && sep<min)
			{
				min=sep;
			}
		}
		if (sepFound)
		{
			continue;
		}

		tokens[numTokens].offset=(int)(current-input);
		tokLen=MIN(min-current, MAX_TOKEN_LEN-1);
		strncpy(tokens[numTokens].token, current, tokLen);
		tokens[numTokens].token[tokLen]='\0';
		numTokens++;
		current=min;
	}

	for (i=0; i<numTokens && i<maxEntries; i++)
	{
		int outAddress=getDictionaryAddress(tokens[i].token, dictionaryAddress);
		WriteMem(parseBuffer++,(byte)((outAddress>>8)&0xFF));
		WriteMem(parseBuffer++,(byte)((outAddress>>0)&0xFF));
		WriteMem(parseBuffer++,(byte)strlen(tokens[i].token));
		WriteMem(parseBuffer++,(byte)(tokens[i].offset+1));
	}

	return MIN(maxEntries, numTokens);
}

void restart()
{
	memcpy(memory, rom, m_memSize);
	memset(biosRAM, 0, 0x10000);
	ASSERT(ReadMem(0)==3);
	m_globalVariables=makeU16(ReadMem(0xC)&0xFF, ReadMem(0xD)&0xFF);
	m_abbrevTable=makeU16(ReadMem(0x18)&0xFF, ReadMem(0x19)&0xFF);
	m_objectTable=makeU16(ReadMem(0xA)&0xFF, ReadMem(0xB)&0xFF);
	m_dictionaryTable=makeU16(ReadMem(0x8)&0xFF, ReadMem(0x9)&0xFF);
	m_pc=makeU16(ReadMem(6)&0xFF, ReadMem(7)&0xFF);
	//WriteMem(1,ReadMem(1)|(1<<4)); // status line not available
	//WriteMem(1,ReadMem(1)&~(1<<5)); // screen splitting available
	//WriteMem(1,ReadMem(1)&~(1<<6)); // variable pitch font
	//WriteMem(0x10,ReadMem(0x10)|(1<<0)); // transcripting
	//WriteMem(0x10,ReadMem(0x10)|(1<<1)); // fixed font
	stackInit(&m_stack, m_numberstack, sizeof(m_numberstack[0]), ARRAY_SIZEOF(m_numberstack));
	stackInit(&m_callStack, m_callstackcontents, sizeof(m_callstackcontents[0]), ARRAY_SIZEOF(m_callstackcontents));
#if USE_BIOS
	callBIOS(0,FALSE);
#endif
}

void process0OPInstruction()
{
	switch (m_ins.op)
	{
		case 0: //rtrue
			returnRoutine(1);
			break;
		case 1: //rfalse
			returnRoutine(0);
			break;
		case 2: //print
			{
#if !USE_BIOS
				m_pc=printText(m_pc);
#else
				int origAddr=m_pc;
				while (!(ReadMem(m_pc)&0x80))
				{
					m_pc+=2;
				}
				m_pc+=2;
				m_ins.operands[1].value=origAddr&1;
				m_ins.operands[2].value=origAddr>>1;
				m_ins.numOps=3;
				callBIOS(1,FALSE);
#endif
				break;
			}
		case 3: //print_ret
			{
#if !USE_BIOS
				m_pc=printText(m_pc);
				printf("\n");
				returnRoutine(1);
#else
				int origAddr=m_pc;
				while (!(ReadMem(m_pc)&0x80))
				{
					m_pc+=2;
				}
				m_pc+=2;
				m_ins.operands[1].value=(origAddr&1)|2;
				m_ins.operands[2].value=origAddr>>1;
				m_ins.numOps=3;
				callBIOS(1,TRUE);
#endif
				break;
			}
		case 4: //nop
			break;
		case 5: //save
			doBranch(FALSE, m_ins.branch);
			break;
		case 6: //restore
			doBranch(FALSE, m_ins.branch);
			break;
		case 7: //restart
			restart();
			break;
		case 8: //ret_popped
			returnRoutine(*(int*)stackPop(&m_stack));
			break;
		case 9: //pop
			stackPop(&m_stack);
			break;
		case 0xA: //quit
#if !USE_BIOS
			haltInstruction();
#else
			callBIOS(6,FALSE);
#endif
			break;
		case 0xB: //new_line
#if !USE_BIOS
			printf("\n");
#else
			m_ins.operands[1].value='\n';
			m_ins.numOps=2;
			callBIOS(2,FALSE);
#endif
			break;
		case 0xC: //show_status
#if !USE_BIOS
			haltInstruction();
#else
			callBIOS(5,FALSE);
#endif
			break;
		case 0xD: //verify
			doBranch(TRUE, m_ins.branch);
			break;
		case 0xE: //extended
			illegalInstruction();
			break;
		case 0xF: //piracy
//			doBranch(TRUE, m_ins.branch);
			forceDynamic=1;
			break;
	}
}

void process1OPInstruction()
{
	switch (m_ins.op)
	{
		case 0: //jz
			doBranch(m_ins.operands[0].value==0, m_ins.branch);
			break;
		case 1: //get_sibling
			{
				ZObject child=getObject(m_ins.operands[0].value);
				int siblingId=ReadMem(child.addr+5)&0xFF;
				setVariable(m_ins.store, siblingId);
				doBranch(siblingId!=0, m_ins.branch);
				break;
			}
		case 2: //get_child
			{
				ZObject child=getObject(m_ins.operands[0].value);
				int childId=ReadMem(child.addr+6)&0xFF;
				setVariable(m_ins.store, childId);
				doBranch(childId!=0, m_ins.branch);
				break;
			}
		case 3: //get_parent_object
			{
				ZObject child=getObject(m_ins.operands[0].value);
				setVariable(m_ins.store, ReadMem(child.addr+4)&0xFF);
				break;
			}
		case 4: //get_prop_len
			{
				int propAddress=(m_ins.operands[0].value&0xFFFF)-1;
				int sizeId=ReadMem(propAddress)&0xFF;
				int size=(sizeId>>5)+1;
				setVariable(m_ins.store, size);
				break;
			}
		case 5: //inc
			{
				int value=readVariable(m_ins.operands[0].value);
				setVariable(m_ins.operands[0].value, value+1);
				break;
			}
		case 6: //dec
			{
				int value=readVariable(m_ins.operands[0].value);
				setVariable(m_ins.operands[0].value, value-1);
				break;
			}	
		case 7: //print_addr
#if !USE_BIOS
			printText(m_ins.operands[0].value);
#else
			m_ins.operands[1].value=m_ins.operands[0].value&1;
			m_ins.operands[2].value=m_ins.operands[0].value>>1;
			m_ins.numOps=3;
			callBIOS(1,FALSE);
#endif
			break;
		case 8: //call_1s
			m_memOffset=(m_ins.operands[0].value&3)*0x20000;
			restart();
			break;
		case 9: //remove_obj
			{
				removeObject(m_ins.operands[0].value);
				break;
			}
		case 0xA: //print_obj
			{
#if !USE_BIOS
				ZObject obj=getObject(m_ins.operands[0].value);
				printText(obj.propTable+1);
#else
				ZObject obj=getObject(m_ins.operands[0].value);
				m_ins.operands[1].value=(obj.propTable+1)&1;
				m_ins.operands[2].value=(obj.propTable+1)>>1;
				m_ins.numOps=3;
				callBIOS(1,FALSE);
#endif
				break;
			}
		case 0xB: //ret
			returnRoutine(m_ins.operands[0].value);
			break;
		case 0xC: //jump
			m_pc+=m_ins.operands[0].value-2;
			break;
		case 0xD: //print_paddr
#if !USE_BIOS
			printText(2*(m_ins.operands[0].value&0xFFFF));
#else
			m_ins.operands[1].value=0;
			m_ins.operands[2].value=m_ins.operands[0].value;
			m_ins.numOps=3;
			callBIOS(1,FALSE);
#endif
			break;
		case 0xE: //load
			setVariable(m_ins.store, readVariableIndirect(m_ins.operands[0].value));
			break;
		case 0xF: //not
			setVariable(m_ins.store, ~m_ins.operands[0].value);
			break;
	}
}

void process2OPInstruction()
{
	switch (m_ins.op)
	{
		case 0:
			illegalInstruction();
			break;
		case 1: //je
			{
				int takeBranch=FALSE;
				int test=m_ins.operands[0].value;
				int i;
				for (i=1; i<m_ins.numOps; i++)
				{
					if (test==m_ins.operands[i].value)
					{
						takeBranch=TRUE;
						break;
					}
				}
				doBranch(takeBranch, m_ins.branch);
				break;
			}
		case 2: //jl
			doBranch(m_ins.operands[0].value<m_ins.operands[1].value, m_ins.branch);
			break;
		case 3: //jg
			doBranch(m_ins.operands[0].value>m_ins.operands[1].value, m_ins.branch);
			break;
		case 4: //dec_chk
			{
				int value=readVariable(m_ins.operands[0].value);
				value--;
				setVariable(m_ins.operands[0].value, value);
				doBranch(value<m_ins.operands[1].value, m_ins.branch);
				break;
			}	
		case 5: //inc_chk
			{
				int value=readVariable(m_ins.operands[0].value);
				value++;
				setVariable(m_ins.operands[0].value, value);
				doBranch(value>m_ins.operands[1].value, m_ins.branch);
				break;
			}
		case 6: //jin
			{
				ZObject child=getObject(m_ins.operands[0].value);
				doBranch((ReadMem(child.addr+4)&0xFF)==m_ins.operands[1].value, m_ins.branch);
				break;
			}
		case 7: //test
			{
				int flags=m_ins.operands[1].value;
				doBranch((m_ins.operands[0].value&flags)==flags, m_ins.branch);
				break;
			}
		case 8: //or
			setVariable(m_ins.store, m_ins.operands[0].value|m_ins.operands[1].value);
			break;
		case 9: //and
			setVariable(m_ins.store, m_ins.operands[0].value&m_ins.operands[1].value);
			break;
		case 0xA: //test_attr
			{
				ZObject obj=getObject(m_ins.operands[0].value);
				int attr=m_ins.operands[1].value;
				int offset=attr/8;
				int bit=0x80>>(attr%8);
				doBranch((ReadMem(obj.addr+offset)&bit)==bit, m_ins.branch);
				break;
			}
		case 0xB: //set_attr
			{
				ZObject obj=getObject(m_ins.operands[0].value);
				int attr=m_ins.operands[1].value;
				int offset=attr/8;
				int bit=0x80>>(attr%8);
				WriteMem(obj.addr+offset,ReadMem(obj.addr+offset)|bit);
				break;
			}
		case 0xC: //clear_attr
			{
				ZObject obj=getObject(m_ins.operands[0].value);
				int attr=m_ins.operands[1].value;
				int offset=attr/8;
				int bit=0x80>>(attr%8);
				WriteMem(obj.addr+offset,ReadMem(obj.addr+offset)&~bit);
				break;
			}
		case 0xD: //store
			setVariableIndirect(m_ins.operands[0].value, m_ins.operands[1].value);
			break;
		case 0xE: //insert_obj
			{
				removeObject(m_ins.operands[0].value);
				addChild(m_ins.operands[1].value, m_ins.operands[0].value);
				break;
			}
		case 0xF: //loadw
			{
				int address=((m_ins.operands[0].value&0xFFFF)+2*(m_ins.operands[1].value&0xFFFF));
				setVariable(m_ins.store, makeS16(ReadMemDyn(address)&0xFF, ReadMemDyn(address+1)&0xFF));
				forceDynamic=0;
				break;
			}
		case 0x10: //loadb
			{
				int address=((m_ins.operands[0].value&0xFFFF)+(m_ins.operands[1].value&0xFFFF));
				setVariable(m_ins.store, ReadMemDyn(address)&0xFF);
				forceDynamic=0;
				break;
			}
		case 0x11: //get_prop
			{
				ZObject obj=getObject(m_ins.operands[0].value);
				ZProperty prop=getProperty(obj, m_ins.operands[1].value);
				if (prop.size==1)
				{
					setVariable(m_ins.store, ReadMem(prop.addr)&0xFF);
				}
				else if (prop.size==2)
				{
					setVariable(m_ins.store, makeS16(ReadMem(prop.addr)&0xFF, ReadMem(prop.addr+1)&0xFF));
				}
				else
				{
					illegalInstruction();
				}
				break;
			}
		case 0x12: //get_prop_addr
			{
				ZObject obj=getObject(m_ins.operands[0].value);
				ZProperty prop=getProperty(obj, m_ins.operands[1].value);
				if (prop.bDefault)
					setVariable(m_ins.store, 0);
				else
					setVariable(m_ins.store, prop.addr);
				break;
			}
		case 0x13: //get_next_prop
			{
				ZObject obj=getObject(m_ins.operands[0].value);
				if (m_ins.operands[1].value==0)
				{
					int address=obj.propTable;
					int textLen=ReadMem(address++)&0xFF;
					address+=textLen*2;
					int nextSizeId=ReadMem(address)&0xFF;
					setVariable(m_ins.store, nextSizeId&31);
				}
				else
				{
					ZProperty prop=getProperty(obj, m_ins.operands[1].value);
					if (prop.bDefault)
					{
						illegalInstruction();
					}
					else
					{
						int nextSizeId=ReadMem(prop.addr+prop.size)&0xFF;
						setVariable(m_ins.store, nextSizeId&31);
					}
				}
				break;
			}
		case 0x14: //add
			setVariable(m_ins.store, m_ins.operands[0].value+m_ins.operands[1].value);
			break;
		case 0x15: //sub
			setVariable(m_ins.store, m_ins.operands[0].value-m_ins.operands[1].value);
			break;
		case 0x16: //mul
			setVariable(m_ins.store, m_ins.operands[0].value*m_ins.operands[1].value);
			break;
		case 0x17: //div
			setVariable(m_ins.store, m_ins.operands[0].value/m_ins.operands[1].value);
			break;
		case 0x18: //mod
			setVariable(m_ins.store, m_ins.operands[0].value%m_ins.operands[1].value);
			break;
		case 0x19: //call_2s
			illegalInstruction();
			break;
		case 0x1A: //call_2n
			illegalInstruction();
			break;
		case 0x1B: //set_colour
			illegalInstruction();
			break;
		case 0x1C: //throw
			illegalInstruction();
			break;
		case 0x1D:
			illegalInstruction();
			break;
		case 0x1E:
			//printf("WriteReg: %04x %04x\n", m_ins.operands[0].value&0xFFFF, m_ins.operands[1].value&0xFFFF);
			if (m_ins.operands[0].value==0x22)
			{
				screen[curIdx%(320*240)]=m_ins.operands[1].value;
				curIdx++;
				curX++;
				if (curX>winXMax)
				{
					curX=winXMin;
					curY++;
					if (curY>winYMax)
					{
						curY=winYMin;
					}
					curIdx=curY*240+curX;
				}
			}
			else if (m_ins.operands[0].value==0x20)
			{
				curX=m_ins.operands[1].value;
				curIdx=curY*240+curX;
			}
			else if (m_ins.operands[0].value==0x21)
			{
				curY=m_ins.operands[1].value;
				curIdx=curY*240+curX;
			}
			else if (m_ins.operands[0].value==0x50)
			{
				winXMin=m_ins.operands[1].value;
			}
			else if (m_ins.operands[0].value==0x51)
			{
				winXMax=m_ins.operands[1].value;
			}
			else if (m_ins.operands[0].value==0x52)
			{
				winYMin=m_ins.operands[1].value;
			}
			else if (m_ins.operands[0].value==0x53)
			{
				winYMax=m_ins.operands[1].value;
			}
			else if (m_ins.operands[0].value==7)
			{
				SDL_UpdateTexture(tex, NULL, screen, 240*sizeof(screen[0]));
				SDL_RenderClear(ren);
				SDL_RenderCopy(ren, tex, NULL, NULL);
				SDL_RenderPresent(ren);
				SDL_Delay(1);
			}
			break;
		case 0x1F:
			illegalInstruction();
			break;
	}
}

void processVARInstruction()
{
	switch (m_ins.op)
	{
		case 0: // call
			callRoutine(2*(m_ins.operands[0].value&0xFFFF), m_ins.store, TRUE);
			break;
		case 1: //storew
			{
				int address=((m_ins.operands[0].value&0xFFFF)+2*(m_ins.operands[1].value&0xFFFF));
				int value=m_ins.operands[2].value;
				WriteMemDyn(address,(byte)((value>>8)&0xFF));
				WriteMemDyn(address+1,(byte)(value&0xFF));
				forceDynamic=0;
				break;
			}
		case 2: //storeb
			{
				int address=((m_ins.operands[0].value&0xFFFF)+(m_ins.operands[1].value&0xFFFF));
				int value=m_ins.operands[2].value;
				WriteMemDyn(address,(byte)(value&0xFF));
				forceDynamic=0;
				break;
			}
		case 3: //put_prop
			{
				ZObject obj=getObject(m_ins.operands[0].value);
				ZProperty prop=getProperty(obj, m_ins.operands[1].value);
				if (!prop.bDefault)
				{
					if (prop.size==1)
					{
						WriteMem(prop.addr,(byte)(m_ins.operands[2].value&0xFF));
					}
					else if (prop.size==2)
					{
						WriteMem(prop.addr+0,(byte)((m_ins.operands[2].value>>8)&0xFF));
						WriteMem(prop.addr+1,(byte)(m_ins.operands[2].value&0xFF));
					}
				}
				else
				{
					illegalInstruction();
				}
				break;
			}
		case 4: //sread
			{
#if !USE_BIOS
				static char input[4096];
				int bufferAddr=m_ins.operands[0].value;
				int parseAddr=m_ins.operands[1].value;
				int maxLength=ReadMem(bufferAddr++)&0xFF;
				int maxParse=ReadMem(parseAddr++)&0xFF;
				int realInLen=0;
				int inLen;
				int i;
				fgets(input, sizeof(input), stdin);
				inLen=strlen(input);
				for (i=0; i<inLen && i<maxLength; i++)
				{
					if (input[i]!='\r' && input[i]!='\n')
					{
						input[realInLen++]=tolower(input[i]);
						WriteMem(bufferAddr++,(byte)input[i]);
					}
				}
				input[realInLen]='\0';
				WriteMem(bufferAddr++,0);
				WriteMem(parseAddr,(byte)lexicalAnalysis(input, parseAddr+1, maxParse));
#else
				m_ins.operands[2].value=m_ins.operands[0].value;
				m_ins.numOps=3;
				callBIOS(4,FALSE);
#endif
				break;
			}
		case 5: //print_char
#if !USE_BIOS
			printf("%c", (char)m_ins.operands[0].value);
#else
			m_ins.operands[1].value=m_ins.operands[0].value;
			m_ins.numOps=2;
			callBIOS(2,FALSE);
#endif
			break;
		case 6: //print_num
#if !USE_BIOS
			printf("%d", m_ins.operands[0].value);
#else
			m_ins.operands[1].value=m_ins.operands[0].value;
			m_ins.numOps=2;
			callBIOS(3,FALSE);
#endif
			break;
		case 7: //random
			{
				int maxValue=m_ins.operands[0].value;
				int ret=0;
				if (maxValue>0)
				{
					randomseed=randomseed^(randomseed<<13);
					randomseed=randomseed^(randomseed>>9);
					randomseed=randomseed^(randomseed<<7);
					ret=((randomseed&0x7FFF)%(maxValue))+1;
				}
				else if (maxValue<0)
				{
					randomseed=maxValue;
				}
				setVariable(m_ins.store, ret);
				break;
			}
		case 8: //push
			setVariable(0, m_ins.operands[0].value);
			break;
		case 9: //pull
			setVariableIndirect(m_ins.operands[0].value, readVariable(0));
			break;
		case 0xA: //split_window
			haltInstruction();
			break;
		case 0xB: //set_window
			haltInstruction();
			break;
		case 0xC: //call_vs2
			illegalInstruction();
			break;
		case 0xD: //erase_window
			illegalInstruction();
			break;
		case 0xE: //erase_line
			illegalInstruction();
			break;
		case 0xF: //set_cursor
			illegalInstruction();
			break;
		case 0x10: //get_cursor
			illegalInstruction();
			break;
		case 0x11: //set_text_style
			illegalInstruction();
			break;
		case 0x12: //buffer_mode
			illegalInstruction();
			break;
		case 0x13: //output_stream
			haltInstruction();
			break;
		case 0x14: //input_stream
			haltInstruction();
			break;
		case 0x15: //sound_effect
			haltInstruction();
			break;
		case 0x16: //read_char
			illegalInstruction();
			break;
		case 0x17: //scan_table
			illegalInstruction();
			break;
		case 0x18: //not
			illegalInstruction();
			break;
		case 0x19: //call_vn
			illegalInstruction();
			break;
		case 0x1A: //call_vn2
			illegalInstruction();
			break;
		case 0x1B: //tokenise
			illegalInstruction();
			break;
		case 0x1C: //encode_text
			illegalInstruction();
			break;
		case 0x1D: //copy_table
			illegalInstruction();
			break;
		case 0x1E: //print_table
			{
				//			printf("GetTouch: %04x\n", m_ins.operands[0].value);
				SDL_Event e;
				while (SDL_PollEvent(&e))
				{
					if (e.type == SDL_QUIT)
						exit(1);
					else if (e.type == SDL_MOUSEBUTTONDOWN)
						mouseDown=1;
					else if (e.type == SDL_MOUSEBUTTONUP)
						mouseDown=0;
					else if (e.type == SDL_MOUSEMOTION)
					{
						SDL_MouseMotionEvent *mm=(SDL_MouseMotionEvent*)&e;
						mouseX=mm->x;
						mouseY=mm->y;
					}
				}
				if (m_ins.operands[0].value==0x93) // touching?
					setVariable(m_ins.store, mouseDown?0:1024);
				else if (m_ins.operands[0].value==0x95) // X
				{
					float m=(840.0f-170.0f)/(216.0f-23.0f);
					float c=840.0f-216.0f*m;
					float v=mouseX*m+c;
					setVariable(m_ins.store, (int)MIN(MAX(v,0),1023));
				}
				else if (m_ins.operands[0].value==0x1A) // Y
				{
					float m=(870.0f-720.0f)/(302.0f-243.0f);
					float c=870.0f-302.0f*m;
					float v=mouseY*m+c;
					setVariable(m_ins.store, (int)MIN(MAX(v,0),1023));
				}
				else
					setVariable(m_ins.store, 0);
				break;
			}
		case 0x1F: //check_arg_count
			{
				int i;
				//printf("Blit: %04x %04x %04x %04x\n", m_ins.operands[0].value&0xFFFF, m_ins.operands[1].value&0xFFFF, m_ins.operands[2].value&0xFFFF, m_ins.operands[3].value&0xFFFF);
				forceDynamic=1;
				for (i=0; i<(m_ins.operands[1].value&0xFFFF); i++)
				{
					byte data=ReadMemDyn(2*(m_ins.operands[0].value&0xFFFF)+i);
					screen[curIdx%(320*240)]=(data&0x80)?m_ins.operands[3].value:m_ins.operands[2].value;
					curIdx++;
					screen[curIdx%(320*240)]=(data&0x40)?m_ins.operands[3].value:m_ins.operands[2].value;
					curIdx++;
					screen[curIdx%(320*240)]=(data&0x20)?m_ins.operands[3].value:m_ins.operands[2].value;
					curIdx++;
					screen[curIdx%(320*240)]=(data&0x10)?m_ins.operands[3].value:m_ins.operands[2].value;
					curIdx++;
					screen[curIdx%(320*240)]=(data&0x08)?m_ins.operands[3].value:m_ins.operands[2].value;
					curIdx++;                         
					screen[curIdx%(320*240)]=(data&0x04)?m_ins.operands[3].value:m_ins.operands[2].value;
					curIdx++;                         
					screen[curIdx%(320*240)]=(data&0x02)?m_ins.operands[3].value:m_ins.operands[2].value;
					curIdx++;                         
					screen[curIdx%(320*240)]=(data&0x01)?m_ins.operands[3].value:m_ins.operands[2].value;
					curIdx++;
					curX+=8;
					if (curX>winXMax)
					{
						curX=winXMin;
						curY++;
						if (curY>winYMax)
						{
							curY=winYMin;
						}
						curIdx=curY*240+curX;
					}
				}
				SDL_UpdateTexture(tex, NULL, screen, 240*sizeof(screen[0]));
				SDL_RenderClear(ren);
				SDL_RenderCopy(ren, tex, NULL, NULL);
				SDL_RenderPresent(ren);
				SDL_Delay(1);
				forceDynamic=0;
				break;
			}
	}
}

void executeInstruction()
{
	m_ins.numOps=0;
	//printf("\nPC:%05x ", m_pc);
	//System.out.println(String.format("%04x", m_pc));
	int opcode=readBytePC();
	if ((opcode&0xC0)==0xC0)
	{
		readVariableForm(opcode);
	}
	else if ((opcode&0xC0)==0x80)
	{
		readShortForm(opcode);
	}
	else
	{
		readLongForm(opcode);
	}
	switch (m_ins.form)
	{
		case Form0OP:
			//printf("Doing op0:%2d\n", m_ins.op);
			m_ins.store=readStoreInstruction(zeroOpStoreInstructions,ARRAY_SIZEOF(zeroOpStoreInstructions),m_ins.op);
			m_ins.branch=readBranchInstruction(zeroOpBranchInstructions,ARRAY_SIZEOF(zeroOpBranchInstructions),m_ins.op);
			//dumpCurrentInstruction();
			process0OPInstruction();
			break;
		case Form1OP:
			//printf("Doing op1:%2d Operands:%04x\n", m_ins.op, m_ins.operands[0].value&0xFFFF);
			m_ins.store=readStoreInstruction(oneOpStoreInstructions,ARRAY_SIZEOF(oneOpStoreInstructions),m_ins.op);
			m_ins.branch=readBranchInstruction(oneOpBranchInstructions,ARRAY_SIZEOF(oneOpBranchInstructions),m_ins.op);
			//dumpCurrentInstruction();
			process1OPInstruction();
			break;
		case Form2OP:
			//printf("Doing op2:%2d Operands:%04x %04x\n", m_ins.op, m_ins.operands[0].value&0xFFFF, m_ins.operands[1].value&0xFFFF);
			m_ins.store=readStoreInstruction(twoOpStoreInstructions,ARRAY_SIZEOF(twoOpStoreInstructions),m_ins.op);
			m_ins.branch=readBranchInstruction(twoOpBranchInstructions,ARRAY_SIZEOF(twoOpBranchInstructions),m_ins.op);
			//dumpCurrentInstruction();
			process2OPInstruction();
			break;
		case FormVAR:
			//if (m_ins.numOps==4)
			//	printf("Doing opvar:%2d Operands:%04x %04x %04x %04x\n", m_ins.op, m_ins.operands[0].value&0xFFFF, m_ins.operands[1].value&0xFFFF, m_ins.operands[2].value&0xFFFF, m_ins.operands[3].value&0xFFFF);
			//else if (m_ins.numOps==3)
			//	printf("Doing opvar:%2d Operands:%04x %04x %04x\n", m_ins.op, m_ins.operands[0].value&0xFFFF, m_ins.operands[1].value&0xFFFF, m_ins.operands[2].value&0xFFFF);
			//else if (m_ins.numOps==2)
			//	printf("Doing opvar:%2d Operands:%04x %04x\n", m_ins.op, m_ins.operands[0].value&0xFFFF, m_ins.operands[1].value&0xFFFF);
			//else if (m_ins.numOps==1)
			//	printf("Doing opvar:%2d Operands:%04x\n", m_ins.op, m_ins.operands[0].value&0xFFFF);
			//else
			//	printf("Doing opvar:%2d Operands:\n", m_ins.op);
			m_ins.store=readStoreInstruction(varOpStoreInstructions,ARRAY_SIZEOF(varOpStoreInstructions),m_ins.op);
			m_ins.branch=readBranchInstruction(varOpBranchInstructions,ARRAY_SIZEOF(varOpBranchInstructions),m_ins.op);
			//dumpCurrentInstruction();
			processVARInstruction();
			break;
	}
}

int main(int argc, char **argv)
{
	TFile fh;
	if (argc!=2)
	{
		printf("Usage: zops game.z3\n");
	}
	else if (fileOpen(&fh, argv[1], TRUE))
	{
		m_memSize=fileSize(&fh);

		SDL_Init(SDL_INIT_VIDEO);
		window = SDL_CreateWindow("TFTLCD",SDL_WINDOWPOS_UNDEFINED,SDL_WINDOWPOS_UNDEFINED,240,320,SDL_WINDOW_SHOWN);
		if (window == NULL)
		{
			printf("Could not create window: %s\n", SDL_GetError());
			return 1;
		}
		ren = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
		if (ren == NULL)
		{
			printf("Could not create renderer: %s\n", SDL_GetError());
			return 1;
		}
		tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_RGB565, SDL_TEXTUREACCESS_STREAMING, 240, 320);
		if (tex == NULL)
		{
			printf("Could not create texture: %s\n", SDL_GetError());
			return 1;
		}

		rom=memAlloc(m_memSize);
		memory=memAlloc(m_memSize);
		biosRAM=memAlloc(0x10000);
		screen=memAlloc(320*240*sizeof(u16));
		fileReadData(&fh, rom, m_memSize);
		fileClose(&fh);
		restart();
		while (1)
		{
			executeInstruction();
		}

		SDL_DestroyTexture(tex);
		SDL_DestroyRenderer(ren);
		SDL_DestroyWindow(window);
		SDL_Quit();
		return 0;
	}
	return 1;
}
