#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module SpliceReports
  
  class ReportsController < ::ApplicationController

    def run_filter_by_id(filter_id)
      filter = SpliceReports::Filter.where(:id=>filter_id).first
      c = SpliceReports::MongoConn.new.get_coll_marketing_report_data()
      if filter[:status] == "all"
        filtered_systems = c.find().as_json
      elsif filter[:status] == "failed"
        filtered_systems = c.find({ :$or => [{:status => "invalid"}, {:status => "insufficient"}]}).as_json
      else
        filtered_systems = c.find({"status" => filter[:status]}).as_json
      end

      logger.info("Splice Reports, id = #{filter_id} filtered_systems: #{filtered_systems}")
      return filtered_systems
    end

    def get_num_summary(systems)
      num_current = 0
      num_invalid = 0
      num_insufficient = 0
      systems.each do | system | 
        case system["status"]
        when "current"
          num_current += 1
        when "invalid"
          num_invalid += 1
        when "insufficient" 
          num_insufficient += 1
        end
      end
      return {num_current: num_current, 
              num_invalid: num_invalid, 
              num_insufficient: num_insufficient,
              num_total: num_current + num_invalid + num_insufficient}
    end

    def rules
      read_system = lambda{System.find(params[:id]).readable?}
        {
          :show => lambda{true},
          :items => lambda{true}
        }

    end

    def show
      filtered_systems = run_filter_by_id(params[:id])
      summary = get_num_summary(filtered_systems)

      #render :partial => "reports/report"
      #render :partial => "report", :locals => {:report_invalid => @report_invalid, :report_valid => @report_valid}
      logger.info("Splice Reports id: #{params[:id]}, num_current = #{summary[:num_current]}, num_invalid = #{summary[:num_invalid]}, num_insufficient = #{summary[:num_insufficient]}")
      render 'show', :locals => {:filter_id => params[:id], 
                                  :num_current => summary[:num_current], 
                                  :num_invalid => summary[:num_invalid], 
                                  :num_insufficient => summary[:num_insufficient], 
                                  :num_total => summary[:num_total]}
    end

    def items
      filtered_systems = self.run_filter_by_id(params[:id])
      #debug
      #render :json=>{ :subtotal => 1, :total=>1, :systems=> [c.find_one]  }
      render :json=>{ :subtotal => 1, :total=>1, :systems=> filtered_systems  }
    end

  end 

end
