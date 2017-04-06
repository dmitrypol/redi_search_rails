require "redi_search_rails/version"

module RediSearchRails
  extend ActiveSupport::Concern

  module ClassMethods

    def redisearch_schema(schema)
      @@schema = schema.to_a.flatten
      @@fields = schema.keys
      @@model = self.name.constantize
      @@index_name = @@model.to_s
      @@score = 1
    end

    def ft_search query
      results = REDI_SEARCH.call('FT.SEARCH', @@index_name, query,
       #'LIMIT', 0, 1000,
       #'NOCONTENT', #'VERBATIM',  #'WITHSCORES', #'NOSTOPWORDS', #'WITHPAYLOADS',
      )
      return results
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    def ft_create
      REDI_SEARCH.call('FT.CREATE', @@index_name,
        #'NOFIELDS', 'NOSCOREIDX', 'NOOFFSETS',
        'SCHEMA', @@schema
      )
      ft_optimize
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    def ft_add_all
      @@model.all.each {|record| ft_add(record) }
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    def ft_add record
      fields = []
      @@fields.each { |field| fields.push(field, record.send(field)) }
      REDI_SEARCH.call('FT.ADD', @@index_name, record.to_global_id, @@score,
        'REPLACE',
        #'NOSAVE', 'PAYLOAD', record.name,
        'FIELDS', fields
      )
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    def ft_del doc_id
      REDI_SEARCH.call('FT.DEL', @@index_name, doc_id)
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    def ft_optimize
      REDI_SEARCH.call('FT.OPTIMIZE', @@index_name)
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    def ft_drop
      REDI_SEARCH.call('FT.DROP', @@index_name)
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    def ft_info
      ap REDI_SEARCH.call('FT.INFO', @@index_name)
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

  end

end
