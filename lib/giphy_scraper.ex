defmodule GiphyScraper do
  @giphy_url Application.get_env(:giphy_scraper, :giphy_url)
  @giphy_api_key Application.get_env(:giphy_scraper, :giphy_api_key)
  def query(search_term) do
    search_term
    |> giphy_url_builder
    |> fetch_and_format_giphy_image
  end

  defp giphy_url_builder(search_term) do
    "#{@giphy_url}search?api_key=#{@giphy_api_key}&q=#{search_term}&limit=25&offset=0"
  end

  defp fetch_and_format_giphy_image(url) do
    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url),
      %{"data" => data} <- Poison.Parser.parse!(body, %{})
    do
      Enum.map(data, &format_giphy_image(&1))
    else
      {:ok, %{status_code: 403, body: body}} -> IO.puts("This happened: #{body}")
      {:error} -> IO.puts("some bad shit happened")
    end
  end

  defp format_giphy_image(data) do
    %GiphyImage{
      id: Map.get(data, "id"),
      url: Map.get(data, "url"),
      author: Map.get(data, "username"),
      title: Map.get(data, "title")
    }
  end
end
