// Sample 7.1 Interaction ofbegin ... end and fork ... join
initial begin
  $display("@%0t: start fork ... join example", $time);
  #10 $display("@%0t: sequential after #10", $time);
  fork
    $display("@%0t: parallel start", $time);
    #50 $display("@%0t: parallel after #50", $time);
    #10 $display("@%0t: parallel after #10", $time);
    begin
      #30 $display("@%0t: sequential after #30", $time);
      #10 $display("@%0t: sequential after #10", $time);
    end
  join
  $display ("@%0t: after join", $time);
  #80 $display("@%0t: finish after #80", $time);
end

//Sample 7.3 Fork ... join_none code
initial begin
  $display("@%0t: start fork...join_none example", $time);
  #10 $display("@%0t: sequential after #10", $time);
  fork
    $display("@%0t: parallel start", $time);
    #50 $display("@%0t: parallel after #50", $time);
    #10 $display("@%0t: parallel after #10", $time);
    begin
      #30 $display("@%0t: sequential after #30", $time);
      #10 $display("@%0t: sequential after #10", $time);
    end
  join_none
  $display ("@%0t: after join_none", $time);
  #80 $display("@%0t: finish after #80", $time);
end

//Sample 7.5 Fork ... join_any code
initial begin
  $display("@%0t: start fork ... join_any example", $time);
  #10 $display("@%0t: sequential after #10·, $time);
  fork
    $display("@%0t: parallel start", $time);
    #50 $display("@%0t: parallel after #50", $time);
    #10 $display("@%0t: parallel after #10", $time);
    begin
      #30 $display("@%Ot: sequential after #30", $time);
      #10 $display("@%Ot: sequential after #10", $time);
    end
  join_any
  $display("@%0t: after join any", $time);
  #80 $display("@%0t: finish after #80", $time);
end
----------------------------------------------------------------
//Sample 7.7 Generator/Driver class with a run task
class Gen_drive;
  // Transactor that creates N packets
  task run (int n) ;
    Packet p;
    fork
      repeat(n) begin
        p = new();
        assert(p.randomize());
        transmit(p) ;
      end
    join_none  // Use fork-join_none so run() does not block
  endtask    
  task transmit(input Packet p);
    ...
  endtask
endclass
               
Gen_drive gen;
               
initial begin
  gen = new();
  gen.run(10) ;
  //Start the checker, monitor, and other threads
  ...          
end               
--------------------------------------------------------------               
// Sample 7.8 Dynamic thread creation
program automatic test(bus_ifc.TB bus);
//Code for interface not shown
  task check_trans (Transaction tr);
    fork
      begin
      wait (bus.cb.addr tr.addr);
      $display("@%Ot: Addr match %d", $time, tr.addr);
      end
    join_none
  end task
  Transaction tr;
  initial begin
    repeat (10) begin
      // Create a random transaction
      tr = new();
      assert(tr.randomize());
      // Send transaction into the DUT
       transmit (tr) ; //Task not shown
      // Wait for reply from DUT
      check_trans(tr);
    end
    #100; // Wait for final transaction to complete
  end
endprogram

// Sample 7.11 Automatic variables in a fork ... join_none
initial begin
  for (int j=O; j<3; j++)
    fork
      automatic int k = j; //Make copy of index
      $write(k);  //Print copy
    join_none
  #0 $display;
end
// The fork ... join_none block is split into two parts. 
// The automatic variable declaration with initialization runs in the thread inside the for-loop. 
// During each loop, a copy of k is created and set to the current value of j.
// Then the body of the fork ... join_none ($write) is scheduled, including a copy ofk. 
// After the loop finishes, #0 blocks the current thread, and so the three threads run, printing the value of their copy of k. When the threads complete, 
// and there is nothing else left during the current time-slot region, System Verilog advances to the next statement and the $display executes. 
    
// automatic variables could write outside of the fork...join_none
// Sample 7.13 Automatic variables in a fork ... join_none
program automatic bug_free;
  initial begin
    for (int j=O; j<3; j++) begin
      int k = j; // Make copy of index
      fork
        $write(k); // Print copy
      join_none
    end
    #0 $display;
  end
endprogram    
    
---------------------------------------------------------------------------
//Sample 7.14 Using wait fork to wait for child threads
task run_threads;
  ...                 // Create some transactions
  fork
    check trans(trl); // Spawn first thread
    check_trans(tr2); // Spawn second thread
    check_trans(tr3); // Spawn third thread
  join_none
  ...                 // Do some other work
  // Now wait for the above threads to complete
  wait fork;
