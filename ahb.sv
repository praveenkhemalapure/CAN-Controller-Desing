module ahb (  AHBIF.AHBM ahbmint , AHBIF.AHBS ahbsint ,cantintf.tox tranint);


reg [31:0]DH,DHm;
reg [31:0]DL,DLm;
reg [31:0]CMD,CMDm;
reg [31:0]ID,IDm;
reg [31:0]ST_BUSY;
reg [31:0]BM_BASE;
reg [31:0]BM_STATUS,LINK,mADDR,mDATA;
reg [4:0]count;
reg [4:0]countm;


reg [10:0]slave_states,nxtslave_states;
reg [10:0]master_states,nxtmaster_states;

always@(posedge ahbsint.HCLK)
begin
	if(ahbsint.HRESET)
	begin
	slave_states <= 0;
	DH	     <= 0;
	ID           <= 0;
	DL 	     <= 0;
	CMD	     <= 0;
	ST_BUSY      <= 0;
	DHm	     <= 0;
	DLm	     <= 0;
	CMDm	     <= 0;
	IDm          <= 0;

	BM_BASE	     <= 0;
	BM_STATUS    <= 0;
	LINK	     <= 0;
	mADDR	     <= 0;
	mDATA	     <= 0;
	nxtmaster_states  <=  0;
	master_states  <=  0;
	nxtslave_states   <=  0;
	count 		<= 0;
	countm 		<= 0;
	end
	else
	begin
	nxtslave_states  <=  slave_states;
	nxtmaster_states <=  master_states;
	count 		 <= countm;
	end

end



