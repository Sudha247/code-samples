let n = try int_of_string Sys.argv.(1) with _ -> 100

let v = ref 0

let () =
  for _ = 1 to n do
    incr v
  done;
  Printf.printf "v = %d\n" !v

