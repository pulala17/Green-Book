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
  
