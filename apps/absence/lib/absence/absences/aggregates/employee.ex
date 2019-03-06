defmodule Absence.Absences.Aggregates.Employee do
  @behaviour EventSourcing.Aggregate

  alias __MODULE__
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Commands.RemoveHours
  alias Absence.Absences.Commands.RequestTimeOff
  alias Absence.Absences.Events.HoursAdded
  alias Absence.Absences.Events.HoursRemoved
  alias Absence.Absences.Events.TimeOffRequested
  alias Absence.Absences.TimeOffRequest

  defstruct [
    :uuid,
    hours: 0,
    pending_timeoff_requests: []
  ]

  def execute(%Employee{} = employee, %AddHours{} = add_hours) do
    %HoursAdded{
      employee_uuid: employee.uuid,
      hours: add_hours.hours
    }
  end

  def execute(%Employee{} = employee, %RemoveHours{} = remove_hours) do
    %HoursRemoved{
      employee_uuid: employee.uuid,
      hours: remove_hours.hours
    }
  end

  def execute(%Employee{} = employee, %RequestTimeOff{} = request_timeoff) do
    %TimeOffRequested{
      employee_uuid: employee.uuid,
      start_date: request_timeoff.start_date,
      end_date: request_timeoff.end_date
    }
  end

  def apply(%Employee{} = employee, %HoursAdded{hours: hours}) do
    %{employee | hours: employee.hours + hours}
  end

  def apply(%Employee{} = employee, %HoursRemoved{hours: hours}) do
    %{employee | hours: employee.hours - hours}
  end

  def apply(%Employee{} = employee, %TimeOffRequested{start_date: start_date, end_date: end_date}) do
    %{
      employee
      | pending_timeoff_requests: [
          %TimeOffRequest{
            employee_uuid: employee.uuid,
            start_date: start_date,
            end_date: end_date
          }
          | employee.pending_timeoff_requests
        ]
    }
  end
end
