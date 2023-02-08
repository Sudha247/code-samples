(* open Processor *)

let num_domains = try int_of_string @@ Sys.argv.(1) with _ -> 4
let n = try int_of_string @@ Sys.argv.(2) with _ -> 40
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)
let work n =
  for _i = 1 to 20 do
    fib n |> ignore
  done

(* let tail ls =
  match ls with
  | [] -> []
  | _::xs -> xs

let get index =
  let cpus = Processor.Affinity.get_cpus () in
  let rec loop index cpus =
    match  index with
    | 0 -> List.hd cpus
    | _ -> loop (index - 1) (tail cpus)
  in
  loop index cpus *)

let () =
  let domains = Array.init num_domains (fun _i -> Domain.spawn @@ fun () -> (work n)) in
  Array.iter Domain.join domains