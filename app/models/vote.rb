class Vote < ActiveRecord::Base
  #----------------------------------------------------------------------------
  # Validations
  #------------
  validates :candidate_id,    :presence => true
  validates :ballot_paper_id, :presence => true
  # TODO: Deprecate this as this should be fetched from the ballot.
  # validates :value_type,      :presence => true, :on => :update

  #----------------------------------------------------------------------------
  # Associations
  #-------------
  belongs_to :candidate
  belongs_to :ballot_paper

  #----------------------------------------------------------------------------

  protected

  def self.permitted_params
    [:value]
  end
end
