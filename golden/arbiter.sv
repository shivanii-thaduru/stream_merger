`timescale 1ns/1ps
module arbiter (
    input  logic clk,
    input  logic rst_n,
    
    input  logic req0,
    input  logic req1,
    
    output logic gnt0,
    output logic gnt1
);
logic last;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        last <= 0;
    else if (req0 && req1 && (gnt0 || gnt1))
        last <= gnt1;
end
assign gnt0 = req0 && (!req1 || last);
assign gnt1 = req1 && (!req0 || !last);
endmodule




