// Test for the I2S interface.
//
// Created by Tom Pritchard, August 2019

module i2s_interface_tb ();

integer file_handle;

reg clk;
reg lr_select;
reg data;
integer lr_counter;
integer sample_rate_pot;

i2s_interface interface (.BCLK(clk),   //Continuous Serial Clock
                         .LRCLK(lr_select),  //Word Select/LR Clock: 0 = left, 1 = right
                         .SDATA(data),
                         .SAMPLE_RATE_POT(sample_rate_pot)); //Serial Data



initial begin
    file_handle = $fopen("sobel_module_tb_out.log"); // Open a message output file
    $fdisplay(file_handle, "Outcome from Sobel Module tests\n"); // Output title
  
    clk = 0;
    data = 0;
    lr_select = 0;
    lr_counter = 0;
    #200 
    sample_rate_pot = 2000;

    $display(file_handle, "Set up input signals.");
end


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Set up clock input																						              */
always #1
    begin
    clk = ~clk;
end

always @(posedge clk) begin
    // data <= 1;
    data <= $urandom;
    lr_counter <= lr_counter + 1;

    if (lr_counter == 24) begin
        lr_select <= !lr_select;
        lr_counter <= 0;
    end
end


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Standard timeout, stopping runaway execution.                              */
initial begin
  #100000
  $fclose(file_handle);
  $stop;
end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* //Dump a vcd file for GTKWave.                                             */
initial begin
  $dumpfile ("i2s_interface_tb.vcd");
  $dumpvars(0, i2s_interface_tb);
end

endmodule