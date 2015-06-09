signature ANNOTATED_LCF =
sig
  include LCF

  (* an annotated tactic *)
  type metadata

  (* construct an annotated tactic *)
  val annotate: metadata * tactic -> tactic

  exception RefinementFailed of
    {error : exn,
     goal : goal,
     metadata : metadata}
end
