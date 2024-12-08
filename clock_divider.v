`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 12:05:34 AM
// Design Name: 
// Module Name: clock_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module clock_divider #(parameter n = 50000000)
(input clk, rst, output reg clk_out);
wire [31:0] count;

binary_counter #(32,n) counterMod(.clk(clk), .reset(rst), .count(count),.en(1'b1));

always @ (posedge clk, posedge rst) begin
if (rst) 
    clk_out <= 0;
        else if (count == n-1)
            clk_out <= ~ clk_out;
end
endmodule

