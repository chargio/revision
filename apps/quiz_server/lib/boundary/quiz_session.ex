defmodule QuizServer.Boundary.QuizSession do
  @moduledoc """
  Creates an easy interface to call the Session as a service
  """
  alias QuizServer.Core.{Template, Quiz, Response}
  alias QuizServer.Boundary.{TemplateManager, QuizManager}

  use GenServer

  def child_spec({%Template{} = template, inputs, uid}) do
    quiz = Quiz.new(template: template, inputs: inputs)
    child_spec({quiz, uid})
  end

  def child_spec({%Quiz{} = quiz, uid}) do
    template = quiz.template

    %{
      id: {__MODULE__, via({template.name, uid})},
      start: {__MODULE__, :start_link, [{quiz, uid}]},
      restart: :temporary
    }
  end

  def start_link({quiz, uid}) do
    template = quiz.template

    GenServer.start_link(
      __MODULE__,
      {quiz, uid},
      name: via({template.name, uid})
    )
  end

  def take_quiz(template_name, inputs, uid) when is_list(inputs) do
    with {:ok, template} <- TemplateManager.lookup_template_by_name(template_name),
         {:ok, quiz} <- QuizManager.build_quiz(template: template, inputs: inputs) do
      take_quiz(quiz, uid)
    else
      nil -> {:error, :template_not_found}
    end
  end

  def take_quiz(%Quiz{} = quiz, uid) do
    template = quiz.template

    DynamicSupervisor.start_child(
      QuizServer.Supervisor.QuizSession,
      {__MODULE__, {quiz, uid}}
    )

    {template.name, uid}
  end

  @impl true
  def init({template_name, uid}) do
    {:ok, {template_name, uid}}
  end

  def lookup_quiz_by_session(manager \\ __MODULE__, {template_name, uid}) do
    GenServer.call(manager, :lookup_quiz_by_title, {template_name, uid})
  end

  def next_question(name) do
    GenServer.call(via(name), :next_question)
  end

  def answer_question(name, answer) do
    GenServer.call(via(name), {:answer_question, answer})
  end

  @impl true
  def handle_call({:lookup_quiz_by_session, quiz, uid}, _from, sessions) do
    {:reply, sessions[{quiz, uid}], sessions}
  end

  @impl true
  def handle_call(:next_question, _from, {quiz, user_id}) do
    case Quiz.next_question(quiz) do
      {:ok, new_quiz} -> {:reply, new_quiz.current_question, {new_quiz, user_id}}
      {:finished, quiz} -> {:reply, :finished, {quiz, user_id}}
    end
  end

  @impl true
  def handle_call({:answer_question, response}, _from, {quiz, user_id}) do
    new_quiz =
      Quiz.answer_question(
        quiz.current_question,
        Response.new(question: quiz.current_question, response: response)
      )

    maybe_finish(new_quiz, user_id)
  end

  defp maybe_finish(%{remaining: []} = _quiz, _id), do: {:stop, :normal, :finished, nil}

  defp maybe_finish(quiz, user_id) do
    {:reply, {quiz.last_response.response, quiz.last_response.correct?}, {quiz, user_id}}
  end

  def via({_title, _uid} = name) do
    {
      :via,
      Registry,
      {QuizServer.Registry.QuizSession, name}
    }
  end
end
