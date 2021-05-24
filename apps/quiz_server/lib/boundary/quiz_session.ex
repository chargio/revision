defmodule QuizServer.Boundary.QuizSession do
  @moduledoc """
  Creates an easy interface to call the Session as a service
  """
  alias QuizServer.Core.{Quiz, Response}
  alias QuizServer.Boundary.QuizManager

  use GenServer

  def init({quiz_name, user_id}) do
    quiz = QuizManager.lookup_quiz_by_title(quiz_name)
    {:ok, {quiz, user_id}}
  end

  def next_question(session) do
    GenServer.call(session, :next_question)
  end

  def answer_question(session, answer) do
    GenServer.call(session, {:answer_question, answer})
  end

  def handle_call(:next_question, _from, {quiz, user_id}) do
    quiz = Quiz.next_question(quiz)
    {:reply, quiz.current_question, {quiz, user_id}}
  end

  def handle_call({:answer_question, answer}, _from, {quiz, user_id}) do
    quiz
    |> Quiz.answer_current_question(Response.new(question: quiz.current_question, id: user_id, answer: answer))
    |> Quiz.next_question()
    |> maybe_finish(user_id)
  end

  defp maybe_finish(nil, _id), do: {:stop, :normal, :finished, nil}

  defp maybe_finish(quiz, user_id) do
    {:reply, {quiz.current_question.asked, quiz.last_response.correct}, {quiz, user_id}}
  end
end
