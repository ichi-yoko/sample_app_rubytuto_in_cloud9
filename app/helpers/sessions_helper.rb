module SessionsHelper
    def log_in(user)
      session[:user_id] = user.id
    end
    
    # 永続セッションとしてユーザーを記憶する
    def remember(user)
      user.remember
      # ブラウザのクッキーに値を登録する
      # 暗号化されたユーザーIDはテーブルからFindByでユーザーを検索するために使用する
      # トークンだけではユーザーを検索することができないため。
      # この2つでテーブルからユーザーを特定する
      cookies.permanent.signed[:user_id] = user.id  # 暗号化されたユーザーID
      cookies.permanent[:remember_token] = user.remember_token
    end
    
    # 渡されたユーザーがログイン済みユーザーであればtrueを返す
    def current_user?(user)
      user == current_user
    end
    
    # def current_user
    #     @current_user ||= User.find_by(id: session[:user_id])
    # end
    # 記憶トークンcookieに対応するユーザーを返す
    def current_user
      if (user_id = session[:user_id])  # ==でなく、= (代入)しているので注意
        @current_user ||= User.find_by(id: user_id)
      elsif (user_id = cookies.signed[:user_id])    # 2回signedを実行すると複合化
        user = User.find_by(id: user_id)
        if user && user.authenticated?(:remember, cookies[:remember_token])
          log_in user
          @current_user = user
        end
      end
    end
        
    def logged_in?
        !current_user.nil?
    end
    
    # 永続的セッションを破棄する
    def forget(user)
      user.forget
      cookies.delete(:user_id)
      cookies.delete(:remember_token)
    end
    
    # 現在のユーザーをログアウトする
    def log_out
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end 
    
    # 記憶したURL (もしくはデフォルト値) にリダイレクト
    def redirect_back_or(default)
        redirect_to(session[:forwarding_url] || default)
        session.delete(:forwarding_url)
    end

    # アクセスしようとしたURLを覚えておく
    def store_location
        session[:forwarding_url] = request.original_url if request.get?
    end
end
