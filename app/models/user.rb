class User < ActiveRecord::Base
  # validations
  validates :name,  presence: true, length: { maximum: 50 }
  # Ruby constant to define regex format of email address
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, 
  format: { with: VALID_EMAIL_REGEX },
  uniqueness: { case_sensitive: false }
  
  # convert email address to lower case before a record is saved
  before_save { self.email = email.downcase }
  
  # add support for secure passwords
  # 1. adds virtual password and password_confirmation attributes
  # 2. makes password(s) mandatory fields
  # 3. adds an authentication method to compare an encrypted password
  #    to password_digest to authenticate users
  has_secure_password
  # ensure password is at least 6 characters
  validates :password, length: { minimum: 6 }
  
end
