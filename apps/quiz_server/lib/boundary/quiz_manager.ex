defmodule QuizServer.Boundary.QuizManager do
  alias QuizServer.Core.Quiz

  @spec build_quiz(list) :: {:ok, %QuizServer.Core.Quiz{}} | {:error, list}
  def build_quiz(fields) do
    quiz = Quiz.new(fields)
    if quiz, do: {:ok, quiz}, else: {:error, fields}
  end

  @spec next_question(%QuizServer.Core.Quiz{}) ::
          {:finished, %QuizServer.Core.Quiz{}} | {:ok, %QuizServer.Core.Quiz{}}
  def next_question(%Quiz{} = quiz) do
    case Quiz.next_question(quiz) do
      :finished -> {:finished, quiz}
      quiz -> {:ok, quiz}
    end
  end

  def answer_question(%Quiz{} = quiz, response) do
    case Quiz.answer_question(quiz, response) do
      :finished -> {:finished, quiz}
      :no_current_question -> {:no_current_question, quiz}
      quiz -> {:ok, quiz}
    end
  end

  def reset_quiz(%Quiz{} = quiz) do
    {:ok, Quiz.reset_quiz(quiz)}
  end
end
