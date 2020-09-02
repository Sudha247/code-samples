let v = ref 0 

let _ = 
  incr v;
  Gc.major ();
  incr v;
  Printf.printf "%d\n" !v