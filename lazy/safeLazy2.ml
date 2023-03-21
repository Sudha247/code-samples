open Unified_interface

type 'a t = 'a lazy_t

(* exception Undefined *)

(* type resume_result = Resume_success | Resume_failure *)

(* type 'a resumer = 'a -> unit
type _ Effect.t += Suspend : ('a resumer -> bool) -> 'a Effect.t *)
(* type 'a resumer = 'a -> unit *)

type 'a lazy_status = Unforced | Forcing of 'a Sched.resumer Queue.t | Forwarded

let from_fun (f : unit -> 'arg) =
  let x = Obj.new_block Obj.lazy_tag 2 in
  Obj.set_field x 0 (Obj.repr Unforced);
  Obj.set_field x 1 (Obj.repr f);
  (Obj.obj x : 'arg t)

let update_to_forcing (blk: 'arg lazy_t) =
  let x = Obj.repr blk in
  let cur = Obj.field x 0 in
  match  Obj.obj cur with
  | Unforced -> begin if (Obj.compare_and_swap_field x 0 (Obj.repr Unforced) (Obj.repr @@ Forcing (Queue.create ()))) then 0 else 1 end
  | _ -> failwith "impossible"
  (* Should we set field atomically? *)
  (* if  (Obj.compare_and_swap_field x 0 (Obj.repr Unforced) (Obj.repr @@ Forcing []))
  then 0
  else 1 *)

(* Assumes blk is of Forcing tag *)
let do_force_val_block blk =
  Printf.printf "\nOnly one fiber is coming%!";
  let b = Obj.repr blk in
  let closure : unit -> 'arg = Obj.obj (Obj.field b 1) in
  Obj.set_field b 1 (Obj.repr ());
  let t : 'a lazy_status = Obj.obj (Obj.field b 0) in
  let result = closure () in
  Obj.set_field b 1 (Obj.repr result);
  Obj.set_field b 0 (Obj.repr Forwarded);
  begin
  match t with
  | Forcing q -> while not (Queue.is_empty q) do
                  let resumer = Queue.pop q in
                  let _ = resumer result in
                  ()
                done
  | _ -> print_endline "empty queue"
  end;
  result

let rec force_gen_lazy_blk (blk : 'arg lazy_t) =
  match update_to_forcing blk with
  | 0 -> do_force_val_block blk
  | _ ->  force_gen_lazy_blk blk (* raise Undefined *)

let force_gen (lzv: 'arg lazy_t) =
  let lzv = Sys.opaque_identity lzv in
  let x = Obj.repr lzv in
  let t : 'a lazy_status = Obj.obj (Obj.field x 0) in
  match t with
  | Forwarded -> (Obj.obj (Obj.field x 1) : 'arg)
  | Forcing q ->  
      begin 
      Printf.printf "\nIs the control coming here in force gen?%!";
      Effect.perform
      (Sched.Suspend (fun r -> Printf.printf "\n Are we inside Suspend effect?%!";
        Queue.push r q;
        true
      (* let new_q = Queue.copy q in
      Queue.push r new_q;
      match Obj.compare_and_swap_field x 0 (Obj.repr @@ Forcing q) (Obj.repr @@ Forcing new_q) with
      | true -> true
      | false -> false *)
      )
      ) end
  | _ when t <> Unforced -> (Obj.obj x : 'arg)
  | _ -> force_gen_lazy_blk lzv
