#!/usr/bin/env ruby

require 'optparse'
require 'yaml'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

def load_file(file, options={})
  if options[:erb].to_i == 1
    YAML.load(ERB.new(File.read(file)).result)
  else
    YAML.load_file(file)
  end
end

logger = Logger.new(STDOUT)

options = {
  buildings: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/buildings/buildings.yml"
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
  vendors: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/vendors/vendors.yml"
    ],
  },
  partners: {
    create: 0,
    data: [
      "#{Dir.pwd}/app/data/partners/partners.yml"
    ],
  }
}

parser = OptionParser.new do |opts|
	opts.banner = "Usage: #{__FILE__} [options]"
  opts.on('-a', '--all', 'create all (optional)') do |s|
    [:buildings, :locations, :markets, :vendors, :partners].each do |key|
      options[key][:create] = 1
    end
	end

  opts.on('-b', '--buildings', 'create buildings (optional)') do |s|
		options[:buildings][:create] = 1
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

  opts.on('-v', '--vendors', 'create vendors (optional)') do |s|
		options[:vendors][:create] = 1
	end

  opts.on('-r', '--partners', 'create partners (optional)') do |s|
                options[:partners][:create] = 1
        end

  opts.on('-h', '--help', 'help') do
		puts opts
		exit
	end
end

parser.parse!

if options[:markets] && options[:markets][:create].to_i == 1
  logger.info "create markets ..."

  options[:markets][:data].each do |file|
    yaml = load_file(file)

    market_data = MarketData.new
    market_data.create(yaml['markets'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:buildings] && options[:buildings][:create].to_i == 1
  logger.info "create buildings ..."

  options[:buildings][:data].each do |file|
    yaml = load_file(file)

    building_data = BuildingData.new
    building_data.create(yaml['buildings'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:locations] && options[:locations][:create].to_i == 1
  logger.info "create locations ..."

  options[:locations][:data].each do |file|
    yaml = load_file(file, erb: 1)

    location_data = LocationData.new
    location_data.create(yaml['locations'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:vendors] && options[:vendors][:create].to_i == 1
  logger.info "create vendors ..."

  options[:vendors][:data].each do |file|
    yaml = load_file(file, erb: 1)

    vendor_data = VendorData.new
    vendor_data.create(yaml['vendors'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:popups] && options[:popups][:create].to_i == 1
  logger.info "create popups ..."

  options[:popups][:data].each do |file|
    yaml = load_file(file, erb: 1)

    popup_data = PopupData.new
    popup_data.create(yaml['popups'].map{ |o| Hashie::Mash.new(o) })
  end
end

if options[:partners] && options[:partners][:create].to_i == 1
  logger.info 'create partners ...'

  options[:partners][:data].each do |file|
    yaml = load_file(file, erb: 1)

    partner_data = PartnerData.new
    partner_data.create(yaml['partners'].map{ |o| Hashie::Mash.new(o) })
  end
end
