`include "defines.v"
module inst_rom(
	input wire					ce,
	input wire[`InstAddrBus]	addr,
	output reg[`InstBus]		inst
);

	reg[`InstBus]		inst_mem[0:`InstMemNum -1];		//数组的大小是2^17
	
	initial $readmemh("inst_rom.data",inst_mem);
	
	always @ (*) begin
		if(ce == `ChipDisable) begin
			inst <= `ZeroWord;
		end else begin
			inst <= inst_mem[addr[`InstMemNumLog2 + 1 : 2]];  
			/*这里解释一下，因为inst_mem数组大小是2^17，因此inst_mem[?],'?'处的
			数字的长度是17位宽[16:0]，又因为‘？’处的内容需要除以一个4，所以取的是addr的
			[18:2]*/
		end
	end
	


endmodule