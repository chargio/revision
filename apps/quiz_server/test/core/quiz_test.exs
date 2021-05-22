defmodule QuizTest do
  # Template.new(name: "hola", instructions: "fill the gap", raw: "<%= @left %> * <%= @right %>", checker: checker)
  use ExUnit.Case

  alias QuizServer.Examples.Multiplication
  alias QuizServer.Core.{Quiz, Question, Response}

  @valid_id "XYZ"

  def quiz_fields_set(context) do
    {:ok, Map.put(context, :quiz_fields, Multiplication.quiz_fields())}
  end

  def quiz_creation(context) do
    {:ok, Map.put(context, :quiz, Multiplication.build_quiz())}
  end

  describe "quiz creation" do
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

    test "creation fails when input_generator is missing", %{quiz_fields: quiz_fields} do
      fields = Keyword.delete(quiz_fields, :input_generator)

      assert_raise ArgumentError, fn -> Quiz.new(fields) end
    end

    test "a new quiz gets x number of questions and selects the first one", %{
      quiz_fields: quiz_fields
    } do
      inputs = quiz_fields[:input_generator].()

      assert length(inputs) > 0
      quiz = Quiz.new(quiz_fields)
      # current_question holds the question we are asking
      assert length(inputs) == length(quiz.questions)
      assert length(quiz.remaining) == length(inputs) - 1
    end

    test "a new quiz with a list for input generates x * 10 questions" do
      generator = fn -> Multiplication.multiplication_input_generator(7..9 |> Enum.to_list()) end
      inputs = generator.()
      assert length(inputs) == 3 * 10

      quiz = Multiplication.build_quiz(input_generator: generator)

      assert length(inputs) == length(quiz.questions)
    end

    test "a newly created quiz has a current question", %{quiz_fields: quiz_fields} do
      quiz = Quiz.new(quiz_fields)

      assert %Question{} = quiz.current_question
      assert quiz.template == quiz.current_question.template
    end

    test "a newly created quiz has no current answer", %{quiz_fields: quiz_fields} do
      quiz = Quiz.new(quiz_fields)

      assert is_nil(quiz.last_response)
    end
  end

  describe "answering a question" do
    setup [:quiz_creation]

    test "reseting a quiz deletes responses and makes thing start from scratch", %{quiz: quiz} do
      new_quiz = Quiz.reset_quiz(quiz)

      assert new_quiz.template == quiz.template
      assert new_quiz.title == quiz.title
      assert new_quiz.questions == new_quiz.questions
      assert new_quiz.input_generator == quiz.input_generator
      assert new_quiz.incorrect == []
      assert new_quiz.correct == []
      assert new_quiz.record == %{good: 0, bad: 0}
    end

    test "asking for next question returns the same question if it is not answered", %{
      quiz: quiz
    } do
      refute is_nil(quiz.current_question)
      advance = Quiz.next_question(quiz)

      assert quiz.current_question == advance.current_question
    end

    test "answer a question leaves with no current question and the answer in last_response", %{
      quiz: quiz
    } do
      response = Response.new(question: quiz.current_question, id: @valid_id, answer: "wrong")

      new_quiz = Quiz.answer_current_question(quiz, response)
      assert is_nil(new_quiz.current_question)

      assert new_quiz.last_response == response
      assert new_quiz.record[:good] == 0
      assert new_quiz.record[:bad] == 1
      assert new_quiz.incorrect == [response]
    end

    test "anwering correctly and incorrectly increases record", %{quiz: quiz} do
      quiz = Quiz.reset_quiz(quiz)


      response =
        Response.new(
          question: quiz.current_question,
          id: @valid_id,
          answer: quiz.current_question.solution
        )

      assert quiz.record[:good] == 0
      assert quiz.record[:bad] == 0

      good_answer =
        Quiz.answer_current_question(quiz, response)

      assert good_answer.record[:good] == 1
      assert good_answer.correct == [response]

      with_next_question = (good_answer |> Quiz.next_question)

      bad_response =
        Response.new(
          question: with_next_question.current_question,
          id: @valid_id,
          answer: "wrong"
        )

      bad_answer = Quiz.answer_current_question(with_next_question, bad_response)

      assert bad_answer.record[:good] == 1
      assert bad_answer.record[:bad] == 1
      assert bad_answer.incorrect == [bad_response]

    end

    test "asking for next question returns a new question if there is no current question", %{
      quiz: quiz
    } do
      response = Response.new(question: quiz.current_question, id: @valid_id, answer: "wrong")
      new_quiz = Quiz.answer_current_question(quiz, response)

      assert is_nil(new_quiz.current_question)

      new_question_quiz = Quiz.next_question(new_quiz)

      refute is_nil(new_question_quiz.current_question)
    end
  end
end
