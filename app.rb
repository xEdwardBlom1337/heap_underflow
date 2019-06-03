require_relative 'models/user'
require_relative 'models/question'
require_relative 'models/tag'
require_relative 'models/tagging'
require 'rack-flash'

class App < Sinatra::Base

    enable :sessions
    use Rack::Flash

    before do
        if session[:user_id]
            @current_user = User.get(session[:user_id])
        else
            @current_user = nil
        end
    end
    
    get '/' do
        slim :'index'
    end
    
    get '/question' do
        slim :'question'
    end
    
    post '/question' do
        errors = Question.ask(params, session[:user_id])
        if errors.any?
            flash[:errors] = errors
            redirect '/question'
        end

        redirect '/'
    end

    get '/questions' do
        @questions = Question.get_all

        slim :'questions'
    end

    get '/questions/:id' do
        

        slim :'questions'
    end

    get '/login' do
        slim :'login'
    end

    get '/signup' do
        slim :'signup'
    end
    
    post '/signup' do
        errors = User.register(params)
        if errors.any?
            flash[:errors] = errors
            redirect '/signup'
        end
        redirect '/login'
    end

    post '/login' do
        session[:user_id] = User.login(params)
        if session[:user_id] == nil
            flash[:errors] = ["Wrong username or password"]
            redirect '/login'
        end

        redirect '/'
    end

    post '/logout' do
        session.destroy
        redirect '/'
    end

end