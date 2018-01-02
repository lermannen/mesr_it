defmodule FeedStore.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(FeedStore, [])
    ]

    options = [
      name: FeedStore.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, options)
  end
end
