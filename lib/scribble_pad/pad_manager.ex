defmodule ScribblePad.PadManager do
  use GenServer
  alias __MODULE__

  defstruct pads: MapSet.new()

  # Client

  def start_link(args) do
    GenServer.start_link(PadManager, args, name: PadManager)
  end

  def register(pad_id) do
    GenServer.cast(PadManager, {:register, pad_id})
  end

  def get_pads() do
    GenServer.call(PadManager, :get_pads)
  end

  # Server (callbacks)

  @impl GenServer
  def init(_) do
    {:ok, %PadManager{}}
  end

  @impl GenServer
  def handle_cast({:register, pad_id}, %{pads: pads} = state) do
    unless MapSet.member?(pads, pad_id) do
      Phoenix.PubSub.broadcast(ScribblePad.PubSub, "scribble_pads", {:new_pad, pad_id})
    end

    state = %{state | pads: MapSet.put(pads, pad_id)}
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:get_pads, _from, state) do
    {:reply, MapSet.to_list(state.pads), state}
  end
end
