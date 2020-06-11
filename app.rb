require "sinatra"
require "yaml"
require "json"

require_relative "./slack"

images = YAML.load_file("#{File.dirname(__FILE__)}/data.yaml")["images"]
limit = images.count
slack = Slack.new

get "/" do
  <<-HTML
<html>
  <body style='width:600px;margin:20px auto;text-align:center'>
    <h1>PR MEME API</h1>
    <h3>Call this URL with the format you prefer</h3>
    <div style='border:1px dotted black;padding:5px 0'>
      <h3>Random image: http://#{request.host}/&lt;FORMAT&gt;</h3>
      <h3>Specific image: http://#{request.host}/&lt;FORMAT&gt;/&lt;NUMBER&gt;</h3>
      <p>Note: if the &lt;NUMBER&gt; overflows, it will just cycle through. Invalid &lt;NUMBER&gt; will return a random image.</p>
    </div>
    <h3>Supported Formats: <a href="/html">html</a>, <a href="/json">json</a></h3>
  </body>
</html>
  HTML
end

get "/:format" do
  format = params["format"]
  id = rand(limit)
  image_url = images[id]

  case format
  when 'html' then "<html><body><img style='max-width:100vw;max-height:100vh;width:auto;height:auto' src=\"#{image_url}\" /></body></html>"
  when 'json' then JSON.generate({id: id,image: image_url})
  else
    "<html><body style='width:450px;margin:20px auto'><p style='text-align:center'>Unsupported format: #{format}</p></body></html>"
  end
end

get "/:format/:id" do
  format = params["format"]
  id = params["id"] =~ /^\d+$/ ? params["id"].to_i : rand(limit)
  image_url = images[id % limit]

  case format
  when 'html' then "<html><body><img style='max-width:100vw;max-height:100vh;width:auto;height:auto' src=\"#{image_url}\" /></body></html>"
  when 'json' then JSON.generate({id: (id % limit),image: image_url})
  else
    "<html><body style='width:450px;margin:20px auto'><p style='text-align:center'>Unsupported format: #{format}</p></body></html>"
  end
end

post "/slack" do
  puts request
  if slack.verify(request)
    "Authentic payload"
  else
    "NOT authentic payload"
  end
end
