class Vote < ActiveRecord::Base
  module Status
    DRAFT    = "DRAFT"
    FINISHED = "FINISHED"
  end

  #----------------------------------------------------------------------------
  # Validations
  #------------
  validates :candidate_id, :presence => true
  validates :ballot_id,    :presence => true
  validates :signature,    :presence => true
  validates :status,       :presence => true
  validates :value,        :presence => true, :on => :update
  validates :value_type,   :presence => true, :on => :update

  #----------------------------------------------------------------------------
  # Associations
  #-------------
  belongs_to :candidate
  belongs_to :ballot
end
