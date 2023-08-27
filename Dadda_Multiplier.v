`timescale 1ns / 100ps
module half_adder( input a,b, output  sum,carry );
assign sum = a ^ b;
assign carry = a & b;
endmodule

module full_adder( input a,b,cin,output sum,carry);
assign sum = a ^ b ^ cin;
assign carry = ((a ^ b) & cin)|(a&b);
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

module dadda_multiplier(a, b, y);

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
    
    wire [23:0]s;
    wire [20:0]cout;
    wire [20:0]c;
    
    ////////////////////////////// level 1 ///////////////////////////////////////
    half_adder h1(p[0][4],p[1][3],s[0],cout[0]);
    
    exact_compressor ec1(p[0][5],p[1][4],p[2][3],p[3][2],cout[0],cout[1],s[1],c[0]);
    
    exact_compressor ec2(p[0][6],p[1][5],p[2][4],p[3][3],cout[1],cout[2],s[2],c[1]);
    half_adder h2(p[4][2],p[5][1],s[3],cout[3]);
    
    exact_compressor ec3(p[0][7],p[1][6],p[2][5],p[3][4],cout[2],cout[4],s[4],c[2]);
    exact_compressor ec4(p[4][3],p[5][2],p[6][1],p[7][0],cout[3],cout[5],s[5],c[3]);
    
    exact_compressor ec5(p[1][7],p[2][6],p[3][5],p[4][4],cout[4],cout[6],s[6],c[4]);
    exact_compressor ec6(p[5][3],p[6][2],p[7][1],0,cout[5],cout[7],s[7],c[5]);
    
    exact_compressor ec7(p[2][7],p[3][6],p[4][5],p[5][4],cout[6],cout[8],s[8],c[6]);
    full_adder f1(p[6][3],p[7][2],cout[7],s[9],c[7]);
    
    exact_compressor ec8(p[3][7],p[4][6],p[5][5],p[6][4],cout[8],cout[9],s[10],c[8]);
    
    full_adder f2(p[4][7],p[5][6],cout[9],s[11],c[9]);
    
    ///////////////////////////level 2 ///////////////////////////
    half_adder h3(p[0][2],p[1][1],s[12],cout[10]);
    
    exact_compressor ec9(p[0][3],p[1][2],p[2][1],p[3][0],cout[10],cout[11],s[13],c[10]);
    
    exact_compressor ec10(s[0],p[2][2],p[3][1],p[4][0],cout[11],cout[12],s[14],c[11]);
    
    exact_compressor ec11(s[1],0,p[4][1],p[5][0],cout[12],cout[13],s[15],c[12]);
    
    exact_compressor ec12(s[2],c[0],s[3],p[6][0],cout[13],cout[14],s[16],c[13]);
    
    exact_compressor ec13(s[4],c[1],s[5],0,cout[14],cout[15],s[17],c[14]);
    
    exact_compressor ec14(s[6],c[2],s[7],c[3],cout[15],cout[16],s[18],c[15]);
    
    exact_compressor ec15(s[8],c[4],s[9],c[5],cout[16],cout[17],s[19],c[16]);
    
    exact_compressor ec16(s[10],c[6],c[7],p[7][3],cout[17],cout[18],s[20],c[17]);
    
    exact_compressor ec17(s[11],c[8],p[6][5],p[7][4],cout[18],cout[19],s[21],c[18]);
    
    exact_compressor ec18(c[9],p[5][7],p[6][6],p[7][5],cout[19],cout[20],s[22],c[19]);
    
    full_adder f3(p[6][7],p[7][6],cout[20],s[23],c[20]);
    
    //////////////////////////////////////// Level 3 ////////////////////////////////////////////
    wire [12:0]t;
    assign y[0]=p[0][0];
    half_adder h4(p[0][1],p[1][0],y[1],t[0]);
    full_adder f4(s[12],p[2][0],t[0],y[2],t[1]);
    full_adder f5(s[13],0,t[1],y[3],t[2]);
    full_adder f6(s[14],c[10],t[2],y[4],t[3]);
    full_adder f7(s[15],c[11],t[3],y[5],t[4]);
    full_adder f8(s[16],c[12],t[4],y[6],t[5]);
    full_adder f9(s[17],c[13],t[5],y[7],t[6]);
    full_adder f10(s[18],c[14],t[6],y[8],t[7]);
    full_adder f11(s[19],c[15],t[7],y[9],t[8]);
    full_adder f12(s[20],c[16],t[8],y[10],t[9]);
    full_adder f13(s[21],c[17],t[9],y[11],t[10]);
    full_adder f14(s[22],c[18],t[10],y[12],t[11]);
    full_adder f15(s[23],c[19],t[11],y[13],t[12]);
    full_adder f16(p[7][7],c[20],t[12],y[14],y[15]);
endmodule
