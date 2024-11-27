`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 01:11:10 PM
// Design Name: 
// Module Name: X_bit_counter
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


module X_bit_counter #(parameter x = 3, n = 6) 
 (input clk, reset, output [x-1:0] count); 
 reg [x-1:0] count; 
 always @(posedge clk, posedge reset) 
 begin 
 if (reset == 1) 
 count <= 0;
  else if (count == n-1) 
  count <= 0; 
   else count <= count + 1;
   end
 endmodule

