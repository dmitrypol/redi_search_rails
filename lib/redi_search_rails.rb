require "redi_search_rails/version"
require "active_support/concern"

module RediSearchRails
  extend ActiveSupport::Concern

  module ClassMethods

    # will configure the RediSearch for the specific model
    #
    # @see https://github.com/dmitrypol/redi_search_rails
    # @param schema [Hash]  name: 'TEXT', age: 'NUMERIC'
    def redi_search_schema(schema)
      @@schema = schema.to_a.flatten
      @@fields = schema.keys
      @@model = self.name.constantize
      @@index_name = @@model.to_s
      @@score = 1
    end

    # search the index for specific keyword(s)
    #
    # @param keyword [String]  'some keyword'
    # @return [Array]   [1, "gid://application_name/User/unique_id", ["name", "Bob", "age", "100"]]
    # @raise [RuntimeError]
    def ft_search keyword
      results = REDI_SEARCH.call('FT.SEARCH', @@index_name, keyword,
       #'LIMIT', 0, 1000,
       #'NOCONTENT', #'VERBATIM',  #'WITHSCORES', #'NOSTOPWORDS', #'WITHPAYLOADS',
      )
      return results
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    # create index for specific model
    #
    # @return [String]
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

    # index all records in specific model
    #
    # @return [String]
    def ft_add_all
      @@model.all.each {|record| ft_add(record) }
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    # index specific record
    #
    # @param record [Object] Object to index
    # @return [String]
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

    # delete specific document from index
    #
    # @param  [doc_id] ID of the document, default is the Rails globalid
    # @return [String]
    def ft_del doc_id
      REDI_SEARCH.call('FT.DEL', @@index_name, doc_id)
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    # optimize specific index
    #
    # @return [String]
    def ft_optimize
      REDI_SEARCH.call('FT.OPTIMIZE', @@index_name)
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    # drop specific index
    #
    # @return [String]
    def ft_drop
      REDI_SEARCH.call('FT.DROP', @@index_name)
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

    # get info about specific index
    #
    # @return [String]
    def ft_info
      REDI_SEARCH.call('FT.INFO', @@index_name)
    rescue Exception => e
      Rails.logger.error e
      return e.message
    end

  end

end
