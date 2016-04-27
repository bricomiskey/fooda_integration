class AccountData < BaseData

  def create(hash)
    log "account:#{hash}"

    response = Fooda::AccountsApi.create({account: hash})

    if [200,201].include?(response.code)
      log "account created"
    else
      errors = response.errors.map{ |o| [o.code, o.message]}
      log "account create error:#{errors}"

      return nil
    end

    response[:account]
  end

  def find(name)
    log "account:#{name}"

    response = Fooda::AccountsApi.get_by({name: name})

    if response.code != 200
      log "account not found"

      return nil
    end

    log "account exists"

    response[:account]
  end

  def find_or_create(name, hash)
    account = find(name)
    return account if account.present?

    create(hash)
  end

end
