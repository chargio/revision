defmodule TemplateTest do
  @moduledoc """
  Tests for Template
  """
  use ExUnit.Case

  alias QuizServer.Examples.Multiplication
  alias QuizServer.Core.Template


  test "a new Template reflect the parameters used" do
    fields = Multiplication.template_fields()
    template = Template.new(fields)

    assert fields[:name] == template.name
    assert fields[:instructions] == template.instructions
    assert fields[:solutioner] == template.solutioner
    assert fields[:raw] == template.raw
  end

  test "you can change imput parameters" do
    fields = Multiplication.template_fields(name: :name, instructions: "template.instructions")

    assert fields[:name] == :name
    assert fields[:instructions] == "template.instructions"
  end

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
