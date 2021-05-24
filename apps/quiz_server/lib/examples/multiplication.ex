defmodule QuizServer.Examples.Multiplication do
  @moduledoc """
  A ready made example that solves all elements in the process.
  It creates a multiplication table to check
  """
  alias QuizServer.Core.{Template, Quiz, Question}

  @table_integers 1..10

  def multiplication_solution(subs) do
    left = Keyword.fetch!(subs, :left)
    right = Keyword.fetch!(subs, :right)
    Integer.to_string(left * right)
  end

  def template_fields(overrides \\ []) do
    Keyword.merge(
      [
        name: :multiplication,
        instructions: "Multiplique los dos números",
        raw: "<%= @left %> * <%= @right %>",
        solutioner: &multiplication_solution/1
      ],
      overrides
    )
  end

  def build_template(overrides \\ []) do
    overrides
    |> template_fields()
    |> Template.new()
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

  def multiplication_input_generator(number_or_list \\ 7)

  def multiplication_input_generator(number) when is_integer(number) do
    for i <- @table_integers, do: [left: number, right: i]
  end

  def multiplication_input_generator(list_of_numbers) when is_list(list_of_numbers) do
    for i <- list_of_numbers, j <- @table_integers, do: [left: i, right: j]
  end

  def quiz_fields(overrides \\ []) do
    Keyword.merge(
      [
        title: "Tabla del 7",
        input_generator: &multiplication_input_generator/0,
        template: build_template()
      ],
      overrides
    )
  end

  def build_quiz(overrides \\ []) do
    overrides
    |> quiz_fields()
    |> Quiz.new()
  end
end
