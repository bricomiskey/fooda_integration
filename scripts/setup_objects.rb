#!/usr/bin/env ruby

require 'optparse'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

logger = Logger.new(STDOUT)

options = {
  accounts: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/accounts/accounts.yml"
    ],
  },
  buildings: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/buildings/buildings.yml"
    ],
  },
  deliveries: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/deliveries/deliveries.yml"
    ],
  },
  locations: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/locations/locations.yml"
    ],
  },
  markets: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/markets/markets.yml"
    ],
  },
  popups: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/popups/popups.yml"
    ],
  },
  tokens: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/tokens/tokens.yml"
    ],
  },
  users: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/users/users.yml"
    ],
  },
  vendors: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/vendors/vendors.yml"
    ],
  },
}

ARGV.push('-h') if ARGV.empty?

parser = OptionParser.new do |opts|
	opts.banner = "Usage: #{__FILE__} [options]"

  opts.on('-c', '--core', 'create core objects (optional)') do |s|
    [:accounts, :buildings, :locations, :markets, :tokens, :vendors, :users].each do |key|
      options[key][:create] = 1
    end
	end

  opts.on('-a', '--accounts', 'create accounts (optional)') do |s|
		options[:accounts][:create] = 1
	end

  opts.on('-b', '--buildings', 'create buildings (optional)') do |s|
		options[:buildings][:create] = 1
	end

  opts.on('-d', '--deliveries', 'create select/delivery events (optional)') do |s|
		options[:deliveries][:create] = 1
	end

  opts.on('-l', '--locations', 'create locaations (optional)') do |s|
		options[:locations][:create] = 1
	end

	opts.on('-m', '--markets', 'create markets (optional)') do |s|
		options[:markets][:create] = 1
	end

  opts.on('-p', '--popups', 'create popup events (optional)') do |s|
		options[:popups][:create] = 1
	end

  opts.on('-t', '--tokens', 'create tokens (optional)') do |s|
		options[:tokens][:create] = 1
	end

  opts.on('-u', '--users', 'create users (optional)') do |s|
		options[:users][:create] = 1
	end

  opts.on('-v', '--vendors', 'create vendors (optional)') do |s|
		options[:vendors][:create] = 1
	end

  opts.on('-h', '--help', 'help') do
		puts opts
		exit
	end
end

parser.parse!

# core objects

if options[:tokens] && options[:tokens][:create].to_i == 1
  logger.info "create tokens ..."

  options[:tokens][:data].each do |file|
    yaml = FileParser.load_file(file, erb: 1)

    token_data = TokenData.new
    token_data.create(yaml['tokens'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:users] && options[:users][:create].to_i == 1
  logger.info "create users ..."

  options[:users][:data].each do |file|
    yaml = FileParser.load_file(file, erb: 1)

    user_data = UserData.new
    user_data.create(yaml['users'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:accounts] && options[:accounts][:create].to_i == 1
  logger.info "accounts ..."

  options[:accounts][:data].each do |file|
    yaml = FileParser.load_file(file)

    account_data = AccountData.new
    account_data.create(yaml['accounts'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:markets] && options[:markets][:create].to_i == 1
  logger.info "markets ..."

  options[:markets][:data].each do |file|
    yaml = FileParser.load_file(file)

    market_data = MarketData.new
    market_data.create(yaml['markets'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:buildings] && options[:buildings][:create].to_i == 1
  logger.info "buildings ..."

  options[:buildings][:data].each do |file|
    yaml = FileParser.load_file(file)

    building_data = BuildingData.new
    building_data.create(yaml['buildings'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:locations] && options[:locations][:create].to_i == 1
  logger.info "locations ..."

  options[:locations][:data].each do |file|
    yaml = FileParser.load_file(file, erb: 1)

    location_data = LocationData.new
    location_data.create(yaml['locations'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:vendors] && options[:vendors][:create].to_i == 1
  logger.info "vendors ..."

  options[:vendors][:data].each do |file|
    yaml = FileParser.load_file(file, erb: 1)

    vendor_data = VendorData.new
    vendor_data.create(yaml['vendors'].map{ |o| Hashie::Mash.new(o) })
  end
end

# non-core objects

if options[:deliveries] && options[:deliveries][:create].to_i == 1
  logger.info "deliveries ..."

  options[:deliveries][:data].each do |file|
    yaml = FileParser.load_file(file, erb: 1)

    select_data = SelectData.new
    select_data.create(yaml['select_events'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:popups] && options[:popups][:create].to_i == 1
  logger.info "popups ..."

  options[:popups][:data].each do |file|
    yaml = FileParser.load_file(file, erb: 1)

    popup_data = PopupData.new
    popup_data.create(yaml['popups'].map{ |o| Hashie::Mash.new(o) })
  end
end
