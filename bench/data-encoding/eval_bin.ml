let encoding = Data_encoding.(list (option int31));;

let value = (Array.to_list (Array.make 300000 (Some 0)))

let num_iterations = 1

let num_domains = try int_of_string Sys.argv.(1) with _ -> 1

let pool = Domainslib.Task.setup_pool ~num_additional_domains:(num_domains - 1) ()

(* let thunk = fun () -> ignore @@ Data_encoding.Binary.to_bytes_exn encoding value *)

let thunk = fun () ->
  ignore @@ Data_encoding.Json.to_string
  @@ Data_encoding.Json.construct encoding value

let _ =
  let start_time = Unix.gettimeofday () in
  (* for _i = 0 to num_iterations - 1 do
    thunk ()
  done ; *)
  Domainslib.Task.parallel_for ~start:0 ~finish:(num_iterations - 1)
  ~body:(fun _ -> thunk ()) pool;
  (* Format.printf "%s done\n" name *)
  let end_time = Unix.gettimeofday () in
  Format.printf
    "Benchmark: %s took %f for %d iterations.@."
    "option_element_int_list"
    (end_time -. start_time)
    num_iterations