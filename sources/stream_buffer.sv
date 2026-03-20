module stream_buffer (
    input  logic clk,
    input  logic rst_n,

    input  logic [7:0] in_data,
    input  logic       in_valid,
    output logic       in_ready,

    output logic [7:0] out_data,
    output logic       out_valid,
    input  logic       out_ready
);

logic full;
logic [7:0] data_q;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        full <= 0;
    end else begin
        if (in_valid) begin 
            data_q <= in_data;
            full <= 1;
        end else if (out_ready) begin
            full <= 0;
        end
    end
end

assign in_ready  = !full;
assign out_valid = full;
assign out_data = data_q;

endmodule
