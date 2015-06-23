#include "ihex.c"
#include <unistd.h>
#include <stdlib.h>

#define DEFAULT_OUT_FILE_NAME		"out.mif"
#define DEAFULT_END_SIZE		"1FFF"

int	memory[65536];		/* the memory is global */
unsigned int 	end_addr_int;
FILE * in, * out;
char *file_name, *end_addr, *out_file_name ;

void usage (void)
{
	printf("Usage: ./ihex2mif  <options>  \n");
	printf("\nOptions: \n");
	printf("         -e <end memory address> : end memory address .\n");
	printf("         -f <file name>: input ihex file  .\n");
	
}

void processArgs (int argc, char **argv )
{
   char c;  

     opterr = 0;

   while ((c = getopt (argc, argv, "e:f:o:h")) != -1)
      {
	 switch (c)
	    {
	 	case 'e':	
			end_addr = optarg;
			break;
		case 'f':	
			file_name = optarg;
			break;
		case 'o':
			out_file_name =  optarg;
			break;
		case 'h':
			usage();
		       	exit(1);
			break;
		case '?':
	     	  if (isprint (optopt))
			  fprintf (stderr, "Unknown option `-%c'.\n", optopt);
	     	  else
			  fprintf (stderr,   "Unknown option character `\\x%x'.\n",   optopt);
		default:
		       	usage();
		       	exit(1);
	    }
      }
}

void update_out_file(void);
int main ( int argc, char **argv ){
	
	processArgs (argc,argv );
	if (file_name == NULL) {usage();exit(1);} 	
	if (end_addr  == NULL) end_addr = DEAFULT_END_SIZE;
	if (out_file_name == NULL) out_file_name = DEFAULT_OUT_FILE_NAME;	
	//printf("filename=%s & size=%s\n",file_name, end_addr);
	sscanf(end_addr, "%x", &end_addr_int);
   	//printf("%u\n", end_addr_int);
	out=fopen(out_file_name,"wb");
	if(out==NULL){printf("Output file cannot be created"); exit(1);}
	load_file(file_name);
	update_out_file();
	

	fclose(out);

return 0;
}


void update_out_file(void){
	unsigned int ram_addr=0,zero_count,ram_data,i;
	fprintf(out,"-- Copyright (C) 2013 Alireza Monemi\n\n");
	fprintf(out,"WIDTH=32;\nDEPTH=%d;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n", (end_addr_int>>2)+1);
	while(ram_addr<end_addr_int){
		
		zero_count =-1;
		
		do{
			zero_count++;			
			ram_data =0;	
			for(i=0;i<4;i++) 
			{
				ram_data <<=8;
				ram_data |= memory[ram_addr+ (zero_count<<2)+i];
				
			}
			//printf("%u=,%08X\n",ram_addr+ (zero_count<<2), ram_data);
			
		}while(ram_data==0 && ((ram_addr+ (zero_count<<2))<end_addr_int ));
		
		if (zero_count == 0) {
			 fprintf(out,"\t%08X\t:\t%08X;\n" , ram_addr>>2,ram_data);
		}else if (zero_count == 1){
			fprintf(out,"\t%08X\t:\t%08X;\n" , (ram_addr>>2),0);
			if(ram_data!=0)fprintf(out,"\t%08X\t:\t%08X;\n" , (ram_addr>>2)+1,ram_data);

		}
		else {
			fprintf(out,"\t[%08X..%08X]\t:\t00000000;\n" ,ram_addr>>2, (ram_addr>>2)+ zero_count-1);
			if(ram_data!=0)fprintf(out,"\t%08X\t:\t%08X;\n" , (ram_addr>>2)+ zero_count,ram_data);			
		}		
		ram_addr+=(zero_count<<2)+4;	
		
		


	}
	fprintf(out,"END;");

return;
}

