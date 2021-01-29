let n = try int_of_string Sys.argv.(1) with _ -> 1000
open Globroots

let _ =
  let a = Array.init n (fun i -> Generational.register (Int.to_string i)) in
  for i = 1 to n do
    a.(i) <- Generational.register (Int.to_string (i+1))
  done;
  Gc.full_major ()