endtask    
    
-------------------------------------------------------------
//Sample 7.16 Disabling a thread
parameter TIME_OUT = 1000;
task check_trans (Transaction tr);
  fork
    begin
      // Wait for response, or some maximum delay
      
      fork : timeout block
        begin
          wait (bus.cb.addr == tr.addr);
          $disp1ay("@%0t: Addr match %d", $time, tr.addr);
        end
        #TIME_OUT $display("@%0t: Error: timeout", $time);
      join_any
      
      disable timeout_block;
    end
  join_none
endtask    
    
// If the correct bus address comes back quickly enough, the wait construct completes, the join_any executes, 
// and then the disable kills offthe remaining thread. 
// However, if the bus address does not get the right value before the TIME_OUT delay completes,
// the error message is printed, the join_any executes, and the disable kills the thread with the wait.    
---------------------------------------------------------------------------------------------------
// Sample 7.17 Limiting the scope ofa disable fork
initial begin
  check_trans (tr0) ;       // Thread 0
  // Create a thread to limit scope of disable
  fork                      // Thread 1
    begin
      check_trans (trl) ;   //Thread 2
      fork                  //Thread 3
        check_trans (tr2) ; //Thread 4
      join
      // Stop threads 1-4, but leave 0 alone
      # (TlME_OUT/2) disable fork;
    end
  join
end    // check_trans is from Sample 7.16
    
// Sample 7.18 Using disable label to stop threads
initial begin
  check_trans(trO) ; // Thread 0
  fork // Thread 1
    begin : threads_inner
      check_trans(trl);// Thread 2
      check_trans(tr2); // Thread 3
    end
    // Stop threads 2 & 3, but leave 0 alone
    #(TIME OUT/2) disable threads_inner;
  join
end    
    
//Sample 7.19 Using disable label to stop a task
task wait_for_time_out(int id);
if (id == 0)
  
  fork
    begin
      #2;
      $display("@%0t: disable wait_for_time_out", $time);
      disable wait_for_time_out;
    end
  join_none
  
  fork : just_a_little
    begin
      $display("@%0t: %m: %0d entering thread", $time, id);
      #TlME_OUT;
      $display("@%0t: %m: %0d done", $time, id);
    end
  join_none
  
endtask
         
initial begin
  wait_for_time_out(0); // Spawn thread 0
  wait_for_time_out(1); // Spawn thread 1
  wait_for_time_out(2); // Spawn thread 2
  #(TlME_OUT*2) $display("@%0t: All done", $time);
end   
    
//the wait_for_time_out task is called three times. spawning three threads. 
// In addition. thread 0 also disables the task after #2. 
// When you run this code. you will see the three threads starting. but none finishes. because of the disable in thread O.    

-----------------------------------------------------------------------------------
//EVENTs
// in SV, an event is a handle to a synchronization object that can be passed around to routines
// this feature allowsto share events across objects without having to make events global.
// SV introduces triggered() method to check whether an event has been triggered.
    
//Sample 7.20 Blocking on an event in Verilog
event el, e2;
initial begin
  $display("@%0t: 1: before trigger", $time);
  -> el;
  @e2;
  $display("@%0t: 1: after trigger" , $time);
end
initial begin
  $display ("@%0t: 2: before trigger", $time);
  -> e2;
  @el;
  $display ("@%0t: 2: after trigger", $time);
end  

//Sample 7.22 Waiting for an event
event e1, e2;
initial begin
  $display("@%0t: 1: before trigger", $time};
  -> e1;
  wait (e2.triggered());
  $display("@%0t: 1: after trigger", $time);
end
initial begin
  $display ("@%0t: 2: before trigger", $time);
  -> e2;
  wait (e1.triggered());
  $display("@%0t: 2: after trigger", $time);
end    
    
//Sample 7.25 Waiting for an edge on an event
forever begin
  // This prevents a zero delay loop!
  @handshake;
  $display("Received next event");
  process_in_zero_time();
end
// The edge-sensitive delay statement continues once and only once per event trigger.           

-------------------------------------------------------------------------
// Sample 7.26 Passing an event into a constructor
class Generator;
  event done;
  
  function new (event done); // Pass event from TB
    this.done = done;
  endfunction
  
  task run();
    fork
      begin
        ... // Create transactions
        -> done;  //tell the test we are done
      end
    join_none
  endtask
 
endclass

