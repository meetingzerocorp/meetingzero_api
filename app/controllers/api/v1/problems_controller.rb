class Api::V1::ProblemsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user
  before_action :authorize_user_for_workshop

  def index
    if params[:my_filter]
      problems_records = ProblemResponse
      .where(
        workshop_id: @workshop.id,
        user_id: @current_user.id
      )
      .order(id: :asc)
    else
      problems_records = ProblemResponse
      .where(workshop_id: @workshop.id)
      .order(id: :asc)
    end

    problems_records = problems_records.map do |pr|
      pr
      .as_json
      .merge!({
        star_voting_vote: StarVotingVote.where(
          user_id: @current_user.id,
          workshop_id: @workshop.id,
          resource_model_name: "ProblemResponse",
          resource_id: pr.id
        ).first
      })
    end

    return render :json => problems_records
  end

  def create
    problems_response = ProblemResponse
    .create(
      workshop_id: @workshop.id,
      user_id: @current_user.id,
      response_text: params[:response_text]
    )

    problems_records = ProblemResponse
    .where(
      workshop_id: @workshop.id,
      user_id: @current_user.id
    )

    return render :json => problems_records, status: 201
  end

  def update
    ProblemResponse
    .find(params[:id])
    .update(response_text: params[:response_text])

    problems_records = ProblemResponse
    .where(
      workshop_id: @workshop.id,
      user_id: @current_user.id
    )

    return render :json => problems_records
  end
end
