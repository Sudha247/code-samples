let v = Atomic.make 0 

let _ = 
  Atomic.incr v;
  Gc.major ();
  Atomic.incr v;
  Printf.printf "%d\n" (Atomic.get v)