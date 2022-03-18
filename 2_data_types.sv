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





