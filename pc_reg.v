`include "defines.v"
module pc_reg(
//wire变量紧跟输入的变化而变化，reg变量能保存上次写入的数据（常对应D触发器或锁存器）
	input wire					clk,		//输入clock信号
	input wire 					rst,		//输入reset信号
	output reg[`InstAddrBus]	pc,			//输出32位的指令地址
	output reg					ce			//输出指令存储器使能信号
);

always @ (posedge clk) begin
	if (rst == `RstEnable) begin
		ce <= `ChipDisable;						//复位有效时，指令存储器禁用
	end else begin
		ce <= `ChipEnable;						//复位结束后，指令寄存器使能
	end
end

always @ (posedge clk) begin
	if(ce == `ChipDisable) begin
		pc <= 32'h00000000;						//指令寄存器禁用时，PC值为0
	end else begin
		pc <= pc + 4'h4;						//指令寄存器使能时，每个时钟周期+4
	end
end

endmodule