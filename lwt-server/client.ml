open Lwt.Infix 

let fibserver = Lwt_unix.ADDR_INET(Unix.inet_addr_of_string "127.0.0.1" , 2000)

let ip_val = "45"

let num_clients = try int_of_string Sys.argv.(1) with _ -> 10
let num_req = try int_of_string Sys.argv.(2) with _ -> 10

let create_socket () = 
  let sock = Lwt_unix.socket PF_INET SOCK_STREAM 0 in 
  Lwt_unix.connect sock fibserver |> Lwt.ignore_result;
  sock 

let rec send_req ic oc n = 
  if n = 0 then Lwt.return_unit
  else begin
    Lwt_io.write_line oc ip_val >>= fun () -> 
      Lwt_io.read_line ic >>= fun line ->
        Lwt_io.printlf "%s\n" line >>= fun () ->
          send_req ic oc (n-1)
  end

let request s =
    let oc = Lwt_io.of_fd ~mode:Output s in 
    let ic = Lwt_io.of_fd ~mode:Input s in
    send_req ic oc num_req

let client () = 
  let sock = create_socket () in 
  request sock 

let c = List.init num_clients (fun _ -> client ()) 

let _ = 
  Lwt_main.run @@ Lwt.join c