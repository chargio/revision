defmodule Test.Boundary.QuizValidatorTest do
  @moduledoc """
  Tests for the Template Validator
  """
  use ExUnit.Case
  alias QuizServer.Examples.Multiplication
  alias QuizServer.Boundary.QuizValidator

  test "errors returns an empty list if everything is ok" do
    fields = Multiplication.quiz_fields()

    assert QuizValidator.errors(fields) == []
  end

  test "errors returns a list of all the errors" do
    fields = []

    assert QuizValidator.errors(fields) == [
             {:template, "must be present"},
             {:inputs, "must be present"}
           ]
  end

  test "has_errors? returns true or false" do
    fields = Multiplication.quiz_fields()

    assert QuizValidator.has_errors?(fields) == false
    assert QuizValidator.has_errors?([]) == true
  end
end
