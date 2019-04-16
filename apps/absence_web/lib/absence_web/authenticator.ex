defmodule AbsenceWeb.Authenticator do
  @token_ttl Application.get_env(:absence_web, :token_ttl)
  @salt "session"

  def encrypt(data) do
    Phoenix.Token.sign(AbsenceWeb.Endpoint, @salt, data, max_age: @token_ttl)
  end

  def decrypt(token) do
    Phoenix.Token.verify(AbsenceWeb.Endpoint, @salt, token, max_age: @token_ttl)
  end
end
