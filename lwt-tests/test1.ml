let num_domains = try int_of_string Sys.argv.(1) with _ -> 4

let d = Lwt_preemptive.detach(fun _ -> 
  Lwt_io.printf "%d\n" (Domain.self () :> int) |> Lwt.ignore_result; 1 + 2)

let _ = 
  Lwt_preemptive.set_bounds(0, num_domains)

let _ = 
  for _i = 0 to 100 do 
    d () |> ignore
  done