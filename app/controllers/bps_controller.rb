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
    @data = params[:dump][:file]
    @datasingle = CSV.new(params[:dump][:file])
    @patientname = @datasingle.shift[1]

    @datatable = CSV.parse(@data,
                           headers: :second_row,
                           return_headers: false,
                           converters: :integer)

    @tablecol = @datatable.by_col!

    @number = @tablecol[0] # number
    @date = @tablecol[1]   # date
    @time = @tablecol[2]   # time
    @sys = @tablecol[3]    # systolic
    @dia = @tablecol[4]    # diastolic
    @hr = @tablecol[5]     # pulse

    @hravg = (@hr.sum / @hr.length)
    @sysavg = (@sys.sum / @sys.length)
    @diaavg = (@dia.sum / @dia.length)

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
