`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 12:04:57 AM
// Design Name: 
// Module Name: bcd
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



module bcd(input [1:0]tog,input [3:0] num,output reg [0:6] segments,output reg [3:0] anode_active);

always @* begin
        case(tog)
            0: anode_active = 4'b1110;
            1: anode_active = 4'b1101;
            2: anode_active = 4'b1011;
            3: anode_active = 4'b0111;
        endcase 
        case(num)
0: segments = 7'b1000000; 
1: segments = 7'b1111001; 
2: segments = 7'b0100100; 
3: segments = 7'b0110000; 
4: segments = 7'b0011001; 
5: segments = 7'b0010010; 
6: segments = 7'b0000010; 
7: segments = 7'b1111000; 
8: segments = 7'b0000000; 
default: segments = 7'b0000100; 

        endcase

end

endmodule