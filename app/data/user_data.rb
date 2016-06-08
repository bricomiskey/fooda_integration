class UserData < BaseData

  def create(objects)
    objects.each do |object|
      user = exists(object[:email])

      if user.blank?
        _create_user(object)
      end
    end
  end

  def exists(email)
    log "user check:#{email}"

    response = Fooda::UsersApi.get_by({email: email})
    user = response.user

    if response.code != 200
      log "user check:#{email} not found"
      return nil
    end

    log "user check:#{email} exists"

    user
  end

  protected

  def _create_user(user_object)
    log "user create:#{user_object}"

    response = Fooda::UsersApi.create({user: user_object})

    if [200,201].include?(response.code)
      log "user created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "user create error:#{errors}"
    end

    response.user
  end

end
