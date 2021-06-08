defimpl Inspect, for: QuizServer.Core.Response do
  alias QuizServer.Core.{Response, Question}


  def inspect(%Response{question: nil}, _opts) do
    "#Response[empty]"
  end

  def inspect(%Response{} = response, _opts) do
    """
    #Response{\
    question: \"#{inspect(response.question)}\", \
    response: \"#{response.response}\", \
    correct?: #{response.correct?}, \
    timestamp: #{response.timestamp} \
    }\
    """
  end
end
