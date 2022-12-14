class i2cmb_env_configuration extends ncsu_configuration;

//   bit       loopback;
//   bit       invert;
//   bit [3:0] port_delay;

  covergroup i2cmb_env_configuration_cg;
  	option.per_instance = 1;
    option.name = name;
  	// coverpoint loopback;
  	// coverpoint invert;
  	// coverpoint port_delay;
  endgroup

  function void sample_coverage();
  	i2cmb_env_configuration_cg.sample();
  endfunction
  
  wb_configuration p0_agent_config;
  i2c_configuration p1_agent_config;

  function new(string name=""); 
    super.new(name);
    i2cmb_env_configuration_cg = new;
    p0_agent_config = new("p0_agent_config");
    p1_agent_config = new("p1_agent_config");
    p0_agent_config.collect_coverage=1;
    p1_agent_config.collect_coverage=1;
    p0_agent_config.sample_coverage();
    p1_agent_config.sample_coverage();
  endfunction

endclass
