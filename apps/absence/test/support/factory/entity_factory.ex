defmodule Absence.Factory.EntityFactory do
  use ExMachina

  alias Absence.Absences.TimeoffRequest

  def timeoff_request_factory do
    %TimeoffRequest{
      uuid: EventSourcing.UUID.generate(),
      start_date: ~D[2019-01-01],
      end_date: ~D[2019-01-10]
    }
  end
end
