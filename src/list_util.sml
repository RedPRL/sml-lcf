structure ListUtil :
sig
  (* Given a list, break it into two sublists at a
   * particular index. If the index is too large for
   * supplied list this raises the Subscript exception
   *)
  val splitAt : int -> 'a list -> 'a list * 'a list
end =
struct
  local
    fun go _ [] = ([], [])
      | go 1 (x::xs) = ([x], xs)
      | go m (x::xs) =
        let val
          (xs', xs'') = go (m - 1) xs
        in
          (x::xs', xs'')
        end
  in
    fun splitAt n ls =
      if n < 0 then
        raise Subscript
      else
        if n = 0 then ([], ls)
      else
        go n ls
  end
end
