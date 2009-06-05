#
#  VendingMachineUI.rb
#  vending
#
#  Created by Mario Aquino on 5/16/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

class VendingMachineUI
  attr_accessor :sale_items_view, :exact_change_button, :denomination_popup
  attr_accessor :amount_deposited_text, :dispensary_bin, :change_bin
  
  def awakeFromNib
    @vending_machine = VendingMachine.new 'password'
    
	  denomination_popup.removeAllItems
	  denomination_titles = Money::denominations.values.sort.map {|value| Money::token_for(value).to_s.capitalize }
	  denomination_popup.addItemsWithTitles denomination_titles
	  
    prices = @vending_machine.sale_prices_by_column
    prices.each_with_index do |pair, index|
      table_column = @sale_items_view.tableColumns[index]
      column_key = pair.first
      column_price = pair.last
      table_column.setIdentifier(column_key)
      table_column.headerCell.setStringValue "#{column_key} (#{column_price})"
    end
    
    dispensary = @dispensary_bin.tableColumns[0]
    dispensary.setIdentifier(:items)
    dispensary.headerCell.setStringValue "Dispensary Bin"

    # FIXME: This is only here temporarily until the service mode is hooked into the UI
  	@vending_machine.service 'password'
  	{a: :Doritos, b: :DingDongs, c: :MicrowaveHamburger}.each do |column, item|
  	  @vending_machine.stock column, *([item] * 3)
  	end
  	@vending_machine.activate_vending
  	
    @sale_items_view.dataSource = VendingTableItemsDataSource.new @vending_machine
    @dispensary_bin.dataSource = DispensaryBinItemsDataSource.new @vending_machine
    @change_bin.dataSource = ChangeBinItemsDataSource.new @vending_machine
    update_view
  end
  
  def column_a_selected(sender)
    make_selection :a
  end
  
  def column_b_selected(sender)
    make_selection :b
  end
  
  def column_c_selected(sender)
    make_selection :c
  end
  
  def deposit_money_clicked(sender)
    selected_denomination = denomination_popup.titleOfSelectedItem.upcase.to_sym
    value = Money.const_get selected_denomination
    @vending_machine.add_money value
    update_view
  end
  
  def cancel_sale_clicked(sender)
  	@vending_machine.cancel
  	update_view
  end
  
  private
  def update_view
    amount_deposited_text.setStringValue @vending_machine.money_deposited
    exact_change_needed = @vending_machine.exact_change_needed?
    button_state = exact_change_needed ? NSOnState : NSOffState
    exact_change_button.highlight exact_change_needed
    exact_change_button.setState button_state
  end
  
  def make_selection(column)
    @vending_machine.make_selection column
    [sale_items_view, dispensary_bin, change_bin].each{|table| table.reloadData}
    update_view
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

class DispensaryBinItemsDataSource
  def initialize(vending_machine)
    @vending_machine = vending_machine
  end
  
  def numberOfRowsInTableView(view)
    @vending_machine.dispensary.size
  end
  
  def tableView(view, objectValueForTableColumn:column, row:index)
    @vending_machine.dispensary[index]
  end
end

class ChangeBinItemsDataSource
  def initialize(vending_machine)
    @vending_machine = vending_machine
  end
  
  def numberOfRowsInTableView(view)
    @vending_machine.coin_return.size
  end
  
  def tableView(view, objectValueForTableColumn:column, row:index)
    @vending_machine.coin_return[index]
  end
end
