defmodule QuizServer.Core.Quiz do
  @moduledoc """
  A quiz, consisting on a list of Questions to be answered, from a Template, that covers a list of inputs
  """

  alias QuizServer.Core.{Question, Response}

  @enforce_keys ~w[title template inputs]a
  defstruct title: nil,
            template: nil,
            remaining: [],
            current_question: nil,
            last_response: nil,
            inputs: [],
            questions: [],
            incorrect: [],
            correct: [],
            record: %{good: 0, bad: 0}

  @doc """
  Creates a new Quiz populating the data with the fields required
  """

  def new(fields) do
    struct!(__MODULE__, fields)
    |> populate_questions()
  end

  @spec next_question(map) :: {:ok, map} | {:finished, map}
  @doc """
  Select the next question to be answered in the quiz
  """
  def next_question(%__MODULE__{current_question: nil, remaining: []} = quiz) do
    {:finished, quiz}
  end

  def next_question(%__MODULE__{current_question: nil, remaining: [head | tail]} = quiz) do
    {:ok, Map.merge(quiz, %{current_question: head, remaining: tail})}
  end

  def next_question(quiz) do
    {:ok, quiz}
  end

  @doc """
  Answer the current question with a string or an Answer
  """
  def answer_question(%__MODULE__{current_question: nil} = quiz, _response),
    do: {:no_current_question, quiz}

  def answer_question(%__MODULE__{current_question: question} = quiz, response)
      when is_binary(response) do
    response = Response.new(question: question, response: response)
    answer_current_question(quiz, response)
  end

  def answer_question(%__MODULE__{} = quiz, %Response{} = response) do
    answer_current_question(quiz, response)
  end

  @doc """
  Resets the quiz to its original form.
  """
  def reset_quiz(%__MODULE__{
        questions: questions,
        title: title,
        inputs: inputs,
        template: template
      }) do
    struct!(__MODULE__,
      questions: questions,
      remaining: questions,
      title: title,
      inputs: inputs,
      template: template
    )
  end

  # Populates the questions with the input generator and the template.
  defp populate_questions(%__MODULE__{template: template, inputs: inputs} = quiz) do
    questions =
      inputs
      |> Enum.map(&Question.new(template, &1))

    quiz
    |> Map.merge(%{questions: questions, remaining: questions})
  end

  # Provides an answer to the current question, save it as the last response, and increases the counts
  # of good and bad answers, then reset current question.

  defp answer_current_question(%__MODULE__{current_question: nil} = quiz, _response),
    do: {:no_current_question, quiz}

  defp answer_current_question(
         %__MODULE__{current_question: question} = quiz,
         %Response{correct?: true, question: question} = response
       ) do
    quiz
    |> save_response(response)
    |> inc_record(:correct)
    |> clean_current_question()
  end

  defp answer_current_question(
         %__MODULE__{current_question: question} = quiz,
         %Response{correct?: false, question: question} = response
       ) do
    quiz
    |> save_response(response)
    |> inc_record(:incorrect)
    |> clean_current_question()
  end

  defp inc_record(quiz, :correct) do
    new_record = Map.update(quiz.record, :good, 1, &(&1 + 1))
    Map.put(quiz, :record, new_record)
  end

  defp inc_record(quiz, :incorrect) do
    new_record = Map.update(quiz.record, :bad, 1, &(&1 + 1))
    Map.put(quiz, :record, new_record)
  end

  defp save_response(quiz, %Response{correct?: false} = response) do
    quiz
    |> Map.put(:last_response, response)
    |> Map.put(:incorrect, [response | quiz.incorrect])
  end

  defp save_response(quiz, %Response{correct?: true} = response) do
    quiz
    |> Map.put(:last_response, response)
    |> Map.put(:correct, [response | quiz.correct])
  end

  defp clean_current_question(quiz) do
    quiz
    |> Map.put(:current_question, nil)
  end
end
