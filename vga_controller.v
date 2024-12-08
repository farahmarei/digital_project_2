`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 05:12:19 PM
// Design Name: 
// Module Name: vga_controller
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


module vga_controller(
    input clock_100,   
    input reset,        // reset
    output display_active,    
    output hsync,       // sync signal for vga
    output vsync,      
    output p_tick,      // pixel clock tick
    output [9:0] x,     // pixel count max 0-799
    output [9:0] y      // pixel count max 0-524
    );

    parameter horizontal_width = 640;            
    parameter HF = 48;             
    parameter HB = 16;             
    parameter HR = 96;             
    parameter horizontal_MAX = horizontal_width+HF+HB+HR-1; // max value of horizontal counter = 799
    
    
    // total vertical length of screen = 525 pixels
    parameter vertical_height = 480;            
    parameter VF = 10;              
    parameter VB = 33;                 
    parameter VR = 2;                
    parameter vertical_MAX = vertical_height+VF+VB+VR-1; // max value of vertical counter = 524   
    
	reg  [1:0] r_25MHz;
	wire w_25MHz;
	
	always @(posedge clock_100 or posedge reset)
		if(reset)
		  r_25MHz <= 0;
		else
		  r_25MHz <= r_25MHz + 1;
	
	assign w_25MHz = (r_25MHz == 0) ? 1 : 0; 
    
    // counter registers,one for buffering to avoid glitches
    reg [9:0] h_count_reg, h_count_next;
    reg [9:0] v_count_reg, v_count_next;
    
    // output buffers
    reg v_sync_reg, h_sync_reg;
    wire v_sync_next, h_sync_next;
    
    // reg control
    always @(posedge clock_100 or posedge reset)
        if(reset) begin
            v_count_reg <= 0;
            h_count_reg <= 0;
            v_sync_reg  <= 1'b0;
            h_sync_reg  <= 1'b0;
        end
        else begin
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            v_sync_reg  <= v_sync_next;
            h_sync_reg  <= h_sync_next;
        end
         
    // horizontal counter
    always @(posedge w_25MHz or posedge reset)      // pixel tick
        if(reset)
            h_count_next = 0;
        else
            if(h_count_reg == horizontal_MAX)                 // end of horizontal scan
                h_count_next = 0;
            else
                h_count_next = h_count_reg + 1;         
  
    // Logic for vertical counter
    always @(posedge w_25MHz or posedge reset)
        if(reset)
            v_count_next = 0;
        else
            if(h_count_reg == horizontal_MAX)                // end of horizontal scan
                if((v_count_reg == vertical_MAX))           // end of vertical scan
                    v_count_next = 0;
                else
                    v_count_next = v_count_reg + 1;
        
    
    assign h_sync_next = (h_count_reg >= (horizontal_width+HB) && h_count_reg <= (horizontal_width+HB+HR-1));
    
    assign v_sync_next = (v_count_reg >= (vertical_height+VB) && v_count_reg <= (vertical_height+VB+VR-1));
    
    // display on/off
    assign display_active = (h_count_reg < horizontal_width) && (v_count_reg < vertical_height); // 0-639 and 0-479 respectively
            
    // output
    assign hsync  = h_sync_reg;
    assign vsync  = v_sync_reg;
    assign x      = h_count_reg;
    assign y      = v_count_reg;
    assign p_tick = w_25MHz;
            
endmodule
