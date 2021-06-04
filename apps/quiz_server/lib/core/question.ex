defmodule QuizServer.Core.Question do
  @moduledoc """
  A question that is part of a Quiz, using a template.
  """
  alias QuizServer.Core.Template

  @enforce_keys ~w[template parameters]a
  defstruct ~w[asked template parameters solution]a

  def new(%Template{} = template, parameters ) do
    %__MODULE__{
      asked: build_question(template, parameters),
      template: template,
      parameters: parameters,
      solution: build_solution(template, parameters)
    }
  end

  defp build_question(%Template{} = template, parameters) when is_list(parameters) do
    template.compiled_query
    |> Code.eval_quoted(assigns: parameters)
    |> elem(0)
  end

  defp build_solution(%Template{} = template, parameters) when is_list(parameters) do
    template.compiled_solver
    |> Code.eval_quoted(assigns: parameters)
    |> elem(0)
  end
end