program automatic test;
  event gen_done;
  Generator gen;
  initial begin
    gen = new(gen_done);        // instantiate testbench
    gen.run();                  // run transactor  
    wait(gen_done.triggered()); // wait for finish
  end
endprogram
       
-------------------------------------------------------------           
// wait for multiple events           
// Sample 7.27 Waiting for multiple threads with wai t fork
event done [N_GENERATORS] ;
initial begin
  foreach (gen[i]) begin
    gen[i] = new();      // create N generators
    gen[i].run(done[i]); //start them running
  end

  // Wait for all gen to finish by waiting for each event
  foreach (gen[i])
    fork
      automatic int k = i;
      wait (done[k].triggered());
    join_none
   
  wait fork; // Wait for all those triggers to finish
end           
           
// Sample 7.28 Waiting for multiple threads by counting triggers
event done [N_GENERATORS] ;
int done_count;

initial begin
  foreach (gen[i]) begin
    gen[i] = new();       // create N generators
    gen[i].run(done[i]); // start them running
  end
  // Wait for all generators to finish
  foreach (gen[i])
    fork
      automatic int k = i;
      begin
        wait(done[k].triggered());
        done_count++;
      end
    join_none
  wait(done_count==N_GENERATORS); // Wait for triggers
end           
           
//Sample 7.29 Waiting for multiple threads using a thread count
class Generator;
  static int thread count = 0;
  task run () ;
    thread_count++; // Start another thread
    fork
      begin
      // Do the real work in here
      // And when done, decrement the thread count
      thread_count--;
      end
    join_none
  end task
endclass
    
Generator gen[N_GENERATORS];
    
initial begin
// Create N generators
  foreach(gen[i])  gen[i] = new();
  // Start them running
  foreach(gen[i])  gen[i].run() ;
  // Wait for all the generators to complete
  wait (Generator::thread_count == 0);
end

-------------------------------------------------------           
//SEMAPHORES           
// semaphores can be used in a testbench when you have a resource (such as bus),
// that may have multiple requestors from inside the testbench
           
//Sample 7.30 Semaphores controlling access to hardware resource
program automatic test(bus_ifc.TB bus);
  semaphore semi; // Create a semaphore
  initial begin
    sem = new(l);  // allocate with 1 key
    fork
      sequencer() ; // spawn 2 threads that both do bue transactions
      sequencer() ;
    join
  end
  
  task sequencer;
    repeat ($urandom%10) // Random wait, 0-9 cycles
       @bus.cb;
    sendTrans() ;        // excute the transaction
  endtask
  task sendTrans;
    sem.get(l);          // get the key to the bus
    @bus.cb;             // drive signals onto bus
    bus.cb.addr <= t.addr;
    ...
    sem.put(l);          // Put it back when done
  endtask
endprogram
       
// 1st: can put more keys back than took out, but only one car
// 2nd: be careful if testbench needs to get and put multiple keys. 
//      perhaps you have one key left, and a thread requests 2, causing it to block
//      in SV, the second request get(1), sneaks ahead of earlier get(2), bypassing the FIFO ordering
-------------------------------------------------------------------------------------           
//MAILBOX           
// like a FIFO. with a source and sink. 
// The source puts data into the mailbox, and the sink gets values from the mailbox.           
// a mailbox is an object           
           
//Sample 7.32 Good generator creates many objects
task generator_good(int n, mailbox mbx) ;
  Transaction t;
  repeat(n) begin
    t = new();              // Create a new transaction
    assert(t.randomize()); // Randomize variables
    $display ("GEN: Sending addr=%h", t.addr) ;
    mbx.put(t);            // Send transaction to driver
  end
endtask          

//  Sample 7.33 Good driver receives transactions from mailbox
task driver (mailbox mbx);
  Transaction t;
  forever begin
    mbx.get(t); // Get transacton from mailbox
    $display("DRV: Received addr=%h", t.addr);   // Drive transaction into DUT
  end
endtask
           
    // try_get() and try_peek() functions. 
    // if they are successful, return a nonzero value; otherwise they reture 0
    
// Sample 7.34 Exchanging objects using a mailbox: the Generator class
class Generator;
  Transaction tr;
  mailbox mbx;
  
  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction
  
  task run(int count);
    repeat (count) begin
      tr = new();
      assert(tr.randomize);
      mbx.put(tr); // Send out transaction
    end
  endtask
endclass    
    
