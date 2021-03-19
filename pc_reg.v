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
// Module:  pc_reg
// File:    pc_reg.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 指令指针寄存器PC
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module pc_reg(

	input	wire										clk,	//时钟信号
	input 	wire										rst,	//复位信号

	//来自控制模块的信息
	input wire[5:0]               stall,

	//来自译码阶段的信息
	input wire                    branch_flag_i,
	input wire[`RegBus]           branch_target_address_i,
	
	output reg[`InstAddrBus]			pc,	//要读取的指令地址 InstAddrBus使指令地址线的宽度
	output reg                    ce							//指令存储器使能信号
	
);

	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin	
			pc <= 32'h00000000;					//芯片禁止信号
		end else if(stall[0] == `NoStop) begin
		  	if(branch_flag_i == `Branch) begin
					pc <= branch_target_address_i;
				end else begin
		  		pc <= pc + 4'h4;				//指令存储器使能的时候，PC的值每时钟周期加4
		  	end									//一条指令对应4个字节
		end
	end
	
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin		//复位的时候指令存储器禁用
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;				//复位结束后，指令寄存器使能。
		end
	end

endmodule