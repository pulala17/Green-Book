There is different use of randomization in verilog, system verilog and uvm
----------------------------------------------
in Verilog.

• $random()- //Flat distribution, returning signed 32-bit random
• $urandom() -//Flat distribution, returning unsigned 32-bit random
• $urandom_range() - //Flat distribution over a range
• $dist_exponential () - //Exponential decay, as shown in Figure 6-1
• $dist_normal () - //Bell-shaped distribution
• $dist_poisson () - //Bell-shaped distribution
• $dist_uniform () - //Flat distribution
The $urandom_range () function takes two arguments, an optional low value, and a high value.
  a = $urandom_range(3, 10) ; // Pick a value from 3 to 10
  a = $urandom_range(10, 3) ; // Pick a value from 3 to 10
  b = $urandom_range(5); // Pick a value from 0 to 5
----------------------------------------------
  
Here is what noted in Chapter6 from Green-book.
<--------------------------------------------->
// Sample 6.1 Simple random class
class Packet;
  rand bit [31:0] src, dst, data[8];// The random variables
  randc bit [7:0] kind;
  constraint c {src > 10; 
                src < 15; } //Limit the values for src
endclass
Packet p;
initial begin
  p = new();    //Create a packet
  assert (p.randomize())
  else $fatal(O, "Packet::randomize failed");
  transmit(p) ;
end
  
// randc, which means random cyclic. 
// so that the random solver docs not repeat a random value until evcry possible value has been assigned.
-----------------------------------------------  
// can randomize integers, bit vectors, etc. 
// cannot have a random string, or refer to a handle in a constraint.  
------------------------------------------------  
// Sample 6.3 Constrained-random class
class Stim;
  const bit [31:0] CONGEST_ADDR = 42;
  typedef enum {READ, WRITE, CONTROL} stim_e;
  randc stim_e kind;                   // Enumerated var
  rand bit [31:0] len, src, dst;
  bit congestion_test;
  
  constraint c_stim {
    len < 1000;
    len > 0;
    if (congestion_test) {
      dst inside {[CONGEST_ADDR-100:CONGEST_ADDR+100]};
      src CONGEST_ADDR;
  }
  else
    src inside {O, [2:10], [100:107]};
  }
endclass
-------------------------------------------------------  
// Sample 6.6 Constrain variables to be in a fixed order
class order;
  rand bit [15:0] 10, med, hi;
  constraint good {10 < med;   //Only use binary constraints
                   med < hi;}  //cannot write as "constraint bad {lo < med < hi;}"
                               // (lo < med < hi) --> ((lo < med) < hi) --> ((0 or 1) < hi)
endclass  
------------------------------------------------------------- 
// The values and weights can be constants or variables. 
// The values can be a single value or a range such as [lo: hi] . 
// The weights are not percentages and do not have to add up to 100. 
// The := operator specifies that the weight is the same for every specified value in the range
// The :/ operator specifies that the weight is to be equally divided between all the values.
  
// Sample 6.7 Weighted random distribution with dist
rand int src, dst;
constraint c_dist {
  src dist {0:=40, [1:3] :=60}; // src 0, weight 40/220; src 1, weight 60/220; src 2, weight 60/220; src 3, weight 60/220
  dst dist {0:/40, [1:3] :/60}; // dst 0, weight 40/100; dst 1, weight 20/100; dst 2, weight 20/100; dst 3, weight 20/100
}
  
// Sample 6.8 Dynamically changing distribution weights
// Bus operation, byte, word, or longword
class BusOp;
  typedef enum {BYTE, WORD, LWRD } length_e;  // Operand length
  rand length_e len;
  bit [31:0] w_byte=l, w_word=3, w_lwrd=5;  // Weights for dist constraint
  constraint c len {
    len dist {BYTE := w_byte,   // choose a random length using variable weights
              WORD := w_word,   
              LWRD := w_lwrd} ; 
  }
endclass  
-----------------------------------------------------  
// Sample 6.9 Random sets of values
rand int c; // Random variable
int 10, hi; // Non-random variables used as limits
constraint c_range {
  c inside {[lo:hi]}; // 10<=c && c<=hi
}
  
