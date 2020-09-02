let v = Atomic.make 0

let update () = Atomic.incr v 

let _ = 
  let d = Array.init 1 (fun _ -> Domain.spawn(update)) in 
  update ();
  Array.iter Domain.join d;
  Printf.printf "%d\n" (Atomic.get v)