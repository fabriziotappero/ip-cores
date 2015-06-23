#ifndef __INITTASK_ARCH_MM_H__
#define __INITTASK_ARCH_MM_H__

#include <l4/macros.h>
#include <l4/types.h>
#include INC_GLUE(memory.h)
#include INC_ARCH(exception.h)
#include <vm_area.h>

struct fault_data;
void set_generic_fault_params(struct fault_data *fault);
void arch_print_fault_params(struct fault_data *fault);
void fault_handle_error(struct fault_data *fault);

#endif /* __INITTASK_ARCH_MM_H__ */
