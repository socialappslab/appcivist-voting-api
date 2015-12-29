class Candidate < ActiveRecord::Base
  module Types
    EXTERNAL = 0
    ASSEMBLY = 1
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

  private

  # See: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/secure_token.rb
  # for why we implement it this way.
  def generate_uuid
    return if self.uuid?
    self.uuid = SecureRandom.uuid
  end
end
