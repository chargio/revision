defmodule QuizServer.Core.Template do
  @moduledoc """
  Template of questions that will be asked.

  Name: the name of the template
  Instructions: the instructions to be shown when using the template
  Raw: the text description of the template
  Compiled: an EEx compiled version of the template used to generate questions
  Checker: a function to be sure that the response is correct
  <future> Alternatives: a generator of viable alternatives for the question
  """

  @enforce_keys ~w[name instructions raw solutioner]a
  defstruct ~w[name instructions raw compiled solutioner]a

  def new(fields) do
    # Let's make the exception to  be of the same type that the rest
    raw =
      try do
        Keyword.fetch!(fields, :raw)
      rescue
        _exception -> reraise ArgumentError, __STACKTRACE__
      end

    # Compile the raw template into something actionable
    struct!(
      __MODULE__,
      Keyword.put(fields, :compiled, EEx.compile_string(raw))
    )
  end
end
