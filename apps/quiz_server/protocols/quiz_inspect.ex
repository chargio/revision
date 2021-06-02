defimpl Inspect, for: QuizServer.Core.Quiz do
  alias Revision.Inquiries.Quiz

  def inspect(%Quiz{template: nil}, _opts) do
    "#Quiz[empty]"
  end

  def inspect(quiz = %Quiz{}, _opts) do
    "%Quiz{title: \"#{quiz.title}\", \
    template: \"#{quiz.template.name}\", \
    current_question: #{inspect(quiz.current_question)}, \
    last_response: #{inspect(quiz.last_response)}, \
    remaining: #{inspect(quiz.remaining)}, \
    inputs: #{inspect(quiz.inputs)}, \
    questions: #{inspect(quiz.questions)}, \
    incorrect: #{inspect(quiz.incorrect)}, \
    correct: #{inspect(quiz.correct)}, \
    record: #{inspect(quiz.record)},"
  end
end
