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

  def add_template(manager \\ __MODULE__, template_fields) do
    GenServer.call(manager, {:add_template, template_fields})
  end

  def lookup_template_by_name(manager \\ __MODULE__, template_name) do
    GenServer.call(manager, {:lookup_template_by_name, template_name})
  end

  @spec all(atom | pid | {atom, any} | {:via, atom, any}) :: list
  def all(manager \\ __MODULE__) do
    GenServer.call(manager, {:all_templates})
  end


  def remove_template(manager \\ __MODULE__, template_fields) do
    GenServer.call(manager, {:remove_template, template_fields})
  end


  def handle_call({:add_template, %Template{} = template}, _from, templates) do
    new_templates = Map.put(templates, template.name, template)
    {:reply, :ok, new_templates}
  end

  def handle_call({:add_template, template_fields}, _from, templates)
      when is_list(template_fields) do
    template = Template.new(template_fields)
    new_templates = Map.put(templates, template.name, template)
    {:reply, :ok, new_templates}
  end

  def handle_call({:lookup_template_by_name, template_name}, _from, templates) do
    if templates[template_name] do
      {:reply, {:ok, templates[template_name]}, templates}
    else
      {:reply, {:error, :template_not_found}, templates}
    end
  end

  def handle_call({:all_templates}, _from, templates) do
    template_list = templates |> Enum.map(fn {k, _v} -> k end)
    {:reply, template_list, templates}
  end

  def handle_call({:remove_template, %Template{} = template}, _from, templates) do
    template_list = Map.delete(templates, template.name)
    {:reply, :ok, template_list}
  end

  def handle_call({:remove_template, name}, _from, templates) when is_binary(name) do
    template_list = Map.delete(templates, name)
    {:reply, :ok, template_list}
  end
end
