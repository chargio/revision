defmodule Test.Boundary.ValidatorTest do
  @moduledoc """
  Tests for Validator
  """
  use ExUnit.Case
  alias QuizServer.Boundary.Validator

  @fields %{
    one: 1,
    two: 2,
    atom1: :test1,
    atom2: :test1,
    func: &Validator.validate_is_atom/1,
    string1: "one",
    string2: "two"
  }
  @previous_errors [{:txt, "one random error"}]

  describe "testing required" do
    test "required can test a single required" do
      errors = []
      assert Validator.required(errors, @fields, :one) == errors
    end

    test "required returns nothing on an empty list with empty required" do
      errors = []
      assert Validator.required(errors, @fields, []) == errors
    end

    test "required adds an error if a required field is not present" do
      errors = []
      assert Validator.required(errors, @fields, :three) == [{:three, "must be present"}]
    end

    test "required add new errors to exiting errors" do
      errors = @previous_errors
      assert Validator.required(errors, @fields, []) == errors
    end
  end

  describe "testing that the validator works with functions" do
    test "validate_with_function can test a single field with a function" do
      errors = []

      assert Validator.validate_with_function(
               errors,
               @fields,
               :atom1,
               &Validator.validate_is_atom/1
             ) == []
    end

    test "validate_with_function can test a list of fields with a function" do
      errors = []

      assert Validator.validate_with_function(
               errors,
               @fields,
               [:atom1, :atom2],
               &Validator.validate_is_atom/1
             ) == []

      assert Validator.validate_with_function(
               errors,
               @fields,
               [:atom1, :atom2, :one],
               &Validator.validate_is_atom/1
             ) == [one: "must be an atom"]

      assert Validator.validate_with_function(
               errors,
               @fields,
               [:atom1, :atom2, :non_existing],
               &Validator.validate_is_atom/1
             ) == errors
    end
  end

  describe "validating base functions" do
    test "validate is_string works on strings and not strings" do
      errors = []

      assert Validator.validate_with_function(
               errors,
               @fields,
               [:string1, :string2],
               &Validator.validate_is_string/1
             ) == []

      assert Validator.validate_with_function(
               errors,
               @fields,
               [:atom1, :string1],
               &Validator.validate_is_string/1
             ) == [atom1: "must be a string"]

      assert Validator.validate_with_function(
               errors,
               @fields,
               [:string1, :string2, :non_existing],
               &Validator.validate_is_string/1
             ) == errors
    end

    test "validate is_function works on functions and not functions" do
      errors = []

      assert Validator.validate_with_function(
               errors,
               @fields,
               [:func],
               &Validator.validate_is_function/1
             ) == errors

      assert Validator.validate_with_function(
               errors,
               @fields,
               [:func],
               &Validator.validate_is_function(&1, 1)
             ) == errors

      assert Validator.validate_with_function(
               errors,
               @fields,
               [:string1, :string2, :func],
               &Validator.validate_is_function/1
             ) == [{:string1, "must be a function"}, {:string2, "must be a function"}]

      assert Validator.validate_with_function(
               errors,
               @fields,
               [:func, :non_existing, :string1],
               &Validator.validate_is_function/1
             ) == [string1: "must be a function"]
    end
  end
end
