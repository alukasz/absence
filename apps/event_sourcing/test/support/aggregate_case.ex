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

  defmacro assert_dispatched(command) do
    pins = collect_pins_from_pattern(command, Macro.Env.vars(__CALLER__))
    dispatched = quote do: EventSourcing.FakeDispatcher.commands_dispatched()

    do_assert_dispatched(command, pins, dispatched)
  end

  defmacro assert_dispatched(aggregate_mod, aggregate_uuid, command) do
    pattern = {:{}, [], [aggregate_mod, aggregate_uuid, command]}
    pins = collect_pins_from_pattern(pattern, Macro.Env.vars(__CALLER__))
    dispatched = quote do: EventSourcing.FakeDispatcher.dispatched()

    do_assert_dispatched(pattern, pins, dispatched)
  end

  def do_assert_dispatched(pattern, pins, dispatched) do
    formatted_pattern = Macro.to_string(pattern)

    quote do
      dispatched = unquote(dispatched)

      message =
        "No command matching " <>
          unquote(formatted_pattern) <>
          EventSourcing.AggregateCase.__pins__(unquote(pins)) <>
          "\nDispatched commands: " <>
          inspect(dispatched, pretty: true)

      assert Enum.any?(dispatched, fn dispatched ->
               match?(unquote(pattern), dispatched)
             end),
             message
    end
  end

  # from ExUnit.Assertions

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
