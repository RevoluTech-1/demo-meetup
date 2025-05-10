class CreateModelExes < ActiveRecord::Migration[8.0]
  def change
    create_table :model_exes do |t|
      t.string :name
      t.timestamps
    end
  end
end
