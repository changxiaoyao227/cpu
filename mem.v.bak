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
// Module:  mem
// File:    mem.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 访存阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem(

	input wire					  rst,//复位信号
	
	//来自执行阶段的信息	
	input wire[`RegAddrBus]       wd_i,//要写入的目的寄存器地址
	input wire                    wreg_i,//是否有
	input wire[`RegBus]			  wdata_i,//数据
	//送到回写阶段的信息
	output reg[`RegAddrBus]      wd_o,//最终要写入的目的寄存器地址
	output reg                   wreg_o,//最终
	output reg[`RegBus]			 wdata_o,//最终
);

	
	always @ (*) begin
		if(rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
		  	wdata_o <= `ZeroWord;	  
		end else begin
		  	wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;		
		end    //if
	end      //always
			

endmodule