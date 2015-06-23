/*******************************************
   assem.c
   an assembler for the TinyX CPU
	 TGB Ulrich Riedel 20040313
*******************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef struct _tag_Tmcode {
	struct _tag_Tmcode *prev;
	struct _tag_Tmcode *next;
	int linenumber;
	unsigned long addr;        // machinecode address
  char label[34];            // destination label
	char mnemo[16];            // mnemonic or directive
	char operand1[80];         // operands
	char operand2[80];
	char operand3[80];
	unsigned char mcod[128];   // machinecode ( maximum of 1024 bit instruction code )
	unsigned char imm[128];
	unsigned long oaddr1;      // operand address1
	unsigned long oaddr2;      // operand address2
	unsigned long oaddr3;      // operand address2
	char olabel1[34];          // operand label1
	char olabel2[34];          // operand label2
	char olabel3[34];          // operand label3
} Tmcode;

typedef struct {
	unsigned long addr;
	char label[40];
} Taddress;

int g_wordSize;  // processor word size

char *getvalue(char *str, unsigned char *val);  // reads string value

int main(int argc,char *argv[])
{
	FILE *fp;
	char filename[256];
	unsigned char binTemp[128];
	char line[80];
	char tmpStr[40];
	char *tempPtr;
	int  linenumber, idx, maxi, jdx, sdx;
	unsigned short slen;
	Tmcode *head, *tail, *cPtr, *hPtr, *tPtr;
	unsigned long addr, val1, val2, val3;
	unsigned char code[128], chksum, lsn, msn;
	Taddress *address;
	unsigned char ccMode;
	unsigned char aluMode;
	unsigned char updateFlag;
	unsigned char carryUse;
	unsigned char writeCycle;
	unsigned char memRead;
	unsigned char immediate;
	unsigned char	valmux;
	unsigned char dstReg;
	unsigned char src1Reg;
	unsigned char src2Reg;

	g_wordSize = 0;

	if (argc == 1) {
    fprintf(stderr, "usage: tinyx file\n");
		return 1;
	}

	fp = fopen(argv[1], "r");
	if(NULL == fp) {
		fprintf(stderr, "%s doesn't exist\n", argv[1]);
		return 2;
	}
	strncpy(filename, argv[1], 120);
	strcat(filename, ".HEX");

	printf("prepass\n");
/////////// pre pass /////////////////////////////////////
  linenumber = 1;  // sourcecode linenumber count
	head = tail = NULL;
	while(fgets(line, 79, fp)) {
		if(line[0] == 0) {  // empty line
			linenumber++;
			continue;
		}
		sdx = strlen(line);
		for(idx=0; idx<sdx; idx++) {
      if(!isspace(line[idx])) break;
		}
		if(sdx == idx) {  // whitespace line
			linenumber++;
			continue;
		}
///////// make line to uppercase characters, ignoring comment lines
		for(idx=0; line[idx]; idx++) {
			if(line[idx] == 13) { line[idx] = 0; continue; }   // return
			if(line[idx] == 10) { line[idx] = 0; continue; }   // linefeed
			if(line[idx] == 9)  { line[idx] = 32; continue; }  // tab
			if((line[idx] & 0xE0) == 0) {
				fprintf(stderr, "%d contains non printable characters.\n", linenumber);
				return 3;
			}
			if(line[idx] < 0) {
				fprintf(stderr, "%d contains non printable characters\n", linenumber);
				return 3;
			}
			line[idx] = toupper(line[idx]);
		}
		if(line[0] == ';') { linenumber++; continue; } // skip comment lines
		if(line[0] == '.') {
      fprintf(stderr, "%d no directive first allowed\n", linenumber);
			linenumber++;
		  continue;
		}
///////// break into up to 5 components //////////////////
////////  alloc mcode structure for this sourcecode line
    hPtr = (Tmcode *) malloc(sizeof(Tmcode));
		memset(hPtr, 0, sizeof(Tmcode));
    if(head == NULL) {
      head = hPtr;
			tail = hPtr;
			cPtr = head;
		} else {
			tPtr = cPtr;
			cPtr->next = hPtr;
			cPtr = cPtr->next;
			cPtr->prev = tPtr;
			tail = cPtr;
		}
		hPtr->linenumber = linenumber;
///////// 1st component, label ///////////////////////////
    idx = 0; // start at beginning sourcecode line
    if(!isspace(line[0])) { // first char nonspace?
			for(; line[idx] && (idx<32); idx++) {  // label max 32 chars
				if(isspace(line[idx])) break;  // delimiter
				if(line[idx] == ';')   break;  // comment
				tmpStr[idx] = line[idx];
			}
			tmpStr[idx] = 0;
      strcpy(hPtr->label, tmpStr);  // save label
		}
		if(0 == line[idx]) {  // end of line?, label only
			linenumber++;
			continue;
		}
///////// 2nd component, mnemonic or directive ///////////
    while(isspace(line[idx])) idx++;  // skip space
    for(jdx=0; line[idx] && (jdx<15); jdx++) {
      if(isspace(line[idx])) break;  // delimiter
			if(line[idx] == ';')   break;  // comment
			tmpStr[jdx] = line[idx++];
		}
		tmpStr[jdx] = 0;
		strcpy(hPtr->mnemo, tmpStr);  // save mnemonic or directive
    if(0 == line[idx]) {  // suddenly end of line?
			fprintf(stderr, "%d operand missing\n", linenumber);
			linenumber++;
			continue;
		}
    while(isspace(line[idx])) idx++;  // skip space
    if(0 == line[idx]) {  // suddenly end of line?
			fprintf(stderr, "%d operand missing\n", linenumber);
			linenumber++;
			continue;
		}
///////// 3,4,5th component, operands /////////////////////////
//// fetch operads strings
    for(jdx=0; line[idx] && (jdx<80); jdx++) {
			tmpStr[jdx] = line[idx++];
		}
		tmpStr[jdx] = 0;
		sdx = jdx;
		jdx = 0;
//// remove spaces between operands
		for(idx=0; idx<sdx; idx++) {
      if(isspace(tmpStr[idx])) continue;
			if(tmpStr[idx] == ';') break; // comment
			tmpStr[jdx++] = tmpStr[idx];
		}
		tmpStr[jdx] = 0;
		hPtr->operand1[0] = 0;
		hPtr->operand2[0] = 0;
		hPtr->operand3[0] = 0;
		idx = 0;
		for(jdx=0; tmpStr[idx] && jdx<70; jdx++) {
			if(tmpStr[idx] == 0) break;
			if(tmpStr[idx] == ',') break;
			hPtr->operand1[jdx] = tmpStr[idx++];
		}
		hPtr->operand1[jdx] = 0;
		if(tmpStr[idx]) {
		  idx++;
			for(jdx=0; tmpStr[idx] && jdx<70; jdx++) {
				if(tmpStr[idx] == 0) break;
				if(tmpStr[idx] == ',') break;
				hPtr->operand2[jdx] = tmpStr[idx++];
			}
		  hPtr->operand2[jdx] = 0;
		  if(tmpStr[idx]) {
			  idx++;
				for(jdx=0; tmpStr[idx] && jdx<70; jdx++) {
					if(tmpStr[idx] == 0) break;
					if(tmpStr[idx] == ',') break;
					hPtr->operand3[jdx] = tmpStr[idx++];
				}
			  hPtr->operand3[jdx] = 0;
		  }
	  }
		hPtr->linenumber = linenumber;
		linenumber++;
	}
	fclose(fp);

#if 0
///////////////// test output //////////////////////////////////
  hPtr = head;
  while(hPtr) {
		printf("%d <%s><%s><%s><%s><%s>\n", hPtr->linenumber,
		                                 hPtr->label,
		                                 hPtr->mnemo,
																		 hPtr->operand1,
																		 hPtr->operand2,
																		 hPtr->operand3);
		hPtr = hPtr->next;
	}
#endif

	printf("1st pass\n");
/////////// 1st pass ////////////////////////////////////
  addr = 0;
  hPtr = head;
	while(hPtr) {
    hPtr->addr = addr;
		if(!strlen(hPtr->mnemo)) {  // label only
      hPtr = hPtr->next;
			continue;
		}
///////// check on directives ///////////////////////////
    if(!strcmp(hPtr->mnemo, ".WORDSIZE")) {  // set processor wordsize
      if(g_wordSize) {
				fprintf(stderr, "processor wordsize already set!\n");
				return 5;
			}
			g_wordSize = atoi(hPtr->operand1);
			if(g_wordSize < 32) {
				fprintf(stderr, "wordsize at least of 32 and multiple of 8 needed!\n");
				return 6;
			}
			if(g_wordSize & 7) {
				fprintf(stderr, "wordsize at least of 32 and multiple of 8 needed!\n");
				return 7;
			}
			hPtr->linenumber = -1;
			hPtr = hPtr->next;
			continue;
		}
		if(g_wordSize == 0) {
			fprintf(stderr, "missing, wordsize at least of 32 and multiple of 8 needed!\n");
			return 8;
		}
    if(!strcmp(hPtr->mnemo, ".ORG")) {  // set location address
      addr = strtol(hPtr->operand1, &tempPtr, 16);
			hPtr->addr = addr;
			hPtr->linenumber = -1;
			hPtr = hPtr->next;
			continue;
		}
		if(!strcmp(hPtr->mnemo, ".DC")) {   // define constant
			getvalue(hPtr->operand1, binTemp);
	    idx = g_wordSize / 8;
			memset(hPtr->mcod, 0, sizeof(hPtr->mcod));
			memcpy(hPtr->mcod, &binTemp[128-idx], idx);
			hPtr = hPtr->next;
			addr++;
			continue;
		}
		ccMode     = 16;
		aluMode    = 16;
		updateFlag = 0;
		carryUse   = 0;
		writeCycle = 0;
		memRead    = 0;
		immediate  = 0;
		valmux     = 0;
		dstReg     = 0;
		src1Reg    = 0;
		src2Reg    = 0;
		sdx        = 0;
	  if(!memcmp(&hPtr->mnemo[sdx], "U", 1)) {  // update flag after alu operation ?
			updateFlag = 1;
			sdx++;
		}
		////// scan condition code
		if(!memcmp(&hPtr->mnemo[sdx], "A", 1)) {          // always
			ccMode = 0;   sdx++;
		} else if(!memcmp(&hPtr->mnemo[sdx], "CC", 2)) {  // carry clear
			ccMode = 1;   sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "CS", 2)) {  // carry set
			ccMode = 2;   sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "EQ", 2)) {  // equal
			ccMode = 3;   sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "GE", 2)) {  // greater equal
			ccMode = 4;   sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "GT", 2)) {  // greater than
			ccMode = 5;   sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "HI", 2)) {  // higher
			ccMode = 6;   sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "LE", 2)) {  // less equal
			ccMode = 7;   sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "LS", 2)) {  // less
			ccMode = 8;   sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "LT", 2)) {  // less than
		  ccMode = 9;   sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "MI", 2)) {  // minus
			ccMode = 10;  sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "NE", 2)) {  // not equal
			ccMode = 11;  sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "PL", 2)) {  // plus
			ccMode = 12;  sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "VC", 2)) {  // overflow clear
			ccMode = 13;  sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "VS", 2)) {  // overflow set
			ccMode = 14;  sdx += 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "N", 1)) {   // never
			ccMode = 15;  sdx++;
		}
    ////// scan alu mode
		if(!memcmp(&hPtr->mnemo[sdx], "MOV", 3)) {         // mov
			aluMode = 0;
		} else if(!memcmp(&hPtr->mnemo[sdx], "AND", 3)) {  // and
			aluMode = 1;
		} else if(!memcmp(&hPtr->mnemo[sdx], "OR", 2)) {   // or
			aluMode = 2;
		} else if(!memcmp(&hPtr->mnemo[sdx], "XOR", 3)) {  // xor
			aluMode = 3;
		} else if(!memcmp(&hPtr->mnemo[sdx], "ADD", 3)) {  // add
			aluMode = 4;
			if(hPtr->mnemo[sdx+3] == 'C') carryUse = 1;
		} else if(!memcmp(&hPtr->mnemo[sdx], "SUB", 3)) {  // sub
			aluMode = 5;
			if(hPtr->mnemo[sdx+3] == 'C') carryUse = 1;
		} else if(!memcmp(&hPtr->mnemo[sdx], "ROR", 3)) {  // ror
			aluMode = 6;
		} else if(!memcmp(&hPtr->mnemo[sdx], "LSR", 3)) {  // lsr
			aluMode = 7;
		} else if(!memcmp(&hPtr->mnemo[sdx], "LSRA", 4)) { // lsra
			aluMode = 8;
		} else if(!memcmp(&hPtr->mnemo[sdx], "SWAP", 4)) { // swap
			aluMode = 9;
		} else if(!memcmp(&hPtr->mnemo[sdx], "SWAPB", 5)) {// swapb
			aluMode = 10;
		} else if(!memcmp(&hPtr->mnemo[sdx], "INC", 3)) {  // inc
			aluMode = 11;
			if(hPtr->mnemo[sdx+3] == 'C') carryUse = 1;
		} else if(!memcmp(&hPtr->mnemo[sdx], "DEC", 3)) {  // dec
			aluMode = 12;
			if(hPtr->mnemo[sdx+3] == 'C') carryUse = 1;
		} else if(!memcmp(&hPtr->mnemo[sdx], "RORB", 4)) { // rorb
			aluMode = 13;
		}
////////////// destination operand
    if(hPtr->operand1[0] == 0) {
		  hPtr = hPtr->next; // goto next line
			fprintf(stderr, "%d destination operand missing\n", hPtr->linenumber);
			continue;
		}
		sdx = 0;
		if(hPtr->operand1[0] == '[') {
			sdx++;
			writeCycle = 1;
	  }
		if(hPtr->operand1[sdx] != 'R') {
			fprintf(stderr, "%d destination operand error\n", hPtr->linenumber);
		} else {
			if(!isdigit(hPtr->operand1[sdx+1])) {
				fprintf(stderr, "%d destination operand number error\n", hPtr->linenumber);
			} else {
				dstReg = hPtr->operand1[sdx+1] - '0';
			}
		}
		src1Reg = dstReg;  // set default register
		src2Reg = dstReg;  // set default register, improve to opcode kontext register
//////////// source1 operand
		if(hPtr->operand2[0]) {
	    sdx = 0;
			if(hPtr->operand2[0] == '[') {
				if(writeCycle) {
			  	hPtr = hPtr->next; // goto next line
					fprintf(stderr, "%d both memory accesses not supported\n", hPtr->linenumber);
					continue;
				}
				sdx++;
				memRead = 1;
		  }
			if(hPtr->operand2[sdx] != 'R') {  // immediate
				if((hPtr->operand2[0] == '$') || isdigit(hPtr->operand2[0])) {
					getvalue(hPtr->operand2, binTemp);
					memcpy(hPtr->imm, &binTemp[128-g_wordSize/8], g_wordSize/8);
				  immediate = 1;
			  } else {  // label
					strcpy(hPtr->olabel2, hPtr->operand2);
				}
			} else {
				if(!isdigit(hPtr->operand2[sdx+1])) {
					fprintf(stderr, "%d source1 operand number error\n", hPtr->linenumber);
				} else {
					src1Reg = hPtr->operand2[sdx+1] - '0';
					if(writeCycle) {
						src2Reg = dstReg;
					}
				}
			}
	///////// source2 operand
			if(hPtr->operand3[0] == 0) {
				if(writeCycle == 0) {
				  src2Reg = src1Reg;
			  }
			} else {
				if(hPtr->operand3[0] != 'R') {
						fprintf(stderr, "%d source2 operand number error\n", hPtr->linenumber);
					continue;
				} else {
					if(!isdigit(hPtr->operand3[1])) {
						fprintf(stderr, "%d source2 operand number error\n", hPtr->linenumber);
					} else {
						src2Reg = hPtr->operand3[1] - '0';
					}
				}
			}
		} // if(hPtr->operand2[0] == 0)
///////// build machine code
		memset(hPtr->mcod, 0, sizeof(hPtr->mcod));
		hPtr->mcod[0] = (ccMode << 4) | aluMode;
		hPtr->mcod[1] = (memRead << 7) | (dstReg << 4) | (writeCycle << 3) | src1Reg;
		hPtr->mcod[2] = (immediate << 7) | (src2Reg << 4) | (updateFlag << 3) | (carryUse << 2);
    idx = g_wordSize / 8;
		memcpy(&hPtr->mcod[3], &hPtr->imm[3], idx-3);
		addr++;            // goto next program address
		hPtr = hPtr->next; // goto next line
	}
/////////// count label addresses ///////////////////////
  hPtr = head;
	maxi = 0;
	while(hPtr) {
		if(hPtr->label[0]) maxi++;
		hPtr = hPtr->next;
	}
/////////// table with label address ////////////////////
  address = (Taddress *) malloc(maxi * sizeof(Taddress));
	hPtr = head;
	idx = 0;
	while(hPtr) {
		if(hPtr->label[0]) {
			address[idx].addr = hPtr->addr;
			strcpy(address[idx].label, hPtr->label);
			idx++;
		}
		hPtr = hPtr->next;
	}

	printf("2nd pass\n");
/////////// 2nd pass ////////////////////////////////////
  hPtr = head;
	while(hPtr) {
    if(hPtr->olabel2[0]) {  // resolve label, treated as immediate operand
      for(idx=0; idx<maxi; idx++) {
				if(!strcmp(address[idx].label, hPtr->olabel2)) {
					hPtr->mcod[2] |= 0x80; // set immediate operand flag
					jdx = g_wordSize / 8;
					switch(jdx) {
						case 4:
							hPtr->mcod[3] = (unsigned char) address[idx].addr;
						break;
						case 5:
							hPtr->mcod[3] = (unsigned char) (address[idx].addr >> 8);
							hPtr->mcod[4] = (unsigned char)  address[idx].addr;
						break;
						case 6:
							hPtr->mcod[3] = (unsigned char) (address[idx].addr >> 16);
							hPtr->mcod[4] = (unsigned char) (address[idx].addr >> 8);
							hPtr->mcod[5] = (unsigned char)  address[idx].addr;
						break;
						default:
						  jdx -= 4;
							hPtr->mcod[jdx++] = (unsigned char) (address[idx].addr >> 24);
							hPtr->mcod[jdx++] = (unsigned char) (address[idx].addr >> 16);
							hPtr->mcod[jdx++] = (unsigned char) (address[idx].addr >>  8);
							hPtr->mcod[jdx++] = (unsigned char)  address[idx].addr;
					}
					break;
				}
			}
			if(idx == maxi) {
				fprintf(stderr, "%d unknown label\n", hPtr->linenumber);
			}
		}
		hPtr = hPtr->next;
	}

////////// output ///////////////////////////////////////
  fp = fopen(filename, "w");  // write into Intel HEX file
	if(NULL == fp) {
		fprintf(stderr, "can't write to %s\n", filename);
		return 0;
	}
  hPtr = head;
	maxi = g_wordSize / 8;
  while(hPtr) {
		if(hPtr->linenumber < 0) {
			hPtr = hPtr->next;
			continue;
		}
		/*
		printf("%04X ", hPtr->addr);
    for(idx=0; idx<maxi; idx++) printf("%02X ", hPtr->mcod[idx]);
		printf("<%s><%s><%s><%s><%s>\n", hPtr->label, hPtr->mnemo, hPtr->operand1, hPtr->operand2, hPtr->operand3);
		*/

		if(maxi) {
      sprintf(line, ":%02X%04X00", maxi, hPtr->addr);
			for(idx=0; idx<maxi; idx++) {
				sprintf(tmpStr, "%02X", hPtr->mcod[idx]);
				strcat(line, tmpStr);
			}
			chksum = 0;
			for(idx=1; line[idx]; idx += 2) {
        msn = line[idx] - '0';
				if(msn > 9) msn -= 7;
        lsn = line[idx+1] - '0';
				if(lsn > 9) lsn -= 7;
				chksum += ((msn<<4) + lsn);
			}
      chksum = 256 - chksum;
			sprintf(tmpStr, "%02X", chksum);
			strcat(line, tmpStr);
			fprintf(fp, "%s\015\012", line);
	  }
		hPtr = hPtr->next;
  }
	fprintf(fp, ":00000001FF\015\012");  // end of HEX file
	fclose(fp);
	return 0;
}

