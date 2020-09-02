let v = ref 0 

let update () = incr v

(*Update ref from another domain*)
let _ = 
  let d = Array.init 1 (fun _ -> Domain.spawn(update)) in 
  update ();
  Array.iter Domain.join d;
  Printf.printf "%d\n" !v