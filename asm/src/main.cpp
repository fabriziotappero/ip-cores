#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

using namespace std;

 // global definition table
 char definition[4*2048][16];
 char def_alias[4*2048][16];
 int  def_cnt = 0;

 // global mem-data table
 bool is_dw[65536];

 // program's xor checksum
 int  xor_checksum = 0;

 // global branch-label table
 char c_label_tab[6*2048][32];
 int  i_label_tab[6*2048];

 // global error/warning indicator
 int  error_cnt = 0;
 int  warning_cnt = 0;

 // image name
 char image_name[10] = {'\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0'};

 // function prototypes
 void includer(char *main_file, const char *output);
 void convert_strings(const char *input_file, const char *output_file);
 void pre_processor(const char *input_file, const char *output_file);
 int  conv_shift(char *input_string, int line);
 int  hexc_to_int(char input_char);
 int  conv_cpreg(char *input_string, int line);
 int  conv_reg(char *input_string, int line);
 int  conv_indexing(char *input_string, int line);
 int  conv_flag_op(char *input_string, int line);
 int  conv_flag_op_2(char *input_string, int line);
 int  conv_cpx_op(char *input_string, int line);
 int  find_offset(char *input_label, int line);
 int  conv_imm(char *input, int max_val, int line);
 void get_labels(const char *input_file);
 int  assemble(const char *input_file, const char *output_file, const char *bin_output_file, const char *boot_output_file);
 int  main(int argc, char *argv[]);
 
 
// *****************************************************************************************************************
// Copy included files to main file
// *****************************************************************************************************************
void includer(char *main_file, const char *output_file){

    FILE *input, *inc_file, *output;
    char line_input[1024];
    int  i = 0, j = 0;
    char *cut_out;
    char txt_string[256];
    char buf_string[256];
    char in_file_name[256];
	bool found = false;
	char ch;

    // open input file
    input = fopen(main_file, "r");
    if(input == NULL){
      printf("INCLUDER: Input file error!");
      exit(1);
    }

    // open output file (main working file)
    output = fopen(output_file, "w+");
    if(output == NULL){
      printf("INCLUDER: Main file error!");
      exit(1);
    }

    // get line
    while(fgets(line_input, 512, input) != NULL){

      // clear working string
      for(i=0; i<strlen(txt_string); i++)
        txt_string[i] = '\0';
      // clear working string
      for(i=0; i<strlen(buf_string); i++)
        buf_string[i] = '\0';
      // clear file name string
      for(i=0; i<strlen(in_file_name); i++)
        in_file_name[i] = '\0';

      // get line entry
      cut_out = strtok(line_input, "\n");
      if (cut_out != NULL)
        sprintf(txt_string, "%s", cut_out);
	  strcpy(buf_string, txt_string); // make a copy

      // erase comments
      for(i=0; i<strlen(txt_string); i++){
        if (txt_string[i] == ';'){
		  for(j=i; j<strlen(txt_string); i++)
            txt_string[j] = '\0';
		  break;
		}
      }

	  // find include statement
	  for (i=0; i<245; i++){
	    if (txt_string[i] == '.'){
		  if (((txt_string[i+1] == 'I') or (txt_string[i+1] == 'i')) and ((txt_string[i+2] == 'N') or (txt_string[i+2] == 'n')) and
		      ((txt_string[i+3] == 'C') or (txt_string[i+3] == 'c')) and ((txt_string[i+4] == 'L') or (txt_string[i+4] == 'l')) and
		      ((txt_string[i+5] == 'U') or (txt_string[i+5] == 'u')) and ((txt_string[i+6] == 'D') or (txt_string[i+6] == 'd')) and
		      ((txt_string[i+7] == 'E') or (txt_string[i+7] == 'e')) and (txt_string[i+8] == ' ') and (txt_string[i+9] == '"')){
			// copy file name
			for (j=i; j<strlen(txt_string); j++){
			  if (txt_string[j+10] == '"')
			    break;
			  in_file_name[j-i] = txt_string[j+10];
			}
			in_file_name[j-i] = '\0';
			found = true;
		  }
	    }
	  }

	  if(found == true){ // include statement found!
        // open to be included file
		printf("Including file '%s'\n", in_file_name);
        inc_file = fopen(in_file_name, "r");
        if(inc_file == NULL){
          printf("INCLUDER: Error loading file '%s'!\n", in_file_name);
          exit(1);
        }
		// copy file
		while ((ch = getc(inc_file)) != EOF)
		  putc(ch, output);
		fclose(inc_file);
	  }
	  else{ // copy data from main input file
		strcat(buf_string, "\n");
        fputs(buf_string, output);
	  }
	  found = false;

	}

    fclose(output);
    fclose(input);
}

 
// *****************************************************************************************************************
// Convert strings into data intialization
// *****************************************************************************************************************
void convert_strings(const char *input_file, const char *output_file){

    FILE *input, *output;
    char line_input[1024];
    int  i = 0, j = 0, k = 0, l = 0;
    char *cut_out;
    char txt_string[256];
    char tmp_string[256];
    char out_string[256];
    char buf_string[256];
    bool found = false;
	int  fill_data_cnt = 0;
	int  line = 1;
	int  high = 0, low = 0;
	int  word = 0;

    // open string converter input file
    input = fopen(input_file, "r");
    if(input == NULL){
      printf("STRING_CONVERTER: Input file error!\n");
      exit(1);
    }

    // open string converter output file
    output = fopen(output_file, "w");
    if(output == NULL){
      printf("STRING_CONVERTER: Output file error!");
      exit(1);
    }

    // get line
	rewind(input);
	rewind(output);
    while(fgets(line_input, 512, input) != NULL){

      // clear working string
      for(i=0; i<strlen(txt_string); i++)
        txt_string[i] = '\0';
      // clear working string
      for(i=0; i<strlen(tmp_string); i++)
        tmp_string[i] = '\0';

      // get line entry
      cut_out = strtok(line_input, "\n");
      if (cut_out != NULL)
        sprintf(txt_string, "%s", cut_out);

      // erase comments
      for(i=0; i<strlen(txt_string); i++){
        if (txt_string[i] == ';'){
		  for(j=i; j<strlen(txt_string); i++)
            txt_string[j] = '\0';
		  break;
		}
      }

      // insert line breaks after labels
      for(i=0; i<strlen(txt_string); i++){
		if(txt_string[i] == ':'){
		  
		  for(j=0; j<(strlen(txt_string)-i); j++){
		    tmp_string[j] = txt_string[i+j+1];
		  }
		  txt_string[i+1] = '\n';
		  txt_string[i+2] = '\0';
		  strcat(txt_string, tmp_string);
		  strcat(txt_string, "\n\0");
		  break;
		}
      }

	  // convert to higher case
      for(i=0; i<strlen(txt_string); i++){
		if((txt_string[i] == 39) or (txt_string[i] == 34)) // stop converting when ' or " has been found
		  break;
        if((txt_string[i] > 96) and (txt_string[i] < 123))
          txt_string[i] = txt_string[i] - 32;
      }
	  strcpy(tmp_string, txt_string); // make a copy
	  strcpy(buf_string, txt_string); // make a copy

	  // find ".string" definiton
	  found = false;
	  for(i=0; i<strlen(tmp_string); i++){
	    if ((tmp_string[i+0] == '.') and (tmp_string[i+1] == 'S') and (tmp_string[i+2] == 'T') and (tmp_string[i+3] == 'R') and
		    (tmp_string[i+4] == 'I') and (tmp_string[i+5] == 'N') and (tmp_string[i+6] == 'G') and (tmp_string[i+7] == 'Z') and (tmp_string[i+8] == ' ')){
		  for(j=0; j<strlen(tmp_string); j++)
		    tmp_string[j] = tmp_string[j+i+8];
		  
		  // isolate text part
		  l = 0;
		  for(k=0; k<strlen(tmp_string); k++){
		    if (tmp_string[k] == 34){ // beginning of string text field
			  for(j=0; j<strlen(tmp_string); j++){
			    if(tmp_string[j+k+1] == 34) // end of string text field
				  break;
				else{
				  if ((tmp_string[j+k+1] ==92) && (tmp_string[j+k+2] == 'n')){ // is linebreak command?
				    out_string[l++] = 13; // carriage return
				    out_string[l++] = 10; // line feed
				    k++; // skip second line break char in input string
				  }
				  else
			        out_string[l++] = tmp_string[j+k+1];
				}
			  }
		      out_string[l] = '\0'; // terminate string
			  break;
			}
		  }
		  found = true;
		  break;
		}
	  }
	  
	  if (found == true){
	    // save label
		for (k=0; k<strlen(txt_string); k++){
		  if (txt_string[k] == '\n'){
		    txt_string[k+1] = '\0';
			fputs(txt_string, output);
			break;
		  }
		}
		// save integer conversion of string
		word = 0;
		for(k=0; k<strlen(out_string); k++){
		  if (k%2==0){
		    word = (int)out_string[k] << 8;
          }
		  else{
		    word = word | (int)out_string[k];
		    sprintf(txt_string, ".dw #%d\n", word);
            fputs(txt_string, output);
	      }
		}
		if((word&255) != 0) // last byte is zero?
		  sprintf(txt_string, ".dw #0\n");
		else
		  sprintf(txt_string, ".dw #%d\n", word);
        fputs(txt_string, output);
	  }
	  else{
        // write default to file
	    strcat(buf_string, "\n");
        fputs(buf_string, output);
	  }

    }

    fclose(output);
    fclose(input);
}


