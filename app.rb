require "sinatra"
require "yaml"
require "json"

images = YAML.load_file("#{File.dirname(__FILE__)}/data.yaml")["images"]
limit = images.count

get "/" do
  <<-HTML
<html>
  <body style='width:450px;margin:20px auto'>
    <h1 style='text-align:center'>PR MEME API</h1>
    <h3 style='text-align:center'>Call this URL with the format you prefer</h3>
    <div style='border:1px dotted black;padding:5px 0'>
      <h3 style='text-align:center'>http://#{request.host}/&lt;FORMAT&gt;</h3>
    </div>
    <h3 style='text-align:center'>Supported Formats: <a href="/html">html</a>, <a href="/json">json</a></h3>
  </body>
</html>
  HTML
end

get "/:format" do
  random_image = images[rand(limit)]
  format = params["format"]
  case format
  when 'html' then "<html><body><img style='max-width:100vw;max-height:100vh;width:auto;height:auto' src=\"#{random_image}\" /></body></html>"
  when 'json' then JSON.generate({image: random_image})
  else
    "<html><body style='width:450px;margin:20px auto'><p style='text-align:center'>Unsupported format: #{format}</p></body></html>"
  end
end
