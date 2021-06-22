open Lwt.Syntax

exception Invalid_input

let num_domains = try int_of_string Sys.argv.(1) with _ -> 4
let iters = try int_of_string Sys.argv.(2) with _ -> 1000

let size = 8192
let mb = 1024. *. 1024.

let run digest n =
  for _ = 1 to n do
    let v = Mirage_crypto_rng.generate 8192 in
    ignore (digest v)
  done

let _ =
  let digest = match Sys.argv.(3) with
  | "md5" -> Mirage_crypto.Hash.MD5.digest
  | "sha1" -> Mirage_crypto.Hash.SHA1.digest
  | "sha256" -> Mirage_crypto.Hash.SHA256.digest
  | "sha512" -> Mirage_crypto.Hash.SHA512.digest
  | _ -> Printf.printf "Available algorithms: md5 sha1 sha256 sha512\n";
         raise Invalid_input
  in
  Lwt_domain.init num_domains (fun _ -> ());
  Mirage_crypto_rng_lwt.initialize ();
  let t1 = Unix.gettimeofday () in
  let runners = List.init num_domains (fun _ -> let+ _ =
    Lwt_domain.detach (fun () -> run digest (iters/num_domains)) () in ()) in
  let j = Lwt.join runners in
  Lwt_main.run j;
  let t2 = Unix.gettimeofday () in
  let time = t2 -. t1 in
  Printf.printf "Throughput: %04f MB/s  (%d iters in %.03f s)\n%!"
    ((float (size * iters) /. time ) /. mb) iters time