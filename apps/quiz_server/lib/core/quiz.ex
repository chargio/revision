defmodule QuizServer.Core.Quiz do
  @moduledoc """
  Quiz questions, will be used to follow the user while the answer some questions.
  """

  alias QuizServer.Core.{Template, Question, Response}

  @enforce_keys [:title, :template, :input_generator]
  defstruct title: nil,
            template: nil,
            used: [],
            current_question: nil,
            last_response: nil,
            questions: [],
            input_generator: nil,
            incorrect: [],
            correct: [],
            record: %{good: 0, bad: 0}

  def new(fields) do
    struct!(__MODULE__, fields)
    |> populate_questions()
    |> pick_current_question()
  end

  def populate_questions(%{template: template} = quiz) do
    questions =
      generate_inputs(quiz)
      |> Enum.shuffle()
      |> Enum.map(&Question.new(template, &1))

    Map.put(quiz, :questions, questions)
  end

  def generate_inputs(quiz) when is_function(quiz.input_generator) do
    quiz.input_generator.()
  end

  def select_question(quiz) do
    quiz
    |> pick_current_question
    |> maybe_reset_questions
  end

  def pick_current_question(%{questions: [head | tail]} = quiz) do
    Map.put(quiz, :current_question, head)
    |> Map.put(:questions, tail)
  end

  def pick_current_question(_) do
    nil
  end

  def maybe_reset_questions(%{questions: [_head | _tail]} = quiz) do
    quiz
  end

  def maybe_reset_questions(%{incorrect: incorrect} = quiz) do
    quiz
    |> Map.put(:questions, incorrect)
    |> Map.put(:incorrect, [])
  end

  def answer_question(quiz, %Response{correct: true} = response) do
    quiz
    |> inc_record(:correct)
    |> save_response(response)
  end

  def answer_question(quiz, %Response{correct: false} = response) do
    quiz
    |> inc_record(:incorrect)
    |> save_response(response)
  end

  def inc_record(quiz, :correct) do
    new_record = Map.update(quiz.record, :good, 1, &(&1 + 1))
    Map.put(quiz, :record, new_record)
  end

  def inc_record(quiz, :incorrect) do
    new_record = Map.update(quiz.record, :bad, 1, &(&1 + 1))
    Map.put(quiz, :record, new_record)
  end

  def save_response(quiz, response) do
    Map.put(quiz, :last_response, response)
  end
end
