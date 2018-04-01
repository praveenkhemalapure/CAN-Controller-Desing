
module canxmit(cantintf inter);

//module canxmit(inter.clk,inter.rst,inter.quantaDiv,inter.propQuanta,inter.seg1Quanta,inter.id,inter.format,inter.xmitdata,inter.datalen,inter.frameType,inter.startXmit,inter.busy,inter.dout,inter.ddrive,inter.din);
/*
input inter.clk,inter.rst,inter.format,inter.startXmit;
input [7:0]inter.quantaDiv;
input [5:0]inter.propQuanta;
input [5:0]inter.seg1Quanta;
input [28:0]inter.id;
input [63:0]inter.xmitdata;
input [3:0]inter.datalen;
input [2:0]inter.frameType;

output reg inter.busy,inter.dout,inter.ddrive,inter.din;
*/

import cantidef::xmitFrameType;


xmitFrameType    Ftype; 

assign Ftype=xmitFrameType'(inter.frameType);

// Internal regs and wires used 


reg [100:0]frame_size;
reg [100:0]frame_crc_size;
reg [14:0]CRC;
reg [150:0]frame;
reg [150:0]frame_d;
reg [150:0]tran_frame;
reg [150:0]final_tran_frame;
reg [150:0]final_tran_frame_d;
reg       frame_ready,frame_ready_Ftrans;
reg [100:0]frame_length;
reg [50:0]stuff_frame_length;
reg [5:0] bit_stuff_count;
reg [3:0] check_zeros,check_ones;
reg [2:0] states,nxt_state;
reg [2:0] final_states;
reg previous_bit;
reg [150:0]final_frame_size;
reg [150:0]final_frame_size_d;
reg [50:0]delay_cycles;
reg [7:0]totalbits;
wire start;
reg stuff_bit;
wire [10:0]delay;
reg  [10:0]delay_cnt;
reg count;
reg next_bit;
reg frame_final;
integer i;
reg [14:0]CRC_result;
reg [100:0]Dframe_crc_size;
reg start_crc;
reg [1:0]CRC_STATES;
reg crc_nxt;

assign delay =  (1+inter.propQuanta+inter.seg1Quanta+inter.seg1Quanta)*inter.quantaDiv;


