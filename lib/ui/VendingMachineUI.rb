#
#  VendingMachineUI.rb
#  vending
#
#  Created by Mario Aquino on 5/16/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

class VendingMachineUI
  attr_accessor :table_view, :exact_change_button, :denomination_popup
  attr_accessor :amount_deposited_text
  
  def awakeFromNib
    @vending_machine = VendingMachine.new 'password'
    
    #exact_change_button.setEnabled false
	  
    amount_deposited_text.setStringValue @vending_machine.money_deposited
	  
	  denomination_popup.removeAllItems
	  
	  denomination_titles = Money::denominations.values.sort.map {|value| Money::token_for(value).to_s.capitalize }
	  
	  denomination_popup.addItemsWithTitles denomination_titles
	  
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
  
  def column_a_selected(sender)
    puts "Select A clicked"
  end
  
  def column_b_selected(sender)
  end
  
  def column_c_selected(sender)
  end
  
  def deposit_money_clicked(sender)
    selected_denomination = denomination_popup.titleOfSelectedItem.upcase.to_sym
    value = Money.const_get selected_denomination
    @vending_machine.add_money value
    amount_deposited_text.setStringValue @vending_machine.money_deposited
  end
  
  def cancel_sale_clicked(sender)
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
