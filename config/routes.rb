require "resque/server"

Rails.application.routes.draw do
  mount Resque::Server.new, :at => "/resque"

  namespace :api do
    namespace :v1 do
      resources :email_submissions

      resources :users do
        collection do
          post "/login" => "users#login"
          get "/me" => "users#me"
          post "/forgot-password" => "users#forgot_password"
          post "/reset-password" => "users#reset_password"
        end
      end

      resources :workshops do
        get "/members" => "workshops#members"
        put "/start" => "workshops#start_workshop"
        post "/validate" => "workshops#validate"
        put "/complete-step" => "workshops#complete_step"
        get "/summary" => "workshops#summary"

        resources :director, controller: :workshop_directors do
          resources :workshop_stage_step_ready, except: [:destroy] do
            collection do
              delete "/" => "workshop_stage_step_ready#destroy"
            end
          end

          collection do
            get "/current" => "workshop_directors#current"
            put "/add_time_to_current" => "workshop_directors#add_time_to_current"
          end
        end

        resources :what_is_working

        resources :problems

        resources :reframe_problem

        resources :opportunity_question

        resources :solutions do
          post "/prioritize" => "solutions#prioritize"

          collection do
            get "/voting" => "solutions#get_solutions_for_voting"
          end
        end

        resources :experiments do
          collection do
            get "/hypothesis" => "experiments#get_hypothesis"
            post "/hypothesis" => "experiments#save_hypothesis"

            get "/tasks" => "experiments#get_tasks"
            post "/tasks" => "experiments#save_task"
            put "/tasks/:task_id" => "experiments#update_task"
            delete "/tasks/:task_id" => "experiments#destroy_task"
            post "/tasks/:task_id/assignments" => "experiments#assign_task"
          end
        end

        resources :star_voting_votes do
          collection do
            post "/calculate-votes" => "star_voting_votes#calculate_votes"
          end
        end

        resources :star_voting_results, only: [:create]
      end
    end
  end

  resources :users, only: [] do
    collection do
      get "/activate-account" => "users#activate_account"
    end
  end
end
