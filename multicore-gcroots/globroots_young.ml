open Globroots

  let num_domains = try int_of_string Sys.argv.(1) with _ -> 4
  let n = (try int_of_string Sys.argv.(2) with _ -> 1000) / num_domains
    
let work () =
  print_string "Generational API\n";
  TestGenerational.test_young n;
  print_newline()
  
let _ =
  let domains = Array.init (num_domains - 1) (fun _ -> Domain.spawn(work)) in
  work ();
  Array.iter Domain.join domains
  