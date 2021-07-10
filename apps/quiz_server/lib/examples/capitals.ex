defmodule QuizServer.Examples.EUCapitals do
    @moduledoc """
    A sample Template and Quiz that can be generated using functions to test the logic of the application.
    """
      
    alias QuizServer.Core.{Template, Quiz, Question}
      
    @european_countries_and_capitals_EN %{
        "Austria" => "Vienna",
        "Belgium" => "Brussels",
        "Bulgaria" => "Sofia",
        "Croatia" => "Zagreb",
        "Cyprus" => "Nicosia",
        "Czechia" => "Prague",
        "Denmark" => "Copenhagen",
        "Estonia" => "Tallin",
        "Finland" => "Helsinki",
        "France" => "Paris",
        "Germany" => "Berlin",
        "Greece" => "Athens",
        "Hungary" => "Budapest",
        "Ireland" => "Dublin",
        "Italy" => "Rome",
        "Latvia" => "Riga",
        "Lithuania" => "Vilnius",
        "Luxemburg" =>  "Luxembourg",
        "Malta" => "Valleta",
        "Netherlands" => "Amsterdam",
        "Poland" => "Warsaw",
        "Portugal" => "Lisbon",
        "Romania" => "Bucharest",
        "Slovakia" => "Bratislava",
        "Slovenia" => "Ljubljiana",
        "Spain" => "Madrid",
        "Sweden" => "Stockholm"
    }
      
        def raw_query() do
          "Capital of <%=@country%>"
        end
      
        def raw_solver() do
          "<%=@capital%>"
        end
      
        def template_fields(overrides \\ []) do
          Keyword.merge(
            [
              name: "Capitals of EU",
              instructions: "Write down the capital of the country",
              raw_query: raw_query(),
              raw_solver: raw_solver()
            ],
            overrides
          )
        end
      
        def build_template(overrides \\ []) do
          overrides
          |> template_fields()
          |> Template.new()
        end
      
        def quiz_fields(overrides \\ []) do
          Keyword.merge(
            [inputs: country_inputs(7), template: build_template()],
            overrides
          )
        end
      
        def question_fields(overrides \\ []) do
          Keyword.merge(
            [
              template: build_template(),
              parameters: [country: "Spain", capital: "Madrid"]
            ],
            overrides
          )
        end
      
        def build_question() do
          fields = question_fields()
      
          template = Keyword.get(fields, :template, nil)
          parameters = Keyword.get(fields, :parameters, nil)
      
          Question.new(template, parameters)
        end
      
        def build_quiz(overrides \\ []) do
          overrides
          |> quiz_fields()
          |> Quiz.new()
        end
      
        defp country_inputs(countries)  do
          for i <- Map.keys(@european_countries_and_capitals_EN), do: [country: i, capital: @european_countries_and_capitals_EN[i]]
        end
      end
      