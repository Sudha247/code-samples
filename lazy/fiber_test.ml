(* open Unified_interface *)
open Printf
open SafeLazy2


let rec fib n = if n < 2 then n else fib (n - 1) + fib (n - 2)
let f = fun () -> (fib 42)

let v = from_fun f


let main () = 
    let new_domain = Domain.spawn (
        fun () ->
        Eio_main.run @@ fun _env ->
        Eio.Switch.run (fun sw ->
            (* printf "\nEio: Running in domain %d%!" (Domain.self () :> int); *)
            Eio.Fiber.fork ~sw
            (fun () -> 
            printf "\nDomain %d : Inside Eio Fiber 1%!" (Domain.self () :> int);
            let ans = force_gen v in
            printf "\nDomain %d: Value taken %d%!" (Domain.self () :> int) ans
            );
            Eio.Fiber.fork ~sw
            (fun () -> 
            printf "\nDomain %d : Inside Eio Fiber 2%!" (Domain.self () :> int);
            );
        )
    ) in ();

    Eio_main.run @@ fun _env ->
      Eio.Switch.run (fun sw ->
        (* printf "\nEio: Running in domain %d%!" (Domain.self () :> int); *)
        Eio.Fiber.fork ~sw
        (fun () -> 
          printf "\nDomain %d : Inside Eio Fiber 1%!" (Domain.self () :> int);
          let ans = force_gen v in
          printf "\nDomain %d: Value taken %d%!" (Domain.self () :> int) ans
        );
        Eio.Fiber.fork ~sw
        (fun () -> 
          printf "\nDomain %d : Inside Eio Fiber 2%!" (Domain.self () :> int);
        );
      );
     let _ = Domain.join new_domain in 
     printf "\nBoth the domains are done completed%!"

let _ = main ()