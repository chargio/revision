defmodule QuizServer.Boundary.TemplateManagerTest do
  use ExUnit.Case
  alias QuizServer.Boundary.TemplateManager
  alias QuizServer.Core.Template
  alias QuizServer.Examples.Multiplication

  def create_transient_template_manager(context) do
    template_manager = start_supervised!(TemplateManager, [])
    template_fields = Multiplication.template_fields()

    new_context =
      Map.merge(context, %{template_manager: template_manager, template_fields: template_fields})

    {:ok, new_context}
  end

  def additional_template_fields() do
    Multiplication.template_fields(name: "other name")
  end

  def updated_template_fields() do
    Multiplication.template_fields(instructions: "new instructions")
  end

  test "There is a working TemplateManager in the system" do
    assert QuizServer.Boundary.TemplateManager in Process.registered()
    assert is_list(TemplateManager.all())

    assert {:error, :template_not_found} =
             TemplateManager.lookup_template_by_name("I am never going to find this")

    fields_unlikely = Multiplication.template_fields(name: "very unlikely name for a Template")

    assert :ok == TemplateManager.add_template(fields_unlikely)
    assert {:ok, _} = TemplateManager.lookup_template_by_name(fields_unlikely[:name])
    assert :ok == TemplateManager.remove_template(fields_unlikely[:name])
    assert {:error, :template_not_found} = TemplateManager.lookup_template_by_name(fields_unlikely[:name])
  end

  describe "parallel with unique TemplateManager" do
    setup [:create_transient_template_manager]

    test "There is a transient template manager", %{template_manager: tm} do
      assert Process.alive?(tm)
    end

    test "you can add a template to a server", %{template_manager: tm, template_fields: tf} do
      assert :ok == TemplateManager.add_template(tm, tf)
    end

    test "you can get a template by name when it has been added", %{
      template_manager: tm,
      template_fields: tf
    } do
      assert :ok == TemplateManager.add_template(tm, tf)
      assert {:ok, %Template{}} = TemplateManager.lookup_template_by_name(tm, tf[:name])
    end

    test "you get an error if the template is not there", %{template_manager: tm} do
      assert {:error, :template_not_found} =
               TemplateManager.lookup_template_by_name(tm, "bad name")
    end

    test "you can add two templates and get both with all", %{
      template_manager: tm,
      template_fields: tf
    } do
      assert :ok == TemplateManager.add_template(tm, tf)
      new_fields = additional_template_fields()
      assert :ok == TemplateManager.add_template(tm, new_fields)
      assert TemplateManager.all(tm) == ["Multiplication", "other name"]
    end

    test "you can add a Template directly", %{template_manager: tm, template_fields: tf} do
      template = Template.new(tf)
      assert :ok == TemplateManager.add_template(tm, template)
    end

    test "adding a template with a name and updated fields updates the template", %{template_manager: tm, template_fields: tf} do
      ins1 = Keyword.get(tf, :instructions)
      name = Keyword.get(tf, :name)

      assert :ok == TemplateManager.add_template(tm, tf)
      assert {:ok, %Template{instructions: ^ins1}} = TemplateManager.lookup_template_by_name(tm, name)

      tf2 = updated_template_fields()
      ins2 = Keyword.get(tf2, :instructions)

      assert ins1 != ins2
      assert :ok == TemplateManager.add_template(tm, tf2)
      assert {:ok, %Template{instructions: ^ins2}} = TemplateManager.lookup_template_by_name(tm, name)
    end

    test "you can delete a Template directly", %{template_manager: tm, template_fields: tf}do
      template = Template.new(tf)
      assert :ok == TemplateManager.add_template(tm, template)
      assert {:ok, _} = TemplateManager.lookup_template_by_name(tm, tf[:name])
      assert :ok == TemplateManager.remove_template(tm, template)
      assert {:error, :template_not_found} = TemplateManager.lookup_template_by_name(tm, tf[:name])
    end

    test "you can delete a Template by name", %{template_manager: tm, template_fields: tf} do
      assert :ok == TemplateManager.add_template(tm, tf)
      assert {:ok, _} = TemplateManager.lookup_template_by_name(tm, tf[:name])
      assert :ok == TemplateManager.remove_template(tm, tf[:name])
      assert {:error, :template_not_found} = TemplateManager.lookup_template_by_name(tm, tf[:name])
    end
  end
end
