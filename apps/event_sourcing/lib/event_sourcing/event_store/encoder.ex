defmodule EventSourcing.EventStore.Encoder do
  @struct_key :struct
  @atom_prefix "__atom__"

  def encode(%struct{} = data) do
    data
    |> Map.from_struct()
    |> Map.put(@struct_key, Atom.to_string(struct))
    |> encode()
  end

  def encode(%{} = data) do
    Map.new(data, fn
      {key, %{} = value} -> {key, encode(value)}
      {key, value} when is_atom(value) -> {key, @atom_prefix <> Atom.to_string(value)}
      {key, value} -> {key, value}
    end)
  end

  def decode(%{} = data) do
    data =
      Map.new(data, fn
        {key, %{} = value} -> {decode_key(key), decode(value)}
        {key, @atom_prefix <> atom} -> {decode_key(key), String.to_existing_atom(atom)}
        {key, value} -> {decode_key(key), value}
      end)

    case Map.has_key?(data, @struct_key) do
      true -> struct(String.to_existing_atom(data.struct), data)
      false -> data
    end
  end

  def decode_key(key) when is_atom(key), do: key
  def decode_key(key), do: String.to_existing_atom(key)

  def decode_value(value), do: value
end
