#
#  VendingMachineUI.rb
#  vending
#
#  Created by Mario Aquino on 5/16/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#
require 'vending'

class VendingMachineUI
  attr_accessor :column_a, :column_b, :column_c, :table_view
  
  def awakeFromNib
    @vending_machine = VendingMachine.new 'password'
    
    prices = @vending_machine.sale_prices_by_column
    prices.each_with_index do |pair, index|
      table_column = @table_view.tableColumns[index]
      column_key = pair.first
      column_price = pair.last
      table_column.setIdentifier(pair[0])
      table_column.headerCell.setStringValue "#{column_key} (#{column_price})"
    end
    
  	@vending_machine.service 'password'
  	{a: :Doritos, b: :DingDongs, c: :MicrowaveHamburger}.each do |column, item|
  	  @vending_machine.stock column, *([item] * 3)
  	end
  	@vending_machine.activate_vending
  	
    @table_view.dataSource = VendingTableItemsDataSource.new @vending_machine
  end
end


class VendingTableItemsDataSource
  def initialize(vending_machine)
    @vending_machine = vending_machine
  end

  def numberOfRowsInTableView(view)
    @vending_machine.sale_items_by_column.size
  end

  def tableView(view, objectValueForTableColumn:column, row:index)
	  items = @vending_machine.sale_items_by_column[column.identifier]	  
	  items[index]
  end
end
