`timescale 1ns / 10ps
//`include "wb_if.sv"

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;

parameter int I2C_DATA_WIDTH = 8;
parameter int I2C_ADDR_WIDTH = 7;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
tri  [NUM_I2C_BUSSES-1:0] sda;

// Variables task

logic  [WB_ADDR_WIDTH-1:0] addr;
logic  [WB_DATA_WIDTH-1:0] data;
logic  we_temp;

//typedef bit i2c_op_t;

// ****************************************************************************
// Clock generator
initial begin : clk_gen
  clk = 0;
  forever begin
      
    #10ns clk = ~clk;
  end
 
end

// ****************************************************************************
// Reset generator

initial begin
 
  #113ns rst = 1'b0;
end


// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript

initial begin
  bit [I2C_ADDR_WIDTH-1:0] address;
  bit [I2C_DATA_WIDTH-1:0] data[];
  bit operation;
  forever begin
    i2c_bus.monitor(address,operation,data);
    //$display("Time %0t, Address %0h",$time,address); 
    if(data.size()) begin
      if(operation == 1'b1)
        $display("I2C Bus Read");

      else
        $display("I2C Bus Write");

      for(int i=0;i<data.size();i=i+1) 
        $display(" %d",data[i]);
    end
    
  end 

end


// ****************************************************************************
// Define the flow of the simulation
initial begin
	int inc;
	//Writing data from 0 to 31
	#150
	//Write byte “1xxxxxxx” to the CSR register. This sets bit E to '1', enabling the core.
	//Write byte “x1xxxxxx” to the CSR register. This sets bit IE to '1', enabling the interrupt.
	wb_bus.master_write(.addr(2'b00),.data(8'b11xxxxxx));
		
		
	//Write byte 0x05 to the DPR. This is the ID of desired I2C bus.
	wb_bus.master_write(.addr(2'b01),.data(8'h05));
	//Write byte “xxxxx110” to the CMDR. This is Set Bus command.
	wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx110));
	//Wait for interrupt or until DON bit of CMDR reads '1'.
	wait(irq == 1'b1);
	//Reading CMDR register to clear the interrupt
	wb_bus.master_read(.addr(2'b10),.data(data));
	
	
		
	//Write byte “xxxxx100” to the CMDR. This is Start command.
	wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx100));
	//Wait for interrupt or until DON bit of CMDR reads '1'.
	wait(irq == 1'b1);
	//Reading CMDR register to clear the interrupt
	wb_bus.master_read(.addr(2'b10),.data(data));
	
	
	
	//Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
    wb_bus.master_write(.addr(2'b01),.data(8'h44));
    //Write byte “xxxxx001” to the CMDR. This is Write command.
    wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx001));
    //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bitis '1', then slave doesn't respond.
    wait(irq == 1'b1);
    //Reading CMDR register to clear the interrupt
    wb_bus.master_read(.addr(2'b10),.data(data));
  
  
	//Writing data
	for(int i=0;i<32;i=i+1) begin
		//Write byte i to the DPR. This is the byte to be written.
		wb_bus.master_write(.addr(2'b01),.data(i));
		//Write byte “xxxxx001” to the CMDR. This is Write command.
		wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx001));
		//Wait for interrupt or until DON bit of CMDR reads '1'.
		wait(irq == 1'b1);
		//Reading CMDR register to clear the interrupt
		wb_bus.master_read(.addr(2'b10),.data(data));
	end
	

  //*********************************Reading data**************************************
  //Write byte “xxxxx100” to the CMDR. This is Start command.
	wb_bus.master_write(.addr(8'b10),.data(8'bxxxxx100));
	//Wait for interrupt or until DON bit of CMDR reads '1'.
	wait(irq == 1'b1);
	//Reading CMDR register to clear the interrupt
	wb_bus.master_read(.addr(8'b10),.data(data));



  //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '1', which means reading.
  wb_bus.master_write(.addr(2'b01),.data(8'h45));
  //Write byte “xxxxx001” to the CMDR. This is Write command.
  wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx001));
  //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bitis '1', then slave doesn't respond.
  wait(irq == 1'b1);
  //Reading CMDR register to clear the interrupt
  wb_bus.master_read(.addr(2'b10),.data(data));


  //Reading data
	for(int i=0;i<31;i=i+1) begin
		//Write byte “xxxxx010” to the CMDR. This is Read with Ack command.
		wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx010));
		//Wait for interrupt or until DON bit of CMDR reads '1'.
		wait(irq == 1'b1);
		//Reading CMDR register to clear the interrupt
		wb_bus.master_read(.addr(2'b10),.data(data));
    //Reading
    wb_bus.master_read(.addr(8'h01),.data(data));
	end

  //Reading with Nak
  wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx011));
  wait(irq == 1);
  //Reading CMDR register to clear the interrupt
  wb_bus.master_read(.addr(2'b10),.data(data));
  //Reading
  wb_bus.master_read(.addr(8'h01),.data(data));
  

  //Alt read write
  inc = 64;
  repeat(64) begin
    //Write byte “xxxxx100” to the CMDR. This is Start command.
    wb_bus.master_write(.addr(2'b10), .data(8'bxxxxx100));
    wait(irq==1);
    //Reading CMDR register to clear the interrupt
    wb_bus.master_read(2'b10, data);

    //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
    wb_bus.master_write(2'b01, 8'h44);
    //Write byte “xxxxx001” to the CMDR. This is Write command.
    wb_bus.master_write(2'b10, 8'bxxxxx001);

    wait(irq==1);
    //Reading CMDR register to clear the interrupt
    wb_bus.master_read(2'h02, data);
    //data = inc;

    //writing 
    wb_bus.master_write(2'h01, inc);
    //Write byte “xxxxx001” to the CMDR. This is Write command.
    wb_bus.master_write(2'h02, 8'h01);

    wait(irq==1);
    //Reading CMDR register to clear the interrupt
    wb_bus.master_read(2'h02, data);



    wb_bus.master_write(2'h02, 8'h04);

    wait(irq==1);
    wb_bus.master_read(2'h02, data);

    wb_bus.master_write(2'h01, 8'h45);
    
    wb_bus.master_write(2'h02, 8'h01);

    wait(irq==1);
    wb_bus.master_read(2'h02, data);

    wb_bus.master_write(2'h02, 8'h03);

    wait(irq==1);
    wb_bus.master_read(2'h02, data);

    wb_bus.master_read(2'h01, data);

    inc = inc + 1;
  end

	
	//Write byte “xxxxx101” to the CMDR. This is Stop command.
  wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx101));
  //Wait for interrupt or until DON bit of CMDR reads '1'.
  wait(irq == 1'b1);
  //Reading CMDR register to clear the interrupt
  wb_bus.master_read(.addr(2'b10),.data(data));
	
	$finish();

end

//Wait for I2C Task
initial begin
	//#150
  bit op;
  bit [I2C_DATA_WIDTH-1:0] write_data[];
  bit [I2C_DATA_WIDTH-1:0] read_data[];
	while(1) begin
		i2c_bus.wait_for_i2c_transfer(op,write_data);
    if(op == 1'b1) begin
      //$display("Read data task");
      break;
    end
	end

  read_data = new[1];
  read_data[0] = 100;

  while(1) begin
    i2c_bus.provide_read_data(read_data,op);
    if(op == 1'b1)
      break;

    read_data[0] = read_data[0] + 1;
  end

  for(int i=0; i <64; i++ ) begin
    while(1) begin
      i2c_bus.wait_for_i2c_transfer(op, write_data);
      if(op==1'b1) begin
        break;
      end
    end
    read_data[0] = 63-i;
    i2c_bus.provide_read_data(read_data,op);
  end

  $finish();
	
end

i2c_if #(
    .ADDR_WIDTH(I2C_ADDR_WIDTH),
    .DATA_WIDTH(I2C_DATA_WIDTH))
i2c_bus(
    .scl(scl),
    .sda(sda)
);


// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );


endmodule
