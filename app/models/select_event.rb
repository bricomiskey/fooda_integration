class SelectEvent
  include LoggerConcern
  include TokenConcern

  def initialize(options={})
    tokens(options)
  end

  def update_state(id, state)
    log.info "select event:#{id} state:#{state} try"

    params = {
      access_token: access_token,
      client_token: client_token,
      select_event: {
        status: state
      }
    }
    response = Fooda::SelectEventsApi.update(id, params)

    if response.code == 200
      log.info "select event:#{id} state:#{state} completed"
    end

    response
  end

end
