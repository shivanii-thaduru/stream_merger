module arbiter (
    input  logic clk,
    input  logic rst_n,

    input  logic req0,
    input  logic req1,

    output logic gnt0,
    output logic gnt1
);
logic sel;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        sel <= 0;
    else if (req0 && req1)
        sel <= 0; 
end

