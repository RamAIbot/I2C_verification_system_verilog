class i2c_coverage extends ncsu_component#(.T(i2c_transaction_base));

    i2c_configuration configuration;

    bit[6:0] address_val_i2c;
    logic[7:0] data_val_i2c;
    bit op_val_i2c;

  	
  covergroup i2c_mod_cg;
  	option.per_instance = 1;
    option.name = get_full_name();

  	address_val_i2c: coverpoint address_val_i2c
    {
        option.auto_bin_max = 256;
        //bins addr[] = {[3:0]};
    }

    coverpoint op_val_i2c
    {
       option.auto_bin_max = 1;
    }   
  endgroup


  covergroup i2c_data_cg;
    option.per_instance = 1;
    option.name = get_full_name();

    coverpoint data_val_i2c
    {
      option.auto_bin_max = 256;
    }
  endgroup

  function new(string name = "", ncsu_component #(T) parent = null); 
    super.new(name,parent);
    i2c_mod_cg = new;
    i2c_data_cg = new;
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void nb_put(T trans);
    $display("i2c_coverage::nb_put() %s called",get_full_name());
    address_val_i2c = trans.addr;
    op_val_i2c = trans.op;
    i2c_mod_cg.sample();
    foreach(trans.data[i]) begin
        data_val_i2c = trans.data[i];
        i2c_data_cg.sample();
    end
  endfunction

endclass
