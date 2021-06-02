defmodule QuizServer.QuestionTest do
  @moduledoc false

  alias QuizServer.Core.Question
  alias QuizServer.Examples.Multiplication

  use ExUnit.Case

  defp question_parameters(context) do
    question_fields = Multiplication.question_fields()
    new_context = Map.put(context, :question_fields, question_fields)

    {:ok, new_context}
  end

  describe "Questions created" do
    setup [:question_parameters]

    test "A new question is a question", %{
      question_fields: [template: template, parameters: parameters]
    } do
      question = Question.new(template, parameters)
      assert %Question{} = question
    end

    test "A new question requires a template", %{
      question_fields: [template: _template, parameters: parameters]
    } do
      assert_raise FunctionClauseError, fn -> Question.new(nil, parameters) end
    end

    test "A new question requires parameters", %{
      question_fields: [template: template, parameters: _parameters]
    } do
      assert_raise FunctionClauseError, fn -> Question.new(template, nil) end
    end

    test "A new question populates the response", %{
      question_fields: [template: template, parameters: parameters]
    } do
      question = Question.new(template, parameters)

      refute is_nil(question.asked)
      refute is_nil(question.solution)
    end
  end
end
