defmodule EventSourcing.Aggregate do
  @type struct_with_uuid :: %{
          :__struct__ => module,
          :uuid => Ecto.UUID.t(),
          optional(atom) => any
        }
  @type aggregate :: struct_with_uuid
  @type event :: struct_with_uuid
  @type command :: struct_with_uuid

  @callback execute(aggregate, command) :: event

  @callback apply(aggregate, event) :: aggregate
end