// Sample 7.35 Exchanging objects using a mailbox: the Driver class
class Driver;
  Transaction tr;
  mailbox mbx;
  
  function new (mailbox mbx) ;
    this.mbx = mbx;
  endfunction
  
  task run(int count);
    repeat (count) begin
      mbx.get(tr);     // Fetch next transaction
      @(posedge bus.cb.ack);
      bus.cb.kind <= tr.kind;
      ...
    end
  endtask
endclass    
    
// Sample 7.36 Exchanging objects using a mailbox: the program block
program automatic mailbox_example(bus_if.TB bus, ...);
  'include "transaction.sv"
  'include "generator.sv"
  'include "driver.sv"
  
  mailbox mbx;         // mailbox connecting generator & driver
  Generator gen;
  Driver drv;
  int count;
  
  initial begin
    count = $urandom_range(50);
    mbx = new();    // Construct the mailbox
    gen = new(mbx); // Construct the generator
    drv = new(mbx); // Construct the driver
    fork
      gen.run(count) ;  // spawn the generator
      drv.run(count) ;  // spawn the driver
    join                // wait for both to finish
  end
endprogram

//Sample 7.37 Bounded mailbox
'timescale 1ns/1ns
program automatic bounded;
  mailbox mbx;
  initial begin
    mbx = new(1); // Mailbox size = 1
    fork
      
      // Producer thread
      for (int i=1; i<4; i++) begin
        $display("Producer: before put(%0d)", i);
        mbx.put(i) ;
        $display("Producer: after put(%0d)", i);
      end
      
      // Consumer thread
      repeat(4) begin
        int j;
        #1ns mbx.get(j);
        $display("Consumer: after get(%0d)", j);
      end
      
    join
  end
endprogram
// default mailbox size is 0, which creates an unbounded mailbox;
// any size greater than 0 creates a bounded mailbox.
// the bounded mailbox acts as a buffer between the 2 processes.    
    
--------------------------------------------------------------------
// handshake
// Sample 7.39 Producer-consumer without synchronization 
// the producer runs to completion before the consumer even starts    
program automatic unsynchronized; 
  mailbox mbx; 
  class Producer; 
    task run(); 
      for (int i=1; i<4; i++) begin 
        $display("Producer: before put(%0d)", i); 
        mbx.put(i) ; 
      end 
    endtask 
  endclass 
  
  class Consumer; 
    task run(); 
      int i; 
      repeat (3) begin 
        mbx.get(i) ; // Get integer from mbx 
        $display("Consumer: after get(%0d)", i); 
      end 
    endtask 
  endclass 
  
  Producer p; 
  Consumer c; 
  
  initial begin 
    // Construct mailbox, producer, consumer 
    mbx = new(); // Unbounded 
    p = new() ; 
    c = new(); 
    fork // Run the producer and consumer in parallel 
      p.run() ; 
      c.run() ; 
    join 
  end 
endprogram    
    
--------------------------------------------------------------
// synchronized threads using a bounded mailbox and a peek
//Sample 7.41 Producer~onsumer synchronized with bounded mailbox 
program automatic synch_peek; 
  // Uses Producer from Sample 7.39 
  mailbox mbx; 
  class Consumer; 
    task run(); 
      int i; 
      repeat (3) begin 
        mbx.peek(i); // Peek integer from mbx 
        $display("Consumer: after get(%0d)", i); 
        mbx.get(i); // Remove from mbx 
      end 
    endtask 
  endclass 
  initial begin 
    // Construct mailbox, producer, consumer 
    mbx = new(l); // Bounded mailbox - limit 11 
    p = new () ; 
    c = new () ; 
    // Run the producer and consumer in parallel 
    fork 
      p.run() ; 
      c.run() ; 
    join 
  end 
endprogram     
// the consumer uses the build-in mailbox method peek() to look at the data in mailbox without removing
// remove data with get()  
// if the Consumer loop started with get() instead of peek()
// the transaction would be immediately removed from mailbox
    
-----------------------------------------------------------------    
// synchronizes thread using a mailbox and event
// can use an event to block the PRoducer after it puts data in the mailbox.
// the Consumer triggers the event after it consumes the data
//Sample 7.43 Producer-consumer synchronized with an event 
program automatic mbx_evt; 
  event handshake; 
  class Producer; 
    task run; 
      for (int i=1; i<4; i++) begin 
        $display("Producer: before put (%0d)", i); 
        mbx.put(i); 
        @handshake;   // edge-sensitive blocking statement to ensure stop after sending transaction
        $display("Producer: after put(%0d)", i); 
      end 
    endtask 
  endclass 
  // Continued in Sample 7.44 
  
  class Consumer; 
    task run; 
      int i; 
      repeat (3) begin 
        mbx.get(i); 
        $display("Consumer: after get(%0d)", i); 
        ->handshake; 
      end 
    endtask 
  endclass 
  initial begin 
    p = new(); 
    c = new(); 
    // Run the producer and consumer in parallel 
    fork 
      p.run(); 
      c.run(); 
    join 
  end 
