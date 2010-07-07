require 'rubygems'
require 'bundler'
#Bundler.setup
require 'sinatra'
require 'logger'

class Array
  def every(count)
    chunks = []
    each_with_index do |item, index|
      chunks << [] if index % count == 0
      chunks.last << item
    end
    chunks
  end
  alias / every
end

configure do
  set :logger, Logger.new(STDOUT)
  set :commands, YAML.load(File.open(File.join(File.dirname(File.expand_path(__FILE__)),'commands.yml')))
end

helpers do
  def render(output)
    "<pre>#{output.join('<br><br>')}</pre>"
  end
end

get '/:hook' do
  options.logger.info "#{params[:hook]} hook called"
  output = []
  options.commands[params[:hook]].each do |command|
    output << command.keys.first
    output << `#{command.values.first} 2>&1`
  end
  render output
end