always @(*)
begin
		case(nxtslave_states)					
		0:
			if((ahbsint.HADDR == 32'hf000ff04) && (ahbsint.HTRANS == 2) && (ahbsint.HWRITE))
			begin
				 	slave_states = 1;
			end
			else
			begin
				 	slave_states = 0;
			end	

		1: 
			
                  //     if(ahbsint.HADDR == 32'hf000ff00)
			if((ahbsint.HADDR == 32'hf000ff00) && (ahbsint.HTRANS == 2) && (ahbsint.HWRITE))
                        begin
                                        slave_states = 2;
					DL = ahbsint.HWDATA;
                        end
                        else
                        begin
                                        slave_states = 1;
		                end	

		2:

 		//	if(ahbsint.HADDR == 32'hf000ff08)
			if((ahbsint.HADDR == 32'hf000ff08) && (ahbsint.HTRANS == 2) && (ahbsint.HWRITE))
                        begin
                                        slave_states = 3;
					DH = ahbsint.HWDATA;
                        end
                        else
                        begin
                                        slave_states = 2;
                        end


		3:

	         //       if(ahbsint.HADDR == 32'hf000ff0c)
			if((ahbsint.HADDR == 32'hf000ff0c) && (ahbsint.HTRANS == 2) && (ahbsint.HWRITE))
                        begin
                                        slave_states = 4;
					CMD = ahbsint.HWDATA;
                        end
                        else
                        begin
                                        slave_states = 3;
                        end
		
		
		4:
		
                
               //     if(ahbsint.HADDR == 32'hf000ff10)
			if((ahbsint.HADDR == 32'hf000ff10) && (ahbsint.HTRANS == 2) && (ahbsint.HWRITE))
                        begin
                    ID  = ahbsint.HWDATA;
                        slave_states = 5;
                        end
                    else
                        begin
                        slave_states = 4;
                        end

                        
		
		5:
			
                        begin
                                        slave_states = 6;
      					  ST_BUSY 	= ahbsint.HWDATA;
				tranint.startXmit  	= 1'b1;
				tranint.quantaDiv  	= CMD[31:24];
			       	tranint.propQuanta	= CMD[23:18];
			       	tranint.seg1Quanta  	= CMD[17:12];
			       	tranint.xmitdata	= {DH,DL};
				tranint.datalen		= CMD[11:8];
				tranint.id		= ID[31:3];
				tranint.format		= CMD[7];
				tranint.frameType	= CMD[6:5];

                        end
		

		6:

		if(ahbsint.HADDR == 32'hf000ff14)
			begin
				slave_states = 7;	
			end
		else	
		begin
			if(ahbsint.HWRITE == 0)
				begin
				tranint.startXmit  	= 1'b0;
				slave_states = 6;
					case(ahbsint.HADDR)	
					32'hf000ff00:
							ahbsint.HRDATA = DH;		
			
					32'hf000ff04:
							ahbsint.HRDATA = DL;
			
					32'hf000ff08:
							ahbsint.HRDATA = CMD;
				
					32'hf000ff0c:
							ahbsint.HRDATA = ID;
			
					32'hf000ff10:
	       						ahbsint.HRDATA = {31'b0,tranint.busy};

					endcase
				end
			else
			begin
	                    if((ahbsint.HADDR == 32'hf000ff04) && (ahbsint.HTRANS == 2) && (ahbsint.HWRITE))
        	            begin
					 	slave_states = 1;
	                    end
        	            else
                	    begin
					 	slave_states = 6; 
	                    end	
        		end  
		end	



		7:
			begin
                        if(ahbsint.HADDR == 32'hf000ff18)
			begin
			BM_BASE   =   ahbsint.HWDATA;
			slave_states = 8;
			ahbmint.mHBUSREQ = 1;
			BM_STATUS	= 1;
			ahbsint.HRDATA = {BM_STATUS,1};
			master_states  = 0;
			end
			else
			begin
			slave_states = 7;
			end
			end




                8:
                        begin
                        if(ahbmint.mHGRANT)
                        begin
			ahbmint.mHTRANS  = 2;
		              case(nxtmaster_states)

				      0:
						begin
//						ahbmint.mHADDR  = BM_BASE + count;
						master_states   = 1;	
						ahbmint.mHWRITE = 1'b0;


							case(count)
							0:
								ahbmint.mHADDR  = BM_BASE;
							1:
								ahbmint.mHADDR  = BM_BASE + 4;
							2:
								ahbmint.mHADDR  = BM_BASE + 8;
							3:
								ahbmint.mHADDR  = BM_BASE + 12;
							4:
								ahbmint.mHADDR  = BM_BASE + 16;
							5:
								ahbmint.mHADDR  = BM_BASE + 20;
							6:
								ahbmint.mHADDR  = BM_BASE + 24;
				
							endcase	
						end	
				      1:
	   	         		        begin
	  						
                                                master_states  = 2;
		
						end			
					
                                      2:
                                                begin
						if(count < 7)
						begin
							case(count)

							0:
							begin
	                                                         DHm   = ahbmint.mHRDATA;
								countm = count + 1;
								master_states = 0;
							end

			 				1:
			       				begin					
		                                                 DLm   = ahbmint.mHRDATA;
								countm = count + 1;
								master_states = 0;
							end	

							2:
							begin
	                                                         CMDm  = ahbmint.mHRDATA;
								countm = count + 1;
								master_states = 0;
							end	
	
 							3:
							begin	
	                                                         IDm   = ahbmint.mHRDATA;
								countm = count + 1;
								master_states = 0;
							end	
							
							4:
							begin	
                                                                 mADDR = ahbmint.mHRDATA;
								countm = count + 1;
								master_states = 0;
							end	

							5:
							begin	
							 	mDATA  = ahbmint.mHRDATA;
								countm = count + 1;
								master_states = 0;
							end	
							
							6:
							begin	
	                                                         LINK  = ahbmint.mHRDATA;
								countm = 0;
								master_states = 3;
							end	
	
	                                                endcase
						 end	 
						 else
						begin	
                                                master_states  = 3;
						end	 

                                                end
			
	

	                             3:
                                                begin

                                                master_states  = 4;
	                               tranint.startXmit       = 1'b1;
        	                       tranint.quantaDiv       = CMDm[31:24];
                	               tranint.propQuanta      = CMDm[23:18];
                     		       tranint.seg1Quanta      = CMDm[17:12];
	                               tranint.xmitdata        = {DHm,DLm};
        	                       tranint.datalen         = CMDm[11:8];
                	               tranint.id              = IDm[31:3];
	                               tranint.format          = CMDm[7];
	                               tranint.frameType       = CMDm[6:5];
                                                end
	
								
				     4:
		     				begin
		                                       tranint.startXmit       = 1'b0;

							if(!tranint.busy)
							begin
								master_states   = 5;
								ahbmint.mHADDR  = mADDR;
								ahbmint.mHWDATA = mDATA;
								ahbmint.mHWRITE = 1'b1;				
							end
							else
							begin
							master_states   = 4;
							ahbmint.mHWRITE = 1'b0;				
							end

						end					

				      5:
						begin
								ahbmint.mHWRITE = 1'b0;				
                                                                if(LINK == 0)
                                                                begin
                                                                BM_STATUS = 0;
								BM_BASE   = LINK;
								ahbsint.HRDATA = {BM_STATUS,0};
                                                                slave_states   = 6;
					                        ahbmint.mHTRANS  = 0;	
                                                                end
                                                                else
                                                                begin
                                                                master_states   = 0;
                                                                BM_BASE         = LINK;
                                                                end




						end







				default: master_states = 0;
				endcase	
                        end
			else
			begin
			slave_states = 8;

			end
                        end




        default: slave_states = 0;
        endcase
        
    end

endmodule
