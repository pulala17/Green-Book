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
    
    
