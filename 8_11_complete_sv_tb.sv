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
                       
// Sample 11.7 Callback class connects driver and scoreboard 
class Scb_Driver_cbs extends Driver_cbs; 
  Scoreboard scb; 
  function new (input Scoreboard scb); 
    this.scb = scb; 
  endfunction : new 
  // Send received cell to scoreboard 
  virtual task post_tx( input Driver drv, 
                        input UNI_cell cell); 
     scb.save_expected(cell); 
  endtask : post_tx 
endclass : Scb_Driver_cbs                       
                       
// Sample 11.8 Callback class connects monitor and scoreboard 
class Scb_Monitor_cbs extends Monitor_cbs; 
  Scoreboard scb; 
  function new (input Scoreboard scb); 
    this.scb = scb; 
  endfunction : new 
  // Send received cell to scoreboard 
  virtual task post_rx( input Monitor mon, 
                        input NNI_cell cell); 
    scb.check_actual(cell, mon.PortID); 
  endtask : post_rx 
endclass : Scb_Monitor_cbs                       
                       
//Sample 11.9 Callback class connects the monitor and coverage 
class Cov_Monitor_cbs extends Monitor_cbs; 
  Coverage cov; 
  function new(input Coverage COy); 
    this.cov = cov; 
  endfunction : new 
  // Send received cell to coverage 
  virtual task post_rx( input Monitor mon, 
                        input NNI_cell cell); 
    CellCfgType CellCfg = top.squat.lut.read(cell.VPI); 
    cov.sample(mon.PortID, CellCfg.FWD); 
  endtask : post_rx 
endclass : Cov_Monitor_cbs                       
                       
