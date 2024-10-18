class Department < ApplicationRecord
  has_many :department_users, dependent: :nullify
  has_many :users, through: :department_users

  default_scope { order(:code) }

  def self.ransackable_attributes(auth_object = nil)
    [
      "code",
      "code_region",
      "created_at",
      "id",
      "id_value",
      "name",
      "name_region",
      "updated_at"
    ]
  end

  def label = none? ? name : code_name_region

  def short_label = none? ? name : code_name

  def self.regions = Department.all.group_by(&:name_region)

  def self.none = Department.find_or_create_by!(code: "00", name: "Aucun")

  private

  def none? = code == "00"

  def code_name_region = "#{code} #{name} - #{name_region}"

  def code_name = "#{code} #{name}"
end

# == Schema Information
#
# Table name: departments
#
#  id          :uuid             not null, primary key
#  code        :string
#  code_region :string
#  name        :string
#  name_region :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
