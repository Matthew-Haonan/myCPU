`include "defines.v"
module mem_wb(
	input wire			clk,
	input wire			rst,
	
	//来自访存阶段的信息
	input wire[`RegAddrBus]		mem_wd,
	input wire					mem_wreg,					//写使能
	input wire[`RegBus]			mem_wdata,
	
	//送到回写阶段的信息
	output reg[`RegAddrBus]		wb_wd,
	output reg					wb_wreg,					//写使能
	output reg[`RegBus]			wb_wdata
);

always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			wb_wd		<=	`NOPRegAddr;
			wb_wreg		<=	`WriteDisable;
			wb_wdata	<=	`ZeroWord;
		end else begin
			wb_wd		<=	mem_wd;
			wb_wreg		<=	mem_wreg;
			wb_wdata	<=	mem_wdata;
		end
	end
	
endmodule