class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  
  #多対多 following
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow 
  
  #Rails命名規則：User から Relationship を取得するとき、user_id が使用される
  #followingクラスがないため補足を加える　#中間テーブル＝has_many :relationship #参照id(カラム)＝follow_id
  #中間テーブルrelationships > relationship > follow_id
  
  
  #多対多 follower
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverse_of_relationship, source: :user
  
  #reverses_of_relationshipは今命名した→クラスを指定する必要あり #follow_id Rails命名規則とは違うことをすると明記
  #中間テーブル＝has_many :reverses_of_relationship… #参照id(カラム)＝user_id
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  #実行したUserのインスタンスがself #見つかればRelation、見つからなければフォロー関係を保存(create=build+save)
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
end
