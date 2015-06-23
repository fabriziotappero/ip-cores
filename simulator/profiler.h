#ifndef _PROFILER_H_
#define _PROFILER_H_
#include "instructions.h"


#define PREDICT_TAKEN_1 0
#define PREDICT_TAKEN_2 1
#define PREDICT_NOT_TAKEN_1 2
#define PREDICT_NOT_TAKEN_2 3

//Yes, yes-- it IS in libc... just expose it already. 
char* strdup(const char* lol);


typedef struct {
	char* type;
	unsigned int* storage;
	unsigned int size;
	unsigned int hits;
	unsigned int misses;
} cache_t;


typedef struct {
	int initialized;

	char* name;
	unsigned long long* instruction_execs;

	unsigned int mp_size;
	unsigned long long total_execs;
	unsigned long long num_per_type[NUM_INSTRUCTIONS];
	unsigned int* instruction_cost;

	unsigned int memory_size;
	unsigned long long* memory_access;

	unsigned long long br_predict;
	unsigned long long br_mispredict;

	unsigned int branch_buffer_size;
	unsigned short* branch_buffer;
	char* branch_pred_scheme;

	cache_t* cache;

	int profile;
	int* reuse;
	int* reuse_sum;
} profile_t;


void profiler_init(int microcode_size, int cache_size);
void profiler_add_execution(unsigned int addr, instr_t instr, int flags);
void profiler_dump_program(char* filename);
void profiler_new();

/* Simulation framework */
void sim_init(char* name, int microprogram_size, int cache_size, unsigned int mem_size, unsigned int branch_buffer_size, char * branch_pred_scheme);
void sim_write_file(profile_t* p, const char* filename);
void sim_write_cache_info(profile_t* p, FILE* f);
void sim_write_reuse_info(profile_t* p, FILE* f);
void sim_write_mc_info(profile_t* p, FILE* f);
void sim_write_instr_counts(profile_t* p, FILE* f);
void sim_write_global_info(profile_t* p, FILE* f);
void sim_write_mem_count(profile_t* p, FILE* f);
void sim_write_branch_counts(profile_t * p, FILE * f);

void cache_load(cache_t* c, unsigned int addr);
void cache_init(cache_t* c,  int size);
void reuse_update(profile_t* p, unsigned int addr);
#endif
