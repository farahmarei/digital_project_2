`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 01:14:16 PM
// Design Name: 
// Module Name: syncgenerator
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


module syncgenerator (
    input clk,
    input rst,
    output reg Horizontal_sync,
    output reg Vertical_sync,
    output reg [9:0] currentRow,
    output reg [9:0] currentColumn
);
   // VGA 640x480 @ 60Hz timings
    parameter H_ACTIVE = 640;
    parameter V_ACTIVE = 480;
    parameter H_FRONT_PORCH = 16;
    parameter H_SYNC_PULSE = 96;
    parameter H_BACK_PORCH = 48;
    parameter H_TOTAL = 800;    // Total horizontal pixels (including sync)

    parameter V_FRONT_PORCH = 10;
    parameter V_SYNC_PULSE = 2;
    parameter V_BACK_PORCH = 33;
    parameter V_TOTAL = 525;    // Total vertical lines (including sync)

    initial begin
        currentColumn = 0;
        currentRow = 0;
    end

    // Generate row and column position counters
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            currentColumn <= 0;
            currentRow <= 0;
        end else begin
            if (currentColumn == H_TOTAL - 1) begin
                currentColumn <= 0;
                if (currentRow == V_TOTAL - 1)
                    currentRow <= 0;
                else
                    currentRow <= currentRow + 1;
            end else begin
                currentColumn <= currentColumn + 1;
            end
        end
    end

    // Horizontal and Vertical Sync Signals (Active Low)
    always @(*) begin
        Horizontal_sync = (currentColumn < H_SYNC_PULSE) ? 0 : 1;  // Active low for sync pulse
        Vertical_sync = (currentRow < V_SYNC_PULSE) ? 0 : 1;        // Active low for sync pulse
    end
endmodule


