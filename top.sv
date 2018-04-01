// A very simple top level for the can transmitter
//
`timescale 1ns/10ps

`include "cant_idef.svh"

import cantidef::*;

`include "cant_intf.svh"
`include "ahbif.svh"

`include "tahb.svhp"

`include "canxmit.sv"

`include "ahb.sv"


module top();

import uvm_pkg::*;
import cant::*;


cantintf ci();
AHBIF ai();

initial begin
  ci.clk=0;
  ai.HCLK=0;
  repeat(2000000) begin
    #5 ci.clk=~ci.clk;
    ai.HCLK=~ai.HCLK;
  end
  $display("Used up the clocks");
  $finish;
end

initial begin
  ci.rst=0;
  ai.HRESET=0;
end

initial begin
    #0;
    uvm_config_db #(virtual cantintf)::set(null, "*", "cantintf" , ci);
    uvm_config_db #(virtual AHBIF)::set(null,"*", "AHBIF",ai);
    run_test("t1");
    $display("Test came back to me");
    #100;
    $finish;


end

initial begin
  $dumpfile("ahb.vpd");
  $dumpvars(9,top);
end


canxmit c(ci.xmit);
ahb a(ai.AHBM,ai.AHBS,ci.tox);





endmodule : top
