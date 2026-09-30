require 'csv'

class BpsController < ApplicationController
  def index
  end

  def graph
    #
    #    CSV format
    #
    # PatientID,000000-0000
    # NO.,DATE,TIME,SYS,DIA,PLS
    # 1,13618/53/255,255:255:255,183,97,75
    #
    file = params[:file]
    unless file.respond_to?(:read)
      redirect_to bps_path, flash: { error: "Please select a CSV file to upload" }
      return
    end

    @data = file.read

    begin
      @datasingle = CSV.new(@data)
      @patientname = @datasingle.shift[1]

      @datatable = CSV.parse(@data,
                             headers: :second_row,
                             return_headers: false,
                             converters: :integer)

      @tablecol = @datatable.by_col!

      # Column arrays include the header cell as their first element
      @number = @tablecol[0].drop(1) # number
      @date = @tablecol[1].drop(1)   # date
      @time = @tablecol[2].drop(1)   # time
      @sys = @tablecol[3].drop(1)    # systolic
      @dia = @tablecol[4].drop(1)    # diastolic
      @hr = @tablecol[5].drop(1)     # pulse

      @hravg = (@hr.sum / @hr.length)
      @sysavg = (@sys.sum / @sys.length)
      @diaavg = (@dia.sum / @dia.length)
    rescue CSV::MalformedCSVError, NoMethodError, TypeError, ZeroDivisionError
      redirect_to bps_path, flash: { error: "Could not parse the CSV file" }
      return
    end

    # Gruff grapher
    g = Gruff::Line.new("1024x768")
    g.title = "#{@patientname} Avg: HR#{@hravg} | Sys#{@sysavg} | Dia#{@diaavg}"

    g.data("Systolic", @sys)
    g.data("Diastolic", @dia)
    g.data("Pulse", @hr)
    g.x_axis_label = "Time"
    send_data(g.to_blob, disposition: :inline, type: 'image/png', filename: "bp_#{@patientname}.png")
  end
end
