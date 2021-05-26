defmodule QuizServer.Boundary.QuizManager do
  @moduledoc """
  Creates an easy interface to access a Manager as a Service
  """
  alias QuizServer.Core.Quiz
  alias QuizServer.Boundary.TemplateManager

  use GenServer

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, %{}, options)
  end

  def init(quizzes) when is_map(quizzes) do
    {:ok, quizzes}
  end

  def init(_quizzes), do: {:error, "quizzes must be a map"}

  def handle_call({:build_quiz, parameters}, _from, quizzes) do
    title = Keyword.fetch!(parameters, :title)
    template_name = Keyword.fetch!(parameters, :template_name)
    input_generator = Keyword.fetch!(parameters, :input_generator)
    template = TemplateManager.lookup_template_by_name(TemplateManager, template_name)

    quiz = Quiz.new(title: title, template: template, input_generator: input_generator)
    new_quizzes = Map.put(quizzes, quiz.title, quiz)
    {:reply, :ok, new_quizzes}
  end

  def handle_call({:lookup_quiz_by_title, quiz_title}, _from, quizzes) do
    {:reply, quizzes[quiz_title], quizzes}
  end

  def build_quiz(manager \\ __MODULE__, parameters) do
    GenServer.call(manager, {:build_quiz, parameters})
  end

  def lookup_quiz_by_title(manager \\ __MODULE__, quiz_title) do
    GenServer.call(manager, {:lookup_quiz_by_title, quiz_title})
  end
end
