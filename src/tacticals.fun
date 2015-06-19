(* See tacticals.sig for a description of the types and
 * effects of these tactics. This structure only contains
 *  documentation on how these tactics are implemented.
 *)
functor Tacticals (Lcf : LCF) : TACTICALS =
struct
  open Lcf

  fun FAIL g =
    raise Fail "FAIL"

  (* Note here that ID's validation may through an
   * exception if is applied to the wrong number of
   * subgoals
   *)
  fun ID g =
    ([g], fn [D] => D | _ => raise Fail "ID")

  (* map_shape takes 3 lists
   *   1. A list of numbers
   *   2. A list of functions
   *     The second list must be at least as long as the first.
   *   3. A list of arguments
   *     The third list must have at least n elements where n is the
   *     sum of the first list.
   *
   * This function breaks the third list into a bunch of sublist,
   * each sublists length is given by the corresponding entry in
   * the first list. Each of these sublists are then fed to
   * corresponding entry in the function list. The results are then
   * collected and returned.
   *
   * For example map_shape [1, 2] [List.sum, List.product] [1, 2, 3]
   * would result in [1, 6] if List.sum and List.product had the obvious
   * meanings.
   *)
  fun map_shape [] _ _ =  []
    | map_shape (n1::nums) (f1::funcs) args =
        let
          val (f1_args,args') = ListUtil.splitAt n1 args
        in
          f1 f1_args :: map_shape nums funcs args'
        end
    | map_shape _ _ _ = raise Subscript

  local
    (* refine takes a validation for a goal, a list of lists of
     * subgoals and a list of their validations and produces a piece
     * of pair of subgoals and a validation for them. The subgoals
     * produced are created by joining the list of subgoal lists
     * provideded.
     *
     * This essentially glues together a two layer deep "tree" of tactic
     * results. It's useful for THEN which needs to collect the results
     * of applying a tactic to a bunch of subgoals.
     *)
    fun refine (supervalidation, subgoals, validations) =
      (List.concat subgoals,
       supervalidation o
         map_shape (map length subgoals) validations)
  in
    (* The THEN* family of tactics are all implemented in terms of
     * THENL_LAZY and THENL.
     *)

    fun THENL_LAZY (tac1, tacn) g =
      case tac1 g of
           (* If there are no subgoals, just return the validation *)
           ([], validation1) => ([], validation1)
         | (subgoals1, validation1) =>
             let
               (* We recursively apply each tactic to the list of subgoals
                * If they don't match this throws an exception. We then
                * separate all the new subgoals and all the new validations
                *)
               val (subgoals2, validations2) =
                 ListPair.unzip (ListPair.mapEq (fn (f,x) => f x) (tacn (), subgoals1))
             in
               (* We the use refine to glue together all the validations and
                * subgoals so that evidence is "properly propagated" up the
                * tree of subgoals
                *)
               refine (validation1, subgoals2, validations2)
             end

    fun THEN_LAZY (tac1, tac2) g =
      case tac1 g of
           ([], validation1) => ([], validation1)
         | (subgoals1, validation1) =>
             let
               (* This is crucial difference from THENL_LAZY, instead of using
                * ListPair.mapEq to pair up tactics with subgoals we just
                * map the same tactic over all of the subgoals. Otherwise
                * they're identical.
                *)
               val (subgoals2, validations2) = ListPair.unzip (List.map (tac2 ()) subgoals1)
             in
               refine (validation1, subgoals2, validations2)
             end
  end

  fun THENL (tac1, tacn) =
    THENL_LAZY (tac1, fn () => tacn)

  fun THEN (tac1, tac2) =
    THEN_LAZY (tac1, fn () => tac2)

  (* TODO: Should ORELSE_LAZY have some idea of
   * how to keep track of failing tactics to present
   * a summary to the user?
   *
   * This wouldn't be hard to implement and potentially makes
   * debugging much easier.
   *)
  fun ORELSE_LAZY (tac1, tac2) g =
    tac1 g handle _ => tac2 () g

  fun ORELSE (tac1, tac2) =
    ORELSE_LAZY (tac1, fn () => tac2)

  fun TRY tac =
    ORELSE(tac, ID)

  fun REPEAT tac = TRY (THEN_LAZY (tac, fn () => TRY (REPEAT tac)))
end

functor ProgressTacticals (Lcf : LCF_APART) : PROGRESS_TACTICALS =
struct
  structure Tacticals = Tacticals (Lcf)
  open Tacticals

  fun PROGRESS tac g =
    let
      (* Run the tactic and get the subgoal *)
      val result as (subgoals, validation) = tac g
      (* Shell out to Lcf.goalApart in order to tell whether
       * any difference has been made. This will fail if *any*
       * of the generated subgoals don't change with respect to original.
       *)
      val made_progress = foldl (fn (g', b) => Lcf.goalApart (g', g) andalso b) true subgoals
    in
      if made_progress then
        result
      else
        raise Fail "PROGRESS"
    end

  val LIMIT = REPEAT o PROGRESS
end
