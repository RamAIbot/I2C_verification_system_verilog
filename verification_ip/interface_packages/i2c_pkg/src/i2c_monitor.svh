class i2c_monitor extends ncsu_component#(.T(i2c_transaction_base));

  i2c_configuration  configuration;
  virtual i2c_if bus;

  T monitored_trans;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    monitored_trans = new("monitored_trans"); ///This should be in constructor and not inside nb_put IMPORTANT Bug
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction
  
  virtual task run ();
    //bus.wait_for_reset();
      forever begin
        //$display("I2C monitor");
        // if ( enable_transaction_viewing) begin
        //    monitored_trans.start_time = $time;
        // end
        
        bus.monitor(monitored_trans.addr, monitored_trans.op, monitored_trans.data);
        // $display("%s i2c_monitor::run() Address 0x%x Operation 0x%p Data 0x%x",
        //          get_full_name(),
        //          monitored_trans.addr, 
        //          monitored_trans.op, 
        //          monitored_trans.data
        //          );
        agent.nb_put(monitored_trans);
        // if ( enable_transaction_viewing) begin
        //    monitored_trans.end_time = $time;
        //    monitored_trans.add_to_wave(transaction_viewing_stream);
        // end
    end
  endtask

endclass
