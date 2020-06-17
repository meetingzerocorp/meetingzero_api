class CreateWorkshops < ActiveRecord::Migration[6.0]
  def change
    create_table :workshops do |t|
      t.string :workshop_token
      t.integer :host_id
      t.text :purpose

      t.timestamps
    end
  end
end
