let num_domains = try int_of_string Sys.argv.(1) with _ -> 4 
let n = try int_of_string Sys.argv.(2) with _ -> 100


let v = Atomic.make 0

let work n () = 
  Printf.printf "%d\n" (Domain.self () :> int);
  for _ = 1 to n do
    Atomic.incr v
  done

let _ =
  let d = Array.init (num_domains - 1) (fun _ ->Domain.spawn(work (n/num_domains))) in
  work (n/num_domains) ();
  Array.iter Domain.join d;
  Printf.printf "v = %d\n" (Atomic.get v)
