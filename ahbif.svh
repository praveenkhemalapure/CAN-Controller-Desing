// This is an interface module for the AHB design problem
// Note, the can xmitter has both a master and a slave interface.
// In the interfaces, the master signals are prefixed with a lower
// case 'm' for clarity. The muxing occurs in the test bench
//

interface AHBIF;
    logic mHBUSREQ,mHGRANT,HREADY,mHREADY;
    logic [1:0] HRESP,mHRESP;   // Basically not used, always words.
    logic HRESET;
    logic HCLK;
    logic [31:0] HRDATA,mHRDATA;
    logic [31:0] HWDATA,mHWDATA;
    logic HLOCK;                // Not used
    logic [1:0] HTRANS,mHTRANS;
    logic [31:0] HADDR,mHADDR;
    logic HWRITE,mHWRITE;
    logic [2:0] HSIZE,mHSIZE;
    logic [2:0] HBURST,mHBURST;
    logic [3:0] HPROT;          // Not used
    logic HSEL;                 // slave select
    logic [3:0] HMASTER;        // Not used
    logic HMASTLOCK;            // not used


    
    clocking cb @(posedge(HCLK));
       
    endclocking : cb

    modport AHBM( input HCLK, input HRESET,
        input mHGRANT, output mHBUSREQ, 
        input mHREADY,input mHRESP, output HPROT,
        input mHRDATA,output mHTRANS, output mHADDR,
        output mHWRITE, output mHWDATA, output mHSIZE, output mHBURST);
    
    modport AHBS( input HCLK, input HRESET,
        input HSEL, input HADDR,
        input HWRITE, input HTRANS,
        input HSIZE, input HBURST, input HWDATA, 
        output HREADY,
        output HRESP, output HRDATA);
        
        
endinterface : AHBIF


