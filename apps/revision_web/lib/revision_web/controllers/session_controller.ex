defmodule RevisionWeb.SessionController do
  use RevisionWeb, :controller
  alias QuizServer.Boundary.QuizSession



  def new(conn, %{"number" => number}) do
    render(conn, "new.html", number: number)
  end

  def create(conn, %{"template" => template_name, "number" => number, "uid" => uid}) do
    inputs =
      with n = String.to_integer(number) do
        for i <- 1..10 do
          [left: n, right: i]
        end
      end
      |> Enum.shuffle

      QuizSession.take_quiz(template_name, inputs, uid)

      redirect(conn, to: "/session/#{template_name}/#{uid}/")
  end

  def show(conn, %{"template" => template_name, "uid" => uid}) do
    question =
    case QuizSession.next_question({template_name, uid}) do
      {:ok, question}  ->     render(conn, "show.html", template: template_name, uid: uid, asked: question.asked)

      {:finished, quiz} -> render(conn, "finished.html", record: quiz.record)

    end
  end

  def update(conn, %{"template" => template_name, "uid" => uid}) do
    answer = conn.params["answer"]
    case QuizSession.answer_question({template_name, uid}, answer) do
      {:error, :no_current_question} -> redirect(conn, to: "/")
      {:error, _} -> redirect(conn, to: "/")
      {:ok, response}  ->  render(conn, "update.html",
     uid: uid,
     template: template_name,
     asked: response.question.asked,
     solution: response.question.solution,
     correct?: response.correct?,
     response: response.response
    )
    end

  end
 end
