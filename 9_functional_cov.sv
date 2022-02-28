//S9.2 P303
program automatic test(busifc.TB ifc);
  class Transaction;
    rand bit [31:0] data;
    rand bit [ 2:0] port; //8 possible values
  endclass
  
  covergroup Covport;
    coverpoint tr.port;  //measure 'port' variables
  endgroup
  
  initial begin
    transaction tr;
    tr = new();
    
    Covport ck;
    ck = new(); //instantiate group

    repeat(32) begin
      assert(tr.randomize);    //random transaction
      ifc.cb.port <= tr.port;  //transmit the transaction's port to interface(ifc)
      ifc.cb.date <= tr.data;
      ck.sample();  //gather coverage *explicitly instantiate to start sampling
      @ifc.cb;     //wait a cycle
    end
  end
endprogram

// To improve functional coverage --> run more / try new random seeds

//S0.5 Func. Cov. inside class P307
class Transactor;
  transaction tr;
  mailbox mbx_in;
  
  covergroup Covport;
    coverpoint tr.port;
  endgroup
  
  function new(mailbox mbx_in);
    Covport = new();  //instantiate covergroup
    this.mbx_in = mbx_in;
  endfunction
  
  task main;
    forever begin
      tr = mbx_in.get;
      ifc.cb.port <= tr.port;  //send to DUT
      ifc.cb.data <= tr.data;
      Covport.sample();      //gather coverage *
    end
  endtask
endclass

//S9.6 using functional coverage cllback
program automatic test;
  Environment env;
  
  initial begin
    Driver_cbs_coverage dcc;
    
    env = new();
    env.gen_cfg();
    env.build();
    
    dcc = new();  //create and register the coverage callback
    env.drv.cbs.push_nack(dcc);  //put into driver's queue
    
    env.run();
    env.wrap_up();
  end
endprogram

class Driver_cbs_coverage extends Driver_cbs;
  covergroup Covport;
    ...
  endgroup
  virtual task post_tx(transaction tr);
    Covport.sample();
  endtask
endclass

//S9.8 with event trigger
event trans_ready;
covergroup Covport @(trans_ready); //sample when the event is triggered.
  coverpoint ifc.cb.port;
endgroup

//S9.9 with assertion
module mem(simple_bus sb);
  bit [7:0] data, addr;
  event write_event;
  
  cover property
    (@ (posedge sb.clock) sb.write_ena==1)  -> write_event;
endmodule
    
program automatic test(simple_bus sb);
  covergroup write_cg @($root.top.m1.write_event);
    coverpoint $root.top.m1.data;
    coverpoint $root.top.m1.addr;
  endgroup
  write_cg wcg;
  initial begin
    wcg = new();
    sb.write_ena <= 1;
    ...
    #10000 $finish;
  end
endprogram
    
//S9.11
//cover group option 'auto_bin_max' specifies the max. #bins to create
covergroup covport;
  coverpoint tr.port { options.auto_bin_max = 2; } //divide into 2 bins
endgroup
//use /auto_bin_max' for entire group
covergroup covport;
  options.auto_bin_max = 2;
  coverpoint tr.port;
  coverpoint tr.data;
endgroup
    
//S9.14
class Transaction;
  rand bit [2:0] hdr_len;     //range 0:7
  rand bit [3:0] payload_len; //range 0:15
  rand bit [3:0] kind;        //range 0:15
  ...
