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
