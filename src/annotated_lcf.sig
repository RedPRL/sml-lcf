signature ANNOTATED_LCF =
sig
  structure Lcf : LCF
  structure TacticAnnotation : TACTIC_ANNOTATION

  (* an annotated tactic *)
  type tactic

  (* construct an annotated tactic *)
  val make : TacticAnnotation.metadata * Lcf.tactic -> tactic

  (* compile an annotated tactic to an LCF tactic *)
  val compile : tactic * TacticAnnotation.annotation -> Lcf.tactic

  exception RefinementFailed of
    {error : exn,
     goal : Lcf.goal,
     metadata : TacticAnnotation.metadata,
     annotation : TacticAnnotation.annotation}
end
