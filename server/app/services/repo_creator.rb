class RepoCreator < BaseService
  attr_reader :token, :description

  def initialize(token:, description:)
    @token = token
    @description = description
  end

  def run
    Rails.logger.info "finding or creating for repo: #{description}"
    repo = Repo.where(token: token, name: repo_name, user: repo_user).first
    unless repo
      repo = Repo.create(token: token, name: repo_name, user: repo_user)
      canonicalizer.run(repo: repo)
    end
  end

  private

  def repo_name
    description.split('/').last
  end

  def repo_user
    description.split('/').second_to_last
  end

  def canonicalizer
    RepoCanonicalizer
  end
end
