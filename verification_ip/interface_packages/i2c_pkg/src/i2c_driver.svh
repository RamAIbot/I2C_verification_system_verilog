class i2c_driver extends ncsu_component#(.T(i2c_transaction_base));

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  virtual i2c_if bus;
  i2c_configuration configuration;
  i2c_transaction_base i2c_trans;

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
  //This is called only when generator gets called so add run function. Put forever and these in that. Here put i2c_trans = trans and call this run from agent.
    i2c_trans = trans;
  endtask

  virtual task run();
    //$display("DRIVER RUN");
    forever begin
      //$display({get_full_name()," ",i2c_trans.convert2string()});
      bus.wait_for_i2c_transfer(i2c_trans.op,i2c_trans.data);
      if(i2c_trans.op == 1'b1) begin
        //$display("Read data from top.sv");
        if(i2c_trans.alt_read_write) begin
          //Alternative read write
          i2c_trans.read_data = new[1];
          i2c_trans.read_data[0] = 255-i2c_trans.x;
          bus.provide_read_data(i2c_trans.read_data,i2c_trans.transfer_complete);
          i2c_trans.read_data.delete();
          i2c_trans.x = i2c_trans.x + 1;
        end
        else begin
          i2c_trans.read_data = new[32];
          for(int i=0;i<32;i++) begin
            i2c_trans.read_data[i] = 100 + i;
          end

          bus.provide_read_data(i2c_trans.read_data,i2c_trans.transfer_complete);
          i2c_trans.alt_read_write = 1'b1;
          i2c_trans.read_data.delete();
        end
      end
      else begin
        //$display("Write data from top.sv");
      end
    end
  endtask

endclass