endclass    
Transaction tr;
covergroup covlen;
  len16: coverpoint (tr.hdr_len + tr.payload_len);
  len32: coverpoint (tr.hdr_len + tr.payload_len + 5'b0); //with 5-bit precision of max 32 auto-generated bins
endgroup

// S9.17
covergroup covkind;  // samples a 4-bit variable 'kind',(total 16 possible values)
  coverpoint tr.kind{ bins zero = {0};        // one bin for kind=0
                     bins lo   = { [1:3], 5}; // one bin for values 1,2,3,5
                     bins hi[] = { [8:$] };   // 8 seperate bins seperatly sample 8...15, the bins is called hi_8, hi_9...hi_f
                                              // use $ on the right side to specify upper value
                                              // use $ on the left side to specify lower limit
                     bins misc = default;  }  // one bin for all rest: 4,6,7
endgroup
    
// S9.19
int i;
covergroup range_cover;
  coverpoint i { bins ned  = { [$:-1] };  //negative values
                 bins zero = {0};
                 bins pos  = { [1:$] };  } //positive values, from 1 to the upper value
endgroup
    
// S9.20 Conditional coverage use 'iff'
covergroup covport;
  coverpoint port iff (!bus_if.reset);  //don't gather coverage when reset==1
endgroup
    
// S9.20 'start' & 'stop'
initial begin
  covport ck = new();  //instantiate cover grou[
  #1ns ck.stop();      //reset sequence stops collection of coverage data
  bus_if.reset = 1;
  #100ns bus_if.reset = 0; //end of reset
  ck.start();
  ...
end
    
// S9.22 ENUM
typedef enum {INIT, DECODE, IDLE} fsm_state;
fsm_state pstate, nstate;  //declare typed variables
covergroup cg_fsm;
  coverpoint pstate;  // it will seperatly sample INIT,DECODE,IDLE
endgroup
    
// S9.24 Transition Coverage
covergroup covport;
  coverpoint port { bins t1 = (0=>1), (0=>2),(0=>3); }
endgroup
    // (1,2 => 3,4) create 4 transitions (1=>3),(1=>4),(2=>3),(2=>4)

// S9.25 'wildcard' create multiple states & transitions
//  x,z,? is treated as 0 or 1;
bit [2:0] port;
covergroup covport;
  coverpoint port { wildcard bins even = {3'b??0};
                    wildcard bins odd = {3'b??1}; }
endgroup
    
    
// S9.26 ignore_bins
bit [2:0] low_ports;
covergroup covport;
  coverpoint low_ports { ignore_bins hi = { [6:7] }; }//ignore upper 2 bins
endgroup
   
// S9.27 'auto_bin_max' 'ignore_bins'
bit [2:0] low_ports;
covergroup covport;
  coverpoint low_ports{ options.auto_bin_max = 4; // 0:1 2:3 4:5 6:7
                       ignore_bins hi = {[6:7]};  } //ignore 6:7
endgroup

// S9.28 illegal_bins 
// some sampled values would cause an error if they are seen
// catch states that were missed by the tests error checking, a double-checks
bit [2:0] low_port;  
covergroup covport;
  coverpoint low_port { illegal_bins hi = { [6:7] } ; }  //give error if seen
endgroup

// S9.29 cross coverage
class transaction;
  rand bit [3:0] kind;
  rand bit [2:0] port;
endclass
    
transaction tr;
    
covergroup covport;
  kind: coverpoint tr.kind;  //create coverpoint kind
  port: coverpoint tr.port;  //create coverpoint port
  cross kind, port;          //cross kind and port
endgroup    
    
// S9.31    
covergroup covPortKind;    
  port: coverpoint tr.port { bins port[] = { [0:$] };  }
  kind: coverpoint tr.kind { bins zero = {0};                            
                             bins lo   = { [1:3] } ; 
                             bins hi[] = { [8:$] };  
                             bins misc = default;  } 
  cross kind, port;
endgroup
    
// S9.33 exclude bins from cross coverage
covergroup covPortKind;    
  port: coverpoint tr.port { bins port[] = { [0:$] };  }
  kind: coverpoint tr.kind { bins zero = {0};                            
                             bins lo   = { [1:3] } ; 
                             bins hi[] = { [8:$] };  
                             bins misc = default;  } 
  cross kind, port { ignore_bins hi = binsof(port) intersect{7};  //exclude bins where port is 7 with any kind
                     ignore_bins md = binsof(port) intersect {0} &&
                                      binsof(kind) intersect {[9:11]};  //exclude bins where bins is 0 and kins is 9, 10, 11
                     ignore_bins lo = binsof(kind.lo);  }
endgroup
    
// S9.34 specify cross coverage weight
covergroup covPortKind;    
  port: coverpoint tr.port { bins port[] = { [0:$] };  
                            option.weight = 0;        } //dont count in total coverage
  kind: coverpoint tr.kind { bins zero = {0};                            
                             bins lo   = { [1:3] } ; 
                             bins hi[] = { [8:$] };  
                             bins misc = default;  
                            option.weight = 5       } // count in total
  cross kind, port { option.weight = 10;  }  //give cross extra weight
endgroup     
    
// S9.35 cross coverage with bin names    
class transaction;
  rand bit a, b;
endclass
    
covergroup crossBinName;
  a: coverpoint tr.a { bins a0 = {0};
                       bins a1 = {1};
                       option.weight = 0 ; }
  b: coverpoint tr.b { bins b0 = {0};
                       bins b1 = {1};
                       option.weight = 0; }
  ab: cross a,b { bins a0b0 = binsof(a.a0) && binsof(b.b0) ;
                  bins a1b0 = binsof(a.a1) && binsof(b,b0) ;
                  bins b1 = binsof(b.b1); }
endgroup
    
// S9.36 cross coverage with binsof
class transaction;
  rand bit a, b;
endclass
    
covergroup crossBinsofIntersect;
  a: coverpoint tr.a { option.weight=0; }  //dont count this coverpoint
  b: coverpoint tr.b { option.weight=0; }  //dont count this coverpoint
  ab: cross a,b { bins a0b0 = binsof(a) intersect {0} &&
                              binsof(b) intersect {0}; 
                  bins a1b0 = binsof(a) intersect {1} &&
                              binsof(b) intersect {0};
                  bins b1   = binsof(b) intersect {1};     }
endgroup  
      
// S9.37 can make coverpoint that samples a concatenation if values, then only have to define bins as following
coverpoint crossManual;
    ab: coverpoint { tr.a, tr.b}   { bins a0b0 = {2'b00};
                                     bins a1b0 = {2'b10};
                                     wildcard bins b1 = {2'b?1};        }
endgroup  
    
// S9.38 split the range into 2 halves
    bit [2:0] port;     // value 0:7
    
covergroup covport (int mid);
    coverpoint port { bins lo = { [0:mid-1] };
                      bins hi = { [mid:$] };   }
endgroup
    
coverport cp;
initial   cp = new(5);        // lo=0:4,  hi=5:7
    
// S9.39 pass-by-reference
bit [2:0] port_a, port_b;    
    
covergroup covport ( ref bit[2:0] port, input int mid);
  coverpoint port { bins lo = { [0:mid-1] };
                    bins hi = { [mid:$] };     }    
endgroup
    
covport cpa, cpb;
initial begin
  cpa = new(port_a, 4);  // port_a, lo=0:3, hi=4:7
  cpb = new(port_b, 2);  // port_b, lo=0:1, hi=2:7
end
    
// S9.40 specifying per-instance coverage, per_instance can only in cover group
covergroup covlength;
  coverpoint tr.length;
  option.per_instance = 1;
  option.comment = $psprintf("%m");
endgroup
    
// S9.41 specify comments for a cover group    
covergroup covport;
  type_option.comment = "hello world";
  coverpoint port;
endgroup
    
// S9.42 specify comments for a cover group instance
covergroup covport (int lo,hi, string comment);
  option.comment = comment;
  option.per_instance = 1;
  coverpoint port { bins range = { [lo:hi] }; }
endgroup
...
covport cp_lo = new(0, 3, "Low port numbers");
covport cp_hi = new(4, 7, "High port numbers");
    
// S9.43 report all bins including empty ones
// cross_num_print_missing tell the simulation and report tools to show all bins
covergroup covport;
   kind: coverpoint tr.kind;
   port: coverpoint tr.port;
   cross kind, port;
   option.cross_num_print_missing = 1_000;  //set to a large value
endgroup
    
// S9.44 specify the coverage goal
covergroup covport;
  coverpoint port;
  option.goal = 90;  //settle for partial coverage
endgroup
 
    
    
//test
