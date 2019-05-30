`include "defines.v"
//if_id : instruction fetch  and instruction decode
module if_id(
	input wire					clk,
	input wire					rst,
	
	//取指阶段的信号
	input wire[`InstAddrBus]	if_pc,		//取值阶段取得的指令对应的地址	
	input wire[`InstBus]		if_inst,	//取指阶段取得的指令
	
	//译码阶段的信号
	output reg[`InstAddrBus]	id_pc,  	//使用reg变量是为了能保存上一个时刻的状态
	output reg[`InstBus]		id_inst
);

always @ (posedge clk) begin 
	if(rst == `RstEnable) begin
		id_pc <= `ZeroWord;					//复位有效时，PC（指令地址）为0
		id_inst <= `ZeroWord;				//复位有效时，对应的指令也为0，即空指令
	end else begin
		id_pc <= if_pc;						//其他情况下，把“上个时刻”的取指阶段的值传递过来
		id_inst <= if_inst;
	end
end

endmodule