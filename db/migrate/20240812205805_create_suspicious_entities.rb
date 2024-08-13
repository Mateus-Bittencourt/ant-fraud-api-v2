class CreateSuspiciousEntities < ActiveRecord::Migration[7.1]
  def change
    create_table :suspicious_devices do |t|
      t.integer :device_id
      t.timestamps
    end

    create_table :suspicious_merchants do |t|
      t.integer :merchant_id
      t.timestamps
    end
    create_table :suspicious_users do |t|
      t.integer :user_id
      t.timestamps
    end
  end
end
