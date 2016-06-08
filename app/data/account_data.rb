class AccountData < BaseData

  def create(objects)
    objects.each do |object|
      account = exists(object[:name])

      if account.blank?
        account = _create_account(object)
      end
    end
  end

  def exists(name)
    log "account check:#{name}"

    response = Fooda::AccountsApi.get_by({name: name})
    account = response.account

    if response.code != 200
      log "account check:#{name} not found"

      return nil
    end

    log "account check:#{name} exists"

    account
  end

  # deprecated
  def find_or_create(name, hash)
    account = find(name)
    return account if account.present?

    create(hash)
  end

  protected

  def _create_account(object)
    log "account create:#{object}"

    response = Fooda::AccountsApi.create({
      access_token: Token.map(Token::ADMIN_USER_EMAIL),
      client_token: Token.get_client,
      account: object
    })
    account = response.account

    if [200,201].include?(response.code)
      log "account created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "account create error:#{errors}"
    end

    account
  end

end
