`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: URTPC
// Engineer: Nitheesh Manjunath
// 
// Create Date: 05/22/2020 10:02:34 PM
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


module top#(dw = 32,
            row = 3,
            col = 3)(
    input clk, rst, start, 
    input signed [dw-1:0] xo, yo, zo,
    input [4-1:0] iter,
    output reg signed [dw-1:0] xn, yn, zn,
//    output [dw-1:0] less_pins,  //Artix 7 only has 166 pins so workaround to synthesis
    (*keep = "true"*) output reg rootsFound
    );

//(*keep = "true"*)reg signed [dw-1:0] xn, yn, zn;

localparam state_0 = 0,
           state_1 = 1,
           state_2 = 2,
           state_3 = 3,
           state_4 = 4,
           state_5 = 5,
           state_6 = 6;
           
(*keep = "true"*)reg [2:0] currentState;

(*keep = "true"*)reg [5-1:0] iter_cnt, col_cnt, row_cnt;
(*keep = "true"*)reg [5-1:0] iAj_address, F_address, IF_Address;
(*keep = "true"*)reg en, newMac, newMac_1, Inv_J_rst;
wire done, macDone;

(*keep = "true"*)reg signed [dw-1:0] x, y, z;
(*keep = "true"*)reg signed [dw-1:0] F [0:2];
wire signed [dw-1:0] Aj00, Aj10, Aj20, Aj01, Aj11, Aj21, Aj02, Aj12, Aj22, D;
wire [2*dw-1:0] x_sq, x2, y_sq, z_sq, xy_sq, y3, yz, xy, xz_sq, yz_sq, z3;
(*keep = "true"*)reg signed [2*dw-1:0] iAj [0:8];

(*keep = "true"*)reg signed [dw-1:0] IFBuffer [0:2];

wire [dw-1:0] A,B, P;

Inverse_Jacob#(
        .dw(dw)
        )Inv_J(
         clk,
         rst | Inv_J_rst,
         en,
         x, y, z,
         done,
         D,
         Aj00, Aj10, Aj20, Aj01, Aj11, Aj21, Aj02, Aj12, Aj22
        );

MAC#(
    dw,
    dw
    )_MAC_(
    clk, 
    rst, 
    newMac_1, 
    A, 
    B, 
    P,
    macDone
    );
    
        
always@(posedge clk) begin
    if(rst) begin
        currentState <= state_0;
        en <= 0;
        x <= 0;
        y <= 0;
        z <= 0;
        iter_cnt <= 0;
        col_cnt <= 0; 
        row_cnt <= 0;
        newMac <= 0;
        rootsFound <= 0;
        Inv_J_rst <= 0;
    end
    else begin
        case(currentState) 
            state_0 : begin
                iter_cnt <= 0;
                col_cnt <= 0; 
                row_cnt <= 0;
                newMac <= 0;
                Inv_J_rst <= 0;
                rootsFound <= 0;
                if(start) begin
                    currentState <= state_1;
                    en <= 1;
                    x <= xo;
                    y <= yo;
                    z <= zo;
                end
                else begin
                    currentState <= state_0;
                    en <= 0;
                    x <= 0;
                    y <= 0;
                    z <= 0;
                end
            end
            state_1 : begin
                en <= 0;
                if(done) begin
                    iter_cnt <= iter_cnt + 1;
                    currentState <= state_2;
                end
                else begin
                    currentState <= state_1;
                end
            end
            state_2 : begin
                currentState <= state_3;
                newMac <= 1;
            end
            state_3 : begin
                if(col_cnt < col-1) begin
                    col_cnt <= col_cnt + 1;
                    newMac <= 0; 
                end
                else begin
                    if(row_cnt < row-1) begin
                        row_cnt <= row_cnt + 1;
                        col_cnt <= 0;
                        newMac <= 1;
                    end
                    else begin
                        currentState <= state_4; 
                        col_cnt <= 0;
                        row_cnt <= 0;
                        newMac <= 0;
                    end
                end
            end
            state_4 : begin
                if(macDone) begin
                    currentState <= state_5;
                    Inv_J_rst <= 1; 
                end
                else begin
                    currentState <= state_4;
                end
            end
            state_5 : begin
                x <= x - IFBuffer[0];
                y <= y - IFBuffer[1];
                z <= z - IFBuffer[2];
                if(iter_cnt < iter) begin
                    currentState <= state_1;
                    en <= 1;
                    Inv_J_rst <= 0;
                end
                else begin
                    currentState <= state_6;
                    en <= 0;
                    Inv_J_rst <= 0;
                end
            end
            state_6 : begin
                currentState <= state_0;
                rootsFound <= 1;
                Inv_J_rst <= 0;
            end
            
            default  : begin
                 currentState <= state_0;
            end
        endcase
    end
end

always@(posedge clk) begin
    if(rst) begin
        F[0] <= 0;
        F[1] <= 0;
        F[2] <= 0;
    end
    else begin
        F[0] <= x_sq[56-1:24] - x2[56-1:24] + y_sq[56-1:24] - z + 32'b00000001__00000000_00000000_00000000;
        F[1] <= xy_sq[56-1:24] - x - y3[56-1:24] + yz[56-1:24] + 32'b00000010__00000000_00000000_00000000;
        F[2] <= xz_sq[56-1:24] - z3[56-1:24] + yz_sq[56-1:24] + xy[56-1:24];
    end
end

assign x2 = 32'b00000010__00000000_00000000_00000000*x;
assign x_sq = x**2;
assign y_sq = y**2;
assign z_sq = z**2;
assign xy_sq = x*y_sq[56-1:24];
assign y3 = 32'b00000011__00000000_00000000_00000000 * y;
assign yz = y*z;
assign xy = x*y;
assign xz_sq = z_sq[56-1:24]*x;
assign yz_sq = z_sq[56-1:24]*y;
assign z3 = 32'b00000011__00000000_00000000_00000000 * z;

always@(posedge clk) begin
    if(rst) begin
        iAj[0] <= 0;
        iAj[1] <= 0;
        iAj[2] <= 0;
        iAj[3] <= 0;
        iAj[4] <= 0;
        iAj[5] <= 0;
        iAj[6] <= 0;
        iAj[7] <= 0;
        iAj[8] <= 0;
    end
    else begin
        if(currentState == state_2) begin
            iAj[0] <= Aj00*D;
            iAj[1] <= Aj10*D;
            iAj[2] <= Aj20*D;
            iAj[3] <= Aj01*D;
            iAj[4] <= Aj11*D;
            iAj[5] <= Aj21*D;
            iAj[6] <= Aj02*D;
            iAj[7] <= Aj12*D;
            iAj[8] <= Aj22*D;
        end
    end
end


always@(posedge clk)  begin
    if(rst) begin
         iAj_address <= 0;
         F_address <= 0;
         newMac_1 <= 0;
    end
    else begin
        if(currentState == state_3)begin
            iAj_address <= col_cnt+row_cnt*row;
            F_address <= col_cnt;
            newMac_1 <= newMac;
        end
    end
end

assign A = iAj[iAj_address][56-1:24];
assign B = F[F_address];

always@(posedge clk) begin
    if(rst || currentState == state_1) begin
        IFBuffer[0] <= 0;
        IFBuffer[1] <= 0;
        IFBuffer[2] <= 0;
        IF_Address <= 0;
    end
    else begin
        if(macDone) begin
            IFBuffer[IF_Address] <= P;
            IF_Address <= IF_Address + 1;
        end
    end
end

always@(posedge clk) begin
    if(rst) begin
        xn <= 0;
        yn <= 0;
        zn <= 0;
    end
    else begin
        xn <= x;
        yn <= y;
        zn <= z;
    end
end

assign less_pins = xn | yn | xn;

endmodule
