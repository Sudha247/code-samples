open Lwt
open Lwt.Infix

let port = 1537

let create_socket port () = 
  let sock = Lwt_unix.socket PF_INET SOCK_STREAM 0 in 
  Lwt_unix.bind sock @@ ADDR_INET(Unix.inet_addr_loopback, port) >>= fun () ->
  Lwt_unix.listen sock 10;
  return sock

let recv ic = 
  Lwt_io.read_line_opt ic 

let rec send oc ic =
  match%lwt recv ic with 
  | Some msg -> 
    Lwt_io.write_line oc msg >>= fun () -> send oc ic 
  | None -> return_unit 

let serve connection =
  let fd, _ = connection in 
  let ic = Lwt_io.of_fd ~mode:Lwt_io.Input fd in 
  let oc = Lwt_io.of_fd ~mode:Lwt_io.Output fd in 
  print_endline "conn"; 
  send oc ic |> Lwt.ignore_result;
  Lwt.return_unit 

let create_server sock = 
  let rec run () = 
    Lwt_unix.accept sock >>= serve >>= run 
  in run 

let _ = 
  Lwt_main.run (create_socket port () >>= fun sock ->
    let run = create_server sock in run ())