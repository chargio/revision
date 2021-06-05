defmodule QuizServer do
  @moduledoc """
  Documentation for `QuizServer`.
  """

  alias QuizServer.Boundary.{QuizSession, TemplateManager, QuizManager}
  alias QuizServer.Boundary.{TemplateValidator, QuizValidator}
  alias QuizServer.Core.Quiz

  def list_templates() do
    TemplateManager.all()
  end

  def take_quiz(template_name, inputs, uid) do
    with {:ok, template} <- TemplateManager.lookup_template_by_name(template_name),
         {:ok, quiz} <- build_quiz(template: template, inputs: inputs) do
      QuizSession.take_quiz(quiz, uid)
    end
  end

  def next_question(session) do
    QuizSession.next_question(session)
  end

  def answer_question(session, answer) do
    QuizSession.answer_question(session, answer)
  end

  @doc """
  Builds a template and puts it in the TemplateManager for later access, after validating it properly
  """
  def build_template(fields) when is_list(fields) do
    with false <- TemplateValidator.has_errors?(fields),
         :ok <- TemplateManager.build_template(TemplateManager, fields) do
      :ok
    else
      {true, errors} -> errors
      _ -> {:error, "Error building template"}
    end
  end

  # Builds a quiz, using a predefined template and inputs
  defp build_quiz(fields) when is_list(fields) do
    with false <- QuizValidator.has_errors?(fields),
         {:ok, quiz} <- QuizManager.build_quiz(fields) do
      {:ok, quiz}
    else
      error -> {:error, error}
    end
  end

  defp build_quiz(%Quiz{} = quiz) do
    {:ok, quiz}
  end
end
