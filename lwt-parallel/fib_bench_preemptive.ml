open Lwt.Syntax
let n = try int_of_string Sys.argv.(1) with _ -> 100
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let l = List.init n (fun _ -> 42)

let fib_values = List.map (fun k ->
            let+ v = Lwt_preemptive.detach fib k in
            print_int(v);
            print_newline ()) l
let j = Lwt.join fib_values

let () =
  Lwt_main.run j