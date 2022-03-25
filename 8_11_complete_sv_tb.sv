/* 
This is structured according to the guidelines from Chap.8
The entire example with the testbench and ATM switch is available for download at 
http://chris.spear.net/systemverilog. 
This chapter shows just the testbench code.

The design is an ATM switch that was shown in S. (2006). 
who based his System Verilog description on an example from Janick Bergeron's Verification Guild. 
S took the original Verilog design and used SystcmVerilog design features 
to create a switch that can be configured from 4 x 4 to 16 x 16. 
The testbcnch in the original example creates ATM cells using $urandom. 
overwrites certain fields with ID valucs. 
sends them through the device. 
and then checks that the same values were received.
*/

//Sample 11.1 Top level module 
`timesca1e 1ns/1ns 
`define TxPorts 4 // set number of transmit ports 
`define RxPorts 4 // set number of receive ports 
module top; 
  parameter int NumRx = `RxPorts; 
  parameter int NumTx = `TxPorts; 
  logic rst, c1k;  
  // System Clock and Reset 
  initial begin 
    rst = 0; clk = 0; 
    #5ns rst = 1; 
    #5ns c1k = 1; 
    #5ns rst = 0; c1k = 0; 
    forever 
      #5ns c1k = ~c1k; 
end 

  Utopia Rx[0:NumRx-1] (); //NumRx x Levell Utopia Rx Interface 
  Utopia Tx[0:NumTx-1] (); //NumTx x Levell Utopia Tx Interface 
  cpu_ifc mif();           //Utopia management interface 
  squat # (NumRx, NumTx) squat (Rx, Tx, mif, rst, c1k); // DUT 
  test  # (NumRx, NumTx) tl(Rx, Tx, mif, rst, c1k);     // Test 
endmodu1e : top
  
// The testbench program in Sample 11.2 passes the interfaces and signals through the port list. 
//  See Section 10.1.4 for a discussion on posts vs. cross module references. 
//  The actual testbench code is in the Environment class. 
//  The program steps through the phases of the environment.  
  
// Sample 11.2 Testbench program 
program automatic test 
  #(parameter int NumRx = 4, parameter int NumTx = 4) 
  (Utopia.TB_Rx Rx[0:NumRx-1], 
   Utopia.TB_Tx Tx[0:NumTx-1] , 
   cpu_ifc.Test mif, 
   input logic rst, c1k); 
  `include "environment.sv" 
    Environment env; 
    initial begin 
      env = new (Rx, Tx, NumRx, NumTx, mif); 
      env.gen_cfg() ; 
      env.bui1d () ; 
      env.run() ; 
      env.wrap_up() ; 
    end 
endprogram // test  
  
//Sample 11.3 CPU Management Interface 
interface cpu ifc; 
  logic BusMode, Se1, Rd_DS, Wr_RW, Rdy_Dtack; 
  logic [11:0] Addr; 
  Ce11CfgType Dataln, DataOut; // Defined in Sample 11.11 
  modport Peripheral 
          (input Bus Mode , Addr, Se1, Dataln, Rd_DS, Wr RW, 
           output DataOut, Rdy_Dtack); 
  modport Test 
          (output BusMode, Addr, Se1, Dataln, Rd_DS, Wr RW, 
           input DataOut, Rdy_Dtack); 
endinterface : cpu_ifc 
typedef virtual cpu_ifc.Test vCPU_T;  
  
//Sample 11.4 Utopia interface 
interface Utopia; 
  parameter int IfWidth = 8; 
  
  logic [IfWidth-1:0] data; 
  bit clk_in, clk_out; 
  bit soc, en, clav, valid, ready, reset, selected; 
  ATMCellType ATMcell; // union of structures for ATM cells 
  
  modport TopReceive ( 
      input data, soc, clav, 
      output clk_in, reset, ready, clk_out, en, ATMcell, valid); 
  
  modport TopTransmit 
      input clav, 
      inout selected, 
      output clk_in, clk_out, ATMcell, data, soc, en, valid, reset, ready); 
  
  modport CoreReceive 
      input clk_in, data, soc, clav, ready, reset, 
      output clk_out, en, ATMcell, valid); 
  
  modport CoreTransmit ( 
      input clk_in, clav, ATMcell, valid, reset, 
      output clk_out, data, soc, en, ready ); 
  
  clocking cbr @(negedge clk_out); 
      input clk_in, clk_out, ATMcell, valid, reset, en, ready; 
      output data, soc, clavi ;
  endclocking : cbr 
  modport TB_Rx (clocking cbr) ; 
    
  clocking cbt @(negedge clk_out); 
      input clk_out, clk_in, ATMcell, soc, en, valid, reset, data, ready; 
      output clavi ;
  endclocking : cbt 
  modport TB_Tx (clocking cbt); 
endinterface 
  
typedef virtual Utopia vUtopia; 
typedef virtual Utopia.TB_Rx vUtopiaRx; 
typedef virtual Utopia.TB_Tx vUtopiaTx;  
  
