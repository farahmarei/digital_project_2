`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 01:51:56 AM
// Design Name: 
// Module Name: seven_seg
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


module seven_seg(input clk, reset,input [3:0] dig0, dig1, dig2, dig3, output [6:0] segments, output  reg [3:0] anodes);
    wire clk_out ;
    wire [1:0] count;
    reg [3:0] num;
    always @(posedge clk_out or posedge reset) begin
        if(reset) begin
            num = 4'b0000;
        end
        else 
        case(count) 
        2'd0: begin
        anodes = 4'b1011; 
        num = dig0;
        end
        2'd1: begin
         anodes = 4'b0111;
         num = dig1;
         end
        2'd2: begin
         num = dig2;
         anodes = 4'b1110;
         end
        2'd3: begin
        num = dig3;
        anodes = 4'b1101;
        end
        endcase      
   end    
clock_divider #(250000) dut(.clk(clk) , .rst(reset) , .clk_out(clk_out));
binary_counter #(2 ,4 ) dut2(.clk(clk_out), .reset(reset), . en(1'b1), .count(count));
bcd dut3(.tog(count) , .num(num) , .segments(segments) , .anode_active());

   
endmodule
