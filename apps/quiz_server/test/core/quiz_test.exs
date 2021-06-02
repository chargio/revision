defmodule QuizServer.QuizTest do
  @moduledoc false

  use ExUnit.Case

  alias QuizServer.Examples.Multiplication
  alias QuizServer.Core.{Quiz, Response}

  def quiz_fields_set(context) do
    {:ok, Map.put(context, :quiz_fields, Multiplication.quiz_fields())}
  end

  def quiz_with_question_selected_create(context) do
    {:ok, quiz} = Multiplication.build_quiz() |> Quiz.next_question()
    {:ok, Map.put(context, :quiz, quiz)}
  end

  def quiz_with_two_questions_one_selected(context) do
    quiz = Multiplication.build_quiz(inputs: [[left: 7, right: 8], [left: 7, right: 7]])
    {:ok, quiz} = Quiz.next_question(quiz)
    {:ok, Map.put(context, :quiz, quiz)}
  end

  describe "Quiz creation" do
    setup [:quiz_fields_set]

    test "you can create a quiz", %{quiz_fields: quiz_fields} do
      assert %Quiz{} = Quiz.new(quiz_fields)
    end

    test "creation fails when title is missing", %{quiz_fields: quiz_fields} do
      fields = Keyword.delete(quiz_fields, :title)

      assert_raise ArgumentError, fn -> Quiz.new(fields) end
    end

    test "creation fails when template is missing", %{quiz_fields: quiz_fields} do
      fields = Keyword.delete(quiz_fields, :template)

      assert_raise ArgumentError, fn -> Quiz.new(fields) end
    end

    test "creation fails when inputs are missing", %{quiz_fields: quiz_fields} do
      fields = Keyword.delete(quiz_fields, :inputs)

      assert_raise ArgumentError, fn -> Quiz.new(fields) end
    end

    test "a newly created quiz has no current question", %{quiz_fields: quiz_fields} do
      quiz = Quiz.new(quiz_fields)

      assert is_nil(quiz.current_question)
    end

    test "you can't answer if there is no current question", %{quiz_fields: quiz_fields} do
      quiz = Quiz.new(quiz_fields)

      assert {:no_current_question, ^quiz} = Quiz.answer_question(quiz, "very bad")
    end

    test "a newly created quiz has no current answer", %{quiz_fields: quiz_fields} do
      quiz = Quiz.new(quiz_fields)

      assert is_nil(quiz.last_response)
    end

    test "reseting a quiz deletes responses and makes questions start from scratch", %{
      quiz_fields: quiz_fields
    } do
      quiz = Quiz.new(quiz_fields)
      assert is_nil(quiz.current_question)
      new_quiz = Quiz.reset_quiz(quiz)
      assert is_nil(quiz.current_question)

      assert new_quiz.template == quiz.template
      assert new_quiz.title == quiz.title
      assert new_quiz.questions == new_quiz.questions
      assert new_quiz.inputs == quiz.inputs
      assert new_quiz.incorrect == []
      assert new_quiz.correct == []
      assert new_quiz.record == %{good: 0, bad: 0}
    end
  end

  describe "answering questions" do
    setup [:quiz_with_question_selected_create]

    test "asking for next question returns the same question until it is answered", %{quiz: quiz} do
      {:ok, next} = Quiz.next_question(quiz)

      assert next.current_question == quiz.current_question
    end

    test "answering a question leaves updates the quiz, no current question and answer in last_response",
         %{quiz: quiz} do
      new_quiz = Quiz.answer_question(quiz, "wrong response")
      assert is_nil(new_quiz.current_question)

      assert %Response{} = new_quiz.last_response

      assert new_quiz.record[:good] == 0
      assert new_quiz.record[:bad] == 1
      assert new_quiz.incorrect == [new_quiz.last_response]
    end

    test "it is possible to answer the quizzes with a Response", %{quiz: quiz} do
      response = Response.new(question: quiz.current_question, response: "wrong")

      answered = Quiz.answer_question(quiz, response)
      assert %Quiz{} = answered

      assert %Response{} = answered.last_response

      assert answered.incorrect == [response]
    end

    test "answering correctly and incorrectly increases record values", %{quiz: quiz} do
      {:ok, quiz} = Quiz.reset_quiz(quiz) |> Quiz.next_question()

      assert quiz.record[:good] == 0
      assert quiz.record[:bad] == 0
      assert quiz.remaining == quiz.questions -- [quiz.current_question]

      response1 =
        Response.new(question: quiz.current_question, response: quiz.current_question.solution)

      answered1 = Quiz.answer_question(quiz, response1)

      assert answered1.record[:good] == 1
      assert answered1.record[:bad] == 0
      assert answered1.correct == [response1]

      assert length(answered1.remaining) == length(answered1.questions) - 1

      {:ok, new_question} = Quiz.next_question(answered1)

      response2 = Response.new(question: new_question.current_question, response: "bad response")

      answered2 = Quiz.answer_question(new_question, response2)

      assert answered2.record[:good] == 1
      assert answered2.record[:bad] == 1

      assert answered2.correct == [response1]
      assert answered2.incorrect == [response2]

      assert [response1.question, response2.question] ++ answered2.remaining ==
               answered2.questions
    end
  end

  describe "end of quiz" do
    setup [:quiz_with_two_questions_one_selected]

    test "when running out of questions, you get :finished as the result", %{quiz: quiz} do
      # We create the quiz with two questions, one remaining and one in current question.
      assert length(quiz.remaining) + 1 == 2
      # We answer the question (badly) and advance to the next question
      {:ok, q2} = Quiz.answer_question(quiz, "bad") |> Quiz.next_question()

      # There is only one in current_question
      refute is_nil(q2.current_question)
      assert length(q2.remaining) + 1 == 1

      # We answer the next question, and last, so there is no question remaining.
      q3 = Quiz.answer_question(q2, "also bad")

      # Thers is no current_question, and nothing remaining
      assert q3.current_question == nil
      assert q3.remaining == []
      assert {:no_current_question, q4} = Quiz.answer_question(q3, "very bad")

      # Next question returns that is finished
      assert q4.current_question == nil
      assert {:finished, _q5} = Quiz.next_question(q4)
    end
  end
end
