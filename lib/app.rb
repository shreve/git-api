require_relative './server'
require_relative './repo'

require 'git'

supplied = ENV.fetch('PROJECTS_DIR')
PROJECTS_DIR = File.expand_path(supplied)

App = Server.new do
  get '/repos' do
    Repo.all.map(&:list_item).sort_by { |r| r[:updated_at] }.reverse
  end

  get '/repos/:repo' do
    Repo.find(repo).show
  end
end
