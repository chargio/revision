defmodule QuizServer.Boundary.QuizManager do
  @moduledoc """
  QuizManager allows you to create new QuizManagers with the proper information.
  It checks using validators that the inputs are correct.
  """
  alias QuizServer.Core.Quiz
  alias QuizServer.Boundary.QuizValidator

  @spec build_quiz(list) :: {:ok, %QuizServer.Core.Quiz{}} | {:error, list}
  def build_quiz(fields) do
    with [] <- QuizValidator.errors(fields),
         quiz <- Quiz.new(fields) do
      {:ok, quiz}
    else
      errors -> {:error, errors}
    end
  end

  @spec next_question(%QuizServer.Core.Quiz{}) ::
          {:finished, %QuizServer.Core.Quiz{}} | {:ok, %QuizServer.Core.Quiz{}}
  def next_question(%Quiz{} = quiz) do
    case Quiz.next_question(quiz) do
      :no_more_questions -> {:finished, quiz}
      quiz -> {:ok, quiz}
    end
  end

  @spec answer_question(%QuizServer.Core.Quiz{}, any) ::
          {:finished, %QuizServer.Core.Quiz{}}
          | {:no_current_question, %QuizServer.Core.Quiz{}}
          | {:ok, %QuizServer.Core.Quiz{}}
  def answer_question(%Quiz{} = quiz, response) do
    case Quiz.answer_question(quiz, response) do
      :finished -> {:finished, quiz}
      :no_current_question -> {:no_current_question, quiz}
      new_quiz -> {:ok, new_quiz}
    end
  end

  @spec reset_quiz(%QuizServer.Core.Quiz{}) :: {:ok, %QuizServer.Core.Quiz{}}
  def reset_quiz(%Quiz{} = quiz) do
    {:ok, Quiz.reset_quiz(quiz)}
  end
end
