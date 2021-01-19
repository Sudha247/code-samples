open Globroots

(* let young_roots () = 
  let size = 1024 in
  match Random.int 4 with
  | 0 -> 
    Gc.minor ()
  | 1 | 2 -> 
    let i = Random.int size in
    G.set a.(i) (Int.to_string i)
  | 3 ->
    let i = Random.int size in
    G.remove a.(i);
    a.(i) <- G.register (Int.to_string i)

let test_young n =
  for _ = 1 to n do
    change();
    print_string "."; flush stdout
  done *)

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
  