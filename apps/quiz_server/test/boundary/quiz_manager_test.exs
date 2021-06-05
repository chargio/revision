defmodule QuizServer.Boundary.QuizManagerTest do
  @moduledoc false
  use ExUnit.Case
  alias QuizServer.Examples.Multiplication
  alias QuizServer.Boundary.QuizManager
  alias QuizServer.Core.Quiz

  def create_transient_template_manager(context) do
    # Quiz fields include the template to be used
    quiz_fields = Multiplication.quiz_fields()

    new_context = Map.merge(context, %{quiz_fields: quiz_fields})

    {:ok, new_context}
  end

  def build_short_quiz(context) do
    qf = Multiplication.quiz_fields(inputs: [[left: 7, right: 8], [left: 7, right: 9]])
    {:ok, quiz} = QuizManager.build_quiz(qf)

    new_context = Map.merge(context, %{quiz: quiz})

    {:ok, new_context}
  end

  describe "Tests with existing template" do
    setup [:create_transient_template_manager]

    test "you can build  a new quiz with proper fields", %{quiz_fields: qf} do
      assert {:ok, _quiz} = QuizManager.build_quiz(qf)
    end

    test "trying to build a new quiz without parameters give an error", %{quiz_fields: qf} do
      assert {:error, [template: "must be a Template"]} =
               QuizManager.build_quiz(template: "hola", inputs: [])

      assert {:error, [inputs: "must be a list"]} =
               QuizManager.build_quiz(template: qf[:template], inputs: nil)

      assert {:error, [inputs: "must be a list", template: "must be a Template"]} =
               QuizManager.build_quiz(template: "hola", inputs: nil)
    end
  end

  describe "tests with short quiz" do
    setup [:build_short_quiz]

    test "You can advance the quiz answering questions until all the questions has been answered",
         %{quiz: quiz} do
      assert %Quiz{} = quiz
      assert {:ok, q2} = QuizManager.next_question(quiz)
      assert {:ok, q2a} = QuizManager.answer_question(q2, "bad response")
      assert {:ok, q3} = QuizManager.next_question(q2a)
      assert {:ok, q3a} = QuizManager.answer_question(q3, "bad response")
      assert {:finished, q4} = QuizManager.next_question(q3a)
      assert {:finished, _aa} = QuizManager.answer_question(q4, "bad response")
    end

    test "You can reset a quiz", %{quiz: quiz} do
      assert {:ok, q2} = QuizManager.next_question(quiz)
      assert {:ok, ^quiz} = QuizManager.reset_quiz(q2)
    end

    test "answering questions when there is no current provides an error", %{quiz: quiz} do
      assert is_nil quiz.current_question
      assert {:no_current_question, ^quiz} = QuizManager.answer_question(quiz, "it does not matter")
    end

  end
end
