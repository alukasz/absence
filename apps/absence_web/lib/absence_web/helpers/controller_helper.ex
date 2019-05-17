defmodule AbsenceWeb.ControllerHelper do
  def current_user(%Plug.Conn{} = conn) do
    conn.assigns.current_user
  end
end
