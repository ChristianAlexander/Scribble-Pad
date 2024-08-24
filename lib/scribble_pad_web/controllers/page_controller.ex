defmodule ScribblePadWeb.PageController do
  use ScribblePadWeb, :controller
  alias ScribblePad.PadManager

  def home(conn, _params) do
    pads = PadManager.get_pads() |> Enum.sort() |> Enum.take(5)
    render(conn, :home, pads: pads)
  end

  def start_pad(conn, %{"pad_name" => pad_name}) do
    redirect(conn, to: ~p"/pad/#{pad_name}")
  end
end
