# Lwt_domain examples

This folder contains some examples of `Lwt_domain` module.

### Fibonacci server

1. `fib.ml` - sequential version
2. `fibp.ml` - parallel version
3. `client.ml` - client that connects with the server, sends input to the server
   and receives the outputs.

### Others

1. `test_detach_main.ml` - run_in_main runs the computation in the main domain (Domain 0)