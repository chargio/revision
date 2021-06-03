# QuizServer

A Server that creates a Quiz with some questions and follows the user while they provide full answers to it, until he understands it properly.

The interface is double: there is a list of Templates that can be used to create a QuizSession, and the way to advance in the session is to answer questions that are part of a Quiz. The Quiz is a token that uses a Template with a list of inputs to generate the questions to be asked.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `quiz_server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:quiz_server, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/quiz_server](https://hexdocs.pm/quiz_server).

