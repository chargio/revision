defimpl Inspect, for: QuizServer.Core.Question do
  alias Revision.Inquiries.Question

  def inspect(%Question{template: nil}, _opts) do
    "#Question[empty]"
  end

  def inspect(question = %Question{}, _opts) do
    "%Question{asked: \"#{question.asked}\", template: \"#{question.template.name}\", parameters: #{inspect(question.parameters)}, solution: \"#{question.solution}\"}"
  end
end
