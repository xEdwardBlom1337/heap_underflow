require_relative 'dbclass'
require_relative 'tagging'

class Question < DB

    set_table 'questions'

    column 'id'
    column 'user_id'
    column 'title'
    column 'content'
    column 'votes'

    attr_reader :id, :user, :title, :content, :votes, :tags

    def initialize(dbout)
        if dbout.key?("tags")
            @tags = dbout["tags"].map {|t| Tag.new(Tag.select({'name': t}))}
        end
        super
        @user = User.new(User.select({'id': @user_id}))
    end

    def self.insert(params, user_id)
        params['votes'] = 0
        params['user_id'] = user_id
        super(params)
    end

    def self.ask(params, user_id)
        errors = []

        if exists?({title: params['title']})
            errors << "A question with this title already exists"
        end

        if errors.length == 0
            insert(params, user_id)
            question = select({title: params['title']})
            tags = params['tags'].gsub(/\s+/m, ' ').strip.split(" ")
            tags.each do |tag|
                if !Tag.exists?(name: tag)
                    Tag.insert({'name' => tag})
                end
                Tagging.insert({'question_id' => question['id'], 'tag_id' => Tag.select({name: tag})['id']})
            end
        end

        return errors
    end

    def self.get_all
        dbout = self.select {{join: 'tags', through: 'taggings'}}

        tag_hash = {}
        dbout.each do |q|
            if !tag_hash.key?(q['Question.id'])
                tag_hash[q['Question.id']] = [q['Tag.name']]
            else
                tag_hash[q['Question.id']] << q['Tag.name']
            end
        end
        
        questions = []

        tag_hash.each do |key, value|
            tmp = dbout.detect {|q| q['Question.id'] == key}
            tmp['tags'] = value
            questions << tmp
        end

        questions.map! {|q| Question.new(q)}

        return questions
    end

end
