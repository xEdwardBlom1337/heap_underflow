require 'byebug'

class DB
    def self.db
        @db ||= SQLite3::Database.new('db.db')
        @db.results_as_hash ||= true
        
        return @db
    end
    
    def self.set_table(tablename)
        @table = tablename
    end
    
    def self.column(column)
        @columns ||= []
        @columns << column
        attr_reader column.to_sym
    end
    
    def self.get_columns
        return @columns
    end

    def initialize(dbout)
        dbout.each do |key, value|
            key = key.gsub(/(#{self.class.to_s})\./, "")
            if self.class.get_columns.include?(key)
                instance_variable_set("@#{key}".to_sym, value)
            end
        end
    end
    
    def self.execute(*args)
        self.db.execute(*args)
    end
    
    def self.count(hash)
        return execute("SELECT count(*) FROM #{@table} WHERE #{hash.keys[0]}=?", hash.values)[0][0]
    end
    
    def self.exists?(hash)
        return count(hash) > 0
    end

    def self.insert(hash)
        execute("INSERT INTO #{@table} (#{@columns.join(",")}) 
        VALUES (#{(@columns.map do |q| "?" end).join(",")})",
        (@columns.map do |c| hash[c] end))
    end

    # Question.select({}) {{join: 'tags', through: 'taggings'}}
    def self.select(hash={})
        if block_given?
            block_hash = yield
            query = ""
            tables = {self => @columns}

            if block_hash[:join] && block_hash[:through]
                tables[classify_string(block_hash[:join])] = classify_string(block_hash[:join]).get_columns
                tables[classify_string(block_hash[:through])] = classify_string(block_hash[:through]).get_columns

                as_string = ""
                tables.each do |table, columns|
                    columns.each do |c|
                        as_string += "#{(table.to_s + "s").downcase}.#{c} as \"#{table.to_s}.#{c}\", "
                    end
                end
                as_string = as_string[0..-3]
                query += "SELECT #{as_string} FROM #{@table}
                INNER JOIN #{block_hash[:through]} ON 
                #{block_hash[:through]}.#{@table[0..-2]}_id = #{@table}.id
                INNER JOIN #{block_hash[:join]} ON 
                #{block_hash[:through]}.#{block_hash[:join][0..-2]}_id = #{block_hash[:join]}.id"
            elsif block_hash[:join]
                tables[block_hash[:join]] = classify_string(block_hash[:join]).get_columns
                
                query += "SELECT * FROM #{@table}
                INNER JOIN #{block_hash[:join]} ON 
                #{@table}.#{block_hash[:join][0..-2]}_id = #{block_hash[:join]}.id"
            end
            if hash.keys.length == 1
                query += " WHERE #{@table}.#{hash.keys[0]} = #{hash.values[0]}"
            end

            return execute(query)
        else
            return execute("SELECT * FROM #{@table} WHERE #{hash.keys[0]}=?", hash.values)[0]
        end
    end

    private
    def self.classify_string(table_str)
        return Object.const_get(table_str.to_s[0..-2].capitalize)
    end

end
