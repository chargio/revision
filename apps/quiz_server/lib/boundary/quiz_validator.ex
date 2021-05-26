defmodule QuizServer.Boundary.QuizValidator do
  @moduledoc """
  Functions to validate quizzes
  """
  import QuizServer.Boundary.Validator
  alias QuizServer.Core.Template

  def errors(fields) when is_map(fields) do
    []
    |> required(fields, ~w[title template input_generator]a)
    |> validate_with_function(fields, :title, &validate_is_atom/1)
    |> validate_with_function(fields, :input_generator, &validate_is_function/1)
    |> validate_with_function(fields, :template, &validate_is_template/1)
  end

  def errors(_fields), do: [{nil}, "A map of fields is required"]

  def has_errors?(fields) do
    case errors(fields) do
      [] -> {false, nil}
      errors -> {true, errors}
    end
  end

  def validate_is_template(%Template{} = _input), do: :ok
  def validate_is_template(_input), do: {:error, "must be a Template"}
end
