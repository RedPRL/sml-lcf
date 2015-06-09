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

  fun annotate (metadata, tactic) goal =
    tactic goal handle Exn =>
      raise RefinementFailed
        {error = Exn,
         goal = goal,
         metadata = metadata}
end
