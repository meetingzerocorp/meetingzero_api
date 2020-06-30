class Api::V1::WorkshopsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user
  before_action :authorize_user_for_workshop, only: [:show]

  def create
    ActiveRecord::Base.transaction do
      begin
        new_workshop = Workshop.create(
          host_id: @current_user.id,
          purpose: params[:purpose]
        )

        workshop_stage_keys = []

        if params[:template]
          template = WorkshopTemplate
          .where(key: params[:template])
          .first

          template_stages = WorkshopTemplateStage
          .where(workshop_template_id: template.id)

          template_stages.each do |template_stage|
            workshop_stage = WorkshopStage.find(template_stage.workshop_stage_id)

            workshop_stage_keys.push(workshop_stage.key)
          end
        else
          workshop_stage_keys = params[:workshop_stage_keys]
        end

        workshop_stage_keys.each do |workshop_stage_key|
          workshop_stage = WorkshopStage
          .where(key: workshop_stage_key)
          .first

          WorkshopStageStep
          .where(workshop_stage_id: workshop_stage.id)
          .each do |workshop_stage_step|
            WorkshopDirector
            .create(
              workshop_id: new_workshop.id,
              workshop_stage_id: workshop_stage.id,
              workshop_stage_step_id: workshop_stage_step.id
            )
          end
        end

        emails = params[:emails]

        emails.each do |email|
          user = User
          .where(email: email)
          .first

          if user
            WorkshopMember
            .create(
              workshop_id: new_workshop.id,
              user_id: user.id
            )

            WorkshopMailer
            .join_workshop(user, @current_user, new_workshop)
            .deliver_later
          else
            WorkshopMailer
            .join_workshop_new_user(email, @current_user, new_workshop)
            .deliver_later
          end
        end

        # Add host to member list
        WorkshopMember
        .create(
          workshop_id: new_workshop.id,
          user_id: @current_user.id
        )

        return render :json => new_workshop, status: 201
      rescue
        render :json => { error: ["could not create workshop"] }, status: 400
        raise ActiveRecord::Rollback
      end
    end
  end

  def show
    workshop = Workshop
    .where(workshop_token: params[:id])
    .first

    return render :json => workshop
  end

  private

  def authorize_user_for_workshop
    workshop = Workshop
    .where(workshop_token: params[:id])
    .first

    workshop_member = WorkshopMember
    .where(
      user_id: @current_user.id,
      workshop_id: workshop.id
    )
    .first

    if !workshop_member
      return render :json => { error: ["user is not part of this workshop"] }, status: 401
    end
  end
end