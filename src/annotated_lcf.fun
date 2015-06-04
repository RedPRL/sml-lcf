functor AnnotatedLcf
  (structure Lcf : LCF
   structure TacticAnnotation : TACTIC_ANNOTATION) : ANNOTATED_LCF =
struct
  structure Lcf = Lcf
  structure TacticAnnotation = TacticAnnotation
  open TacticAnnotation

  exception RefinementFailed of
    {error : exn,
     goal : Lcf.goal,
     metadata : TacticAnnotation.metadata,
     annotation : TacticAnnotation.annotation}

  structure Private =
  struct
    type tactic =
      {metadata : metadata,
       tactic : Lcf.tactic}

    fun make (metadata, tactic) =
      {metadata = metadata,
       tactic = tactic}

    fun compile ({metadata, tactic}, annotation) goal =
      tactic goal handle Exn =>
        raise RefinementFailed
          {error = Exn,
           goal = goal,
           metadata = metadata,
           annotation = annotation}
  end :
  sig
    type tactic
    val make : metadata * Lcf.tactic -> tactic
    val compile : tactic * annotation -> Lcf.tactic
  end

  open Private
end
