class WorkshopDirector < ApplicationRecord
  belongs_to :workshop
  belongs_to :workshop_stage
  belongs_to :workshop_stage_step

  def self.get_ordered(workshop_token)
    return Workshop
    .where(workshop_token: workshop_token)
    .first
    .workshop_directors
    .all
    .order(id: :asc)
  end

  def self.get_current(workshop_token)
    incomplete_director = Workshop
    .where(workshop_token: workshop_token)
    .first
    .workshop_directors
    .includes(:workshop_stage, :workshop_stage_step)
    .where(completed: false)
    .order(id: :asc)
    .first

    if !incomplete_director
      return Workshop
      .where(workshop_token: workshop_token)
      .first
      .workshop_directors
      .includes(:workshop_stage, :workshop_stage_step)
      .order(id: :asc)
      .last
    end

    return incomplete_director
  end
end
