defmodule QuizServerTest do
  use ExUnit.Case
  doctest QuizServer

  test "greets the world" do
    assert QuizServer.hello() == :world
  end
end
