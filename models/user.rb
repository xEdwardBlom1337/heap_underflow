require_relative 'dbclass'

class User < DB

    set_table 'users'

    column 'id'
    column 'username'
    column 'password'
    column 'email'
    column 'karma'

    attr_reader :username, :email, :karma

    def self.insert(params)
        params['karma'] = 0
        params['password'] = BCrypt::Password.create(params['password'])
        super
    end

    def self.register(params)
        errors = []

        if exists?({username: params['username']})
            errors << "Username already taken"
        end
        if exists?({email: params['email']})
            errors << "Email already taken"
        end
        if params['password'] != params['password-confirmation']
            errors << "Passwords don't match"
        end
        if params['password'].length < 5
            errors << "Password must be at least five characters long"
        end
        if params['password'][/\d/].nil?
            errors << "Password must contain at least one numeric character"
        end
        if params['password'][/\p{L}/].nil?
            errors << "Password must contain at least one letter"
        end

        if errors.length == 0
            insert(params)
        end

        return errors
    end

    def self.login(params)
        user = select({username: params['username']})
        if user && BCrypt::Password.new(user['password']) == params['password']
            return user['id']
        else
            return nil
        end
    end

    def self.get(userid)
        self.new(select({id: userid}))
    end

end