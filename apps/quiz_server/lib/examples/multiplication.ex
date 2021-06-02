defmodule QuizServer.Examples.Multiplication do
  @moduledoc """
  A sample Template and Quiz that can be generated using functions to test the logic of the application.
  """

  alias QuizServer.Core.{Template, Quiz, Question}

  @table_integers 1..10

  def raw_query() do
    "<%= @left %> * <%= @right %>"
  end

  def raw_solver() do
    "<%= @left * @right %>"
  end

  def template_fields(overrides \\ []) do
    Keyword.merge(
      [
        name: "Multiplication",
        instructions: "Multiply both numbers",
        raw_query: raw_query(),
        raw_solver: raw_solver()
      ],
      overrides
    )
  end

  def build_template(overrides \\ []) do
    overrides
    |> template_fields()
    |> Template.new()
  end

  def quiz_fields(overrides \\ []) do
    Keyword.merge(
      [title: "Tabla del 7", inputs: table_inputs(7), template: build_template()],
      overrides
    )
  end

  def question_fields(overrides \\ []) do
    Keyword.merge(
      [
        template: build_template(),
        parameters: [left: 7, right: 8]
      ],
      overrides
    )
  end

  def build_question(overrides \\ []) do
    fields =
      overrides
      |> question_fields()

    template = Keyword.get(fields, :template, nil)
    parameters = Keyword.get(fields, :parameters, nil)

    Question.new(template, parameters)
  end

  def build_quiz(overrides \\ []) do
    overrides
    |> quiz_fields()
    |> Quiz.new()
  end

  defp table_inputs(number) when is_integer(number) do
    for i <- @table_integers, do: [left: number, right: i]
  end
end
