class CreateTokenRevs < ActiveRecord::Migration[8.0]
  def change
    create_table :token_revs do |t|
      t.string :val

      t.timestamps
    end
  end
end
