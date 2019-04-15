defmodule AbsenceWeb.AuthenticatePlug do
  import Plug.Conn, only: [get_session: 2, assign: 3]

  @accounts Application.get_env(:absence_web, :accounts)
  @token_max_age 60 * 60 * 24

  def init(opts), do: opts

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
    case Phoenix.Token.verify(AbsenceWeb.Endpoint, "session", token, max_age: @token_max_age) do
      {:ok, user_id} -> user_id
      _ -> nil
    end
  end

  defp get_user(nil), do: nil
  defp get_user(user_id) do
    @accounts.get_user(user_id)
  end
end
