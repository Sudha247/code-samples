(*Kronecker is using the following algorithm : 
 Function Kronecker generator(scale, edgefactor) :
 	N = 2^scale
 	M = edgefactor * N (No of edges)
 	[A,B,C] = [0.57, 0.19, 0.19]
 	ijw = {	{1,1,1,1,1,...Mtimes};
 			{1,1,1,1,1...Mtimes};
 			{1,1,1,1,1...Mtimes};
 			}
 	ab = A + B;
  	c_norm = C/(1 - (A + B));
  	a_norm = A/(A + B);
  	for i in (0, scale) :
  		ii_bit = rand(1,M) > ab;
  		jj_bit = rand (1, M) > ( c_norm * ii_bit + a_norm * not (ii_bit) );(not a: a xor 0)
  		ijw(1:2,:) = ijw(1:2,:) + 2^(ib-1) * [ii_bit; jj_bit];
  	ijw(3,:) = unifrnd(0, 1, 1, M);//produce values from 0 to 1 for 1*M array.
  	
  	p = randperm (N);	
  	ijw(1:2,:) = p(ijw(1:2,:));
  	p = randperm (M);
  	ijw = ijw(:, p);
  	ijw(1:2,:) = ijw(1:2,:) - 1;
	Here, the labels are from 0 to N-1.
*)

let scale = try int_of_string Sys.argv.(1) with _ -> 2

let edgefactor = try int_of_string Sys.argv.(2) with _ -> 1

let map f l =
  let rec map_aux acc = function
    | [] -> acc []
    | x :: xs -> map_aux (fun ys -> acc (f x :: ys)) xs
  in
  map_aux (fun ys -> ys) l

let zip_with f xs ys =
  let rec aux acc xs ys =
    match xs, ys with
    | [], _ -> List.rev acc
    | _, [] -> acc
    | x::xss, y::yss -> aux ((f x y)::acc) xss yss  
  in aux [] xs ys

let listGenerator m =
  List.init 3 (fun _ -> List.init m (fun _ -> 0.))

let randomWghtGen len =
  List.init len (fun _ -> Random.float 1.)
  (* if len = 0 then list else randomWghtGen (len - 1) (Random.float 1. :: list) *)

let generateIIBitList m ab =
  let rec aux acc n =
    if n = 0 then acc 
    else begin 
      match (Random.float @@ 1.) > ab with
      | true -> aux (1. :: acc) (n - 1)
      | false -> aux (0. :: acc) (n - 1)
    end
  in 
  aux [] m

let generateJJBitList ii_bit a_norm c_norm =
  let cmp b = if
    Random.float 1. 
    > (c_norm *. b) +. (a_norm *. float_of_int (int_of_float b lxor 1))
  then 1.
  else 0.
  in
  map (cmp) ii_bit 

let modifyRowIJW kk_list list index = 
  zip_with (fun x y -> y +. ((2.** float_of_int index) *. x)) kk_list list

let rec compareWithPr index m n ab a_norm c_norm ijw scale =
  if index = scale then ijw
  else
    let ii_bit = generateIIBitList m ab in
    let jj_bit = generateJJBitList ii_bit a_norm c_norm in
    let firstRowIJW = modifyRowIJW ii_bit (List.nth ijw 0) index in
    let secondRowIJW = modifyRowIJW jj_bit (List.nth ijw 1) index in
    let ijw = [ firstRowIJW ] @ [ secondRowIJW ] @ [ List.nth ijw 2 ] in
    compareWithPr (index + 1) m n ab a_norm c_norm ijw scale

let permute list = 
  let list = map (fun x -> (Random.bits (), x)) list in
  let list = List.sort compare list in
  map (fun x -> snd x) list

  let  transpose ls =
  let rec transpose_rec acc = function
  | [] | [] :: _ -> List.rev acc
  | ls -> transpose_rec (map (List.hd) ls :: acc) (map (List.tl) ls)
  in transpose_rec [] ls

let rec printList list =
  let _ = Printf.printf "\n" in
  match list with
  | [] -> Printf.printf "END"
  | head :: tail ->
      List.iter print_float head;
      printList tail

let rec writeFile ijw file = 
  match ijw with 
  [] -> None |
  head::tail -> let _ = List.iter (Printf.fprintf file "%f, ") head in let _ = Printf.fprintf file "\n" in writeFile tail file

let computeNumber scale edgefactor =
  let n = int_of_float (2. ** float_of_int scale) in
  let m = edgefactor * n in
  (n, m)

let kronecker scale edgefactor =
  let n, m = computeNumber scale edgefactor in
  let a, b, c = (0.57, 0.19, 0.19) in
  let ijw = listGenerator m in
  (*For debugging*)
  let ab = a +. b in
  let c_norm = c /. (1. -. (a +. b)) in
  let a_norm = a /. (a +. b) in
  let ijw = compareWithPr 0 m n ab a_norm c_norm ijw scale in
  (*For debugging*)
  let thirdRow = randomWghtGen m in
  let ijw = [ List.nth ijw 0 ] @ [ List.nth ijw 1 ] @ [ thirdRow ] in
  let firstRowPermute = permute (List.nth ijw 0) in
  let secondRowPermute = permute (List.nth ijw 1) in
  let ijw = [ firstRowPermute ] @ [ secondRowPermute ] @ [ List.nth ijw 2 ] in
  (*For debugging*)
  let ijw = permute (transpose ijw) in
  let ijw = transpose ijw in
  let _ = Sys.remove "kronecker.txt" in
  let file = open_out "kronecker.txt" in
  let _ = writeFile ijw file in
  let _ = close_out file in
  ijw

;;

kronecker scale edgefactor;;
