#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <getopt.h>

#include <mcapi.h>

extern void startup(unsigned int local, unsigned int remote);
extern void demo(unsigned int local, int listen);
extern int encoder();
extern int main_dct();

static struct sigaction oldactions[32];

static void usage(const char *name)
{
	printf("Usage: %s [options] <local node id> <remote node id>\n"
			"Options:\n"
			"  -l, --loop      send and receive messages until killed.\n",
			name);
	exit(1);
}

static void cleanup(void)
{
	mcapi_status_t status;

	printf("%s\n", __func__);
	mcapi_finalize(&status);
}

static void signalled(int signal, siginfo_t *info, void *context)
{
	struct sigaction *action;

	action = &oldactions[signal];

	if ((action->sa_flags & SA_SIGINFO) && action->sa_sigaction)
		action->sa_sigaction(signal, info, context);
	else if (action->sa_handler)
		action->sa_handler(signal);
	
	exit(signal);
}

struct sigaction action = {
	.sa_sigaction = signalled,
	.sa_flags = SA_SIGINFO,
};

int main(int argc, char *argv[])
{

  atexit(cleanup);
	sigaction(SIGQUIT, &action, &oldactions[SIGQUIT]);
	sigaction(SIGABRT, &action, &oldactions[SIGABRT]);
	sigaction(SIGTERM, &action, &oldactions[SIGTERM]);
	sigaction(SIGINT,  &action, &oldactions[SIGINT]);

	

	main_dct();

	return 0;
}