// *****************************************************************************************************************
// Formating pre-processor
// Erase comments and empty lines, convert to higher case, get definitions and insert data initializations
// *****************************************************************************************************************
void pre_processor(const char *input_file, const char *output_file){

    FILE *input, *output;
    char line_input[1024];
    int  i = 0, j = 0, k = 0;
    char *cut_out;
    char txt_string[256];
    char tmp_string[256];
	char buf_string[512];
    bool empty_line = false;
	int  fill_data_cnt = 0;
	int  line = 1;
	int  high = 0, low = 0;
	int  word = 0;
	bool insert_label = false;
	bool empty_label_line = false;
	bool found = false;

    // open pre_processor input file
    input = fopen(input_file, "r");
    if(input == NULL){
      printf("PRE_PROCESSOR: Input file error!\n");
      exit(1);
    }

    // open pre_processor output file
    output = fopen(output_file, "w");
    if(output == NULL){
      printf("PRE_PROCESSOR: Output file error!");
      exit(1);
    }

	// clear dw table
	for(i=0; i<65536; i++)
	  is_dw[i] = false;

    // get line
	rewind(input);
	rewind(output);
    while(fgets(line_input, 512, input) != NULL){

      // clear working string
      for(i=0; i<strlen(txt_string); i++)
        txt_string[i] = '\0';
      // clear working string
      for(i=0; i<strlen(buf_string); i++)
        buf_string[i] = '\0';

      // get line entry
      cut_out = strtok(line_input, "\n");
      if (cut_out != NULL)
        sprintf(txt_string, "%s", cut_out);

      // clear pending empty spaces
      for(i=strlen(txt_string); i>0; i--){
        if ((txt_string[i] == 0) or (txt_string[i] == ' ') or (txt_string[i] == '\n') or (txt_string[i] == 9))
          txt_string[i] = '\0';
        else{
          txt_string[i+1] = '\n';
          txt_string[i+2] = '\0';
          break;
        } 
      }

	  // convert to higher case
      for(i=0; i<strlen(txt_string); i++){
		if((txt_string[i] == 39) or (txt_string[i] == 34)) // stop converting when ' or " has been found
		  break;
        if((txt_string[i] > 96) and (txt_string[i] < 123))
          txt_string[i] = txt_string[i] - 32;
      }
	  
	  // insert label?
	  if (insert_label == true){
	    strncat(buf_string, tmp_string, strlen(tmp_string));
	    strncat(buf_string, txt_string, strlen(txt_string));
		strcpy(txt_string, buf_string);
	  }

      // find empty lines
      empty_line = true;
      for(i=0; i<strlen(txt_string); i++){
        if((txt_string[i] == ' ') or (txt_string[i] == 9) or (txt_string[i] == '\n') or (txt_string[i] == '\0'))
          empty_line = empty_line;
        else{
          empty_line = false;
          break;
        }
      }

      // delete tabs and commas
      for(i=0; i<strlen(txt_string); i++){
        if ((txt_string[i] == 9) or (txt_string[i] == ',') or (txt_string[i] == '\n'))
          txt_string[i] = ' ';
      }

      // delete new line after empty labels
	  insert_label = false;
	  empty_label_line = true;
      for(i=0; i<strlen(txt_string); i++){
        if (txt_string[i] == ':'){ // label found
          for(j=i+1; j<strlen(txt_string); j++){ // check line - empty?
		    if ((txt_string[j] == ' ') or (txt_string[j] == 9) or (txt_string[j] == '\n') or (txt_string[j] == '\0'))
		      empty_label_line = empty_label_line;
			else{
			  empty_label_line = false;
			  break;
			}
		  }
          if (empty_label_line == true){
			txt_string[j] = ' ';
			txt_string[j+1] = '\0';
			strcpy(tmp_string, txt_string);
            empty_line = true;
			insert_label = true;
            break;
          }
		}
      }

      // reduce spaces
      j = strlen(txt_string);
      while(j>0){
        for(i=0; txt_string[i] != '\0'; i++){
          if ((txt_string[i] == ' ') and (txt_string[i+1] == ' ')) {
            for (j=i; txt_string[j] != '\0'; j++)
              txt_string[j+1] = txt_string[j+2];
          }
        }
        j--;
      }

	  // line starting with space?
	  if (txt_string[0] == ' '){
        for(i=0; txt_string[i+1] != '\0'; i++) // cut off
          txt_string[i] = txt_string[i+1];
        txt_string[i] ='\0';
	  }

	  // magic
	  strcpy(tmp_string, txt_string);
	  for (i=0; i<255; i++) {
	    if ((txt_string[i] == ':') and (txt_string[i+1] != ' ')) {
			txt_string[i+1] = ' ';
			for (j=i+2; j<254; j++)
			  txt_string[j] = tmp_string[j-1];
		    break;
		}
	  }

	  // find definitions
	  if ((txt_string[0] == '.') and (txt_string[1] == 'E') and (txt_string[2] == 'Q') and (txt_string[3] == 'U')){
		empty_line = true;
		for(i=5; txt_string[i] != ' '; i++)
		  def_alias[def_cnt][i-5] = txt_string[i];
		i++;
		for(j=i; txt_string[j] != ' '; j++)
		  definition[def_cnt][j-i] = txt_string[j];
		def_cnt++;
	  }


	  // find memory reserve definitions
mem_reserve_loop:
	  found = false;
	  for(i=0; i<strlen(txt_string); i++){
	    if(txt_string[i] == '.') {
		  if ((txt_string[i+1] == 'S') and (txt_string[i+2] == 'P') and (txt_string[i+3] == 'A') and (txt_string[i+4] == 'C') and (txt_string[i+5] == 'E') and (txt_string[i+6] == ' ')){
 		    for(j=0; j<256; j++) // clear temp string
		      tmp_string[j] = '\0';
			for(j=i+7; txt_string[j] != ' '; j++) // cut-out name/value
		      tmp_string[j-(i+7)] = txt_string[j];
			for(j=0; j<def_cnt; j++){ // is definition?
			  if (strcmp(tmp_string, def_alias[j]) == 0){
			    strcpy(tmp_string, definition[j]);
				found = true;
				break;
			  }
			}
			if(tmp_string[0] == '#'){ // delete '#'
			  for(k=0; k<(strlen(tmp_string)-1); k++)
				tmp_string[k] = tmp_string[k+1];
			    tmp_string[k] = '\0';
			  }
			fill_data_cnt = atoi(tmp_string);
			break;
		  }
		}
	  }
	  // insert nops for reservation area
	  if (fill_data_cnt != 0){
	    j = 0;
	    for(i=0; i<strlen(txt_string); i++){
		  if(txt_string[i] == ':'){
		    txt_string[i+2] = 'N';
		    txt_string[i+3] = 'O';
		    txt_string[i+4] = 'P';
		    txt_string[i+5] = '\0';
			j = 1;
			break;
		  }
		}
		if (j == 0){
		  txt_string[0] = 'N';
		  txt_string[1] = 'O';
		  txt_string[2] = 'P';
		  txt_string[3] = '\0';
		}
		fill_data_cnt--;
	  }

      if (empty_line == false){
		strcat(txt_string, "\n");
        fputs(txt_string, output);
	    line++; // inc line index
      }

	  if(fill_data_cnt != 0){
	    // clear working string
        for(i=0; i<strlen(txt_string); i++)
          txt_string[i] = '\0';
	    goto mem_reserve_loop;
		
	  }

    }

    fclose(output);
    fclose(input);
}


// *****************************************************************************************************************
// Convert shift command
// *****************************************************************************************************************
int conv_shift(char *input_string, int line){

    int sft = 0;

    if (strcmp(input_string, "#SWP") == 0)
      sft = 0;
    else if (strcmp(input_string, "#ASR") == 0)
      sft = 1;
    else if (strcmp(input_string, "#ROL") == 0)
      sft = 2;
    else if (strcmp(input_string, "#ROR") == 0)
      sft = 3;
    else if (strcmp(input_string, "#LSL") == 0)
      sft = 4;
    else if (strcmp(input_string, "#LSR") == 0)
      sft = 5;
    else if (strcmp(input_string, "#RLC") == 0)
      sft = 6;
    else if (strcmp(input_string, "#RRC") == 0)
      sft = 7;
    else {
      printf("ERROR: Invalid shift <%s>! (line %d)\n", input_string, line);
      error_cnt++;
    }
    
    return sft;
}


// *****************************************************************************************************************
// Convert Hex char to int
// *****************************************************************************************************************
int hexc_to_int(char input_char){

    int ret = -1;

	switch(input_char){
	  case '0': ret = 0; break;
	  case '1': ret = 1; break;
	  case '2': ret = 2; break;
	  case '3': ret = 3; break;
	  case '4': ret = 4; break;
	  case '5': ret = 5; break;
	  case '6': ret = 6; break;
	  case '7': ret = 7; break;
	  case '8': ret = 8; break;
	  case '9': ret = 9; break;
	  case 'A': ret = 10; break;
	  case 'B': ret = 11; break;
	  case 'C': ret = 12; break;
	  case 'D': ret = 13; break;
	  case 'E': ret = 14; break;
	  case 'F': ret = 15; break;
	}
    
    return ret;
}


