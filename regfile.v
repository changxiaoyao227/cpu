//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  regfile
// File:    regfile.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 通用寄存器，共32个
// Revision: 1.0
//////////////////////////////////////////////////////////////////////
//译码阶段 给出要进行的运算类型，以及参与运算的操作数，有reg id id/ex
`include "defines.v"
//可以同时进行两个寄存器的读操作 和一个寄存器的写操作
module regfile(

	input wire										clk,
	input wire										rst,
	
	//写端口
	input wire										we,//写使能信号
	input wire[`RegAddrBus]							waddr,//要写入的寄存器地址 4：0 ！
	input wire[`RegBus]								wdata,//要写入的数据 32位
	
	//读端口1
	input wire										re1,//读使能信号
	input wire[`RegAddrBus]			 				raddr1,//第一个要读的寄存器的地址
	output reg[`RegBus]          					rdata1,//第一个寄存器的值
	
	//读端口2
	input wire										re2,//读使能信号2
	input wire[`RegAddrBus]			  				raddr2,//同上
	output reg[`RegBus]           					rdata2
	
);

	reg[`RegBus]  regs[0:`RegNum-1];//32个寄存器 每个寄存器的数据宽度为 32位

	always @ (posedge clk) begin
		if (rst == `RstDisable) begin  //写操作 写的不是0寄存器就行 0寄存器不能被写入
			if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
				regs[waddr] <= wdata;
			end
		end
	end
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			  rdata1 <= `ZeroWord; //读操作 
	  end else if(raddr1 == `RegNumLog2'h0) begin
	  		rdata1 <= `ZeroWord;//读0寄存器的操作
	  end else if((raddr1 == waddr) && (we == `WriteEnable) 
	  	            && (re1 == `ReadEnable)) begin //要读的寄存器是要写的寄存器的值 直接取出来了 
	  	  rdata1 <= wdata;
	  end else if(re1 == `ReadEnable) begin //如果没有rst 和0寄存器 还有什么写寄存器同地址的操作 读相应的寄存器
	      rdata1 <= regs[raddr1];
	  end else begin//如果不让读 没有读使能信号 回个0
	      rdata1 <= `ZeroWord;
	  end
	end

	always @ (*) begin
		if(rst == `RstEnable) begin
			  rdata2 <= `ZeroWord;
	  end else if(raddr2 == `RegNumLog2'h0) begin
	  		rdata2 <= `ZeroWord;
	  end else if((raddr2 == waddr) && (we == `WriteEnable) 
	  	            && (re2 == `ReadEnable)) begin
	  	  rdata2 <= wdata;
	  end else if(re2 == `ReadEnable) begin
	      rdata2 <= regs[raddr2];
	  end else begin
	      rdata2 <= `ZeroWord;
	  end
	end

endmodule