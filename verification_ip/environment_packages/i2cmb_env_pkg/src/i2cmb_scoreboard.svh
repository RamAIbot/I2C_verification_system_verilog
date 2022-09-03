class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction_base));
  T trans_in;
  T trans_out;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    trans_in = new("Trans_In");
    trans_out = new("Trans_Out");
  endfunction

  virtual function void nb_transport(input T input_trans, output T output_trans);
    //$display({get_full_name()," nb_transport: expected transaction ",input_trans.convert2string()}); //Causes BAD HANDLE Error
    //$display("Got from NB_Transport");
    this.trans_in = input_trans;
    output_trans = trans_out;
    //$display("NB_Transport %x",this.trans_in.data.size());
  endfunction

  virtual function void nb_put(T trans);
    //$display("SB_Nb_put");
    $display({get_full_name()," From nb_put: Actual transaction ",trans.convert2string()});
    $display({get_full_name()," From nb_transport: Expected transaction ",trans_in.convert2string()});
    if ( this.trans_in.compare(trans) ) begin $display({get_full_name()," WB & I2C transaction MATCH!"}); end
    else                                $display({get_full_name()," WB & I2C transaction MISMATCH!"});
  endfunction
endclass


