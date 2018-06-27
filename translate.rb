require 'uri'
require 'net/http'
require 'json'
require 'dotenv/load'
require 'yaml'

URL_API = "https://translate.yandex.net/api/v1.5/tr.json/translate?lang=en-es&key=#{ENV['YANDEX']}"

def translate(text)
	uri = URI(URL_API)
	req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/x-www-form-urlencoded')
	req.set_form_data({
		text: text
	})
	res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
	  http.request(req)
	end
	result = JSON.parse(res.body)
	return result["text"].first.to_s.capitalize
end 

def save_pair(parent, myHash)
  myHash.each {|key, value|
    value.is_a?(Hash) ? save_pair(key, value) : myHash.merge!(Hash[key , translate(value)])
  }
end

Dir["#{File.dirname(__FILE__)}/yml/**/*.yml"].each do |file_path|
	dirname =  File.dirname(file_path)
	puts "Procesando #{dirname}"
	yml = YAML.load(File.read(file_path))
	save_pair(nil, yml)
	File.open("#{dirname}/es.yml","w") do |f|
		f.write yml.to_yaml
	end 
end


