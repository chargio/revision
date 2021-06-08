defimpl Inspect, for: QuizServer.Core.Quiz do
  alias QuizServer.Core.Quiz
  alias QuizServer.Core.Template

  defp template_or_nil(data) when is_map(data) do
    case Map.get(data, :template, %{})  do
      %Template{} = template -> Map.get(template, :name)
      _ -> "#\{BAD TEMPLATE\}"
    end
  end

  defp template_or_nil(data) do
    inspect(data)
  end

  def inspect(%Quiz{template: nil}, _opts) do
    "#Quiz[empty]"
  end

  def inspect(%Quiz{} = quiz, _opts) do
    """
    #Quiz{\
    template: \"#{template_or_nil(quiz)}\", \
    current_question: #{quiz.current_question}, \
    last_response: #{quiz.last_response}, \
    remaining: #{inspect(quiz.remaining)}, \
    inputs: #{inspect(quiz.inputs)}, \
    questions: #{inspect(quiz.questions)}, \
    incorrect: #{inspect(quiz.incorrect)}, \
    correct: #{inspect(quiz.correct)}, \
    record: #{inspect(quiz.record)} \
    }\
    """
  end
end