// *****************************************************************************************************************
// Convert coprocessor register to int address
// *****************************************************************************************************************
int conv_cpreg(char *input_string, int line){

    int reg = 0;
	int i = 0;

	// any coprocessor register definition?
	for (i=0; i<def_cnt; i++){
	  if (strcmp(input_string, def_alias[i]) == 0)
	    strcpy(input_string, definition[i]);
	}

    if (strcmp(input_string, "C0") == 0)
      reg = 0;
    else if (strcmp(input_string, "C1") == 0)
      reg = 1;
    else if (strcmp(input_string, "C2") == 0)
      reg = 2;
    else if (strcmp(input_string, "C3") == 0)
      reg = 3;
    else if (strcmp(input_string, "C4") == 0)
      reg = 4;
    else if (strcmp(input_string, "C5") == 0)
      reg = 5;
    else if (strcmp(input_string, "C6") == 0)
      reg = 6;
    else if (strcmp(input_string, "C7") == 0)
      reg = 7;
    else {
      printf("ERROR: Invalid coprocessor register name <%s>! (line %d)\n", input_string, line);
      error_cnt++;
    }
    
    return reg;
}


// *****************************************************************************************************************
// Convert register to int address
// *****************************************************************************************************************
int conv_reg(char *input_string, int line){

    int reg = 0;
	int i = 0;
	
    if ((input_string[0] == '+') or (input_string[0] == '-')) {
      for(i=0; i<31; i++)
        input_string[i] = input_string[i+1];                    
    }

	// any register definition?
	for (i=0; i<def_cnt; i++){
	  if (strcmp(input_string, def_alias[i]) == 0)
	    strcpy(input_string, definition[i]);
	}

    if (strcmp(input_string, "R0") == 0)
      reg = 0;
    else if (strcmp(input_string, "R1") == 0)
      reg = 1;
    else if (strcmp(input_string, "R2") == 0)
      reg = 2;
    else if (strcmp(input_string, "R3") == 0)
      reg = 3;
    else if (strcmp(input_string, "R4") == 0)
      reg = 4;
    else if (strcmp(input_string, "R5") == 0)
      reg = 5;
    else if (strcmp(input_string, "R6") == 0)
      reg = 6;
    else if (strcmp(input_string, "R7") == 0)
      reg = 7;
    else {
      printf("ERROR: Invalid register name <%s>! (line %d)\n", input_string, line);
      error_cnt++;
    }
    
    return reg;
}


// *****************************************************************************************************************
// Convert PRE / POST indexing mode
// *****************************************************************************************************************
int conv_indexing(char *input_string, int line){

    int mode = 0;

    if (strcmp(input_string, "PRE") == 0)
      mode = 0;
    else if (strcmp(input_string, "POST") == 0)
      mode = 1;
    else {
      printf("ERROR: Invalid register name <%s>! (line %d)\n", input_string, line);
      error_cnt++;
    }
    
    return mode;
}


// *****************************************************************************************************************
// Convert flag update option
// *****************************************************************************************************************
int conv_flag_op(char *input_string, int line){

    int opt = 0;

    if (strcmp(input_string, "ALU_FLAGS") == 0)
      opt = 1;
    else if (strcmp(input_string, "SYS_FLAGS") == 0)
      opt = 2;
    else if (strcmp(input_string, "USR_FLAGS") == 0)
      opt = 3;
    else if (strcmp(input_string, "") == 0)
      opt = 0;
    else {
      printf("ERROR: Invalid flag option <%s>! (line %d)\n", input_string, line);
      error_cnt++;
    }
    
    return opt;
}


// *****************************************************************************************************************
// Convert restricted flag update option
// *****************************************************************************************************************
int conv_flag_op_2(char *input_string, int line){

    int opt = 0;

    if (strcmp(input_string, "SYS_FLAGS") == 0)
      opt = 0;
    else if (strcmp(input_string, "USR_FLAGS") == 0)
      opt = 1;
    else {
      printf("ERROR: Invalid flag option <%s>! (line %d)\n", input_string, line);
      error_cnt++;
    }
    
    return opt;
}


// *****************************************************************************************************************
// Convert CPX flag option
// *****************************************************************************************************************
int conv_cpx_op(char *input_string, int line){

    int opt = 0;

    if (strcmp(input_string, "C_ANDZ") == 0)
      opt = 0;
    else if (strcmp(input_string, "C_ORZ") == 0)
      opt = 2;
    else if (strcmp(input_string, "NOTC_ANDZ") == 0)
      opt = 4;
    else if (strcmp(input_string, "NOTC_ORZ") == 0)
      opt = 6;
    else if (strcmp(input_string, "") == 0)
      opt = 0;
    else {
      printf("ERROR: Invalid CPX flag option <%s>! (line %d)\n", input_string, line);
      error_cnt++;
    }

    return opt;
}


// *****************************************************************************************************************
// Get branch offset
// *****************************************************************************************************************
int find_offset(char *input_label, int line){

    int  offset = 0;
	bool match = false;
	bool pos = false;
    int  i = 0;

	if(input_label[0] == '#'){
	  for(i=0; i<strlen(input_label); i++)
        input_label[i] = input_label[i+1]; 
	  if (input_label[1]== '-')
	    pos = false;
	  else
	    pos = true;
	  offset = atoi(input_label);
	  match = true;
	}

	// search definition
	else{
	  for(i=0; i<4*2048; i++){
        if (strcmp(input_label, c_label_tab[i]) == 0){
	      offset = i_label_tab[i] - line;
	      match = true;
	  	break;
        }		
      }
	}

	// label definition found?
	if (match == false){
	  printf("ERROR: Label <%s> not found! (line %d)\n", input_label, line);
	  error_cnt++;
	}

	// out of reach?
	if (line != -1){ // marker: full 16-bit range
	  if ((offset > 255) or (offset < -256)){
	    printf("ERROR: Label <%s> out of reach (offset: %d bytes)! (line %d)\n", input_label, offset*2, line);
	    error_cnt++;
	  }
      offset = offset & 511; // make it nine bit wide
	}

    return offset;
}


