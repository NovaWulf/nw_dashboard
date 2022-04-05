# This service will determine if this repo is the canonical version of the github
# repo, and mark it as such or not
# Github's API works after renames which in our case can double count
class RepoCanonicalizer < BaseService
  attr_reader :repo

  def initialize(repo:)
    @repo = repo
  end

  def run
    return if repo.github_id.present?

    repo_details = github_client.repo_details(user: repo.user, name: repo.name)
    if repo_details.nil? || repo_details['message'] == 'Not Found'
      repo.update(error_fetching_at: Time.now, canonical: false)
      Rails.logger.info "couldn't canonicalize repo: #{repo.id} as couldn't fetch"
      return
    end

    repo.github_id = repo_details['id']
    repo.canonical = repo.description == repo_details['full_name']
    repo.save

    if repo.canonical
      # if it is canonical, mark others with matching id as not so.
      Repo.where(github_id: repo_details['id']).each do |r|
        r.update(canonical: false) if r.id != repo.id
      end
    else
      # if it isn't canonical, make sure the canonical one exists
      # (this will short circuit if it already exists)
      repo_creator.run(token: repo.token, description: repo_details['full_name'])
    end
  end

  private

  def repo_creator
    RepoCreator
  end

  def github_client
    GithubRest.new
  end
end
