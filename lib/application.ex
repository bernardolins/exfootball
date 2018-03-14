defmodule Exfootball.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [worker(Cachex, [:exfootball_cache, []])]

    opts = [strategy: :one_for_one, name: Exfootball.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
