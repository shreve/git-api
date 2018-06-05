class Repo
  def initialize(path)
    @path = path
  end

  def client
    @client ||= Git.open(@path)
  end

  def list_item
    {
      name: @path.sub(PROJECTS_DIR + '/', ''),
      updated_at: latest_commit.date
    }
  end

  def show
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
    `git '--git-dir=#{@path}/.git' rev-list --count #{rev}`.to_i
  end

  class << self
    def find(repo)
      Repo.new(File.join(PROJECTS_DIR, repo))
    end

    def all
      Dir
        .glob('**/.git', base: PROJECTS_DIR)
        .map { |fn| Repo.find File.dirname(fn) }
    end
  end
end
