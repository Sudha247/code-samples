let num_domains = try int_of_string Sys.argv.(1) with _ -> 4
let n = try int_of_string Sys.argv.(2) with _ -> 1000

module Task = Domainslib.Task

let add_task pool n () =
  let a = Array.init n (fun i -> Task.async pool (fun _ -> ignore i)) in
  Array.iter (Task.await pool) a

let _ =
  let pool = Task.setup_pool ~num_domains:(num_domains - 1) in
  add_task pool n ()