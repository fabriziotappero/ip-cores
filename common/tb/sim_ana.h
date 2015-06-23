/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Simulation analyzer, gethering info. for performance analyses.
 
 Possible bugs:
 * the histograph function has not been tested yet.


 History:
 29/06/2010  Initial version. <wsong83@gmail.com>
 28/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

#ifndef SIM_ANA_H_
#define SIM_ANA_H_

#include <cstdlib>
#include <cmath>
#include <iostream>
#include <fstream>
#include <string>
#include "sim_record.h"
#include "hash_table.h"

using namespace std;

// a data type for accumulative performance, such as throughput analysis
class accu_record{
 private:
  double V1, V2;		/* two values to avoid loss of accuracy, V1 save the accumulated V2 of at least 512 records */
  unsigned int N1, N2;
 public:
  accu_record()
    :V1(0), V2(0), N1(0), N2(0)
    {}
  
  accu_record& operator+= (const double m) {
    N2++;
    V2 += m;
    if(N2 >= N1/512) {
      N1 += N2;
      V1 += V2;
      N2 = 0;
      V2 = 0;
    }
    return(*this);
  }

  double avalue() {		/* return averged value */
    double rt;

    if(0 == N1+N2)
      rt = 0;
    else
      rt = (V1 + V2) / (N1 + N2);

    V1 = 0;
    V2 = 0;
    N1 = 0;
    N2 = 0;
    return rt;
  }

  double value() {		/* return the accumulative value */
    double rt;

    if(0 == N1+N2)
      rt = 0;
    else
      rt = (V1 + V2);

    V1 = 0;
    V2 = 0;
    N1 = 0;
    N2 = 0;
    return rt;
  }
};

/* the major simulation record class, only one such object in one simulation */
class sim_ana {
 public:

  sim_ana()
    : warm_time(0), record_period(0),last_time(0),
    delay_ana(false), throughput_ana(false), delay_histo_ana(false),
    histo_data(NULL) {}
  
  sim_ana(double mwt, double mrp)
    : warm_time(mwt), record_period(mrp), last_time(0),
    delay_ana(false), throughput_ana(false), delay_histo_ana(false),
    histo_data(NULL) {}

  ~sim_ana();

  /* currently 16 table entries is enough and good for memory efficiency */
  hash_table<sim_record<2>,16> ANA;

  bool start(long, double);	/* start to record a new record */
  bool record(long, double);	/* record a time stamp */
  bool stop(long, double, unsigned int);	/* stop an old record */

  bool set_ana_parameters(double, double); /* set analysis time parameters */
  bool analyze_delay(string);	/* enable delay analysis */
  bool analyze_throughput(string); /* enable throughput analysis */
  bool analyze_delay_histo(string, double, double, unsigned int); /* enable delay histo analysis */

 private:
  double warm_time;
  double record_period;
  double last_time;
  
  bool delay_ana;		/* whether analyze frame delay */
  bool throughput_ana;		/* whether analyze throughput */
  bool delay_histo_ana;		/* whether analyze frame delay histo */
  unsigned int delay_histo_binnum; /* bin number of the histo graph */
  double delay_histo_start;	   /* histo begin level */
  double delay_histo_end;	   /* histo end level */
  double delay_histo_gap;	   /* gap bewteen two levels (gap = (start-end)/(binnum-2)) */
  unsigned long * histo_data;

  string delay_file;		/* the name for delay analyses result file */
  string throughput_file;	/* the name for throughput analyses result file */
  string delay_histo_file;	/* the name for histograph analyses file */
  
  accu_record fm_dly;		/* records of frame delay */
  accu_record pth_dly;		/* records of path delay */
  accu_record th_value;		/* records of throughput */
};

#endif
