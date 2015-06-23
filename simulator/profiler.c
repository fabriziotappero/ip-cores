#include <malloc.h>
#include <err.h>
#include <math.h>

#include "types.h"
#include "microcode.h"
#include "instructions.h"
#include "object.h"
#include "profiler.h"
#include "memory.h"
#include <string.h>
#include "io.h"

unsigned int *instruction_executions;

profile_t profile;
cache_t cache;
int profile_number;

/* Initialize a profil^W simulator structure */
void sim_init(char* name, int microprogram_size, int cache_size, unsigned int mem_size, unsigned int branch_buffer_size, char * branch_pred_scheme)
{
//	if(p == NULL)
//		p = &profile;


	profile.branch_buffer = calloc(branch_buffer_size, sizeof(int));
	profile.reuse = calloc(mem_size, sizeof(int));
	profile.reuse_sum = calloc(mem_size, sizeof(long long int));
	profile.instruction_execs = calloc(microprogram_size, sizeof(long long int));
	profile.memory_access = calloc(mem_size, sizeof(long long int));
	printf("initialized memory to %d\n", mem_size);
	cache_init(&cache, cache_size);

	profile.name = strdup(name);
	profile.mp_size = microprogram_size;
	profile.memory_size = mem_size;
	profile.total_execs = 0;
	profile.cache = &cache;
	/* branches */
	profile.branch_buffer_size = branch_buffer_size;

	profile.br_predict = 0;
	profile.br_mispredict = 0;
	profile.branch_pred_scheme = branch_pred_scheme;
	
	//profile.num_per_type = calloc(NUM_INSTRUCTIONS, sizeof(int));
	int i;
	for(i=0;i < NUM_INSTRUCTIONS; i++) { profile.num_per_type[i] = 0; }

	/* OK! */
	profile.initialized = 1;
}


void
profiler_init(int microprogram_size,  int cache_size)
{
	int i;
	profile.instruction_execs = calloc(microprogram_size, sizeof(int));
	profile.total_execs = 0;
	profile.mp_size = microprogram_size;
	for(i = 0; i < NUM_INSTRUCTIONS; i++) { profile.num_per_type[i] = 0; }
	cache_init(&cache, cache_size);
	profile_number = 0;

	profile.memory_size = DEFAULT_MEMORY_SIZE;

	/* Initialize memory */
	profile.memory_access = calloc(DEFAULT_MEMORY_SIZE, sizeof(int));
	/* Last re-use time for memory addresses */
	profile.reuse = calloc(DEFAULT_MEMORY_SIZE, sizeof(int));
	/* Sum of reuse-times for all memory addresses */
	profile.reuse_sum = calloc(DEFAULT_MEMORY_SIZE, sizeof(int));
}

void
profiler_new()
{
	profile_number++;
	memset(profile.instruction_execs, 0, profile.mp_size);
	profile.total_execs = 0;
	memset(profile.num_per_type, 0, NUM_INSTRUCTIONS);

	profile.cache->hits = 0;
	profile.cache->misses = 0;
	memset(profile.cache->storage, 0, profile.cache->size);

}


void
profiler_add_execution(unsigned int addr, instr_t instr, int flags)
{
	if(profile.initialized != 1) { return; }

	profile.instruction_execs[addr]++;
	profile.total_execs++;
	//uint32_t ls;
	int32_t ls = 0;

	//Add to type-count.
	profile.num_per_type[instr.op]++;
	switch(instr.op) {
		case INS_STORE:
			break;
		case INS_LOAD:

		 	ls = (OBJECT_DATUM(instr_get_reg(instr.r2))+instr.disp);
			if ((ls & IO_AREA_MASK) == IO_AREA_MASK) {
				break;
			}
			cache_load(profile.cache, ls);
			profile.memory_access[ls]++;
			reuse_update(&profile, ls);
			break;
		case INS_BRANCH:
		case INS_BRANCH_REG:
			if(0 == strcmp(profile.branch_pred_scheme, "taken")) {
				if ((instr.flag_mask & flags) == instr.flag_values) {
					profile.br_predict++;
				} else {
					profile.br_mispredict++;
				}
			} else if(0 == strcmp(profile.branch_pred_scheme, "2bit")) {

				//int branch_entry = addr%profile.branch_buffer_size;
				int branch_entry = (unsigned int)addr%(unsigned int)profile.branch_buffer_size;

				if(profile.branch_buffer[branch_entry] == PREDICT_TAKEN_1) {
					if ((instr.flag_mask & flags) == instr.flag_values) {
						profile.br_predict++;
						profile.branch_buffer[branch_entry] = PREDICT_TAKEN_1;
					} else {
						profile.branch_buffer[branch_entry] = PREDICT_TAKEN_2;
						profile.br_mispredict++;
					}
				} else if(profile.branch_buffer[branch_entry] == PREDICT_TAKEN_2) {
					if ((instr.flag_mask & flags) == instr.flag_values) {
						profile.br_predict++;
						profile.branch_buffer[branch_entry] = PREDICT_TAKEN_1;
					} else {
						profile.branch_buffer[branch_entry] = PREDICT_NOT_TAKEN_1;
						profile.br_mispredict++;
					}
				} else if(profile.branch_buffer[branch_entry] == PREDICT_NOT_TAKEN_1) {
						if ((instr.flag_mask & flags) == instr.flag_values) {
							profile.branch_buffer[branch_entry] = PREDICT_TAKEN_1;
							profile.br_mispredict++;
						} else {
							profile.br_predict++;
							profile.branch_buffer[branch_entry] = PREDICT_NOT_TAKEN_1;
						}
				} else if(profile.branch_buffer[branch_entry] == PREDICT_NOT_TAKEN_2) {
					if ((instr.flag_mask & flags) == instr.flag_values) {
						profile.branch_buffer[branch_entry] = PREDICT_TAKEN_1;
						profile.br_mispredict++;
					} else {
						profile.br_predict++;
						profile.branch_buffer[branch_entry] = PREDICT_NOT_TAKEN_1;
					}
				}
			}	
			break;
		default:
			break;
	}


	if (profile.total_execs==0) {
		errx(1, "instruction count overflow\n");
	}
}


