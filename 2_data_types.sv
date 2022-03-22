//
// SystemVerilog introduces new data types with the following benefits.
//    • Two-state: better performance, reduced memory usage
//    • Queues, dynamic and associative arrays: reduced memory usage, built-in support for searching and sorting
//    • Classes and structures: support for abstract data structures
//    • Unions and packed structures: allow multiple views ofthe same data
//    • Strings: built-in string support
//    • Enumerated types: code is easier to write and understand


// A 'logic' signal can be used anywhere a net is used, 
// except that a logic variable cannot be driven by [multiple structural drivers], 
// such as when you are modeling a [bidirectional bus]. 
// In this case, the variable needs to be a net-type such as 'wire' so that SV can resolve the multiple values to determine the final value.

//Sample 2.2 Signed data types
bit b;            // 2-state, single-bit
bit [31:0] b32;   // 2-state, 32-bit unsigned integer
int unsigned Ui;  // 2-state, 32-bit unsigned integer
int i;            // 2-state, 16-bit signed integer
byte b8;          // 2-state,  8-bit signed integer
shortint s;       // 2-state, 16-bit signed integer
longint l;        // 2-state, 64-bit signed integer
integer i4;       // 2-state, 32-bit signed integer
time t;           // 2-state, 64-bit unsigned integer
real r;           //  2-state, double precision floating pt


//Sample 2.3 Checking for 4-state values
if ($isunknown(iport) == 1)
  $display("@%0t: 4-state value detected on iport %b", $time, iport);
// Use the $isunknown() operator that returns 1 if any bit of the expression is X or Z.
// The format %0t and the argument $time print the current simulation time.

// Many SystemVerilog simulators store each element on a 32-bit word boundary.
// Sample 2.6 Unpacked array declarations
bit [7:0] b_unpack[3]; // Unpacked
// for b_unpack[0], b_unpack[1], b_unpack[2], their [7:0] are used, the left [31:8] are unused space

//Sample 2.7 Initializing an array
int ascend[4] = '{0,1,2,3}; // Initialize 4 elements
int descend[5] ;            
descend = '{4,3,2,1,0};     // set 5 elements
descend[0:2] = '{5,6,7};    // set first 3 elements
ascend = '{4{8}};           // four values of 8
descend= '{9, 8, default:-1};// {9, 8, -1, -1, -1}

//Sample 2.8 Using arrays with for- and foreach-Ioops
initial begin
  bit [31:0] src[5], dst[5];
  for (int i=0; i<$size(src); i++)
    src [i] = i;
  foreach (dst[j])
    dst[j] = src[j] * 2; // dst doubles src values
end

// Sample 2.9 Initialize and step through a multidimensional array
int md[2][3] = '{'{0,1,2}, '{3,4,5}};
initial begin
  $disp1ay("Initial value:");
  foreach (md[i,j]) 
    $display ("md [%0d] [%0d] = %0d", i, j, md[i][j] );
  $display ("New value:") ;
  // Replicate last 3 values of 5
  md = '{'{9, 8, 7}, '{3{'5}}};
  foreach (md[i,j]) 
    $display ("md [%0d] [%0d] = %0d", i, j, md[i][j]) ;
end
// Instead of listing each subscript in separate square brackets - [i][j]- they are combined with a comma - [i,j] .

//Sample 2.11 Printing a multidimensional array
initial begin
  byte twoD[4][6];
  foreach(twoD[i,j])
    twoD[i][j] = i * 10 + j;
  foreach (twoD[i]) begin  // step through first dimension
    $write("%2d:", i);
    foreach(twoD[,j])      // step through second dimension
      $write("%3d", twoD[i][j]);
      $display;
  end
end

// The array 'f[5]' is equivalent to 'f[O:4]'
// a 'foreach(f[i])' is equivalent to 'for(int i=O; i<=4; i++)'. 
// With the array 'rev[6:2]', the statement 'foreach (rev[i])' is equivalent to 'for(int i=6; i>=2; i--)'

// Sample 2.15 Packed array declaration and usage
bit [3:0] [7:0] bytes;      // 4 bytes packed into 32-bits
bytes = 32'hCafe_Dada;
$displayh(bytes,,           // Show all 32-bits
          bytes [3],,       // Most significant byte "CA"
          bytes [3] [7] ) ; // Most significant bit "I"
