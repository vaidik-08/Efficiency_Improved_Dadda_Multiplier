`timescale 1ns / 1ps

module half_adder( input a,b, output  sum,carry );
assign sum = a ^ b;
assign carry = a & b;
endmodule

module full_adder( input a,b,cin,output sum,carry);
assign sum = a ^ b ^ cin;
assign carry = ((a ^ b) & cin)|(a&b);
endmodule

module approx_compressor(input x1,x2,x3,x4,output sum,carry);
wire [5:0]w;
xor g1(w[0],x1,x2);
nand g2(w[1],x1,x2);
xor g3(w[2],x3,x4);
nand g4(w[3],x3,x4);
not g5(w[4],w[0]);
mux2x1 m1(w[2],w[0],w[4],sum);
nand g6(w[5],w[0],w[2]);
nand g7(carry,w[1],w[5],w[3]);
endmodule

module mux2x1(input sel,x0,x1,output y);
assign y=((~sel)&x0)|(sel&x1);
endmodule

module exact_compressor(input a,b,c,d,cin,output cout,sum,carry);
assign sum = a^b^c^d^cin;
assign cout = ((a^b)&c)|((~(a^b))&a);
assign carry = ((a^b^c^d)&cin)|((~(a^b^c^d))&d);
endmodule

module AND(a, b, c);
    input [7:0] a;
    input b;
    output [7:0] c;

    assign c[0] = a[0] & b;
    assign c[1] = a[1] & b;
    assign c[2] = a[2] & b;
    assign c[3] = a[3] & b;
    assign c[4] = a[4] & b;
    assign c[5] = a[5] & b;
    assign c[6] = a[6] & b;
    assign c[7] = a[7] & b;

endmodule

module Dadda_multiplier_approx(a,b,y);
    input [7:0] a, b;
    output [15:0] y;


    wire [7:0] p[7:0];

    AND a1(a, b[0], p[0]);//calls module that will and b[0] with every bit of a.
    AND a2(a, b[1], p[1]);
    AND a3(a, b[2], p[2]);
    AND a4(a, b[3], p[3]);
    AND a5(a, b[4], p[4]);
    AND a6(a, b[5], p[5]);
    AND a7(a, b[6], p[6]);
    AND a8(a, b[7], p[7]);
    
    wire [23:0]c;
    wire [23:0]s;
    wire [20:0]cout;
    
    ////////////////////////////////////////////////////// level 1 ////////////////////////////////////////////////////////
    
    /////////////////////////////////approx///////////////////////////////////////////////////
    half_adder h1(p[0][4],p[1][3],s[0],c[0]);
    
    approx_compressor ac1(p[0][5],p[1][4],p[2][3],p[3][2],s[1],c[1]);
    
    approx_compressor ac2(p[0][6],p[1][5],p[2][4],p[3][3],s[2],c[2]);
    half_adder h2(p[4][2],p[5][1],s[3],c[3]);
    
    approx_compressor ac3(p[0][7],p[1][6],p[2][5],p[3][4],s[4],c[4]);
    approx_compressor ac4(p[4][3],p[5][2],p[6][1],p[7][0],s[5],c[5]);
    
    //////////////////////////////////////exact///////////////////////////////////////////////
    exact_compressor ec1(p[1][7],p[2][6],p[3][5],p[4][4],0,cout[0],s[6],c[6]);
    full_adder fa1(p[5][3],p[6][2],p[7][1],s[7],c[7]);
    
    exact_compressor ec2(p[2][7],p[3][6],p[4][5],p[5][4],cout[0],cout[1],s[8],c[8]);
    half_adder h3(p[6][3],p[7][2],s[9],c[9]);
    
    exact_compressor ec3(p[3][7],p[4][6],p[5][5],p[6][4],cout[1],cout[2],s[10],c[10]);
    
    full_adder fa2(p[4][7],p[5][6],cout[2],s[11],c[11]);
    
    /////////////////////////////////////////// level 2 /////////////////////////////////////////////////////////
    
    /////////////////////////////////////// approx ///////////////////////////////////////////////
    approx_compressor ac5(s[0],p[2][2],p[3][1],p[4][0],s[12],c[12]);
    approx_compressor ac6(s[1],c[0],p[4][1],p[5][0],s[13],c[13]);
    approx_compressor ac7(s[2],c[1],s[3],p[6][0],s[14],c[14]);
    approx_compressor ac8(s[4],c[2],s[5],c[3],s[15],c[15]);
    
    ///////////////////////////////////////// exact /////////////////////////////////////////////////
    exact_compressor ec4(s[6],c[4],s[7],c[5],0,cout[3],s[16],c[16]);
    exact_compressor ec5(s[8],c[6],s[9],c[7],cout[3],cout[4],s[17],c[17]);
    exact_compressor ec6(s[10],c[8],p[7][3],c[9],cout[4],cout[5],s[18],c[18]);
    exact_compressor ec7(s[11],c[10],p[6][5],p[7][4],cout[5],cout[6],s[19],c[19]);
    exact_compressor ec8(c[11],p[5][7],p[6][6],p[7][5],cout[6],cout[7],s[20],c[20]);
    full_adder fa4(p[6][7],p[7][6],cout[7],s[21],c[21]);
    
    //////////////////////////////////////// level 3 ////////////////////////////////////////////////////
    assign y[0]=0;
    assign y[1]=0;
    assign y[2]=0;
    assign y[3]=0;
    half_adder fa5(s[12],0,y[4],cout[8]);
    full_adder fa6(s[13],c[12],cout[8],y[5],cout[9]);
    full_adder fa7(s[14],c[13],cout[9],y[6],cout[10]);
    full_adder fa8(s[15],c[14],cout[10],y[7],cout[11]);
    full_adder fa9(s[16],c[15],cout[11],y[8],cout[12]);
    full_adder fa10(s[17],c[16],cout[12],y[9],cout[13]);
    full_adder fa11(s[18],c[17],cout[13],y[10],cout[14]);
    full_adder fa12(s[19],c[18],cout[14],y[11],cout[15]);
    full_adder fa13(s[20],c[19],cout[15],y[12],cout[16]);
    full_adder fa14(s[21],c[20],cout[16],y[13],cout[17]);
    full_adder fa15(p[7][7],c[21],cout[17],y[14],y[15]);
    
endmodule