// *****************************************************************************************************************
// Convert immediate
// *****************************************************************************************************************
int conv_imm(char *input, int max_val, int line){

    int  imm = 65535;
    int  i = 0;
    int  j = 0;
    int  offset = 0;
	char temp[32];
	char num[32];
	char input_string[32];
	bool extended = false;

	strcpy(input_string, input);

    if ((input_string[0] == '+') or (input_string[0] == '-')) {
      for(i=0; i<31; i++)
        input_string[i] = input_string[i+1];  
    }

	// any normal immediate definition?
	for (i=0; i<def_cnt; i++){
	  if (strcmp(input_string, def_alias[i]) == 0){
	    strcpy(temp, definition[i]);
		for (i=0; i<strlen(temp); i++)
		  temp[i] = temp[i+1];
	    imm = atoi(temp);
	    goto skip_analysis;
	  }
	}

    if (input_string[0] == '#') {
      for(i=0; i<31; i++)
        input_string[i] = input_string[i+1];     
    }

	// binary format?
	if ((input_string[0] == '0') and (input_string[1] == 'B')){
      for(i=0; i<31; i++)
        input_string[i] = input_string[i+2];
	  imm = 0;
	  for(i=0; i<strlen(input_string); i++){
	    if(input_string[i] == '1')
		  imm = imm + (int)pow(2, (strlen(input_string)-1-i));
		else if (input_string[i] == '0')
		  imm = imm;
		else{
		  imm = -1; // invalid
		  break;
		}
	  }
	  goto skip_analysis;
	}

	// hex format?
	if ((input_string[0] == '0') and (input_string[1] == 'X')){
      for(i=0; i<31; i++)
        input_string[i] = input_string[i+2];
      imm = -1;
      if (input_string[1] == '\0'){ // one hex char
	  	imm = 1*hexc_to_int(input_string[0]);
      }
      else if (input_string[2] == '\0'){ // two hex chars
	  	imm = 16*hexc_to_int(input_string[0]) + 1*hexc_to_int(input_string[1]);
      }
      else if (input_string[3] == '\0'){ // three hex chars
	  	imm = 256*hexc_to_int(input_string[0]) + 16*hexc_to_int(input_string[1]) + 1*hexc_to_int(input_string[2]);
      }
      else { // four hex chars
	  	imm = 4096*hexc_to_int(input_string[0]) + 256*hexc_to_int(input_string[1]) + 16*hexc_to_int(input_string[2]) + 1*hexc_to_int(input_string[3]);
      }
	  goto skip_analysis;
	}

	// extended immediate? (upper 16 bit of 32-bit label)
    if (input_string[0] == 'X') {
	  extended = true;
      for(i=0; i<31; i++)
        input_string[i] = input_string[i+1];  
    }

	// character?
	if ((input_string[0] == 39)){ // -> '
	  temp[0] = input_string[1];
	  temp[1] = '\0';
	  imm = (int)temp[0];
	  goto skip_analysis;
	}

	// any label reference definition?
	if ((input_string[0] == '[')){
	  for(i=1; i<strlen(input_string); i++){
	    if (input_string[i] != ']')
		  temp[i-1] = input_string[i];
		else{
		  temp[i-1] = '\0';
		  break;
		}
	  }
	  imm = ((find_offset(temp, -1)-2)*2);
	  goto skip_analysis;
	}

	// any low immediate definition?
	if ((input_string[0] == 'L') and (input_string[1] == 'O') and (input_string[2] == 'W') and (input_string[3] == '[')){
	  for(i=4; i<strlen(input_string); i++){
	    if (input_string[i] != ']')
		  temp[i-4] = input_string[i];
		else{
		  temp[i-4] = '\0';
		  break;
		}
	  }
	  // valid definition?
	  for (i=0; i<def_cnt; i++){
	    if (strcmp(temp, def_alias[i]) == 0){
	      strcpy(temp, definition[i]);
		  for (i=0; i<strlen(temp); i++)
		    temp[i] = temp[i+1];
		  if (extended == true)
		    imm = (atoi(temp) >> 16) & 255; // low immediate of 32-bit immediate
		  else
	        imm = atoi(temp) & 255; // low immediate
	      goto skip_analysis; // valid definition found
		}
	  }
	}

	// any high immediate definition?
	if ((input_string[0] == 'H') and (input_string[1] == 'I') and (input_string[2] == 'G') and (input_string[3] == 'H') and (input_string[4] == '[')){
	  for(i=5; i<strlen(input_string); i++){
	    if (input_string[i] != ']')
		  temp[i-5] = input_string[i];
		else{
		  temp[i-5] = '\0';
		  break;
		}
	  }
	  // valid definition?
	  for (i=0; i<def_cnt; i++){
	    if (strcmp(temp, def_alias[i]) == 0){
	      strcpy(temp, definition[i]);
		  for (i=0; i<strlen(temp); i++)
		    temp[i] = temp[i+1];
		  if (extended == true)
		    imm = (atoi(temp) >> 24) & 255; // high immediate of 32-bit immediate
		  else
	        imm = (atoi(temp) >> 8) & 255; // high immediate
	      goto skip_analysis; // valid definition found
		}
	  }
	}

    imm = atoi(input_string); // normal immediate

	// immediate REALTIVE LOW label-address?
	if ((input_string[0] == 'R') and (input_string[1] == 'L') and (input_string[2] == 'O') and (input_string[3] == 'W') and (input_string[4] == '[')){
	  for(i=5; i<31; i++){
	    if (input_string[i] != ']')
		  temp[i-5] = input_string[i];
		else{
		  temp[i-5] = '\0';
		  break;
		}
	  }
	  // inline math stuff?
	  offset = 0;
	  for(i=0; i<31; i++){
	  	if ((temp[i] == '+') or (temp[i] == '-')) {
	      if (temp[i] == '-')
	        offset = -1;
	      else
	        offset = +1;
	  	  temp[i] = '\0'; // terminate here
	  	  for (j=0; j<(31-i); j++)
	  	    num[j] = temp[i+j+1];
	  	  offset = offset * atoi(num);
	  	  break;
	    }
	  }
	  if (temp[0] == '#'){ // immediate
	    for(i=0; i<31; i++)
          temp[i] = temp[i+1];
		 if (extended == true)
		   imm = ((atoi(temp) + offset - line) >> 16) & 255; // low immediate of 32-bit immediate
		 else
	       imm = (atoi(temp) + offset - line) & 255; // low immediate
	  }
	  else { // label address
	    if (extended == true)
		  imm = (((find_offset(temp, -1)-line-1)*2+offset) >> 16) & 255; // low immediate of 32-bit immediate
		else
	      imm = ((find_offset(temp, -1)-line-1)*2+offset) & 255; // low immediate
	  }
	}
	// immediate REALTIVE HIGH label-address?
	if ((input_string[0] == 'R') and (input_string[1] == 'H') and (input_string[2] == 'I') and (input_string[3] == 'G') and (input_string[4] == 'H') and (input_string[5] == '[')){
	  for(i=6; i<31; i++){
	    if (input_string[i] != ']')
		  temp[i-6] = input_string[i];
		else{
		  temp[i-6] = '\0';
		  break;
		}
	  }
	  // inline math stuff?
	  offset = 0;
	  for(i=0; i<31; i++){
	  	if ((temp[i] == '+') or (temp[i] == '-')) {
	      if (temp[i] == '-')
	        offset = -1;
	      else
	        offset = +1;
	  	  temp[i] = '\0'; // terminate here
	  	  for (j=0; j<(31-i); j++)
	  	    num[j] = temp[i+j+1];
	  	  offset = offset * atoi(num);
	  	  break;
	    }
	  }
	  if (temp[0] == '#'){ // immediate
	    for(i=0; i<31; i++)
          temp[i] = temp[i+1];
		if (extended == true)
		  imm = ((atoi(temp) + offset - line) >> 24) & 255; // high immediate of 32-bit immediate
		else
	      imm = ((atoi(temp) + offset - line) >> 8) & 255; // high immediate
	  }
	  else{ // label address
	    if (extended == true)
		  imm = (((find_offset(temp, -1)-line-1)*2+offset) >> 24) & 255; // high immediate of 32-bit immediate
		else
	      imm = (((find_offset(temp, -1)-line-1)*2+offset) >> 8) & 255; // high immediate
	  }
	}

	// immediate LOW label-address?
	if ((input_string[0] == 'L') and (input_string[1] == 'O') and (input_string[2] == 'W') and (input_string[3] == '[')){
	  for(i=4; i<31; i++){
	    if (input_string[i] != ']')
		  temp[i-4] = input_string[i];
		else{
		  temp[i-4] = '\0';
		  break;
		}
	  }
	  // inline math stuff?
	  offset = 0;
	  for(i=0; i<31; i++){
	  	if ((temp[i] == '+') or (temp[i] == '-')) {
	      if (temp[i] == '-')
	        offset = -1;
	      else
	        offset = +1;
	  	  temp[i] = '\0'; // terminate here
	  	  for (j=0; j<(31-i); j++)
	  	    num[j] = temp[i+j+1];
	  	  offset = offset * atoi(num);
	  	  break;
	    }
	  }
	  if (temp[0] == '#'){ // immediate
	    for(i=0; i<31; i++)
          temp[i] = temp[i+1];
		 if (extended == true)
		   imm = ((atoi(temp) + offset) >> 16) & 255; // low immediate of 32-bit immediate
		 else
	       imm = (atoi(temp) + offset) & 255; // low immediate
	  }
	  else { // label address
	    if (extended == true)
		  imm = (((find_offset(temp, -1)-2)*2+offset) >> 16) & 255; // low immediate of 32-bit immediate
		else
	      imm = ((find_offset(temp, -1)-2)*2+offset) & 255; // low immediate
	  }
	}
	// immediate HIGH label-address?
	if ((input_string[0] == 'H') and (input_string[1] == 'I') and (input_string[2] == 'G') and (input_string[3] == 'H') and (input_string[4] == '[')){
	  for(i=5; i<31; i++){
	    if (input_string[i] != ']')
		  temp[i-5] = input_string[i];
		else{
		  temp[i-5] = '\0';
		  break;
		}
	  }
	  // inline math stuff?
	  offset = 0;
	  for(i=0; i<31; i++){
	  	if ((temp[i] == '+') or (temp[i] == '-')) {
	      if (temp[i] == '-')
	        offset = -1;
	      else
	        offset = +1;
	  	  temp[i] = '\0'; // terminate here
	  	  for (j=0; j<(31-i); j++)
	  	    num[j] = temp[i+j+1];
	  	  offset = offset * atoi(num);
	  	  break;
	    }
	  }
	  if (temp[0] == '#'){ // immediate
	    for(i=0; i<31; i++)
          temp[i] = temp[i+1];
		if (extended == true)
		  imm = ((atoi(temp) + offset) >> 24) & 255; // high immediate of 32-bit immediate
		else
	      imm = ((atoi(temp) + offset) >> 8) & 255; // high immediate
	  }
	  else{ // label address
	    if (extended == true)
		  imm = (((find_offset(temp, -1)-2)*2+offset) >> 24) & 255; // high immediate of 32-bit immediate
		else
	      imm = (((find_offset(temp, -1)-2)*2+offset) >> 8) & 255; // high immediate
	  }
	}

skip_analysis:

	// message
	//if (extended == true){
	//  printf("WARNING: Loading extended 32-bit immediate. (line %d)\n", line);
	//  warning_cnt++;
	//}

	// out of range?
    if ((imm > max_val) or (imm < 0)){
      printf("ERROR: Invalid immediate <%s>! (line %d)\n", input_string, line);
      error_cnt++;
    }

    return imm;
}


// *****************************************************************************************************************
// Get labels and locations
// *****************************************************************************************************************
void get_labels(const char *input_file){

    FILE *data_in;
    char line_input[512];
    int  index = 0;
    int  j = 0;
    int  line = 0;
    int  label_cnt = 0;
    char *cut_out;
    char line_string[256];

    // open input/output file
    data_in = fopen(input_file, "r");
    if(data_in == NULL){
      printf("GET_LABEL: Input file error_cnt!\n");
      exit(1);
    }

    // get line
    line = 1;
    while(fgets(line_input, 512, data_in) != NULL){

      // clear working string
      for(j=0; j<strlen(line_string); j++)
        line_string[j] = '\0';

      // get line entry
      cut_out = strtok(line_input, "\n");
      if (cut_out != NULL)
        sprintf(line_string, "%s", cut_out);

      // label present?
      for (index=0; index<512; index++){
        if (line_string[index] == ':'){
          strncpy(c_label_tab[label_cnt], line_string, index);
          index++;
          c_label_tab[label_cnt][index] = '\0';
          i_label_tab[label_cnt] = line;
          label_cnt++;
          index++;
          for(j=0; line_string[j+index] != '\0'; j++) // cut off
            line_string[j] = line_string[j+index];
          line_string[j] ='\0';
          break;
        }
      }

      line++;
    }

    fclose(data_in);

}



