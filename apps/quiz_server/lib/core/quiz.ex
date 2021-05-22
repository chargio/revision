defmodule QuizServer.Core.Quiz do
  @moduledoc """
  Quiz questions, will be used to follow the user while the answer some questions.
  """

  alias QuizServer.Core.{Question, Response}

  @enforce_keys [:title, :template, :input_generator]
  defstruct title: nil,
            template: nil,
            remaining: [],
            current_question: nil,
            last_response: nil,
            questions: [],
            input_generator: nil,
            incorrect: [],
            correct: [],
            record: %{good: 0, bad: 0}

  @doc """
  Creates an new Quiz populating the data with the fields
  """
  def new(fields) do
    struct!(__MODULE__, fields)
    |> populate_questions()
    |> pick_current_question()
  end

  @doc """
  Selects the new question from the quiz
  If a current_question exists, then returns the same
  """
  def next_question(%__MODULE__{current_question: nil} = quiz) do
    quiz
    |> pick_current_question
  end

  def next_question(quiz) do
    quiz
  end

  @doc """
  Compares a question with an answer and udpates the quiz appropriately.
  It sets current_question to nil.
  """
  def answer_current_question(
        %__MODULE__{current_question: question} = quiz,
        %Response{correct: true, question: question} = response
      ) do
    quiz
    |> save_response(response)
    |> inc_record(:correct)
    |> clean_current_question()
  end

  def answer_current_question(
        %__MODULE__{current_question: question} = quiz,
        %Response{correct: false, question: question} = response
      ) do
    quiz
    |> save_response(response)
    |> inc_record(:incorrect)
    |> clean_current_question()
  end

  def answer_current_question(quiz, _response) do
    quiz |> Map.put(:last_response, {:error, "only current question can be answered"})
  end

  @doc """
  Resets the quiz to its original form.
  """
  def reset_quiz(
        %__MODULE__{
          questions: questions,
          title: title,
          input_generator: input_generator,
          template: template
        } = _quiz
      ) do
    struct!(__MODULE__,
      questions: questions,
      remaining: questions,
      title: title,
      input_generator: input_generator,
      template: template
    )
    |> pick_current_question()
  end

  # Populates the questions with the input generator and the template.
  defp populate_questions(%{template: template} = quiz) do
    questions =
      generate_inputs(quiz)
      |> Enum.shuffle()
      |> Enum.map(&Question.new(template, &1))

    Map.put(quiz, :questions, questions)
    |> Map.put(:remaining, questions)
  end

  # Calls the input generator to calculate the inputs
  defp generate_inputs(quiz) when is_function(quiz.input_generator) do
    quiz.input_generator.()
  end

  # If there are remaining questions, pick one,
  # put it in current_question, and modify remaining.
  # If not, just return :empty
  defp pick_current_question(%{remaining: [head | tail]} = quiz) do
    Map.put(quiz, :current_question, head)
    |> Map.put(:remaining, tail)
  end

  defp pick_current_question(_) do
    :empty
  end

  defp inc_record(quiz, :correct) do
    new_record = Map.update(quiz.record, :good, 1, &(&1 + 1))
    Map.put(quiz, :record, new_record)
  end

  defp inc_record(quiz, :incorrect) do
    new_record = Map.update(quiz.record, :bad, 1, &(&1 + 1))
    Map.put(quiz, :record, new_record)
  end

  defp save_response(quiz, %Response{correct: false} = response) do
    quiz
    |> Map.put(:last_response, response)
    |> Map.put(:incorrect, [response | quiz.incorrect])
  end

  defp save_response(quiz, %Response{correct: true} = response) do
    quiz
    |> Map.put(:last_response, response)
    |> Map.put(:correct, [response | quiz.correct])
  end

  defp clean_current_question(quiz) do
    quiz
    |> Map.put(:current_question, nil)
  end
end
