defmodule QuizServer.Core.Response do
  @moduledoc """
  Response provided by a user to a Question
  """
  @enforce_keys ~w[id template question]a
  defstruct ~w[template question id answer correct timestamp]a

  def new(question: question, id: id, answer: answer) do
    template = question.template

    %__MODULE__{
      id: id,
      question: question,
      template: template,
      answer: answer,
      correct: is_correct?(question, answer),
      timestamp: DateTime.utc_now()
    }
  end

  defp is_correct?(question, answer) do
    answer == question.solution
  end
end
