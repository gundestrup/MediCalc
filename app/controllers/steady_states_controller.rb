class SteadyStatesController < ApplicationController
  def index
    if params[:name].present? && params[:admin].present? && params[:half].present?
      # Dosage calculation
      admin = params[:admin].to_f
      number = params[:number].to_i
      half = params[:half].to_f
      name = params[:name]

      konc = [admin]
      number.times do
        konc.push(admin + (konc.last * (0.5**(1 / half))))
      end

      # Graph drawing
      g = Gruff::Line.new
      g.title = name
      g.data(name, konc)
      g.labels = { 0 => '0', 5 => '5', 10 => '10', 15 => '15', 20 => '20', 25 => '25', 30 => '30', 40 => '40', 50 => '50' }
      g.x_axis_label = "Time"
      g.y_axis_label = "Koncentration"
      send_data(g.to_blob, filename: "StadyState_#{name}.png", type: "image/png", disposition: :inline)
    end
  end
end
