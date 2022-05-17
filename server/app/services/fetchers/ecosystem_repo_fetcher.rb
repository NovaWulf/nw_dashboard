module Fetchers
  class EcosystemRepoFetcher < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    repos = electric_client.repos(token)
    Rails.logger.info "found #{repos.count} repos for #{token}"
    repos.each do |r|
      RepoCreator.run(token: token, description: r)
    end
  end

  def electric_client
    Electric.new
  end
end
end