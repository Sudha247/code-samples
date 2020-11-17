let k = Domain.DLS.new_key Random.State.make_self_init

let n = try int_of_string Sys.argv.(1) with _ -> 100

type t = int * int ref

let create ?(max = 32) () = (max, ref 1)

let once (maxv, r) state =
  let t = Random.State.int state !r in
  r := min (2 * !r) maxv;
  if t = 0 then ()
  else begin
    for _ = 1 to t do
      Domain.Sync.cpu_relax ()
    done
  end

let _ =
  let s = Domain.DLS.get k in
  let b = create () in
  for _ = 1 to n do
    once b s
  done