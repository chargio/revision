# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Revision.Repo.insert!(%Revision.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias QuizServer.Examples.Multiplication
alias QuizServer.Boundary.TemplateManager


TemplateManager.add_template(Multiplication.build_template())
