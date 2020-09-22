[@@@ocaml.warning "-3"]
let s = Lwt_sequence.create () 

let add_r n = 
  for _i = 1 to n do 
    Lwt_sequence.add_r 10 s |> ignore
  done 

let take_r n = 
  for _i = 1 to n do 
    Lwt_sequence.take_r s |> ignore
  done 

let add_l n = 
  for _i = 1 to n do 
    Lwt_sequence.add_l 10 s |> ignore
  done 

let take_l n = 
  for _i = 1 to n do 
    Lwt_sequence.take_l s |> ignore
  done 

let _ = 
  let n = try int_of_string Sys.argv.(1) with _ -> 100 in 
  add_r n;
  take_r n;
  add_l n;
  take_l n