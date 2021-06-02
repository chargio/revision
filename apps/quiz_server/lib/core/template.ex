defmodule QuizServer.Core.Template do
  @moduledoc """
  Template that enables to create new questions.

  Name: the name of the template
  Instructions: A string showing the instructions to be shown to show how to fill the questions
  Raw: the text version of the template, to be compiled.
  Compiled: An EEx version of the template used to generate questions.
  RAW_Solution: A text version, in  EEX format, of the solution to the query
  Compiled Solution: An EEx version opf the solution so they can be easily compared.
  TODO: Alternatives: A way of generating alternatives to the proper answer
  """

  @enforce_keys ~w[name instructions raw_query raw_solver]a
  defstruct ~w[name instructions raw_query compiled_query raw_solver compiled_solver]a

  def new(fields) do
    raw_query =
      try do
        Keyword.fetch!(fields, :raw_query)
      rescue
        _exception -> reraise ArgumentError, __STACKTRACE__
      end

    raw_solver =
      try do
        Keyword.fetch!(fields, :raw_solver)
      rescue
        _exception -> reraise ArgumentError, __STACKTRACE__
      end

    struct!(
      __MODULE__,
      Keyword.merge(fields,
        compiled_query: EEx.compile_string(raw_query),
        compiled_solver: EEx.compile_string(raw_solver)
      )
    )
  end
end
