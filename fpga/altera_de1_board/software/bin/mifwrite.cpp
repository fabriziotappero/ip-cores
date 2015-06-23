// this prog is taken from http://www.johnloomis.org/ece595c/notes/isa/mifwrite.html
// and slightly changed to satisfy quartus6.1 *.mif eating engine.
//
// it takes binary file of arbitrary length and treating it as collection of 16-bit words,
// writes *.mif file for quartus
//
//


#include <stdio.h>
#include <stdlib.h>

void mifwrite(FILE *in, FILE *out, int offset);

int main(int argc, char *argv[])
{
	char *filename;

	if (argc<3) {
		printf("usage: mifwrite input_file output_file [offset]\n");
		printf("The default offset is zero");
		return -1;
	}

	FILE *in, *out;
	filename = argv[1];
	in = fopen(filename,"rb");
	if (!in) {
		printf("file: %s not found\n",filename);
		return -1;
	}
	filename = argv[2];
	out = fopen(filename,"wt");
	if (!out) {
		printf("file: %s not opened\n",filename);
		return -1;
	}
	int offset = 0;
	if (argc>3) sscanf(argv[3],"%x",&offset);
	if (offset) printf("address_offset %x\n",offset);
	mifwrite(in,out,offset);
	return 0;
}

void mifwrite(FILE *in, FILE *out,int offset)
{
	int count;
	unsigned int data;
	unsigned int address = 0;
	int ndepth;
	int nwidth = 16;

	fseek(in,0,SEEK_END);
	ndepth = ftell(in)/2;
	fseek(in,0,SEEK_SET);
	
	
	fprintf(out,"DEPTH = %d;\n",ndepth);
	fprintf(out,"WIDTH = %d;\n\n",nwidth);
	fprintf(out,"ADDRESS_RADIX = HEX;\n");
	fprintf(out,"DATA_RADIX = HEX;\n");
	fprintf(out,"CONTENT\n  BEGIN\n");
	fprintf(out,"[0..%x]   :  0;\n",ndepth-1);
	address = 0;
	offset = offset>>2;
	data=0;
	while (count = fread(&data,2,1,in)) {
		if (address<offset) {
			offset--;
			continue;
		}
		fprintf(out,"%04x  : %04x;\n",address,data);
		address++;
//		if (address>=ndepth) break;
	}
	fprintf(out,"END;\n");
	fclose(in);
	fclose(out);
}
