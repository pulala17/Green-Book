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
    
    
    
    
    
