signature LCF =
sig
  type goal
  type evidence

  type validation = evidence list -> evidence
  type tactic = goal -> goal list * validation

  val goalToString : goal -> string
end

(* If goals have an apartness relation, then we may express the notion of "progress". *)
signature LCF_APART =
sig
  include LCF

  val goalApart : goal * goal -> bool
end

