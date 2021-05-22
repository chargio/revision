defmodule TemplateTest do
  @moduledoc """
  Tests for Template
  """
  use ExUnit.Case

  alias QuizServer.Examples.Multiplication
  alias QuizServer.Core.Template

  test "building a test compiles the raw template" do
    fields = Multiplication.template_fields([])
    template = Template.new(fields)

    assert is_nil(Keyword.get(fields, :compiled))
    assert not is_nil(template.compiled)
  end

  test "building a test requires a name and raises an error" do
    fields = Multiplication.template_fields([]) |> Keyword.delete(:name)

    assert_raise ArgumentError, fn -> Template.new(fields) end
  end

  test "building a test requires instructions and raises an error" do
    fields = Multiplication.template_fields([]) |> Keyword.delete(:instructions)

    assert_raise ArgumentError, fn -> Template.new(fields) end
  end

  test "building a test requires a checker and raises an erro" do
    fields = Multiplication.template_fields([]) |> Keyword.delete(:solutioner)

    assert_raise ArgumentError, fn -> Template.new(fields) end
  end

  test "building a test requires a raw template and raises an erro" do
    fields = Multiplication.template_fields([]) |> Keyword.delete(:raw)

    assert_raise ArgumentError, fn -> Template.new(fields) end
  end
end
