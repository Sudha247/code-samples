let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let n = try int_of_string Sys.argv.(1) with _ -> 10

let num_domain = try int_of_string Sys.argv.(2) with _ -> 2

let my_val = try int_of_string Sys.argv.(3) with _ -> 20
let k = fib my_val

let _ =
  Lwt_domain.set_bounds num_domain
let fib_list = List.init n (fun _ -> Lwt_domain.detach fib my_val)

let answer = List.init n (fun _ -> k)

let _ =
  let v = Lwt.all fib_list in
  let ans = Lwt_main.run v in
  let b = (v = ans) in
  Printf.printf "%b\n" b