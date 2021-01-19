let n = try int_of_string Sys.argv.(1) with _ -> 10000
open Globroots

let _ = young2old (); Gc.full_major ()

let _ =
  assert (static2young (1, 1) Gc.full_major == 0x42)

let _ =
  print_string "Non-generational API\n";
  TestClassic.test n;
  print_newline();
  print_string "Generational API\n";
  TestGenerational.test n;
  print_newline();
