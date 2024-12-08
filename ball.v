`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 03:11:54 PM
// Design Name: 
// Module Name: ball
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


module ball(input [2:0] row_address,output reg [7:0] row_data);
    
    always @*
        case(row_address)
            3'b000 :    row_data = 8'b00111100; //   ****  
            3'b001 :    row_data = 8'b01111110; //  ******
            3'b010 :    row_data = 8'b11111111; // ********
            3'b011 :    row_data = 8'b11111111; // ********
            3'b100 :    row_data = 8'b11111111; // ********
            3'b101 :    row_data = 8'b11111111; // ********
            3'b110 :    row_data = 8'b01111110; //  ******
            3'b111 :    row_data = 8'b00111100; //   ****
        endcase
    
endmodule
