defmodule EventSourcing.Command do
  defmacro __using__(_opts) do
    quote do
      import EventSourcing.Command
      import Ecto.Changeset

      Module.register_attribute(__MODULE__, :fields, accumulate: true)
    end
  end

  defmacro field(name, type, opts \\ []) do
    quote do
      Module.put_attribute(__MODULE__, :fields, {unquote(name), unquote(type), unquote(opts)})
    end
  end

  defmacro command(do: block) do
    quote do
      try do
        unquote(block)
      after
        :ok
      end

      @names Enum.map(@fields, &elem(&1, 0))
      @required_names Enum.filter(@fields, fn {_, _, opts} ->
                        Keyword.get(opts, :required, true)
                      end)
                      |> Enum.map(&elem(&1, 0))
      @types Enum.map(@fields, fn {name, type, _} -> {name, type} end) |> Enum.into(%{})
      @struct_definition [uuid: nil] ++
                           Enum.map(@fields, fn {name, _, opts} ->
                             {name, Keyword.get(opts, :default)}
                           end)
      @empty_data Enum.into(@struct_definition, %{})
      @schema {@empty_data, @types}

      @uuid_generator Application.get_env(:event_sourcing, :uuid_generator)

      defstruct @struct_definition

      def changeset do
        cast(%{})
      end

      def build(params) do
        params
        |> cast()
        |> Ecto.Changeset.put_change(:uuid, @uuid_generator.generate())
        |> Ecto.Changeset.validate_required(@required_names)
        |> validate()
        |> get_command()
      end

      def validate(changeset) do
        changeset
      end

      defp cast(params) do
        changeset = Ecto.Changeset.cast(@schema, params, @names)
        put_in(changeset.changes, Map.merge(@empty_data, changeset.changes))
      end

      defp get_command(changeset) do
        case Ecto.Changeset.apply_action(changeset, :insert) do
          {:ok, changes} -> {:ok, struct(__MODULE__, changes)}
          error -> error
        end
      end

      defoverridable validate: 1
    end
  end
end
