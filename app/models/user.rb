class User < ApplicationRecord
  has_many :microposts, dependent: :destroy # モデル同士をを関連付けるhas_manyとbelong_toは対で一緒に使用
  
  before_save { self.email = email.downcase }   # 保存する直前に実行される
  
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  # 正規表現を定数に宣言
  validates :email, presence: true, length: { maximum: 255 }, 
             format: { with: VALID_EMAIL_REGEX }, 
             uniqueness: { case_sensitive: false }
  
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  def feed
    Micropost.where("user_id = ?", id)
  end
  
end
