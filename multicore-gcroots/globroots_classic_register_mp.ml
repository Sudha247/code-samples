let num_domains = try int_of_string Sys.argv.(1) with _ -> 4 
let n = try int_of_string Sys.argv.(2) with _ -> 1000

open Globroots
let v = Array.make 1024 0

let work n () =
  let a = Array.init n (fun i -> Classic.register (Int.to_string i)) in
  Gc.minor ();
  for i = 0 to n - 1 do
    Classic.set a.(i) (Int.to_string (i+1))
  done

let _ =
  let d = Array.init (num_domains - 1) (fun _ -> Domain.spawn(work (n/num_domains))) in
  work (n/num_domains) ();
  Array.iter Domain.join d