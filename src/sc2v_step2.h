/* -----------------------------------------------------------------------------
 *
 *  SystemC to Verilog Translator v0.4
 *  Provided by Universidad Rey Juan Carlos
 *
 * -----------------------------------------------------------------------------
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include "sglib.h"
 
#define MAX_NAME_LENGTH 256
 
typedef struct _write_node
{
  char name[MAX_NAME_LENGTH];
  struct _write_node *next;
} WriteNode;

typedef struct _port_node
{
  char name[MAX_NAME_LENGTH];
  char tipo[MAX_NAME_LENGTH];
  int size;
  struct _port_node *next;
  int pflag;
} PortNode;

typedef struct _signal_node
{
  char name[MAX_NAME_LENGTH];
  int size;
  int arraysize;
  struct _signal_node *next;
  int sflag;
} SignalNode;

typedef struct _bind_node
{
  char nameport[MAX_NAME_LENGTH];
  char namebind[MAX_NAME_LENGTH];
  struct _bind_node *next;
} BindNode;

typedef struct _instance_node
{
  char nameinstance[MAX_NAME_LENGTH];
  char namemodulo[MAX_NAME_LENGTH];
  BindNode *bindslist;
  struct _instance_node *next;
} InstanceNode;

typedef struct _funcinput_node
{
  int lenght;
  char name[MAX_NAME_LENGTH];
  struct _funcinput_node *next;
  int sgnflag;
} FunctionInputNode;


typedef struct _function_node
{
  char name[MAX_NAME_LENGTH];
  int outputlenght;
  FunctionInputNode *list;
  struct _function_node *next;
  int sgnflag;
} FunctionNode;

typedef struct _sensibility_node
{
  char tipo[MAX_NAME_LENGTH];
  char name[MAX_NAME_LENGTH];
  struct _sensibility_node *next;
} SensibilityNode;


typedef struct _process_node
{
  char name[MAX_NAME_LENGTH];
  char tipo[MAX_NAME_LENGTH];			//comb or seq
  SensibilityNode *list;
  struct _process_node *next;
} ProcessNode;

typedef struct _enumerates_node
{
  char name[MAX_NAME_LENGTH];
  struct _enumerates_node *next;
} EnumeratesNode;

typedef struct _enumlist_node
{
  char name[MAX_NAME_LENGTH];
  int istype;
  EnumeratesNode *list;
  struct _enumlist_node *next;
} EnumListNode;


/*Global var to read from file_writes.sc2v*/
  WriteNode *writeslist;
/*Global var to store ports*/
  PortNode *portlist;
/* Global var to store signals*/
  SignalNode *signalslist;
/* Global var to store sensitivity list*/
  SensibilityNode *sensibilitylist;
/* Global var to store process list*/
  ProcessNode *processlist;
/* Global var to store instantiated modules*/
  InstanceNode *instanceslist;
/*List of enumerates*/
  EnumeratesNode *enumerateslist;
  EnumListNode *enumlistlist;
/* Global var to store functions inputs list*/
  FunctionInputNode *funcinputslist;
/* Global var to store process list*/
  FunctionNode *functionslist;



/* Functions for DEFINES list*/
void ShowDefines (char *filedefines);

/* Functions for WRITES list*/
WriteNode *InsertWrite (WriteNode *list,char *name);
int IsWrite (WriteNode *list,char *name);
WriteNode *ReadWritesFile (WriteNode *list,char *name);

/* Functions for ports list*/
PortNode *InsertPort (PortNode *list,char *name, char *tipo, int size, int pflag);
void ShowPortList (PortNode *list);
void EnumeratePorts (PortNode *list);

/* Functions for signals list*/
SignalNode *InsertSignal (SignalNode *list,char *name, int size,int arraysize,int sflag);
void ShowSignalsList (SignalNode* list, WriteNode* writeslist);
int IsWire (char *name, InstanceNode * list);

/* Functions for sensitivity list*/
SensibilityNode *InsertSensibility (SensibilityNode * list, char *name, char *tipo);
void ShowSensibilityList (SensibilityNode * list);

/* Functions for process list*/
ProcessNode *InsertProcess (ProcessNode * list, char *name,SensibilityNode *SensibilityList, char *tipo);
void ShowProcessList (ProcessNode *list);
void ShowProcessCode (ProcessNode *list);

/* Functions for instances and binds list*/
InstanceNode *InsertInstance (InstanceNode *list, char *nameInstance,char *namemodulo);
BindNode *InsertBind (BindNode *list, char *namePort, char *namebind);
void ShowInstancedModules (InstanceNode * list);

/* Functions for enumerates list*/
EnumeratesNode *InsertEnumerates (EnumeratesNode * list, char *name);
int ShowEnumeratesList (EnumeratesNode * list);

/*Functions of list of enumerates list*/
EnumListNode *InsertEnumList (EnumListNode * list, EnumeratesNode * enumlist,char *name, int istype);
void ShowEnumListList (EnumListNode * list);
int findEnumList (EnumListNode * list, char *name);
int findEnumerateLength (EnumListNode * list, int offset);

/* Functions for functions inputs list*/
FunctionInputNode *InsertFunctionInput (FunctionInputNode * list, char *name, int lenght, int flag);
void ShowFunctionInputs (FunctionInputNode * list);

/* Functions for functions list*/
FunctionNode *InsertFunction (FunctionNode *list, char *name,FunctionInputNode *InputsList,int outputlenght,int flag);
void ShowFunctionCode (FunctionNode *list);
