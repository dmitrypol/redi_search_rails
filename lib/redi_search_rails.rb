require "redi_search_rails/version"
require "active_support/concern"
require "ostruct"

module RediSearchRails
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    # will configure the RediSearch for the specific model
    #
    # @see https://github.com/dmitrypol/redi_search_rails
    # @param schema [Hash]  name: 'TEXT', age: 'NUMERIC'
    def redi_search_schema(schema)
      @schema = schema.to_a.flatten
      @fields = schema.keys
      @model = self.name.constantize
      @index_name = @model.to_s
      @score = 1
    end

    # search the index for specific keyword(s)
    #
    # @param keyword [String]  'some keyword'
    # @param offset [Integer]   default 0
    # @param keyword [Integer]  default 10
    # @return [Array]   [1, "gid://application_name/User/unique_id", ["name", "Bob", "age", "100"]]
    # @raise [RuntimeError]
    def ft_search keyword:, offset: 0, num: 10, filter: {}
      if filter[:numeric_field].blank?
        results = REDI_SEARCH.call('FT.SEARCH', @index_name, keyword.strip,
          'LIMIT', offset, num)
      else
        results = REDI_SEARCH.call('FT.SEARCH', @index_name, keyword.strip,
          'LIMIT', offset, num,
          'FILTER', filter[:numeric_field], filter[:min], filter[:max]
        )
      end
      #'NOCONTENT', 'VERBATIM',  'WITHSCORES', 'NOSTOPWORDS', 'WITHPAYLOADS',
      #'INKEYS', 'INFIELDS', 'SLOP', 'LANGUAGE', 'EXPANDER', 'SCORER', 'PAYLOAD', 'SORTBY'
      return results
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # search the index for specific keyword(s) and return output as array of objects
    #
    # @param keyword [String]  'some keyword'
    # @param offset [Integer]   default 0
    # @param keyword [Integer]  default 10
    # @return [Array]   [{"id": "gid://application_name/User/unique_id", "name": "Bob", "age": "100"}, ...]
    def ft_search_format(args)
      results = ft_search(args)
      # => transform into array of objects
      output = []
      results.shift  # => remove count
      results.each_slice(2) do |result|
        attributes = {}
        result[1].each_slice(2) do |attribute|
          attributes[attribute[0]] = attribute[1]
        end
        hash = {id: result[0]}.merge(attributes)
        output << OpenStruct.new(hash)
      end
      return output
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # number of records found for keywords
    #
    # @param keyword [Hash]  keyword that gets passed to ft_search
    # @return [Integer]   number of results matching the search
    def ft_search_count(args)
      ft_search(args).first
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # create index for specific model
    #
    # @return [String]
    def ft_create
      REDI_SEARCH.call('FT.CREATE', @index_name,
        'SCHEMA', @schema
        #'NOFIELDS', 'NOSCOREIDX', 'NOOFFSETS',
      )
      ft_optimize
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # index all records in specific model
    #
    # @return [String]
    def ft_add_all
      @model.all.each {|record| ft_add(record: record) }
      ft_optimize
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # index specific record
    #
    # @param record [Object] Object to index
    # @return [String]
    def ft_add record:
      fields = []
      @fields.each { |field| fields.push(field, record.send(field)) }
      REDI_SEARCH.call('FT.ADD', @index_name, record.to_global_id.to_s, @score,
        'REPLACE',
        'FIELDS', fields
        #'NOSAVE', 'PAYLOAD', 'LANGUAGE'
      )
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # index existing Hash
    #
    # @param record [string] key of existing HASH key in Redis that will hold the fields the index needs.
    # @return [String]
    def ft_addhash redis_key:
      REDI_SEARCH.call('FT.ADDHASH', @index_name, redis_key, @score, 'REPLACE')
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # delete all records in specific model
    #
    # @return [String]
    def ft_del_all
      @model.all.each {|record| ft_del(record: record) }
      ft_optimize
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # delete specific document from index
    #
    # @param record [Object] Object to delete
    # @return [String]
    def ft_del record:
      doc_id = record.to_global_id
      REDI_SEARCH.call('FT.DEL', @index_name, doc_id)
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # optimize specific index
    #
    # @return [String]
    def ft_optimize
      REDI_SEARCH.call('FT.OPTIMIZE', @index_name)
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # drop specific index
    #
    # @return [String]
    def ft_drop
      REDI_SEARCH.call('FT.DROP', @index_name)
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # get info about specific index
    #
    # @return [String]
    def ft_info
      REDI_SEARCH.call('FT.INFO', @index_name)
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # add all values for a model attribute to autocomplete
    #
    # @param attribute [String] - name, email, etc
    def ft_sugadd_all (attribute:)
      @model.all.each {|record| ft_sugadd(record: record, attribute: attribute) }
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # add string to autocomplete dictionary
    #
    # @param record [Object] object
    # @param attribute [String] - name, email, etc
    # @param score [Integer] - score
    # @return [Integer] - current size of the dictionary
    def ft_sugadd (record:, attribute:, score: 1)
      # => combine model with attribute to create unique key like user_name
      key = "#{@model.to_s}:#{attribute}"
      string = record.send(attribute)
      REDI_SEARCH.call('FT.SUGADD', key, string, score)
      # => INCR
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # query dictionary for suggestion
    #
    # @param attribute [String] - name, email, etc
    # @param prefix [String] - prefix to query dictionary
    # @return [Array] - suggestions for prefix
    def ft_sugget (attribute:, prefix:)
      key = "#{@model}:#{attribute}"
      REDI_SEARCH.call('FT.SUGGET', key, prefix)
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # delete all values for a model attribute to autocomplete
    #
    # @param attribute [String] - name, email, etc
    def ft_sugdel_all (attribute:)
      @model.all.each {|record| ft_sugdel(record: record, attribute: attribute) }
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # delete a string from a suggestion index.
    #
    # @param attribute [String]
    # @param value [String] - string to delete
    # @return [Integer] - 1 if found, 0 if not
    def ft_sugdel (record:, attribute:)
      key = "#{@model}:#{attribute}"
      string = record.send(attribute)
      REDI_SEARCH.call('FT.SUGDEL', key, string)
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

    # size of dictionary
    #
    # @param attribute [String]
    # @return [Integer] - number of possible suggestions
    def ft_suglen (attribute:)
      key = "#{@model}:#{attribute}"
      REDI_SEARCH.call('FT.SUGLEN', key)
    rescue Exception => e
      Rails.logger.error e if defined? Rails
      return e.message
    end

  end

end
