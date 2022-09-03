class wb_transaction_base extends ncsu_transaction;
  `ncsu_register_object(wb_transaction_base)

  //      bit [63:0] header, payload [8], trailer;
  // rand bit [5:0]  delay;
  parameter int WB_ADDR_WIDTH = 2;
  parameter int WB_DATA_WIDTH = 8;
  bit [WB_ADDR_WIDTH-1:0]  addr;
  logic [WB_DATA_WIDTH-1:0]  data;
  bit we;
  bit check_for_irq;

  rand bit [WB_ADDR_WIDTH-1:0]  random_addr;
  rand logic [WB_DATA_WIDTH-1:0]  random_data;
  rand bit random_we;
  // rand bit check_for_irq;
  rand bit[3:0] bus_id;
  // //rand bit[WB_ADDR_WDITH-1:0] read_address;

  function new(string name=""); 
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string(),$sformatf("Address:0x%x WE:0x%x Data:0x%p ", this.addr, this.we, this.data)};
  endfunction

  function bit compare(wb_transaction_base rhs);
    return ((this.addr  == rhs.addr ) && 
            (this.data == rhs.data) &&
            (this.we == rhs.we) );
  endfunction

  // virtual function void add_to_wave(int transaction_viewing_stream_h);
  //    super.add_to_wave(transaction_viewing_stream_h);
  //    $add_attribute(transaction_view_h,header,"header");
  //    $add_attribute(transaction_view_h,payload,"payload");
  //    $add_attribute(transaction_view_h,trailer,"trailer");
  //    $add_attribute(transaction_view_h,delay,"delay");
  //    $end_transaction(transaction_view_h,end_time);
  //    $free_transaction(transaction_view_h);
  // endfunction

endclass
