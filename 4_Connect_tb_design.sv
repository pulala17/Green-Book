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

// Sample4.20 Testbench using interface with clocking block
program automatic test (arb_if.TEST arbif)    
  initial begin
    arbif.cb.request <= 2'b01;
    $display ("@%0t: Drove req=01", $time);
    repeat (2) @arbif.cb;
    if (arbif.cb.grant != 2'b01)
      $display ("@%0t: grant ! = 2'b01", $time);
  end
endprogram test 
    
//Sample 4.24 Bidirectional signals in a program and interface
interface master if (input bit clk);
    wire [7:0] data; //Bidirectional signal
    clocking cb @(posedge clk);
       inout data;
    endclocking
    modport TEST (clocking cb);
endinterface
program test(master_if.TEST mif);
    initial begin
        mif.cb.data <= 'z;        // tri-state the bus
        @mif.cb;
        $displayh(mif.cb.data);   // read from the bus
        @mif.cb;
        mif.cb.data <= 7'h5a;   // drive the bus
        @mif.cb;
        mif.cb.data <= 'z;      // release the bus
    end
endprogram
  
    
/*
'always' block not allowed in a progeam
    SV programs with one or more entry points
    an 'always' block might trigger on every positive edge of a clock from the start of simulation
    When the last 'initial' block completes in the program, simulation implicitly ends as if had executed '$finish'
    if had an 'always' block, it would never stop, so have to explicitly call '$exit' to signal that the program clock completed.
*/
    
//Sample 4.26 Good clock generator in module
module clock_generator (output bit clk);
    initial
        forever #5 clk = ~clk; // Generate edges after time 0
endmodule    
    
//Sample 4.27 Top module using a simple arbiter interface
module top;
  bit clk;
  always #5 clk = ~clk;
  arb_if arbif(.*);
  arb  al (.*) ;
  test tl (.*) ;
endmodule : top    
    
    
//Sample 4.29 Module with an interface
// This will not compile without interface declaration
module uses_an_interface(arb_ifc.DUT ifc);
    initial ifc.grant = 0;
endmodule    
    
// Sample 4.30 Top module connecting DUT and interface
module top;
  bit clk;
  always #10 clk = !clk;
  arb_ifc ifc(clk);           // interface with clocking block
  uses an interface ul(ifc);  // that is needed to compile this
endmodule
 
//Sample 4.31 Top-level scope for arbiter design
// root.sv
`timescale 1ns/1ns
parameter int TIMEOUT = 1_000_000;
const string time_out_msg = "ERROR: Time out";
module top;
    test tl () ;
endmodule
program automatic test;
    initial begin
      #TIMEOUT;
      $display( "%s". time_out_msg);
      $finish;
    end
endprogram    
    
// Sample 4.32 Cross-module references with $root
`timescale 1ns/1ns
parameter TIMEOUT = 1_000_000;
    top tl(); // Explicitly instantiate top-level module
module top;
    bit clk;
    test tl(.*);
endmodule
'define TOP $root.t1
program automatic test;
    initial begin
        // Absolute reference
        $display("clk=%b", $root.tl.clk) ;
        $display("clk=%b", `TOP.clk); // With macro

        // Relative reference
        $display("clk=%b", tl.clk);
    end
endprogram    
    
------------------------------------------------------------------------
//Sample 4.33 Checking a signal with an if-statement
bus.cb.request <= 1;
repeat (2) @bus.cb;
if (bus.cb.grant 1= 2'b01)
    $display ("Error, grant ! = 1");
...  
    
//Sample 4.34 Simple immediate assertion
bus.cb.request <= 1;
repeat (2) @bus.cb;
a1: assert (bus.cb.grant == 2'b01)
...      
    
//Sample 4.36 Creating a custom error message in an immediate assertion
al: assert (bus.cb.grant == 2'b01)
else $error("Grant not asserted");    
// If grant does not have the expected value. you'll see an error message.    
    
// Sample 4.38 Creating a custom error message
al: assert (bus.cb.grant == 2'b01)
    grants_received++;           // Another succesful result
else
    $error("Grant not asserted");    
    
// Sample 4.39 Concurrent assertion to check for X/Z
interface arb_if (input bit clk);
    logic [1:0] grant, request;
    logic rst;
    property request_2state;
        @(posedge clk) disable iff (rst)
        $isunknown(request) == 0;         // Make sure no Z or X found
    endproperty
    assert_request_2state: assert property (request_2state);
endinterface    
    
--------------------------------------------------------------------------
      4-PORT ATM Router
// Sample 4.40 ATM router model header without an interface
module atm_router(
    // 4 x Level 1 Utopia ATM layer Rx Interfaces
    RX_clk_0,  RX_clk_1,  RX_clk_2,  RX_clk_3,
    RX_data_0, RX_data_1, RX_data_2, RX_data_3,
    RX_soc_0,  RX_soc_1,  RX_soc_2,  RX_soc_3,
    RX_en_0,   RX_en_1,   RX_en_2,   RX_en_3,
    RX_clav_0, RX_clav_1, RX_clav_2, RX_clav_3,
  
    // 4 x Level 1 Utopia ATM layer Tx Interfaces
    TX_clk_0,  TX_clk_1,  TX_clk_2,  TX_clk_3,
    TX_data_0, TX_data_1, TX_data_2, TX_data_3,
    TX_soc_0,  TX_soc_1,  TX_soc_2,  TX_soc_3,
    TX_en_0,   TX_en_1,   TX_en_2,   TX_en_3,
    TX_clav_0, TX_clav_1, TX_clav_2, TX_clav_3,    
    
    // Miscellaneous control interfaces
    rst, clk);

    // 4 x Level 1 Utopia ATM layer Rx Interfaces
    output     RX_clk_0,  RX_clk_1,  RX_clk_2,  RX_clk_3;
    input[7:0] RX_data_0, RX_data_1, RX_data_2, RX_data_3;
    input      RX_soc_0,  RX_soc_1,  RX_soc_2,  RX_soc_3;
    output     RX_en_0,   RX_en_1,   RX_en_2,   RX_en_3;
    input      RX_clav_0, RX_clav_1, RX_clav_2, RX_clav_3;
  
    // 4 x Level 1 Utopia Tx Interfaces
    output     TX_clk_0,  TX_clk_1,  TX_clk_2,  TX_clk_3;
    input[7:0] TX_data_0, TX_data_1, TX_data_2, TX_data_3;
    input      TX_soc_0,  TX_soc_1,  TX_soc_2,  TX_soc_3;
    output     TX_en_0,   TX_en_1,   TX_en_2,   TX_en_3;
    input      TX_clav_0, TX_clav_1, TX_clav_2, TX_clav_3;
  
    // Miscellaneous control interfaces
    input rst, clk;
    ...
endmodule    
    
// Sample 4.41 top-level netlist without an interface
module top;
  bit clk;
  always #5 clk = !clk;
  wire  RX_clk_0,  RX_clk_1,  RX_clk_2,  RX_clk_3,
        RX_soc_0,  RX_soc_1,  RX_soc_2,  RX_soc_3,
        RX_en_0,   RX_en_1,   RX_en_2,   RX_en_3,
        RX_clav_0, RX_clav_1, RX_clav_2, RX_clav_3,
        TX_clk_0,  TX_clk_1,  TX_clk_2,  TX_clk_3,
        TX_soc_0,  TX_soc_1,  TX_soc_2,  TX_soc_3,
        TX_en_0,   TX_en_1,   TX_en_2,   TX_en_3,
        TX_clav_0, TX_clav_1, TX_clav_2, TX_clav_3, rst;  
  
  wire [7:0] RX_data_0, RX_data_1, RX_data_2, RX_data_3,
             TX_data_0, TX_data_1, TX_data_2, TX_data_3;
    
  atm_router al (   RX_clk_0,  RX_clk_1,  RX_clk_2,  RX_clk_3,
                    RX_data_0, RX_data_1, RX_data_2, RX_data_3,
                    RX_soc_0,  RX_soc_1,  RX_soc_2,  RX_soc_3,
                    RX_en_0,   RX_en_1,   RX_en_2,   RX_en_3,
                    RX_clav_0, RX_clav_1, RX_clav_2, RX_clav_3,
                    TX_clk_0,  TX_clk_1,  TX_clk_2,  TX_clk_3,
                    TX_data_0, TX_data_1, TX_data_2, TX_data_3,
                    TX_soc_0,  TX_soc_1,  TX_soc_2,  TX_soc_3,
                    TX_en_0,   TX_en_1,   TX_en_2,   TX_en_3,
                    TX_clav_0, TX_clav_1, TX_clav_2, TX_clav_3, 
                 rst, clk );
  
  test        t1 (  RX_clk_0,  RX_clk_1,  RX_clk_2,  RX_clk_3,
                    RX_data_0, RX_data_1, RX_data_2, RX_data_3,
                    RX_soc_0,  RX_soc_1,  RX_soc_2,  RX_soc_3,
                    RX_en_0,   RX_en_1,   RX_en_2,   RX_en_3,
                    RX_clav_0, RX_clav_1, RX_clav_2, RX_clav_3,
                    TX_clk_0,  TX_clk_1,  TX_clk_2,  TX_clk_3,
                    TX_data_0, TX_data_1, TX_data_2, TX_data_3,
                    TX_soc_0,  TX_soc_1,  TX_soc_2,  TX_soc_3,
                    TX_en_0,   TX_en_1,   TX_en_2,   TX_en_3,
                    TX_clav_0, TX_clav_1, TX_clav_2, TX_clav_3, 
                    rst, clk );
endmodule
    
//Sample 4.43 Rx interface
// Rx interface with modports and clocking block
interface Rx_if (input logic clk);
  logic [7:0] data;
  logic soc, en, clav, rclk;
  clocking cb @(posedge clk);
    output data, soc, clav; //Directions are relative
    input en;               // to the testbench
  endclocking : cb
  modport DUT (output en, rclk,
                input data, soc, clav) ;
  modport TB (clocking cb) ;
endinterface : Rx_if    
    
// Sample 4.44 Tx interface
// Tx interface with modports and clocking block
interface Tx_if (input logic clk);
  logic [7:0] data;
  logic soc, en, clav, tclk;
  clocking cb @(posedge clk);
    input data, soc, en;
    output clavi
  endclocking : cb
  modport DUT (output data, soc, en, tclk,
                input clk, clav);
  modport TB (clocking cb);
endinterface : Tx_if    
    
//Sample 4.45 ATM router model with interface using modports
module atm_router(Rx_if.DUT Rx0, Rxl, Rx2, Rx3,
                  Tx_if.DUT Tx0, Txl, Tx2, Tx3,
                  input logie clk, rst);
  ...
endmodule    
    
//Sample 4.46 Top-level netlist with interface
module top;
  bit clk, rst;
  always #5 clk = !clk;
  Rx_if Rx0 (clk), Rxl (clk), Rx2 (clk), Rx3 (clk);
  Tx_if Tx0 (clk), Txl (clk), Tx2 (clk), Tx3 (clk);
  atm_router al (Rx0, Rxl, Rx2, Rx3,        // or just (.*)
                 Tx0, Txl, Tx2, Tx3, clk, rst);
  test       tl (Rx0, Rxl, Rx2, Rx3,       // or just (.*)
                 Tx0, Txl, Tx2, Tx3, elk, rst);
endmodule : top    
    
//Sample 4.47 Testbench using an interrace with a clocking block
program test(Rx_if.TB Rx0, Rxl, Rx2, Rx3,
             Tx_if.TB Tx0, Txl, Tx2, Tx3,
              input logic clk, output logic rst);
  
  bit [7:0] bytes[ATM_CELL_SIZE];
  
  initial begin
    // Reset the device
    rst <= 1;
    RxO.cb.data <= 0;
    ...
    receive_ceIIO() ;
    ...
  end
  
  task receive_cell0();
    @(Tx0.cb) ;
    Tx0.cb.clav <= 1;         //Assert ready to receive
    wait (Tx0.cb.soc == 1);   //Wait for Start of Cell

    for (int i=0; i<`ATM_CELL_SIZE; i++) begin
      wait (Tx0.cb.en == 0); // Wait for enable
        @(Tx0.cb);
      bytes[i] = Tx0.cb.data;
      @(Tx0.cb) ;
      Tx0.cb.clav <= 0;     // deassert flow control
    end
  endtask : receive_cell0
endprogram : test
 
//Sample 10.4 Top level module with array of interfaces
module top;
  logie clk, rst;
  Rx_if Rx[4] (clk);
  Tx_if Tx[4] (clk);
  test       t1 (Rx, Tx, rst);
  atm_router a1 (Rx[0], Rx[1], Rx[2], Rx[3] ,
                 Tx[0], Tx[1], Tx[2], Tx[3] ,
                 clk, rst);
  initial begin
    clk = 0;
    forever #20 clk = !clk;
  end
endmodule : top    
    
// Sample 10.5 Testbench using virtual interfaces
program automatic test(Rx_if.TB Rx0, Rxl, Rx2, Rx3,
                       Tx_if.TB Tx0, Txl, Tx2, Tx3,
                       output logic rst);
  Driver drv[4] ;
  Monitor mon[4];
  Scoreboard scb[4];
  virtual Rx_if.TB vRx[4] = '{Rx0, Rxl, Rx2, Rx3};
  virtual Tx_if.TB vTx[4] = '{Tx0, Txl, Tx2, TX3};
  initial begin
    foreach (scb[i]) begin
      scb[i] = new(i);
      drv[i] = new(scb[i].exp_mbx, i, vRx[i]);
      mon[i] = new(scb[i].rcv_mbx, i, vTx[i]);
    end
    ...
  end
endprogram   
// You can also skip the virtual interface array variables, and make an array in the port list.   
// Sample 10.6 Testbench using virtual interfaces
program automatic test(Rx_if.TB Rx[4], Tx_if.TB Tx[4],
                       output logic rst);
...
  initial begin
    foreach (scb[i]) begin
      scb[i] = new(i);
      drv[i] = new(scb[i].exp_mbx, i, Rx[i]);
      mon[i] = new(scb[i].rcv_mbx, i, Tx[i]);
    end
  end
endprogram   
    
// Sample 10.7 Driver class using virtual interfaces
class Driver;
  int stream_id;
  bit done = 0;
  mailbox exp_mbx;
  virtual Rx_if.TB Rx;
  
  function new (input mailbox exp_mbx,
                input int     stream_id,
                input virtual Rx_if.TB Rx);
    this.exp_mbx = exp_mbx;
    this.stream_id = stream_id;
    this.Rx = Rx;
  endfunction
  
  task run (input int ncells, input event driver done) ;
    ATM_Cell ac;
    fork // Spawn this as a separate thread
      begin
        // Initialize output signals
        Rx.cb.clav <= 0;
        Rx.cb.soc  <= 0;
        @Rx.cb;
        
        // Drive cells until the last one is sent
        repeat (ncells) begin
          ac = new
          assert (ac.randomize) ;
          if (ac.eot_cell) break; // End transmission
              drive_cell (ac) ;
        end
        $display("@%0t: Driver::run Driver [%0d] is done", $time, stream_id);
        -> driver done;
      end
    join_none
  endtask : run
  
  task drive_cell (input ATM Cell ac);
    bit [7:0] bytes[];
    #ac.delay;
    ac.byte_pack(bytes) ;
    $display("@%0t: Driver::drive cell(%0d) vci=%h",
                $time, stream_id, ac.vci);
    // Wait to start on a new cycle
    @Rx.cb;
    Rx.cb.clav <= 1;      // assert ready to xfr
    do
      @Rx.cb;
    while (Rx.cb.en != 0)
    
    Rx.cb.soc <= 1;           // start of cell
    Rx.cb.data <= bytes[0];   // drive first byte
    @Rx.cb;
    Rx.cb.soc <= 0;           // start of cell done
    Rx.cb.data <= bytes[1];   // drive first byte
    for (int i=2; i<`ATM_SIZE; i++) begin
      @Rx.cb;
      Rx.cb.data <= bytes[i];
    end
    
    @Rx.cb;
    Rx.cb.soc <= l'bz;   // tristate SOC at end
    Rx.cb.clav <= 0;
    Rx.cb.data <= 8'bz;  // Clear data lines
    $display("@%0t: Driver::drive cell(%0d) finish", $time, stream_id);
    
    // Send cell to scoreboard
    exp_mbx.put(ac) ;
  endtask : drive_cell_t
endclass : Driver   
    
-------------------------------------------------    
// Sample 4.48 A final block
program test;
  int errors, warnings;
  initial begin
      ... // Main program activity
  end
  final
      $display("Test done with %Od errors and %Od warnings", errors, warnings);
endprogram    
    
------------------------------------------------------------------------------------    
    LC3 Fetch Block
    
 // Sample 4.49 Fetch block Verilog code
module fetch(clock, reset, state, pc, npc, rd,
              taddr, br_taken);
  input clock, reset, br_taken;
  input [15:0] taddr;
  input [3:0] state;
  output [15:0] pc, npc; // current and next PC
  output rd;
  // protected code omitted
endmodule  
    
// Sample 4.50 Fetch block interface
interface fetch_ifc(input bit clock);
    logic reset, br_taken, rd;
    logic [15:0] taddr;
    cntrl_e      state;  //Defined in Sample 4.52
    logic [15:0] pc, npc; //current and next PC
  
    clocking cb @(posedge clock);
        input pc, npc, rd;
        output taddr, state, br_taken, reset;
    endclocking // cb
  
    modport TEST (clocking cb, output reset);
      
    modport DUT ( input clock, reset, br_taken, taddr, state,
                  output pc, npc, rd);
      
    // For monitoring DUT signals
    clocking cbm @(posedge clock);
        input pc, npc, rd, taddr, state, br taken;
    endclocking // cbm
      
    modport MONITOR (clocking cbm) ;
endinterface II fetch ifc    
    
//  Sample 4.51 Fetch block directed test
program automatic test(fetch_ifc.TEST if_t,
                       fetch_ifc.MONITOR if_m);
  initial begin
    cntrl_e cntrl;
    $timeformat(-9, 0, "ns", 5);
    $monitor("%t: pc=%h npc=%h rd=%b state=%s",
              $realtime, if_m.cbm.pc, if_m.cbm.npc,
              if_m.cbm.rd, if_m.cbm.state.name);
    $display("%t: Reset all signals", $realtime);
    if_t.reset <= 1;
    if_t.cb.taddr <= 16'hFFFC;
    if_t.cb.br taken <= 0;
    if_t.cb.state <= CNTRL_UPDATE_PC;
    
    repeat (2) @if_t.cb;
    pc_post_reset: assert (if_t.cb.pc == 16'h3000);
    
    ##1 if_t.cb.reset <= 0; // Synchronously deassert reset
    
    @ (if_t.cb) ;
    $display("\n%t: Test loading of target address", $realtime) ;
    if_t.cb.state <= CNTRL_UPDATE_PC;
    if_t.cb.br_taken <= 1;
    
    @(if_t.cb) ;
    @(if_t.cb) ;
    pc_br_taken: assert (if_t.cb.pc == 16'hFFFC);
    $display("%t: Did the PC rollover as expected?", $realtime) ;
    if_t.cb.br_taken <= 0;
    if t.cb.state <= CNTRL_UPDATE_PC;
    repeat (5) @(if_t.cb);
    pc_rollover: assert (if_t.cb.pc == 16'h0000);
    
    $display("\n%t: Step through all the controller states", $realtime);
    for (int i=CNTRL_FETCH; i<=CNTRL_COMPUTE_MEM; i++)
      begin
      $cast(cntrl, i);
      if (cntrl == CNTRL_UPDATE_PC)  continue;
      $display("%t: Try with controller state=%Od %s",
                $realtime, cntrl, cntrl.name);
      if_t.cb.br_taken <= 0;
      if_t.cb.state <= cntrl;
        repeat (2) @(if_t.cb);
        pc_no_load: assert (if_t.cb.pc == 16'h0001);
     end // for i

    $display("\n%t: Tristate on PC output", $realtime);
    if_t.cb.state <= CNTRL_READ_MEM;
    @(if_t.cb);
    pc_z_read_mem: assert (if_t.cb.pc === 16'hzzzz);
    
    if_t.cb.state <= CNTRL_IND_ADDR_RD;
    @(if_t.cb) ;
    pc_z_ind_addr_rd: assert (if_t.cb.pc === 16'hzzzz);
    
    if_t.cb.state <= CNTRL_WRITE_MEM;
    @(if_t.cb) ;
    pc_z_write_mem: assert (if_t.cb.pc === 16'hzzzz);
  end
endprogram // test

//Sample 4.52 Top level block for fetch testbench
`timescale 1ns/1ns
typedef enum  { CNTRL_UPDATE_PC   = 0,
                CNTRL_FETCH       = 1,
                CNTRL_DECODE      = 2,
                CNTRL_EXECUTE     = 3,
                CNTRL_UPDATE_REGF = 4,
                CNTRL_COMPUTE_PC  = 5,
                CNTRL_COMPUTE_MEN = 6,
                CNTRL_READ_MEN    = 7,
                CNTRL_IND_ADDR_RD = 8,
                CNTRL_WRITE_MEN   = 9}  cntrl_e;
module top;
  bit clock;
  always #10 clock = ~clock;
  fetch_ifc fif(clock);
  test  t1 (fif, fif);
  fetch f1 ( clock, fif.reset, fif.state, fif.pc,
            fif.npc, fif.rd, fif.taddr, fif.br_taken);
endmodule //top
