/*
 * Program execution
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/ipcdefs.h>
#include <l4lib/types.h>
#include <l4/macros.h>
#include <l4/api/errno.h>
#include <malloc/malloc.h>
#include <vm_area.h>
#include <syscalls.h>
#include <string.h>
#include <exec.h>
#include <file.h>
#include <user.h>
#include <task.h>
#include <exit.h>
#include <lib/elf/elf.h>
#include <init.h>
#include <stat.h>
#include <alloca.h>

/*
 * Probes and parses the low-level executable file format and creates a
 * generic execution description that can be used to run the task.
 */
int task_setup_from_executable(struct vm_file *vmfile,
			       struct tcb *task,
			       struct exec_file_desc *efd)
{
	memset(efd, 0, sizeof(*efd));

	return elf_parse_executable(task, vmfile, efd);
}

int init_execve(char *filepath)
{
	struct vm_file *vmfile;
	struct exec_file_desc efd;
	struct tcb *new_task, *self;
	struct args_struct args, env;
	char env_string[30];
	int err;
	int fd;

	struct task_ids ids = {
		.tid = TASK_ID_INVALID,
		.spid = TASK_ID_INVALID,
		.tgid = TASK_ID_INVALID,
	};

	sprintf(env_string, "pagerid=%d", self_tid());

	/* Set up args_struct */
	args.argc = 1;
	args.argv = alloca(sizeof(args.argv));
	args.argv[0] = alloca(strlen(filepath) + 1);
	strncpy(args.argv[0], filepath, strlen(filepath) + 1);
	args.size = sizeof(args.argv) * args.argc + strlen(filepath) + 1;

	/* Set up environment */
	env.argc = 1;
	env.argv = alloca(sizeof(env.argv));
	env.argv[0] = alloca(strlen(env_string) + 1);
	strncpy(env.argv[0], env_string, strlen(env_string) + 1);
	env.size = sizeof(env.argv) + strlen(env_string) + 1;

	self = find_task(self_tid());
	if ((fd = sys_open(self, filepath,
			   O_RDONLY, 0)) < 0) {
		printf("FATAL: Could not open file "
		       "to write initial task.\n");
		BUG();
	}
	/* Get the low-level vmfile */
	vmfile = self->files->fd[fd].vmfile;

	if (IS_ERR(new_task = task_create(0, &ids,
					  TCB_NO_SHARING,
					  TC_NEW_SPACE))) {
		sys_close(self, fd);
		return (int)new_task;
	}

	/*
	 * Fill and validate tcb memory
	 * segment markers from executable file
	 */
	if ((err = task_setup_from_executable(vmfile,
					      new_task,
					      &efd)) < 0) {
		sys_close(self, fd);
		kfree(new_task);
		return err;
	}

	/* Map task's new segment markers as virtual memory regions */
	if ((err = task_mmap_segments(new_task, vmfile,
				      &efd, &args, &env)) < 0) {
		sys_close(self, fd);
		kfree(new_task);
		return err;
	}

	/* Set up task registers via exchange_registers() */
	task_setup_registers(new_task, 0,
			     new_task->args_start,
			     new_task->pagerid);


	/* Add new task to global list */
	global_add_task(new_task);

	/* Start the task */
	task_start(new_task);

	return 0;
}


/*
 * TODO:
 *
 * Dynamic Linking.
 * See if an interpreter (dynamic linker) is needed
 * Find the interpreter executable file, if needed
 * Map all dynamic linker file segments
 * (should not clash with original executable
 * Set up registers to run dynamic linker (exchange_registers())
 * Run the interpreter
 *
 * The interpreter will:
 * - Need some initial info (dyn sym tables) at a certain location
 * - Find necessary shared library files in userspace
 *   (will use open/read).
 * - Map them into process address space via mmap()
 * - Reinitialise references to symbols in the shared libraries
 * - Jump to the entry point of main executable.
 */

int do_execve(struct tcb *sender, char *filename,
	      struct args_struct *args,
	      struct args_struct *env)
{
	struct vm_file *vmfile;
	struct exec_file_desc efd;
	struct tcb *new_task, *tgleader, *self;
	int err;
	int fd;

	self = find_task(self_tid());
	if ((fd = sys_open(self, filename, O_RDONLY, 0)) < 0)
		return fd;

	/* Get the low-level vmfile */
	vmfile = self->files->fd[fd].vmfile;

	/* Create a new tcb */
	if (IS_ERR(new_task = tcb_alloc_init(TCB_NO_SHARING))) {
		sys_close(self, fd);
		return (int)new_task;
	}

	/*
	 * Fill and validate tcb memory
	 * segment markers from executable file
	 */
	if ((err = task_setup_from_executable(vmfile,
					      new_task,
					      &efd)) < 0) {
		sys_close(self, fd);
		kfree(new_task);
		return err;
	}

	/*
	 * If sender is a thread in a group, need to find the
	 * group leader and destroy all threaded children in
	 * the group.
	 */
	if (sender->clone_flags & TCB_SHARED_TGROUP) {
		struct tcb *thread;

		/* Find the thread group leader of sender */
		BUG_ON(!(tgleader = find_task(sender->tgid)));

		/* Destroy all children threads. */
		list_foreach_struct(thread,
				    &tgleader->children,
				    child_ref)
			do_exit(thread, 0);
	} else {
		/* Otherwise group leader is same as sender */
		tgleader = sender;
	}

	/*
	 * Copy data to be retained from exec'ing task to new one.
	 * Release all task resources, do everything done in
	 * exit() except destroying the actual thread.
	 */
	if ((err = execve_recycle_task(new_task, tgleader)) < 0) {
		sys_close(self, fd);
		kfree(new_task);
		return err;
	}

	/* Map task's new segment markers as virtual memory regions */
	if ((err = task_mmap_segments(new_task, vmfile,
				      &efd, args, env)) < 0) {
		sys_close(self, fd);
		kfree(new_task);
		return err;
	}

	/* Set up task registers via exchange_registers() */
	task_setup_registers(new_task, 0,
			     new_task->args_start,
			     new_task->pagerid);

	/* Add new task to global list */
	global_add_task(new_task);

	/* Start the task */
	task_start(new_task);

	return 0;
}

int sys_execve(struct tcb *sender, char *pathname,
	       char *argv[], char *envp[])
{
	int ret;
	char *path;
	struct args_struct args;
	struct args_struct env;

	if (!(path = kzalloc(PATH_MAX)))
		return -ENOMEM;

	memset(&args, 0, sizeof(args));
	memset(&env, 0, sizeof(env));

	/* Copy the executable path string */
	if ((ret = copy_user_string(sender, path,
				    pathname, PATH_MAX)) < 0)
		return ret;

	/* Copy the args */
	if (argv && ((ret = copy_user_args(sender, &args,
					   argv, ARGS_MAX)) < 0))
		goto out1;

	/* Copy the env */
	if (envp && ((ret = copy_user_args(sender, &env, envp,
					   ARGS_MAX - args.size))
		     < 0))
		goto out2;

	ret = do_execve(sender, path, &args, &env);

	if (env.argv)
		kfree(env.argv);
out2:
	if (args.argv)
		kfree(args.argv);
out1:
	kfree(path);
	return ret;
}

