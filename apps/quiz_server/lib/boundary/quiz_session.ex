defmodule QuizServer.Boundary.QuizSession do
  @moduledoc """
  Creates an easy interface to call the Session as a service
  """
  alias QuizServer.Core.{Quiz, Response}

  use GenServer

  def child_spec({%Quiz{} = quiz, uid}) do
    %{
      id: {__MODULE__, {quiz.title, uid}},
      start: {__MODULE__, :start_link, [{quiz, uid}]},
      restart: :temporary
    }
  end

  def start_link({%Quiz{} = quiz, uid}) do
    GenServer.start_link(
      __MODULE__,
      {quiz, uid},
      name: via({quiz.title, uid})
    )
  end

  def take_quiz(%Quiz{} = quiz, uid) do
    DynamicSupervisor.start_child(
      QuizServer.Supervisor.QuizSession,
      {__MODULE__, {quiz, uid}}
    )
  end

  @impl true
  def init({quiz_title, user_id}) do
    {:ok, {quiz_title, user_id}}
  end

  def next_question(name) do
    GenServer.call(via(name), :next_question)
  end

  def answer_question(name, answer) do
    GenServer.call(via(name), {:answer_question, answer})
  end

  @impl true
  def handle_call(:next_question, _from, {quiz, user_id}) do
    quiz = Quiz.next_question(quiz)
    {:reply, quiz.current_question, {quiz, user_id}}
  end

  @impl true
  def handle_call({:answer_question, answer}, _from, {quiz, user_id}) do
    quiz
    |> Quiz.answer_current_question(
      Response.new(question: quiz.current_question, id: user_id, answer: answer)
    )
    |> Quiz.next_question()
    |> maybe_finish(user_id)
  end

  defp maybe_finish(nil, _id), do: {:stop, :normal, :finished, nil}

  defp maybe_finish(quiz, user_id) do
    {:reply, {quiz.current_question.asked, quiz.last_response.correct}, {quiz, user_id}}
  end

  def via({_title, _uid} = name) do
    {
      :via,
      Registry,
      {QuizServer.Registry.QuizSession, name}
    }
  end
end
