defmodule QuizServer.ResponseTest do
  @moduledoc false

  use ExUnit.Case

  alias QuizServer.Core.Response
  alias QuizServer.Examples.Multiplication

  defp new_quiz_and_question(context) do
    template = Multiplication.build_template()
    question = Multiplication.build_question(template: template)

    new_context = Map.merge(context, %{template: template, question: question})
    {:ok, new_context}
  end

  describe "Basic tests for Response" do
    setup [:new_quiz_and_question]

    test "A new response is a Response", %{question: question} do
      assert %Response{} = Response.new(question: question, response: "wrong")
    end

    test "A new response needs a Question" do
      assert_raise FunctionClauseError, fn ->
        Response.new(question: nil, response: "wrong")
      end
    end

    test "A new response needs a response", %{question: question} do
      assert_raise FunctionClauseError, fn ->
        Response.new(question: question, response: nil)
      end
    end

    test "A new response fails if the answer is not a string", %{question: question} do
      assert_raise FunctionClauseError, fn ->
        Response.new(question: question, response: 7)
      end
    end

    test "building responses checks answers", %{question: question} do
      right = Response.new(question: question, response: question.solution)
      wrong = Response.new(question: question, response: "wrong")
      assert right.correct?
      refute wrong.correct?
    end

    test "response has the date when it was created", %{question: question} do
      right = Response.new(question: question, response: question.solution)
      assert %DateTime{} = right.timestamp
      assert DateTime.compare(right.timestamp, DateTime.utc_now()) == :lt
    end
  end
end
