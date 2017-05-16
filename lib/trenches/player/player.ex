defmodule Trenches.Player do
  alias __MODULE__
  alias Trenches.Unit

  defstruct [:id, :name, units: [], money: 1000]

  def new(id, name) do
    %Player{id: id, name: name}
  end

  def add_unit(%Player{units: units} = player, unit_type) do
    case Unit.new(unit_type) do
      %Unit{} = unit ->
        money_left_after_unit = player.money - unit.cost
        case money_left_after_unit > 0 do
          true ->
            %{player | units: [unit | units], money: money_left_after_unit}
          false -> player
        end
      :error ->
        player
    end
  end

  def move_units(%Player{units: units} = player) do
    units = Enum.map(units, fn unit ->
      Unit.move(unit)
    end)
    %{player | units: units}
  end
end
