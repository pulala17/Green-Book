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
  
--------------------------------------------------
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
                                    
-------------------------------------------  
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
  
  
  
  
