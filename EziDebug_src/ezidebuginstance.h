#ifndef EZIDEBUGINSTANCE_H
#define EZIDEBUGINSTANCE_H

#include "ezidebugmodule.h"
template <class Key, class T> class QMap ;
class EziDebugInstance :public EziDebugModule
{

   QMap<QString,QString> m_idefparameter ; // defparameter ²ÎÊý
};

#endif // EZIDEBUGINSTANCE_H
