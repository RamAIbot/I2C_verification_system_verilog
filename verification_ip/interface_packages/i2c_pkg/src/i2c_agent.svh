class i2c_agent extends ncsu_component#(.T(i2c_transaction_base));

  i2c_configuration configuration;
  i2c_driver        driver;
  i2c_monitor       monitor;
  i2c_coverage      coverage;
  ncsu_component #(T) subscribers[$];
  virtual i2c_if    bus;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    if ( !(ncsu_config_db#(virtual i2c_if)::get(get_full_name(), this.bus))) begin;
      $display("abc_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      $finish;
    end
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    driver = new("driver",this);
    driver.set_configuration(configuration);
    driver.build();
    driver.bus = this.bus;
    //ADD THIS TO ENCLOSE COVERAGE PART IN CODE LATER FOR PROJECT 3 and 4
    if (configuration.collect_coverage) begin
      coverage = new("coverage",this);
      coverage.set_configuration(configuration);
      coverage.build();
      connect_subscriber(coverage);
    end
    monitor = new("monitor",this);
    monitor.set_configuration(configuration);
    monitor.set_agent(this);
    //monitor.enable_transaction_viewing = 1;
    monitor.build();
    monitor.bus = this.bus;
  endfunction

  virtual function void nb_put(T trans);
    foreach(subscribers[i]) begin
      //$display("AGENT_Subscriber_start");
      subscribers[i].nb_put(trans);
      //$display("I2C_SUbs_Put_size:%x",trans.data.size());
      //$display("AGENT_Subscriber_stop");
    end
  endfunction

  virtual task bl_put(T trans);
    driver.bl_put(trans);
  endtask

  virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    subscribers.push_back(subscriber);
  endfunction

  virtual task run();
      //$display("inside I2c agent run");
     fork monitor.run();driver.run(); join_none
  endtask

endclass


