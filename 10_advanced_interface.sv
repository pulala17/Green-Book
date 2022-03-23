
//Sample 10.8 Test harness using an interface in the port list
module top;
  bus ifc bus(); //Instantiate the interface
  test tl(bus);  //Pass to test through port list
  dut  dl(bus);  //Pass to DUT through port list
  ...
endmodule

//Sample 10.9 Test with an interface in the port list
program automatic test(bus_ifc bus);
  initial $display(bus.data); // Use an interface signal
endprogram

//Sample 10.10 Top module with a second interface in the test's port list
module top;
  bus_ifc bus ();     //Instantiate the interface
  new_ifc newb();     //and a new one
  test tl(bus, newb); //Test with two interfaces
  dut  dl(bus, newb); //DUT with two interfaces
endmodule

// Sample 10.11 Test with two interfaces in the port list
program automatic test(bus_ifc bus, new_ifc newb);
  initial $display(bus.data); // Use an interface signal
endprogram

//Sample 10.12 Test with virtual interface and XMR
program automatic test();
  virtual bus_ifc bus = top.bus; // Cross module reference
  initial $display(bus.data);    // Use an interface signal
endprogram

// Sample 10.13 Test harness without interfaces in the port list
module top;
  bus_ifc bus() ;   //Instantiate the interface
  test tl() ;       //Don't use port list for test
  dut dl(bus) ;     //Still use port list for DUT
endmodule

//Sample 10.14 Test harness with a second interface
module top;
  bus_ifc bus();      // instantiate the interface
  new_ifc newb () ;   // and a new one
  test tl () ;        // instantiation remains the same
  dut dl(bus, newb);
  ...
endmodule

// Sample 10.15 Test with two virtual interfaces and XMRs
program automatic test();
  virtual bus_ifc bus = top.bus;
  virtual new_ifc newb = top.newb;
  initial begin
    $display(bus.data);  // Use existing interface
    $display(newb.addr); // and new one
  end
endprogram

------------------------------------------------------------------------

