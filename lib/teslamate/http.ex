defmodule TeslaMate.HTTP do
  def child_spec(arg) do
    %{
      id: __MODULE__,
      start:
        {Finch, :start_link,
         [
           Keyword.merge(
             [
               name: __MODULE__,
               pools: %{
                 :default => [
                   size: 5,
                   conn_opts: [transport_opts: [inet6: true]]
                 ],
                 "https://owner-api.teslamotors.com" => [
                   size: 10,
                   conn_opts: [transport_opts: [inet6: true]]
                 ],
                 "https://nominatim.openstreetmap.org" => [
                   size: 3,
                   conn_opts: [transport_opts: [inet6: true]]
                 ],
                 "https://api.github.com" => [
                   size: 1,
                   conn_opts: [transport_opts: [inet6: true]]
                 ]
               }
             ],
             arg
           )
         ]}
    }
  end

  @pool_timeout 10_000

  def get(url, opts \\ []) do
    {headers, opts} =
      opts
      |> Keyword.put_new(:pool_timeout, @pool_timeout)
      |> Keyword.pop(:headers, [])

    Finch.build(:get, url, headers, nil)
    |> Finch.request(__MODULE__, opts)
  end

  def post(url, body \\ nil, opts \\ []) do
    {headers, opts} =
      opts
      |> Keyword.put_new(:pool_timeout, @pool_timeout)
      |> Keyword.pop(:headers, [])

    Finch.build(:post, url, headers, body)
    |> Finch.request(__MODULE__, opts)
  end
end
