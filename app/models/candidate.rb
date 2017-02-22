class Candidate < ActiveRecord::Base
  self.table_name='candidate'
  module Types
    EXTERNAL = 0
    ASSEMBLY = 1
    CONTRIBUTION = 2
    CAMPAIGN = 3
    USER = 4
    GROUP = 5
  end

  #----------------------------------------------------------------------------
  # Validations
  #------------
  validates :ballot_id,         :presence => true
  validates :candidate_type,    :presence => true
  validates :contribution_uuid, :presence => true

  #----------------------------------------------------------------------------
  # Associations
  #-------------
  belongs_to :ballot

  #----------------------------------------------------------------------------
  # Callbacks
  #----------
  before_create :generate_uuid

  #----------------------------------------------------------------------------

  protected

  def self.permitted_params
    [:candidate_type, :contribution_uuid]
  end

  #----------------------------------------------------------------------------

  private

  # See: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/secure_token.rb
  # for why we implement it this way.
  def generate_uuid
    return if self.uuid?
    self.uuid = SecureRandom.uuid
  end
end
