defmodule Absence.Factory.EntityFactory do
  use ExMachina

  alias Absence.Absences.TimeoffRequest

  @uuid_generator Application.get_env(:event_sourcing, :uuid_generator)

  def timeoff_request_factory do
    %TimeoffRequest{
      uuid: @uuid_generator.generate(),
      start_date: ~D[2019-01-01],
      end_date: ~D[2019-01-10]
    }
  end
end