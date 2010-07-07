require 'rubygems'
require 'bundler'
#Bundler.setup
require 'sinatra'
require 'logger'
require 'helpers'

configure do
  set :logger, Logger.new(ARGV[0] || STDOUT)
  set :commands, YAML.load(File.open(File.join(File.dirname(File.expand_path(__FILE__)),'commands.yml')))
  set :last_run, File.join(File.dirname(File.expand_path(__FILE__)),'last_run.yml')
end

# show output of latest run
get '/' do
  @output = YAML.load(File.read(options.last_run))
  @run_at = File.ctime(options.last_run)
  erb :index
end

# execute 
get '/:hook' do
  options.logger.info "#{params[:hook]} hook called"
  output = []
  options.commands[params[:hook]].each do |command|
    options.logger.info "  Executing #{command.keys.first}: #{command.values.first}"
    output << { command.keys.first => `#{command.values.first} 2>&1` }
  end
  File.open(options.last_run, 'w') { |f| f.puts(output.to_yaml) }
  return ''
end
