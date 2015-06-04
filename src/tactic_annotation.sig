signature TACTIC_ANNOTATION =
sig
  (* intrinsic information, such as: name, author, version *)
  type metadata

  (* use-dependent information, such as: source position *)
  type annotation
end
