defmodule QuizServer.Boundary.QuizSession do
  @moduledoc """
  Creates an easy interface to call the Session as a service
  """
  alias QuizServer.Core.Quiz
  alias QuizServer.Boundary.{TemplateManager, QuizManager}

  use GenServer

  def start_link({quiz, uid}) do
    template = quiz.template

    GenServer.start_link(
      __MODULE__,
      {quiz, uid},
      name: via({template.name, uid})
    )
  end

  @impl true
  def init({quiz, uid}) do
    {:ok, {quiz, uid}}
  end

  def child_spec({%Quiz{} = quiz, uid}) do
    # Get the template (should be a valid quiz)
    template = quiz.template

    %{
      id: {__MODULE__, via({template.name, uid})}, # Use via to be multi-process
      start: {__MODULE__, :start_link, [{quiz, uid}]},
      restart: :temporary
    }
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
    case DynamicSupervisor.start_child(
      QuizServer.Supervisor.QuizSession,
      {__MODULE__, {quiz, uid}}
    )
    do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
      {:error, error} -> error
    end

  end


  def next_question({_template_name, _uid} = name) do
    GenServer.call(via(name), :next_question)
  end

  def answer_question(name, answer) do
    GenServer.call(via(name), {:answer_question, answer})
  end

  @impl true
  def handle_call(:next_question, _from, {quiz, uid}) do
    case QuizServer.Boundary.QuizManager.next_question(quiz) do
      {:ok, new_quiz} -> {:reply, {:ok, new_quiz.current_question}, {new_quiz, uid}}
      {:finished, quiz} -> {:reply, {:finished, quiz}, {quiz, uid}}
    end
  end

  @impl true
  def handle_call({:answer_question, response}, _from, {quiz, user_id}) do
    QuizManager.answer_question(quiz, response)
    |> maybe_finish(user_id)
  end

  defp maybe_finish({:finished, _quiz}, uid), do: {:stop, :normal, {:ok, :finished}, {:finished, uid}}

  defp maybe_finish({:ok, quiz}, uid) do
    {:reply, {:ok, quiz.last_response}, {quiz, uid}}
  end

  defp maybe_finish({:no_current_question, quiz}, uid) do
    {:reply, {:error, :no_current_question}, {quiz, uid}}
  end

  def via({_title, _uid} = name) do
    {
      :via,
      Registry,
      {QuizServer.Registry.QuizSession, name}
    }
  end
end
