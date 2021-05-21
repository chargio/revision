defmodule QuizServer.Core.Question do
  alias QuizServer.Core.Template

  @moduledoc """
  Questions are built from templates and allow us to make the template an item that we can act upon
  """
  defstruct ~w[asked template parameters answer]a

  def new(%Template{} = template, parameters) do
    %__MODULE__{
      asked: build_question(template, parameters),
      parameters: parameters,
      template: template
    }
  end

  def build_question(template, parameters) do
    template.compiled
    |> Code.eval_quoted(assigns: parameters)
    |> elem(0)
  end
end