always @(posedge inter.clk)
begin
	if(inter.startXmit)
	begin
	inter.busy = 1;
	frame	   = 0;
	frame_size = 0;
	case(Ftype)
	0:
		if(inter.format)
		begin
		frame_size 	 = 54+(inter.datalen*8);
		//frame 		 <= {0,inter.id,1,1,1,inter.datalen,inter.xmitdata[63:totalbits]};
		
			case(inter.datalen)
				0: frame = {1'b0,inter.id[28:18],1'b1,1'b0,inter.id[17:0],1'b0,1'b0,1'b0,inter.datalen};
				1: frame = {1'b0,inter.id[28:18],1'b1,1'b0,inter.id[17:0],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:56]};
				2: frame = {1'b0,inter.id[28:18],1'b1,1'b0,inter.id[17:0],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:48]};
				3: frame = {1'b0,inter.id[28:18],1'b1,1'b0,inter.id[17:0],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:40]};
				4: frame = {1'b0,inter.id[28:18],1'b1,1'b0,inter.id[17:0],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:32]};
				5: frame = {1'b0,inter.id[28:18],1'b1,1'b0,inter.id[17:0],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:24]};
				6: frame = {1'b0,inter.id[28:18],1'b1,1'b0,inter.id[17:0],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:16]};
				7: frame = {1'b0,inter.id[28:18],1'b1,1'b0,inter.id[17:0],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:8]};
				8: frame = {1'b0,inter.id[28:18],1'b1,1'b0,inter.id[17:0],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:0]};
			endcase
				
				
				frame_crc_size   = 39+(inter.datalen*8);
				//CRC	         = CalCrc(frame,frame_crc_size);
				//frame            = {frame,CRC,1'b1,1'b1,1'b1,7'b1111111};
				//frame            = {frame,CRC};
				//$display("frame is %b ",frame);
				start_crc      = 1'b1;
				end
		else
		begin
			         frame_size 	 = 34+(inter.datalen*8);
				//$display("size is %d",frame_size);
				 //frame		 = {0,inter.id[28:17],1,1,1,inter.datalen,inter.xmitdata[63:totalbits]};
           			frame_crc_size   = 19+(inter.datalen*8);
		
		
			case(inter.datalen)
				0: frame = {1'b0,inter.id[28:18],1'b0,1'b0,1'b0,inter.datalen};
				1: frame = {1'b0,inter.id[28:18],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:56]};
				2: frame = {1'b0,inter.id[28:18],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:48]};
				3: frame = {1'b0,inter.id[28:18],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:40]};
				4: frame = {1'b0,inter.id[28:18],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:32]};
				5: frame = {1'b0,inter.id[28:18],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:24]};
				6: frame = {1'b0,inter.id[28:18],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:16]};
				7: frame = {1'b0,inter.id[28:18],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:8]};
				8: frame = {1'b0,inter.id[28:18],1'b0,1'b0,1'b0,inter.datalen,inter.xmitdata[63:0]};
			endcase

		//CRC 		 = CalCrc(frame,frame_crc_size);
		//frame 	         = {frame,CRC};
		start_crc      = 1'b1;
	//	$display("frame is %b  frame_ready = %b",frame,frame_ready);
		end
	

	1:
		if(inter.format)
		begin
		frame_size 	 = 54;
		frame 		 = {1'b0,inter.id[28:18],1'b1,1'b0,inter.id[17:0],1'b1,1'b0,1'b0,inter.datalen};
		//CRC              = CalCrc(frame,10'd39);
		//frame 	         = {frame,CRC};
		//frame 	         = {frame,CRC,1'b1,1'b1,1'b1,7'b1111111};
		start_crc      = 1'b1;
		end
		else
		begin
		frame_size 	 = 34;
		frame		 = {1'b0,inter.id[28:18],1'b1,1'b0,1'b0,inter.datalen};
		//$display("Frame before crc %b",frame);
		//CRC 	         = CalCrc(frame,5'd19);
		//frame 	         = {frame,CRC};
		//frame 	         = {frame,CRC,1'b1,1'b1,1'b1,7'b1111111};
		start_crc      = 1'b1;
		end
	
endcase

end


else

begin
	if(final_states == 3)
		inter.busy = 0;
	else if (CRC_STATES == 1)
	begin
	start_crc = 0;	
	end

end











end


always @(posedge inter.clk)
	if(inter.rst)
		begin
		CRC_result = 0;
		Dframe_crc_size = 0;	
		CRC_STATES = 0;
		frame_d  = 0;
		end
	else
		begin
	
		case(CRC_STATES)
	0:	
		if(start_crc)
		begin
			Dframe_crc_size = frame_crc_size;
			CRC_result = 0;
			CRC_STATES = 1;
			frame_d = frame;
		end
	1:		
		begin		
		//	start_crc  = 0;
		if(Dframe_crc_size != 0 )
		begin
		        crc_nxt = frame_d[Dframe_crc_size - 1] ^ CRC_result[14];
       			CRC_result = {CRC_result[13:0],1'b0};
     		   	if(crc_nxt)begin
	                CRC_result[14:0] = CRC_result[14:0] ^ 15'h4599;
		        end
			Dframe_crc_size = Dframe_crc_size - 1;
			CRC_STATES = 1;
		end
		else
		CRC_STATES = 2;
		end

	2:	
		begin
		frame_ready = 1;
		frame_d={frame_d,CRC_result};
		CRC_STATES = 3;
		end

	3:    
		begin
		CRC_STATES = 0;
		frame_ready = 0;
		
		end



	default: 
		CRC_STATES = 0;

	endcase
		end	




always @(posedge inter.clk)
begin
        if(inter.rst)
	begin
        CRC  <= 0;
	delay_cnt    <= 0;
	count  <= 1;
end
	else
	begin
end


end






// State diagram for bit stuffing:

always @(posedge inter.clk)
begin
if(inter.rst)
begin
		tran_frame  = 0;

	stuff_frame_length  = 0;
	frame_length = 0;
	bit_stuff_count  = 0;
	check_ones   = 0;
	check_zeros  = 0;
	final_tran_frame = 0;	
	final_frame_size   = 0;
	states = 0;

end
else
begin
case (states)

//IDLE_STUFFING :
	0:
		if(frame_ready)
		begin
//		state <= TRANS_STUFFING;
		states = 1;
		bit_stuff_count  = 0;
		frame_length = frame_size;
		stuff_frame_length  = frame_size;
		frame_ready_Ftrans = 0;
	//	frame_ready = 0;
		check_zeros = 0;
		check_ones  = 0;
		//$display("before bit stuff %b",frame);	
		//$display("before bit stuff %d",stuff_frame_length);	
		end	
		else
		begin
		states = 0;
//		state <= IDLE_STUFFING;
		end

	
//TRANS_STUFFING: 
      
	1:

	begin
		//frame_ready = 1'b0;	
		frame_ready_Ftrans = 0;
		if(stuff_frame_length != 0 )
		begin
			if((check_zeros < 3'b101) && (check_ones < 3'b101))
			begin
			 tran_frame = {tran_frame,frame_d[stuff_frame_length-1]};
			// $display("bit stuff %b length is %d",tran_frame,stuff_frame_length - 1);		
		 		 
			 stuff_frame_length   = stuff_frame_length - 1;
				if(tran_frame[0] == 1)
				begin				
				check_ones  = check_ones + 1;
				check_zeros = 0;
				end
				else
				begin
				check_zeros = check_zeros + 1;
				check_ones  = 0;
			//$display("check zeros %d",check_zeros);	
				end		
//				state <= TRANS_STUFFING;
				states = 1;
			//$display("check ones %d",check_ones);	
			end	
			else
			begin
//				if ((check_ones == 5) && (next_bit == 1))
	//
			 	//$display("just before stuffing %b",tran_frame[stuff_frame_length - 1]);			
				if((check_ones == 3'd5) && (frame_d[stuff_frame_length - 1] == 1))
					begin
	
					//$display("check ones %d next bit %b",check_ones,frame[stuff_frame_length]);	
					check_ones      = 0;
				        check_zeros     = 0;
    					tran_frame      = {tran_frame,1'b0};
					//      state           <= TRANS_STUFFING;
				 	states          = 1;
				        bit_stuff_count = bit_stuff_count + 1;
				        end
			       	else if((check_zeros == 3'd5) && (frame_d[stuff_frame_length - 1] == 0))
					begin
			//$display("check zeros %d",check_zeros);	
   					check_zeros       = 0;
					check_ones        = 0;
	      			        tran_frame        = {tran_frame,1'b1};
    			 		states            = 1;
       				        //state           <= TRANS_STUFFING;
				        bit_stuff_count   = bit_stuff_count + 1;
					end
				else
				begin
					check_zeros       = 0;
					check_ones 	  = 0;	
					states		  = 1;	
				end	
			end

		
		end
		else
		begin
			states              = 2;
			stuff_bit           = 1'b1;
		//	state              <= IDLE_STUFFING;
		end
	end
	
	2:
	begin	

		if (stuff_bit == 1)
		begin
		stuff_bit = 1'b0;
		//$display("after bit stuff %b",tran_frame);
			case (inter.frameType)
			0: 
				if(inter.format)
				begin
				tran_frame = {tran_frame,10'b1111111111};
				final_frame_size = bit_stuff_count + frame_length + 10;
				end
				else
				begin
				tran_frame = {tran_frame,10'b1111111111};
				final_frame_size = bit_stuff_count + frame_length + 10;
				end
			1:	
				begin	
				tran_frame = {tran_frame,10'b1111111111};
				final_frame_size = bit_stuff_count + frame_length + 10;
				end	
			endcase
		//$display("total frame length %d",final_frame_size);
		final_tran_frame = tran_frame;	
		frame_ready_Ftrans = 1;
		stuff_bit 	 = 0;
		//$display("after bit stuff %b",final_tran_frame);
		end
		states              = 3;
	end

	3:
	begin
		frame_ready_Ftrans = 0;
		states              = 0;
	

	end


default: states  = 0;
		
endcase
end
end




// State machine for time syncronization:

always @(posedge inter.clk)
begin
	if(inter.rst)
	begin

	final_states <= 0;
	inter.dout <= 1;
	delay_cycles <= 0;

	inter.dout <= 1;

	end
	else	
	begin	
	case (final_states)

//	IDLE_FINAL:
	0:
		if(frame_ready_Ftrans)
//		if(frame_final)
		begin	
		final_states         <= 2;
		final_frame_size_d   <= final_frame_size;
		delay_cycles 	     <= (1+inter.propQuanta+inter.seg1Quanta+inter.seg1Quanta)*inter.quantaDiv;
		inter.dout 	     <= final_tran_frame[final_frame_size - 1];
//		frame_ready_Ftrans   <= 0;	
	//	$display("bit is %b",final_tran_frame[final_frame_size - 1]);
		end
		else
		begin
	//	final_states <= IDLE;
		final_states <= 0;
		end


//	PUSH_FINAL:
	1:
		if((final_frame_size_d) != 0)
			begin
					inter.ddrive 	     <=	1;
					inter.dout 	     <= final_tran_frame[final_frame_size_d - 1];
						final_states <= 2;
		//	$display("dout is %b ",tran_frame[final_frame_size - 1]);
	//	$display("bit is %b",inter.dout);
			end
		else
			begin
			inter.ddrive 	     <= 0;
			final_states 	     <= 3;
			end


//	SYNC_TIME_FINAL:
	2:
		begin

		if (delay_cycles != 2)
		begin
		final_states <= 2;
		delay_cycles <= delay_cycles - 1;
	//	final_states = SYNC_TIME;
		end	
		else
		begin
//		final_states = PUSH;
		delay_cycles <= (1+inter.propQuanta+inter.seg1Quanta+inter.seg1Quanta)*inter.quantaDiv;
		final_states <= 1;
		final_frame_size_d <= final_frame_size_d - 1;
		end	
	end	

	3:
		begin
		final_states 	     <= 0;
		end


	default:
	begin
	final_states <= 0;
end
	//final_state <= IDLE_FINAL;

	endcase
	end
end





endmodule



