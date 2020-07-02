`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: URTPC
// Engineer: Nitheesh Manjunath
// 
// Create Date: 05/22/2020 10:40:51 PM
// Design Name: 
// Module Name: top_tb
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


module top_tb#(
    dw = 32
    );
    
reg clk, rst, start;
reg signed [dw-1:0] xo, yo, zo;
wire signed [dw-1:0] xn, yn, zn;
reg [4-1:0] iter;
wire rootsFound;

top#(dw)uut(
    clk, rst, start, 
    xo, yo, zo,
    iter,
    xn, yn, zn,
    rootsFound
    );

integer period = 10, j, i;

initial begin
    clk = 0;
    forever #(period/2) clk = ~clk;
end

initial begin
    rst = 1;
    xo = 0;
    yo = 0;
    zo = 0;
    iter  = 9;
    start = 0;
    #(period*5);
    
    rst = 0;
    #(5*period);
    
    start = 1;
    xo = 32'b00000001__00000000_00000000_00000000;  //1.0
    yo = 32'b00000010__00000000_00000000_00000000;  //2.0
    zo = 32'b00000011__00000000_00000000_00000000;  //3.0
    #(period);
    
    start = 0;
    #(period);
    
    while(!rootsFound) begin
        #(period);
    end
    
    #(10*period)
    rst = 1;
    #(period*5);
    
    rst = 0;
    #(5*period);
    
    xo = 0;
    yo = 0;
    zo = 0;
    start = 1;
    iter  = 8;
    #(period);
    
    start = 0;
    #(period);
    
    while(!rootsFound) begin
        #(period);
    end
    
    $finish();
end
endmodule
