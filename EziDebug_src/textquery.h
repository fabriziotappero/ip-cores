#ifndef TEXTQUERY_H
#define TEXTQUERY_H

#include <QtAlgorithms>
#include <QString>
#include <QStringList>
#include <QFile>
#include <QFileInfo>
#include <QVector>
#include <QPair>
#include <QTextStream>
#include <QDebug>
#include <memory.h>

#define OUT(n)  "OUT" #n ".txt"
#define OUTT(n)  OUT##n
#define OUTFILE(n) outfile##n

// QString module_name = "ifft_top";




#if 0
inout_table1[] =
{
    "clk_8x", 1, 0, 0,
    "rst", 1, 0, 0,
    "frame_mk_done", 1, 0, 0,
    "cp_len", 1, 8, 0,
    "ulmc_sym_num ", 1, 5, 0,
    "datao_frame_buf", 1, 23, 0,
    "dspreg_ifftexp_ref",1, 5, 0,
    "mc_ul_start", 1, 0, 0,
    "mc_ul_len", 1, 19, 0,
    "ifft_airif_data", 0, 23, 0,
    "ifft_airif_dval", 0, 0, 0,
    "ren_frame_buf", 0, 0, 0,
    "raddr_frame_buf", 0, 15, 0,
    "rover_frame_buf", 0, 0, 0,
    "master_source_ena_ifft", 0, 0, 0,
    "master_sink_sop_ifft", 0, 0, 0,
    "datai_ifft_real_14b", 0, 13, 0,
    "datai_ifft_imag_14b", 0, 13, 0,
    "wflag_duc_buf", 0, 0, 0,
    "ifft_done_d1", 0, 0, 0,
    "rflag_frame_buf",0, 0, 0,
    "airif_clr", 0, 0, 0,
    "wen_shift_buf", 0, 0, 0,
    "ren_airif_buf", 0, 0, 0,
    "usedw_airif_buf", 0, 10, 0,
    "fmk_done_val", 0, 0, 0,
    "ifft_start", 0, 0, 0,
    "",0,0,0,
}
#endif



