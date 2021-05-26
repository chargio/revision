defmodule QuizServer.Boundary.TemplateManager do
  @moduledoc """
  Templates Boundary, gives an easy access to the server holding the templates
  """
  alias QuizServer.Core.Template
  use GenServer

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, %{}, options)
  end

  def init(templates) when is_map(templates) do
    {:ok, templates}
  end

  def init(_) do
    {:error, "Templates should be a map"}
  end

  def build_template(manager \\ __MODULE__, template_fields) do
    GenServer.call(manager, {:build_template, template_fields})
  end

  def lookup_template_by_name(manager \\ __MODULE__, template_name) do
    GenServer.call(manager, {:lookup_template_by_name, template_name})
  end

  def handle_call({:build_template, template_fields}, _from, templates) do
    template = Template.new(template_fields)
    new_templates = Map.put(templates, template.name, template)
    {:reply, :ok, new_templates}
  end

  def handle_call({:lookup_template_by_name, template_name}, _from, templates) do
    {:reply, templates[template_name], templates}
  end
end
