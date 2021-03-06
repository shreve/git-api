class Repo
  def initialize(path)
    @path = path
  end

  def client
    @client ||= Git.bare(@path)
  end

  def readme
    return nil unless readme_filename
    client.object("HEAD:#{readme_filename}").contents
  end

  def readme_filename
    client.gtree('HEAD').children.keys.find do |name|
      return name if name.casecmp('readme.md').zero?
    end
    nil
  end

  def latest_commit
    client.log.first
  end

  def commit_count(rev = 'HEAD')
    rev = '--all' if rev == :all
    `git '--git-dir=#{@path}' rev-list --count #{rev}`.to_i
  end

  def commit(params)
    sha = params.fetch('sha', nil)
    commit = client.gcommit(sha)
    begin
      commit.message
      commit
    rescue Git::GitExecuteError
      nil
    end
  end

  def commits(params)
    page = params.fetch('page', 1).to_i - 1
    client.log.skip(page * 30).tap do |log|
      # Force fetch the log
      log.instance_eval { check_log }
    end
  end

  class << self
    def find(repo)
      Repo.new(File.join(PROJECTS_DIR, repo))
    end

    def all
      Dir
        .glob('**/HEAD', base: PROJECTS_DIR)
        .map { |fn| Repo.find File.dirname(fn) }
    end
  end
end
