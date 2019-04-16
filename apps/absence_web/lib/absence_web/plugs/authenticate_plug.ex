defmodule AbsenceWeb.AuthenticatePlug do
  import Plug.Conn, only: [get_session: 2, assign: 3]

  alias AbsenceWeb.Authenticator

  @accounts Application.get_env(:absence_web, :accounts)

  def init(opts), do: opts

  def call(conn = %{assigns: %{current_user: user}}, _opts) when not is_nil(user), do: conn

  def call(conn, _opts) do
    user =
      conn
      |> get_session(:user_id)
      |> decode_token()
      |> get_user()

    assign(conn, :current_user, user)
  end

  defp decode_token(nil), do: nil

  defp decode_token(token) do
    Authenticator.decrypt(token)
  end

  defp get_user({:ok, user_id}) do
    @accounts.get_user(user_id)
  end

  defp get_user(_), do: nil
end
