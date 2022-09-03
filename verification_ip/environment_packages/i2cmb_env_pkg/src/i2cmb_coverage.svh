class i2cmb_coverage extends ncsu_component#(.T(wb_transaction_base));

    i2cmb_env_configuration configuration;

    bit [3:0] fsm_state_values;
    bit [3:0] fsm_transitions;
    bit[2:0] prev;
    bit check;
    int done = 7,nak = 6,al = 5,error = 4;

  covergroup fsmr_state_transition_cg;
    option.per_instance = 1;
    option.name = get_full_name();
    coverpoint fsm_state_values
    {
      // bins idle = {0};
      // bins start = {3};
      // bins bus_taken = {1};
      // bins write = {5};
      // bins read = {6};
      // bins stop = {4};
      // illegal_bins other = default;

      bins idle          = {0};
      bins bus_taken     = {1};
      //bins start_pending  = {2};
      bins start          = {3};
      bins stop           = {4};
      bins write          = {5};
      bins read           = {6};
      //bins waiter          = {7};
      illegal_bins other = default;
    }

    coverpoint fsm_transitions
    {
      bins cover_ = (0,1,2,3,4,5,6,7 => 0,1,2,3,4,5,6,7);
      // bins idle_to_start = (0=>3);
      // bins start_to_bus_taken = (3=>1);
      // bins bus_taken_to_write = (1=>5);
      // bins write_to_bus_taken = (5=>1);
      // bins bus_taken_to_read = (1=>6);
      // bins read_to_bus_taken = (6=>1);
      // bins bus_taken_to_stop = (1=>4);
      illegal_bins start_to_stop = (3=>1=>4);
      illegal_bins self_idle[] = (0=>5,6=>0);

    }
  endgroup

  function new(string name = "", ncsu_component #(i2c_transaction_base) parent = null);  //This should be i2c transaction and not wb
    super.new(name,parent);
    fsmr_state_transition_cg = new;
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void nb_put(T trans);
    $display("i2cmb_coverage::nb_put() %s called",get_full_name());
    $display({get_full_name()," ",trans.convert2string()});
    fsm_transitions = trans.data[7:4];
    fsm_state_values = trans.data[7:4];
    if(trans.addr == 2'b11) begin 
      $display("FSM coverage");
      fsmr_state_transition_cg.sample();
    end

    if(trans.addr == 2'b10 && trans.data[2:0] != prev && trans.we == 1'b1) begin
      case(trans.data[2:0])
        3'b000: begin
          prev = trans.data[2:0]; $display("Wait");
        end

        3'b001: begin
          prev = trans.data[2:0]; $display("Write");
        end

        3'b010: begin
          prev = trans.data[2:0]; $display("Read with Ack");
        end

        3'b011: begin
          prev = trans.data[2:0]; $display("Read with Nack");
        end

        3'b100: begin
          prev = trans.data[2:0]; $display("Start");
        end

        3'b101: begin
          prev = trans.data[2:0]; $display("Stop");
        end

        3'b110: begin
          prev = trans.data[2:0]; $display("Bus ID");
        end

      endcase
    end

    if(trans.addr == 2'b10 && trans.we == 1'b0) begin //Reading from CMDR
      case(prev)
        0: begin
          check = ((trans.data[done] == 1 || trans.data[error] == 1) && (trans.data[nak] == 0 && trans.data[al] == 0)); //Wait
        end

        1: begin
          check = ((trans.data[done] == 1 || trans.data[error] == 1) || (trans.data[nak] == 1 || trans.data[al] == 1)); //Write
        end

        4: begin
          check = ((trans.data[done] == 1) || (trans.data[al] == 1) && (trans.data[nak] == 0 && trans.data[error] == 0)); //Start
        end

        5: begin
          check = ((trans.data[done] == 1) && (trans.data[error] == 0) && (trans.data[nak] == 0 && trans.data[al] == 0)); //Stop
        end

        6: begin
          check = ((trans.data[done] == 1) || (trans.data[error] == 1) && (trans.data[nak] == 0 && trans.data[al] == 0)); //BusID
        end
      endcase
      CMDR_responses: assert(check == 1) else $fatal;
    end

  endfunction

endclass
