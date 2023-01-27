defmodule AliyunOpenApiSdk.Core do
  @moduledoc """
  path = ""
  method = "GET"
  body = %{
    "Action" => "DescribeApiGroups",
  }
    req_data = %{
    "PRODUCT" => "apigateway",
    "REGIONS"=> "cn-shenzhen",
    "ALIYUN_ACCESS_KEY" => "<YOUR ALIYUN_ACCESS_KEY>",
    "ALI_YUN_ACCESS_SECRET"=> "<YOUR ALI_YUN_ACCESS_SECRET>",
  }
  AliyunOpenApiSdk.Core.aliyun_api_request(method, path, body, req_data)

  path = ""
  method = "POST"
  body = %{
    "AppName" => "demo",
    "Description" => "demo",
    "Action" => "CreateApp",
    "Tag" => [%{"test1" => "test1"},%{"test2" => "test2"}]
  }
  body = %{
  "Action" => "CreateApp",
  "AppName" => "demo",
  "Description" => "demo",
  "Tag" => [%{"test1" => "test1"}, %{"test2" => "test2"}],
  }
  AliyunOpenApiSdk.Core.aliyun_api_request(method, path, body, req_data)

  """

  def client(req_data, now_time) do
    header = [{"Date", Calendar.DateTime.Format.httpdate(now_time)}]
    host = "https://#{req_data["PRODUCT"]}.#{req_data["REGIONS"]}.aliyuncs.com"

    middleware = [
      {Tesla.Middleware.BaseUrl, host},
      {Tesla.Middleware.Headers, header},
      Tesla.Middleware.FormUrlencoded,
      Tesla.Middleware.Logger
    ]

    Tesla.client(middleware)
  end

  def aliyun_api_request(method, path, body, req_data) do
    now_time = Calendar.DateTime.now_utc()
    body = gen_body(body, now_time, req_data)
    gen_body_sign_str2(method, body, req_data)
    sign_body = Map.put(body, "Signature", gen_body_sign_str(method, body, req_data))

    client(req_data, now_time)
    |> api_request(String.upcase(method), path, sign_body, req_data)
    |> case do
      {:ok, %{status: 200, body: body, headers: headers}} ->
        {:ok, %{:body => body, :headers => headers}}

      {:error, %{status: status, body: body, headers: headers}} ->
        {:error, %{:body => body, :headers => headers, :status => status}}

      other ->
        other
    end
  end

  defp api_request(client, "POST", path, body, _) do
    Tesla.post(client, path, body)
  end

  defp api_request(client, "GET", _path, body, _) do
    Tesla.get(client, "?#{URI.encode_query(body)}")
  end

  def hmac_sha(data, key) do
    :crypto.mac(:hmac, :sha, key <> "\&", data)
  end

  def gen_body(body, now_time, req_data) do
    # now_time = Calendar.DateTime.now!()
    body
    |> Map.put("Version", "2016-07-14")
    |> Map.put("Format", "JSON")
    |> Map.put("AccessKeyId", req_data["ALIYUN_ACCESS_KEY"])
    |> Map.put("SignatureNonce", UUID.uuid4())
    |> Map.put("Timestamp", Calendar.Strftime.strftime!(now_time, "%Y-%m-%dT%H:%M:%SZ"))
    |> Map.put("SignatureMethod", "HMAC-SHA1")
    |> Map.put("SignatureVersion", "1.0")
  end

  def gen_body_sign_str(method, body, req_data) do
    body
    |> URI.encode_query(:rfc3986)
    |> URI.encode_www_form()
    |> sign_body(method)
    |> hmac_sha(req_data["ALI_YUN_ACCESS_SECRET"])
    |> Base.encode64()
  end

  def body_item_handle(key, value) do
    "\&#{key}=#{URI.encode_www_form(value)}"
  end

  def sign_body(data, method) do
    "#{String.upcase(method)}\&%2F\&" <> data
  end

  def gen_body_sign_str2(method, body, _) do
    body
    |> URI.encode_query(:rfc3986)
    |> URI.encode_www_form()
    |> sign_body(method)
    |> IO.puts()
  end

  def handle_array(body) do
    Map.filter(body, fn {_key, val} -> is_list(val) end)
    |> Enum.map(fn {k, v} -> handle_array_key_value(k, v) end)
    |> List.flatten()

  end

  def handle_array_key_value(key, value) do
    Enum.with_index(value,fn element, index -> {"#{key}.#{index+1}", Map.to_list(element),key} end)

  end
end
