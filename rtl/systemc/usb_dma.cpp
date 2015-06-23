/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB IDMA Engine                                            ////
////                                                             ////
////  SystemC Version: usb_dma.cpp                               ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_idma.v                                ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

#include "systemc.h"
#include "usb_dma.h"

void usb_dma::empty_int_up(void) {
	ep_empty_int.write(ep_empty.read());
}

void usb_dma::full_int_up(void) {
	ep_full_int.write(ep_full.read());
}

void usb_dma::mwe_up1(void) {
	mwe_r.write(rx_data_valid.read());
}

void usb_dma::mwe_up2(void) {
	mwe.write(mwe_r.read() && !ep_full_int.read());
}

void usb_dma::data_valid_up(void) {
	rx_data_valid_r.write(rx_data_valid.read());
}

void usb_dma::data_done_up(void) {
	rx_data_done_r.write(rx_data_done.read());
}

void usb_dma::tx_dma_en_up1(void) {
	tx_dma_en_r.write(tx_dma_en.read());
}

void usb_dma::tx_dma_en_up2(void) {
	tx_dma_en_r1.write(tx_dma_en_r.read());
}

void usb_dma::tx_dma_en_up3(void) {
	tx_dma_en_r2.write(tx_dma_en_r1.read());
}

void usb_dma::idma_done_up(void) {
	idma_done.write(rx_data_done_r.read() || sizd_is_zero_d.read() || ep_empty_int.read());
}

void usb_dma::rx_cnt_up1(void) {
	if (!rst.read())
		rx_cnt_r.write(0);
	else if (rx_data_done_r.read())
		rx_cnt_r.write(0);
	else if (rx_data_valid.read())
		rx_cnt_r.write(rx_cnt_r.read() + 1);
}

void usb_dma::rx_cnt_up2(void) {
	if (!rst.read())
		rx_cnt.write(0);
	else if (rx_data_done_r.read())
		rx_cnt.write(rx_cnt_r.read());
}

void usb_dma::rx_done_up(void) {
	rx_done.write(rx_data_done_r.read());
}

// Transmit Size Counter (counting backward from input size)
// For MAX packet size
void usb_dma::sizd_cnt_up(void) {
	if (!rst.read())
		sizd_c.write(511);
	else if (tx_dma_en.read())
		sizd_c.write(size.read());
	else if (siz_dec.read())
		sizd_c.write(sizd_c.read() - 1);
}

void usb_dma::is_zero_up1(void) {
	sizd_is_zero_d.write(sizd_c.read() == 0);
}

void usb_dma::is_zero_up2(void) {
	sizd_is_zero.write(sizd_is_zero_d.read());
}

void usb_dma::siz_dec_up(void) {
	siz_dec.write((tx_dma_en_r.read() || tx_dma_en_r1.read() || rd_next.read()) && !sizd_is_zero_d.read());
}

void usb_dma::tx_busy_up(void) {
	tx_busy.write(send_data.read() || tx_dma_en_r.read() || tx_dma_en.read());
}

void usb_dma::tx_valid_up1(void) {
	tx_valid_r.write(tx_valid.read());
}

void usb_dma::tx_valid_up2(void) {
	tx_valid_e.write(tx_valid_r.read() && !tx_valid.read());
}

// Since we are prefetching two entries in to our fast fifo, we
// need to know when exactly ep_empty was asserted, as we might
// only need 1 or 2 bytes. This is for ep_empty_r
void usb_dma::empty_up(void) {
	if (!rst.read())
		ep_empty_r.write(false);
	else if (!tx_valid.read())
		ep_empty_r.write(false);
	else if (tx_dma_en_r2.read())
		ep_empty_r.write(ep_empty_int.read());
}

void usb_dma::send_data_up1(void) {
	if (!rst.read())
		send_data_r.write(false);
	else if (tx_dma_en_r.read() && !ep_empty_int.read())
		send_data_r.write(true);
	else if (rd_next.read() && (sizd_is_zero_d.read() || (ep_empty_int.read() && !sizd_is_zero_d.read())))
		send_data_r.write(false);
}

void usb_dma::send_data_up2(void) {
	send_data.write((send_data_r.read() && !ep_empty_r.read() && !(sizd_is_zero.read() &&
			(size.read() == 1))) || tx_dma_en_r1.read());
}

void usb_dma::mre_up(void) {
	mre.write((tx_dma_en_r1.read() || tx_dma_en_r.read() || rd_next.read()) &&
			!sizd_is_zero_d.read() && !ep_empty_int.read() &&
			(send_data.read() || tx_dma_en_r1.read() || tx_dma_en_r.read()));
}

void usb_dma::ff_we_up1(void) {
	ff_we1.write(mre.read());
}

void usb_dma::ff_we_up2(void) {
	ff_we.write(ff_we1.read());
}

void usb_dma::ff_re_up(void) {
	ff_re.write(rd_next.read());
}

void usb_dma::ff_clr_up(void) {
	ff_clr.write(!tx_valid.read());
}
/*
usb_dma::~usb_dma(void) {
	if (i_ff2)
		delete i_ff2;
}
*/
