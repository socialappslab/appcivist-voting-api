# A ballot is an election process within an organization.
class BallotConfiguration < ActiveRecord::Base
  self.table_name='ballot_configuration'
  validates :ballot_id,  :presence => true
  validates :position,   :presence => true
  validates :key,        :presence => true
  validates :value,      :presence => true

  belongs_to :ballot
end
