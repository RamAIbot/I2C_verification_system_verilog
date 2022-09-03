class i2cmb_predictor extends ncsu_component#(.T(wb_transaction_base));

  ncsu_component#(i2c_transaction_base) scoreboard;
  i2c_transaction_base transport_trans;
  i2cmb_env_configuration configuration;

  i2c_transaction_base i2c_trans_temp;

  bit start_bit,stop_bit,started;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    i2c_trans_temp = new("i2c_trans_temp");
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(ncsu_component #(i2c_transaction_base) scoreboard);
      this.scoreboard = scoreboard;
  endfunction

  virtual function void nb_put(T trans);
  //$display("I2cmb_pred nb_put");
    //$display({get_full_name()," ",trans.convert2string()});
    if(trans.addr == 2'b10) begin
        //Using CMDR Register
        //Start condition
        if(trans.data == 8'b100) begin
            start_bit = 1'b1;
            stop_bit = 1'b0;
            started = 1;
        end

        //Stop condition
        if(trans.data == 8'b101) begin //Dont use 
            start_bit = 1'b0;
            stop_bit = 1'b1;
        end
    end

    //Getting data
    //DPR register
    if(start_bit && !stop_bit && trans.addr == 2'b01) begin
      i2c_trans_temp.data = new[i2c_trans_temp.data.size() + 1](i2c_trans_temp.data);
      i2c_trans_temp.data[i2c_trans_temp.data.size()-1] = trans.data;
      //$display("Data from wb: %x",i2c_trans_temp.data[i2c_trans_temp.data.size()-1]);
    end

    if(start_bit && !stop_bit && trans.addr == 2'b01) begin
      if(started == 1) begin
        i2c_trans_temp.op = i2c_trans_temp.data[i2c_trans_temp.data.size() - 1][0];
        i2c_trans_temp.addr = (i2c_trans_temp.data[i2c_trans_temp.data.size() - 1] >> 1);
        started = 0;
        //$display("Address from wb:%x",i2c_trans_temp.addr);
        i2c_trans_temp.data.delete();
      end
      scoreboard.nb_transport(i2c_trans_temp, transport_trans);
    end
    
  endfunction

endclass
