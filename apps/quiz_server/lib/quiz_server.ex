defmodule QuizServer do
  @moduledoc """
  Documentation for `QuizServer`.
  """

  alias QuizServer.Boundary.{QuizSession, QuizManager, TemplateManager}
  alias QuizServer.Boundary.{TemplateValidator, QuizValidator}
  alias QuizServer.Core.Quiz

  def take_quiz(title, uid) do
    with %Quiz{} = quiz <- QuizManager.lookup_quiz_by_title(title),
         {:ok, _} <- QuizSession.take_quiz(quiz, uid) do
      {title, uid}
    else
      error -> error
    end
  end

  @doc """
  Builds a template, after validating it properly
  """
  def build_template(fields) do
    with {false, nil} <- TemplateValidator.has_errors?(fields),
         :ok <- TemplateManager.build_template(TemplateManager, fields) do
      :ok
    else
      {true, errors} -> errors
      _ -> {:error, "Error building template"}
    end
  end

  def build_quiz(fields) do
    with false <- QuizValidator.has_errors?(fields),
         :ok <- QuizManager.build_quiz(QuizManager, fields) do
      :ok
    else
      error -> error
    end
  end
end
