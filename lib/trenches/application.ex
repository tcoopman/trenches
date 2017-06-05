defmodule Trenches do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Trenches.Web.Endpoint, []),
      supervisor(Registry, [:unique, Trenches.Registry]),
      supervisor(Trenches.Lobby, []),
      worker(Trenches.PlayerRepo, []),
    ]

    opts = [strategy: :one_for_one, name: Trenches.Supervisor]

    resp = Supervisor.start_link(children, opts)

    # ONLY IN DEV
    Trenches.PlayerRepo.create("thomas")
    Trenches.PlayerRepo.create("michel")
    
    resp
  end

  def service_name(service_id), do: {:via, Registry, {Trenches.Registry, service_id}}
end
