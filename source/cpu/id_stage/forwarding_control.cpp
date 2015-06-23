#include "forwarding_control.h"

void forwarding_control::do_forwarding_control()
{
  if ((id_ex_writeregister.read() == rs.read()) && (id_ex_regwrite.read() == 1))
    {
      id_fw_ctrl.write("01");
    }
  else if ((id_ex_m_writeregister.read() == rs.read()) && (id_ex_m_regwrite.read() == 1))
    {
      id_fw_ctrl.write("10");
    }
  else if ((id_ex_m_wb_writeregister.read() == rs.read()) && (id_ex_m_wb_regwrite.read() == 1))
    {
      id_fw_ctrl.write("11");
    }
  else
    {
      id_fw_ctrl.write("00");
    }
}
