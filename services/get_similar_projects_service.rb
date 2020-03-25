# frozen_string_literal: true

# WHAT_FOR
# 引数に渡した案件と職種カテゴリが近い職種を新着順に検索して返す
# Queryにしなかったのは「配列」を返すから

class GetSimilarProjectsService
  attr_reader :project

  def initialize(project)
    @project = project
  end

  # NOTE: 案件の「小カテゴリ職種」と一致する案件の次に、「大カテゴリ職種」と一致する案件の順番で返す
  def call
    small_profession_ids = project.project_professions.pluck(:profession_id)
    project_categories = project.project_professions.map { |pp| Profession.find(pp.profession_id).category }.uniq
    big_profession_ids = project_categories.map { |pc| pc.professions.ids }.flatten - small_profession_ids

    former_projects = Project.opened
                             .where.not(id: project.id)
                             .joins(:project_professions)
                             .merge(ProjectProfession.where(profession_id: small_profession_ids))
                             .distinct
                             .order(application_open_at: :desc, id: :desc)
    latter_projects = Project.opened
                             .where.not(id: project.id)
                             .joins(:project_professions)
                             .merge(ProjectProfession.where(profession_id: big_profession_ids))
                             .distinct
                             .order(application_open_at: :desc, id: :desc)
    # 重複をなくす
    latter_projects -= former_projects
    former_projects + latter_projects
  end
end
