define /class in /program /module /package /outside of ant of them
// Sample 5.4 A newO function with arguments 
class Transaction; 
  logic [31:0] addr, crc, data [8] ; 
  function new(logic [31:0] a=3, d=5); 
    addr = a; 
    foreach (data[i])   data[i] = d; 
  endfunction 
endclass 
  
initial begin 
  Transaction tr; 
  tr = new(10); // data uses default of 5 
end 
  
//  Sample 5.5 Calling the right new() function 
class Transaction; 
  ...
endclass : Transaction 
class Driver; 
  Transaction tr; 
  function new();  //driver's new function
    tr = new();    //call the transaction new function
  endfunction 
endclass : Driver 

  // new[] operator is building an array with multiple elements, only takes a single value for the number of elements in the array
  // new() function is caalled to construct a single object. can take arguments for setting object values
 
------------------------------------------------------------  
//Sample 5.10 The class scope resolution operator
class Transaction;
  static int count = 0;  ////Number of objects created
endclass
initial begin
  run_test () ;
  $display("%d transaction were created", Transaction::count); // Reference static w/o handle
end

//Sample 5.11 Static storage for a handle
class Transaction;
  static Config cfg;  //a handle with static storage
  MODE_E mode;
  function new () ;
    mode = cfg.mode;
  endfunction
endclass
Config cfg;
initial begin
  cfg = new (MODE_ON) ;
  Transaction::cfg = cfg;
  ...
end  
  
//Sample 5.12 Static method displays static variable
class Transaction;
  static Config cfg;
  static int count = 0;
  int id;

  // Static method to display static variables.
  static function void display_statics();
    $display ( "Transaction cfg.mode=%s, count=%0d", cfg.mode.name(), count);
  endfunction
endclass
Config cfg;
initial begin
  cfg = new (MODE_ON);
  Transaction::cfg = cfg;
  Transaction::display_statics(); // Static method call
end
// SV doesn't allow a static method to read or write nonstatic variables, such as 'id'  
  
-----------------------------------------------------
//Sample 5.13 Routines in the class
class Transaction;
  bit [31:0] addr, crc, data[8];
  function void display();
    $display("@%0t: TR addr=%h, crc=%h", $time, addr, crc);
    $write("\tdata[0-7]=");
    foreach (data[i]) $write(data[i]);
    $display() ;
  endfunction
endclass
class PCl_Tran;
  bit [31:0] addr, data; // Use realistic names
  function void display();
    $display("@%0t: PCl: addr=%h, data=%h", $time, addr, data);
  endfunction
endclass
Transaction t;
PCl_Tran pc;
initial begin
  t = new();     // construct a transaction
  t.disp1ay() ;  // display a transaction
  pc = new () ;  // construct a PCI transaction
  pc.display() ; // display a PCI transaction
end
  
---------------------------------------------------- 
//Sample 5.14 Out-or-block method declarations
class Transaction;
  bit [31:0] addr, cre, data[8];
  extern function void display();
endclass
    
function void Transaction::display();
  $display ("@%0t: Transaction addr=%h, crc=%h", $time, addr, crc);
  $write("\tdata[0-7]=");
  foreach (data[i]) $write(data[i]);
  $display () ;
endfunction
    
class PCl_Tran;
  bit [31:0] addr, data; // Use realistic names
  extern function void display();
endclass
    
function void PCl_Tran::display();
  $display("@%0t: PCl: addr=%h, data=%h", $time, addr, data);
endfunction  
    
------------------------------------------------------------------
//Sample 5.16 Name scope
int limit;         // $root.limit
program automatic p;
  int limit;       //$root.p.limit
  class Foo;
    int limit, array[]; //$root.p.Foo.limit
    // $root.p.Foo.print.limit
    function void print (int limit);
      for (int i=0; i<limit; i++)
        $display("%m: array[%0d]=%0d", i, array[i]);
    endfunction
  endclass
  
  initial begin
    int limit = $root.limit; // 'limit' is used for a global variable
    Foo bar;
    bar = new();
    bar.array = new [limit] ;
    bar.print (limit);
  end
endprogram
// if a variable is only used in single 'initial' block, 
// you should declare it there to avoid possible name conflicts with other blocks
// if you declare a variable in an unnamed block, there is no hierarchical name that works consistently across all tools

-----------------------------------------------------------------------------------
// 'this' let SV know that u r assigning the local variable    
class Scoping;
  string oname;
  function new(string oname);
    this.oname = oname; // class oname = local oname
  endfunction
endclass    
    
---------------------------------------------------------------    
// using one class inside another
//Sample 5.20 Statistics class declaration
class Statistics;
  time startT, stopT;    //Transaction times
  static int ntrans = 0; // Transaction count
  static time total_elapsed_time = 0;
  function time how_long;
    how_long = stopT - startT;
    ntrans++;
    total_elapsed_time += how_long;
  endfunction
  function void start;
    startT = $time;
  endfunction
endclass
// Sample 5.21 Encapsulating the Statistics class
class Transaction;
  bit [31:0] addr, crc, data[8];
  Statistics stats;  // statistics handle
  function new();
    stats = new();   // make instance of stats
  endfunction
  task create_packet();
    stats.start();
  endtask
endclass    

