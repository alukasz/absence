defmodule AbsenceWeb.RequireGuest do
  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias AbsenceWeb.Router.Helpers

  def init(opts), do: opts

  def call(conn = %{assigns: %{current_user: user}}, _opts) when not is_nil(user) do
    conn
    |> put_flash(:info, "You are already authenticated")
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end

  def call(conn, _opts), do: conn
end
