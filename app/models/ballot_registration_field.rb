require 'digest/sha1'

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

  def self.generate_signature_from_params(params)
    concat = params.map {|field| field[:user_input].to_s.downcase.strip}.join("")
    return Digest::SHA1.hexdigest(concat)
  end


  #----------------------------------------------------------------------------

  protected

  def self.permitted_params
    [:name, :description, :expected_value, :user_input]
  end
end