////////// gets a decimal or hexadecimal value
// decimal     is ddd
// hexadecimal is $hhh
// returns ptr after value
char *getvalue(char *str, unsigned char *val)
{
	int idx, jdx, kdx, radix, cy;
	unsigned short temp[128];
	unsigned short help[128];

	memset(temp, 0, sizeof(temp));
	memset(help, 0, sizeof(help));
	radix = 10;
	if(str[0] == '$') radix = 16;
  if(radix == 10) {
    for(idx=0; str[idx]; idx++) {
		  if(!isdigit(str[idx])) break;
			cy = 0;
      for(jdx=127; jdx >=0; jdx--) { // shift left
				temp[jdx] <<= 1;
				if(cy) temp[jdx]++;
				cy = 0;
				if(temp[jdx] > 255) {
					cy++;
					temp[jdx] &= 255;
				}
			}
			memcpy(help, temp, sizeof(help));
			for(kdx=0; kdx<2; kdx++) {
				cy = 0;
	      for(jdx=127; jdx >=0; jdx--) { // shift left
					temp[jdx] <<= 1;
					if(cy) temp[jdx]++;
					cy = 0;
					if(temp[jdx] > 255) {
						cy++;
						temp[jdx] &= 255;
					}
				}
			}
      cy = 0;
			for(jdx=127; jdx >=0; jdx--) {  // add
				temp[jdx] += help[jdx];
				if(cy) temp[jdx]++;
				cy = 0;
				if(temp[jdx] > 255) {
					cy++;
					temp[jdx] &= 255;
				}
			}
			temp[127] += (str[idx] - '0');
			cy = 0;
			if(temp[127] > 255) {
				cy++;
				temp[127] &= 255;
			}
			for(jdx=126; jdx >=0; jdx--) {
				temp[jdx] += cy;
				cy = 0;
				if(temp[jdx] > 255) {
					cy++;
					temp[jdx] &= 255;
				}
			}
		} // end for
	} else {
		for(idx=1; str[idx]; idx++) {
			if(!isxdigit(str[idx])) break;
      for(jdx=0; jdx<127; jdx++) {  // shift 4 bits left
        temp[jdx] <<= 4;
				temp[jdx] |= (15 & (temp[jdx+1] >> 4));
			}
			temp[127] <<= 4;
      jdx = str[idx] - '0';
			if(jdx > 9) jdx -= 7;
			temp[127] |= jdx;
		} // end for
	}
	for(idx=128-(g_wordSize/8); idx<128; idx++) {
		val[idx] = temp[idx];
	}
	return &str[idx];
}