void reuse_update(profile_t* p, unsigned int addr)
{
	int sample = abs(p->total_execs - p->reuse[addr]);
	p->reuse[addr] = p->total_execs;
	p->reuse_sum[addr] += sample;
}


void
profiler_dump_program(char* filename)
{
//	char filename[50];

//	sprintf(filename, "profile_%d.txt", profile_number);

	if(profile.initialized != 1) return;
	sim_write_file(&profile, filename);
	return;
}





/*----------------------------*/
/* - File writing functions - */
/*----------------------------*/

void sim_write_file(profile_t* p, const char* filename)
{
	if(filename == NULL) {
		errx(1, "no filename in write_profiler_file\n");
	}
	
	printf("Writing simulation data to disk.\n");
	FILE* f = fopen(filename, "w");
	sim_write_global_info(p, f);
	sim_write_cache_info(p, f);
	sim_write_branch_counts(p, f);
	sim_write_instr_counts(p, f);
	sim_write_reuse_info(p, f);	
	sim_write_mem_count(p, f);
	sim_write_mc_info(p, f);
	fclose(f);
}

void sim_write_global_info(profile_t* p, FILE* f)
{
	printf("Global information\n");
	fprintf(f, "[NAME]\n");
	fprintf(f, "%s\n", p->name);
	fprintf(f, "[TOTAL_EXECS]\n");
	fprintf(f, "%llu\n", p->total_execs);
}

void sim_write_cache_info(profile_t* p, FILE* f)
{
	printf("Writing cache info\n");
	fprintf(f, "[CACHESIZE]\n %u\n", p->cache->size);
	fprintf(f, "[CACHEHITS]\n %u\n", p->cache->hits);
	fprintf(f, "[CACHEMISS]\n %u\n", p->cache->misses);
}

void sim_write_reuse_info(profile_t* p, FILE* f)
{
	printf("Writing reuse times for memsize %d\n",p->memory_size);
	int i;
	fprintf(f, "[REUSE]\n");
	for (i = 0; i < p->memory_size; i++) {
		fprintf(f, "0x%08X %d %llu\n", i, p->reuse_sum[i], p->memory_access[i]);
	}
}

void sim_write_mem_count(profile_t* p, FILE* f)
{
	printf("Writing memory hit counts\n");
	int i;
	fprintf(f, "[MEMCOUNT]\n");
	for (i = 0; i < p->memory_size; i++) {
		fprintf(f, "0x%08X %llu\n", i, p->memory_access[i]);
	}
}

void sim_write_mc_info(profile_t* p, FILE* f)
{
	printf("Writing microprogram instruction counts\n");
	int i;
	fprintf(f, "[MICROPROGRAM]\n");
	for (i = 0; i < microcode_size(); i++) {
		fprintf(f, "0x%08X %llu\n", i, p->instruction_execs[i]);
	}
}

void sim_write_instr_counts(profile_t* p, FILE* f) 
{
	printf("Writing total instruction type counts\n");
	int i;
	fprintf(f, "[TYPECOUNT]\n");
	for(i = 0; i < NUM_INSTRUCTIONS; i++) {
		if(instruction_type != NULL)
			fprintf(f, "%s %llu\n", instruction_type(i), p->num_per_type[i]);
	}
}

void sim_write_branch_counts(profile_t* p, FILE* f) 
{
	printf("Writing branch predicts and mispredicts\n");
	fprintf(f, "[BRANCH-PREDICT]\n");
	fprintf(f, "%llu\n", p->br_predict);

	fprintf(f, "[BRANCH-MISPREDICT]\n");
	fprintf(f, "%llu\n", p->br_mispredict);
}





/*------------------*/
/* Cache simulation */
/*------------------*/

void cache_load(cache_t* c, unsigned int addr)
{
	/* Do cache load, register hit or miss */	
	int position = addr % c->size;
	if(c->storage[position] == addr) {
		c->hits++;
	} else {
		c->storage[position] = addr;
		c->misses++;
	}
}

void cache_init(cache_t* c, int size)
{
	c->storage = calloc(size, sizeof(unsigned int));	
	c->size = size;
	c->hits = 0;
	c->misses = 0;
}


