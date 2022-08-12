# == Schema Information
#
# Table name: repo_commits
#
#  id         :bigint           not null, primary key
#  count      :integer
#  day        :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  repo_id    :bigint           not null
#
# Indexes
#
#  index_repo_commits_on_repo_id          (repo_id)
#  index_repo_commits_on_repo_id_and_day  (repo_id,day) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#
class RepoCommit < ApplicationRecord
  belongs_to :repo
  scope :by_token, ->(token) { joins(:repo).where(repos: { token: token }) }
end
