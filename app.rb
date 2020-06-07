require "sinatra"
require "yaml"

images = YAML.load_file("#{File.dirname(__FILE__)}/data.yaml")["images"]
limit = images.count

get "/" do
  random_image = images[rand(limit)]
  "<html><body><img src=\"#{random_image}\" /></body></html>"
end
