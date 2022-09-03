`timescale 1ns / 10ps

interface i2c_if #(
    int ADDR_WIDTH = 7,                                
    int DATA_WIDTH = 8)
(
    inout triand scl,
    inout triand sda  //Important as if one of the drivers is 0, the result will also be 0
);
typedef bit i2c_opt_t;
bit start_bit,stop_bit;
bit[ADDR_WIDTH-1:0] address;
bit[DATA_WIDTH-1:0] monitor_array[];
i2c_opt_t operation;
int size_of_data_array;
int size_of_monitor_array;
bit sda_line_released=1'b0;
bit sda_temp;

int counter;
bit[3:0] condition_to_ack;

//Checking for start condition
always @(negedge sda) begin
    if(scl == 1'b1) begin
        start_bit <= 1'b1;
        //stop_bit <= 1'b0;
        counter = 0;
    end
end

//Checking for stop condition
always @(posedge sda) begin
    if(scl == 1'b1) begin
        stop_bit <= 1'b1;
        //start_bit <= 1'b0;
    end

end

always @(posedge scl) begin
    counter++;
end

assign sda = (sda_line_released) ? sda_temp : 1'bz;

assign condition_to_ack = (counter) % 9;


property i2c_ack_check;
	@(posedge scl) (condition_to_ack<8 && operation==1'b0) |-> (!sda_line_released); 
endproperty 
	
assert property(i2c_ack_check) else $fatal;
 

task wait_for_i2c_transfer(output i2c_opt_t op, output bit[DATA_WIDTH-1:0] write_data[]);

    bit[ADDR_WIDTH-1:0] address_recv;
    bit[DATA_WIDTH-1:0] data_recv;
    automatic int loop_index;
    op = 1'b0;
    //$display("Wait for I2C transfer");
    
    wait(start_bit);
    #1ns
    start_bit = 1'b0;
    stop_bit = 1'b0;
    //$display("start bit obtained");
    repeat(7) begin
        //Getting address
        @(posedge scl);
        address_recv = {address_recv,sda};
    end

    //address_recv = (address_recv >> 1);

    address = address_recv;
    //Getting operation
    @(posedge scl);
    op = sda;

    operation = op;
    
    @(negedge scl);
    //Sending ACK
    sda_line_released = 1'b1;
    sda_temp = 1'b0;

    if(op == 1'b1) begin
        //Read
        return;
    end

    @(negedge scl);
    //Return control to master
    sda_line_released = 1'b0;

    //Write

    fork 
        //Parallel process 1
        begin
        //Capturing data
            while(1) begin
                repeat(8) begin
                    @(posedge scl);
                        data_recv = {data_recv,sda};
                end

                size_of_data_array = write_data.size();
                write_data = new[size_of_data_array+1](write_data);
                write_data[size_of_data_array] = data_recv;

                size_of_monitor_array = monitor_array.size();
                monitor_array = new[size_of_monitor_array+1](monitor_array);
                monitor_array[size_of_monitor_array] = data_recv;
                

                //Sending ACK
                @(negedge scl);
                sda_line_released = 1'b1;
                sda_temp = 1'b0;

                //Return control to master
                @(negedge scl);
                sda_line_released = 1'b0;
            end
        end

        //Parallel process 2
        begin
            //Repeated start bit
            wait(start_bit == 1'b1);
            //$display("Another start bit");
        end

        //Parallel process 3
        begin
            //Stop bit
            wait(stop_bit == 1'b1);
            //$display("Stop bit");
        end
    join_any

    disable fork;

endtask

task provide_read_data(input bit[DATA_WIDTH-1:0]read_data[], output bit transfer_complete);

    bit[DATA_WIDTH-1:0] read_data_queue[$],read_data_temp;
    read_data_queue = read_data;
    //monitor_array.delete();

    transfer_complete = 1'b0;
    while(read_data_queue.size() != 0) begin
        //Providing read data
        read_data_temp = read_data_queue.pop_front();
        sda_line_released = 1'b1;
        for(int i=0;i<8;i++)begin
            @(negedge scl);
            sda_temp = read_data_temp[7-i]; //Sending from MSB;
        end

        size_of_monitor_array = monitor_array.size();
        monitor_array = new[size_of_monitor_array+1](monitor_array);
        monitor_array[size_of_monitor_array] = read_data_temp;

        //Releasing control to master
        @(negedge scl);
        sda_line_released = 1'b0;

        //Reciving ACK from master
        @(posedge scl);
        if(sda == 1'b0) begin
            transfer_complete = 1'b0;
        end
        else begin
            transfer_complete = 1'b1;
        end


    end

    

endtask


task monitor(output bit[DATA_WIDTH-1:0] addr, output i2c_opt_t op, output bit[DATA_WIDTH-1:0] data[]);
    //$display("In MONITOR");
    wait(start_bit);
    //$display("Start condition");
    wait(!start_bit);
    //$display("Started and data transmission");
    //repeated start or stop
    wait(start_bit || stop_bit);
    //$display("Repeated start or stop");
    addr = address;
    op = operation;
    data = monitor_array;
    //$display("Address from I2C_IF:%x",addr);
    //$display("DATA from I2C_IF:%x",data);
    monitor_array.delete();
    
    
endtask

endinterface