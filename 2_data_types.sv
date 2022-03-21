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


































