open Tezos_crypto
open Domainslib.Task

type tree = Empty | Leaf of int option | Node of tree * tree

module Merkle = Blake2B.Generic_Merkle_tree (struct
  type t = tree

  type elt = int option

  let empty = Empty

  let leaf i = Leaf i

  let node x y = Node (x, y)
end)

let parallel_map pool ?(chunk_size=0) f arr =
  let len = Array.length arr in
  let res = Array.make len (f arr.(0)) in
  parallel_for ~chunk_size ~start:1 ~finish:(len - 1)
  ~body:(fun i ->
    res.(i) <- (f arr.(i))) pool;
  res

let l = List.init 50000 (fun i -> List.init 10000 (fun j -> Some (i+j)))

let num_domains = try int_of_string Sys.argv.(1) with _ -> 1

let arr = Array.of_list l

let p = setup_pool ~num_additional_domains:(num_domains - 1) ()

let t1 = Unix.gettimeofday ()

let c =  parallel_map p Merkle.compute arr

let t2 = Unix.gettimeofday () 

let _ = Format.printf "time = %f\n" (t2 -. t1)