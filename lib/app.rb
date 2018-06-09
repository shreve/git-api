require_relative './server'
require_relative './repo'

require 'git'

supplied = ENV.fetch('PROJECTS_DIR')
PROJECTS_DIR = File.expand_path(supplied)

App = Server.new do
  get '/repos' do
    Repo.all.map(&:list_item).sort_by { |r| r[:updated_at] }.reverse
  end

  get '/repos/:repo/commits/:sha' do
    if commit = Repo.find(repo).commit(params)
      {
        committer_date: commit.committer_date,
        author_date: commit.author_date,
        sha: commit.sha,
        message: commit.message,
        author: {
          name: commit.author.name,
          email: commit.author.email
        },
        changes: commit.diff(commit.parent.gtree).patch.split("\n")
      }
    end
  end

  get '/repos/:repo/commits' do
    puts params.inspect
    Repo.find(repo).commits(params).map do |commit|
      {
        sha: commit.sha,
        message: commit.message,
        timestamp: commit.date,
        author: commit.author.name
      }
    end
  end

  get '/repos/:repo' do
    Repo.find(repo).show
  end
end
