defmodule AbsenceWeb.SessionController do
  use AbsenceWeb, :controller

  alias Absence.Accounts.User

  @accounts Application.get_env(:absence_web, :accounts)
  @token_max_age 60 * 60 * 24

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
    token = Phoenix.Token.sign(conn, "session", id, max_age: @token_max_age)
    put_session(conn, :user_id, token)
  end
end
