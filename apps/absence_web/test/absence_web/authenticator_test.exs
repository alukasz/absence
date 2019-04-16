defmodule AbsenceWeb.AuthenticatorTest do
  use ExUnit.Case, async: true

  alias AbsenceWeb.Authenticator

  @data "very important message"

  test "encrypts and decrypts data" do
    token = Authenticator.encrypt(@data)

    refute @data == token

    assert Authenticator.decrypt(token) == {:ok, @data}
  end

  test "returns error tuple when decrypting invalid token" do
    assert {:error, _} = Authenticator.decrypt(@data)
  end
end
