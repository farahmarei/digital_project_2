`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 03:32:40 PM
// Design Name: 
// Module Name: game_display
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


module game_display(
    input clock,  
    input reset,    
    input up_1,
    input down_1,
    input up_2,
    input down_2,
    input gra_still,
    input display_on, // enables the display when active-high
    input [9:0] x, // horizontal position of pixel
    input [9:0] y, // vertical position of pixel
    output graph_on,
    output reg hit, miss,miss2,   // ball hit or miss for 1 and miss for 2
    output reg [11:0] rgb_color // pixel color 
    );
    
    // max x and y on monitor
    parameter MAX_X = 639;
    parameter MAX_Y = 479;
    
    //  refresh tick
    wire refresh;
    assign refresh = ((y == 481) && (x == 0)) ? 1 : 0; // refresh =1 when x = 0 and y = 481
   
    // wall boundaries
    parameter wall_left= 0;    
    parameter wall_right = 7;    // 8 pixels wide
    
    // left paddle parameters
    parameter paddle_left_1 = 8;
    parameter paddle_right_1 = 13;   
    // right paddle parameters
    parameter paddle_left_2 = 626;
    parameter paddle_right_2 = 631;
    
    parameter paddle_height = 72;
    parameter paddle_speed = 2;  

    wire [9:0] y_paddle_top_1, y_paddle_bottom_1, y_paddle_top_2, y_paddle_bottom_2; // wire that defines vertical boundaries
      
    reg [9:0] y_paddle_reg_1, y_paddle_next_1, y_paddle_reg_2, y_paddle_next_2; //registers that track vertical position
    
    // ball
    // square rom boundaries
    parameter Ball_size = 8;
  
    wire [9:0] ball_left, ball_right; // horizontal boundaries
   
    wire [9:0] ball_top, ball_bottom; // vertical boundaries
    
    // register to track top left position
    reg [9:0] ball_top_reg, ball_left_reg;
    // signals for register buffer
    wire [9:0] ball_top_next, ball_left_next;
 
    // registers to track ball speed and buffers
    reg [9:0] ball_xspeed_reg, ball_xspeed_next;
    reg [9:0] ball_yspeed_reg,ball_yspeed_next;
    
    // pos and neg ball velocity
    parameter BALL_VELOCITY_POS = 0.5;
    parameter BALL_VELOCITY_NEG = -0.5;
    
    // round ball from square image
    wire [2:0] rom_address, rom_cols;   // 3-bit rom address and rom column
    reg [7:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
    

    
    
    // register control
    always @(posedge clock or posedge reset)
        if(reset) begin // reets everything back 
            y_paddle_reg_1 <= 0;
            y_paddle_reg_2 <= 0;
            ball_left_reg <= 319;
            ball_top_reg <= 239;
            ball_xspeed_reg <= 10'h002;
            ball_yspeed_reg <= 10'h002;
        end
        else begin 
            y_paddle_reg_1 <= y_paddle_next_1;
            y_paddle_reg_2 <= y_paddle_next_2;
            ball_left_reg <= ball_left_next;
            ball_top_reg <= ball_top_next;
            ball_xspeed_reg <= ball_xspeed_next;
            ball_yspeed_reg <= ball_yspeed_next;
        end
    
    // ball design
    always @*
        case(rom_address)
            3'b000 :    rom_data = 8'b00111100; //   ****  
            3'b001 :    rom_data = 8'b01111110; //  ******
            3'b010 :    rom_data = 8'b11111111; // ********
            3'b011 :    rom_data = 8'b11111111; // ********
            3'b100 :    rom_data = 8'b11111111; // ********
            3'b101 :    rom_data = 8'b11111111; // ********
            3'b110 :    rom_data = 8'b01111110; //  ******
            3'b111 :    rom_data = 8'b00111100; //   ****
        endcase
    
    // status signals
    wire wall_active, pad_on_1,pad_on_2, sq_ball_active, ball_active;
    wire [11:0] wall_color, paddle_color_1, paddle_color_2, ball_color, bg_color;
    
    // pixel within wall boundaries
    assign wall_active = ((wall_left <= x) && (x <= wall_right))  || ((MAX_X - wall_right <= x) && (x <= MAX_X - wall_left)) ? 1 : 0;
    
    
    
    // assign all colors
    assign wall_color = 12'hAAA;      
    assign paddle_color_1 =  12'hFFF;       
    assign paddle_color_2 = 12'hFFF;   
    assign ball_color = 12'h000;      
    assign bg_color = 12'hF8C;      
    
    // paddle for player 1
    assign y_paddle_top_1 = y_paddle_reg_1;                             // top position
    assign y_paddle_bottom_1 = y_paddle_top_1 + paddle_height - 1;      // paddle bottom position
    assign pad_on_1= (paddle_left_1 <= x) && (x <= paddle_right_1) &&     // pixel within paddle boundaries
                    (y_paddle_top_1 <= y) && (y <= y_paddle_bottom_1);
             
 // paddle for player 2
    assign y_paddle_top_2 = y_paddle_reg_2; // paddle top position
    assign y_paddle_bottom_2 = y_paddle_top_2 + paddle_height - 1;  // paddle bottom position
    assign pad_on_2= (paddle_left_2 <= x) && (x <= paddle_right_2) &&     // pixel within paddle boundaries
                    (y_paddle_top_2 <= y) && (y <= y_paddle_bottom_2);                   
                    
    // paddle control for 1
    always @* begin
        y_paddle_next_1 = y_paddle_reg_1;    
        if(refresh)
            if(up_1 & (y_paddle_top_1 > paddle_speed))
                y_paddle_next_1 = y_paddle_reg_1 - paddle_speed;  // move up
            else if(down_1 & (y_paddle_bottom_1 < (MAX_Y - paddle_speed)))
                y_paddle_next_1 = y_paddle_reg_1 + paddle_speed;  // move down
    end
    
        // paddle control for 2
    always @* begin
        y_paddle_next_2 = y_paddle_reg_2;     // no move
        if(refresh)
            if(up_2 & (y_paddle_top_2 > paddle_speed))
                y_paddle_next_2 = y_paddle_reg_2 - paddle_speed;  // move up
            else if(down_2 & (y_paddle_bottom_2 < (MAX_Y - paddle_speed)))
                y_paddle_next_2 = y_paddle_reg_2 + paddle_speed;  // move down
    end
    
    // rom data square boundaries
    assign ball_left = ball_left_reg;
    assign ball_top = ball_top_reg;
    assign ball_right = ball_left + Ball_size - 1;
    assign ball_bottom = ball_top + Ball_size - 1;
    
    // pixel within rom square boundaries
    assign sq_ball_active = (ball_left <= x) && (x <= ball_right) && (ball_top <= y) && (y <= ball_bottom);
                        
    // map current pixel location to rom addr and col
    assign rom_address = y[2:0] - ball_top[2:0];   // 3-bit address
    assign rom_cols = x[2:0] - ball_left[2:0];    // 3-bit column index
    assign rom_bit = rom_data[rom_cols];         // 1-bit signal rom data by column
   
    // pixel within round ball
    assign ball_active = sq_ball_active & rom_bit;    // making sure its within square boundaries AND rom data bit == 1

    
    
    
      // new ball position
    assign ball_left_next = (gra_still) ? MAX_X / 2 :
                         (refresh) ? ball_left_reg + ball_xspeed_reg : ball_left_reg;
    assign ball_top_next = (gra_still) ? MAX_Y / 2 :
                         (refresh) ? ball_top_reg + ball_yspeed_reg : ball_top_reg;
    
    // collision detection
    always @* begin
        ball_xspeed_next = ball_xspeed_reg;
        ball_yspeed_next = ball_yspeed_reg;
        hit = 1'b0;
        miss = 1'b0;
        miss2 = 1'b0;
        if(gra_still) begin
            ball_xspeed_next = BALL_VELOCITY_NEG;
            ball_yspeed_next = BALL_VELOCITY_POS;
        end
        else if(ball_top <= 1)                                            // collide with top
            ball_yspeed_next = BALL_VELOCITY_POS;                       // move down
            
        else if(ball_bottom >= MAX_Y)                                   // collide with bottom
            ball_yspeed_next = BALL_VELOCITY_NEG;                       // move up      
            
        else if((paddle_left_1 <= ball_right) && (ball_right <= paddle_right_1+5) &&
                (y_paddle_top_1 <= ball_bottom) && (ball_top <= y_paddle_bottom_1))     // collide with paddle
            ball_xspeed_next = BALL_VELOCITY_POS;                       // move left
        else if((paddle_left_2 <= ball_right) && (ball_right <= paddle_right_2) &&
                (y_paddle_top_2 <= ball_bottom) && (ball_top <= y_paddle_bottom_2))begin     // collide with paddle
                    ball_xspeed_next = BALL_VELOCITY_NEG; 
                    hit = 1'b1; 
             end       
         else if(ball_right >= MAX_X-wall_right)
            miss = 1'b1; 
         else if(ball_left <= wall_right)
            miss2 = 1'b1;

    end     
    assign graph_on = wall_active | pad_on_1 | | pad_on_2 | ball_active ;
    // rgb multiplexing circuit
    always @*
        if(~display_on)
            rgb_color = 12'h000;      // if display not on, show nothing
        else
            if(wall_active)
                rgb_color = wall_color;     // wall color
            else if(pad_on_1)
                rgb_color = paddle_color_1;      // paddle color
             else if(pad_on_2)
                rgb_color = paddle_color_2;
            else if(ball_active)
                rgb_color = ball_color;     // ball color
            else
                rgb_color = bg_color;       // background color
       
endmodule
