require_relative 'dbclass'

class Tagging < DB
    
    set_table 'taggings'

    column 'question_id'
    column 'tag_id'

    # TOOOOODDDDOOOOOO: MAKE REFAKTOR JAA
    def self.get_tags_by(question_id)
        tags = execute("
            SELECT tags.name
            FROM tagging
            INNER JOIN tags
            ON tags.id = tagging.tag_id
            WHERE tagging.question_id = #{question_id}
        ")

        tags.map! { |t| t['name'] }
        
        return tags
    end

    def self.get_questions_by(tag_id)
        return execute("
            SELECT questions.id, users.username, questions.title, questions.content, questions.votes
            FROM taggings
            INNER JOIN questions
            ON questions.id = taggings.question_id
            INNER JOIN users
            ON users.id = questions.user_id
            WHERE tagging.tag_id = #{tag_id}
        ")
    end

    # Question.select({user_id: 3}) {{join: 'tags', through: 'tagging'}}
    def self.get_all_questions
        db_questions = execute("
            SELECT questions.id, users.username, questions.title, questions.content, questions.votes
            FROM questions
            INNER JOIN users
            ON questions.user_id = users.id
        ")
        p db_questions
        db_questions.map! { |q| Question.new(q) }
        questions = []
        db_questions.each do |q|
            tags = get_tags_by q.id
            questions << { "question" => q, "tags" => tags.map {|t| Tag.new(t)} }
        end

        return questions
    end

end