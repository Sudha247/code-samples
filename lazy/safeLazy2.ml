type 'a t = 'a lazy_t

exception Undefined

(* type resume_result = Resume_success | Resume_failure *)

type 'a resumer = 'a -> 'a
type _ Effect.t += Suspend : ('a resumer -> bool) -> 'a Effect.t


type 'a lazy_status = Unforced | Forcing of 'a resumer list | Forwarded

let from_fun (f : unit -> 'arg) =
  let x = Obj.new_block Obj.lazy_tag 2 in
  Obj.set_field x 0 (Obj.repr Unforced);
  Obj.set_field x 1 (Obj.repr f);
  (Obj.obj x : 'arg t)

let update_to_forcing (blk: 'arg lazy_t) =
  let x = Obj.repr blk in
  let cur = Obj.field x 0 in
  match  Obj.obj cur with
  | Unforced -> begin if (Obj.compare_and_swap_field x 0 (Obj.repr Unforced) (Obj.repr @@ Forcing [])) then 0 else 1 end
  | _ -> failwith "impossible"
  (* Should we set field atomically? *)
  (* if  (Obj.compare_and_swap_field x 0 (Obj.repr Unforced) (Obj.repr @@ Forcing []))
  then 0
  else 1 *)

(* Assumes blk is of Forcing tag *)
let do_force_val_block blk =
  let b = Obj.repr blk in
  let closure : unit -> 'arg = Obj.obj (Obj.field b 1) in
  Obj.set_field b 1 (Obj.repr ());
  let _t : 'a lazy_status = Obj.obj (Obj.field b 0) in
  let result = closure () in
  Obj.set_field b 1 (Obj.repr result);
  Obj.set_field b 0 (Obj.repr Forwarded);
  (* match t with
  | Forcing list -> List.iter (fun x -> x ) list
  | _ -> print_endline "empty queue"; *)
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
  | Forcing list -> begin Effect.perform
      (Suspend (fun r -> let new_list = r::list in
      match Obj.compare_and_swap_field x 0 (Obj.repr @@ Forcing list) (Obj.repr @@ Forcing new_list) with
      | true -> true
      | false -> false)) end
      (* This r should take an input of result and return result *)
  | _ when t <> Unforced -> (Obj.obj x : 'arg)
  | _ -> force_gen_lazy_blk lzv
