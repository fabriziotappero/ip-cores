//errorhandler_sim.cpp
/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is HyperTransport Tunnel IP Core.
 *
 * The Initial Developer of the Original Code is
 * Ecole Polytechnique de Montreal.
 * Portions created by the Initial Developer are Copyright (C) 2005
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Ami Castonguay <acastong@grm.polymtl.ca>
 *
 * Alternatively, the contents of this file may be used under the terms
 * of the Polytechnique HyperTransport Tunnel IP Core Source Code License 
 * (the  "PHTICSCL License", see the file PHTICSCL.txt), in which case the
 * provisions of PHTICSCL License are applicable instead of those
 * above. If you wish to allow use of your version of this file only
 * under the terms of the PHTICSCL License and not to allow others to use
 * your version of this file under the MPL, indicate your decision by
 * deleting the provisions above and replace them with the notice and
 * other provisions required by the PHTICSCL License. If you do not delete
 * the provisions above, a recipient may use your version of this file
 * under either the MPL or the PHTICSCL License."
 *
 * ***** END LICENSE BLOCK ***** */

#include "errorhandler_sim.h"
#include <math.h>

namespace
{
	// number that shall come from a random generator to apply
	// signals that are considered don't cares
	int randomNb = 6455;
	// option for selecting a particular test vector
	int testOption = 0;
	sc_bv<32> ZERO_BV32 = "00000000000000000000000000000000";
};


ht_errorHandler_sim::ht_errorHandler_sim( sc_module_name name ) :
	sc_module(name)
{	
	// Thread where processes are notified
	SC_THREAD(simulate);

	SC_METHOD(coldReset);
	sensitive(activate_coldReset);
	dont_initialize();
	SC_METHOD(warmReset);
	sensitive(activate_warmReset);
	dont_initialize();
	SC_METHOD(sendRequest);
	sensitive(activate_sendRequest);
	dont_initialize();
	SC_METHOD(receiveResponse);
	sensitive(activate_receiveResponse);
	dont_initialize();
}



/// Deactivate all the flag signals
void
ht_errorHandler_sim::dropFlagSignals()
{
	ro_available_eh.write( false );
	fc_consume_eh.write( false );
	csr_eoc.write( sc_bit(0) );
	csr_initcomplete.write( sc_bit(0) );
	csr_drop_uninit_link.write( sc_bit(0) );
}

/// On triggering, activate a cold reset for 20 ns
void
ht_errorHandler_sim::coldReset()
{
	next_trigger(activate_coldReset);
	cout << "ht_errorHandler_sim::coldReset" << endl;
	
	pwrok.write(false);
	resetx.write(false);

	next_trigger(20,SC_NS);

	pwrok.write(true);

	next_trigger(20,SC_NS);

	resetx.write(true);

	next_trigger(activate_coldReset);
}

/// On triggering, activate a warm reset for 20 ns
void
ht_errorHandler_sim::warmReset()
{
	next_trigger(activate_warmReset);
	cout << "ht_errorHandler_sim::warmReset" << endl;

	resetx.write(false);

	next_trigger(20,SC_NS);

	resetx.write(true);

	next_trigger(activate_warmReset);
}

/// On triggering, send signals corresponding to a test vector for 
/// testing the	Request Packet reception interface of ht_errorHandler module
void
ht_errorHandler_sim::sendRequest()
{
	next_trigger(activate_sendRequest);
	cout << "ht_errorHandler_sim::sendRequest" << endl;

	syn_ControlPacketComplete dummyCtrlPkt; // defaults to NOP packet
	syn_ControlPacketComplete ctrlPkt;

	switch( testOption )
	{
/*
Tableau 60 - Tests pour le Reordering (RO)

Vecteur d'entrée	Actions / États intermédiaires	Vecteur de sortie
ro_command_eh = X
ro_available_eh = X
RO_data_associated = 1
RO_data_addr = X
RO_addr_error = X	Ne rien faire.
Erreur: données manquantes. Un paquet de commande n'a pas été envoyé. Une donnée ne peut donc pas y être associée.	ack_RO = 0
*/
	case 0:
	ro_command_eh.write( dummyCtrlPkt );
	ro_available_eh.write( false );

	break;
/*
ro_command_eh = X
ro_available_eh = X
RO_data_associated = 0
RO_data_addr = X
RO_addr_error = 1	Ne rien faire.
Erreur: données manquantes. Un paquet de commande n'a pas été envoyé. L'erreur d'adressage ne peut pas y être associée.	ack_RO = 0
*/
	case 1:
	dummyCtrlPkt.error64BitExtension = true;
	ro_command_eh.write( dummyCtrlPkt );
	ro_available_eh.write( false );
	break;

/*
ro_command_eh = X
ro_available_eh = X
RO_data_associated = 0
RO_data_addr = X
RO_addr_error = 0	Ne rien faire.
Erreur: données manquantes. Un paquet de commande n'a pas été envoyé. L'erreur EOC ne peut y être associée.	ack_RO = 0
*/
	case 2:
	dummyCtrlPkt.error64BitExtension = false;
	ro_command_eh.write( dummyCtrlPkt );
	ro_available_eh.write( false );
	break;

/*
ro_command_eh = command ro_available_eh = 1
RO_data_associated = 0
RO_data_addr = X
RO_addr_error = 0	Pas d'erreur de type EOC. Donc on ne lit pas la commande.	ack_RO = 0
*/
	case 3:
	ro_command_eh.write( dummyCtrlPkt );
	ro_available_eh.write( true );
	break;

/*
ro_command_eh = command
ro_available_eh = 1
RO_data_associated = 0
RO_data_addr = X
RO_addr_error = 0	Oui une erreur de type EOC. On lit la commande.	ack_RO = 1
*/
	case 4:
	{
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(randomNb);
	BroadcastPacket bp( "0000", "0001" );
	ctrlPkt.packet = bp;
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );
	}
	break;

/*
ro_command_eh = command
ro_available_eh = 0
RO_data_associated = 0
RO_data_addr = X
RO_addr_error = 0	Ne rien faire.	ack_RO = 0
*/
	case 5:
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( false );
	break;

/*
ro_command_eh = command
ro_available_eh = 1
RO_data_associated = 1
RO_data_addr = "0000"
RO_addr_error = 0
RO_EOC_error = 0	Oui une erreur de type EOC. On lit la commande. Lui associer l'adresse 0 pour la donnée associée.	ack_RO = 1
*/
	case 6:
	{
	// Has data and is posted
	sc_bv<64> bv;
	bv.range(63,32) = ZERO_BV32;
	bv.range(31,0) = "00000000000000000000000000101000";
	ReadPacket rp( bv ); 
	ctrlPkt.packet = rp;
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
	ctrlPkt.error64BitExtension = false;
	csr_eoc.write( sc_bit(1) );
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );
	}
	break;

