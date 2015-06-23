/*
 * Copyright (C) 2011 Simon A. Berger
 * 
 *  This program is free software; you may redistribute it and/or modify its
 *  under the terms of the GNU Lesser General Public License as published by the Free
 *  Software Foundation; either version 2 of the License, or (at your option)
 *  any later version.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 *  for more details.
 */


#ifndef BACKGROUND_READER_H
#define BACKGROUND_READER_H


#ifdef __cplusplus

#include <boost/thread/mutex.hpp>
#include <boost/thread/thread.hpp>
#include <boost/thread/barrier.hpp>
#include <boost/scoped_ptr.hpp>

#include <deque>
#include <vector>

#include <pthread.h>
#include <stdint.h>
// the all singing, all dancing background reader, written in shiny new c++

class background_reader
{
    typedef boost::mutex mutex_t;
    //typedef boost::unique_lock<mutex_t> unique_lock_t;
    typedef boost::lock_guard<mutex_t> lock_guard_t;
    
    boost::condition_variable m_can_read_condition;
    boost::mutex m_pq_mtx;
    //boost::scoped_ptr<boost::thread> m_thread;
    boost::thread_group m_thread_group;
    
    volatile bool m_stop; // FIXME: use atomic var
    int m_socket;
    
    size_t m_max_size;
    
    std::deque<std::string> m_pq;
    size_t m_pq_mem;
    size_t m_pq_max_mem;
    
    size_t m_pq_max_depth;
    
    
    //pthread_t m_native_handle;
    boost::mutex m_nh_mtx;
    std::vector<pthread_t> m_native_handles;
    const size_t N_THREADS;
    boost::barrier m_run_barrier;
    bool m_threads_joined;
    
    void run();
public:
    background_reader( int s, size_t size );
    virtual ~background_reader();
    
    void start();
    void interrupt();
    void stop() { m_stop = true; __sync_synchronize(); } // try to make sure that the new value of m_stop is visible to all bg threads before interrupt is called.
    void join();
    
    ssize_t block_recv( void* buf, size_t size );
    ssize_t poll();
    ssize_t purge();


};
#endif

// the boring old ansi c interface

#ifdef __cplusplus
extern "C" {
#endif

typedef struct fpga_bgr_s {
    void *bgr_cpp;
} fpga_bgr_t;


void fpga_bgr_init( fpga_bgr_t *bgr, int socket, size_t size );
void fpga_bgr_delete( fpga_bgr_t *bgr );

void fpga_bgr_start( fpga_bgr_t *bgr);
ssize_t fpga_bgr_block_recv( fpga_bgr_t *bgr, void *buf, size_t size );
ssize_t fpga_bgr_poll();
void fpga_bgr_stop_interrupt_join( fpga_bgr_t *bgr);

// high level functions
int fpga_bgr_recv_charv( fpga_bgr_t *bgr, char *buf, size_t n );
int fpga_bgr_recv_shortv( fpga_bgr_t *bgr, int16_t *buf, size_t n );
int fpga_bgr_recv_intv( fpga_bgr_t *bgr, int32_t *buf, size_t n );
int fpga_bgr_recv_longv( fpga_bgr_t *bgr, int64_t *buf, size_t n );
int fpga_bgr_recv_floatv( fpga_bgr_t *bgr, float *buf, size_t n );
int fpga_bgr_recv_doublev( fpga_bgr_t *bgr, double *buf, size_t n );

#ifdef __cplusplus
}
#endif



#endif // BACKGROUND_READER_H
