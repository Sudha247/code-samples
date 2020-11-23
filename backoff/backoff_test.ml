let n = try int_of_string Sys.argv.(1) with _ -> 100

let _ =
  let t = Unix.gettimeofday () in
  for _ = 1 to n do
    Domain.Sync.cpu_relax ()
  done;
  Printf.printf "%f\n" (Unix.gettimeofday () -. t)