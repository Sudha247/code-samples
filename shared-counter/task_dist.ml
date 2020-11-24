module C = Domainslib.Chan
let num_domains = try int_of_string Sys.argv.(1) with _ -> 4
let n = try int_of_string Sys.argv.(2) with _ -> 1000

let c = C.make_unbounded ()

let add_items n () =
  for i = 1 to n do
    C.send c i
  done

let get_items n () =
  for _ = 1 to n do
    C.recv c |> ignore
  done

let _ =
  add_items n ();
  let t = Unix.gettimeofday () in
  let d = Array.init (num_domains - 1) (fun _ -> Domain.spawn(get_items (n/num_domains))) in
  get_items (n/num_domains) ();
  Array.iter Domain.join d;
  Printf.printf "%f\n" (Unix.gettimeofday () -. t)
