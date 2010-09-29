require 'rubygems'
require 'sinatra'
require 'logger'
require 'yaml'
require 'open3'
require File.join(File.dirname(File.expand_path(__FILE__)),'helpers.rb')

configure do
  set :logger, Logger.new(ARGV[1] || STDOUT)
  set :commands, YAML.load(File.open(File.join(File.dirname(File.expand_path(__FILE__)),'commands.yml')))
  set :last_run, File.join(File.dirname(File.expand_path(__FILE__)),'last_run.yml')
  set :views, File.join(File.dirname(__FILE__), 'views')
end

# show output of latest run
get '/' do
  begin
    @output = YAML.load(File.read(options.last_run))
    @run_at = File.ctime(options.last_run)
    erb :index
  rescue Errno::ENOENT
    'Cimple has not been run yet! <a href="http://github.com/cannikin/cimple/blob/master/README">Set up your hooks</a> first, then check back.'
  end
end

# execute 
get '/:hook' do
  options.logger.info "#{params[:hook]} hook called"
  output = { params[:hook] => [] }
  options.commands[params[:hook]].each do |command|
    options.logger.info "  Executing #{command.keys.first}: #{command.values.first}"
    stdin, stdout, stderr = Open3.popen3(command.values.first)
    output[params[:hook]] << { command.keys.first => { 'stdout' => stdout.readlines.join, 'stderr' => stderr.readlines.join }}
    # output << { command.keys.first => `#{command.values.first} 2>&1` }
  end
  File.open(options.last_run, 'w') { |f| f.puts(output.to_yaml) }
  return ''
end
