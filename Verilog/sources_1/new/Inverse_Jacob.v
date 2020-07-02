`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: URTPC
// Engineer: Nitheesh Manjunath
// 
// Create Date: 05/22/2020 03:55:52 PM
// Design Name: 
// Module Name: Inverse_Jacob
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


module Inverse_Jacob#(
    dw = 32
    )(
    input clk,
    input rst,
    input en,
    input signed [dw-1:0] x, y, z,
    
    output reg done_o,
    output signed [dw-1:0] determinant,
    output signed [dw-1:0] Aj00, Aj10, Aj20, Aj01, Aj11, Aj21, Aj02, Aj12, Aj22
    );


localparam state_0 = 0,
           state_1 = 1,
           state_2 = 2,
           state_3 = 3,
           state_4 = 4,
           state_5 = 5,
           state_6 = 6;
           
(*keep = "true"*)reg [2:0] currentState;

//reg en2, en3, en4, en5;

(*keep = "true"*)reg signed [dw-1:0] j00, j01, j02, j10, j11, j12, j20, j21, j22;
(*keep = "true"*)reg signed [2*dw-1:0] iAj00, iAj01, iAj02, iAj10, iAj11, iAj12, iAj20, iAj21, iAj22; 
(*keep = "true"*)reg signed [dw-1:0] D;
(*keep = "true"*)reg signed [dw-1:0] DD, DDD;

wire signed [2*dw-1:0] j00_1, j01_1, j10_1, j11_1, j20_1, j22_1, j22_2, D_0, D_1, D_2;
wire signed [dw-1:0] DI;
wire done;
wire overflow_flag;

/////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////

//always@(posedge clk) begin
//    if(rst) begin
//        en2 <= 0;
//        en3 <= 0;
//        en4 <= 0;
//        en5 <= 0;
//    end
//    else begin
//        en2 <= en;
//        en3 <= en2;
//        en4 <= en3;
//        en5 <= en4;
//    end
//end

always@(posedge clk) begin
    if(rst) begin
        currentState = state_0;
        done_o <= 0;
    end
    else begin
        case(currentState)
            state_0 : begin
                done_o <= 0; 
                if(en) begin
                    currentState <= state_1;
                end
                else begin
                    currentState <= state_0;
                end
            end
            state_1 : begin
                currentState <= state_2;
            end
            state_2 : begin
                currentState <= state_3;
            end
            state_3 : begin
                currentState <= state_4;
            end
            state_4 : begin
                currentState <= state_5;
            end
            state_5 : begin
                if(!done) begin
                    currentState <= state_5;
                end
                else begin
                    currentState <= state_6;
                end
            end
            
            state_6 : begin
                done_o <= 1;
                currentState <= state_0;
            end
        endcase
    end
end 
/////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////
always@(posedge clk) begin
    if(rst) begin
        j00 <= 0;
        j01 <= 0;
        j02 <= 0;
        
        j10 <= 0;
        j11 <= 0;
        j12 <= 0;
        
        j20 <= 0;
        j21 <= 0;
        j22 <= 0;
    end
    else begin
        if(en)  begin
            j00 <= j00_1[56-1:24] + 32'b11111110__00000000_00000000_00000000;
            j01 <= j01_1[56-1:24];
            j02 <= 32'b11111111__00000000_00000000_00000000;
            
            j10 <= j10_1[56-1:24] + 32'b11111111__00000000_00000000_00000000;
            j11 <= j11_1[56-1:24] + 32'b11111101__00000000_00000000_00000000 + z;
            j12 <= y;
            
            j20 <= j20_1[56-1:24] + y;
            j21 <= j20_1[56-1:24] + x;
            j22 <= j22_2[56-1:24] + 32'b11111101__00000000_00000000_00000000;
        end
    end
end

assign j00_1 = 32'b00000010__00000000_00000000_00000000*x;  //2*x
assign j01_1 = 32'b00000010__00000000_00000000_00000000*y;  //2*y
assign j10_1 = y**2;                                        //y^2
assign j11_1 = j00_1[56-1:24]*y;                            //2*x*y
assign j20_1 = z**2;                                        //z^2
assign j22_1 = 32'b00000010__00000000_00000000_00000000*z;  //2*z
assign j22_2 = j22_1[56-1:24]*(y + x);                      //2*z(x+y)

/////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////
always@(posedge clk) begin
    if(rst) begin
        iAj00 <= 0;
        iAj01 <= 0;
        iAj02 <= 0;
        
        iAj10 <= 0;
        iAj11 <= 0;
        iAj12 <= 0;
        
        iAj20 <= 0;
        iAj21 <= 0;
        iAj22 <= 0;
    end
    else begin
        if(currentState == state_1) begin
            iAj00 <= j11*j22 - j12*j21;
            iAj01 <= -(j10*j22 - j20*j12);
            iAj02 <= j10*j21 - j20*j11;
            iAj10 <= -(j01*j22 - j21*j02);
            iAj11 <= j00*j22 - j20*j02;
            iAj12 <= -(j00*j21 - j01*j20);
            iAj20 <= j01*j12 - j11*j02;
            iAj21 <= -(j00*j12 - j10*j02);
            iAj22 <= j00*j11 - j10*j01;
        end
    end
end

/////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////
always@(posedge clk) begin
    if(rst) begin
        D <= 0;
    end
    else begin
        if(currentState == state_2) begin
            D <= D_0[56-1:24] + D_1[56-1:24] + D_2[56-1:24];
        end
    end
end 

assign D_0 = j00*Aj00;
assign D_1 = j01*Aj01;
assign D_2 = j02*Aj02;

always@(posedge clk) begin
    if(rst) begin
        DD <= 0;
    end
    else begin
        if(currentState == state_3) begin
            if(D[31])begin
                DD <= -(D);
            end
            else begin
                DD <= D ;
            end
        end
    end
end 

qdiv #(24,dw) my_divider(
    .i_dividend(32'b00000001__00000000_00000000_00000000),
    .i_divisor(DD),
    .i_start(currentState == state_4),
    .i_clk(clk),
    .o_quotient_out(DI),
    .o_complete(done),
    .o_overflow(overflow_flag)
    );

/////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////
always@(posedge clk) begin
    if(rst) begin
        DDD <= 0;
    end
    else begin
        if (done) begin
            if(D[31]) begin
                DDD <= -(DI);
            end
            else begin
                DDD <= DI;
            end
        end
    end
end

assign determinant = DDD;

//always@(posedge clk) begin
//    if(rst) begin
//        Aj00 <= 0;
//        Aj01 <= 0;
//        Aj02 <= 0;
        
//        Aj10 <= 0;
//        Aj11 <= 0;
//        Aj12 <= 0;
        
//        Aj20 <= 0;
//        Aj21 <= 0;
//        Aj22 <= 0;
//    end
//    else if(currentState == state_6) begin
//        Aj00 <= iAj00[56-1:24] * DDD;
//        Aj10 <= iAj10[56-1:24] * DDD;
//        Aj20 <= iAj20[56-1:24] * DDD;
//        Aj01 <= iAj01[56-1:24] * DDD;
//        Aj11 <= iAj11[56-1:24] * DDD;
//        Aj21 <= iAj21[56-1:24] * DDD;
//        Aj02 <= iAj02[56-1:24] * DDD;
//        Aj12 <= iAj12[56-1:24] * DDD;
//        Aj22 <= iAj22[56-1:24] * DDD;
//    end

//end


assign Aj00 = iAj00[56-1:24];
assign Aj10 = iAj10[56-1:24];
assign Aj20 = iAj20[56-1:24];
assign Aj01 = iAj01[56-1:24];
assign Aj11 = iAj11[56-1:24];
assign Aj21 = iAj21[56-1:24];
assign Aj02 = iAj02[56-1:24];
assign Aj12 = iAj12[56-1:24];
assign Aj22 = iAj22[56-1:24];

endmodule
