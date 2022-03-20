class Repo < ApplicationRecord
  has_many :repo_commits, dependent: :destroy
end
