// Sample4.1 arbiter model using ports
module arb_port (output logic [1: 0] grant,
                  input logic [1: 0] request,
                  input logic rst,
                  input logic clk) ;
  ...
  always @(posedge clk or posedge rst) begin
    if (rst)   grant <= 2'bOO;
    else  ...
  end
endmodule
      
// Sample 4.2 Testbench using ports
module test ( input logic [1: 0] grant,
              output logic [1: 0] request,
              output logic rst,
               input logic clk);
  initial begin
    @(posedge clk) request <= 2'b01;
    $display("@%0t: Drove req=0l", $time);
    repeat(2) @(posedge elk);
    if (grant != 2'b01)
        $display("@%Ot: a1: grant 1= 2'b01", $time);
    ...
    $finish;
  end
endmodule
    
// Sample 4.3 Top-level netlist without an interface
module top;
  logic [1:0] grant, request;
  bit   clk, rst;
  always #5 clk = ~clk;
  arb_port a1 (grant, request, rst, clk);
  test     t1 (grant, request, rst, clk);
endmodule
    
------------------------------------------------------------
    
//Sample 4.4 Simple interface for arbiter
interface arb_if (input bit clk);
  logic [1:0] grant, request;
  logic rst;
endinterface    
    
// Sample 4.5 Arbiter using a simple interface
module arb (arb_if arbif);
  always @(posedge arbif.clk or posedge arbif.rst) begin
    if (arbif. rst)
      arbif.grant <= 2'b00;
    else
      arbif.grant <= next_grant;
    ...
  end
endmodule    
    
//Sample 4.6 Testbench using a simple arbiter interface
module test (arb_if arbif);
  ...
  initial begin
    //reset code left out
    @(posedge arbif.c1k);
    arbif.request <= 2'b01;
    $display("@%0t: Drove req=01", $time);
    repeat (2) @(posedge arbif.c1k);
    if (arbif.grant ! = 2'b01)
      $disp1ay("@%0t: al: grant != 2'b01", $time);
    $finish;
  end
endmodule : test    
    
//Sample 4.7 Top module using a simple arbiter interface
module top;
  bit clk;
  always #5 clk = ~clk;
  arb_if arbif(c1k);
  arb al (arbif);
  test tl (arbif) ;
endmodu1e : top
 
// if want to put a new signal in an interface,
//      just add it to the interface definition and the modules that actually used it
//      not have to change any modules such as 'top' that just pass the interface through
  
 ---------------------------------------------------------------------   
// Sample4.9 connecting an interface to a module that uses portrs
  module top;
    bit clk;
    always #5 clk = ~clk;
    arb_if arbif(clk);
    arb_port al ( .grant   (arbif.grant),
                  .request (arbif.request),
                  .rst     (arbif.rst),
                  .clk     (arbif.clk)            );
    test t1(arbif);
  endmodule:top
  
  ---------------------------------------------------------------------     
 // Sample 4.10 Interface with modports
interface arb if (input bit elk);
  logic [1:0] grant, request;
  logic rst;
  modport TEST (output request, rst,
                input grant, elk);
  modport DUT (input request, rst, elk,
               output grant);
  modport MONITOR (input request, grant, rst, elk);
endinterfaee  
    
//Sample 4.11 Arbiter model with interface using modports
module arb (arb_if.DUT arbif);
  ...
endmodule
//Sample 4.12 Testbench with interface using modports
module test (arb_if.TEST arbif);
  ...
endmodule    
    
  ---------------------------------------------------------------------     
// Sample 4.13 Arbiter model with interface using modports
  module monitor (arb_if.MONITOR arbif);
    always @(posedge arbif.request[0]) begin
      $display("@%0t: request [0] asserted", $time);
      @(posedge arbif.grant[0]);
      $display("@%0t: grant [0) asserted", $time);
  end
  always @(posedge arbif.request[l]) begin
    $display("@%0t: request [1) asserted", $time);
    @(posedge arbif.grant[l]);
    $display("@%0t: grant [1) asserted", $time);
  end
endmodule    
    
/*
The advantages to using an interface are as follows.
• An interface is ideal for design reuse. 
  When two blocks communicate with a specified protocol using more than two signals, consider using an interface.
  If groups of signals are repeated over and over, as in a networking switch, you should additionally use virtual interfaces.
• The interface takes the jumble of signals that you declare over and over in every module or program 
  and puts it in a central location, reducing the possibility of misconnecting signals.
• To add a new signal, you just have to declare it once in the interface, 
  not in higher-level modules, once again reducing errors.
• Modports allow a module to easily tap a subset of signals from an interface.
  You can specify signal direction for additional checking.    
    
The disadvantages of using an interface are as follows.
• For point-to-point connections, 
  interfaces with modports are almost as verbose as using ports with lists of signals. 
  Interfaces have the advantage that all the declarations are still in one central location, 
  reducing the chance for making an error.
• You must now use the interface name in addition to the signal name, 
  possibly making the modules more verbose.
• If you are connecting two design blocks with a unique protocol that will not be reused, 
  interfaces may be more work than just wiring together the ports.
• It is difficult to connect two different interfaces. 
  A new interface (bus_if) may contain all the signals of an existing one (arb_if), 
  plus new signals (address, data, etc.). 
  You may have to break out the individual signals and drive them appropriately.    
 
 */
// Sample 4.14 Interrace with a clocking block
interface arb_if(input bit clk);
  logic [1:0] grant, request;
  logic rst;
  
  clocking cb @(posedge clk);  // declare cb
      output request;
      input grant;
  endclocking
  
  modport TEST (clocking cb,  // use cb
                output rst);
  modport DUT (input request, rst, output grant);
endinterface
    
  // Trivial test, see Sample 4.20 for a better one
module test(arb_if.TEST arbif);
  initial begin
    arbif.cb.request <= 0;
    @arbif.cb;
    $display("@%0t: Grant = %b", $time, arbif.cb.grant);
  end
endmodule

//Sample 4.15 Interface with a clocking block
interface asynch_if();
    logic 1;
    wire w;
endinterface
module test(asynch_if ifc);
  logic local_wire;
  assign ifc.w <= local_wire;
  initial begin
    ifc.l <= 0;      // Drive asych logic directly ...
    local wire <= 1; // but drive wire through assign
  end
endmodule   

// Sample 4.17 Testbench using interface with clocking block
program automatic test (arb_if.TEST arbif);
  ...
  initial begin
    arbif.cb.request <= 2'b01;
    $display("@%0t: Drove req=01", $time);
    repeat (2) @arbif.cb;
    if (arbif.cb.grant != 2'b01)
      $display("@%0t: al: grant != 2'b01", $time);
    end
    ...
  end
endprogram : test    
    
//Sample 4.18 Signal synchronization
program automatic test(bus_if.TB bus);
  initial begin
    @bus.cb;                  // continue on active edge in clocking block
    repeat(3) @bus.cb;       // wait for 3 active edge
    @bus.cb.grant;            // continue on any edge
    @(posedge bus.cb.grant);  // continue on posedge
    @(negedge bus.cb.grant);  // continue on negedge
    wait (bus.cb.grant==l);   // wait for expression, no delay is already true
    @(posedge bus.cb.grant or
      negedge bus.rst);       // wait for several signals
  end
endprogram

// Sample 4.19 Synchronous interface sample and drive from module
'timescale 1ns/1ns
program test(arb_if.TEST arbif);
  initial begin
    $monitor("@%0t: grant=%h", $time, arbif.cb.grant);
    #50ns $display("End of test");
  end
endprogram
    
module arb(arb_if.DUT arbif);
  initial begin
    #7  arbif.grant = 1; // @ 7ns
    #10 arbif.grant = 2; // @ 17ns
    #8  arbif.grant = 3; // @ 25ns
  end
endmodule    
// The arb module drives grant to 1 and 2 in the middle of a cycle, and then to 3 exactly at the clock edge.    
    
    
    
    
    
