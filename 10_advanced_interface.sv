
//Sample 10.8 Test harness using an interface in the port list
module top;
  bus ifc bus(); //Instantiate the interface
  test tl(bus);  //Pass to test through port list
  dut  dl(bus);  //Pass to DUT through port list
  ...
endmodule

//Sample 10.9 Test with an interface in the port list
program automatic test(bus_ifc bus);
  initial $display(bus.data); // Use an interface signal
endprogram

//Sample 10.10 Top module with a second interface in the test's port list
module top;
  bus_ifc bus ();     //Instantiate the interface
  new_ifc newb();     //and a new one
  test tl(bus, newb); //Test with two interfaces
  dut  dl(bus, newb); //DUT with two interfaces
endmodule

// Sample 10.11 Test with two interfaces in the port list
program automatic test(bus_ifc bus, new_ifc newb);
  initial $display(bus.data); // Use an interface signal
endprogram

//Sample 10.12 Test with virtual interface and XMR
program automatic test();
  virtual bus_ifc bus = top.bus; // Cross module reference
  initial $display(bus.data);    // Use an interface signal
endprogram

// Sample 10.13 Test harness without interfaces in the port list
module top;
  bus_ifc bus() ;   //Instantiate the interface
  test tl() ;       //Don't use port list for test
  dut dl(bus) ;     //Still use port list for DUT
endmodule

//Sample 10.14 Test harness with a second interface
module top;
  bus_ifc bus();      // instantiate the interface
  new_ifc newb () ;   // and a new one
  test tl () ;        // instantiation remains the same
  dut dl(bus, newb);
  ...
endmodule

// Sample 10.15 Test with two virtual interfaces and XMRs
program automatic test();
  virtual bus_ifc bus = top.bus;
  virtual new_ifc newb = top.newb;
  initial begin
    $display(bus.data);  // Use existing interface
    $display(newb.addr); // and new one
  end
endprogram

------------------------------------------------------------------------
Connecting to Multiple Design Configurations

//Sample 10.16 Interface for 8-bit counter 
interface X_if (input logie elk); 
  logic [7:0] din, dout; 
  logic reset_1, load;
  
  clocking cb @(posedge clk); 
    output din, load; 
    input dout; 
  endclocking 
  always @cb 
    $strobe ("@%0t: %m: out=%0d, in=%0d, 1d=%0d, r=%0d", 
              $time, dout, din, load, reset_1); 
  modport DUT (input clk, din, reset_1, load, 
                output dout); 
  modport TB (clocking cb, output reset_1); 
endinterface

//Sample 10.17 Counter model using X_if interface 
// Simple a-bit counter with load and active-low reset 
module dut(X_if.DUT xi); 
  logic [7:0] count; 
  assign xi.dout = count; 
  always @(posedge xi.clk or negedge xi.reset_l) 
    begin 
      if (!xi.reset_l)  count <= 0; 
      else if (xi.load) count <= xi.din; 
      else              count <= count+1;
    end 
endmodule 

// Sample 10.18 Testbench using an array of virtual interfaces 
parameter NUM_XI = 2; // Number of design instances 
    
module top; 
  // Clock generator 
  bit clk; 
  initial begin 
    clk <= '0; 
    forever #20 clk = ~ clk;
  end 

  // Instantiate N interfaces 
  X_if xi[NUM_XI] (clk); 
  
  // Instantiate the testbench 
  test tb () ; 
  // Generate N DUT instances 
  generate 
    for (genvar i=0; i<NUM_XI; i++) 
      begin : dut_blk 
        dut d (xi[i]); 
      end 
  endgenerate 
endmodule : top

// Sample 10,19 Counter testbench using virtual interfaces 
program automatic test; 
  virtual X_if.TB vxi[NUM_XI]; // Virtual interface array 
  Driver driver[]; 
  
  initial begin 
    // Connect local virtual interface to top 
    vxi = top.xi; 
    // Create N drivers 
    driver = new[NUM_XI] ; 
    foreach (driver[i]) 
      driver[i] = new(vxi[i], i); 
    foreach (driver[i]) begin 
      int j = i 
      fork 
        begin 
          driver[j].reset(); 
          driver[j].load_op(); 
        end 
      join_none 
    end
      
    repeat (10) @(vxi[0].cb); 
  end 
endprogram
    
