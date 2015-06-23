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
 27/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

#include "sim_ana.h"

bool sim_ana::set_ana_parameters(double mwt, double mrp) {
  if((mwt < 0) || (mrp < 0))
    return false;

  warm_time = mwt;
  record_period = mrp;
  return true;
}

bool sim_ana::analyze_delay(string mfname) {
  ofstream file_handle;

  delay_ana = true;
  delay_file = mfname;
  
  file_handle.open(delay_file.data(), fstream::trunc);
  file_handle.close();

  return true;
}

bool sim_ana::analyze_throughput(string mfname) {
  ofstream file_handle;

  throughput_ana = true;
  throughput_file = mfname;
  
  file_handle.open(throughput_file.data(), fstream::trunc);
  file_handle.close();

  return true;
}

bool sim_ana::analyze_delay_histo(string mframe, double tstart, double tend, unsigned int binnum) {
  ofstream file_handle;
  
  if((tstart < 0) || (tend <= tstart) || (binnum < 3))
    return false;

  delay_histo_ana = true;
  delay_histo_file = mframe;

  file_handle.open(delay_histo_file.data(), fstream::trunc);
  file_handle.close();

  delay_histo_start = tstart;
  delay_histo_end = tend;
  delay_histo_gap = (tstart - tend) / (binnum - 2);
  delay_histo_binnum = binnum;

  histo_data = new unsigned long [binnum];

  for(unsigned int i=0; i<binnum; i++)
    histo_data[i] = 0;

  return true;
}
  
bool sim_ana::start(long mkey, double mtime) {
  sim_record<2> * mrd;
  
  mrd = new sim_record<2> (mtime, mkey);

  ANA.insert(*mrd);

  return true;
}

bool sim_ana::stop(long mkey, double mtime, unsigned int payload) {
  ofstream file_handle;
  sim_record<2> * mrd;

  mrd = ANA.find(mkey);
  
  if(mrd == NULL)
    return false;

  //  cout << mtime << "   "  << mtime - mrd->stamp[0] << endl;

  if(mtime < warm_time) {
    ANA.clear(mrd);
    return true;
  }

  if(delay_ana) {
    fm_dly += (mtime - mrd->stamp[0]);
    pth_dly += (mrd->stamp[1] -  mrd->stamp[0]);
  }

  if(throughput_ana) {
    th_value += payload;
  }

  if(delay_histo_ana) {
    double delay = mtime - mrd->stamp[0];
    
    if(delay >= delay_histo_end)
      histo_data[delay_histo_binnum-1]++;
    else {
      delay -= delay_histo_start;
      if(delay < 0)
	histo_data[0]++;
      else {
	histo_data[(unsigned long)(1 + delay/delay_histo_gap)]++;
      }
    }
  }

    ANA.clear(mrd);

  // check whether need to write out
  if(floor(mtime/record_period) > floor(last_time/record_period)) {
    if(delay_ana) {
      file_handle.open(delay_file.data(), fstream::app);
      file_handle << mtime << "\t" << fm_dly.avalue() << "\t" << pth_dly.avalue() << endl;
      file_handle.close();
    }
    
    if(throughput_ana) {
      file_handle.open(throughput_file.data(), fstream::app);
      file_handle << mtime << "\t" << th_value.value() << endl;
      file_handle.close();
    }

    last_time = mtime;
  }

  
  return true;
}
      
bool sim_ana::record(long mkey, double mtime) {
  sim_record<2> * mrd;

  mrd = ANA.find(mkey);
  
  if(mrd == NULL)
    return false;

  mrd->stamp[mrd->index] = mtime;

  return true;
}
      

sim_ana::~sim_ana() {
  ofstream file_handle;

  if(delay_histo_ana) {
    file_handle.open(delay_histo_file.data(), fstream::app);
    
    for(unsigned int i=0; i<delay_histo_binnum; i++)
      file_handle << (double)(delay_histo_start + i*delay_histo_gap) << "\t" << histo_data[i] << endl;

    file_handle.close();
  }

  if(histo_data != NULL)
    delete[] histo_data;
}

