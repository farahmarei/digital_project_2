`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 12:29:27 PM
// Design Name: 
// Module Name: vga_driver
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

module vga_driver (
    input clk,                    // Clock input
    input rst,                    // Reset input
    input [9:0] currentRow,       // Row position (from sync generator)
    input [9:0] currentColumn,    // Column position (from sync generator)
    input video_on,               // Video signal (active area)
    output reg [3:0] vgaRed,      // Red color intensity
    output reg [3:0] vgaGreen,    // Green color intensity
    output reg [3:0] vgaBlue,     // Blue color intensity
    output reg hsync,             // Horizontal sync output
    output reg vsync              // Vertical sync output
);

    // Define the color for each of the three columns
    wire [3:0] red_column = 4'hF;    // Full red intensity for the first column
    wire [3:0] green_column = 4'hF;  // Full green intensity for the second column
    wire [3:0] blue_column = 4'hF;   // Full blue intensity for the third column
    
    // Column widths: Two columns of 213 pixels, and one column of 214 pixels
    parameter COLUMN1_WIDTH = 213; // Width of the first column
    parameter COLUMN2_WIDTH = 213; // Width of the second column
    parameter COLUMN3_WIDTH = 214; // Width of the third column

    // VGA color output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            vgaRed <= 4'b0000;
            vgaGreen <= 4'b0000;
            vgaBlue <= 4'b0000;
        end else if (video_on) begin
            // Check which column the current pixel is in and assign colors
            if (currentColumn < COLUMN1_WIDTH) begin
                // First column (Red)
                vgaRed <= red_column;
                vgaGreen <= 4'b0000;
                vgaBlue <= 4'b0000;
            end else if (currentColumn < (COLUMN1_WIDTH + COLUMN2_WIDTH)) begin
                // Second column (Green)
                vgaRed <= 4'b0000;
                vgaGreen <= green_column;
                vgaBlue <= 4'b0000;
            end else if (currentColumn < (COLUMN1_WIDTH + COLUMN2_WIDTH + COLUMN3_WIDTH)) begin
                // Third column (Blue)
                vgaRed <= 4'b0000;
                vgaGreen <= 4'b0000;
                vgaBlue <= blue_column;
            end
        end else begin
            // During the sync period, set the colors to black (no signal)
            vgaRed <= 4'b0000;
            vgaGreen <= 4'b0000;
            vgaBlue <= 4'b0000;
        end
    end

    // Sync signals output (passed from sync generator)
    always @(*) begin
        hsync = (currentColumn < 96 || (currentColumn > 112 && currentColumn < 752)) ? 0 : 1;  // Active low
        vsync = (currentRow < 2 || (currentRow > 34 && currentRow < 515)) ? 0 : 1;            // Active low
    end
endmodule



