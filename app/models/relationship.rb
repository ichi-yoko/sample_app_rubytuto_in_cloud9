class Relationship < ApplicationRecord
  # ここの部分はRailに乗り切れない！乗らない場合は「設定」を書き足す必要がある。（COC）
  # ★ここ大事★
  belongs_to :follower, class_name: "User"  # follower_id クラス名Userを渡せばそのidと関連付けられる
  belongs_to :followed, class_name: "User"  # followed_id
  # belongs_to :hoge, class_name: 'User', foreign_key: 'follower_id'
  # belongs_to :user user_id(モデル名_id)
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