#if 0
regchain_table1[] =
{
    "ifft_time_ctrl_inst.ren_frame_buf", 0, 0,
    "ifft_time_ctrl_inst.raddr_frame_buf", 15, 0,
    "ifft_time_ctrl_inst.rover_frame_buf", 0, 0,
    "ifft_time_ctrl_inst.master_sink_dav_ifft", 0, 0,
    "ifft_time_ctrl_inst.master_source_dav_ifft", 0, 0,
    "ifft_time_ctrl_inst.master_sink_sop_ifft", 0, 0,
    "ifft_time_ctrl_inst.datai_ifft_real", 11, 0,
    "ifft_time_ctrl_inst.datai_ifft_imag", 11, 0,
    "ifft_time_ctrl_inst.wen_shift_buf", 0, 0,
    "ifft_time_ctrl_inst.waddr_shift_buf", 10, 0,
    "ifft_time_ctrl_inst.datai_shift_real", 11, 0,
    "ifft_time_ctrl_inst.datai_shift_imag", 11, 0,
    "ifft_time_ctrl_inst.ren_shift_buf", 0, 0,
    "ifft_time_ctrl_inst.raddr_shift_buf", 9, 0,
    "ifft_time_ctrl_inst.wen_duc_buf ", 0, 0,
    "ifft_time_ctrl_inst.rflag_frame_buf", 0, 0,
    "ifft_time_ctrl_inst.rcnt_frame_buf", 9, 0,
    "ifft_time_ctrl_inst.exp_ifft_shift", 5, 0,
    "ifft_time_ctrl_inst.rcnt_shift_buf", 10, 0,
    "ifft_time_ctrl_inst.ifft_done", 0, 0,
    "ifft_time_ctrl_inst.ifft_start",0,0,
    "ifft_time_ctrl_inst.ren_frame_buf_d1",0,0,
    "ifft_time_ctrl_inst.ren_frame_buf_d2",0,0,
    "ifft_time_ctrl_inst.ren_frame_buf_d3",0,0,
    "ifft_time_ctrl_inst.wen_shift_buf_d1",0,0,
    "ifft_time_ctrl_inst.wen_shift_buf_d2",0,0,
    "ifft_time_ctrl_inst.ifft_done_d1",0,0,
    "ifft_time_ctrl_inst.ifft_done_d2",0,0,
    "ifft_time_ctrl_inst.wflag_duc_buf_d1",0,0,
    "ifft_time_ctrl_inst.ren_shift_buf_d1",0,0,
    "ifft_time_ctrl_inst.ren_shift_buf_d2",0,0,
    "ifft_time_ctrl_inst.master_source_ena_ifft_d1",0,0,
    "ifft_time_ctrl_inst.datao_real_ifft_d1", 11, 0,
    "ifft_time_ctrl_inst.datao_imag_ifft_d1", 11, 0,
    "ifft_time_ctrl_inst.frame_mk_done_d1",0,0,
    "ifft_time_ctrl_inst.ifft_airif_dval_d1",0,0,
    "ifft_time_ctrl_inst.ifft_airif_dval_d2",0,0,
    "ifft_time_ctrl_inst.ifft_airif_dval_d3",0,0,

    "ifft_inst.master_sink_ena",0,0,
    "ifft_inst.master_source_sop",0,0,
    "ifft_inst.master_source_eop",0,0,
    "ifft_inst.master_source_ena",0,0,
    "ifft_inst.butt_ram_raddr",9,0,
    "ifft_inst.butt_ram_ren", 0, 0,
    "ifft_inst.butt_ram_wdatai", 16, 0,
    "ifft_inst.butt_ram_wdataq", 16, 0,
    "dut.ifft_inst.butt_ram_wval", 0, 0,
    "ifft_inst.wpi", 14, 0,
    "ifft_inst.wpq", 14, 0,
    "ifft_inst.wpi_d1", 14, 0,
    "ifft_inst.wpq_d1", 14, 0,
    "ifft_inst.xi", 13, 0,
    "ifft_inst.xq", 13, 0,
    "ifft_inst.xi_d1", 13, 0,
    "ifft_inst.xq_d1", 13, 0,
    "ifft_inst.x1i", 13, 0,
    "ifft_inst.x1q", 13, 0,
    "ifft_inst.x2w1pi", 14, 0,
    "ifft_inst.x2w1pq", 14, 0,
    "ifft_inst.x3w2pi", 14, 0,
    "ifft_inst.x3w2pq", 14, 0,
    "ifft_inst.x4w3pi", 14, 0,
    "ifft_inst.x4w3pq", 14, 0,
    "ifft_inst.y1i", 16, 0,
    "ifft_inst.y1q", 16, 0,
    "ifft_inst.y2i",16,0,
    "ifft_inst.y2q",16,0,
    "ifft_inst.y3i",16,0,
    "ifft_inst.y3q",16,0,
    "ifft_inst.y4i",16,0,
    "ifft_inst.y4q",16,0,
    "ifft_inst.wp_index",7,0,
    "ifft_inst.state",2,0,
    "ifft_inst.fft_addr_cnt",10,0,
    "ifft_inst.fft_addr_cnt_d1",1,0,
    "ifft_inst.degree_cnt",2,0,
    "ifft_inst.op_exp",2,0,
    "ifft_inst.degree_exp",2,0,
    "",0,0,
}
#endif



//using namespace std;


class TextQuery
{
public:

    enum FPGA_Type {Xilinx, Altera};

    enum EDGE_TYPE {posedge , nededge , other} ;

    struct module_top
    {
        char * port_name;
        short inout;
        short width_first;
        short width_second;
    };

    struct sample
    {
        char *sample_name ;
        short width_first ;
        short width_second ;
    };

    struct regchain
    {
        char *reg_name;
        short width_first;
        short width_second;
    };

    struct system_port
    {
        char *port_name;
        char *reg_name ;
        short width_first;
        short width_second;
    };

    TextQuery(QString topmodule ,QStringList idatafilename , QString directory ,const QList<module_top*>& inouttbl , const QList<sample *>&sampletbl , const QVector<QList<regchain *> >&chaintbl , \
              const QList<system_port*>& systemporttbl,FPGA_Type type = Altera)
    {
        //memset(this, 0, sizeof(TextQuery));
        inout_table = inouttbl ;
        sample_table = sampletbl ;
        regchain_table = chaintbl ;
        Fpga = type ;
        module_name = topmodule ;
        m_idataFileNameList = idatafilename ;
        m_ioutputDirectory = directory ;
        systeminout_table = systemporttbl ;
    }

    void retrieve_text();
    void constructDataFile(const QString &filename ,const QStringList &datalist);
    void doit()
    {
        retrieve_text();
    }
    void setNoNeedSig(QString clockport, QString resetport ,EDGE_TYPE resetedge,QString resetval) ;

private:
    QList<module_top *> inout_table ;
    QList<sample *> sample_table ;
    QList<system_port*> systeminout_table ;
    QVector<QList<regchain *> > regchain_table;
    QString module_name ;
    FPGA_Type Fpga;
    QStringList m_idataFileNameList ;
    QString m_ioutputDirectory ;
    QString m_iclockSigName ;
    QString m_iresetSigName ;
    EDGE_TYPE m_eresetEdge ;
    QString m_iresetSigVal ;
};




#endif // TEXTQUERY_H