// *****************************************************************************************************************
// Assemble pre-processor file
// *****************************************************************************************************************
int assemble(const char *input_file, const char *output_file, const char *bin_output_file, const char *boot_output_file){

    FILE *data_in, *data_out, *bin_data_out, *boot_out;
    char line_input[512];
    int  index = 0;
    int  i = 0, j = 0;
    int  line = 0;
    char *cut_out;
    char line_string[256];
    char tmp_string[32];
    char buf_string[32];
    char arg[10][64];
    int opcode;
    int temp;

    // open input/output file
    data_in = fopen(input_file, "r");
    if(data_in == NULL){
      printf("ASSEMBLE: Input file error_cnt!\n");
      exit(1);
    }
    data_out = fopen(output_file, "w");
    if(data_out == NULL){
      printf("ASSEMBLE: Output file error!\n");
      exit(1);
    }
    bin_data_out = fopen(bin_output_file, "wb");
    if(bin_data_out == NULL){
      printf("ASSEMBLE: Binary output file error!\n");
      exit(1);
    }
    boot_out = fopen(boot_output_file, "wb");
    if(boot_out == NULL){
      printf("ASSEMBLE: Boot output file error!\n");
      exit(1);
    }

	// reserve memory for header (16 byte)
	for (i=0; i<16; i++)
		fputc(char(0), bin_data_out);
	for (i=0; i<8; i++)
		fputs("000000 => x\"0000\",\n", boot_out);

    // get line
    line = 1;
    while(fgets(line_input, 512, data_in) != NULL){

      // clear working string
      for(i=0; i<strlen(line_string); i++)
        line_string[i] = '\0';

      // clear argument list
      for(j=0; j<10; j++){
        for (i=0; i<64; i++)
          arg[j][i] = '\0';
      }

      // get line entry
      cut_out = strtok(line_input, "\n");
      if (cut_out != NULL)
        sprintf(line_string, "%s", cut_out);

	  // end of block?
	  if(line % 65535 == 0){
	    printf("WARNING: End of memory block! <%s> (line %d)\n", line_string, line);
		warning_cnt++;
	  }

      // label present?
      for (index=0; line_string[index] != '\0'; index++){
        if (line_string[index] == ':'){
          index+=2;
          for(j=0; line_string[j+index] != '\0'; j++) // cut off
            line_string[j] = line_string[j+index];
          line_string[j] ='\0';
          break;
        }
      }

      // get command and operands (9x)
      for (i=0; i<10; i++){
        for (index=0; index<512; index++){
          if (line_string[index] == ' '){
            strncpy(arg[i], line_string, index);
            index++;
            arg[i][index] = '\0';
            for(j=0; line_string[j+index] != '\0'; j++) // cut off
              line_string[j] = line_string[j+index];
            line_string[j] ='\0';
            break;
          }
        }
      }

      // translate line by line
      opcode = 0;
	  
	  // ALU Operations (without flag update)
	  // ---------------------------------------------------------------------------------------------------------
      if (strcmp(arg[0], "INC") == 0)
        opcode = (0<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_imm(arg[3], 7, line);
      else if (strcmp(arg[0], "DEC") == 0)
        opcode = (1<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_imm(arg[3], 7, line);
      else if (strcmp(arg[0], "ADD") == 0)
        opcode = (2<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      else if (strcmp(arg[0], "ADC") == 0)
        opcode = (3<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      else if (strcmp(arg[0], "SUB") == 0){
      	if (conv_reg(arg[2], line) == conv_reg(arg[3], line)) { printf("WARNING: Redundant SUB will result in NEG instruction! (line %d)\n", line); warning_cnt++;}
        opcode = (4<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      }
      else if (strcmp(arg[0], "NEG") == 0)
      	opcode = (4<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[2], line);
      else if (strcmp(arg[0], "SBC") == 0){
      	if (conv_reg(arg[2], line) == conv_reg(arg[3], line)) { printf("WARNING: Redundant SBC will result in NEC instruction! (line %d)\n", line); warning_cnt++;}
        opcode = (5<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      }
      else if (strcmp(arg[0], "NEC") == 0)
      	opcode = (5<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[2], line);
      else if ((strcmp(arg[0], "CMP") == 0) or (strcmp(arg[0], "CMPS") == 0))
        opcode = (6<<10) | (1<<3) | (conv_reg(arg[1], line)<<4) | conv_reg(arg[2], line);
      else if ((strcmp(arg[0], "CPX") == 0) or (strcmp(arg[0], "CPXS") == 0))
        opcode = (7<<10) | (1<<3) | (conv_reg(arg[1], line)<<4) | conv_reg(arg[2], line) | (conv_cpx_op(arg[3], line)<<7);
      else if (strcmp(arg[0], "AND") == 0){
	    if (conv_reg(arg[2], line) == conv_reg(arg[3], line)) { printf("WARNING: Redundant AND will result in STUB instruction! (line %d)\n", line); warning_cnt++;}
        opcode = (8<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
	  }
      else if (strcmp(arg[0], "STUB") == 0) // store register to user bank register
        opcode = (8<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[2], line);
      else if (strcmp(arg[0], "ORR") == 0){
	    if (conv_reg(arg[2], line) == conv_reg(arg[3], line)) { printf("WARNING: Redundant ORR will result in LDUB instruction! (line %d)\n", line); warning_cnt++;}
        opcode = (9<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
	  }
      else if (strcmp(arg[0], "LDUB") == 0) // load register from user bank register
        opcode = (9<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[2], line);
      else if (strcmp(arg[0], "EOR") == 0)
        opcode = (10<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      else if (strcmp(arg[0], "NAND") == 0)
        opcode = (11<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      else if (strcmp(arg[0], "BIC") == 0)
        opcode = (12<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      else if ((strcmp(arg[0], "TEQ") == 0) or (strcmp(arg[0], "TEQS") == 0))
        opcode = (13<<10) | (1<<3) | (conv_reg(arg[1], line)<<4) | conv_reg(arg[2], line);
      else if ((strcmp(arg[0], "TST") == 0) or (strcmp(arg[0], "TSTS") == 0))
        opcode = (14<<10) | (1<<3) | (conv_reg(arg[1], line)<<4) | conv_reg(arg[2], line);
      else if (strcmp(arg[0], "SFT") == 0)
        opcode = (15<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_shift(arg[3], line);
	  
	  // ALU Operations (with flag update)
	  // ---------------------------------------------------------------------------------------------------------
      else if (strcmp(arg[0], "INCS") == 0)
        opcode = (0<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_imm(arg[3], 7, line);
      else if (strcmp(arg[0], "DECS") == 0)
        opcode = (1<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_imm(arg[3], 7, line);
      else if (strcmp(arg[0], "ADDS") == 0)
        opcode = (2<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      else if (strcmp(arg[0], "ADCS") == 0)
        opcode = (3<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      else if (strcmp(arg[0], "SUBS") == 0){
      	  if (conv_reg(arg[2], line) == conv_reg(arg[3], line)) { printf("WARNING: Redundant SUBS will result in NEGS instruction! (line %d)\n", line); warning_cnt++;}
          opcode = (4<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
		}
      else if (strcmp(arg[0], "NEGS") == 0)
      	opcode = (4<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[2], line);
      else if (strcmp(arg[0], "SBCS") == 0){
      	  if (conv_reg(arg[2], line) == conv_reg(arg[3], line)) { printf("WARNING: Redundant SBCS will result in NECS instruction! (line %d)\n", line); warning_cnt++;}
          opcode = (5<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
		}
      else if (strcmp(arg[0], "NECS") == 0)
      	opcode = (5<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[2], line);
      else if (strcmp(arg[0], "LDSR") == 0) // load register from msr
        opcode = (6<<10) | (conv_reg(arg[1], line)<<7) | (conv_flag_op(arg[2], line)<<5);
      else if (strcmp(arg[0], "STSR") == 0) // store register to msr
        opcode = (7<<10)                               | (conv_flag_op(arg[2], line)<<5) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "STAF") == 0){ // store immediate to MSR's user/system ALU flags
        temp = conv_imm(arg[1], 63, line);
        opcode = (7<<10) | ((temp>>3)<<7) | (1<<6) | (conv_flag_op_2(arg[2], line)<<5) | (1<<4) | (temp & 7);
	  }
      else if (strcmp(arg[0], "ANDS") == 0){
	    if (conv_reg(arg[2], line) == conv_reg(arg[3], line)) { printf("WARNING: Redundant ANDS will result in STUBS instruction! (line %d)\n", line); warning_cnt++;}
        opcode = (8<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
	  }
      else if (strcmp(arg[0], "STUBS") == 0) // store register to user bank register and set flags
        opcode = (8<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[2], line);
      else if (strcmp(arg[0], "ORRS") == 0){
	    if (conv_reg(arg[2], line) == conv_reg(arg[3], line)) { printf("WARNING: Redundant ORRS will result in LDUBS instruction! (line %d)\n", line); warning_cnt++;}
        opcode = (9<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
	  }
      else if (strcmp(arg[0], "LDUBS") == 0) // load register from user bank register and set flags
        opcode = (9<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[2], line);
      else if (strcmp(arg[0], "EORS") == 0)
        opcode = (10<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      else if (strcmp(arg[0], "NANDS") == 0)
        opcode = (11<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
      else if (strcmp(arg[0], "BICS") == 0)
        opcode = (12<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line);
 
	  else if ((strcmp(arg[0], "STPC") == 0)    or (strcmp(arg[0], "GT") == 0)    or (strcmp(arg[0], "RET") == 0)) // goto [register]
        opcode = (13<<10) |          (conv_reg(arg[1], line)<<4);
	  else if ((strcmp(arg[0], "STPCL") == 0)   or (strcmp(arg[0], "GTL") == 0)   or (strcmp(arg[0], "RETL") == 0)) // goto [register] and link
        opcode = (13<<10) |          (conv_reg(arg[1], line)<<4) | (1<<2);
	  else if ((strcmp(arg[0], "STPCU") == 0)   or (strcmp(arg[0], "GTU") == 0)   or (strcmp(arg[0], "RETU") == 0)) // goto [register] and switch to user mode
        opcode = (13<<10) |          (conv_reg(arg[1], line)<<4) |                   (1<<0);
	  else if ((strcmp(arg[0], "STPCI") == 0)   or (strcmp(arg[0], "GTI") == 0)   or (strcmp(arg[0], "RETI") == 0)) // goto [register] and set global xint flag
        opcode = (13<<10) |          (conv_reg(arg[1], line)<<4) |          (1<<1);
	  else if ((strcmp(arg[0], "STPCUI") == 0)  or (strcmp(arg[0], "GTUI") == 0)  or (strcmp(arg[0], "RETUI") == 0)) // goto [register] and set global xint flag and switch to user mode
        opcode = (13<<10) |          (conv_reg(arg[1], line)<<4) |          (1<<1) | (1<<0);
	  else if ((strcmp(arg[0], "STPCUL") == 0)  or (strcmp(arg[0], "GTUL") == 0)  or (strcmp(arg[0], "RETUL") == 0)) // goto [register] and switch to user mode and link
        opcode = (13<<10) |          (conv_reg(arg[1], line)<<4) | (1<<2) |          (1<<0);
	  else if ((strcmp(arg[0], "STPCIL") == 0)  or (strcmp(arg[0], "GTIL") == 0)  or (strcmp(arg[0], "RETIL") == 0)) // goto [register] and set global xint flag and link
        opcode = (13<<10) |          (conv_reg(arg[1], line)<<4) | (1<<2) | (1<<1);
	  else if ((strcmp(arg[0], "STPCUIL") == 0) or (strcmp(arg[0], "GTUIL") == 0) or (strcmp(arg[0], "RETUIL") == 0)) // goto [register] and set global xint flag and switch to user mode and link
        opcode = (13<<10) |          (conv_reg(arg[1], line)<<4) | (1<<2) | (1<<1) | (1<<0);
	  else if ((strcmp(arg[0], "STPCX") == 0)   or (strcmp(arg[0], "GTX") == 0)   or (strcmp(arg[0], "RETX") == 0)) // goto [register] and switch to previous mode
        opcode = (13<<10) | (1<<7) | (conv_reg(arg[1], line)<<4);
	  else if ((strcmp(arg[0], "STPCXI") == 0)  or (strcmp(arg[0], "GTXI") == 0)  or (strcmp(arg[0], "RETXI") == 0)) // goto [register] and set global xint flag and switch to previous mode
        opcode = (13<<10) | (1<<7) | (conv_reg(arg[1], line)<<4) |          (1<<1);
	  else if ((strcmp(arg[0], "STPCXL") == 0)  or (strcmp(arg[0], "GTXL") == 0)  or (strcmp(arg[0], "RETXL") == 0)) // goto [register] and switch to previous mode and link
        opcode = (13<<10) | (1<<7) | (conv_reg(arg[1], line)<<4) | (1<<2);
	  else if ((strcmp(arg[0], "STPCXIL") == 0) or (strcmp(arg[0], "GTXIL") == 0) or (strcmp(arg[0], "RETXIL") == 0)) // goto [register] and set global xint flag and switch to previous mode and link
        opcode = (13<<10) | (1<<7) | (conv_reg(arg[1], line)<<4) | (1<<2) | (1<<1);
 
	  else if (strcmp(arg[0], "LDPC") == 0) // load program counter to register
        opcode = (14<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[1], line)<<4);
      else if (strcmp(arg[0], "SFTS") == 0)
        opcode = (15<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_shift(arg[3], line);
	  
	  // Branch
	  // ---------------------------------------------------------------------------------------------------------
      else if ((strcmp(arg[0], "B") == 0) or (strcmp(arg[0], "BAL") == 0)) // branch always
        opcode = (1<<15) | (15<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BEQ") == 0) // branch if equal
        opcode = (1<<15) | (0<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BNE") == 0) // branch if not equal
        opcode = (1<<15) | (1<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BCS") == 0) // branch if unsigned higher or same
        opcode = (1<<15) | (2<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BCC") == 0) // branch if unsigned lower
        opcode = (1<<15) | (3<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BMI") == 0) // branch if negative
        opcode = (1<<15) | (4<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BPL") == 0) // branch if positive or zero
        opcode = (1<<15) | (5<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BOS") == 0) // branch if overflow
        opcode = (1<<15) | (6<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BOC") == 0) // branch if no overflow
        opcode = (1<<15) | (7<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BHI") == 0) // branch if unsigned higher
        opcode = (1<<15) | (8<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLS") == 0) // branch if unsigned lower or same
        opcode = (1<<15) | (9<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BGE") == 0) // branch if greater than or equal
        opcode = (1<<15) | (10<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLT") == 0) // branch if less than
        opcode = (1<<15) | (11<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BGT") == 0) // branch if greater than
        opcode = (1<<15) | (12<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLE") == 0) // branch if less than or equal
        opcode = (1<<15) | (13<<10) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BTS") == 0) // branch if transfer flag set
        opcode = (1<<15) | (14<<10) | find_offset(arg[1], line);
	  
	  // Branch and link
	  // ---------------------------------------------------------------------------------------------------------
      else if ((strcmp(arg[0], "BL") == 0) or (strcmp(arg[0], "BALL") == 0)) // branch and link always
        opcode = (1<<15) | (15<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLEQ") == 0) // branch and link if equal
        opcode = (1<<15) | (0<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLNE") == 0) // branch and link if not equal
        opcode = (1<<15) | (1<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLCS") == 0) // branch and link if unsigned higher or same
        opcode = (1<<15) | (2<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLCC") == 0) // branch and link if unsigned lower
        opcode = (1<<15) | (3<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLMI") == 0) // branch and link if negative
        opcode = (1<<15) | (4<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLPL") == 0) // branch and link if positive or zero
        opcode = (1<<15) | (5<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLOS") == 0) // branch and link if overflow
        opcode = (1<<15) | (6<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLOC") == 0) // branch and link if no overflow
        opcode = (1<<15) | (7<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLHI") == 0) // branch and link if unsigned higher
        opcode = (1<<15) | (8<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLLS") == 0) // branch and link if unsigned lower or same
        opcode = (1<<15) | (9<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLGE") == 0) // branch and link if greater than or equal
        opcode = (1<<15) | (10<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLLT") == 0) // branch and link if less than
        opcode = (1<<15) | (11<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLGT") == 0) // branch and link if greater than
        opcode = (1<<15) | (12<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLLE") == 0) // branch and link if less than or equal
        opcode = (1<<15) | (13<<10) | (1<<9) | find_offset(arg[1], line);
      else if (strcmp(arg[0], "BLTS") == 0) // branch and link if transfer flag set
        opcode = (1<<15) | (14<<10) | (1<<9) | find_offset(arg[1], line);
	  
	  // Load immediate
	  // ---------------------------------------------------------------------------------------------------------
      else if ((strcmp(arg[0], "LDIL") == 0) or (strcmp(arg[0], "LDIH") == 0)){
		temp = conv_imm(arg[2], 255, line);
	    if (strcmp(arg[0], "LDIL") == 0) // load whole register with sign extended immediate
          opcode = (3<<14) | (0<<11) | ((temp & 128)<<3) | (conv_reg(arg[1], line)<<7) | (temp & 127);
        else if (strcmp(arg[0], "LDIH") == 0) // only load high byte of register with immediate
          opcode = (3<<14) | (1<<11) | ((temp & 128)<<3) | (conv_reg(arg[1], line)<<7) | (temp & 127);
	  }
	  
	  // Bit operations
	  // ---------------------------------------------------------------------------------------------------------
      else if (strcmp(arg[0], "SBR") == 0) // set select-bit
        opcode = (13<<12) | (0<<11) | (1<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_imm(arg[3], 15, line);
      else if (strcmp(arg[0], "CBR") == 0) // clear select-bit
        opcode = (13<<12) | (0<<11) | (0<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_imm(arg[3], 15, line);
      else if (strcmp(arg[0], "STB") == 0) // store select-bit to t-flag
        opcode = (13<<12) | (1<<11) | (1<<10) | (0<<7)                      | (conv_reg(arg[1], line)<<4) | conv_imm(arg[2], 15, line);
      else if (strcmp(arg[0], "STBI") == 0) // store inverted select-bit to t-flag
        opcode = (13<<12) | (1<<11) | (1<<10) | (1<<7)                      | (conv_reg(arg[1], line)<<4) | conv_imm(arg[2], 15, line);
      else if (strcmp(arg[0], "SPR") == 0) // store parity-bit to t-flag
        opcode = (13<<12) | (1<<11) | (1<<10) | (1<<8) | (0<<7)             | (conv_reg(arg[1], line)<<4) | conv_imm(arg[2], 15, line);
      else if (strcmp(arg[0], "STBR") == 0) // store select-bit to t-flag (index by register)
        opcode = (13<<12) | (1<<11) | (1<<10) | (1<<9) | (0<<7)             | (conv_reg(arg[1], line)<<4) | conv_reg(arg[2], line);
      else if (strcmp(arg[0], "STBRI") == 0) // store inverted select-bit to t-flag (index by register)
        opcode = (13<<12) | (1<<11) | (1<<10) | (1<<9) | (1<<7)             | (conv_reg(arg[1], line)<<4) | conv_reg(arg[2], line);
      else if (strcmp(arg[0], "LDB") == 0) // load select-bit form t-flag
        opcode = (13<<12) | (1<<11) | (0<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | conv_imm(arg[3], 15, line);

	  // System call
	  // ---------------------------------------------------------------------------------------------------------
      else if (strcmp(arg[0], "SYSCALL") == 0){ // trigger software interrupt trap
	    if (strcmp(arg[1], "") == 0)
		  temp = 0;
		else
		  temp = conv_imm(arg[1], 1023, line);
		opcode = (63<<10) | temp; // 10-bit system call tag
	  }
	  
	  // Memory Access
	  // ---------------------------------------------------------------------------------------------------------
      else if (strcmp(arg[0], "LDR") == 0){ // load register
        opcode = (1<<14) | (0<<10) | (conv_reg(arg[1], line)<<7); // mem_access, load, data register
		opcode = opcode | (conv_reg(arg[2], line)<<4); // base register
		opcode = opcode | (conv_indexing(arg[4], line)<<13); // indexing mode
		if (arg[3][0] == '+') // add indexing
          opcode = opcode | (1<<12);
		if (arg[3][1] == '#') // immediate offset
		  opcode = opcode | (1<<3) | conv_imm(arg[3], 7, line);
		else // register offset
		  opcode = opcode | conv_reg(arg[3], line);
		if (arg[5][0] == '!') // write back base register
		  opcode = opcode | (1<<11);
		else{
		  if ((conv_indexing(arg[4], line)==1) and (arg[5][0] != '!')){
		    printf("WARNING: Redundant LDR indexing instruction. (line %d)\n", line);
	        warning_cnt++;
		  }
		}
	  }
      else if (strcmp(arg[0], "STR") == 0){ // store register
        opcode = (1<<14) | (1<<10) | (conv_reg(arg[1], line)<<7); // mem_access, store, data register
		opcode = opcode | (conv_reg(arg[2], line)<<4); // base register
		opcode = opcode | (conv_indexing(arg[4], line)<<13); // indexing mode
		if (arg[3][0] == '+') // add indexing
          opcode = opcode | (1<<12);
		if (arg[3][1] == '#') // immediate offset
		  opcode = opcode | (1<<3) | conv_imm(arg[3], 7, line);
		else // register offset
		  opcode = opcode | conv_reg(arg[3], line);
		if (arg[5][0] == '!') // write back base register
		  opcode = opcode | (1<<11);
		else{
		  if ((conv_indexing(arg[4], line)==1) and (arg[5][0] != '!')){
		    printf("WARNING: Redundant STR indexing instruction. (line %d)\n", line);
	        warning_cnt++;
		  }
		}
	  }
	  else if (strcmp(arg[0], "SWP") == 0){ // data swap: Rd -> MEM[Rb] -> Rd
        opcode = (1<<14) | (conv_reg(arg[1], line)<<7); // mem_access, load_data register
		opcode = opcode | (conv_reg(arg[2], line)<<4) | conv_reg(arg[3], line); // base register, store_data register
		opcode = opcode | (1<<13) | (0<<11); // indexing mode = post and NO write back = redundant to mark swap operation
	  }

	  // Coprocessor Access
	  // ---------------------------------------------------------------------------------------------------------
      else if (strcmp(arg[0], "CDP") == 0){ // coprocessor data processing
	    opcode = (14<<12) | (conv_imm(arg[1], 1, line)<<10) | (conv_cpreg(arg[2], line)<<7);
		opcode = opcode | (conv_cpreg(arg[3], line)<<4) | conv_imm(arg[4], 7, line);
	  }
	  else if (strcmp(arg[0], "MRC") == 0){ // move data from coprocessor
	    opcode = (14<<12) | (1<<11) | (conv_imm(arg[1], 1, line)<<10) | (conv_reg(arg[2], line)<<7);
		opcode = opcode | (conv_cpreg(arg[3], line)<<4) | (0<<3) | conv_imm(arg[4], 7, line);
	  }
	  else if (strcmp(arg[0], "MCR") == 0){ // move data to coprocessor
	    opcode = (14<<12) | (1<<11) | (conv_imm(arg[1], 1, line)<<10) | (conv_cpreg(arg[2], line)<<7);
		opcode = opcode | (conv_reg(arg[3], line)<<4)   | (1<<3) | conv_imm(arg[4], 7, line);
	  }

	  // Special Commands
	  // ---------------------------------------------------------------------------------------------------------
      else if (strcmp(arg[0], "SLEEP") == 0){ // go to sleep
	    if (strcmp(arg[1], "") == 0)
		  temp = 0;
		else
		  temp = conv_imm(arg[1], 511, line);
		opcode = (61<<10) | (0<<9) | temp; // +9-bit tag
	  }
      else if (strcmp(arg[0], "RBAEQ") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | ( 0<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBANE") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | ( 1<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBACS") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | ( 2<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBACC") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | ( 3<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBAMI") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | ( 4<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBAPL") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | ( 5<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBAVS") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | ( 6<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBAVC") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | ( 7<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBAHI") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | ( 8<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALS") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | ( 9<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBAGE") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | (10<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALT") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | (11<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBAGT") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | (12<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALE") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | (13<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBATS") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | (14<<3) | (conv_reg(arg[1], line)<<0);
      else if ((strcmp(arg[0], "RBA") == 0) or (strcmp(arg[0], "RBAAL") == 0)) // register-base branch absolute - always
		opcode = (61<<10) | (1<<9) | (1<<8) | (0<<7) | (15<<3) | (conv_reg(arg[1], line)<<0);

      else if (strcmp(arg[0], "RBREQ") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | ( 0<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRNE") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | ( 1<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRCS") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | ( 2<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRCC") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | ( 3<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRMI") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | ( 4<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRPL") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | ( 5<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRVS") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | ( 6<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRVC") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | ( 7<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRHI") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | ( 8<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLS") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | ( 9<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRGE") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | (10<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLT") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | (11<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRGT") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | (12<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLE") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | (13<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRTS") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | (14<<3) | (conv_reg(arg[1], line)<<0);
      else if ((strcmp(arg[0], "RBR") == 0) or (strcmp(arg[0], "RBRAL") == 0)) // register-base branch relative - always
		opcode = (61<<10) | (1<<9) | (0<<8) | (0<<7) | (15<<3) | (conv_reg(arg[1], line)<<0);

      else if (strcmp(arg[0], "RBALEQ") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | ( 0<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALNE") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | ( 1<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALCS") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | ( 2<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALCC") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | ( 3<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALMI") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | ( 4<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALPL") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | ( 5<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALVS") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | ( 6<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALVC") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | ( 7<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALHI") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | ( 8<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALLS") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | ( 9<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALGE") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | (10<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALLT") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | (11<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALGT") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | (12<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALLE") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | (13<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBALTS") == 0)
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | (14<<3) | (conv_reg(arg[1], line)<<0);
      else if ((strcmp(arg[0], "RBAL") == 0) or (strcmp(arg[0], "RBALAL") == 0)) // register-base branch absolute & link - always
		opcode = (61<<10) | (1<<9) | (1<<8) | (1<<7) | (15<<3) | (conv_reg(arg[1], line)<<0);

      else if (strcmp(arg[0], "RBRLEQ") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | ( 0<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLNE") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | ( 1<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLCS") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | ( 2<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLCC") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | ( 3<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLMI") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | ( 4<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLPL") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | ( 5<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLVS") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | ( 6<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLVC") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | ( 7<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLHI") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | ( 8<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLLS") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | ( 9<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLGE") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | (10<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLLT") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | (11<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLGT") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | (12<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLLE") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | (13<<3) | (conv_reg(arg[1], line)<<0);
      else if (strcmp(arg[0], "RBRLTS") == 0)
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | (14<<3) | (conv_reg(arg[1], line)<<0);
      else if ((strcmp(arg[0], "RBRL") == 0) or (strcmp(arg[0], "RBRLAL") == 0)) // register-base branch relative & link - always
		opcode = (61<<10) | (1<<9) | (0<<8) | (1<<7) | (15<<3) | (conv_reg(arg[1], line)<<0);

	  // MUL-Instructions
	  // ---------------------------------------------------------------------------------------------------------
      else if (strcmp(arg[0], "MUL") == 0) // 16-bit multiplication result
		opcode = (15<<12) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | (0<<3)  | (conv_reg(arg[3], line)<<0);
      else if (strcmp(arg[0], "MULH") == 0) // 32-bit multiplication high result
		opcode = (15<<12) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | (1<<3)  | (conv_reg(arg[3], line)<<0);

	  // Pseudo-Instructions
	  // ---------------------------------------------------------------------------------------------------------
	  else if (strcmp(arg[0], "NOP") == 0) // dummy operation (no actual system state change)
        opcode = 0; // actually this is an increment with a zero immediate and no flag update
      else if (strcmp(arg[0], "MOV") == 0) // increment with #0 = move register
        opcode = (0<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | 0;
      else if (strcmp(arg[0], "MOVS") == 0) // increment with #0 = move register and flag update
        opcode = (0<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[2], line)<<4) | 0;
      else if (strcmp(arg[0], "CLR") == 0) // set register to 0
        opcode = (10<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[1], line)<<4) | conv_reg(arg[1], line);
      else if (strcmp(arg[0], "CLRS") == 0) // set register to 0 and set flags
        opcode = (10<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[1], line)<<4) | conv_reg(arg[1], line);
      else if (strcmp(arg[0], "COM") == 0) // 1's complement
        opcode = (11<<10) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[1], line)<<4) | conv_reg(arg[1], line);
      else if (strcmp(arg[0], "COMS") == 0) // 1's complement and set flags
        opcode = (11<<10) | (1<<3) | (conv_reg(arg[1], line)<<7) | (conv_reg(arg[1], line)<<4) | conv_reg(arg[1], line);
      else if (strcmp(arg[0], "PUSH+") == 0) // push on positive growing stack
	     opcode = (1<<14) | (1<<13) | (1<<12) | (1<<11) | (1<<10) | (conv_reg(arg[1], line)<<7) | (6<<4) | (1<<3) | (2<<0);
      else if (strcmp(arg[0], "POP+") == 0) // pop from positive growing stack
	     opcode = (1<<14) | (0<<13) | (0<<12) | (1<<11) | (0<<10) | (conv_reg(arg[1], line)<<7) | (6<<4) | (1<<3) | (2<<0);
      else if (strcmp(arg[0], "PEEK") == 0) // pushpop from/on stack
	     opcode = (1<<14) | (0<<13) | (1<<12) | (0<<11) | (0<<10) | (conv_reg(arg[1], line)<<7) | (6<<4) | (1<<3) | (2<<0);
      else if (strcmp(arg[0], "PUSH") == 0) // push on negative growing stack
	     opcode = (1<<14) | (1<<13) | (0<<12) | (1<<11) | (1<<10) | (conv_reg(arg[1], line)<<7) | (6<<4) | (1<<3) | (2<<0);
      else if (strcmp(arg[0], "POP") == 0) // pop from negative growing stack
	     opcode = (1<<14) | (0<<13) | (1<<12) | (1<<11) | (0<<10) | (conv_reg(arg[1], line)<<7) | (6<<4) | (1<<3) | (2<<0);

	  // Direct memory initialization
	  // ---------------------------------------------------------------------------------------------------------
      else if (strcmp(arg[0], ".DW") == 0) // memory init (word)
	     opcode = conv_imm(arg[1], (int)(pow(2,16)-1), line);

	  // Conditional move instructions
	  // ---------------------------------------------------------------------------------------------------------
      else if (strcmp(arg[0], "MVEQ") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | ( 0<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVNE") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | ( 1<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVCS") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | ( 2<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVCC") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | ( 3<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVMI") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | ( 4<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVPL") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | ( 5<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVOS") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | ( 6<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVOC") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | ( 7<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVHI") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | ( 8<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVLS") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | ( 9<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVGE") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | (10<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVLT") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | (11<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVGT") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | (12<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVLE") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | (13<<3) | (conv_reg(arg[2], line)<<0);
      else if (strcmp(arg[0], "MVTS") == 0)
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | (14<<3) | (conv_reg(arg[2], line)<<0);
      else if ((strcmp(arg[0], "MV") == 0) or (strcmp(arg[0], "MVAL") == 0))
		opcode = (62<<10) | (conv_reg(arg[1], line)<<7) | (15<<3) | (conv_reg(arg[2], line)<<0);

	  // Unknown Command
	  // ---------------------------------------------------------------------------------------------------------
	  else {
         printf("ERROR: Unknown command <%s>! (line %d)\n", arg[0], line);
         error_cnt++;
	  }


	  opcode = opcode & (int(pow(2, 16))-1); // only 16-bit, thanks

	  if (error_cnt == 0) {
	    // init file output
	    sprintf(tmp_string, "%06d => x\"%04x\", -- %s\n", line-1, opcode, arg[0]);
        fputs(tmp_string, data_out);
	    // binary data file output
	    fputc(char((opcode>>8)&255), bin_data_out);
	    fputc(char(opcode&255),      bin_data_out);
	    // boot image output
	    sprintf(buf_string, "%06d => x\"%04x\",\n", line-1+8, opcode);
		fputs(buf_string, boot_out);
		// compute xor-checksum
		xor_checksum = xor_checksum xor opcode;
		xor_checksum = xor_checksum & (int)(pow(2, 16)-1);
      }

      line++;
    }

	if (error_cnt == 0){
	  fputs("others => x\"0000\"  -- NOP", data_out);
	  fputs("others => x\"0000\"", boot_out);
	}

	// build header
	rewind(bin_data_out);
	rewind(boot_out);

	// bootfile signature
	fputc(char(((51966)>>8)&255), bin_data_out);
	fputc(char((51966)&255),      bin_data_out);
	sprintf(buf_string, "000000 => x\"%04x\",\n", 51966); fputs(buf_string, boot_out);

	// program size (words)
	fputc(char(((line-1)>>8)&255), bin_data_out);
	fputc(char((line-1)&255),      bin_data_out);
	sprintf(buf_string, "000001 => x\"%04x\",\n", line-1); fputs(buf_string, boot_out);

	// xor-checksum
	fputc(char(((xor_checksum)>>8)&255), bin_data_out);
	fputc(char((xor_checksum)&255),      bin_data_out);
	sprintf(buf_string, "000002 => x\"%04x\",\n", xor_checksum); fputs(buf_string, boot_out);

	// image name
	for(i=0; i<10; i++)
		fputc(char((image_name[i])&255), bin_data_out);
	for(i=0; i<10; i+=2){
	  sprintf(buf_string, "%06d => x\"%04x\",\n", i/2+3, (((int)(image_name[i]&255))<<8)|(((int)(image_name[i+1]&255))));
	  fputs(buf_string, boot_out);
	}
	
	 
    fclose(bin_data_out);
    fclose(data_out);
    fclose(data_in);
    fclose(boot_out);
	
	return line;
}


// *****************************************************************************************************************
// Main function
// *****************************************************************************************************************
int main(int argc, char *argv[]){

	int p_size = 0;
	int i = 0;

    printf("ATLAS 2k Assembler, Version 2014.05.11\n");
    printf("by Stephan Nolting (stnolting@gmail.com), Hanover, Germany\n");
    printf("www.opencores.org/project,atlas_core\n\n");

	// save image name
	if (argv[2] != '\0'){
		for(i=0; i<10; i++)
			image_name[i] = char(argv[2][i]);
	}
	else{
		for(i=0; i<10; i++)
			image_name[i] = '\0';
	}

	// pre_processor.asm - intermediate processing file
	// init.vhd - vhdl memory initialization data block
	// out.bin - binary program output for bootloader downloading

	includer(argv[1], "included.xasm"); // include other files - copy them to work file
	convert_strings("included.xasm", "job.xasm"); // convert strings into direct memory inits
    pre_processor("job.xasm", "pre_processor.asm"); // erase comments & empty lines & get definitions
    get_labels("pre_processor.asm"); // find and list labels
	p_size = assemble("pre_processor.asm", "init.vhd", "out.bin", "boot_init.vhd"); // do the magic conversion

	if (error_cnt == 0){
	  printf("\nAssembler completed without errors (%d warnings)\n", warning_cnt);
	  printf("Image size:    0x%04X (%d) bytes\n", (p_size-1)*2, (p_size-1)*2);
	  printf("XOR check sum: 0x%04X\n", xor_checksum);
	  printf("Image name:    ");
	  if (image_name[0] != '\0'){
	  	for(i=0; i<10;i++)
	  		printf("%c", image_name[i]);
	  	printf("\n");
	  }
	  else
	  	printf("-\n");
	  if (warning_cnt != 0)
	    printf("Line numbers refer to the intermediate \"pre_processor.asm\" processing file.\n");
    }
	else{
	  printf("\nAssembler terminated with %d errors (%d warnings)!\n", error_cnt, warning_cnt);
	  printf("Line numbers refer to the intermediate \"pre_processor.asm\" processing file.\n");
	}

    return 0;
}
