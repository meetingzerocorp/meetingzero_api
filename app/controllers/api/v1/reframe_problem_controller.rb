class Api::V1::ReframeProblemController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user
  before_action :authorize_user_for_workshop

  def index
    if params[:my_filter]
      reframe_problem_record = ReframeProblemResponse
      .where(
        workshop_id: @workshop.id,
        user_id: @current_user.id
      )
      .first
    else
      reframe_problem_record = ReframeProblemResponse
      .where(workshop_id: @workshop.id)
    end

    return render :json => reframe_problem_record
  end

  def create
    reframe_problem_response = ReframeProblemResponse
    .create(
      workshop_id: @workshop.id,
      user_id: @current_user.id,
      response_text: params[:response_text]
    )

    return render :json => reframe_problem_response, status: 201
  end

  def update
    ReframeProblemResponse
    .find(params[:id])
    .update(response_text: params[:response_text])

    reframe_problem_record = ReframeProblemResponse
    .where(
      workshop_id: @workshop.id,
      user_id: @current_user.id
    )
    .first

    return render :json => reframe_problem_record
  end
end
