defmodule QuizServer.Core.Response do
  @moduledoc """
  Response provided by a user to a Question
  """
  @enforce_keys ~w[quiz_title template question id answer]a
  defstruct ~w[quiz_title template question id answer correct timestamp]a

  def new(quiz, id, answer) do
    question = quiz.current_question
    template = quiz.template

    %__MODULE__{
      id: id,
      quiz_title: quiz.title,
      question: question,
      template: template,
      answer: answer,
      correct: template.checker.(question.parameters, answer),
      timestamp: DateTime.utc_now()
    }
  end
end
