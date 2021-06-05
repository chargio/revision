defimpl Inspect, for: QuizServer.Core.Question do
  alias QuizServer.Core.Question

  @doc ~S"""

  ###  Examples
    iex> inspect %QuizServer.Core.Question{template: nil, parameters: nil}
    #Question[empty]

  """
  def inspect(%Question{template: nil}, _opts) do
    "#Question[empty]"
  end

  def inspect(%Question{} = question, _opts) do
    """
    #Question{\
    asked: \"#{question.asked}\", \
    parameters: #{inspect(question.parameters)}, \
    solution: \"#{question.solution}\"\
    }\
    """
  end
end
