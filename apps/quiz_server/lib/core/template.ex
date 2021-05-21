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

  @enforce_keys ~w[name instructions raw checker]a
  defstruct ~w[name instructions raw compiled checker]a

  def new(fields) do
    raw = Keyword.fetch!(fields, :raw)

    # Compile the raw template into something actionable
    struct!(
      __MODULE__,
      Keyword.put(fields, :compiled, EEx.compile_string(raw))
    )
  end
end
