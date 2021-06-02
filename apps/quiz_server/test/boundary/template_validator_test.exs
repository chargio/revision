defmodule Test.Boundary.TemplateValidatorTest do
  @moduledoc """
  Tests for the Template Validator
  """
  use ExUnit.Case
  alias QuizServer.Examples.Multiplication
  alias QuizServer.Boundary.TemplateValidator

  test "errors returns an empty list if everything is ok" do
    fields = Multiplication.template_fields()

    assert TemplateValidator.errors(fields) == []
  end

  test "errors returns a list of all the errors" do
    fields = []

    assert TemplateValidator.errors(fields) == [
             {:name, "must be present"},
             {:instructions, "must be present"},
             {:raw_query, "must be present"},
             {:raw_solver, "must be present"}
           ]
  end

  test "has_errors? returns true or false" do
    fields = Multiplication.template_fields()

    assert TemplateValidator.has_errors?(fields) == false
    assert TemplateValidator.has_errors?([]) == true
  end
end
