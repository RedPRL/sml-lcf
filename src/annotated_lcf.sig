(* In order to support a more robust form a failure
 * for a tactic, we have a notion of an LCF system
 * which knows how to annotate tactics. This lets a
 * failing tactic give information about what went wrong.
 *)
signature ANNOTATED_LCF =
sig
  (* This is a strict superset of an unannoted system *)
  include LCF

  (* an annotated tactic *)
  type metadata

  (* construct an annotated tactic *)
  val annotate: metadata * tactic -> tactic

  (* A failing tactic will throw this in order to
   * describe where it has died.
   *)
  exception RefinementFailed of
    {error : exn,
     goal : goal,
     metadata : metadata}
end
