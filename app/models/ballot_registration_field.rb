class BallotRegistrationField < ActiveRecord::Base
  #----------------------------------------------------------------------------
  # Validations
  #------------
  validates :ballot_id,      :presence => true
  validates :name,           :presence => true
  validates :description,    :presence => true
  validates :expected_value, :presence => true
  validates :position,       :presence => true

  #----------------------------------------------------------------------------
  # Associations
  #-------------
  belongs_to :ballot


  #----------------------------------------------------------------------------

  protected

  def self.permitted_params
    [:name, :description, :expected_value]
  end
end
