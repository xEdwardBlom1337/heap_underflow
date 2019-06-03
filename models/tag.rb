require_relative 'dbclass'

class Tag < DB
    
    set_table 'tags'

    column 'id'
    column 'name'

    attr_reader :id, :name

    def initialize(dbout)
        @id = dbout['id']
        @name = dbout['name']
    end

end