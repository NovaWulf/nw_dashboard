class EcosystemRepoFetcher < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    repos = electric_client.repos(token)
    Rails.logger.info 'found '
    repos.each do |r|
      Repo.find_or_create_by(token: token, name: repo_name(r), user: repo_user(r))
    end
  end

  def electric_client
    Electric.new
  end

  def repo_name(repo)
    repo.split('/').last
  end

  def repo_user(repo)
    repo.split('/').second_to_last
  end
end
