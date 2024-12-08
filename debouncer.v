`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 03:20:33 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer(input clock, button_in, output button_out);
    reg sync1, sync2, sync3;
    
    always @(posedge clock) begin
        sync1 <= button_in;
        sync2 <= sync1;
        sync3 <= sync2;
    end
    
    assign button_out = sync3;
    
endmodule