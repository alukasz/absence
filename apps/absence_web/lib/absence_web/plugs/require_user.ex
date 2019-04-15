defmodule AbsenceWeb.RequireUser do
  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias AbsenceWeb.Router.Helpers

  def init(opts), do: opts

  def call(conn = %{assigns: %{current_user: user}}, _opts) when not is_nil(user), do: conn

  def call(conn, _opts) do
    conn
    |> put_flash(:error, "You must be authenticated to access this page")
    |> redirect(to: Helpers.session_path(conn, :new))
    |> halt()
  end
end
