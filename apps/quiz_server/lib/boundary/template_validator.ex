defmodule QuizServer.Boundary.TemplateValidator do
  @moduledoc """
  Functions to validate Templates
  """
  import QuizServer.Boundary.Validator

  @doc """
  Errors returns an empty list or a list of all the errors when validating fields
  """
  def errors(fields) when is_list(fields) do
    fields = Map.new(fields)

    []
    |> required(fields, ~w[name instructions raw_query raw_solver]a)
    |> validate_with_function(fields, ~w[name instructions raw_query raw_solver]a, &validate_is_string/1)
  end

  def errors(_fields), do: [{nil, "A map of fields is required"}]

  def has_errors?(fields) do
    case errors(fields) do
      [] -> false
      _ -> true
    end
  end
end
