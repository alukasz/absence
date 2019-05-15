defmodule EventSourcing.AggregateCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import EventSourcing.DataCase, only: [errors_on: 1]
      import EventSourcing.AggregateCase
    end
  end

  setup do
    EventSourcing.EventStore.AgentEventStore.__reset__()
    start_supervised!({EventSourcing.FakeDispatcher, name: self()})

    :ok
  end

  defmacro assert_dispatched(pattern) do
    formatted_pattern = Macro.to_string(pattern)
    pins = collect_pins_from_pattern(pattern, Macro.Env.vars(__CALLER__))

    quote do
      dispatched_commands = EventSourcing.FakeDispatcher.commands_dispatched()

      message =
        "No command matching " <>
          unquote(formatted_pattern) <>
          EventSourcing.AggregateCase.__pins__(unquote(pins)) <>
          "\nDispatched commands: " <>
          inspect(dispatched_commands, pretty: true)

      assert Enum.any?(dispatched_commands, fn dispatched_command ->
               match?(unquote(pattern), dispatched_command)
             end),
             message
    end
  end

  # from ExUnit
  defp collect_pins_from_pattern(expr, vars) do
    {_, pins} =
      Macro.prewalk(expr, [], fn
        {:^, _, [{name, _, nil} = var]}, acc ->
          if {name, nil} in vars do
            {:ok, [{name, var} | acc]}
          else
            {:ok, acc}
          end

        form, acc ->
          {form, acc}
      end)

    Enum.uniq_by(pins, &elem(&1, 0))
  end

  @indent "\n  "

  def __pins__([]), do: ""

  def __pins__(pins) do
    content =
      pins
      |> Enum.reverse()
      |> Enum.map_join(@indent, fn {name, var} -> "#{name} = #{inspect(var)}" end)

    "\nThe following variables were pinned:" <> @indent <> content
  end
end
