defmodule Absence.Factory.EventFactory do
  use ExMachina

  alias Absence.Absences.Events

  def hours_added_factory do
    %Events.HoursAdded{
      hours: 8
    }
  end

  def hours_removed_factory do
    %Events.HoursRemoved{
      hours: 8
    }
  end

  def timeoff_requested_factory do
    %Events.TimeoffRequested{
      start_date: ~D[2019-01-01],
      end_date: ~D[2019-01-10]
    }
  end

  def timeoff_request_approved_factory do
    %Events.TimeoffRequestApproved{}
  end

  def timeoff_request_rejected_factory do
    %Events.TimeoffRequestRejected{}
  end
end
