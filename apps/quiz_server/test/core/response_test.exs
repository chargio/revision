defmodule ResponseTest do
  @moduledoc """
  Tests for the response
  """
  use ExUnit.Case
  alias QuizServer.Core.Response
  alias QuizServer.Examples.Multiplication

  @valid_id "XYZ"

  defp new_quiz_and_question(context) do
    template = Multiplication.build_template()
    question = Multiplication.build_question()
    new_context = Map.put(context, :template, template) |> Map.put(:question, question)
    {:ok, new_context}
  end

  describe "Basic tests for a response" do
    setup [:new_quiz_and_question]

    test "A new response is a Response", %{question: question} do
      assert %Response{} = Response.new(question: question, id: @valid_id, answer: "wrong")
    end

    test "Response needs an id", %{question: question} do
      assert_raise FunctionClauseError, fn ->
        Response.new(question: question, answer: "wrong")
      end
    end

    test "Response needs a question" do
      assert_raise FunctionClauseError, fn -> Response.new(id: @valid_id, answer: "wrong") end
    end

    test "Response needs an answer", %{question: question} do
      assert_raise FunctionClauseError, fn -> Response.new(question: question, id: @valid_id) end
    end

    test "building responses checks answers", %{question: question} do
      right = Response.new(question: question, id: "XYZ", answer: question.solution)
      wrong = Response.new(question: question, id: "XYZ", answer: "wrong")
      assert right.correct
      refute wrong.correct
    end

    test "response has the date when it was created", %{question: question} do
      right = Response.new(question: question, id: "XYZ", answer: question.solution)
      assert %DateTime{} = right.timestamp
      assert right.timestamp < DateTime.utc_now()
    end
  end
end