// Sample 11.5 Environment class header 
class Environment; 
  UNI_generator gen[] ; 
  mailbox gen2drv[]; 
  event   drv2gen[] ; 
  Driver drv[] ; 
  Monitor mon[]; 
  Config cfg; 
  Scoreboard scb; 
  Coverage cov; 
  virtual Utopia.TB_Rx Rx[]; 
  virtual Utopia.TB_Tx Tx[]; 
  int numRx, numTx; 
  vCPU_T mif; 
  CPU_driver cpu; 
  extern function new(input vUtopiaRx Rx[], 
                      input vUtopiaTx Tx[], 
                      input int numRx, numTx, 
                      input vCPU_T mif) ; 
  extern virtual function void gen_cfg(); 
  extern virtual function void build() ; 
  extern virtual task run(); 
  extern virtual function void wrap_up(); 
endclass : Environment  
  
// Sample 11.6 Environment class methods 
//--------------------------->
// Construct an environment instance 
function Environment::new(input vUtopiaRx Rx[], 
                          input vUtopiaTx Tx[], 
                          input int numRx, numTx, 
                          input vCPU_T mif); 
  this.Rx new[Rx.size()]; 
  foreach (Rx[i])  this.Rx[i] = Rx[i];
  this.Tx = new[Tx.size()]; 
  foreach (Tx[i]   this.Tx[i] = Tx[i] ;
  this.numRx = numRx; 
  this.numTx = numTx; 
  this.mif = mif; 
  cfg = new(NumRx,NumTx); 

  if ($test$plusargs("ntb random_seed")) begin 
    int seed; 
    $value$plusargs("ntb random_seed=%d", seed); 
    $display("Simulation run with random seed=%0d", seed); 
  end 
  else 
    $display("Simulation run with default random seed"); 
  endfunction : new 
//--------------------------->
// Randomize the configuration descriptor 
function void Environment::gen_cfg(); 
  assert(cfg.randomize(» ; 
  cfg.display() ; 
endfunction : gen_cfg 
//---------------------------->
// Build the environment objects for this test 
// Note that objects are built for every channel, 
// even if they are not used. This reduces null handle bugs. 
function void Environment::build(); 
  cpu = new(mif, cfg); 
  gen = new [numRx] ; 
  dry = new [numRx] ; 
  gen2drv = new [numRx] ; 
  drv2gen = new [numRx] ; 
  scb = new(cfg) ; 
  cov = new(); 
  
  // Build generators 
  foreach(gen[i]) begin 
    gen2drv[i] = new(); 
    gen[i] = new(gen2drv[i], drv2gen[i], 
                 cfg.cells-per_chan[i], i); 
    dry[i] = new(gen2drv[i], drv2gen[i], Rx[i], i); 
  end 
  
  // Build monitors 
  mon = new [numTx] ; 
  foreach (mon[i]) 
    mon[i] = new (Tx[i], i); 
  
  // Connect scoreboard to drivers & monitors with callbacks 
  begin 
    Scb_Driver_cbs sdc = new(scb); 
    Scb_Monitor_cbs smc = new(scb); 
    foreach (drv[i]) drv[i].cbsq.push_back(sdc); 
    foreach (mon[i]) mon[i].cbsq.push_back(smc); 
  end 
  
  // Connect coverage to monitor with callbacks 
  begin 
    Cov_Monitor_cbs smc = new (cov) ; 
    foreach (mon[i]) 
      mon[i].cbsq.push_back(smc); 
  end 
endfunction : build 
//------------------------->
// Start the transactors: generators, drivers, monitors 
// Channels that are not in use don't get started 
task Environment::run(); 
  int num_gen_running; 
  // The CPU interface initializes before anyone else 
  cpu.run(); 
  
  num_gen_running = numRx; 
  
  // For each input RX channel, start generator and driver 
  foreach(gen[i]) begin 
    int j=i; // Automatic var holds index in spawned threads 
    fork 
      begin 
        if (cfg.in_use_Rx[j]) 
          gen[j].run() ; // Wait for generator to finish 
        num_gen_running--;  // Decrement driver count 
      end 
      if (cfg.in_use_Rx[j]) drv[j].run(); 
    join_none 
  end 

  // For each output TX channel, start monitor 
  foreach(mon[i]) begin 
    int j=i; // Automatic var holds index in spawned threads 
    fork 
      mon[j].run(); 
    join_none 
  end 
  
  // Wait for all generators to finish, or time-out 
  fork : timeout block 
    wait (num_gen_running == 0); 
    begin 
      repeat (1_000_000) @(Rx[0].cbr); 
      $display("@%0t: %m ERROR: Generator timeout", $time); 
      cfg.nErrors++; 
    end 
  join_any 
  disable timeout_block; 
  // Wait for the data to flow through switch, into monitors, and scoreboards 
  repeat (1_000) @(Rx[0] .cbr); 
endtask : run 
//---------------------->
// Post-run cleanup / reporting 
function void Environment::wrap_up(); 
  $display("@%0t: End of sim, %0d errors, %0d warnings", 
            $time, cfg.nErrors, cfg.nWarnings); 
  scb.wrap_up; 
endfunction : wrap_up 