endprogram     
 
-------------------------------------------------------------    
// synchronizes thread using 2 mailboxes    
//Sample 7.46 Producer-consumer synchronized with a mailbox 
program automatic mbx_mbx2; 
  mailbox mbx, rtn; 
  
  class Producer; 
    task run(); 
      int k; 
      for (int i=1; i<4; i++) begin 
        $display ("Producer: before put (%0d) ", i); 
        mbx.put(i); 
        rtn.get(k); 
        $display ("Producer: after get (%0d) ", k); 
      end 
    endtask 
  endclass 
  
  class Consumer; 
    task run(); 
      int i; 
      repeat(3) begin 
        $display("Consumer: before get"); 
        mbx.get(i) ; 
        $display("Consumer: after get(%0d)", i); 
        rtn.put(-i) ; 
      end 
    endtask 
  endclass 
  
  initial begin 
    p = new(); 
    c = new(); 
    // Run the producer and consumer in parallel 
    fork 
      p.run(); 
      c.run(); 
    join 
  end 
endprogram     
    
----------------------------------------------------------------    
// Sample 7.48 Basic Transactor 
class Agent; 
  mailbox gen2agt, agt2drv; 
  Transaction tr; 
  
  function new (mailbox gen2agt, agt2drv); 
    this.gen2agt = gen2agt; 
    this.agt2drv = agt2drv; 
  endfunction 
  
  task run(); 
    forever begin 
      gen2agt.get(tr); //Get transaction from upstream block 
      ...              // Do some processing
      agt2drv.put(tr) ;// Send it to downstream block 
    end 
  endtask 

  task wrap_up() ;     //Empty for now 
  endtask 

endclass    
    
//The configuration class allows you to randomize the configuration of your system for every simulation   
//Sample 7.49 Configuration class 
class Config; 
  bit [31:0] run_for_n_trans; 
  constraint reasonable  {run_for_n_trans inside {[1:1000]};  } 
endclass    
    
//The Environment class. holds the Generator. Agent. Driver, Monitor. Checker. Scoreboard, and Config objects. and the mailboxes between them. 
//Sample 7.50 Environment class 
class Environment; 
  Generator gen;
  Agent     agt;
  Driver    drv;
  Monitor   mon;
  Checker   chk;
  Scoreboard scb; 
  Config     cfg; 
  mailbox gen2agt, agt2drv, mon2chk; 
  extern function new(); 
  extern function void gen_cfg() ; 
  extern function void build(); 
  extern task run(); 
  extern task wrap_up(); 
endclass 
    
function Environment::new(); 
  cfg = new(); 
endfunction 
    
function void Environment::gen_cfg; 
  assert(cfg.randomize); 
endfunction 

function void Environment::build(); 
  // Initialize mailboxes 
  gen2agt = new();
  agt2drv = new();
  mon2chk = new();
  // Initialize transactors 
  gen = new(gen2agt); 
  agt = new(gen2agt, agt2drv); 
  dry = new(agt2drv); 
  mon = new(mon2chk); 
  chk = new(mon2chk); 
  scb = new(); 
endfunction 
  
task Environment::run(); 
  fork 
    gen.run(cfg.run_for_n_trans) ; 
    agt.run() ; 
    drv.run() ; 
    mon.run() ; 
    chk.run() ; 
    scb.run(cfg.run_for_n_trans) ; 
  join 
endtask 
  
task Environment::wrap_up(); 
  fork 
    gen.wrap_up() ; 
    agt.wrap_up() ; 
    drv.wrap_up() ; 
    mon.wrap_up() ; 
    chk.wrap_up() ; 
    scb.wrap_up() ; 
  join 
endtask    
    
//main test
//Sample 7.51 Basic test program 
program automatic test; 
  Environment env; 
  initial begin 
    env = new(); 
    env.gen_cfg(); 
    env.build (); 
    env.run(); 
    env.wrap_up(); 
  end 
endprogram    
    
    
