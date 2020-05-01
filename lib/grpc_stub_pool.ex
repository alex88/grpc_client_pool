defmodule GRPCClientPool do
  @moduledoc """
  Defines a GRPC Client Connection Pool
  """

  @type t :: module

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      {otp_app} = GRPCClientPool.Supervisor.compile_config(__MODULE__, opts)

      @otp_app otp_app

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      def start_link(_) do
        GRPCClientPool.Supervisor.start_link(__MODULE__, @otp_app)
      end

      def stop(timeout \\ 5000) do
        Supervisor.stop(__MODULE__, :normal, timeout)
      end

      defp with_channel(f) do
        pool_name = GRPCClientPool.Supervisor.poolboy_name(__MODULE__)

        :poolboy.transaction(
          pool_name,
          fn pid ->
            channel = GenServer.call(pid, :get_channel)
            f.(channel)
          end,
          :infinity
        )
      end
    end
  end
end
