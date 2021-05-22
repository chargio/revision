defmodule QuizServer.Core.Question do
  @moduledoc """
  Questions are built from templates and allow us to make the template an item that we can act upon
  """
  alias QuizServer.Core.Template
  @enforce_keys [:template, :parameters]
  defstruct ~w[asked template parameters solution]a

  def new(%Template{} = template, parameters) do
    %__MODULE__{
      asked: build_question(template, parameters),
      parameters: parameters,
      template: template,
      solution: build_solution(template, parameters)
    }
  end

  defp build_question(template, parameters) do
    template.compiled
    |> Code.eval_quoted(assigns: parameters)
    |> elem(0)
  end

  defp build_solution(template, parameters) do
    template.solutioner.(parameters)
  end
end
