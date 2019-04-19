defmodule AbsenceWeb.SessionController do
  use AbsenceWeb, :controller

  alias Absence.Accounts.User
  alias AbsenceWeb.Authenticator

  plug AbsenceWeb.RequireGuest when action in [:new, :create]
  plug AbsenceWeb.RequireUser when action in [:delete]

  @accounts Application.get_env(:absence_web, :accounts)

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case @accounts.authenticate_email_password(email, password) do
      {:ok, %User{} = user} ->
        conn
        |> put_user_in_session(user)
        |> put_flash(:info, "Authenticated successfully")
        |> redirect(to: Routes.page_path(conn, :index))

      :error ->
        conn
        |> put_flash(:error, "Invalid email/password")
        |> render("new.html")
    end
  end

  defp put_user_in_session(conn, %User{id: id}) do
    put_session(conn, :user_id, Authenticator.encrypt(id))
  end

  def delete(conn, _) do
    delete_session(conn, :user_id)

    conn
    |> put_flash(:ok, "Logged out successfully")
    |> redirect(to: "/session/new")
  end
end
