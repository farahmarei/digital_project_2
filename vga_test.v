`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 01:09:48 PM
// Design Name: 
// Module Name: vga_test
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

module vga_test (
    output [3:0] vgaRed,       // VGA Red output
    output [3:0] vgaGreen,     // VGA Green output
    output [3:0] vgaBlue,      // VGA Blue output
    output Hsync,              // Horizontal sync output
    output Vsync,              // Vertical sync output
    input clk,                 // Clock input
    input rst                  // Reset input
);

    wire pixel_clk;            // Pixel clock
    wire [9:0] currentRow;     // Current row (vertical position)
    wire [9:0] currentColumn;  // Current column (horizontal position)
    wire video_on;             // Video signal (active when inside visible area)

    // Generate 25 MHz pixel clock (for VGA timing)
    clk_divider #(2) pixel_clock_gen(
        .clk(clk),
        .rst(rst),
        .clk_out(pixel_clk)  // Use the divided clock
    );

    // VGA sync generator to generate timing signals
    syncgenerator sync_gen(
        .clk(pixel_clk),      // Use pixel clock for timing
        .rst(rst),
        .Horizontal_sync(Hsync),  // Connect Hsync directly to the output
        .Vertical_sync(Vsync),    // Connect Vsync directly to the output
        .currentRow(currentRow),
        .currentColumn(currentColumn)
    );

    // Video signal (active when inside visible screen area)
    assign video_on = (currentRow < 480 && currentColumn < 640);

    // VGA controller to display colors
    vga_driver vga_ctrl(
        .clk(pixel_clk),
        .rst(rst),
        .currentRow(currentRow),
        .currentColumn(currentColumn),
        .video_on(video_on),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue)
        // Do not connect hsync and vsync here, they are driven by sync_gen
    );

endmodule
