defmodule AbsenceWeb.Admin.TimeoffView do
  use AbsenceWeb, :view

  def pending?(%{status: :pending}), do: true
  def pending?(%{status: _}), do: false

  def approve_timeoff_request_form(conn, changeset, request) do
    timeoff_request_form(conn, changeset, request, "approve")
  end

  def reject_timeoff_request_form(conn, changeset, request) do
    timeoff_request_form(conn, changeset, request, "reject")
  end

  defp timeoff_request_form(conn, changeset, request, action) do
    route = Routes.admin_timeoff_path(conn, :update, request.uuid)

    form_for(
      changeset,
      route,
      [as: action <> "_timeoff_request", method: :patch, class: "inline-form"],
      &[
        hidden_input(&1, :employee_uuid, value: request.employee_uuid),
        hidden_input(&1, :timeoff_request_uuid, value: request.uuid),
        submit(String.capitalize(action), class: "button button-outline button-small")
      ]
    )
  end
end