//
//         | bytes [3]| bytes [2]| bytes [1]| bytes [0]| 
// bytes : | 76543210 | 76543210 | 76543210 | 76543210 |

// Sample 2.16 Declaration for a mixed packed/unpacked array
bit [3:0] [7:0] barray [3];    // Packed: 3x32-bit
bit [31:0] lw = 32'h0123 4567; // Word
bi t [7:0] [3:0] nibbles; //Packed array of nibbles
barray[0] = lw;
barray[0][3] = 8'h01;
barray[0][1][6] = 1'b1;
nibbles = barray[0];      // Copy packed values

//            | b [0][3] | b [0][2] | b [0][1] | b [0][0] |
// barray [0] | 76543210 | 76543210 | 76543210 | 76543210 |
// barray [1] | 76543210 | 76543210 | 76543210 | 76543210 |
// barray [2] | 76543210 | 76543210 | 76543210 | 76543210 |

// Note: because one dimension is specified after the name,
// barray [3] , that dimension is unpacked,

// A packed array is handy if u need to convert to and from scalars. 
// For example, you might need to reference a memory as a byte or as a word.
// If you need to wait for a change in an array, you have to use a packed array. 
// Perhaps your testbench might need to wake up when a memory changes value, and so you want to use the @operator.
// This is however only legal with scalar values and packed arrays.

------------------------------------------------------------------------------------------------------------------------
// Sample 2.17 Using dynamic arrays
int dyn[], d2[]; // Declare dynamic arrays
initial begin
  dyn = new[5];                 // A: Allocate 5 elements
  foreach (dyn[j]) dyn[j] = j;  // B: Initialize the elements
  d2 = dyn;                     // C: Copy a dynamic array
  d2[0] = 5;                    // D: Modify the copy
  $display (dyn[0], d2[0]);     // E: See both values (0 & 5)
  dyn = new[20] (dyn);          // F: Allocate 20 ints 
                                // & copy the existing 5 elements of dyn to the beginning of the array
  dyn = new[100];               // G: Allocate 100 new ints.   Old values are lost
  dyn.delete();                 // H: Delete all elements
end

// Sample 2.18 Using a dynamic array for an uncounted list
bit [7:0] mask[] = '{8'b0000_0000, 8'b0000_0001,
                     8'b0000_0011, 8'b0000_0111,
                     8'b0000_2111, 8'b0001_1111,
                     8'b0011_1111, 8'b0111 1111,
                     8'b1111_1111} ;
// there are 9 masks for 8 bits, can let SV coungt them, 
// rather than making a fixed-size array adn accidently choosing the wrong size of other numbers

// dynamic array can be assigned to a fixed array (when they have same number of elements)

------------------------------------------------------------------------------------------
[QUEUE]
// A queue is declared with [$]
// the elements of a queue are numbered from 0 to $

// Sample 2.19 Queue operations
int j = 1,
q2[$] = {3, 4},     // queue literals do not use '
q[$]  = {0, 2, 5};
initial begin
  q.insert(1, j);   // insert 1 before 2
  q.insert(3, q2);  // insert queue in q1
  q.delete(1);      // delete elem. #1
  
  // these operation are fast
  q.push_front(6);  // insert at front
  j = q.pop_back;   // j = 5
  q.push_back(8);   // insert at back
  j = q.pop_front;  // j = 6
  foreach (q[i])
    $display (q[i]);  // print entire queue
  q.delete() ;        // delete entire queue
end

// Note that queue literals only have curly braces, 
// and are missing the initial apostrophe of array literals

// if $ on the left side eg.[$:2],  $ stands for the min. value, [0:2]
// if $ on the right side eg.[3:$], $ stands for the max. value

