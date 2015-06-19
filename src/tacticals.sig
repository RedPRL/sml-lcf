signature TACTICALS =
sig
  type tactic

  val ID : tactic
  val THEN : tactic * tactic -> tactic
  val THENL : tactic * tactic list -> tactic
  val THEN_LAZY : tactic * (unit -> tactic) -> tactic
  val THENL_LAZY : tactic * (unit -> tactic list) -> tactic
  val REPEAT : tactic -> tactic

  val FAIL : tactic
  val ORELSE : tactic * tactic -> tactic
  val ORELSE_LAZY : tactic * (unit -> tactic) -> tactic
  val TRY : tactic -> tactic

  (* TRACE s will print out s to the console when run and then behave
   * like ID
   *)
  val TRACE : string -> tactic
end

signature PROGRESS_TACTICALS =
sig
  include TACTICALS

  val PROGRESS : tactic -> tactic
  val LIMIT : tactic -> tactic
end

