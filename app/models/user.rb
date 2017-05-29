class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
    # <Getter & Setter>
    # def remember_token
    #   @token
    # end
    # def remember_token=(str)
    #   @token = str
    # end
  
  # before_save { self.email = email.downcase }   # 保存する直前に実行される
  before_save   :downcase_email
  before_create :create_activation_digest  # sign upの時にこの処理が走る
  
  has_many :microposts, dependent: :destroy # モデル同士をを関連付けるhas_manyとbelong_toは対で一緒に使用
  
  # ※active_relationshipsという名称はなんでもよい。この名称がメソッド名となる。
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  # User.first.active_relationships.map(&:followed)を使わなくても
  # 以下のhas_manyがあればUser.first.followingで取得できる
  # followingとしているのは、following_idを探しに行かせるから
  # もしここをhogeにするとhoge_idはありませんというエラーになる。
  has_many :following, through: :active_relationships, source: :followed  # sourceの後はUser.rbのbelongs_toで定義したものを指定する
  has_many :followers, through: :passive_relationships, source: :follower
  
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
  
  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token  # この左辺のselfは省略不可
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  # ユーザーIDとパスワードで認証していたauthenticateも同じことをしている
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil?
  #   BCrypt::Password.new(self.remember_digest).is_password?(remember_token) # ここのselfは省略可能
  # end
  # トークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")  # モデル内にあるのでselfは省略することもできる
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil) # nilを入れれば必ずログインは失敗するというBcryptの仕様
  end
  
  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  def feed
    # Micropost.where("user_id = ?", self.id)
    
    # これだとフォローしているユーザー数が多いときに処理が遅くなってしまう
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    # following_ids: following_ids, user_id: id)
     
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end
  
  # ユーザーをフォローする
  def follow(other_user)
    self.active_relationships.create(followed_id: other_user.id)
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    self.active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    self.following.include?(other_user)
  end
  
  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token # 仮想のactivation_tokenにまずは保存。ここに保存したものはユーザーのメールに含まれる
      self.activation_digest = User.digest(activation_token)  # 実態を持つところに保存。ハッシュ化したものを保存したのでこれでユーザーに教えたトークンは忘れられる。
    end
end
