module SimpleRecord

    #
    # We need to make this behave as if the full set were loaded into the array.
    class ResultsArray
        include Enumerable

        attr_reader :next_token, :clz, :params, :items, :i


        def initialize(clz=nil, params=[], items=[], next_token=nil)
            @clz = clz
            #puts 'class=' + clz.inspect
            @params = params
            @items = items
            @next_token = next_token
            @i = 0
        end

        def << (val)
            @items << val
        end

        def [](*i)
            # todo: load items up to i if size > i
            @items[*i]
        end

        def first
            @items[0]
        end

        def last
            @items[@items.length-1]
        end

        def empty?
            @items.empty?
        end

        def include?(obj)
            @items.include?(obj)
        end

        def size
            # puts 'SIZE count=' + @count.inspect
            return @count if @count
            params_for_count = params.dup
            params_for_count[0] = :count
            #puts 'params_for_count=' + params_for_count.inspect
            @count = clz.find(*params_for_count)
            # puts '@count=' + @count.to_s
            @count
        end

        def length
            return size
        end

        def each(&blk)
            limit = nil
            if params.size > 1
                options = params[1]
                limit = options[:limit]
            else
                options = {}
                params[1] = options
            end

            @items.each do |v|
                #puts @i.to_s
                yield v
                @i += 1
                if !limit.nil? && @i >= limit
                    return
                end
            end
            # no more items, but is there a next token?
            return if clz.nil?

            unless next_token.nil?
                #puts 'finding more items...'
                #puts 'params in block=' + params.inspect
                options[:next_token] = next_token
                res = clz.find(*params)
                items = res.items # get the real items array from the ResultsArray
                items.each do |item|
                    @items << item
                end
                @next_token = res.next_token
                each(&blk)
            end
        end

        def delete(item)
            @items.delete(item)
        end

        def delete_at(index)
            @items.delete_at(index)
        end

    end
end

