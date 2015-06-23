
typedef virtual interface wb_m_if#(lp_ADDR_W, lp_DATA_W, lp_SEL_W)  virt_wb_m_if_t;

class wb_tb_simple_master;

  static int id = 0;

  static function int next_id();
    next_id = ++id;
  endfunction

  string          name;
  virt_wb_m_if_t  m_if;

  function new (string name = "master", virt_wb_m_if_t  m_if );
    string str;
  begin
    str.itoa(next_id());
    this.name = {name, " " ,str};

    this.m_if = m_if;
  end
  endfunction : new

  //------------------------------------------------------------------------------------------------------
  // task to generate data packet for ram
  //------------------------------------------------------------------------------------------------------

  bit [lp_DATA_W-1 : 0] data [];

  task generate_data_packet (int length = 10);
    data = new[length];
    for (int i = 0; i < length; i++)
      data[i] = i+$urandom_range(1,512);//$urandom;
    //$display("[%t]: %m, length==%h", $time, length); //for (int i=0;i<5;i++) $display("[%t]: %m, data[i]==%h", $time, data[i]);
  endtask

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  int max_ws  = 0;
  int err_cnt = 0;

  //
  task init ();
    m_if.init();
    $display("%s ready", name);
  endtask

  //
  function void log ();
    $display("%s have %0d errors", name, err_cnt);
  endfunction

  //
  task write_data_packet (input bit [lp_ADDR_W-1:0] start_addr, input int hold = 0, rnd = 0);
    int addr;
    int err;
    int delay;
  begin
    //$display("[%t]: %m ps 1, data.size()==%h, hold==%b", $time, data.size(), hold);
    for (int i = 0; i < data.size(); i++) begin
      addr  = start_addr + i;
      delay = rnd ? $urandom_range(0, max_ws) : max_ws;

      if (hold) begin
        if (i == (data.size()-1)) begin //$display("[%t]: %m 1", $time);
            m_if.write_end(err, addr, data[i], delay); //$display("[%t]: %m 2", $time);
          end
        else begin //$display("[%t]: %m 3", $time);
            m_if.write_begin(err, addr, data[i], delay); //$display("[%t]: %m 4", $time);
          end
      end
      else begin //$display("[%t]: %m 5", $time);
        m_if.write(err, addr, data[i], delay); //$display("[%t]: %m 6", $time);
      end

      assert (err == 0) else begin
        $warning("%s bus error occured", name);
        $stop;
      end
    end
    //$display("[%t]: %m pe 1", $time);
  end
  endtask

  task write_data_packet_nlocked (input bit [lp_ADDR_W-1:0] start_addr, input int rnd = 0);
    write_data_packet (start_addr, 0, rnd);
  endtask

  task write_data_packet_locked (input bit [lp_ADDR_W-1:0] start_addr, input int rnd = 0);
    write_data_packet (start_addr, 1, rnd);
  endtask

  //
  task read_data_packet (input bit [lp_ADDR_W-1:0] start_addr, hold = 0, input int rnd = 0);
    int addr;
    int err;
    int delay;
    bit [lp_DATA_W-1 : 0] rd_data;
  begin
    for (int i = 0; i < data.size(); i++) begin
      addr  = start_addr + i;
      delay = rnd ? $urandom_range(0, max_ws) : max_ws;

      if (hold) begin
        if (i == (data.size()-1))
          m_if.read_end(err, rd_data, addr, delay);
        else
          m_if.read_begin(err, rd_data, addr, delay);
      end
      else begin
        m_if.read(err, rd_data, addr, delay);
      end

      assert (rd_data == data[i]) else begin
        $error("%s slave reading bus error occured, rd_data != data[i] : i=%h, rd_data==%h, data[i]==%h", name, i, rd_data, data[i]); //#10ns; $stop;
        err_cnt++;
      end

      assert (err == 0) else begin
        $warning("%s bus error occured", name);
        $stop;
      end
    end
  end
  endtask

  task read_data_packet_nlocked (input bit [lp_ADDR_W-1:0] start_addr, input int rnd = 0);
    read_data_packet (start_addr, 0, rnd);
  endtask

  task read_data_packet_locked (input bit [lp_ADDR_W-1:0] start_addr, input int rnd = 0);
    read_data_packet (start_addr, 1, rnd);
  endtask

endclass
