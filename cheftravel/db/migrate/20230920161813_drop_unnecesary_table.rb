# frozen_string_literal: true

class DropUnnecesaryTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :receipt
  end
end