// Sometimes you need to compile a class that includes another class that is not yet defined. 
// The declaration of the handle causes an error, as the compiler does not recognize the new type. 
// Declare the class name with a typedef statement, as shown below.    
// Sample 5.22 Using a typedef class statement
typedef class Statistics; // Define a lower level class
class Transaction;
  Statistics stats; // Use Statistics class
endclass
class Statistics; // Define Statistics class
  ...
endclass    
    
// Sample 5.23 Passing objects
// Transmit a packet onto a 32-bit bus
task transmit(Transaction t);
  CBbus.rx_data <= t.data;
  t.stats.startT = $time;
endtask
Transaction t;
initial begin
  t = new();    // allocate the object
  t.addr = 42;  // initialize values
  transmit(t) ; // pass object to task
end    
//A common coding mistake is to forget to use 'ref' on method arguments that you want to modify, especially handles. 
  function void create( ref Transaction tr); // remember to use 'ref', otherwise the t in 'initial' will be null
  tr = new ( ) ;
  tr.addr = 42;
  // Initialize other fields
  ...
endfunction
Transaction t;
initial begin
  create(t);
  $display(t.addr) ;
end

//Sample 5.27 Good generator creates many objects
task generator_good(int n) ;
  Transaction t;
  repeat (n) begin
    t = new();          // Create one new object
    //if miss new(), the $display shows many addr values with the same value.
    t.addr = $random(); // Initialize variables
    $display("Sending addr=%h", t.addr);
    transmit(t);        // send it into DUT
  end
endtask
  
//Sample 5.28 Using an array of handles
task generator();
  Transaction tarray[lO] ;
  foreach (tarray[i])
  begin
    tarray[i] = new();  // construct each object
    transmit(tarray[i));
  end
endtask  
                    
//Sample 5.29 Copying a simple class with new
class Transaction;
  bit [31:0] addr, crc, data[B];
endclass
Transaction src, dst;
initial begin
  src = new ();  // create first object
  dst = new src; // make a copy with new operator
end      
                    
// Sample 5.30 Copying a complex class with new operator
class Transaction;
  bit [31:0] addr, crc, data[8];
  static int count 0;
  int id;
  Statistics stats; // Handle points to Statistics object
  function new();
    stats = new(); // Construct a new Statistics obecjt
    id = count++;
  endfunction
endclass
Transaction src, dst;
initial begin
  src = new();           // Create a Transaction object
  src.stats.startT = 42; // results in 42
  dst = new src;         // Copy src to dst with new operator, startT in dist = 42
  dst.stats.startT = 96; // Changes stats for dst & src, both = 96
  $display(src.stats.startT); 
end
                   
//Sample 5.31 Simple class with copy function
class Transaction;
  bit [31:0] addr, crc, data[8]; // no statistic handle
  function Transaction copy() ;
    copy = new () ;   //construct destination
    copy.addr = addr; // fill in data values
    copy.crc  = crc;
    copy.data = data; // array copy
  endfunction
endclass

// Sample 5.32 Using a copy function
Transaction src, dst;
initial begin
  src = new();       // create first object
  dst = src.copy();  // make a copy of object
end

//Sample 5.33 Complex class with deep copy function
class Transaction;
  bit [31:0] addr, crc, data[8];
  Statistics stats; // Handle points to Statistics object
  static int count = 0;
  int id;
  
  function new();
    stats = new();
    id = count++;
  endfunction
  
  function Transaction copy();
    copy = new();     // construct destination object
    copy.addr = addr; // fill  in data values
    copy.crc  = crc;
    copy.data = data;
    copy.stats = stats.copy();  // call statistics::copy
  endfunction
endclass          
                    
class Statistics;
  time startT, stopT; // Transaction times
  ...
  function Statistics copy();
    copy = new();
    copy.startT = startT
    copy.stopT  = stopT;
  endfunction
endclass         
                    
//Sample 5.35 Copying a complex class with new operator
Transaction src, dst;
initial begin
  src = new();           // Create first object
  src.stats.startT = 42; // Set start time
  dst = new src;         // Copy src to dst with deep copy
  dst.stats.startT 96;   // Changes stats for dst only
  $display(src.stats.startT);  // stats in src = 42; stats in dst = 96
end        
                    
-------------------------------------------------------------------------
Sample 5.36 Transaction class with pack and unpack functions
class Transaction;
  bit [31:0] addr, crc, data [8] ; // Real data
  static int count = 0;
  int id;
  function newel;
    id = count++;
  endfunction
  function void display();
    $write("Tr: id=%Od, addr=%x, crc=%x", id, addr, crc);
    foreach(data[i]) $write(" %x", data[i]);
    $display;
  endfunction
  function void pack(ref byte bytes[40]);
    bytes = { >> {addr, crc, data}};
  endfunction
  function Transaction unpack(ref byte bytes[40]);
    { >> {addr, crc, data}} = bytes;
  endfunction
endclass : Transaction
  
//Sample 5.37 Using the pack and unpack functions
Transaction tr, tr2;
byte b[40];
initial begin
  tr = new() ;  // addr + crc + data = 40 bytes
  tr.addr = 32'ha0a0a0a0;
  tr.crc = '1;
  foreach (tr.data[i])  tr.data[i] = i;
  tr.pack(b);  // Pack object into byte array
  $write("Pack results: ");
  foreach(b[i])  $write("%h", b[i]);
  $display;
  tr2 = new();
  tr2.unpack(b) ;
  tr2.display () ;
end                    
