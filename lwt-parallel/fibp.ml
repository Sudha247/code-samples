open Lwt
open Lwt.Infix

let port = 2001

let num_domains = try int_of_string Sys.argv.(1) with _ -> 4
let counter = ref 0

let _ =
  Lwt_domain.set_bounds num_domains

let create_socket port () =
  let sock = Lwt_unix.socket PF_INET SOCK_STREAM 0 in
  Lwt_unix.bind sock @@ ADDR_INET(Unix.inet_addr_loopback, port) >>= fun () ->
  Lwt_unix.listen sock 100;
  return sock

let recv ic =
  Lwt_io.read_line_opt ic

let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let send_res oc res =
  Lwt_io.write_line oc res |> Lwt.ignore_result

let compute v =
  Printf.printf "%d\n" (Domain.self() :> int);
  try
    let n = int_of_string v in
    string_of_int @@ fib n
  with _ ->
    "invalid argument for fib"

let detached oc =
  Lwt_domain.detach (fun msg -> compute msg |> send_res oc)

let rec main oc ic =
  match%lwt recv ic with
  | Some msg ->
    incr counter;
    if !counter mod num_domains = 0 then begin
      compute msg |> send_res oc;
      main oc ic
      end
    else
      detached oc msg >>= fun () -> main oc ic
  | None -> return_unit

let serve connection =
  let fd, _ = connection in
  let ic = Lwt_io.of_fd ~mode:Lwt_io.Input fd in
  let oc = Lwt_io.of_fd ~mode:Lwt_io.Output fd in
  print_endline "conn";
  main oc ic |> Lwt.ignore_result;
  Lwt.return_unit

let create_server sock =
  let rec run () =
    Lwt_unix.accept sock >>= serve >>= run
  in run

let _ =
  Lwt_main.run (create_socket port () >>= fun sock ->
    let run = create_server sock in run ())