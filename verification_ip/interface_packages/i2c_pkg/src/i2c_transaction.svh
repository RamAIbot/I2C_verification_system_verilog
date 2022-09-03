class i2c_transaction_base extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction_base)

  //      bit [63:0] header, payload [8], trailer;
  // rand bit [5:0]  delay;

  parameter int I2C_ADDRESS_WDITH = 7;
  parameter int I2C_DATA_WIDTH = 8;

  bit[I2C_ADDRESS_WDITH-1:0] addr;
  bit[1:0] op;
  bit[I2C_DATA_WIDTH-1:0] data[];
  bit transfer_complete;
  bit[I2C_DATA_WIDTH-1:0] read_data[];
  bit alt_read_write;
  int x;

  function new(string name=""); 
    super.new(name);
    x = 0;
    alt_read_write = 1'b0;
  endfunction

  virtual function string convert2string();
      //$display("Convert to string i2cTrans");
     return {super.convert2string(),$sformatf("Address:0x%x Operation:0x%x Data:0x%p", addr, op, data)};
  endfunction

  function bit compare(i2c_transaction_base rhs);
    return ((this.addr  == rhs.addr ) && 
            (this.op == rhs.op) &&
            (this.data == rhs.data) );
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
