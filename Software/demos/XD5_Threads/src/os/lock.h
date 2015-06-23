#ifndef __LOCK_H__
#define __LOCK_H__

void Lock(volatile int *lock, int *load_count, int *store_count);
void LockAlmost(volatile int *lock, int *load_count, int *store_count);
void LockNull(volatile int *lock, int *load_count, int *store_count);
void Unlock(volatile int *lock);

#endif

