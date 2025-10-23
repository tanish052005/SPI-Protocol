module spi_state(
    input  wire clk,        // System clock
    input  wire reset,      // Asynchronous system reset
    input  wire [15:0] datain, // Binary input vector
    output wire spi_cs_1,   // SPI Active-low chip select
    output wire spi_sclk,   // SPI bus clock
    output wire spi_data,   // SPI bus data
    output wire [4:0] counter
);

reg [15:0] MOSI;  // SPI shift register
reg [4:0] count;  // Control counter
reg cs_1;         // SPI chip select (active-low)
reg sclk;         // SPI clock
reg [1:0] state;  // FSM state: 0-IDLE,1-SHIFT,2-CLOCK

always @(posedge clk or posedge reset) begin
    if (reset) begin
        MOSI  <= 16'b0;
        count <= 5'd16;
        cs_1  <= 1'b1;
        sclk  <= 1'b0;
        state <= 0;
    end else begin
        case (state)
            0: begin // IDLE
                cs_1  <= 1'b1;
                sclk  <= 1'b0;
                count <= 5'd16;
                MOSI  <= datain;
                state <= 1;
            end
            1: begin // SHIFT DATA
                cs_1 <= 1'b0;        // Activate chip select
                sclk <= 1'b0;        // Prepare clock low
                state <= 2;
            end
            2: begin // CLOCK HIGH & SHIFT
                sclk <= 1'b1;
                MOSI <= {MOSI[14:0], 1'b0}; // Shift left
                count <= count - 1;
                if (count == 1) begin
                    state <= 0; // Done, go IDLE
                end else begin
                    state <= 1; // Continue
                end
            end
        endcase
    end
end

assign spi_cs_1 = cs_1;
assign spi_sclk = sclk;
assign spi_data = MOSI[15]; // MSB first
assign counter  = count;

endmodule



module tb_spi_state;

// Inputs
reg clk;
reg reset;
reg [15:0] datain;

// Outputs
wire spi_cs_1;
wire spi_sclk;
wire spi_data;
wire [4:0] counter;

// Instantiate the Unit Under Test (UUT)
spi_state dut (
    .clk(clk),
    .reset(reset),
    .datain(datain),
    .spi_cs_1(spi_cs_1),
    .spi_sclk(spi_sclk),
    .spi_data(spi_data),
    .counter(counter)
);

// Clock generation
always #5 clk = ~clk; // 100 MHz clock

initial begin
    // Initialize Inputs
    clk = 0;
    reset = 1;
    datain = 16'h0000;

    // Release reset after 10 ns
    #10 reset = 0;

    // Apply test vectors
    #10 datain = 16'hA569;
    #330 datain = 16'h2563;
    #330 datain = 16'h9B63;
    #330 datain = 16'h6A61;
    #330 datain = 16'hA265;
    #330 datain = 16'h7564;

    // Finish simulation
    #1000 $finish;
end

endmodule