// Sample 6.10 Specifying minimum and maximum range with $
rand bit [6: 0] b; // 0<=b<= 127
rand bit [5: 0] e; // 0<=e<= 63
constraint c _range {
  b inside {[$:4], [20:$}; // 0<=b<=4 || 20<=b<=127
  e inside {[$:4], [20:$}; // 0<=e<=4 || 20<=e<=63
}
                    
// Sample 6.11 Inverted random set constraint
constraint c_range {
  ! (c inside {[lo:hi]} );  //c<10 or c>hi
}                    
--------------------------------------------------
// Sample 6.12 Random set constraint for an array
rand int f;
int fib[5] = '{1,2,3,5,8};
constraint c fibonacci {  f inside fib;  }
                    
// This is expanded into the following set of constraints:
                    
// Sample 6.13 Equivalent set of constraints
constraint c_fibonacci {
  (f == fib [0] ) || (f == fib [1]) || (f == fib [2]) || (f == fib [3] ) || (f == fib [4]); 
  // f==1  || f==2 || f==3 || f==5 || f==8       
}
--------------------------------------------------                   
// Sample 6.14 Repeated values in inside constraint
class Weighted;
    rand int val;
    int array[] = '{1,1,2,3,5,8,8,8,8,8};
    constraint c {val inside array;}
endclass
                    
Weighted w;
                    
initial begin
  int count [9] , maxx[$];
  w = new();
  
  repeat (2000) begin
    assert( w.randomize() );
    count[w.val]++;   // Count the number of hits
  end
  
  maxx = count.max(); // Get largest value in count
  
  // Print histogram of count
  foreach(count[i])
  if (count[i]) begin
    $write("count[%Od] = %5d", i, count[i] );
    repeat(count[i]*40/maxx[0]) $write("*");
    $display;
  end
end                    
-----------------------------------------
// Sample 6.16 Class to choose from an array ofpossihle values
class Days;
  typedef enum {SUN, MON, TUE, WED,THO, FRI, SAT} days_e;
  days_e choices[$];
  rand days_e choice;
  constraint cday {choice inside choices;}
endclass
                  
// Choosing from an array of values
initial begin
  Days days;
  days = new () ;
  
  days.choices = {Days::SUN, Days::SAT};
  assert (days.randomize());
  $display("Random weekend day %s\n", days.choice.name);
  
  days.choices = {Days::MON, Days::TUE, Days::WED, Days::THU, Days::FRI};
  assert (days.randomize());
  $display ("Random week day %s ", days.choice.name) ; // the name() function returns a string with the name of an enumerated value
end
---------------------------------------------------------------------                   
// Sample 6.18 Using randc to choose array values in random order
class RandcInside;
  int array[];  //Values to choose
  randc bit [15:0] index;  //Index into array
  
  function new(input int a[]); // construct & initialize
    array = a;
  endfunction
  
  function int pick;  //  Return most recent pick
    return array [index] ;
  endfunction

  constraint c size {index < array.size();}
endclass
                
initial begin
  RandcInside ri;
  ri = new('{l,3,5,7,9,ll,13});
  repeat (ri.array.size()) begin
    assert(ri.randomize());
    $display("Picked %2d [%Od]", ri.pick(), ri.index);
  end
end                    
----------------------------------------------------------                   
//Sample 6.19 Constraint block with implication operator

constraint c io {
  (io_space_mode) -> addr[31] == l'b1;
}                    
                    
// Sample 6.20 Constraint block with if-else operator
class BusOp;
constraint c_len_rw {
  if (op == READ)
    len inside { [BYTE:LWRD] };
  else
    len == LWRD;
}                    
------------------------------     
// System Verilog solves constraints simultaneously.
// System Verilog constraints are bidirectional, which means that the constraints on all random variables are solved concurrently.
  
// However. multiplication, division and module are very expensive with 32-bit values. the solver may take a long time to find suitable values.
// Remember that any constant without an explicit size. such as 42 is treated as a 32-bit value.  
// Many constants in hardware are powers of 2.
// so take advantage of this by using bit extraction rather than division and modulo. Likewise. multiplication by a power of two can be replaced by a shift.  
  
---------------------------
// Sample 6.24 Class unconstrained
class Unconstrained;
  rand bit x; II 0 or 1
  rand bit [1:0] y; // 0, 1, 2, or 3
endclass
// There are eight possible solutions. Since there are no constraints, each has the same probability.

--------------------------------------
// Sample 6.25 Probility
class Imp1;
  rand bit x; // 0 or 1
  rand bit [1:0] y;  // 0, 1, 2, or 3
  constraint c_xy {  (x==O) -> y==O;  }  // if(x==0) y==0;
endclass
  // P(x==0, y==0)=1/2, P(x==0, y==1)=0, P(x==0, y==2)=0, P(x==0, y==3)=0, 
  // P(x==1, y==0)=1/8, P(x==1, y==1)=1/8, P(x==1, y==2)=1/8, P(x==1, y==3)=1/8
----------------------------------------
//  Sample 6.27 Class with implication and sol ve ... before
class SolveBefore;
  rand bit x;
  rand bit [1:0] y;
  constraint c_xy { 
     (x==O) -> y==O; 
     solve x before y;
  }
endclass
// The 'solve ... before' constraint does not change the solution space, just the probability of the results.
// 'solve x before y': The solver chooses values of x (0, 1) with equal probability  
  
------------------------------------------------
//  At run-time. can use the built-in constraint_mode () routine to turn constraints on and off. 
// can control a single constraint with 'handle.constraint.constraint_mode()'. 
// To control all constraints in an object use 'handle.constraint_mode()'.
  
// Sample 6.28 Using constraint_mode
class Packet;
  rand int length;
  constraint c_short {length inside {[1:32]}; }
  constraint c_Iong  {length inside {[lOOO:l023]}; }
endclass
  
Packet p;

initial begin
  p = new();
  // Create a long packet by disabling short constraint
  p.c_short.constraint_mode(O) ;  
  assert (p.randomize());
  transmit(p);
  // Create a short packet by disabling all constraints
  // then enabling only the short constraint
  p.constraint_mode(O);
  p.c_short.constraint_mode(l);
  assert (p.randomize());
  transmit(p) ;
end
  
----------------------------
// SystemVerilog allows to add an extra constraint using 'randomize () with'
// Sample 6.30 The randomize () with statement
class Transaction;
  rand bit [31:0] addr, data;
  constraint c1 {addr inside{[0:100], [1000:2000]};}
endclass
Transaction t;
  
initial begin
  t = new();
  
  // addr is 50-100, 1000-1500, data < 10
  assert ( t.randomize() with {addr >= 50;  addr <= 1500;  data < 10;} );
  driveBus(t);
  
  // force addr to a specific value, data> 10
  assert (t.randomize () with {addr == 2000; data> 10;});
  driveBus(t);
end  
// SystemVerilog uses the scope of the class. That is why Sample 6.30 used just addr, not t.addr.
  
-----------------------------------------------------------------------------------------------
//  set some nonrandom class variables (such as limits or weights) before randomization starts, or you may need to calculate the error correction bits for random data.
// System Verilog lets you do this with two special void functions, 'pre_randomize' and 'post_randomize'.
// Sample 6.31 Building a bathtub distribution
class Bathtub;
  int value; // Random variable with bathtub dist
  int WIDTH = 50, DEPTH=4, seed=l;
  function void pre_randomize();
    // Calculate an exponental curve
    value = $dist_exponential (seed, DEPTH);
    if (value > WIDTH)  value = WIDTH;
    // Randomly put this point on the left or right curve
    if ($urandom_range(l))  value = WIDTH - value;
  endfunction
endclass
  
----------------------------------------------------------------
//  Sample 6.33 Constraint with a variable bound
class bounds;
  rand int size;
  int max size = 100;
  constraint c_size { size inside {[l:max_sizel}; }
endclass

// Sample 6.34 dist constraint with variable weights
typedef enum (READ8, READ16, READ32) read e;
class ReadCommands;
  rand read_e read_cmd;
  int read8_wt=1, read16_wt=1, read32_wt=1;
  constraint c_read {
    read cmd dist {
       READ8 := read8_wt,
      READ16 := read16_wt,
      READ32 := read32_wt};
  }
endclass
                                    
---------------------------------------------------------------------------  
// Sample 6.35 rand_mode disables randomization of variables
// Packet with variable length payload
class Packet;
  rand bit [7:0] length, payload[];
  constraint c valid {length > 0;
                      payload.size() == length; }
  function void display(string msg);
    $display ("\n%s ", msg);
    length;}
    $write("Packet len=%Od, payload size=%Od", length, payload.size());
    for (int i=O; (i<4 && i<payload.size() ); i++)
      $write("%Od", payload[i]);
    $display;
  endfunction
endclass
Packet p;
initial begin
  p = new () ;
  assert (p.randomize());    // Randomize all variables
  p.display("Simple randomize");
  p.length.rand_mode (0) ;   // Make length nonrandom,
  p.length = 42;             // set it to a constant value
  assert (p.randomize());    //then randomize the payload
  p.display("Randomize with rand_mode");
end  

----------------------------------------------------------------------------
// Call 'handle.randomize(null)' and System Verilog treats all variables as nonrandom ("state variables") and just ensures that all constraints are satisfied.  
----------------------------------------------------------------------------
// Sample 6.36 Randomizing a subset of variables in a class
class Rising;
  byte low;           // not random
  rand byte med, hi;  // random variable
  constraint up { low < med; med < hi; } 
endclass
initial begin
  Rising r;
  r = new () ;
  r.randomize() ;        //Randomize med, hi; low untouched
  r.randomize(med) ;     //Randomize only med
  r.randomize(low);      //Randomize only low
end
--------------------------------------------------------------------------
// Sample 6.37 Using the implication constraint as a case statement
class Instruction;
  typedef enum {NOP, HALT, CLR, NOT} opcode_e;
  rand opcode_e opcode;
  bit [1:0] n_operands;
  constraint c_operands {
    if (n_operands == 0)        opcode == NOP || opcode == HALT;
    else if (n_operands == 1)   opcode == CLR || opcode == NOT;
    .........
  }
endclass
---------------------------------------------------------------------------
// Sample 6.38 Turning constraints on and otT with constraint_mode
class Instruction;
  rand opcode_e opcode;
  constraint c_no_operands { opcode == NOP || opcode == HALT;}
  constraint c_one_operand { opcode == CLR || opcode == NOT;}
endclass
Instruction instr;
initial begin
  instr = new () ;
  // Generate an instruction with no operands
  instr.constraint_mode(O); // Turn off all constraints
  instr.c_no_operands.constraint_mode(l);
  assert (instr.randomize());
  // Generate an instruction with one operand
  instr.constraint_mode(O); // Turn off all constraints
  instr.c_one_operand.constraint_mode(l);
  assert (instr.randomize());
end
--------------------------------------------------------------------                                    
// Sample 6.39 Class with an external constraint
// packet.sv
class Packet;
  rand bit [7:0] length;
  rand bit [7:0] payload[];
  constraint c_valid {length> 0;
                      payload.size () == length; }
  constraint c_external;
endclass
// Program defining an external constraint
// test.sv
program test;
  constraint Packet::c_external {length == l;}
endprogram     

//External constraints can be put in a file and thus reused between tests                                    
----------------------------------------------------------------------------
// Sample 6,44 Constraining dynamic array size
class dyn_ size;
  rand logic [31:0] d[];
  constraint d_size { d.size() inside {[1:10]}; }
endclass
// Using the 'inside' constraint lets you set a lower and upper boundary on the array size. 
// In many cases you may not want an empty array. that is .size==O. 
------------------------------------------------------------------------                                                                  
// Sample 6.45 Random strobe pattern class
parameter MAX_TRANS FER_LEN = 10;
class StrobePat;
  rand bit strobe[MAX TRANSFER_LEN];
  constraint c_set_four { strobe.sum() == 4'h4; }
endclass

initial begin
  StrobePat sp;
  int count = 0; // Index into data array
  sp = new();
  assert (sp.randomize());
  foreach (sp.strobe[i]) begin
    @bus.cb;
    bus.cb.strobe <= sp.strobe[i]; 
    //If strobe is enabled, drive out next data word
    if (sp.strobe[i]) bus.cb.data <= data[count++];
  end  
end
----------------------------------------------------------
// Sample 6.55 Simple foreach constraint: good_sumS
class good_sumS;
  rand uint len[];
  constraint c len {foreach (len[i])  len[i] inside {[1:255]};
                    len.sum < 1024;
                    len.size() inside {[1:8]};  } 
endclass

// Sample 6.57 Creating ascending array values with foreach
class Ascend;
  rand uint d[lO] ;
  constraint c {
    foreach (d[i])      //For every element
      if (i>0)          // except the first
        d[i] > d[i-l]; // compare with previous element
  }
endclass 

---------------------------------------------------------                                    
// Sample 6.58 Creating unique array of random unique values with foreach
class UniqueSlow;
  rand bit [7:0] ua[64];
  constraint c {
    foreach (ua[i])  // for every elements
      foreach (ua[j])
        if (i != j)
          ua [i] ! = ua [j] ;
endclass

//  Sample 6.59 Creating unique array values with a rande helper class
class randc8;
  randc bit [7:0] val;
endclass
class LittleUniqueArray;
  bit [7:0] ua [64]; // Array of unique values
  function void pre_randomize;
    randc8 re8;
    re8 = new();
    foreach (ua[i]) begin
      assert(rcS.randomize());
      ua[i] = rc8.val;
    end
  endfunction
endclass
                               
//Sample 6.60 Unique value generator
    // Create unique random values in a range (0:max-l)
class RandcRange;
  randc bit [15:0] value;
  int max_value; // Maximum possible value
  function new(int max_value = 10);
    this.max_value = max_value;
  endfunction
  constraint c_max_value {value < max_value;}
endclass                                    

// Sample 6.61 Class to generate a random array of unique values
class UniqueArray;
  int max_array_size, max_value;
  rand bit [7:0]a[]; // Array of unique values
  constraint c_size {a.size() inside { [1:max_array_size]}; }
  
  function new(int max_array_size=2, max_value=2);
    this.max_array_size = max_array_size;
    // If max_value is smaller than array size, array could have duplicates, so adjust max value
    if (max_value < max_array_size)  this.max_value = max_array_size;
    else  this.max_value = max_value;
  endfunction
  
  // Array a[] allocated in randomize(), fill w/unique vals
  function void post_randomize;
    RandcRange rr;
    rr = new(max_value);
    foreach (a[i]) begin
      assert (rr.randomize());
      a[i] = rr.value;
    end
  endfunction
  
  function void display() ;
    $write("Size: %3d:", a.size());
    foreach (a[i]) $write("%4d", a[i]);
    $display;
  endfunction
endclass
    
// Using the UniqueArray class
program automatic test;
  UniqueArray ua;
  initial begin
    ua = new (50) ; // Array size 50
    repeat (10) begin
      assert(ua.randomize()); //Create random array
      ua.display(); //Display values
    end
  end
endprogram

--------------------------------------------------
// Sample 6.63 Constructing elements in a random array, use dynamic array of handles
parameter MAX_SIZE = 10;
class RandStuff;
  rand int value;
endclass
    
class RandArray;
  rand RandStuff array[]; 
  constraint c {array.size() inside {[l:MAX_SIZE]}; }
  function new();
    array = new[MAX_SIZE] ;
    foreach (array[i])  array[i] = new();
  endfunction;
endclass
    
RandArray ra;
initial begin
  ra = new();              // Construct array and all objects
  assert(ra.randomize()) ; // Randomize and maybe shrink array
  foreach (ra.array[i])  $display(ra.array[i].value);
end   

---------------------------------------------------------------    
// Sample 6.64 Command generator using randsequence
initial begin
  for (int i=0; i<15; i++) begin
    randsequence(stream)
      stream  :    cfg_read := 1 | io_read := 2 | mem_read := 5;
    cfg_read: {cfg_read_task;} | {cfg_read_task;} cfg_read;  //A 'cfg_read' can be either a single call to the 'cfg_read_task', or a call to the task followed by another 'cfg_read'.
      mem_read: {mem_read_task;} | {mem_read_task;} mem_read;
      io_read :  {io_read_task;} | {io_read_task;} io_read;
    endsequence
  end // for
end
task cfg_read_task;
  ...
endtask
task mem_read_task;
  ...
endtask
task io_read_task;
  ...
endtask
// The code to generate the sequence is separate and a very different style from the classes with data and constraints used by the sequence.
// if you use both randomize () and randsequence, you have to master two difTerent forms of randomization.    

// Sample 6.65 Random control with randcase and $urandom_range
initial begin
  int len;
  randcase
    1: len = $urandom_range(0, 2);   //10%: 0,1,2
    8: len = $urandom_range(3, 5);   //80%: 3,4,5
    1: len = $urandom_range(6, 7);   //10%: 6,7
  endcase
  $display ("len=%Od", len);
end   
// constraint c {len dist { [0:2]:=1, [3:5]:=8, [6:7]:=1}; }    
// choose the branches based on the weight    

//Sample 6.67 Creating a decision tree with randcase
initial begin
  // Level 1
  randcase
    one_write_wt: do_one_write();
    one_read_wt:  do_one_read();
    seq_write_wt: do_seq_write();
    seq_read_wt:  do_seq_read();
  endcase
end

task do_one_write;
  randcase
    mem_write_wt: do_mem_write();
    io_write_wt:  do_io_write();
    cfg_write_wt: do_cfg_write();
  endcase
endtask
    
task do_one_read;
  randcase
    mem_read_wt: do_mem_read();
    io_read_wt:  do_io_read();
    cfg_read_wt: do_cfg_read();
  endcase
endtask

-----------------------------------------------------
//Sample 6.71 Ethernet switch configuration class
class eth_cfg;
  rand bit [ 3:0] in_use;        //ports used in test
  rand bit [47:0] mac addr[4];   
  rand bit [ 3:0] is_100;       //100mb mode
  rand uint run_for_n_frames;

  // Force some addr bits when running in unicast mode
  constraint local_unicast {
    foreach (mac_addr[i])   mac_addr[i][41:40] == 2'b00;
  }
  constraint reasonable { // Limit test length
  run_for_n_frames inside {[1:100]};
  }
endclass : eth_cfg

//Sample 6.72 Building environment with random configuration
class Environment;
  eth_cfg cfg;
  eth_src gen[4];
  eth_mii drv[4];
  
  function new() ;
    cfg = new();  // Construct the cfg
  endfunction
  
  function void gen_cfg;
    assert(cfg.randomize()); // Randomize the cfg
  endfunction
  
  // Use random configuration to build the environment
  function void build();
    foreach (gen[i])
      if (cfg.in_use[i]) begin
        gen [i] = new () ;
        drv [i] = new () ;
        if (cfg.is_100[i])  drv[i].set_speed(lOO);
      end
  endfunction
  
  task run();
    foreach (gen[i])
      if (cfg.in_use[i]) begin 
        // Start the testbench transactors
        gen[i].run();
      end
  endtask
  
  task wrap_up () ;
    // Not currently used
  endtask
  
endclass : Environment
   
// Sample 6.73 Simple test using random configuration
program test;
  Environment env;
  initial begin
    env = new();   // construct environment
    env.gen_cfg;   // create random configuration
    env.build();   // build the testbench environment
    env.run();     // run the test
    env.wrap_up() ; // clean up after test & report
  end
endprogram

//Sample 6.74 Simple test that overrides random configuration
program test;
  Environment env;
  initial begin
    env = new(); // Construct environment
    env.gen_cfg; // Create random configuration
    // Override random in-use - turn all 4 ports on
    env.cfg.in_use = 4'bllll;
    env.build();   //build the testbench environment
    env.run();     // run test
    env.wrap_up(); //clean up after test & report
  end
endprogram

