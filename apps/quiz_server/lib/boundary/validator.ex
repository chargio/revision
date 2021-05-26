defmodule QuizServer.Boundary.Validator do
  @moduledoc """
  Functions to validate that the API inputs are properly configured
  """
  @type result_error :: {atom(), String.t()}
  @type validation_result :: :ok | {:error, String.t()}

  @spec required(list(result_error), map(), list() | atom()) :: list(result_error)
  @doc """
  Goes through a list of required fields and validate that they are present.
  It is fed with a list of errors, fields, and list of fields to validate
  and returns updated errors if there is something missing.
  """
  def required(errors, fields, validate_list) when is_list(validate_list) do
    validate_list
    |> Enum.reduce(errors, &required(&2, fields, &1))
  end

  # Validates that a single field is present and adds an error if it is not
  def required(errors, fields, required_field) do
    if Map.has_key?(fields, required_field) do
      add_error(:ok, errors, required_field)
    else
      add_error({:error, "must be present"}, errors, required_field)
    end
  end

  @spec validate_with_function(list(result_error), map(), list() | atom(), fun) ::
          list(result_error)
  @doc """
  Calls a function that returns validation_result to see if the field or fields are comformant with specifications.
  Adds the errors to the error list
  """
  def validate_with_function(errors, fields, field_list, f)
      when is_function(f) and is_list(field_list) do
    field_list |> Enum.reduce(errors, &validate_with_function(&2, fields, &1, f))
  end

  def validate_with_function(errors, fields, field_name, f) when is_function(f) do
    result =
      if Map.has_key?(fields, field_name) do
        Map.fetch!(fields, field_name)
        |> f.()
      else
        :ok
      end

    add_error(result, errors, field_name)
  end

  @spec validate_is_atom(any) :: validation_result()
  @doc """
  Validation to make sure that the field is an atom
  """
  def validate_is_atom(input) when is_atom(input), do: :ok
  def validate_is_atom(_input), do: {:error, "must be an atom"}

  @spec validate_is_string(any) :: validation_result()
  @doc """
  Validation to make sure that the field is a string
  """
  def validate_is_string(input) when is_binary(input), do: :ok
  def validate_is_string(_input), do: {:error, "must be a string"}

  @doc """
  Validation to make sure that the field is a function
  """

  @spec validate_is_function(any, integer()) :: validation_result()
  def validate_is_function(input, arity \\ 1)

  def validate_is_function(input, arity) when is_function(input, arity), do: :ok
  def validate_is_function(_input, _), do: {:error, "must be a function"}

  # If the validation is ok, then return the errors (no changes)
  defp add_error(:ok, errors, _field_name), do: errors

  # If there is a list of errors, add them all
  # TODO: find if there is any real requirement to do this
  # defp add_error({:error, messages}, errors, field_name) when is_list(messages) do
  #  errors ++ Enum.map(messages, &{field_name, &1})
  # end

  # If there is a single error, add it directly.
  defp add_error({:error, message}, errors, field_name) do
    errors ++ [{field_name, message}]
  end
end
