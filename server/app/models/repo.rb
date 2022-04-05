# == Schema Information
#
# Table name: repos
#
#  id                :bigint           not null, primary key
#  backfilled_at     :datetime
#  canonical         :boolean          default(FALSE)
#  error_fetching_at :datetime
#  last_fetched_at   :datetime
#  name              :string
#  token             :string
#  user              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  github_id         :integer
#
# Indexes
#
#  index_repos_on_user_and_name_and_token  (user,name,token) UNIQUE
#
class Repo < ApplicationRecord
  has_many :repo_commits, dependent: :destroy

  scope :by_token, ->(t) { where(token: t) }
  scope :healthy, -> { where(error_fetching_at: nil) }
  scope :canonical, -> { where(canonical: true) }
  scope :not_backfilled, -> { where(backfilled_at: nil) }
  scope :least_recently_fetched, -> { order('last_fetched_at ASC') }

  def description
    "#{user}/#{name}"
  end
end
