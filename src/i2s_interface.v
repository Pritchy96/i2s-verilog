// Performs bitcrushing on an I2S signal, outputting it again as I2S. 
// Reduces the Sample Resolution by bit shifting left then back right again
// Reduces the Sample Rate by skipping n samples every SAMPLE_RATE_SUBDIVISIONS
// We probably want to tie SAMPLE_RATE_SUBDIVISIONS to the SAMPLE_RATE (defined by the ADC/DAC)

`define INPUT_BIT_DEPTH 24
`define SAMPLE_RATE 44100 //To be defined by the ADC
`define SAMPLE_RATE_POT_MAX 10000 //Maximum value that can be reported by the sample rate pot.
`define SAMPLE_RATE_SUBDIVISIONS 100 //How many different possible divisors for subdivsions do we want.

module i2s_interface(input wire         BCLK,   //Continuous Serial Clock
                     input wire         LRCLK,  //Word Select/LR Clock: 0 = left, 1 = right
                     input wire [31:00] SAMPLE_RATE_POT, //Sample Rate Pot Value.
                     input wire         SDATA,  //Serial Data
                     output reg         ODATA); //Out Data

    reg prev_lrclk; 
    reg [23:00] data;
    reg [23:00] prev_data, output_data;
    reg [07:00] bit_crushed_depth;
    reg [07:00] samples_to_skip;
    reg [07:00] sample_counter;

    initial begin
        data = 0;
        prev_data = 0;
        prev_lrclk = 0;
        bit_crushed_depth = 8;
        samples_to_skip = 0;
        sample_counter = 0;
    end

    always @(SAMPLE_RATE_POT) begin
        samples_to_skip = (SAMPLE_RATE_POT * `SAMPLE_RATE_POT_MAX) / `SAMPLE_RATE_SUBDIVISIONS; //Get value of pot between 1 and SAMPLE_RATE_SUBDIVISIONS.
    end

    always @(posedge BCLK) begin
        data <= (data << 1) + SDATA; //Read in new data.

        //Push out last data
        ODATA <= output_data[0];
        output_data <= output_data >> 1;

        //New word on next clock cycle
        if (prev_lrclk != LRCLK) begin  

            if (sample_counter >= `SAMPLE_RATE_SUBDIVISIONS) begin
                sample_counter = 0; //Reset sample counter.
            end

            //Time to process current word and set it to prev_data (if not a skipped sample for sample rate reduction!)
            if (sample_counter <= `SAMPLE_RATE_SUBDIVISIONS - samples_to_skip) begin 
                prev_data <= ((data >> (`INPUT_BIT_DEPTH - bit_crushed_depth)) << (`INPUT_BIT_DEPTH - bit_crushed_depth));
            end

            output_data <= prev_data; //Store the previous data so we can reuse it for sample rate reduction.

            data <= 24'd0;
            prev_lrclk <= LRCLK;

            if (LRCLK == 0) begin   //Only increment the sample count when we're on a left signal channel, we don't want to increment per channel, just per sample.
                sample_counter = sample_counter + 1;
            end
        end
    end

endmodule