/*
 * Kernel preemption functions.
 */
#ifndef __PREEMPT_H__
#define __PREEMPT_H__

void preempt_enable(void);
void preempt_disable(void);
int preemptive(void);
int preempt_count(void);

int in_nested_irq_context(void);
int in_irq_context(void);
int in_task_context(void);

#endif /* __PREEMPT_H__ */