// Sample 2.20 Queue operations
int j = 1,
q2[$] = {3, 4}, 
q[$] = {0,2,5};
initial begin
  q = {q[0], j, q[1:$]};    // {0,1,2,5} insert 1 before 2
  q = {q[0:2], q2, q[3:$]}; // {0,1,2,3,4,5} insert queue in q
  q = {q[0], q[2:$]};       // {0,2,3,4,5} delete elem. #1

  // these operations are fast
  q = {6,q};    // {6,0,2,3,4,5} insert at front
  j = q[$];     // j = 5
  q = q[0:$-1]; // {6,0,2,3,4} pop_back
  q = {q,8};    // {6,0,2,3,4,8}  insert at back
  j = q[0];     // j = 6
  q = q[1:$];   // {0,2,3,4,8} pop_front
  q = {};       // delete entire queue
end

---------------------------------------------------------------------------------
[ ASSOCIATIVE ARRAYS ]
// When modeling a processor that has a multi-gigabyte address range. 
// During a typical test, the processor may only touch a few hundred or thousand memory locations 
// which containing executable code and data, so allocating and initializing gigabytes of storage is wasteful.
//
// SV offers associative arrays to store entries in a sparse matrix

// Sample 2.21 Declaring. initializing. and using associative arrays
initial begin
  bit [63:0] assoc[int], idx = 1;
  
  // Initialize widely scattered values
  repeat (64) begin
    assoc[idx] = idx;
    idx = idx << 1;
  end
  
  // Step through all index values with foreach
  foreach (assoc[i])
    $ display (Rassoc [%h] = %h", i, assoc[i]);
               
  // Step through all index values with functions
  if (assoc.first(idx)) begin
    do
      $display ("assoc[%h] = %h", idx, assoc[idx]);
    while (assoc.next(idx)); // Get next index
  end
  // Find and delete the first element
  assoc.first(idx);
  assoc.delete(idx) ;
  $display("The array now has %0d elements", assoc.num);
end

// can use 'first' and 'next' functions in a 'do...while' loop
// these functions modify the index argument, and reture 0 or 1 depending on whether ant elements are left in array
               
// Sample 2.22 Using an associative array with a string index
    /*
    Input file contains:
          42 min address
        1492 max address
    */              
int switch [string], min_address, max_address;
initial begin
  int i, r, file;
  string s;
  file = $fopen("switch.txt", "r");
  while ( ! $feof(file) )  begin
    r = $fscanf(file, "%d %s", i, s);
    switch[s] = i;
  end
  $fclose(file);
  
  // Get the min address, default is 0
  min_address = switch ["min_address"];
  
  // Get the max address, default = 1000
  if (switch.exists("max_address"))
    max_address = switch["max_address"];
  else
    max_address = 1000;

  // Print all switches
  foreach (switch[s])
    $display("switch['%s']=%0d", s, switch[s]);
end

// function 'exist' use to check if an element exists
               
------------------------------------------------------------
[ Array Methods ]   
               
// Sample 2.23 Creating the sum of an array
bit on[10]; // Array of single bits
int total;
initial begin
  foreach (on[i])   on[i] = i;  // on[i] gets 0 or 1
  
  // Print the single-bit sum
  $display("on.sum = %Od", on.sum); // on.sum 1
  
  // Print the sum using 32-bit total
  $display("on.sum = %0d", on.sum + 32'd0); // on.sum = 5
  
  // Sum the values using 32-bits as total is 32-bits
  total = on.sum;
  $display("total = %0d", total); // total = 5
  
  // Compare the sum to a 32-bit value
  if (on.sum >= 32'd5)  // True
    $display("sum has 5 or more l's");
  
  // Compute with 32-bit signed arithimetic
  $display("int sum=%0d", on.sum with (int'(item));
end

// if add values of a single-bit array, result is a single bit

// Sample 2.24 Picking a random element from an associative array
int aa[int], rand_idx, element, count;
           
element = $urandom_range(aa.size()-l),
foreach(aa[i])
  if (count++ == element) begin
    rand_idx = i, // Save the associative array index and quit
    break;
  end
 $display ("%0d element aa [%0d] = %0d", element, rand_idx, aa[rand_idx] );

// $urandom_range(array.size()-l) for queues and dynamic arrays, 
// $urandom_range ($size (array) -1) for fixed arrays, queues, dynamic, and associative arrays.

// If the array was indexed by a string, just change the type of 'idx' to 'string'.           

--------------------------------------------------------------------------------------
// Sample 2.25 Array locator methods: min, max, unique
int f[6] = '{1,6,2,6,8,6};
int d[]  = '{2,4,6,8,10}; 
int q[$] = {1,3,5,7}, tq[$];

tq = q.min();       // {1}
tq = q.max();       // {10}
tq = f.unique();    //{1,6,2,8}

// 'unique' returns a queue of the unique values from the array

// Sample 2.26 Array locator methods: find
int d[] = `{9 ,1, 8, 3, 4, 4}, tq[$] ;
// Find all elements greater than 3
tq = d.find with (item > 3);   //{9,8,4,4}
// Equivalent code
tq.delete();
foreach (d[i])
  if (d[i] > 3)  tq.push_back(d[i]);
           
tq = d.find_index with (item > 3);        // {0,2,4,5}
tq = d.find_first with (item > 99);       // {}     
tq = d.find first_index with (item==8);   // {2} d[2]=8
tq = d.find_last with (item==4);          // {4}
tq = d.find_last_index with (item==4);    // {5} d[5]=4


// These are equivalent. Declaring the iterator argument
tq d.find first with (item==4);
tq d.find first() with (item==4) ;
tq d.find first(item) with (item==4); 
tq d.find first(x) with (x==4) ;

// Sample 2.28 Array locator methods
int count, total, d[] = '{9,1,8,3,4,4};
count = d.sum with (item > 7) ;             // 2 : {9, 8}   compares the item with 7. return 1 or 0
total = d.sum with ( (item > 7) * item) ;   // 17= 9+8
count = d.sum with (item < 8) ;             // 4 : {1, 3, 4, 4}
total = d.sum with (item < 8 ? item : 0) ;  // 12=1+3+4+4
count = d.sum with (item -- 4) ;            // 2 : {4, 4}

// Sample 2.29 Sorting an array
           int d[] =         '{9,1,8,3,4,4};
           d.reverse();   // '{4,4,3,8,1,9}
           d.sort();      // '{1,3,4,4,8,9}
           d.rsort();     // '{9,8,4,4,3,1}
           d.shuffle();   // '{9,4,3,8,1,4}

// Sample 2.30 Sorting an array of structures
struct packed { byte red, green, blue; } c[];
initial begin
  c = new[100]; // Allocate 100 pixels
  foreach(c[i])
    c[i] = $urandom; // Fill with random values
  
  c.sort with (item.red); // sort using red only
  // sort by green value then blue
  c.sort(x) with ({x.green, x.blue});
end

// Sample 2.31 A scoreboard with array methods
typedef struct packed
    {bit [7:0] addr;
     bit [7:0] pr;
     bit [15:0] data; } Packet;
Packet scb[$];
function void check_addr(bit [7:0] addr);
  int intq[$];
  intq = scb.find_index() with (item.addr == addr);  
  // 'find_index()' returns an int queue
  case (intq.size())
    0: $display("Addr %h not found in scoreboard", addr);
    1: scb.delete(intq[O]);
    default:
      $display("ERROR: Multiple hits for addr %h", addr);
  endcase
endfunction : check_addr

---------------------------------------------------------
// Queues are slightly less efficient to access than fixed-size or dynamic arrays 
//           because of additional pointers.           
/*
• Network packets. 
Properties: fixed size, accessed sequentially. Use a fixedsize or dynamic array for fixed- or variable-size packets.
• Scoreboard of expected values. 
Properties: size not known until run-time. accessed by value, and a constantly changing size.  
In general, use a queue, as you are continually adding and deleting elements during simulation. 
If you can give every transaction a fixed id, such as 1,2,3 .... , you could use this as an index into the queue. 
If your transaction is filled with random values, you can just push them into a queue and search for unique values. 
If the scoreboard may have hundreds of elements, 
and you are often inserting and deleting them from the middle, an associative array may be faster.
• Sorted structures. 
Use a queue if the data comes out in a predictable order.
or an associative array if the order is unspecified. 
If the scoreboard never needs to be searched, just store the expected values in a mailbox
• Modeling very large memories, greater than a million entries. 
If you do not need every location, use an associative array as a sparse memory. 
If you do need every location, try a different approach where you do not need so much live data. 
Still stuck? Be sure to use 2-state values packed into 32-bits.
• Command names or opcodes from a file. 
Property: translate a string to a fixed value. 
Read string from a file, and then look up the commands or opcodes in an associative array using the command as a string index.
*/
--------------------------------------------------------------------------------
TYPEDEF
 //Sample 2.33 User-defined type in SystemVeriiog
parameter OPSIZE = 8;
typedef reg [OPSIZE-l:0] opreg_t; 
opreg_t op_a, op_b;
           
typedef bit [31:0] uint;    // 32-bit unsigned 2-state
typedef int unsigned uint;  //  Equivalent definition        

//Sample 2.35 User-defined array type
typedef int fixed_array5[5];
fixed_array5 f5;
initial begin
  foreach (f5[i])  f5[i] = i;
end           
           
----------------------------------------------------------
           //Sample 2.38 Initializing a struct
initial begin
  typedef struct {int a;
                  byte b;
                  shortint c;
                  int d;} my_struct_s;
  my_struct_s st '{32'haaaa_aaaad,
                    8'hbb,
                   16'hcccc,
                   32'hdddd_dddd};
  $display("str = %x %x %x %x ", st.a, st.b, st.c, st.d);
end

// Sample 2.39 Using typedef to create a union
typedef union { int i; real f; } num_u;
num_u un;
un.f = 0.0; // set value in floating point format           
// Unions are useful when frequently need to read and write a register in several different formats.           
           
// Sample 2.40 Packed structure
typedef struct packed {bit [7:0] r, g, b;} pixel_p_s;
pixel_p_s my_pixel;
// a packed structure is stored as a contiguous set of bits with no unesed space.
// packed structures are used when underlying bits represent a numerical value,
// or when trying to reduce memory usage
           
/* 
Packed Structure:   if make aggregate operations on the structure, such as copying the entire structure
Unpacked Structure: if code accesses the individual members more than the entire structure
*/
           
-------------------------------------------------------------------------------------------------------           
CAST
// Sample 2.41 Converting between int and real with static cast
int i;
real r; 
i = int' (10.0 - 0.1); // cast is optional
r = real'(42);         // cast is optional           
           
// Sample 2.42 Basic streaming operator
initial begin
  int h;
  bit [7:0] b, g[4], j[4] = '{8'ha, 8'hb, 8'hc, 8'hd};
  bit [7:0] g, r, s, t;
  
  h = { >> {j} };        // 0a0b0c0d - pack array into int
  h = { << {j} };        // b030d050 reverse bits
  h = { << byte {j} };   // 0d0c0b0a reverse bytes
  g = { << byte {j} };   // 0d, 0c, 0b, 0a unpack into array
  b = { << {8'b0011_0101}   };  // 1010_1100 reverse bits
  b = { << 4 {8'b0011_0101} };  // 0101_0011 reverse nibble
  { >> {q, r, s, t} } = j;      // Scatter j into bytes
  h = { >> {t, s, r, g} };      // Gather bytes into h
end           
           
/* 
The >> operator streams data from left to right 
The << operator streams data from right to left
*/           
           
// Sample 2.43 Converting between queues with streaming operator
initial begin
  bit [15:0] wq[$] = {16'h1234, 16'h5678};
  bit [ 7:0] bq[$];
  
  // Convert word array to byte
  bq = { >> {wq} }; // 12 34 56 78
  
  // Convert byte array to words
  bq {8'h98, 8'h76, 8'h54, 8'h32};
  wq = { >> {bq} }; // 9876 5432
end           
           
// Sample 2.44 Converting between a structure and array with streaming operators
initial begin
  typedef struct {int a;
                  byte b;
                  shortint c;
                  int d;} my_struct_s;
  my_struct_s st = `{32'haaaa_aaaa,
                     8'hbb,
                     16'hcccc,
                     32'hdddd_dddd} ;
  byte b[];
  
  // Covert from struct to byte array
  b = { >> {st} };     // {aa aa aa aa bb cc cc dd dd dd dd}
  
  // Convert from byte array to a struct
  b = '{ 8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77,
         8'h88, 8'h99, 8'haa, 8'hbb};
  st = { >> {b} };      // st = 11223344, 55, 6677, 8899aabb
end
          
           
---------------------------------------------------------------------------------------
           ENUMERATED TYPE
// Sample 2.46 Enumerated types
           
// Create data type for values 0, 1, 2
typedef enum {INIT, DECODE, IDLE} fsmstate_e;
fsmstate_e pstate, nstate; // declare typed variables
           
initial begin
  case (pstate)
    IDLE:     nstate = INIT;    // data assignment
    INIT:     nstate = DECODE;
    default:  nstate = IDLE
  endcase
  $display("Next state is %S", nstate.name()); // Display symbolic state name
end           
    // get the string representation of an enumerated variable with the built-in function name()
    
typedef enum {INIT, DECODE=2, IDLE} fsmtype_e;           
// default INIT=0, DECODE = 2, IDLE = 3
// actual values default to integers starting at 0 and then increase.
// an enumerated type is stored as int unless specify otherwise
/*    
• first() returns the first member of the enumeration.
• last()  returns the last member of the enumeration.
• next()  returns the next element of the enumeration.
• next(N) returns the Nth next element.
• prev()  returns the previous element of the enumeration.
• prev(N) returns the Nth previous element.

get the starting number with 'first' and the next member with 'next'
If you use 'current != current.last',  the loop ends before using the last value. 
If you use 'current <= current.last',  you get an infinite loop, as next never gives you a value that is greater than the final value.    
*/
    
//Sample 2.50 Stepping through all enumerated members
typedef enum {RED, BLUE, GREEN} color_e;
color_e color;
color = color.first;
do
  begin
    $display("Color = %0d/%s", color, color.name);
    color = color.next;
  end
while (color != color.first); //Done at wrap-around

// Sample 2.51 Assignments between integers and enumerated types
typedef enum {RED, BLUE, GREEN} COLOR_E;
COLOR_E color, c2;
int c;
initial begin
  color = BLUE;           // Set to known good value
  c = color;              // Convert from enum to int (1)
  c++;                    // Increment int (2)
  if (! $cast(color, c) ) // Cast int back to enum
    $display("Cast failed for c=%0d", c);
  $display("Color is %0d / %s", color, color.name);
  e++;                    // 3 is out-of-bounds for enum
  c2 = COLOR_E'(c) ;      // No type checking
  $display("Color is %0d / %s", color, color.name);
end
         
    // $cast() assign the right value to the left variable,
    // if succeeds, $cast() returns 1
    // if fails, no assignment is made and the function returns 0
    
    // can cast the value using ' type`(val) '
    // it does not do any type checking, the results may be out-of-bounds
         
-----------------------------------------------------------------------------
  STRING
/*
Memory for strings is dynamically allocated, 
so you do not have to worry about running out of space to store the string.
*/
// Sample 2.53 String methods
string s;
initial begin
  s = "IEEE";
  
  $display( s.getc(0) ) ;   // display: 73('I')
  $display( s.tolower());   // display: ieee
  
  s.putc( s.len()-1, "-"); // change ' '-> '-'
  s = {s, "p1800"};        // "IEEE-P1800"
  
  $display( s.substr (2, 5) ); // Display: EE-P
  
  // Create temporary string, note format
  my_log_rtn($psprintf ("%s %5d", s, 42));
end
task my_log{string message);
  //Print a message to a log
  $display( "@%0t: %S", $time, message);
endtask
         
/*
The function 'getc(N)' returns the byte at location N, 
and 'toupper' returns an upper-case copy of the string 
and 'tolower' returns a lowercase copy. 
The curly braces {} are used for concatenation. 
The task 'putc(M,C)' writes a byte c into a string at location M, which must be between 0 and the length as given by 'len'
The 'substr (start, end)' function extracts characters from location start to end.
         

+ Queues             work well for creating scoreboards for which you constantly need to add and remove data. 
+ Dynamic arrays     allow you to choose the array size at run-time for maximum testbench flexibility. 
+ Associative arrays are used for sparse memories and some scoreboards with a single index. 
+ Enumerated types   make your code easier to read and write by creating groups of named constants.         
         
         
         
         
    
    


