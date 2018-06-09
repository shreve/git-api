require_relative './server'
require_relative './repo'
require_relative './response'

require 'git'

supplied = ENV.fetch('PROJECTS_DIR')
PROJECTS_DIR = File.expand_path(supplied)

App = Server.new do
  get '/repos' do
    Repo.all.sort_by { |r| r.latest_commit.date }.reverse
  end

  get '/repos/:repo' do
    Repo.find(repo)
  end

  get '/repos/:repo/commits' do
    Repo.find(repo).commits(params)
  end

  get '/repos/:repo/commits/:sha' do
    Repo.find(repo).commit(params)
  end
end
