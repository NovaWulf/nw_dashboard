class RepoCommit < ApplicationRecord
  belongs_to :repo

  scope :by_token, ->(token) { joins(:repo).where(repos: {token: token})}
end
