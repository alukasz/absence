defmodule Absence.Absences do
  alias Absence.Dispatcher
  alias Absence.Absences.Commands

  def request_timeoff(timeoff_params) do
    with {:ok, command} <- Commands.RequestTimeoff.build(timeoff_params) do
      Dispatcher.dispatch(command)
    end
  end
end
