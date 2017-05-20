class Micropost < ApplicationRecord
  belongs_to :user # ←これだけでは相互に関連付けたと言えない。Userにhas_manyを書く必要がある。
  
  # default_scope : デフォルトのスコープを定義
  # default_scopeに{}の中身の式が変数として渡されている。⇒ラムダ式みたいだけど、これはブロック。両者は微妙に違いがある。
  default_scope -> { order(created_at: :desc) } 
  
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size
  
  private

    # アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
