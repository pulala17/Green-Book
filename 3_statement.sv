/*
Task:     consume time
Function: not consume time, cannot have a delay a blocking statement or call a task
*/

//Sample Verilog
task mytask2;
  output [31:0] x;
  reg    [31:0] x;
  input y;
  ...
end task
  
//Sample System Verilog
task mytaskl (output logic [31:0] x,
               input logic y);
endtask  
  
  task T3(a, b, output bit [15:0] u, v);
// a and b are input logic, 1-bit wide
// u and v are 16-bit output bit types                          
    
    
// Sampie 3.10 Passing arrays using ref and const
function void print_checksum (const ref bit [31:0] a[]);
  bit [31:0] checksum = 0;
  for (int i=0; i<a.size(); i++)
    checksum ^= a[i];
  $display("The array checksum is %0d", checksum);
endfunction  
    
/* always use 'ref' when passing arrays to a routine for best performance
    If you don't want the routine to change the array values, use the 'const ref' type, 
    which causes the compiler to check that your routine does not Illodify the array.
 * a second benefit of 'ref' arguments is
    a task can modify a variable and is instantly seen by the calling function
*/
    
// Sample 3.11 Using across threads
task bus_read(input logic [31:0] addr,
                ref logic [31:0] data);
  
  // Request bus and drive address
  bus.request = 1'b1;
  @(posedge bus.grant) bus.addr = addr;
  
  // Wait for data from memory
  @(posedge bus.enable) data = bus.data;
  
  // Release bus and wait for grant
  bus.request = 1'b0;
  @(negedge bus.grant);
endtask
    
logic [31:0] addr, data;
    
initial
  fork
    bus_read(addr, data);
    thread2: begin
      @data;      // Trigger on data change
      $display("Read %h from bus", data);
    end
  join
    ...
end
/* The 'data' argument is passed as 'ref',
    and as a result, the '@data' statement triggers as soon as data changes in the task. 
    If you had declared 'data' as 'output', 
    the '@data' statement would not trigger until the end of the bus transaction. 
*/
    
//Sampie 3.12 Function with default argument values
function void print checksum( ref bit [31:0] a[],
                              input bit [31:0] low 0,
                              input int high = -1);
  bit [31:0] checksum = 0;
  
  if (high == -1 || high >= a.size() )
    high = a.size()-l;
  for (int i=low; i<=high; i++)
    checksum += a[i];
  $display ("The array checksum is %0d", sum);
endfunction    

// Sample 3.13 Using default argument values
print_checksum(a) ;        // Checksum a[O:size() -1] - default
print_checksum(a, 2, 4) ;  // Checksum a[2:4]
print_checksum(a, 1) ;     // Start at 1
print_checksum(a,, 2) ;     // Checksum a [0: 2]
print_checksum();          // Compile error: a has no default    

    
//Sampie 3.14 Binding arguments by name
task many (input int a=l, b=2, c=3, d=4);
  $display("%0d %0d %0d %0d", a, b, c, d);
endtask
initial begin        // a b c d
  many(6, 7, 8, 9) ; // 6 7 8 9 Specify all values
  many() ;           // 1 2 3 4 Use defaults
  many(.c(5)) ;      // 1 2 5 4 Only specify c
  many(, 6, .d(8));  // 1 6 3 8 Mix styles
end
    
    
// Sample 3.16 Task header with additional array argument
    task sticky ( ref int array[50],
                 int a,b);
      // a and b take the direction of the previous argument: 'ref'
    task sticky ( ref int array[50],
                  input int a,b); // be explicit
      
// Sample 3.19 Return in a task
task load_array(int len, ref int array[]);
  if (len <= 0) begin
  $display ("Bad len");
  return;
  end
  // Code for the rest of the task
  ...
endtask
      
      
// Sample 3.20 returning an array from a function with a typedef
      typedef int fixed_array5[5];
      fixed_array5 f5;
      
      function fixed_array5 init(int start)
        foreach (init[i])
          init[i] = i + start;
      endfunction
      
      initial begin
        f5 = init(5);
        foreach (f5[i])
          $display ( "f5[%0d] = %0d", i, f5[i]);
      end
      
      
      
    
    
