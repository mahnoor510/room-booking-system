class CreateBookingLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :booking_logs do |t|
      t.references :booking, null: false, foreign_key: true
      t.string :action, null: false

      t.timestamps
    end
  end
end
