#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'
require 'wikidata_ids_decorator'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class MembersPage < Scraped::HTML
  decorator WikidataIdsDecorator::Links

  field :members do
    member_rows.map { |row| fragment(row => MemberRow).to_h }
  end

  private

  def member_table
    noko.xpath('//table[.//th[contains(., "Grup parlamentar")]]')
  end

  def member_rows
    member_table.xpath('.//tr[td]')
  end
end

class MemberRow < Scraped::HTML
  field :name do
    tds[1].css('a').map(&:text).map(&:tidy).first
  end

  field :id do
    tds[1].css('a/@wikidata').map(&:text).first
  end

  field :area do
    tds[2].css('a').map(&:text).map(&:tidy).first
  end

  field :area_id do
    tds[2].css('a/@wikidata').map(&:text).first
  end

  field :party do
    tds[3].css('a').map(&:text).map(&:tidy).first
  end

  field :party_id do
    tds[3].css('a/@wikidata').map(&:text).first
  end

  private

  def tds
    noko.css('td')
  end
end

url = 'https://ro.wikipedia.org/wiki/Legislatura_2016-2020_(Camera_Deputa%C8%9Bilor)'
Scraped::Scraper.new(url => MembersPage).store(:members)