// Sample 10.20 Driver class using virtual interfaces 
// the Driver class uses a single virtual interface to drive and sample signals from the counter.    
class Driver; 
  virtual X_if xi; 
  int id; 
  
  function new(input virtual X_if.TB xi, input int id); 
    this.xi = xi; 
    this.id = id; 
  endfunction 
  
  task reset(); 
    $display ("@%0t: %m: Start reset [%0d]", $time, id); 
    // Reset the device 
    xi.reset_1 <= 1; 
    xi.cb.load <= 0; 
    xi.cb.din  <= 0; 
    @(xi.cb) xi.reset_1 <= 0; 
    @(xi.cb) xi.reset_1 <= 1; 
    $display("@%0t: %m: End reset [%0d] ", $time, id); 
  endtask : reset 
  
  task load_op(); 
    $display("@%0t: %m: Start load [%0d]", $time, id); 
    ##1 xi.cb.load <= 1; 
    xi.cb.din <= id + 10; 
    ##1 xi.cb.load <= 0; 
    repeat(5) @(xi.cb); 
    $display("@%0t: %m: End load [%0d]", $time, id); 
  endtask : load_op 
endclass : Driver    

------------------------->    
// can reduce the amount of typing and ensure you always use the correct modport by replacing "virtual X_if.TB" with a typedef. 
// Sample 10.21 Testbench using a typedef for virtual interfaces 
typedef virtual X_if.TB vx_if; 
    
program automatic test; 
  vx_if vxi[NUM_XI]; // Virtual interface array
  Driver driver[]; 
  ...
endprogram 

// Sample 10.22 Driver using a typedef for virtual interfaces 
class Driver; 
  vx_if xi; 
  int id; 
  function new(input vx_if xi, input int id); 
    this.xi = xi; 
    this.id = id; 
  endfunction 
  ...
endclass : Driver   
    
//Sample 10.23 Testbench using an array ofvirtual interfaces 
//uses a global parameter to define the number of X interfaces
parameter NUM_XI = 2; // Number of instances 
    
module top; 
  // Instantiate N interfaces 
  X_if xi [NUM_XI] (clk); 
  ...
  // Instantiate the testbench 
  test tb(xi); 
endmodule : top    
    
//Sample 10.24 Testbench passing virtual interfaces with a port 
program automatic test(X_if xi [NOM_XI]); 
  Driver driver[]; 
  virtual X_if vxi[NUM_XI]; 
  
  initial begin 
    // Connect the local virtual interfaces to the top 
    if (NUM_XI <= 0) $finish; 
    
    driver = new[NUM_XI] ; 
    vxi = xi; //Assign the interface array 
    for (int i=0; i<NUM_XI; i++) begin 
      driver[i] = new(vxi[i], i); 
      driver[i].reset; 
    end 
    ...
  end 
endprogram    
    
-----------------------------------------------------
 Procedural Code in an Interface
/* an interface can contain code such as routines, assertions, and initial and always blocks.    
 the interface block for a bus can contain the signals and also routines to perform commands such as a read or write.   
 
 Access to these routines is controlled using the 'modport' statement, 
  just as with signals. 
 A task or function is imported into a modport 
  so that it is then visible to any block that uses the 'modport'.   
 */
    
// Sample 10.25 Interface with tasks for parallel protocol 
interface simple_if(input logic clk); 
  logic [7:0] addr; 
  logic [7:0] data; 
  bus_cmd_e cmd; 
  modport TARGET 
    (input addr, cmd, data, 
     import task targetRcv (output bus_cmd_e c, 
                             logic [7: 0] a, d)  ); 
  modport INITIATOR 
    (output addr, cmd, data, 
     import task initiatorSend(input bus_cmd_e c, 
                               logic [7: 0] a, d) ) ; 
  // Parallel send 
  task initiatorSend(input bus_cmd_e c,  logic [7: 0] a, d) ; 
    @(posedge clk); 
    cmd  <= c; 
    addr <= a; 
    data <= d; 
  endtask 
     
  // Parallel receive 
  task targetRcv(output bus_cmd_e c, logic [7:0] a, d); 
     @ (posedge clk); 
     a = addr; 
     d = data; 
     c = cmd; 
  endtask 
endinterface: simple_if    

//Sample 10.26 Interface with tasks for serial protocol 
interface simple_if(input logic clk); 
  logic addr; 
  logic data; 
  logic start = 0; 
  bus_cmd_e cmd; 
  
  modport TARGET(input addr, cmd, data, 
                 import task targetRcv (output bus_cmd_e c, 
                                        logic [7:0] a, d)  ); 
  modport INITIATOR(output addr, cmd, data, 
                    import task initiatorSend(input bus_cmd_e c, 
                                              logic [7:0] a, d) ); 
  // Serial send
  task initiatorSend(input bus_cmd_e c, logic [7:0] a, d); 
    @(posedge clk); 
    start <= 1; 
    cmd <= c; 
    foreach (a[i]) begin 
      addr <= a[i]; 
      data <= d[i]; 
      @(posedge clk); 
      start <= 0; 
    end 
    cmd <= IDLE; 
  endtask 
                    
  // Serial receive 
  task targetRcv(output bus_cmd_e c, logic [7:0] a, d); 
    @(posedge start); 
    c = cmd; 
    foreach (a[i]) begin 
      @(posedge clk); 
      a[i] = addr; 
      d[i] = data; 
    end 
  endtask 
endinterface: simple_if



