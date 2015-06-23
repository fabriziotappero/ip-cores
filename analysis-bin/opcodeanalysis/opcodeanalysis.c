/*
  Instruction opcode frequency analysis application

  Author:
  Julius Baxter - julius.baxter@orsoc.se

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Opcode space in OR1K is 32-bits, so maximum 64 opcodes
#define MAX_OR1K_32_OPCODES 64
// Array of opcode string pointers (we malloc space for actual strings)
char *opcode_strings[MAX_OR1K_32_OPCODES];
// Count for occurance of each opcode
int opcode_count[MAX_OR1K_32_OPCODES];

// Maximum number of pairs to keep track of
#define MAX_OR1K_32_PAIRS (MAX_OR1K_32_OPCODES*MAX_OR1K_32_OPCODES)
// 2-dimensional array, long enough to hold all possible pairs, and the 2
// indexes corresponding to their opcode in the *opcode_strings[] array
// Ie. Each will be: [previous_opcode][current_opcode][count]
int opcode_pairs[MAX_OR1K_32_PAIRS][3];

// Maximum number of triplets to kep track of
#define MAX_OR1K_32_TRIPLETS (MAX_OR1K_32_OPCODES*MAX_OR1K_32_OPCODES*MAX_OR1K_32_OPCODES)
// 2-dimensional array, long enough to hold all possible pairs, and the 2
// indexes corresponding to their opcode in the *opcode_strings[] array
// Ie. Each will be: 
//      [second_prev][first_prev][current_opcode][count]
int opcode_triplets[MAX_OR1K_32_TRIPLETS][4];

// Maximum number of quadruples to keep track of
#define MAX_OR1K_32_QUADS (MAX_OR1K_32_OPCODES*MAX_OR1K_32_OPCODES*MAX_OR1K_32_OPCODES*MAX_OR1K_32_OPCODES)
// 2-dimensional array, long enough to hold all possible pairs, and the 2
// indexes corresponding to their opcode in the *opcode_strings[] array
// Ie. Each will be: 
//  [third_prev][second_prev][first_prev][current_opcode][count]
int opcode_quads[MAX_OR1K_32_QUADS][5];

// Strings shouldn't be more than 32 bytes long
#define OPCODE_STRING_SIZE 32

// Indicator for an opcode we haven't seen before
#define IS_UNIQUE -1

// Result defines
#define SORTED_DESCENDING_DISPLAY

// Style of output  - String or CSV
// Uncomment only 1!
#define DISPLAY_STRING
//#define DISPLAY_CSV

// Report only the 10 most common pairs/triples/quadruples, etc
#define MAX_SETS_TO_REPORT 10

// Little function to strip newlines
inline void strip_newline(char* str)
{
  int len = strlen(str);
  if (str[len-1] == '\n')
    str[len-1] = '\0';
  
}

// Return the position in the index this instruction is at
// else -1 if it isn't
int check_opcode(char *opcode_to_check, int num_opcodes_so_far)
{
  // Get stringlength of current instruction
  int opcode_strlen = strlen(opcode_to_check);
  
  int i = 0;
  // Loop for all opcodes we have so far
  while (i < num_opcodes_so_far)
    {
      // Do we have a match?
      // Debugging output
      //printf("Comparing: %s (%d) == %s (%d) ?\n", 
      //	     opcode_to_check, opcode_strlen,
      //             opcode_strings[i], strlen(opcode_strings[i]));
      if ((strncmp(opcode_to_check, opcode_strings[i], opcode_strlen) == 0)
	  && (strlen(opcode_strings[i]) == opcode_strlen))
	// Found a match - return its index
	return i;
      // No match yet, go to next opcode
      i++;
    }
  // No opcodes found, indicate it's one we haven't seen before
  return IS_UNIQUE;
}

// Record an opcode in our list of known opcodes
void add_opcode(char *opcode_to_add, int num_opcodes_so_far)
{
  int opcode_strlen = strlen(opcode_to_add);
  
  // Malloc space to hold the new opcode string
  char *new_opcode;
  new_opcode = (char*) calloc(OPCODE_STRING_SIZE, 1);
  
  // Copy in opcode string
  strncpy(new_opcode, opcode_to_add, opcode_strlen);
  
  // Now store the pointer to this new opcode string
  opcode_strings[num_opcodes_so_far] = new_opcode;

  // Initialise count
  opcode_count[num_opcodes_so_far] = 1;

  return;  
}

// Increment the count for this opcode
void count_opcode(int opcode_index)
{
  opcode_count[opcode_index]++;

  return;
}



void display_opcodes(int total_unique_opcodes, int total_opcodes_counted)
{

#ifdef DISPLAY_STRING  
  // Totals
  printf("Number of total opcodes: %d\n",total_opcodes_counted);
  printf("Number unique opcodes: %d\n", total_unique_opcodes);
#endif
#ifdef DISPLAY_CSV
  printf("\"Opcode\",\"Occurances\",\"%%'age of total\",\"Total opcodes counted:\",%d\n",total_opcodes_counted);
#endif

#ifdef SIMPLE_DISPLAY  
  while (total_unique_opcodes)
    {
      --total_unique_opcodes;
      printf("Opcode:\t%s\tCount:\t%d\n",
	     opcode_strings[total_unique_opcodes],
	     opcode_count[total_unique_opcodes]);
    }
#endif
#ifdef SORTED_DESCENDING_DISPLAY
  int i, largest, largest_index;
  int initial_total = total_unique_opcodes;
  while (total_unique_opcodes)
    {
      --total_unique_opcodes;
      largest=0;
      // Go through the list, find the largest, print it, eliminate it
      for(i=0;i<initial_total;i++)
	if(opcode_count[i] > largest)
	  {
	    largest = opcode_count[i];
	    largest_index = i;
	  }

      printf(
#ifdef DISPLAY_STRING      
	     "Opcode:\t%s\tCount:\t%d\t(%f%%)\n",
#endif
#ifdef DISPLAY_CSV
	     // CSV format - "opcode string",frequency,percentage
	     "\"%s\",%d,%f\n",
#endif
	     opcode_strings[largest_index],
	     opcode_count[largest_index],
	     (float)(((float)opcode_count[largest_index])/
		     ((float)total_opcodes_counted))*100.f);
      

      opcode_count[largest_index] = -1; // Eliminate this one
      
    }
#endif

  
}

// Deal with opcode pair checking
int opcode_pair_check( int previous_opcode_index, int current_opcode_index,
		       int total_pairs )
{
  int i;
  // Check through for this pair's occurance before
  for (i=0;i<total_pairs;i++)
    {
      if ((opcode_pairs[i][0] == previous_opcode_index) &&
	  (opcode_pairs[i][1] == current_opcode_index))
	// Found a match
	{
	  opcode_pairs[i][2]++;
	  return 0;
	}
    }
  // No match, let's create a new entry
  // Index for previous opcode
  opcode_pairs[total_pairs][0] = previous_opcode_index;
  // Index for current opcode
  opcode_pairs[total_pairs][1] = current_opcode_index;
  // Count for this pair
  opcode_pairs[total_pairs][2] = 1;
  
  return 1;
  
}


void opcode_pair_report(int total_opcode_sets)
{

  int i, largest, largest_index;
  int initial_total = total_opcode_sets;

#ifdef DISPLAY_STRING 
  printf("Number of unique opcode pairs: %d\n", total_opcode_sets);
#endif
#ifdef DISPLAY_CSV
  printf("\"Opcode pair\",\"Occurances\",\"Total unique pairs:\",%d\n", 
	 total_opcode_sets);
#endif

  while (total_opcode_sets)
    {
      --total_opcode_sets;
      largest=0;
      // Go through the list, find the largest, print it, eliminate it
      for(i=0;i<initial_total;i++)
	if(opcode_pairs[i][2] > largest)
	  {
	    largest = opcode_pairs[i][2];
	    largest_index = i;
	  }
      printf(
#ifdef DISPLAY_STRING            
	     "Opcode pair:\t%s\t%s\tCount:\t%d\n",
#endif
#ifdef DISPLAY_CSV
	     "\"%s %s\",%d\n",
#endif

	     opcode_strings[opcode_pairs[largest_index][0]],
	     opcode_strings[opcode_pairs[largest_index][1]],
	     opcode_pairs[largest_index][2]);


      opcode_pairs[largest_index][2] = -1; // Eliminate this one

      // If we've printed out the maximum we wanted then return
      if ((initial_total - total_opcode_sets) == MAX_SETS_TO_REPORT)
	return;
      
      
    }

  
}

// Deal with opcode triplet checking
int opcode_triplet_check(int second_previous_opcode_index,  
			 int previous_opcode_index, 
			 int current_opcode_index,
			 int sets_so_far )
{
  int i;
  // Check through for this pair's occurance before
  for (i=0;i<sets_so_far;i++)
    {
      if ((opcode_triplets[i][0] == second_previous_opcode_index) &&
	  (opcode_triplets[i][1] == previous_opcode_index) &&
	  (opcode_triplets[i][2] == current_opcode_index))
	
	// Found a match
	{
	  opcode_triplets[i][3]++;
	  return 0;
	}
    }
  // No match, let's create a new entry
  opcode_triplets[sets_so_far][0] = second_previous_opcode_index;
  // Index for previous opcode
  opcode_triplets[sets_so_far][1] = previous_opcode_index;
  // Index for current opcode
  opcode_triplets[sets_so_far][2] = current_opcode_index;
  // Count for this pair
  opcode_triplets[sets_so_far][3] = 1;
  
  return 1;
  
}

void opcode_triplet_report(int total_opcode_sets)
{

  int i, largest, largest_index;
  int initial_total = total_opcode_sets;

#ifdef DISPLAY_STRING 
  printf("Number of unique opcode triplets: %d\n", total_opcode_sets);
#endif
#ifdef DISPLAY_CSV
  printf("\"Opcode triplet\",\"Occurances\",\"Total unique triplets:\",%d\n", 
	 total_opcode_sets);
#endif

  while (total_opcode_sets)
    {
      --total_opcode_sets;
      largest=0;
      // Go through the list, find the largest, print it, eliminate it
      for(i=0;i<initial_total;i++)
	if(opcode_triplets[i][3] > largest)
	  {
	    largest = opcode_triplets[i][3];
	    largest_index = i;
	  }
      
      printf(
#ifdef DISPLAY_STRING
	     "Opcode triplet:\t%s\t%s\t%s\tCount:\t%d\n",
#endif
#ifdef DISPLAY_CSV
	     "\"%s %s %s\",%d\n",
#endif	     
	     opcode_strings[opcode_triplets[largest_index][0]],
	     opcode_strings[opcode_triplets[largest_index][1]],
	     opcode_strings[opcode_triplets[largest_index][2]],
	     opcode_triplets[largest_index][3]);
      
      opcode_triplets[largest_index][3] = -1; // Eliminate this one
      
      // If we've printed out the maximum we wanted then return
      if ((initial_total - total_opcode_sets) == MAX_SETS_TO_REPORT)
	return;
            
    }
}

// Deal with opcode triplet checking
int opcode_quad_check(int third_previous_opcode_index,  
		      int second_previous_opcode_index,  
		      int previous_opcode_index, 
		      int current_opcode_index,
		      int sets_so_far )
{
  int i;
  // Check through for this pair's occurance before
  for (i=0;i<sets_so_far;i++)
    {
      if ((opcode_quads[i][0] == third_previous_opcode_index) &&
	  (opcode_quads[i][1] == second_previous_opcode_index) &&
	  (opcode_quads[i][2] == previous_opcode_index) &&
	  (opcode_quads[i][3] == current_opcode_index))
	
	// Found a match
	{
	  opcode_quads[i][4]++;
	  return 0;
	}
    }
  // No match, let's create a new entry
  opcode_quads[sets_so_far][0] = third_previous_opcode_index;
  opcode_quads[sets_so_far][1] = second_previous_opcode_index;
  // Index for previous opcode
  opcode_quads[sets_so_far][2] = previous_opcode_index;
  // Index for current opcode
  opcode_quads[sets_so_far][3] = current_opcode_index;
  // Count for this pair
  opcode_quads[sets_so_far][4] = 1;
  
  return 1;
  
}

void opcode_quad_report(int total_opcode_sets)
{

  int i, largest, largest_index;
  int initial_total = total_opcode_sets;

#ifdef DISPLAY_STRING 
  printf("Number of unique opcode quads: %d\n", total_opcode_sets);
#endif
#ifdef DISPLAY_CSV
  printf("\"Opcode quad\",\"Occurances\",\"Total unique quadruples:\",%d\n", 
	 total_opcode_sets);
#endif

  while (total_opcode_sets)
    {
      --total_opcode_sets;
      largest=0;
      // Go through the list, find the largest, print it, eliminate it
      for(i=0;i<initial_total;i++)
	if(opcode_quads[i][4] > largest)
	  {
	    largest = opcode_quads[i][4];
	    largest_index = i;
	  }
      
      printf(
#ifdef DISPLAY_STRING
	     "Opcode triplet:\t%s\t%s\t%s\t%s\tCount:\t%d\n",
#endif
#ifdef DISPLAY_CSV
	     "\"%s %s %s %s\",%d\n",
#endif	     
	     opcode_strings[opcode_quads[largest_index][0]],
	     opcode_strings[opcode_quads[largest_index][1]],
	     opcode_strings[opcode_quads[largest_index][2]],
	     opcode_strings[opcode_quads[largest_index][3]],
	     opcode_quads[largest_index][4]);
      
      opcode_quads[largest_index][4] = -1; // Eliminate this one

      // If we've printed out the maximum we wanted then return
      if ((initial_total - total_opcode_sets) == MAX_SETS_TO_REPORT)
	return;      
      
    }
}


int main(int argc, char *argv[])
{
  FILE *fp;

  char current_opcode[OPCODE_STRING_SIZE];  

  int num_unique_opcodes = 0;

  int opcode_index;

  int total_seen_opcodes = 0;
  
  int previous_opcode_indexes[16]; // keep last 16 opcode indexes

  int i;
  
  int num_opcode_pairs = 0;
  
  int num_opcode_triplets = 0;
  int num_opcode_quads = 0;
  


  if((fp = fopen(argv[ 1 ], "r"))==NULL) {
    printf("Cannot open file.\n");
    exit(1);
  }

  // Do initial instruction set analysis
  while(!feof(fp)) {
    if(fgets(current_opcode, OPCODE_STRING_SIZE, fp)) 
      {

	strip_newline(current_opcode);
	//printf("Checking for: %s \n", current_opcode);
	
	// Find if we have this opcode already, if so we'll get its index in
	// the list, else we'll get an indication that it's unique
	opcode_index = check_opcode(current_opcode, num_unique_opcodes);
	
	if (opcode_index == IS_UNIQUE)
	  {
	    // Add this opcode to our list so we know it now
	    add_opcode(current_opcode, num_unique_opcodes);
	    // Increment the number of known opcodes
	    num_unique_opcodes++;
	  }
	else
	  // Is not unique, just increment the incidences of this opcode
	  count_opcode(opcode_index);

	// Track the total number of opcodes we've looked at
	total_seen_opcodes++;
	
	// Error check - bail out early if we're doing something wrong and
	// there's too many unique opcodes (ISA is only so big...)
	if (num_unique_opcodes == MAX_OR1K_32_OPCODES)
	  {
	    printf("Error: Reached maximum opcodes\n");
	    break;
	  }
	
	//printf("So far: unique: %d total: %d\n", 
	//num_unique_opcodes, total_seen_opcodes);
	
      }
  }

  // Print some more detailed information
  display_opcodes(num_unique_opcodes, total_seen_opcodes);

#ifdef DISPLAY_STRING
  fprintf(stdout,"Beginning groups analysis\n");
#endif

  // Now do groups analysis
  rewind(fp);
  
  // Reset total_seen_opcodes, we'll count through the list again
  
  total_seen_opcodes = 0;

  while(!feof(fp)) {
    if(fgets(current_opcode, OPCODE_STRING_SIZE, fp)) 
      {
	
	total_seen_opcodes++;

	strip_newline(current_opcode);
	
	// Find if we have this opcode already, if so we'll get its index in
	// the list, else we'll get an indication that it's unique
	opcode_index = check_opcode(current_opcode, num_unique_opcodes);

	if (opcode_index == IS_UNIQUE)
	  {
	    // Error! Should not have unique opcodes here...
	    printf("Unique opcode detected during pair analysis.\n");
	    break;
	  }

	// Now pass this current pair to the function to check if we've seen
	// it before - if not we record it (and return 1) else we just increment
	// count of it (and return 0)
	if (total_seen_opcodes > 1)
	  {
	    if (opcode_pair_check(previous_opcode_indexes[0], opcode_index, 
				  num_opcode_pairs))
	      num_opcode_pairs++;
	  }
	
	if (total_seen_opcodes > 2)
	  {
	    if (opcode_triplet_check(previous_opcode_indexes[1],
				     previous_opcode_indexes[0],
				     opcode_index, 
				     num_opcode_triplets))
	      num_opcode_triplets++;
	  }
	if (total_seen_opcodes > 3)
	  {
	    if (opcode_quad_check(previous_opcode_indexes[2],
				  previous_opcode_indexes[1],
				  previous_opcode_indexes[0],
				  opcode_index, 
				  num_opcode_quads))
	      num_opcode_quads++;
	  }
	// Shift along our list of previously seen opcodes
	for (i=16-1;i > 0; i--)
	  previous_opcode_indexes[i] = previous_opcode_indexes[i-1];
	
	previous_opcode_indexes[0] = opcode_index;

      }
  }
  
  opcode_pair_report(num_opcode_pairs);

  opcode_triplet_report(num_opcode_pairs);

  opcode_quad_report(num_opcode_quads);

  // Close file pointer, we're done with it
  fclose(fp); 
  
  // Free all the strings we declared
  while(num_unique_opcodes)
    {
      --num_unique_opcodes;
      free(opcode_strings[num_unique_opcodes]);
    }

  //printf("freeing complete: %d\n", num_unique_opcodes);

  return 0;
}
