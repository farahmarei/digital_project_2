`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 12:33:41 PM
// Design Name: 
// Module Name: clk_divider
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

module clk_divider #(parameter n = 4) 
(input clk, rst, output reg clk_out);
    wire [31:0] count;

    X_bit_counter #(32, n) counterMod(
        .clk(clk),
        .reset(rst),
        .count(count)
    );

    always @ (posedge clk, posedge rst) begin
        if (rst)
            clk_out <= 0;
        else if (count == n - 1)
            clk_out <= ~clk_out;
    end
endmodule

