class wb_monitor extends ncsu_component#(.T(wb_transaction_base));

  wb_configuration  configuration;
  virtual wb_if bus;

  T monitored_trans;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    monitored_trans = new("monitored_trans");
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction
  
  virtual task run ();
    bus.wait_for_reset();
    //$display("Inside WB monitor run");
      forever begin   
        // if ( enable_transaction_viewing) begin
        //    monitored_trans.start_time = $time;
        // end
       //
        bus.master_monitor(
                   monitored_trans.addr,
                   monitored_trans.data,
                   monitored_trans.we                    
                  );
        // $display("wb_monitor::run() Address 0x%x Data 0x%p Operation 0x%x ",
        //          monitored_trans.addr,
        //          monitored_trans.data,
        //          monitored_trans.we
        //          );
        agent.nb_put(monitored_trans);
        // if ( enable_transaction_viewing) begin
        //    monitored_trans.end_time = $time;
        //    monitored_trans.add_to_wave(transaction_viewing_stream);
        // end
    end
  endtask

endclass
