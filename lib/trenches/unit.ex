defmodule Trenches.Unit do
  alias __MODULE__
  defstruct [:type, position: 0, strength: 0, cost: 0, speed: 0]

  def new("soldier") do
    %Unit{type: :soldier, position: 0, strength: 100, cost: 300, speed: 2}
  end
  def new("tank") do
    %Unit{type: :tank, position: 0, strength: 500, cost: 500, speed: 1}
  end
  def new(_), do: :error

  def move(%Unit{position: position, speed: speed} = unit) do
    %{unit | position: position + speed}
  end
end
