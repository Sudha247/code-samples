open SafeLazy2
open Effect
open Effect.Deep
open Printf
open Unified_interface
(* type _ Effect.t += Suspend : ('a resumer -> bool) -> 'a Effect.t *)

let rec fib n = if n < 2 then n else fib (n - 1) + fib (n - 2)
let f = fun () -> (fib 45)

let v = from_fun f

let m = Mutex.create ()
let c = Condition.create ()

let f () = let ans = force_gen v in printf "\nOhk some value we are getting %d" ans

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
    printf "\n Is the control coming inside domain spawn?%!";
     
    try_with f ()
    { 
      (* retc = (fun x -> printf "Returned %d" x; x);
      exnc =  (fun ex -> Printexc.raise_with_backtrace ex (Printexc.get_raw_backtrace ())); *)
      effc = fun (type a) (eff: a t) ->
        match eff with
        | Sched.Suspend f -> Some (fun (k:(a, _) continuation) ->
        (* | Suspend _ -> Some (fun _ -> *)
            printf "\nInside suspend effect %d%!" (Domain.self ():> int);
            (* Unix.sleep 1; *)
            (* Resumer *)
            let resumer v = (let _ = continue k v in printf "\nIs the resumer working actually?%!"; Condition.signal c;Sched.Resume_success) in 
            (if (f resumer) then 
            begin 
              Mutex.lock m;
              Condition.wait c m 
            end
            else 
              begin
                printf "I guess race is happening";
                discontinue k Exit
              end
            )
            (* 100 *)
            )
        | _ -> None
    }
    
    )

let () =
  let d = Array.init 1 (fun _ -> create ()) in
  let x = force_gen v in
  Array.iter (fun x -> Domain.join x) d;
  Printf.printf "\nDomain %d : value is x : %d\n%!" (Domain.self () :> int) x

