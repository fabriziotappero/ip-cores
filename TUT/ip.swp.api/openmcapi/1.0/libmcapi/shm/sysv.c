/*
 * Copyright (c) 2011, Mentor Graphics Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of the <ORGANIZATION> nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/* This file allows the shared memory transport to mmap a file rather than
 * requiring dedicated physical memory. This is useful for development and
 * debugging, but obviously can only work for MCAPI processes within a single
 * OS (single filesystem). In addition to mmap(), it uses 0-length SysV message
 * queues as IPIs. */

#include <mcapi.h>
#include "shm.h"
#include "shm_os.h"

#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#include <sys/ipc.h>
#include <sys/msg.h>

#define FILENAME "/tmp/mcapi-shm"


const unsigned int shm_bytes = 0x00100000; /* XXX */

static int msgqid;
static pthread_t shm_rx_thread;

struct shm_msgbuf {
    long mtype;
};

mcapi_status_t openmcapi_shm_notify(mcapi_uint32_t unit_id,
                                    mcapi_uint32_t node_id)
{
    struct shm_msgbuf msg = {node_id + 1};
    int rc;
    mcapi_status_t status = MCAPI_SUCCESS;

    rc = msgsnd(msgqid, &msg, 0, 0);
    if (rc == -1)
        status = MGC_MCAPI_ERR_NOT_CONNECTED;

    return status;
}

mcapi_uint32_t openmcapi_shm_schedunitid(void)
{
    return 0;
}

void *openmcapi_shm_map(void)
{
    void *shm;
    int key;
    int fd;

    /* Create the file. */
    fd = open(FILENAME, O_RDWR | O_CREAT | O_EXCL, 0660);
    if (fd != -1) {
        /* We created it first. Make it a sparse file of the correct size, then
         * initialize the associated semaphore. */
        lseek(fd, shm_bytes-1, SEEK_SET);
        write(fd, "\0", 1);
    } else {
        if (errno == EEXIST) {
            /* Another process created it, but we can use it. */
            fd = open(FILENAME, O_RDWR, 0660);
        }
    }
    if (fd == -1) {
        perror("open backing file");
        goto out1;
    }

    key = ftok(FILENAME, 'A');
    if (key == -1) {
        perror("ftok");
        goto out2;
    }

    msgqid = msgget(key, IPC_CREAT | 0660);
    if (msgqid == -1) {
        perror("msgget");
        goto out2;
    }

    /* mmap it. */
    shm = mmap(NULL, shm_bytes, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if (shm == MAP_FAILED) {
        perror("mmap shared memory");
        goto out2;
    }

    /* Don't need the original fd around any more. */
    close(fd);

    return shm;

out2:
    close(fd);
out1:
    return NULL;
}

static void *mcapi_receive_thread(void *data)
{
    int rc;
    static struct shm_msgbuf msg = {0};

    do {
        /* Block until data for this node is available. */
        rc = msgrcv(msgqid, &msg, 0, MCAPI_Node_ID + 1, 0);
        if (rc < 0) {
            /* This likely means the other side has already torn down the
             * message queue, so just exit. */
            break;
        }

        /* Obtain lock so we can safely manipulate the RX_Queue. */
        MCAPI_Lock_RX_Queue();

        /* Process the incoming data. */
        shm_poll();

        MCAPI_Unlock_RX_Queue(0);

    } while (1);

    return NULL;
}

/* Now that SM_Mgmt_Blk has been initialized, we can start the RX thread. */
mcapi_status_t openmcapi_shm_os_init(void)
{
    mcapi_status_t mcapi_status = MCAPI_SUCCESS;
    int rc;

    rc = pthread_create(&shm_rx_thread, NULL, mcapi_receive_thread, NULL);
    if (rc) {
        perror("couldn't create pthread");
        mcapi_status = MCAPI_ERR_GENERAL;
    }

    return mcapi_status;
}

/* Finalize the SM driver OS specific layer. */
mcapi_status_t openmcapi_shm_os_finalize(void)
{
    mcapi_status_t mcapi_status = MCAPI_SUCCESS;
    int rc;

    rc = pthread_cancel(shm_rx_thread);
    if (rc) {
        perror("couldn't cancel thread");
        mcapi_status = MCAPI_ERR_GENERAL;
    }

    return mcapi_status;
}

void openmcapi_shm_unmap(void *shm)
{
    /* File and message queue will be removed multiple times, once by each
     * process, but that's OK. */
    unlink(FILENAME);
    msgctl(msgqid, IPC_RMID, NULL);

    munmap(shm, shm_bytes);
}
