defmodule EventSourcing.CommandTest do
  use ExUnit.Case, async: true

  defmodule ExampleCommand do
    use EventSourcing.Command

    command do
      field :foo, :integer
      field :bar, :string
      field :baz, :date
    end
  end

  describe "defining command" do
    test "struct has all defined fields" do
      assert %{foo: _, bar: _, baz: _} = %ExampleCommand{}
    end

    test "struct has uuid field" do
      assert %{uuid: _} = %ExampleCommand{}
    end

    test "generates changeset/0 function" do
      assert function_exported?(ExampleCommand, :changeset, 0)
    end

    test "generates build/1 function" do
      assert function_exported?(ExampleCommand, :build, 1)
    end
  end

  describe "changeset/0" do
    test "returns changeset for command" do
      assert %Ecto.Changeset{} = ExampleCommand.changeset()
    end
  end

  describe "build/1" do
    defmodule FancyCommand do
      use EventSourcing.Command

      command do
        field :default, :integer, default: 42
        field :optional, :integer, required: false
        field :required, :integer, required: true
      end
    end

    test "with valid params build command" do
      assert {:ok, %FancyCommand{default: 1, optional: 2, required: 3}} =
               FancyCommand.build(%{default: 1, optional: 2, required: 3})
    end

    test "with invalid params return changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} = FancyCommand.build(%{})
    end

    test "sets :action on changeset" do
      assert {:error, %Ecto.Changeset{action: :insert} = changeset} = FancyCommand.build(%{})
    end

    test "required fields" do
      assert {:error, changeset} = FancyCommand.build(%{})
      assert "can't be blank" in errors_on(changeset).required
    end

    test "optional fields" do
      assert {:error, changeset} = FancyCommand.build(%{})
      refute Map.has_key?(errors_on(changeset), :optional)
    end
  end

  describe "validate/1" do
    defmodule ValidateCommand do
      use EventSourcing.Command

      command do
        field :number, :integer
      end

      def validate(changeset) do
        validate_number(changeset, :number, equal_to: 42)
      end
    end

    test "defines custom validation" do
      assert {:error, changeset} = ValidateCommand.build(%{number: 12})

      assert "must be equal to 42" in errors_on(changeset).number
    end
  end

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