//Sample 11.10 Environment configuration class 
class Config; 
  int nErrors, nWarnings;     // Number of errors, warnings 
  bit [31:0] numRx, numTx;    // Copy of parameters 
  
  rand bit [31:0] nCells;     // Total cells 
  constraint c_nCells_valid       {nCells > 0; } 
  constraint c_nCells_reasonable  {nCells < 1000; } 
  
  rand bit in_use_Rx[];       // Input / output channel enabled 
  constraint c_in_use_valid {in_use_Rx.sum > 0;} // At least one RX is enabled 
  
  rand bit [31:0] cells_per_chan[); 
  constraint c_sum_ncells_sum // Split cells over all channels 
                                 {cells_per_chan.sum == nCells;} // Total number of cells 
  
 // Set the cell count to zero for any channel not in use 
  constraint zero_unused_channels
      {foreach (cells_per_chan[i]) 
          { 
            // Needed for even dist of in use 
            solve in_use_Rx[i] before cells_per_chan[i]; 
            // the active channel mask is solved before dividing up the cells between channels.
            if (in_use_Rx[i] 
                cells_per_chan[i] inside {[1:nCells]}; 
                else cells_per_chan[i] == 0; // set the number of cells to 0 for inacive channels
           }
       }
                          
    extern function new (input bit [31:0] numRx, numTx); 
    extern virtual function void display(input string prefix=""); 
endclass : Config                       
                       
// Sample 11.11 Cell configuration type 
typedef struct packed { 
  bit [`TxPorts-1:0] FWD; 
  bit [11: 0] VPI; 
} CellCfgType;                       
                       
//Sample 11.12 Configuration class methods 
function Config::new(input bit [31:0] numRx, numTx); 
  this.numRx = numRx; 
  in_use_Rx = new [numRx] ; 
  this.numTx = numTx; 
  cells_per_chan = new [numRx] ; 
endfunction : new 
function void Config: :display(input string prefix); 
  $write("%sConfig: numRx=%0d, numRx=%0d, nCells=%0d", 
            prefix, numRx, numRx, nCells); 
  foreach (cells_per_chan[i]) 
              $write("%0d", cells_per chan[i]); 
  $write("%s enabled RX:", prefix); 
  foreach (in_use_Rx[i]) if (in_use_Rx[i]) $write("%0d", i); 
  $display; 
endfunction : display                       
                       
//Sample 11.13 UNI cell format 
typedef struct packed { 
  bit [3: 0]  GFC; 
  bit [7: 0]  VPl; 
  bit [15: 0] VCl; 
  bit         CLP; 
  bit [2: 0]  PT; 
  bit [7: 0]  HEC; 
  bit [0:47] [7: 0] Payload; 
} uniType;                       
                       
//Sample 11.14 NNI cell format 
typedef struct packed { 
  bit [11:0] VPl; 
  bit [15:0] VCl; 
  bit        CLP; 
  bit [2: 0] PT; 
  bit [7: 0] HEC; 
  bit [0: 47] [7: 0] Payload; 
} nniType;                       
                       
 //Sample 11.15 ATMCellType 
//The UNI and NNI cells are merged with a byte memory to form a universal type      
typedef union packed { 
  uniType uni; 
  nniType nni; 
  bit [0:52] [7:0] Mem; 
} ATMCell Type;                      
                       
// Sample 11.16 UNI_cell definition 
class UNI_cell extends BaseTr;
  // Physical fields 
  rand bit [3: 0]  GFC; 
  rand bit [7: 0]  VPI; 
  rand bit [15: 0] VCI; 
  rand bit         CLP; 
  rand bit [2: 0]  PT; 
       bit [7: 0]  HEC; 
  rand bit [0:47] [7: 0] Payload; 
  
  // Meta-data fields 
  static bit [7:0] syndrome [0:255] ; 
  static bit syndrome_not_generated = 1; 
  
  extern function new(); 
  extern function void post_randomize(); 
  extern virtual function bit compare(input BaseTr to); 
  extern virtual function void display(input string prefix=""); 
  extern virtual function void copy_data(input UNI_cell copy); 
  extern virtual function BaseTr copy(input BaseTr to=null); 
  extern virtual function void pack(output ATMCellType to); 
  extern virtual function void unpack(input ATMCellType from); 
  extern function NNI_cell to_NNI(); 
  extern function void generate_syndrome(); 
  extern function bit [7:0] hec (bit [31:0] hdr); 
endclass : UNI cell
      
// Sample 11.17 UNI_cell methods 
function UNI_cell::new(); 
  if (syndrome_not_generated) 
      generate_syndrome(); 
endfunction : new 

// Compute the HEC value after all other data has been chosen 
function void UNI_cell::post_randomize(); 
  HEC = hec({GFC, VPI, VCI, CLP, PT}); 
endfunction : post randomize 

// Compare this cell with another 
// This could be improved by telling what field mismatched 
function bit UNI_cell::compare(input BaseTr to); 
  UNI_cell cell; 
  $cast(cell, to) ; 
  if (this.GFC ! = cell.GFC) return 0; 
  if (this.VPI ! = cell. VPI) return 0; 
  if (this.VCI ! = cell. VCI) return 0; 
  if (this.CLP ! = cell.CLP) return 0; 
  if (this.PT  ! = cell. PT) return 0; 
  if (this.HEC ! = cell.HEC) return 0; 
  if (this.Payload != cell.Payload) return 0; 
  return 1; 
endfunction : compare 
    
// Print a 'pretty' version of this object 
function void UNI_cell::display(input string prefix); 
  ATMCellType p; 
  
  $display("%sUNI id:%0d GFC=%x, VPI=%x, VCI=%x, CLP=%b, PT=%x, HEC=%x, Payload[0]=%x", 
           prefix, id, GFC, VPI, VCI, CLP, PT, HEC, Payload[0]); 
  this.pack(p) ; 
  $write("%s", prefix); 
  foreach (p.Mem[i]) $write("%x", p.Mem[i]); 
  $display; 
endfunction : display 
    
// Copy the data fields of this cell 
function void UNI_cell::copy_data(input UNI_cell copy); 
  copy.GFC = this.GFC; 
  copy.VPI = this.VPI; 
  copy.VCI = this.VCI;  
  copy.CLP = this.CLP; 
  copy.PT  = this.PT; 
  copy.BEC = this.HEC; 
  copy.Payload = this.Payload; 
endfunction : copy_data 
    
// Make a copy of this object 
function BaseTr UNl_cell::copy(input BaseTr to); 
  UNl_cell dst; 
  if (to == null) dst = new(); 
  else            $cast(dst, to); 
  copy_data(dst); 
  return dst; 
endfunction : copy 
    
// Pack this object's properties into a byte array 
function void UNl cell::pack(output ATMCellType to); 
  to.uni.GFC = this.GFC; 
  to.uni.VPl = this.VPl; 
  to.uni.VCl = this.VCl;
  to.uni.CLP = this.CLP;
  to.uni.PT  = this.PT;
  to.uni.HEC = this.HEC;
  to.uni.Payload = this.Payload; 
endfunction : pack 
    
// Unpack a byte array into this object 
function void UNl_cell::unpack(input ATMCellType from); 
  this.GFC = from.uni.GFC; 
  this.VPl = from.uni.VPl; 
  this.VCl = from.uni.VCl;
  this.CLP = from.uni.CLP; 
  this.PT  = from.uni.PT;
  this.HEC = from.uni.HEC;
  this.Payload = from.uni.Payload; 
endfunction : unpack 
    
// Generate a NNl cell from an UNl cell - used in scoreboard 
function NNl_cell UNl_cell::to_NNl(); 
  NNl_cell copy; 
  copy = new () ; 
  copy.VPl = this.VPl; //NNl has wider VPl 
  copy.VCl = this.VCl; 
  copy.CLP = this.CLP;
  copy.PT  = this.PT; 
  copy.HEC = this.HEC; 
  copy.Payload = this.Payload; 
  return copy; 
endfunction : to_NNI 

// Generate the syndrome array, which is used to compute HEC 
function void UNI_cell::generate syndrome(); 
  bit [7:0] sndrm; 
  for (int i = 0; i < 256; i = i + 1 ) begin 
    sndrm = i; 
    repeat (8) begin 
      if (sndrm[7] === 1'b1) 
          sndrm = (sndrm << 1 ) ^ 8'h07;
      else 
          sndrm = sndrm << 1;
    end
    syndrome[i] = sndrm; 
  end 
  syndrome_not_generated = 0; 
endfunction : generate_syndrome 
  
// Compute the HEC value for this object 
function bit [7:0] UNI cell::hec (bit [31:0] hdr); 
  hec = 8'h00; 
  repeat (4) begin 
    hec = syndrome[hec ^ hdr[31:24]]; 
    hdr = hdr << 8; 
  end
  hec = hec ^ 8'h55; 
endfunction : hec      
      
//Sample 11.18 UNI~enerator class 
class UNI generator; 
  UNI_cell blueprint; // Blueprint for generator 
  mailbox gen2drv;    // mailbox Mailbox to driver for cells 
  event   drv2gen;    // Event from driver when done with cell 
  int     nCells;     // Num cells for this generator to create 
  int     PortID;     // Which Rx port are we generating? 
  
  function new (input mailbox gen2drv, 
                input event drv2gen, 
                input int nCells, PortID); 
    this.gen2drv = gen2drv; 
    this.drv2gen = drv2gen;
    this.nCells  = nCells; 
    this.PortID  = PortID; 
    blueprint = new();
  endfunction : new
  
  task run(); 
    UNI_cell cell; 
    repeat (nCells) begin 
      assert(blueprint.randomize()) ; 
      $cast(cell, blueprint.copy()); 
      cel1.display($psprintf("@%0t: Gen%0d:" $time, PortID)); 
      gen2drv.put(cell) ; 
      @drv2gen;      // Wait for driver to finish with it 
    end 
  endtask : run 
endclass : UNI_generator      
      
//Sample 11.19 driver class 
typedef class Driver_cbs; 
  
class Driver; 
  mailbox gen2drv; // For cells sent from generator 
  event drv2gen;   // Tell generator when I am done with cell
  vUtopiaRx Rx;     // Virtual ifc for transmitting cells 
  Driver cbs cbsq[$]; // Queue of callback objects 
  int PortID; 
  
  extern function new ( input mailbox gen2drv, 
                        input event drv2gen, 
                        input vUtopiaRx Rx, 
                        input int PortID); 
  extern task run(); 
  extern task send (input UNI_cell cell); 
endclass : Driver 
    
// new(): Construct a driver object 
function Driver::new( input mailbox gen2drv, 
                      input event drv2gen, 
                      input vUtopiaRx Rx, 
                      input int PortID); 
  this.gen2drv = gen2drv; 
  this.drv2gen = drv2gen; 
  this.Rx = Rx; 
  this.PortID = PortID; 
endfunction : new 
    
// run(): Run the driver. 
// Get transaction from generator, send into DUT 
task Driver::run(); 
  UNI_cell cell; 
  bit drop = 0; 
  
  // Initialize ports 
  Rx.cbr.data <= 0; 
  Rx.cbr.soc  <= 0; 
  Rx.cbr.clav <= 0; 
  
  forever begin 
    // Read the cell at the front of the mailbox 
    gen2drv.peek(cell) ; 
    begin: Tx 
      // Pre-transmit callbacks 
      foreach (cbsq[i]) begin 
        cbsq[i].pre_tx(this, cell, drop); 
        if(drop) disable Tx; // Don't transmit this cell 
      end 
      
      cell.display($psprintf("@%0t: Drv%0d:" $time, PortID)); 
      send(cell); 

      // Post-transmit callbacks 
      foreach (cbsq[i])  cbsq[i].post_tx(this, cell); 
    end : Tx 
    
    gen2drv.get(cell); // Remove cell from the mailbox 
    ->drv2gen; // Tell the generator we are done with this cell 
  end 
endtask : run 
    
// send(): Send a cell into the DUT 
task Driver::send(input UNI cell cell); 
  ATMCellType Pkt; 
  
  cell.pack(Pkt) ; 
  $write("Sending cell: "); 
  foreach (Pkt.Mem[i) 
  $write("%x ", Pkt.Mem[i]); $display; 
                   
  // Iterate thru bytes of cell 
  @(Rx.cbr); 
  Rx.cbr.clav <= 1; 
  for (int i=O; i<=52; i++) begin 
    // If not enabled, loop 
    while (Rx.cbr.en === 1'b1) @(Rx.cbr); 
    
    // Assert Start Of Cell, assert enable, send byte 0 (i==O) 
    Rx.cbr.soc <= (i == 0); 
    Rx.cbr.data <= Pkt.Mem[i]; 
    @(Rx.cbr); 
  end 
  Rx.cbr.soc <= 'z; 
  Rx.cbr.data <= 8'bx; 
  Rx.cbr.clav <= 0; 
endtask      
      
//Sample 11.20 Driver callback class 
typedef class Driver; 
  
class Driver_cbs; 
  virtual task pre_tx(input Driver drv, 
                      input UNI cell cell, 
                      inout bit drop); 
  endtask : pre_tx 
  
  virtual task post_tx( input Driver drv, 
                        input UNI cell cell); 
  endtask : post_tx 
endclass : Driver_cbs      
      
 //Sample 11.21 Monitor callback class 
typedef class Monitor; 
  
class Monitor_cbs; 
  virtual task post_rx( input Monitor drv, 
                        input NNI cell cell); 
  endtask : post_rx 
endclass : Monitor cbs     
      
//Sample 11.22 The Monitor class 
typedef class Monitor_cbs;
  
class Monitor; 
  vUtopiaTx Tx;         // Virtual interface with output of DUT 
  Monitor_cbs cbsq[$];  // Queue of callback objects 
  int PortID; 

  extern function new(input vUtopiaTx Tx, input int PortID); 
  extern task run(); 
  extern task receive (output NNI_cell cell); 
endclass : Monitor 
    
// new(): construct an object 
function Monitor::new(input vUtopiaTx Tx, input int PortID); 
  this.Tx = Tx; 
  this.PortID = PortID; 
endfunction : new 

// run(): Run the monitor 
task Monitor::run(); 
  NNI_cell cell; 
  forever begin 
    receive(cell); 
    foreach (cbsq[i]) 
      cbsq[i].post_rx(this, cell); // Post-receive callback 
  end 
endtask : run 
    
// receive(): Read cell from the DUT, pack into a NNI cell 
task Monitor::receive(output NNI cell cell); 
  ATMCellType Pkt; 
  
  Tx.cbt.clav <= 1; 
  while (Tx.cbt.soc !== 1'b1 && Tx.cbt.en !== 1'b0) 
    @(Tx.cbt) ; 
  for (int i=0; i<=52; i++) begin 
    // If not enabled, loop 
    while (Tx.cbt.en !== 1'b0) @(Tx.cbt); 
    Pkt.Mem[i] = Tx.cbt.data; 
    @(Tx.cbt) ; 
  end 
  
  Tx.cbt.clav <= 0; 
  cell = new(); 
  cell.unpack(Pkt); 
  cell.display($psprintf ("@%0t: Mon%0d:" $time, PortID)); 
endtask : receive
                          
//Sample 11.23 The Scoreboard class 
class Expect_cells; 
  NNI_cell q[$]; 
  int iexpect, iactual; 
endclass : Expect_cells 
           
class Scoreboard; 
  Config cfg; 
  Expect cells expect_cells[); 
  NNI_cell cellq[$); 
  int iexpect, iactual;
                 
  extern function new(Config cfg); 
  extern virtual function void wrap_up(); 
  extern function void save_expected(UNI_cell ucell); 
  extern function void check_actual (input NNI_cell cell, 
                                     input int portn); 
  extern function void display(string prefix=""); 
endclass : Scoreboard 
  
function Scoreboard::new(Config cfg); 
  this.cfg = cfg; 
  expect_cells = new [NumTx] ; 
  foreach (expect_cells[i] )
     expect_cells [i] = new(); 
endfunction : Scoreboard 
              
function void Scoreboard::save_expected(UNI_cell ucell); 
  NNI_cell ncell = ucell.to_NNI; 
  CellCfgType CellCfg = top.squat.lut.read(ncell.VPI); 
  
  $display("@%0t: Scb save: VPI=%0x, Forward=%b", $time, ncell.VPI, CellCfg.FWD); 
  ncell.display($psprintf ("@%0t: Scb save: ", $time)); 
                           
  // Find all Tx ports where this cell will be forwarded 
  for (int i=0; i<NumTx; i++) 
    if (CellCfg.FWD[i]) begin 
      expect_cells[i].q.push_back(ncell); // Save cell in this q 
      expect_cells[i].iexpect++; 
      iexpect++; 
    end 
endfunction : save_expected 

function void Scoreboard::check_actual (input NNI_cell cell, 
                                        input int portn) ; 
  NNI_cell match; 
  int match_idx; 
  
  cell.display($psprintf("@%0t: Scb check: ", $time)); 
  
  if (expect_cells[portn].q.size() == 0) begin 
    $display("@%0t: ERROR: %m cell not found, SCB TX%0d empty", $time, portn); 
    cell.display("Not Found: "); 
    cfg.nErrors++; 
    return; 
  end 
  
  expect_cells[portn].iactual++; 
  iactual++; 
  
  foreach (expect_cells[portn].q[i]) begin 
    if (expect_cells[portn].q[i].compare(cell)) begin 
      $display("@%0t: Match found for cell", $time); 
      expect cells[portn].q.delete(i); 
      return; 
    end 
  end 
  
  $display("@%0t: ERROR: %m cell not found", $time); 
  cell.display("Not Found: "); 
  cfg.nErrors++; 
endfunction : check actual
             
// Print end of simulation report 
function void Scoreboard::wrap_up(); 
  $display("@%0t: %m %0d expected cells, %0d actual cells rcvd", $time, iexpect, iactual); 
  
  // Look for leftover cells 
  foreach (expect_cells[i]) begin 
    if (expect_cells[i].q.size()) begin 
      $display("@%0t: %m cells remain in SCB Tx[%0d] at end of test", $time, i); 
      this.display ("Unclaimed: "); 
      cfg.nErrors++; 
    end 
  end 
endfunction wrap_up 

// Print the contents of the scoreboard, mainly for debugging 
function void Scoreboard::display(string prefix); 
  $display("@%0t: %m so far %0d expected cells, %0d actual rcvd", $time, iexpect, iactual); 
  foreach (expect_cells[i]) begin 
    $display ("Tx[%0d]: exp=%0d, act=%0d" , 
               i, expect_cells[i].iexpect, expect_cells[i].iactual); 
  foreach (expect_cells[i].q[j]) 
    expect_cells[i].q[j].display( $psprintf ("%sScoreboard: Tx%0d:" prefix, i)); 
  end 
endfunction : display                          
                          
//Sample 11.24 Functional coverage class 
class Coverage; 
  bit [1:0] src; 
  bit [NumTx-1:0] fwd; 
  
  covergroup CG_Forward; 
    coverpoint src  { bins src [] = {[0:3]}; 
                      option.weight = a;      } 
    coverpoint fwd  { bins fwd[] = {[1:15]}; // Ignore fwd==O 
                      option.weight = a;      } 
    cross src, fwd; 
  endgroup : CG_Forward 
  
  function new; 
     CG_Forward = new; // Instantiate the covergroup
  endfunction : new 
  
  // Sample input data 
  function void sample(input bit [1:0] src, 
                       input bit [NumTx-1:0] fwd); 
    $display("@%0t: Coverage: src=%d. FWD=%b" , $time, src, fwd); 
    this.src = src; 
    this. fwd = fwd; 
    CG_Forward.sample(); 
  endfunction : sample 
endclass : Coverage                          
           
// Sample 11.25 The CPU_driver class 
class CPU_driver; 
  vCPU_T mif; 
  CellCfgType lookup [255:0]; // copy of look-up table 
  Config cfg; 
  bit [NumTx-1:0] fwd; 
  
  extern function new(vCPU_T mif, Config cfg); 
  extern task Initialize_Host (); 
  extern task HostWrite (int a, CellCfgType d); // configure 
  extern task HostRead (int a, output CellCfgType d); 
  extern task run(); 
endclass CPU_driver 
    
function CPU_driver::new(vCPU_T mif, Config cfg); 
  this.mif = mif; 
  this.cfg = cfg; 
endfunction : new 
    
task CPU driver::Initialize_Host (); 
  mif.BusMode <= 1; 
  mif.Addr    <= 0; 
  mif.DataIn  <= 0; 
  mif.Sel     <= 1; 
  mif.Rd_DS   <= 1; 
  mif.Wr_RW   <= 1; 
endtask : Initialize Host 
    
task CPU_driver::HostWrite (int a, CellCfgType d); //configure 
  #10 mif.Addr <= a; mif.DataIn <= d; mif.Sel <= 0; 
  #10 mif.Wr_RW <= 0; 
  while (mif.Rdy_Dtack!==O) #10; 
  #10 mif.Wr_RW <= 1; mif.Sel <= 1; 
  while (mif.Rdy_Dtack==O) #10; 
endtask : HostWrite 
    
task CPU_driver::HostRead (int a, output CellCfgType d); 
  #10 mif.Addr <= a; mif.Sel <= 0; 
  #10 mif.Rd_DS <= 0; 
  while (mif.Rdy_Dtackl==0) #10; 
  #10 d = mif.DataOUt; mif.Rd DS <= 1; mif.Sel <= 1; 
  while (mif.Rdy_Dtack==O) #10; 
endtask : HostRead 
    
task CPU_driver::run(); 
  CellCfgType CellFwd; 
  Initialize_Host() ; 
  
  // Configure through Host interface 
  repeat (10) @(negedge clk); 
  $write ("Memory: Loading ... "); 
  for (int i=0; i<=255; i++) begin 
    CellFwd.FWD = $urandom(); 
  `ifdef FWDALL 
      CellFwd.FWD = '1 
  `endif 
    CellFwd.VPI i; 
    HostWrite(i, CellFwd); 
    lookup[i] = Cel1Fwd; 
  end 
  
  // Verify memory 
  $write ("Verifying ... "); 
  for (int i=0; i<=255; i++) begin 
    HostRead(i, CellFwd); 
    if (lookup[i]!= CellFwd) begin 
      $display("FATAL, Mem Loc 0x%x contains 0x%x, expected 0x%x", 
               i, lookup[i], CellFwd); 
      $finish; 
    end 
  end 
  $display ("Verified") ; 
endtask : run    
    
-----------------------------------------------------------------------------------    
 Sample 11.26 Test with one cell 
program automatic test 
  #(parameter int NumRx = 4, parameter int NumTx = 4) 
  ( Utopia.TB_Rx Rx[0:NumRx-1], 
    Utopia.TB_Tx Tx[0:NumTx-1], 
    cpu_ifc.Test mif, 
    input logic rst, clk); 
  
  `include "environment.sv" 
    Environment env; 
  
  class Config_1_cell extends Config; 
    constraint one_cells {nCells == 1; } 
    function new(input int NumRx,NumTx); 
      super.new(NumRx,NumTx) ; 
    endfunction : new 
  endclass : Config_1_cell 
  
  initial begin 
    env = new(Rx, Tx, NumRx, NumTx, mif); 
    begin // Just simulate for 1 cell 
      Config_1_cells c1 = new(NumRx,NumTx); 
      env.cfg = c1; 
    end 
    
    env.gen_cfg(); // Config will have just 1 cell
    env.build(); 
    env.run(); 
    env.wrap_up(); 
  end 
endprogram // test   
    
 //Sample 11.27 Test that drops cells using driver callback 
program automatic test 
  #(parameter int NumRx = 4, parameter int NumTx = 4) 
  ( Utopia.TB_Rx Rx[0:NumRx-1], 
    Utopia.TB_Tx Tx[0:NumTx-1], 
    cpu_ifc.Test mif, 
    input logic rst, clk); 
  
  `include "environment.sv" 
  Environment env; 
  
  class Driver_cbs drop extends Driver_cbs; 
    virtual task pre_tx(input ATM_cell cell, ref bit drop); 
      // Randomly drop lout of every 100 transactions 
      drop = ($urandom_range(0,99) == 0); 
    endtask 
  endclass 
  
  initial begin 
    env = new(Rx, Tx, NumRx, NumTx, mif); 
    env.gen_cfg(); 
    env.build(); 
    
    begin // Create error injection callback 
      Driver_cbs_drop dcd = new(); 
      env.drv.cbs.push_back(dcd); // Put into driver's Q 
    end 
    
    env.run(); 
    env.wrap_up(); 
  end 
endprogram // test   
    
    
    
                          
