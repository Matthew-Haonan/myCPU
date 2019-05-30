`include "defines.v"
//regfile 实现32个通用寄存器，可以同时进行“两个寄存器的读操作”和“一个寄存器的写操作”
module regfile(
	input wire 					clk,
	input wire					rst,
	
	//写端口
	input wire[`RegAddrBus]		waddr,		//要写入哪个寄存器
	input wire[`RegBus]			wdata,		//要写什么数据
	input wire					we,			//写使能
	
	//读端口1
	input wire[`RegAddrBus]		raddr1,		//要读哪个寄存器
	input wire					re1,		//端口1读使能
	output reg[`RegBus]		rdata1,		//端口1中读出的数据
	
	//读端口2
	input wire[`RegAddrBus]		raddr2,		//要读哪个寄存器
	input wire					re2,		//端口2读使能
	output reg[`RegBus]		rdata2		//端口2中读出的数据
);

/* 第一段：定义32个32位寄存器*/
reg[`RegBus] regs[0:`RegNum-1];

/* 第二段：写操作*/
always @ (posedge clk) begin
	if(rst == `RstDisable) begin
		if((we == `WriteEnable) && (waddr != `RegNumLog2'h0) ) begin		//不能写0寄存器，0寄存器的内容一直是0
			regs[waddr] <= wdata;
		end
	end
end

/* 第三段：读端口1*/
always @ (*) begin
	if(rst == `RstEnable) begin
		rdata1 <= `ZeroWord;					//复位时，读出的数据是默认0值
	end else if(raddr1 == `RegNumLog2'h0) begin
		rdata1 <= `ZeroWord;					//如果读0寄存器的内容，即为0
	end else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin	
		rdata1 <= wdata;						//要考虑到可能读写同一个寄存器，此时读出的内容为写进去的内容
	end else if(re1 == `ReadEnable) begin
		rdata1 <= regs[raddr1];
	end else begin
		rdata1 <= `ZeroWord;					//读端口不能使用时，直接输出0
	end
end

/* 第四段：读端口2*/
always @ (*) begin
	if(rst == `RstEnable) begin
		rdata2 <= `ZeroWord;					//复位时，读出的数据是默认0值
	end else if(raddr2 == `RegNumLog2'h0) begin
		rdata2 <= `ZeroWord;					//如果读0寄存器的内容，即为0
	end else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin	
		rdata2 <= wdata;						//要考虑到可能读写同一个寄存器，此时读出的内容为写进去的内容
	end else if(re1 == `ReadEnable) begin
		rdata2 <= regs[raddr2];
	end else begin
		rdata2 <= `ZeroWord;					//读端口不能使用时，直接输出0
	end
end

endmodule