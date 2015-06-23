#ifndef __TEST_ALLOC_GENERIC_H__
#define __TEST_ALLOC_GENERIC_H__

enum test_state_title {
	TEST_STATE_BEGIN = 0,
	TEST_STATE_MIDDLE,
	TEST_STATE_END,
	TEST_STATE_ERROR
};

typedef void (*print_alloc_state_t)(void);
typedef void *(*alloc_func_t)(int size);
typedef int (*free_func_t)(void *addr);

enum alloc_action {
	FREE = 0,
	ALLOCATE = 1,
};

void get_output_filepaths(FILE **out1, FILE **out2,
			  char *alloc_func_name);

int test_alloc_free_random_order(const int MAX_ALLOCATIONS,
				 const int ALLOC_SIZE_MAX,
				 alloc_func_t alloc, free_func_t free,
				 print_alloc_state_t print_allocator_state,
				 FILE *init_state, FILE *exit_state);

#endif /* __TEST_ALLOC_GENERIC_H__ */
