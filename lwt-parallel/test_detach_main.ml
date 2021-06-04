open Lwt.Infix


let _ =
  let f () =
    Lwt_domain.run_in_main (fun () ->
      assert ((Domain.self () :> int) = 0);
      Lwt_unix.sleep 0.01 >>= fun () ->
      Lwt.return 42)
    in
    Lwt_domain.detach f () >>= fun x ->
    Lwt.return (x = 42)

let _ =
  print_endline "ok"