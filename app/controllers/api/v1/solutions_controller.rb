class Api::V1::SolutionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user
  before_action :authorize_user_for_workshop

  def index
    if params[:my_filter]
      solutions_records = SolutionResponse
      .where(
        workshop_id: @workshop.id,
        user_id: @current_user.id
      )
    else
      solutions_records = SolutionResponse
      .where(workshop_id: @workshop.id)
      
      solutions_records = solutions_records.map do |sr|
        sr
        .as_json
        .merge!({
          my_solution_response_priority: SolutionResponsePriority.where(
            user_id: @current_user.id,
            workshop_id: @workshop.id,
            solution_response_id: sr.id
          ).first
        })
      end
    end

    return render :json => solutions_records
  end

  def create
    solutions_response = SolutionResponse
    .create(
      workshop_id: @workshop.id,
      user_id: @current_user.id,
      response_text: params[:response_text]
    )

    solutions_records = SolutionResponse
    .where(
      workshop_id: @workshop.id,
      user_id: @current_user.id
    )

    return render :json => solutions_records, status: 201
  end

  def update
    SolutionResponse
    .find(params[:id])
    .update(response_text: params[:response_text])

    solutions_records = SolutionResponse
    .where(
      workshop_id: @workshop.id,
      user_id: @current_user.id
    )

    return render :json => solutions_records
  end

  def prioritize
    solution_response_priority = SolutionResponsePriority
    .where(
      workshop_id: @workshop.id,
      user_id: @current_user.id,
      solution_response_id: params[:solution_id]
    )
    .first

    if solution_response_priority
      solution_response_priority
      .update(
        impact_level: params[:impact_level],
        effort_level: params[:effort_level]
      )
    else
      SolutionResponsePriority.create(
        workshop_id: @workshop.id,
        user_id: @current_user.id,
        solution_response_id: params[:solution_id],
        impact_level: params[:impact_level],
        effort_level: params[:effort_level]
      )
    end

    solutions_records = SolutionResponse
    .where(workshop_id: @workshop.id)

    solutions_records = solutions_records.map do |sr|
      sr
      .as_json
      .merge!({
        my_solution_response_priority: SolutionResponsePriority.where(
          user_id: @current_user.id,
          workshop_id: @workshop.id,
          solution_response_id: sr.id
        ).first
      })
    end

    return render :json => solutions_records, status: 201
  end

  def get_solutions_for_voting
    solutions_for_voting = SolutionResponse
    .get_solutions_for_voting(@current_user.id, @workshop.id)

    return render :json => solutions_for_voting
  end
end
