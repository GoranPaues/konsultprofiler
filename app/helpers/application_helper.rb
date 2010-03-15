# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def ranking_pairs
    [['Nybörjare', 1], ['Erfaren', 2], ['Mycket erfaren', 3], ['Expert', 4], ['Guru', 5]]
  end
  
  def ranking_presentation value
    ranking_pairs.rassoc(value).first
  end

  # These two functions are taken from railscasts. They are explained here:
  # http://media.railscasts.com/videos/197_nested_model_form_part_2.mov
  # Note that most of tje Ajax logic i in the file 'application.js'
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end
  
  def chained_skill_selects_for model, relation
    select_tag(:category_id, 
      	options_for_select(["Välj kategori"] + SkillCategory.all(:order => 'name').collect {|c| [c.name, c.id]}),
      	:onchange => remote_function(:update => "new_#{relation}_skills", 
      	                             :url => skill_selector_path, 
      	                             :with => 'Form.Element.serialize(this)')) +
    select_tag("new_#{relation}_skills", options_for_select(["Välj kategori först"]), 
		    :name => "#{model}[#{relation}_attributes][new_#{relation}][skill_id]")
  end

  def swedish_date_select(f, association)
    f.date_select association, :discard_day => true,
      :use_month_names => %w{Jan Feb Mar Apr Maj Jun Jul Aug Sep Okt Nov Dec}
  end
  
  def standard_links
    links = []
    links.push(link_to 'Alla profiler', profiles_path) if !current_page?(profiles_path)
    links.push(link_to 'Sök profil', new_search_path) if current_user && !current_page?(new_search_path)
    links.push(link_to 'Kompetenser', skills_path) if admin? && !current_page?(skills_path)
    links.push(link_to 'Användare', users_path) if admin? && !current_page?(users_path)
    links
  end
end
