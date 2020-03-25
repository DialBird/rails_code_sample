# frozen_string_literal: true

# == Schema Information
#
# Table name: carriers # 職歴
#
#  id          :bigint(8)        not null, primary key
#  detail      :text             default(""), not null    # 業務内容
#  end_month   :integer                                   # 終了月
#  end_year    :integer                                   # 終了年
#  is_employed :boolean          default(FALSE), not null # 在職中フラグ
#  start_month :integer                                   # 開始月
#  start_year  :integer                                   # 開始年
#  title       :string           default(""), not null    # 会社名・プロジェクト名
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  pro_info_id :bigint(8)
#
# Indexes
#
#  index_carriers_on_pro_info_id  (pro_info_id)
#
# Foreign Keys
#
#  fk_rails_...  (pro_info_id => pro_infos.id)
#

class Carrier < ApplicationRecord
  ATTRIBUTES = %i[
    id _destroy title detail is_employed
    start_year end_year start_month end_month
  ].freeze

  belongs_to :pro_info

  validates :title, presence: true
  validate :end_year_and_month_should_be_together
  validate :start_should_be_earlier_than_end
  validate :start_year_and_month_should_be_together

  private

  def end_year_and_month_should_be_together
    return if (!end_year && !end_month) || (end_year && end_month)

    errors.add(:base, '終了年と月を両方入力してください')
  end

  def start_should_be_earlier_than_end
    return unless start_year.present? && start_month.present? && end_year.present? && end_month.present?

    start_time = Date.new(start_year, start_month)
    end_time = Date.new(end_year, end_month)
    return if start_time <= end_time

    errors.add(:base, '開始年月と終了年月を正しく入力してください')
  end

  def start_year_and_month_should_be_together
    return if (!start_year && !start_month) || (start_year && start_month)

    errors.add(:base, '開始年と月を両方入力してください')
  end
end
