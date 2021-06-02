defmodule QuizServer.Core.Response do
  @moduledoc """
  An answer to a Question generated from a Template
  """

  @enforce_keys ~w[question response]a
  defstruct ~w[question response correct? timestamp]a

  alias QuizServer.Core.Question

  def new(question: %Question{} = question, response: response) when is_binary(response) do
    %__MODULE__{
      question: question,
      response: response,
      correct?: is_correct?(question, response),
      timestamp: DateTime.utc_now()
    }
  end

  defp is_correct?(question, response, strategy \\ :exact)

  # The current strategy is :exact, but giving room for other
  defp is_correct?(question, response, :exact) do
    response == question.solution
  end
end
