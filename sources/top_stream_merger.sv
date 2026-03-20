module top_stream_merger (
    input  logic clk,
    input  logic rst_n,

    input  logic [7:0] in0_data,
    input  logic       in0_valid,
    output logic       in0_ready,

    input  logic [7:0] in1_data,
    input  logic       in1_valid,
    output logic       in1_ready,

    output logic [7:0] out_data,
    output logic       out_valid,
    input  logic       out_ready
);

logic [7:0] buf0_data, buf1_data;
logic buf0_valid, buf1_valid;
logic buf0_ready, buf1_ready;

logic gnt0, gnt1;

stream_buffer u_buf0 (.*);
stream_buffer u_buf1 (.*);

arbiter u_arb (
    .clk(clk),
    .rst_n(rst_n),
    .req0(buf0_valid),
    .req1(buf1_valid),
    .gnt0(gnt0),
    .gnt1(gnt1)
);

assign out_valid = (gnt0 && buf0_valid) || (gnt1 && buf1_valid);
assign out_data  = gnt0 ? buf0_data : buf1_data;

assign buf0_ready = gnt0;
assign buf1_ready = gnt1;

endmodule
