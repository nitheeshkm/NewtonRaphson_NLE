`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: URTPC
// Engineer: Nitheesh Manjunath
// 
// Create Date: 05/22/2020 04:13:08 PM
// Design Name: 
// Module Name: Inverse_Jacob_tb
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


module Inverse_Jacob_tb#(
        dw = 32
        );

reg clk, rst, en;

reg [dw-1:0] x,y,z;
wire signed [dw-1:0] Aj00, Aj10, Aj20, Aj01, Aj11, Aj21, Aj02, Aj12, Aj22;
wire done;
wire signed [dw-1:0] d;
reg signed [2*dw-1:0] iAj00, iAj01, iAj02, iAj10, iAj11, iAj12, iAj20, iAj21, iAj22;
Inverse_Jacob#(
        .dw(dw)
        )uut(
         clk,
         rst,
         en,
         x, y, z,
         done,
         d,
         Aj00, Aj10, Aj20, Aj01, Aj11, Aj21, Aj02, Aj12, Aj22
        );

integer period = 10;
//reg signed [dw-1:0] i, j;
//reg signed [2*dw-1:0] k;

initial begin
    clk = 0;
    forever #(period/2) clk = ~clk;
end 

initial begin
    rst = 1;
    en = 0;
    x = 0;
    y = 0;
    z = 0;
//    i = 32'b00000010_00000000_00000000_00000000;
//    j = 32'b11111110_00000000_00000000_00000000;
//    k = i*j;
    
    #(5*period);
    
    rst = 0;
    #(5*period);
    
    en = 1;
    x = 32'b00000001__00000000_00000000_00000000;  //1.0
    y = 32'b00000010__00000000_00000000_00000000;  //2.0
    z = 32'b00000011__00000000_00000000_00000000;  //3.0
    
    #(5*period);
    en = 0;
    
    while(!done) begin
        #(period);
    end
    
    #(5*period);
    iAj00 = Aj00*d;
    iAj10 = Aj10*d;
    iAj20 = Aj20*d;
    iAj01 = Aj01*d;
    iAj11 = Aj11*d;
    iAj21 = Aj21*d;
    iAj02 = Aj02*d;
    iAj12 = Aj12*d;
    iAj22 = Aj22*d;
    
    $finish();
end

endmodule
