`include "defines.v"
module openmips(
	input wire				clk,
	input wire				rst,
	
	input wire[`RegBus]		rom_data_i,				//从指令存储器取得的指令
	output wire[`RegBus]	rom_addr_o,				//输出到指令存储器的地址
	output wire				rom_ce_o				//指令存储器使能信号
);

/*	连接PC与ID模块之间的变量*/
	wire[`InstAddrBus]	pc;
	//另有一变量ce(输出指令存储器使能信号)，是该模块的输出变量rom_ce_o

/********************站在译码（ID）的视角下的变量*******************************************/
/* 连接IF/ID模块与译码阶段ID模块的变量 */
	wire[`InstAddrBus] 	id_pc_i;
	wire[`InstBus]		id_inst_i;
	
/*	ID和ID/EX之间的变量*/
	wire[`AluOpBus]		id_aluop_o;
    wire[`AluSelBus]	id_alusel_o;
    wire[`RegBus]		id_reg1_o;
    wire[`RegBus]		id_reg2_o;
    wire[`RegAddrBus]	id_wd_o;
    wire				id_wreg_o;

/*	译码阶段ID模块和通用寄存器Regfile模块的变量*/
	wire[`RegAddrBus]	reg1_addr;
	wire				reg1_read;	
	wire[`RegBus]		reg1_data;
	wire[`RegAddrBus]	reg2_addr;
	wire				reg2_read;	
	wire[`RegBus]		reg2_data;

/********************站在执行（EX）的视角下的变量*******************************************/	
/* ID/EX和EX之间的变量*/
	wire[`AluOpBus]		ex_aluop_i;
    wire[`AluSelBus]	ex_alusel_i;
    wire[`RegBus]		ex_reg1_i;
    wire[`RegBus]		ex_reg2_i;
    wire[`RegAddrBus]	ex_wd_i;
    wire				ex_wreg_i;
	
/* EX和EX/MEM之间的变量*/
	wire[`RegAddrBus]		ex_wd_o;
	wire					ex_wreg_o;	
    wire[`RegBus]			ex_wdata_o;
	
/********************站在访存（MEM）的视角下的变量*******************************************/	
/* EX/MEM和MEM之间的变量*/
	wire[`RegAddrBus]		mem_wd_i;
    wire					mem_wreg_i;
    wire[`RegBus]			mem_wdata_i;
	
/* MEM和MEM/WB之间的变量*/
	wire[`RegAddrBus]		mem_wd_o;
    wire					mem_wreg_o;
    wire[`RegBus]			mem_wdata_o;

/********************站在回写（WB）的视角下的变量*******************************************/	
/* MEM/WB和“回写阶段”之间的变量*/
	wire[`RegAddrBus]		wb_wd_i;
    wire					wb_wreg_i;
    wire[`RegBus]			wb_wdata_i;

	
/*接下来是例化每一个模块，将他们连接起来*/

	pc_reg pe_reg0(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.ce(rom_ce_o)
	);
	//指令存储器的输入地址就是pc的值
	assign rom_addr_o = pc; 					//连续赋值语句（assign）能独立于过程块 存在于module中
	
	if_id if_id0(
		.clk(clk),
		.rst(rst),
		.if_pc(pc),	
		.if_inst(rom_data_i),
		.id_pc(id_pc_i),  
		.id_inst(id_inst_i)
	);
	
	id id0(
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),
		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),
		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read),
		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 
	    .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o)
	);

	regfile regfile1(
		.clk(clk),
		.rst(rst),
		.waddr(wb_wd_i),	
		.wdata(wb_wdata_i),	
		.we(wb_wreg_i),		
		.raddr1(reg1_addr),
		.re1(reg1_read),	
		.rdata1(reg1_data),  
        .raddr2(reg2_addr),
        .re2(reg2_read),	
        .rdata2(reg2_data)
	);
	
	id_ex id_ex0(
		.clk(clk),
		.rst(rst),
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i)
	);
	
	ex ex0(
		.rst(rst),
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),	
		.wdata_o(ex_wdata_o)
	);
	
	ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i)
	);
	
	mem mem0(
		.rst(rst),
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),	
		.wdata_i(mem_wdata_i),
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),	
		.wdata_o(mem_wdata_o)
	);
	
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),	
		.wb_wdata(wb_wdata_i)
	);


endmodule
	