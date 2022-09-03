class i2cmb_random_test_base extends ncsu_component#(.T(i2c_transaction_base));

  i2cmb_env_configuration  cfg;
  i2cmb_environment        env;
  i2cmb_random_generator          gen;


  function new(string name = "", ncsu_component_base parent = null); 
    super.new(name,parent);
    cfg = new("cfg");
    cfg.sample_coverage();
    env = new("env",this);
    env.set_configuration(cfg);
    env.build();
    gen = new("gen",this);
    gen.set_agent0(env.get_p0_agent());
    gen.set_agent1(env.get_p1_agent());
  endfunction

  virtual task run();
     env.run();
     gen.run();
  endtask

endclass
