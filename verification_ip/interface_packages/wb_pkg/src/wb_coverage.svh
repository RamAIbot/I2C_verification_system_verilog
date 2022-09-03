class wb_coverage extends ncsu_component#(.T(wb_transaction_base));

    wb_configuration configuration;

    bit[1:0] address_val_wb;
    logic[7:0] data_val_wb;
    bit we_bit_wb;

   int bus_id_to_use = 0;
   int bus_in_use = 0;
   bit[1:0] bus_id;
   bit[3:0] bus_id_data;
   bit bus_id_write;
  	
  covergroup wishbone_cg;
  	option.per_instance = 1;
    option.name = get_full_name();

  	address_val_wb: coverpoint address_val_wb
    {
        option.auto_bin_max = 4;
        //bins addr[] = {[3:0]};
    }

    coverpoint data_val_wb
    {
        //  bins csr_bin[] = {[$:64],[15:0]} iff(address_val_wb == 2'h0);
        //  bins dpr_bin[] = {[$:0]} iff(address_val_wb == 2'h1);
        //  bins cmdr_bin[] = {[7:0]} iff(address_val_wb == 2'h2);
        option.auto_bin_max = 256;
    }

    coverpoint we_bit_wb
    {
        bins writing = {1}; //1 writing
        bins reading = {0};
    }   
  endgroup

  covergroup multiple_bus_test_cg;
    option.per_instance = 1;
    option.name = get_full_name();

    coverpoint bus_id
    {
      // bins index_0 = {0};
      // bins index_1 = {1};
      // bins index_2 = {2};
      // bins index_3 = {3};
      // bins index_4 = {4};
      // bins index_5 = {5};
      // bins index_6 = {6};
      // bins index_7 = {7};
      // bins index_8 = {8};
      // bins index_9 = {9};
      // bins index_10 = {10};
      // bins index_11 = {11};
      // bins index_12 = {12};
      // bins index_13 = {13};
      // bins index_14 = {14};
      // bins index_15 = {15};
      //option.auto_bin_max = 16;
      //ignore_bins invalid = {[16:$]};
      bins addr_transitions = (2'b01 => 2'b10); //DPR to CMDR
      
    }

    coverpoint bus_id_data
    {
      bins data_transitions = (8'h0,8'h1,8'h2,8'h3,8'h4,8'h5,8'h6,8'h7,8'h8,8'h9,8'd10,8'd11,8'd12,8'd13,8'd14,8'd15 => 8'bxxxxx110);
      
    }

    coverpoint bus_id_write
    {
      bins write_enable = (1'b1 => 1'b1);
    }

    cross bus_id,bus_id_data,bus_id_write;

  endgroup

  function new(string name = "", ncsu_component #(T) parent = null); 
    super.new(name,parent);
    wishbone_cg = new;
    multiple_bus_test_cg = new;
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void nb_put(T trans);
    $display("wb_coverage::nb_put() %s called",get_full_name());

    single_bus_active:assert(!(bus_in_use && trans.addr==2'b10 && trans.data === 8'b00000110)) else $fatal;

    if(trans.addr == 2'b10 && trans.data === 8'b00000110 && trans.check_for_irq == 1'b0)
      bus_in_use = 1;
    
    if(trans.addr == 2'b10 && trans.data === 8'b00000101 && trans.check_for_irq == 1'b0) //Stop
      bus_in_use = 0;


    // if(trans.addr == 2'b01 && trans.check_for_irq == 1'b0) begin
    //   $display("BUS ID DPR");
    //   bus_id_to_use = trans.data;
    // end

    address_val_wb = trans.addr;
    data_val_wb = trans.data;
    we_bit_wb = trans.we;
    wishbone_cg.sample();

    // if(trans.addr == 2'b10 && trans.data === 8'b00000110 && trans.check_for_irq == 1'b0) begin
    //   $display("ID SAMPLE");
    //   bus_id = bus_id_to_use;
    //   multiple_bus_test_cg.sample();
    // end
    bus_id = trans.addr;
    bus_id_data = trans.data;
    bus_id_write = trans.we;
    multiple_bus_test_cg.sample();
  endfunction

endclass