/*
ro_command_eh = command
ro_available_eh = 1
RO_data_associated = X
RO_data_addr = X
RO_addr_error = 1
RO_EOC_error = 0	Oui une erreur de type EOC. On lit la commande. Lui associer une erreur d'adressage 64 bits.	ack_RO = 1
*/
	case 7:
	{
	// Has data and is posted
	sc_bv<64> bv;
	bv.range(63,32) = ZERO_BV32;
	bv.range(31,0) = "00000000000000000000000000101000";
	ReadPacket rp( bv ); 
	ctrlPkt.packet = rp;
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(randomNb);
	ctrlPkt.error64BitExtension = true;
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );
	}
	break;

/*
ro_command_eh = command
ro_available_eh = 1
RO_data_associated = X
RO_data_addr = X
RO_addr_error = 1
RO_EOC_error = 1	Oui une erreur de type EOC. On lit la commande. Lui associer une erreur de type EOC et une erreur d'adressage 64 bits.	ack_RO = 1
*/
	case 8:
	{
	// Has data and is non posted
	sc_bv<64> bv;
	bv.range(63,32) = ZERO_BV32;
	bv.range(31,0) = "00000000000000000000000000001000";
	WritePacket wp( bv ); 
	ctrlPkt.packet = wp;
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(randomNb);
	ctrlPkt.error64BitExtension = false;
	csr_eoc.write( sc_bit(1) );
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );
	}
	break;
	}

	next_trigger(activate_sendRequest);
}

/// On triggering, send signals corresponding to a test vector for 
/// testing the	Response Packet sending interface of ht_errorHandler module
void
ht_errorHandler_sim::receiveResponse()
{
	next_trigger(activate_receiveResponse);
	cout << "ht_errorHandler_sim::receiveResponse" << endl;

	ControlPacketComplete ctrlPkt;

	switch( testOption )
	{	
	/*
Tableau 61 - Tests pour le Flow Control et Data Buffer (FC,DB)

Vecteur d'entrée	Actions / États intermédiaires	Vecteur de sortie
fc_consume_eh = X
	Ne rien faire.
	eh_datacommand_fc = X
eh_available_fc = 0
eh_address_db = X
eh_drop_db = 0
eh_vctype_db = X
*/
	case 0:
	{
//	fc_consume_eh.write( randomNb );
	}
	break;

/*
fc_consume_eh = 1	Ne rien faire.
	eh_datacommand_fc = X
eh_available_fc = 0
eh_address_db = X
eh_drop_db = 0
eh_vctype_db = X
*/
	case 1:
	{
	fc_consume_eh.write( true );
	}
	break;

/*
fc_consume_eh = 0	La commande est un Broadcast. Ne rien faire.	eh_datacommand_fc = X
eh_available_fc = 0
eh_address_db = X
eh_drop_db = 0
eh_vctype_db = X
*/
	case 2:
	{
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(randomNb);
	BroadcastPacket bp( "0000", "0001" );
	ctrlPkt.packet = bp;
	ctrlPkt.error64BitExtension = false;
	csr_eoc.write( sc_bit(1) );
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );
	}
	break;

/*
fc_consume_eh = 0	La commande est un NonPosted Write. Envoyer un message TgtDone.	eh_datacommand_fc = command
eh_available_fc = 1,0
eh_address_db = X
eh_drop_db = 0
eh_vctype_db = X
*/
	case 3:
	{
	// Has data and is non posted
	sc_bv<64> bv;
	bv.range(63,32) = ZERO_BV32;
	bv.range(31,0) = "00000000000000000000000000001000";
	WritePacket wp( bv );
	ctrlPkt.packet = wp;
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(randomNb);
	csr_eoc.write( sc_bit(1) );
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );
	}
	break;

