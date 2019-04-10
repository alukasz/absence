defmodule AbsenceWeb.RegistrationController do
  use AbsenceWeb, :controller

  alias Absence.Accounts

  plug :scrub_params, "user" when action == :create

  def new(conn, _params) do
    render(conn, "new.html", user: Accounts.user_changeset())
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Registration successful")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Registration failed")
        |> render("new.html", user: changeset)
    end
  end
end
