open SafeLazy2
open Effect
open Effect.Deep
(* type _ Effect.t += Suspend : ('a resumer -> bool) -> 'a Effect.t *)

let rec fib n = if n < 2 then n else fib (n - 1) + fib (n - 2)
let f = fun () -> (fib 45)

let v = from_fun f
(* 
try_with f () {
  effc = fun (type a) (eff: a t) ->
    match eff with
    | Suspend f -> Some (fun (k: (a, _) continuation) ->
      f (fun x -> x))
    | _ -> None
};; *)

let create () =
  Domain.spawn (fun () ->
    (* Printf.printf "\n Is the control coming inside domain spawn? %d %!\n" (Domain.self ():> int); *)
    let res = try_with force_gen v
    {
      effc = fun (type a) (eff: a t) ->
        match eff with
        | Suspend f -> Some (fun (k: (a, _) continuation) ->
            (* Resumer *)
            (* let resumer = fun x -> () in
            let res = f resumer in
            continue k res *)
            (* f (fun x -> x) |> ignore; *)
            Printf.printf "\nInside suspend effect %d%!\n" (Domain.self ():> int);
            let resumer v = (continue k v) in 
            (if (f resumer) then ()
            else ());
            100
            (* Condition.wait *)
            (* f resumer - add signal in resumer, counter - how many suspended*))
        | _ -> print_endline "No suspend effect"; None
    } in
    Printf.printf "I ended\n";
    res)

let () =
  let d = Array.init 4 (fun _ -> create ()) in
  let x = force_gen v in
  Array.iter (fun x -> Domain.join x |> Printf.printf "Finally: %d\n") d;
  Printf.printf "%d\n" x

(*
let v2 = from_fun (fun () -> fib 42)

let main _env =
  Fiber.both
    (try_with force_gen v
    {
      effc = fun (type a) (eff: a t) ->
        match eff with
        | Suspend _ -> Some (fun (_: (a, _) continuation) ->
            100)
        | _ -> None
    })
    (try_with force_gen v
    {
      effc = fun (type a) (eff: a t) ->
        match eff with
        | Suspend _ -> Some (fun (_: (a, _) continuation) ->
            100)
        | _ -> None
    });; *)