defmodule AbsenceWeb.AuthorizePlug do
  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [action_name: 1, put_flash: 3, redirect: 2]

  alias AbsenceWeb.Router.Helpers

  def init(opts), do: opts

  def call(conn, policy) when is_atom(policy), do: call(conn, [policy, nil])

  def call(conn, [policy, resource_name]) do
    user = conn.assigns.current_user
    resource = conn.assigns[resource_name]

    if apply_policy(policy, action_name(conn), user, resource) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to access this page")
      |> redirect(to: Helpers.timeoff_path(conn, :index))
      |> halt()
    end
  end

  defp apply_policy(module, action, user, nil), do: apply(module, action, [user])
  defp apply_policy(module, action, user, resource), do: apply(module, action, [user, resource])
end
