require 'git'

module Response
  module Object
    def to_response
      inspect
    end

    def to_preview
      inspect
    end
  end

  module Array
    def to_response
      map(&:to_preview)
    end
  end

  module Repo
    def to_preview
      {
        name: @path.sub(PROJECTS_DIR + '/', ''),
        updated_at: latest_commit.date
      }
    end

    def to_response
      {
        branches: client.branches.local,
        tags: client.tags.map(&:name),
        commits: commit_count,
        readme: readme,
        files: client.gtree('HEAD').children.each_pair.map do |name, blob|
          {
            name: name,
            directory: blob.tree?,
            size: (blob.size unless blob.tree?)
          }
        end
      }
    end
  end

  module Commit
    def to_preview
      {
        sha: sha,
        message: message,
        timestamp: date,
        author: author.name
      }
    end

    def to_response
      {
        committer_date: committer_date,
        author_date: author_date,
        sha: sha,
        message: message,
        author: {
          name: author.name,
          email: author.email
        },
        changes: diff(parent.gtree).patch.split("\n")
      }
    end
  end

  module Log
    def to_response
      @commits.to_response
    end
  end
end

Object.include(Response::Object)
Array.include(Response::Array)
Repo.include(Response::Repo)
Git::Object::Commit.include(Response::Commit)
Git::Log.include(Response::Log)
