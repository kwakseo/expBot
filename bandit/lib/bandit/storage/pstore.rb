module Bandit
  class PstoreStorage < BaseStorage
    def initialize(config)
      if config[:use_yaml_store]
        require 'yaml/store'
        @store = YAML::Store.new(config[:file] || 'bandit.yamlstore')
      else
        require 'pstore'
        @store = PStore.new(config[:file] || 'bandit.pstore')
      end
    end

    def getAlt(key)
      retValue = []

      @store.transaction do
        @store.roots.each do |variable| 
          unless variable.start_with?("participants:") or variable.start_with?("altstarted:") or variable.start_with?("conversions:") or variable.start_with?("::") 
            if variable.start_with?(key)
              retValue << variable
            end
          end
        end
      end

      retValue
    end

    def addAlt(key, alt)
      @store.transaction do
        @store[key+"#"+alt] = 1
      end
    end
    
    def addValue(inx, val)
      @store.transaction do
        if @store[inx].nil?
          @store[inx] = [val]
        else 
          @store[inx] << val
        end
      end
    end
    def getValue(inx)
      retValue = []
     @store.transaction do
      retValue = @store[inx]
     end
     retValue
     end

    def getResArray()
      retValue = []
     @store.transaction do
      retValue = @store['::res']
     end
     retValue
    end

    def addRes(res)
      @store.transaction do
        if @store['::res'].nil?
          @store['::res'] = [res]
        else 
          @store['::res'] << res
        end
      end
    end

    # increment key by count
    def incr(key, count=1)
      @store.transaction do
        unless @store[key].nil?
          @store[key] = @store[key] + count
        else
          @store[key] = count
        end
      end
    end

    # initialize key if not set
    def init(key, value)
      @store.transaction do
        @store[key] = value if @store[key].nil?
      end
    end

    # get key if exists, otherwise 0
    def get(key, default=0)
      @store.transaction(true) do
        @store[key] || default
      end
    end

    # set key with value, regardless of whether it is set or not
    def set(key, value)
      @store.transaction do
        @store[key] = value
      end
    end

    def clear!
      @store.transaction do
        @store.roots.each do |key|
          @store.delete(key)
        end
      end
    end
  end
end
