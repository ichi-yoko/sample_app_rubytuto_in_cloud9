class User < ApplicationRecord
  before_save { self.email = email.downcase }   # 保存する直前に実行される
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  # 正規表現を定数に宣言
  validates :email, presence: true, length: { maximum: 255 }, 
             format: { with: VALID_EMAIL_REGEX }, 
             uniqueness: { case_sensitive: false }
  
  has_secure_password
end
