defimpl Inspect, for: QuizServer.Core.Response do
  alias QuizServer.Core.Response

  def inspect(%Response{question: nil}, _opts) do
    "#Response[empty]"
  end

  def inspect(response = %Response{}, _opts) do
    "%Response{question: \"#{response.question.asked}\", response: \"#{response.response}\", correct?: #{response.correct?}, timestamp: #{response.timestamp}"
  end
end
