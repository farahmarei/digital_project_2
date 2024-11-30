`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 05:27:27 PM
// Design Name: 
// Module Name: top
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


module top(
    input clk_100MHz,       
    input reset,            // btnR
    input up_1,               
    input down_1,    
    input up_2,               
    input down_2,          
    output hsync,           // to VGA port
    output vsync,           // to VGA port
    output [11:0] rgb       // to DAC, to VGA port
    );
    
    wire w_reset, w_up_1, w_down_1,w_up_2, w_down_2, w_display_on, w_p_tick;
    wire [9:0] w_x, w_y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    vga_controller vga(.clock_100(clk_100MHz), .reset(w_reset), .display_active(w_display_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
   
   
    game_display game(.clock(clk_100MHz), .reset(w_reset), .up_1(w_up_1), .down_1(w_down_1), 
                 .up_2(w_up_2), .down_2(w_down_2), .display_on(w_display_on), .x(w_x), .y(w_y), .rgb_color(rgb_next));
   
    debouncer debounce_reset(.clock(clk_100MHz), .button_in(reset), .button_out(w_reset));
    
    debouncer paddle1_up(.clock(clk_100MHz), .button_in(up_1), .button_out(w_up_1));
    
    debouncer paddle1_down(.clock(clk_100MHz), .button_in(down_1), .button_out(w_down_1));
    
    debouncer paddle2_up(.clock(clk_100MHz), .button_in(up_2), .button_out(w_up_2));
    
    debouncer paddle2_down(.clock(clk_100MHz), .button_in(down_2), .button_out(w_down_2));
    
    // rgb buffer
    always @(posedge clk_100MHz)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;
    
endmodule