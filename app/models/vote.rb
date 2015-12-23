class Vote < ActiveRecord::Base
  #----------------------------------------------------------------------------
  # Validations
  #------------
  validates :candidate_id, :presence => true
  validates :ballot_id,    :presence => true
  validates :signature,    :presence => true
  validates :status,       :presence => true
  validates :value,        :presence => true
  validates :value_type,   :presence => true

  #----------------------------------------------------------------------------
  # Associations
  #-------------
  belongs_to :candidate
  belongs_to :ballot
end
