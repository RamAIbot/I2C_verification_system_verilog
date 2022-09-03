class wb_driver extends ncsu_component#(.T(wb_transaction_base));

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  virtual wb_if bus;
  wb_configuration configuration;
  wb_transaction_base wb_trans;

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
    //$display({get_full_name()," ",trans.convert2string()});
    if(trans.check_for_irq == 1'b0) begin
      bus.master_write(
              trans.addr,
              trans.data);
      //bus.master_read(2'b11,trans.data); //Reading FSMR for coverage
    end

    else begin
      if(trans.addr == 2'b10) begin
        //$display("Waiting for interrupt");
        bus.wait_for_interrupt();
        //bus.master_read(2'b11,trans.data); //Reading FSMR for coverage
      end
      //$display("Reading from CMDR to remove irq");
      bus.master_read(
                 trans.addr,
                 trans.data);
      bus.master_read(2'b11,trans.data); //Reading FSMR for coverage
    end

     //bus.master_read(2'b11,trans.data); //Reading FSMR for coverage
  endtask

endclass
