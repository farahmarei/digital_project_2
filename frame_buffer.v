`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 01:15:50 PM
// Design Name: 
// Module Name: frame_buffer
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


module frame_buffer (
    input clk,
    input rst,
    input write_enable,       // Control for writing to BRAM
    input [9:0] address,      // 10-bit address (for 640x480 resolution)
    input data_in,            // Data to write (1-bit color intensity)
    output reg data_out       // Data read (1-bit color intensity)
);

    // Block RAM to store the framebuffer (640x480 resolution, 1 bit per pixel)
    reg [0:0] bram [0:639*479-1];  // Use BRAM for framebuffer (640x480, 1 bit per pixel)

    // Write logic (synchronous write)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset, clear only the output
            data_out <= 0;  // Clear the output on reset
        end else if (write_enable) begin
            bram[address] <= data_in;  // Write data to BRAM
        end
    end

    // Read logic (synchronous read)
    always @(posedge clk) begin
        data_out <= bram[address];  // Read data from BRAM
    end
endmodule

