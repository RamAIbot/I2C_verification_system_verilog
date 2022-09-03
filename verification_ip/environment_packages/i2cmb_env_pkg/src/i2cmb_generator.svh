// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(abc_transaction_base));
class i2cmb_generator extends ncsu_component#(.T(wb_transaction_base));

  wb_transaction_base wb_transaction;
  i2c_transaction_base i2c_transaction;

  ncsu_component #(wb_transaction_base) wb_agent;
  ncsu_component #(i2c_transaction_base) i2c_agent;
  string trans_name_wb,trans_name_i2c;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    wb_transaction = new("wb_transaction");
    i2c_transaction = new("i2c_transaction");
    // if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name_wb)) begin
    //   $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
    //   $fatal;
    // end
    // $display("%m found +GEN_TRANS_TYPE=%s", trans_name_wb);

    // if ( !$value$plusargs("I2C_GEN_TRANS_TYPE=%s", trans_name_i2c)) begin
    //   $display("FATAL: +I2C_GEN_TRANS_TYPE plusarg not found on command line");
    //   $fatal;
    // end
    // $display("%m found +I2C_GEN_TRANS_TYPE=%s", trans_name_i2c);


  endfunction

  virtual task run();
    
    // //foreach (wb_transaction[i]) begin  
    // $cast(wb_transaction,ncsu_object_factory::create(trans_name_wb));
    // //assert (wb_transaction.randomize());
    // wb_agent.bl_put(wb_transaction);
    // $display({get_full_name()," ",wb_transaction.convert2string()});
    // //end

    //  //foreach (i2c_transaction[i]) begin  
    // $cast(i2c_transaction,ncsu_object_factory::create(trans_name_i2c));
    // //assert (i2c_transaction.randomize());
    // i2c_agent.bl_put(i2c_transaction);
    // $display({get_full_name()," ",i2c_transaction.convert2string()});
    // //end
    fork
      //$display("Generating I2C Objects");
      i2c_agent.bl_put(i2c_transaction);
    join_none

    enabling_the_core();
    set_bus();
    start_command();
    setting_write_address();
    writing_data();
    setting_read_address();
    reading_data();
    alternative_read_and_write();
    stop_command();

    #100000000 $finish;
  endtask

  function void set_agent0(ncsu_component #(wb_transaction_base) agent);
    this.wb_agent = agent;
  endfunction

  function void set_agent1(ncsu_component #(i2c_transaction_base) agent);
    this.i2c_agent = agent;
  endfunction

  task enabling_the_core;
    //Write byte “1xxxxxxx” to the CSR register. This sets bit E to '1', enabling the core.
	//Write byte “x1xxxxxx” to the CSR register. This sets bit IE to '1', enabling the interrupt.
	//wb_bus.master_write(.addr(2'b00),.data(8'b11xxxxxx));
    wb_transaction.addr = 2'b00;
    wb_transaction.data = 8'b11xxxxxx;
    wb_transaction.check_for_irq = 1'b0; //Writing
    wb_agent.bl_put(wb_transaction);		
  endtask

  task set_bus;
    //Write byte 0x05 to the DPR. This is the ID of desired I2C bus.
	//wb_bus.master_write(.addr(2'b01),.data(8'h05));
    wb_transaction.addr = 2'b01;
    wb_transaction.data = 8'h05;
    wb_transaction.check_for_irq = 1'b0; //Writing
    wb_agent.bl_put(wb_transaction);


	//Write byte “xxxxx110” to the CMDR. This is Set Bus command.
	//wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx110));
    wb_transaction.addr = 2'b10;
    wb_transaction.data = 8'bxxxxx110;
    wb_transaction.check_for_irq = 1'b0; //Writing
    wb_agent.bl_put(wb_transaction);


	//Wait for interrupt or until DON bit of CMDR reads '1'.
	//wait(irq == 1'b1);
	//Reading CMDR register to clear the interrupt
	//wb_bus.master_read(.addr(2'b10),.data(data));
    wb_transaction.addr = 2'b10;
    wb_transaction.check_for_irq = 1'b1; //Reading
    wb_agent.bl_put(wb_transaction);
  endtask

  task start_command;
    //Write byte “xxxxx100” to the CMDR. This is Start command.
	//wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx100));
    wb_transaction.addr = 2'b10;
    wb_transaction.data = 8'bxxxxx100;
    wb_transaction.check_for_irq = 1'b0; //Writing
    wb_agent.bl_put(wb_transaction);

	//Wait for interrupt or until DON bit of CMDR reads '1'.
	//wait(irq == 1'b1);
	//Reading CMDR register to clear the interrupt
	//wb_bus.master_read(.addr(2'b10),.data(data));
    wb_transaction.addr = 2'b10;
    wb_transaction.check_for_irq = 1'b1; //Reading
    wb_agent.bl_put(wb_transaction);
  endtask

  task setting_write_address;
    //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
    //wb_bus.master_write(.addr(2'b01),.data(8'h44));
    wb_transaction.addr = 2'b01;
    wb_transaction.data = 8'h44;
    wb_transaction.check_for_irq = 1'b0; //Writing
    wb_agent.bl_put(wb_transaction);

    //Write byte “xxxxx001” to the CMDR. This is Write command.
    //wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx001));
    wb_transaction.addr = 2'b10;
    wb_transaction.data = 8'bxxxxx001;
    wb_transaction.check_for_irq = 1'b0; //Writing
    wb_agent.bl_put(wb_transaction);


    //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bitis '1', then slave doesn't respond.
    //wait(irq == 1'b1);
    //Reading CMDR register to clear the interrupt
    //wb_bus.master_read(.addr(2'b10),.data(data));
    wb_transaction.addr = 2'b10;
    wb_transaction.check_for_irq = 1'b1; //Reading
    wb_agent.bl_put(wb_transaction);

  endtask

  task writing_data;
    //Writing data
	for(int i=0;i<256;i=i+1) begin
		//Write byte i to the DPR. This is the byte to be written.
		//wb_bus.master_write(.addr(2'b01),.data(i));
        wb_transaction.addr = 2'b01;
        wb_transaction.data = i;
        wb_transaction.check_for_irq = 1'b0; //Writing
        wb_agent.bl_put(wb_transaction);

		//Write byte “xxxxx001” to the CMDR. This is Write command.
		//wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx001));
        wb_transaction.addr = 2'b10;
        wb_transaction.data = 8'bxxxxx001;
        wb_transaction.check_for_irq = 1'b0; //Writing
        wb_agent.bl_put(wb_transaction);

		//Wait for interrupt or until DON bit of CMDR reads '1'.
		//wait(irq == 1'b1);
		//Reading CMDR register to clear the interrupt
		//wb_bus.master_read(.addr(2'b10),.data(data));
        wb_transaction.addr = 2'b10;
        wb_transaction.check_for_irq = 1'b1; //Reading
        wb_agent.bl_put(wb_transaction);

	end

  endtask

  task setting_read_address;
    //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '1', which means reading.
    //wb_bus.master_write(.addr(2'b01),.data(8'h45));
    start_command();
    wb_transaction.addr = 2'b01;
    wb_transaction.data = 8'h45;
    wb_transaction.check_for_irq = 1'b0; //Writing
    wb_agent.bl_put(wb_transaction);


    //Write byte “xxxxx001” to the CMDR. This is Write command.
    //wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx001));
    wb_transaction.addr = 2'b10;
    wb_transaction.data = 8'bxxxxx001;
    wb_transaction.check_for_irq = 1'b0; //Writing
    wb_agent.bl_put(wb_transaction);


    //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bitis '1', then slave doesn't respond.
    //wait(irq == 1'b1);
    //Reading CMDR register to clear the interrupt
    //wb_bus.master_read(.addr(2'b10),.data(data));
    wb_transaction.addr = 2'b10;
    wb_transaction.check_for_irq = 1'b1; //Reading
    wb_agent.bl_put(wb_transaction);

  endtask


  task reading_data;
    //Reading data
	for(int i=0;i<31;i=i+1) begin
		//Write byte “xxxxx010” to the CMDR. This is Read with Ack command.
		//wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx010));
        wb_transaction.addr = 2'b10;
        wb_transaction.data = 8'bxxxxx010;
        wb_transaction.check_for_irq = 1'b0; //Writing
        wb_agent.bl_put(wb_transaction);

		//Wait for interrupt or until DON bit of CMDR reads '1'.
		//wait(irq == 1'b1);
		//Reading CMDR register to clear the interrupt
		//wb_bus.master_read(.addr(2'b10),.data(data));
        wb_transaction.addr = 2'b10;
        wb_transaction.check_for_irq = 1'b1; //Reading
        wb_agent.bl_put(wb_transaction);

        //Reading
        //wb_bus.master_read(.addr(8'h01),.data(data));
        wb_transaction.addr = 2'b01;
        wb_transaction.check_for_irq = 1'b1; //Writing
        wb_agent.bl_put(wb_transaction);
	end

  //Reading with Nak
  //wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx011));
    wb_transaction.addr = 2'b10;
    wb_transaction.data = 8'bxxxxx011;
    wb_transaction.check_for_irq = 1'b0; //Writing
    wb_agent.bl_put(wb_transaction);

  //wait(irq == 1);
  //Reading CMDR register to clear the interrupt
  //wb_bus.master_read(.addr(2'b10),.data(data));
    wb_transaction.addr = 2'b10;
    wb_transaction.check_for_irq = 1'b1; //Reading
    wb_agent.bl_put(wb_transaction);
  //Reading
    //wb_bus.master_read(.addr(8'h01),.data(data));
    wb_transaction.addr = 2'b01;
    wb_transaction.check_for_irq = 1'b1; //Writing
    wb_agent.bl_put(wb_transaction);

  endtask

  task alternative_read_and_write;
    //Alt read write
    int inc = 64;
    repeat(64) begin
        // //Write byte “xxxxx100” to the CMDR. This is Start command.
        // wb_bus.master_write(.addr(2'b10), .data(8'bxxxxx100));
        // wait(irq==1);
        // //Reading CMDR register to clear the interrupt
        // wb_bus.master_read(2'b10, data);

        // //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
        // wb_bus.master_write(2'b01, 8'h44);
        // //Write byte “xxxxx001” to the CMDR. This is Write command.
        // wb_bus.master_write(2'b10, 8'bxxxxx001);

        // wait(irq==1);
        // //Reading CMDR register to clear the interrupt
        // wb_bus.master_read(2'h02, data);
        // //data = inc;
        start_command();
        setting_write_address();

        //writing 
        //wb_bus.master_write(2'h01, inc);
        wb_transaction.addr = 2'h01;
        wb_transaction.data = inc;
        wb_transaction.check_for_irq = 1'b0; //Writing
        wb_agent.bl_put(wb_transaction);
        
        //Write byte “xxxxx001” to the CMDR. This is Write command.
        //wb_bus.master_write(2'h02, 8'h01);
        wb_transaction.addr = 2'h02;
        wb_transaction.data = 8'h01;
        wb_transaction.check_for_irq = 1'b0; //Writing
        wb_agent.bl_put(wb_transaction);

        //wait(irq==1);
        //Reading CMDR register to clear the interrupt
        //wb_bus.master_read(2'h02, data);
        wb_transaction.addr = 2'h02;
        wb_transaction.check_for_irq = 1'b1; //Reading
        wb_agent.bl_put(wb_transaction);



        // wb_bus.master_write(2'h02, 8'h04);

        // wait(irq==1);
        // wb_bus.master_read(2'h02, data);

        // wb_bus.master_write(2'h01, 8'h45);
        
        // wb_bus.master_write(2'h02, 8'h01);

        // wait(irq==1);
        // wb_bus.master_read(2'h02, data);
        //start_command();
        setting_read_address();

        //wb_bus.master_write(2'h02, 8'h03);
        wb_transaction.addr = 2'h02;
        wb_transaction.data = 8'h03;
        wb_transaction.check_for_irq = 1'b0; //Writing
        wb_agent.bl_put(wb_transaction);

        //wait(irq==1);
        //wb_bus.master_read(2'h02, data);
        wb_transaction.addr = 2'h02;
        wb_transaction.check_for_irq = 1'b1; //Reading
        wb_agent.bl_put(wb_transaction);


        //wb_bus.master_read(2'h01, data);
        wb_transaction.addr = 2'b01;
        wb_transaction.check_for_irq = 1'b1; //Reading
        wb_agent.bl_put(wb_transaction);

        inc = inc + 1;
    end
  endtask

  task stop_command;
    	//Write byte “xxxxx101” to the CMDR. This is Stop command.
        //wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx101));
        wb_transaction.addr = 2'b10;
        wb_transaction.data = 8'bxxxxx101;
        wb_transaction.check_for_irq = 1'b0; //Writing
        wb_agent.bl_put(wb_transaction);

        //Wait for interrupt or until DON bit of CMDR reads '1'.
        //wait(irq == 1'b1);
        //Reading CMDR register to clear the interrupt
        //wb_bus.master_read(.addr(2'b10),.data(data));
        wb_transaction.addr = 2'h10;
        wb_transaction.check_for_irq = 1'b1; //Reading
        wb_agent.bl_put(wb_transaction);
  endtask

endclass
