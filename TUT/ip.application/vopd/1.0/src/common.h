/**
 *
 * @file   common.h
 * @author Lasse Lehtonen
 *
 * @brief VOPD - Common stuff for all nodes.
 *
 */

#ifndef COMMON_H
#define COMMON_H

#include <mcapi.h>

#define WAIT_TIMEOUT 0xFFFFFFFF

#define mcapi_assert_success(s) \
        if (s != MCAPI_SUCCESS) { printf("%s:%d status %d\n", __FILE__, __LINE__, s); abort(); }


/** Connects port 'tx_port' on local to port 'rx_port' on remote node 
 *  and return handle
 */
void connect_fwd(int local, int tx_port, mcapi_pktchan_recv_hndl_t* send_hndl,
                 int remote, int rx_port);

/** Opens local endpoint tx_port for receiving and returns handle 
 */
void connect_rev(int local, int rx_port, mcapi_pktchan_recv_hndl_t* recv_hndl);


/** Cleans things
 */
void cleanup();

#endif

// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

