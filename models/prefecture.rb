# frozen_string_literal: true

class Prefecture < ActiveYaml::Base
  include ActiveHash::Enum

  set_root_path 'config/master'
  set_filename name.underscore

  enum_accessor :type

  # NOTE: 案件の都道府県の選択肢にだけ「複数拠点」を含む
  class << self
    def for_user
      # NOTE: 「全国」「複数拠点」以外
      where.not(id: [find_by(name: '全国').id, find_by(name: '複数拠点').id])
    end

    # MN-multi_area
    def for_project
      # NOTE: 海外以外の選択肢で、「全国」「複数拠点」「都道府県」の順番に並べる
      prefectures = where(id: 1..47)
      [find_by(name: '全国'), find_by(name: '複数拠点'), prefectures].flatten
    end
  end
end