/*
fc_consume_eh = 0,1,0	La commande est un NonPosted Read. Envoyer un message RdResponse. Attendre que le ack tombe à vrai puis à faux, puis envoyer le data associé.	eh_datacommand_fc = command, data
eh_available_fc = 1,0,1,0
eh_address_db = X
eh_drop_db = 0
eh_vctype_db = X
*/
	case 4:
	{
	// Has data and is non posted
	sc_bv<64> bv;
	ReadPacket rp(  "0000","10000","01010","0111",0,true);

	ctrlPkt.packet = rp;
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
	csr_eoc.write( sc_bit(1) );
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );

//	fc_consume_eh.write( true );
	}
	break;

/*
fc_consume_eh = 0	La commande est un Posted Write. Si du data lui est associé, écrire l'adresse ainsi que le canal de la commande. Attendre un front et mettre drop à vrai.	eh_datacommand_fc = X
eh_available_fc = 0
eh_address_db = "0000"
eh_drop_db = 0,1
eh_vctype_db = "00"
*/
	case 5:
	{
	// Has data and is posted
	sc_bv<64> bv;
	bv.range(63,32) = ZERO_BV32;
	bv.range(31,0) = "00000000000000000000000000101000";
	WritePacket wp( bv );
	ctrlPkt.packet = wp;
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
	csr_eoc.write( sc_bit(1) );
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );
	}
	break;

/*
fc_consume_eh = 0	La commande est un Posted Read. Si du data lui est associé, écrire l'adresse ainsi que le canal de la commande. Attendre un front et mettre drop à vrai.	eh_datacommand_fc = X
eh_available_fc = 0
eh_address_db = "0000"
eh_drop_db = 0,1
eh_vctype_db = "00"
*/
	case 6:
	{
	// Has data and is posted
	sc_bv<64> bv;
	bv.range(63,32) = ZERO_BV32;
	bv.range(31,0) = "00000000000000000000000000101000";
	ReadPacket rp( bv ); 
	ctrlPkt.packet = rp;
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(0);
	csr_eoc.write( sc_bit(1) );
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );

	fc_consume_eh.write( true );
	}
	break;

/*
fc_consume_eh = 0	La commande est un Atomic. Si du data lui est associé, écrire l'adresse ainsi que le canal de la commande. Attendre un front et mettre drop à vrai.	eh_datacommand_fc = X
eh_available_fc = 0
eh_address_db = X
eh_drop_db = X
eh_vctype_db = X
*/
	case 7:
	{
	// Does not have data and is non posted
	sc_bv<64> bv;
	bv.range(63,32) = ZERO_BV32;
	bv.range(31,0) = ZERO_BV32;
	AtomicPacket ap( bv ); 
	ctrlPkt.packet = ap;
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(randomNb);
	csr_eoc.write( sc_bit(1) );
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );
	}
	break;

/*
fc_consume_eh = 0	La commande est un Flush.	eh_datacommand_fc = X
eh_available_fc = 0
eh_address_db = X
eh_drop_db = X
eh_vctype_db = X
*/
	case 8:
	{
	// Does not have data and is non posted
	FlushPacket fp( "0001", "0000" );
	ctrlPkt.packet = fp;
	ctrlPkt.data_address = sc_uint<BUFFERS_ADDRESS_WIDTH>(randomNb);
	csr_eoc.write( sc_bit(1) );
	ro_command_eh.write( ctrlPkt );
	ro_available_eh.write( true );
	}
	break;
	}

	next_trigger(activate_receiveResponse);

}


/// Thread for activating the processes. Deal with timing issues.
void
ht_errorHandler_sim::simulate()
{
	while( true )
	{
		testOption = 4;

		cout << "ht_errorHandler_sim::simulate1" << endl;
		//activate_coldReset.notify();
		resetx.write(true);
		pwrok.write(true);

		dropFlagSignals();
		wait( 35, SC_NS );
		cout << "ht_errorHandler_sim::simulate2" << endl;
		activate_sendRequest.notify();
		wait( 40, SC_NS ); 
		cout << "ht_errorHandler_sim::simulate3" << endl;
		dropFlagSignals();
		wait( 40, SC_NS );
		cout << "ht_errorHandler_sim::simulate4" << endl;
		activate_receiveResponse.notify();
		wait( 40, SC_NS );
		fc_consume_eh.write( true );
		wait( 40, SC_NS );
		ro_available_eh.write( false );
		wait( 40, SC_NS );
		fc_consume_eh.write( false );
		wait( 20, SC_NS );
		fc_consume_eh.write( true );
		wait();
	}
}
