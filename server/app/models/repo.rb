class Repo < ApplicationRecord
  has_many :repo_commits, dependent: :destroy

  scope :by_token, ->(t) { where(token: t) }
  scope :healthy, -> { where(error_fetching_at: nil) }

  def description
    "#{user}/#{name}"
  end
end
