# A ballot paper represents a particular user's votes on the candidates on a
# ballot. Its real world representation is a piece of paper, hence BallotPaper.
# See https://en.wikipedia.org/wiki/Ballot
class BallotPaper < ActiveRecord::Base
  module Status
    DRAFT    = 0
    FINISHED = 1
  end

  #----------------------------------------------------------------------------
  # Validations
  #------------
  validates :ballot_id,    :presence => true
  validates :signature,    :presence => true
  validates :status,       :presence => true

  #----------------------------------------------------------------------------
  # Associations
  #-------------
  belongs_to :ballot
  has_many   :votes

  #----------------------------------------------------------------------------
  # Callbacks
  #----------
  before_create :generate_uuid

  #----------------------------------------------------------------------------

  protected

  def self.permitted_params
    [:signature, :status]
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
