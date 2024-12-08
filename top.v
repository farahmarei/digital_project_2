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
    output [11:0] rgb,      // to DAC, to VGA port
    output [6:0] segments,
    output [3:0] anodes
    );
    
      // state declarations for 4 states
    parameter newgame = 2'b00;
    parameter play    = 2'b01;
    parameter newball = 2'b10;
    parameter over    = 2'b11;
 
    reg [1:0] state_reg, state_next;
    wire w_reset, w_up_1, w_down_1,w_up_2, w_down_2, w_display_on, w_p_tick,  graph_on, hit, miss,miss2;
    wire [9:0] w_x, w_y;
    reg [11:0] rgb_reg;
    reg [11:0] rgb_next;
    wire [3:0] text_on;
    wire [11:0] graph_rgb, text_rgb;
    wire [3:0] dig0, dig1,dig2, dig3;
    reg gra_still, d_inc, d_clr,d2_inc, d2_clr, timer_start;
    wire timer_tick, timer_up;
    reg [1:0] ball_reg, ball_next;
    
    seven_seg seg(.clk(clk_100MHz) , .reset(reset) , .dig0(dig0), .dig1(dig1),.dig2(dig2),.dig3(dig3), .segments(segments) , .anodes(anodes));
    
    vga_controller vga(.clock_100(clk_100MHz), .reset(w_reset), .display_active(w_display_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
 
    game_display game (.clock(clk_100MHz), .reset(w_reset), .up_1(w_up_1), .down_1(w_down_1), 
                 .up_2(w_up_2), .down_2(w_down_2), .gra_still(gra_still), .display_on(w_display_on), .x(w_x), .y(w_y), 
                 .graph_on(graph_on),.hit(hit) , .miss(miss),.miss2(miss2), .rgb_color(graph_rgb));
   
    text text_dut(.clk(clk_100MHz), .x(w_x),.y(w_y),.dig0(dig0),.dig1(dig1),.dig2(dig2),.dig3(dig3),.ball(ball_reg),.text_on(text_on),.text_rgb(text_rgb));
    debouncer debounce_reset(.clock(clk_100MHz), .button_in(reset), .button_out(w_reset));
    
     // 60 Hz tick when screen is refreshed
    assign timer_tick = (w_x == 0) && (w_y == 0);
    timer timer_unit(.clk(clk_100MHz ),.reset(w_reset),.timer_tick(timer_tick),.timer_start(timer_start),.timer_up(timer_up));
    
    score_counter counter(
        .clk(clk_100MHz),
        .reset(w_reset),
        .d_inc(d_inc),
        .d_clr(d_clr),
        .dig0(dig0),
        .dig1(dig1));
        
        score_counter counter2(
        .clk(clk_100MHz),
        .reset(w_reset),
        .d_inc(d2_inc),
        .d_clr(d2_clr),
        .dig0(dig2),
        .dig1(dig3));
    
    debouncer paddle1_up(.clock(clk_100MHz), .button_in(up_1), .button_out(w_up_1));
    
    debouncer paddle1_down(.clock(clk_100MHz), .button_in(down_1), .button_out(w_down_1));
    
    debouncer paddle2_up(.clock(clk_100MHz), .button_in(up_2), .button_out(w_up_2));
    
    debouncer paddle2_down(.clock(clk_100MHz), .button_in(down_2), .button_out(w_down_2));
    
      // FSMD state and registers
    always @(posedge clk_100MHz or posedge reset)
        if(reset) begin
            state_reg <= newgame;
            ball_reg <= 0;
            rgb_reg <= 0;
        end
    
        else begin
            state_reg <= state_next;
            ball_reg <= ball_next;
            if(w_p_tick)
                rgb_reg <= rgb_next;
        end
    
// FSMD next state logic
always @* begin
    gra_still = 1'b1;
    timer_start = 1'b0;
    d_inc = 1'b0;
    d_clr = 1'b0;
    state_next = state_reg;
    ball_next = ball_reg;
    d2_inc = 1'b0; 
    d_inc = 1'b0; 
    case(state_reg)

        newgame: begin
            d_clr = 1'b1;  // Clear the scores
            d_clr = 1'b1; 
            if(up_1 != 1'b0 | up_2 != 1'b0| down_1 != 1'b0 | down_2 != 1'b0) begin
                // Start game when both players are ready
                state_next = play;
            end
        end
        
        play: begin
            gra_still = 1'b0;   // Animated screen
            
            if(miss & ~miss2) begin
                    d_inc = 1'b1; 
                    if (dig3 == 5)
                        state_next = over;
                  
                        
                    else
                        state_next = newball;  // Game Over
             end
             else if(miss2 & ~miss) begin
                    d2_inc = 1'b1; 
                    if (dig1 == 5)
                        state_next = over;
                    else
                        state_next = newball;  // Game Over
             end
             
            timer_start = 1'b1;
        end
        
        newball: begin
            // Wait for 2 sec and until both buttons are pressed to continue
            if(timer_up && (up_1 != 1'b0 | up_2 | 1'b0 | down_1 != 1'b0 | down_2 != 1'b0)) begin
                state_next = play;
            end
        end
        
        over: begin
            // Wait for 2 sec to display "Game Over"
            if(timer_up) begin
                state_next = over;  // Return to new game state after 2 sec
            end
        end
    endcase           
end
    
    // rgb multiplexing
    always @*
        if(~w_display_on)
            rgb_next = 12'h000; // blank
        
        else
            if(graph_on)
                    rgb_next = graph_rgb;   // colors in graph_text
            else if(text_on[3] || ((state_reg == newgame) && text_on[1]) || ((state_reg == over) && text_on[0]))
                rgb_next = text_rgb;    // colors in pong_text
            else if(text_on[2])
                rgb_next = text_rgb;    // colors in pong_text
                
            else
                rgb_next = 12'hF8C;     // aqua background
    
       // output
    assign rgb = rgb_reg;
    
//    // rgb buffer
//    always @(posedge clk_100MHz)
//        if(w_p_tick)
//            rgb_reg <= rgb_next;
            
//    assign rgb = rgb_reg;
    
endmodule