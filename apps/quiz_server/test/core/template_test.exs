defmodule QuizServer.TemplateTest do
  @moduledoc false

  use ExUnit.Case

  alias QuizServer.Examples.Multiplication
  alias QuizServer.Core.Template

  test "A new Template reflects the parameters used" do
    fields = Multiplication.template_fields()
    template = Template.new(fields)

    assert fields[:name] == template.name
    assert fields[:instructions] == template.instructions
    assert fields[:raw_query] == template.raw_query
    assert fields[:raw_solver] == template.raw_solver
  end

  test "A new template has a compiled query and solver" do
    fields = Multiplication.template_fields()
    template = Template.new(fields)

    refute is_nil(template.compiled_query)
    refute is_nil(template.compiled_solver)
  end

  test "you can change input paramters" do
    fields =
      Multiplication.template_fields(name: "Another name", instructions: "More instructions")

    assert fields[:name] == "Another name"
    assert fields[:instructions] == "More instructions"
  end

  test "building a test compiles the raw templates" do
    fields = Multiplication.template_fields()
    template = Template.new(fields)

    assert is_nil(Keyword.get(fields, :compiled_query))
    assert is_nil(Keyword.get(fields, :compiled_solver))
    refute is_nil(template.compiled_query)
    refute is_nil(template.compiled_solver)
  end

  test "building a template requires a name, raises an error otherwise" do
    fields = Multiplication.template_fields([]) |> Keyword.delete(:name)

    assert_raise ArgumentError, fn -> Template.new(fields) end
  end

  test "building a template requires instructions, raises an error otherwise" do
    fields = Multiplication.template_fields([]) |> Keyword.delete(:instructions)

    assert_raise ArgumentError, fn -> Template.new(fields) end
  end

  test "building a template requires a raw query, raises an error otherwise" do
    fields = Multiplication.template_fields([]) |> Keyword.delete(:raw_query)

    assert_raise ArgumentError, fn -> Template.new(fields) end
  end

  test "building a template requires a raw solver, raises an error otherwise" do
    fields = Multiplication.template_fields([]) |> Keyword.delete(:raw_solver)

    assert_raise ArgumentError, fn -> Template.new(fields) end
  end
end
