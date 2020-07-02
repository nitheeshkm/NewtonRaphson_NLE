`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: URTPC
// Engineer: Nitheesh Manjunath
// 
// Create Date: 05/22/2020 10:48:27 PM
// Design Name: 
// Module Name: MAC
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


module MAC#(
    dw_i = 32,
    dw_o = 32
    )(
    clk, rst_n, newMac, A, B, P, macdone
    );
    
input clk;
input rst_n;

input newMac;
input signed [dw_i-1:0] A;
input signed [dw_i-1:0] B;
output signed [dw_o-1:0] P;
output macdone;

(*keep = "true"*)reg signed [2*dw_o-1:0] partial_product;
(*keep = "true"*)reg signed [2*dw_i-1:0] partialSum;

(*keep = "true"*)reg newMac_1, newMac_2, newMac_3;

always@(*) begin
    if(rst_n) begin
        partial_product <= 0;
    end
    else begin
        partial_product <= A*B;
    end 
end

always@(posedge clk) begin
    if(rst_n) begin
        partialSum <= 0;
    end
    else begin
        newMac_1 <= newMac;
        newMac_2 <= newMac_1;
        newMac_3 <= newMac_2;
        if(!newMac) begin
            partialSum <= partialSum + partial_product;
        end
        else begin
            partialSum <= partial_product;
        end
    end
end

assign P = partialSum[56-1:24];
assign macdone = newMac_3;

endmodule
