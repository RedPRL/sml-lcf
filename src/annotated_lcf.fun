(* Given any LCF system we can trivially annotate its tactics.  This
 * lets us add information to when tactic fails (specifically the
 * exception it throws). This will let us distinguish failing tactics
 * and present error information such a source locations to the user.
 *)
functor AnnotatedLcf
  (structure Lcf : LCF
   type metadata) : ANNOTATED_LCF =
struct
  type metadata = metadata
  open Lcf

  exception RefinementFailed of
    {error : exn,
     goal : goal,
     metadata : metadata}

  (* If the tactic succeeds, annotating it will do
   * nothing. The tactic is only affected by operations
   * if it throws an exception in which case the exception
   * is wrapped up into a RefinementFailed exception and
   * reraised.
   *)
  fun annotate (metadata, tactic) goal =
    tactic goal handle Exn =>
      raise RefinementFailed
        {error = Exn,
         goal = goal,
         metadata = metadata}
end
