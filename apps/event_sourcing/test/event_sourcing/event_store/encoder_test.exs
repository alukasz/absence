defmodule EventSourcing.EventStore.EncoderTest do
  use ExUnit.Case, async: true

  alias EventSourcing.EventStore.Encoder

  defmodule Data do
    defstruct [:foo]
  end

  describe "encode/1" do
    test "changes struct to map with :struct field" do
      assert Encoder.encode(%Data{foo: "bar"}) == %{foo: "bar", struct: Atom.to_string(Data)}
    end

    test "recursively changes structs" do
      assert %{struct: _, foo: %{struct: _, foo: %{struct: _, foo: _}}} =
               Encoder.encode(%Data{foo: %Data{foo: %Data{}}})
    end
  end

  describe "decode/1" do
    test "changes map with :struct field to struct" do
      assert Encoder.decode(%{foo: "bar", struct: Atom.to_string(Data)}) == %Data{foo: "bar"}
    end

    test "changes string map with :struct field to struct" do
      assert Encoder.decode(%{"foo" => :bar, "struct" => Atom.to_string(Data)}) == %Data{
               foo: :bar
             }
    end

    test "recursibely changes maps" do
      struct = Atom.to_string(Data)

      assert %Data{foo: %Data{foo: %Data{}}} =
               Encoder.decode(%{struct: struct, foo: %{struct: struct, foo: %{struct: struct}}})
    end
  end

  describe "encoding and decoding" do
    test "decodes dates" do
      data = %Data{foo: Date.utc_today()}

      assert encode_decode(data) == data
    end

    test "decodes datetimes" do
      data = %Data{foo: DateTime.now("Utc")}

      assert encode_decode(data) == data
    end

    test "decodes atoms" do
      data = %Data{foo: "bar"}

      assert encode_decode(data) == data
    end
  end

  defp encode_decode(data) do
    data
    |> Encoder.encode()
    |> Encoder.decode()
  end
end
