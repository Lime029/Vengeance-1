#===============================================================================
# The Bag object, which actually contains all the items
#===============================================================================
class PokemonBag
    attr_accessor :lastpocket
  
    def self.pocketNames
      return Settings.bag_pocket_names
    end
  
    def self.numPockets
      return self.pocketNames.length-1
    end
  
    def initialize
      @lastpocket = 1
      @pockets    = []
      @choices    = []
      for i in 0..PokemonBag.numPockets
        @pockets[i] = []
        @choices[i] = 0
      end
      @registeredItems = []
      @registeredIndex = [0, 0, 1]
    end
  
    def rearrange
      if (@pockets.length - 1) != PokemonBag.numPockets
        newpockets = []
        for i in 0..PokemonBag.numPockets
          newpockets[i] = []
          @choices[i] = 0 if !@choices[i]
        end
        num_pockets = PokemonBag.numPockets
        for i in 0...[@pockets.length, num_pockets].min
          for item in @pockets[i]
            p = GameData::Item.get(item[0]).pocket
            newpockets[p].push(item)
          end
        end
        @pockets = newpockets
      end
    end
  
    def clear
      @pockets.each { |pocket| pocket.clear }
    end
  
    def pockets
      rearrange
      return @pockets
    end
  
    def maxPocketSize(pocket)
      maxsize = Settings::BAG_MAX_POCKET_SIZE[pocket]
      return -1 if !maxsize
      return maxsize
    end
  
    # Gets the index of the current selected item in the pocket
    def getChoice(pocket)
      if pocket <= 0 || pocket > PokemonBag.numPockets
        raise ArgumentError.new(_INTL("Invalid pocket: {1}", pocket.inspect))
      end
      rearrange
      return [@choices[pocket], @pockets[pocket].length].min || 0
    end
  
    # Sets the index of the current selected item in the pocket
    def setChoice(pocket,value)
      if pocket <= 0 || pocket > PokemonBag.numPockets
        raise ArgumentError.new(_INTL("Invalid pocket: {1}", pocket.inspect))
      end
      rearrange
      @choices[pocket] = value if value <= @pockets[pocket].length
    end
  
    def getAllChoices
      ret = @choices.clone
      for i in 0...@choices.length
        @choices[i] = 0
      end
      return ret
    end
  
    def setAllChoices(choices)
      @choices = choices
    end
  
    def pbQuantity(item)
      item = GameData::Item.get(item)
      pocket = item.pocket
      return ItemStorageHelper.pbQuantity(@pockets[pocket], item.id)
    end
  
    def pbHasItem?(item)
      return pbQuantity(item) > 0
    end
  
    def pbCanStore?(item, qty = 1)
      item = GameData::Item.get(item)
      pocket = item.pocket
      maxsize = maxPocketSize(pocket)
      maxsize = @pockets[pocket].length + 1 if maxsize < 0
      return ItemStorageHelper.pbCanStore?(
         @pockets[pocket], maxsize, Settings::BAG_MAX_PER_SLOT, item.id, qty)
    end
  
    def pbStoreItem(item, qty = 1)
      item = GameData::Item.get(item)
      if $game_switches[111] # No healing items in battle
        case item
        when :POTION
          item = :POTION1
        when :SUPERPOTION
          item = :SUPERPOTION1
        when :HYPERPOTION
          item = :HYPERPOTION1
        when :ULTRAPOTION
          item = :ULTRAPOTION1
        when :MAXPOTION
          item = :MAXPOTION1
        when :FULLRESTORE
          item = :FULLRESTORE1
        when :AWAKENING
          item = :AWAKENING1
        when :ANTIDOTE
          item = :ANTIDOTE1
        when :BURNHEAL
          item = :BURNHEAL1
        when :PARALYZEHEAL
          item = :PARALYZEHEAL1
        when :ICEHEAL
          item = :ICEHEAL1
        when :FULLHEAL
          item = :FULLHEAL1
        when :LAVACOOKIE
          item = :LAVACOOKIE1
        when :OLDGATEAU
          item = :OLDGATEAU1
        when :PEWTERCRUNCHIES
          item = :PEWTERCRUNCHIES1
        when :CASTELIACONE
          item = :CASTELIACONE1
        when :REVIVE
          item = :REVIVE1
        when :MAXREVIVE
          item = :MAXREVIVE1
        when :BERRYJUICE
          item = :BERRYJUICE1
        when :RAGECANDYBAR
          item = :RAGECANDYBAR1
        when :SWEETHEART
          item = :SWEETHEART1
        when :FRESHWATER
          item = :FRESHWATER1
        when :SODAPOP
          item = :SODAPOP1
        when :LEMONADE
          item = :LEMONADE1
        when :MOOMOOMILK
          item = :MOOMOOMILK1
        when :ENERGYPOWDER
          item = :ENERGYPOWDER1
        when :ENERGYROOT
          item = :ENERGYROOT1
        when :HEALPOWDER
          item = :HEALPOWDER1
        when :REVIVALHERB
          item = :REVIVALHERB1
        when :ETHER
          item = :ETHER1
        when :MAXETHER
          item = :MAXETHER1
        when :ELIXIR
          item = :ELIXIR1
        when :MAXELIXIR
          item = :MAXELIXIR1
        when :CHERIBERRY
          item = :CHERIBERRY1
        when :CHESTOBERRY
          item = :CHESTOBERRY1
        when :PECHABERRY
          item = :PECHABERRY1
        when :RAWSTBERRY
          item = :RAWSTBERRY1
        when :ASPEARBERRY
          item = :ASPEARBERRY1
        when :LEPPABERRY
          item = :LEPPABERRY1
        when :ORANBERRY
          item = :ORANBERRY1
        when :LUMBERRY
          item = :LUMBERRY1
        when :SITRUSBERRY
          item = :SITRUSBERRY1
        when :BIGMALASADA
          item = :BIGMALASADA1
        when :BLUEMOONICECREAM
          item = :BLUEMOONICECREAM1
        when :VANILLAICECREAM
          item = :VANILLAICECREAM1
        when :CHOCOLATEICECREAM
          item = :CHOCOLATEICECREAM1
        when :STRAWBERRYICECREAM
          item = :STRAWBERRYICECREAM1
        when :COFFEE
          item = :COFFEE1
        when :PERSIMBERRY
          item = :PERSIMBERRY1
        when :KONIKONIFRIEDCOMBUSKEN
          item = :KONIKONIFRIEDCOMBUSKEN1
        when :FRESHCREAM
          item = :FRESHCREAM1
        when :BRITTLEBONES
          item = :BRITTLEBONES1
        when :BOILEDEGG
          item = :BOILEDEGG1
        when :BREAD
          item = :BREAD1
        when :INSTANTNOODLES
          item = :INSTANTNOODLES1
        when :FRIEDFOOD
          item = :FRIEDFOOD1
        when :KRABBYCAKE
          item = :KRABBYCAKE1
        when :COCONUTMILK
          item = :COCONUTMILK1
        when :MOOMOOCHEESE
          item = :MOOMOOCHEESE1
        when :PRECOOKEDBURGER
          item = :PRECOOKEDBURGER1
        when :PACKAGEDCURRY
          item = :PACKAGEDCURRY1
        when :PASTA
          item = :PASTA1
        when :SMOKEPOKETAIL
          item = :SMOKEPOKETAIL1
        when :PEKINGPSYDUCK
          item = :PEKINGPSYDUCK1
        when :SHARPEDOFINSOUP
          item = :SHARPEDOFINSOUP1
        when :GIGANTAMIX
          item = :GIGANTAMIX1
        end
      end
      pocket = item.pocket
      maxsize = maxPocketSize(pocket)
      maxsize = @pockets[pocket].length + 1 if maxsize < 0
      return ItemStorageHelper.pbStoreItem(
         @pockets[pocket], maxsize, Settings::BAG_MAX_PER_SLOT, item.id, qty, true)
    end
  
    def pbStoreAllOrNone(item, qty = 1)
      return false if !pbCanStore?(item, qty)
      return pbStoreItem(item, qty)
    end
  
    def pbChangeItem(old_item, new_item)
      old_item = GameData::Item.get(old_item)
      new_item = GameData::Item.get(new_item)
      pocket = old_item.pocket
      ret = false
      @pockets[pocket].each do |item|
        next if !item || item[0] != old_item.id
        item[0] = new_item.id
        ret = true
      end
      return ret
    end
  
    def pbChangeQuantity(pocket, index, newqty = 1)
      return false if pocket <= 0 || pocket > self.numPockets
      return false if !@pockets[pocket][index]
      newqty = [newqty, maxPocketSize(pocket)].min
      @pockets[pocket][index][1] = newqty
      return true
    end
  
    def pbDeleteItem(item, qty = 1)
      item = GameData::Item.get(item)
      pocket = item.pocket
      ret = ItemStorageHelper.pbDeleteItem(@pockets[pocket], item.id, qty)
      return ret
    end
  
    def registeredItems
      @registeredItems = [] if !@registeredItems
      return @registeredItems
    end
  
    def pbIsRegistered?(item)
      item = GameData::Item.get(item).id
      registeredlist = self.registeredItems
      return registeredlist.include?(item)
    end
  
    # Registers the item in the Ready Menu.
    def pbRegisterItem(item)
      item = GameData::Item.get(item).id
      registeredlist = self.registeredItems
      registeredlist.push(item) if !registeredlist.include?(item)
    end
  
    # Unregisters the item from the Ready Menu.
    def pbUnregisterItem(item)
      item = GameData::Item.get(item).id
      registeredlist = self.registeredItems
      for i in 0...registeredlist.length
        next if registeredlist[i] != item
        registeredlist[i] = nil
        break
      end
      registeredlist.compact!
    end
  
    def registeredIndex
      @registeredIndex = [0, 0, 1] if !@registeredIndex
      return @registeredIndex
    end
  end
  
  
  
  #===============================================================================
  # The PC item storage object, which actually contains all the items
  #===============================================================================
  class PCItemStorage
    attr_reader :items
  
    MAX_SIZE     = 999   # Number of different slots in storage
    MAX_PER_SLOT = 999   # Max. number of items per slot
  
    def initialize
      @items = []
      # Start storage with a Potion
      pbStoreItem(:POTION) if GameData::Item.exists?(:POTION)
    end
  
    def [](i)
      return @items[i]
    end
  
    def length
      return @items.length
    end
  
    def empty?
      return @items.length == 0
    end
  
    def clear
      @items.clear
    end
  
    def getItem(index)
      return (index < 0 || index >= @items.length) ? nil : @items[index][0]
    end
  
    def getCount(index)
      return (index < 0 || index >= @items.length) ? 0 : @items[index][1]
    end
  
    def pbQuantity(item)
      item = GameData::Item.get(item).id
      return ItemStorageHelper.pbQuantity(@items, item)
    end
  
    def pbCanStore?(item, qty = 1)
      item = GameData::Item.get(item).id
      return ItemStorageHelper.pbCanStore?(@items, MAX_SIZE, MAX_PER_SLOT, item, qty)
    end
  
    def pbStoreItem(item, qty = 1)
      item = GameData::Item.get(item).id
      return ItemStorageHelper.pbStoreItem(@items, MAX_SIZE, MAX_PER_SLOT, item, qty)
    end
  
    def pbDeleteItem(item, qty = 1)
      item = GameData::Item.get(item).id
      return ItemStorageHelper.pbDeleteItem(@items, item, qty)
    end
  end
  
  
  
  #===============================================================================
  # Implements methods that act on arrays of items.  Each element in an item
  # array is itself an array of [itemID, itemCount].
  # Used by the Bag, PC item storage, and Triple Triad.
  #===============================================================================
  module ItemStorageHelper
    # Returns the quantity of check_item in item_array
    def self.pbQuantity(item_array, check_item)
      ret = 0
      item_array.each { |i| ret += i[1] if i && i[0] == check_item }
      return ret
    end
  
    # Deletes an item (items array, max. size per slot, item, no. of items to delete)
    def self.pbDeleteItem(items, item, qty)
      raise "Invalid value for qty: #{qty}" if qty < 0
      return true if qty == 0
      ret = false
      for i in 0...items.length
        itemslot = items[i]
        next if !itemslot || itemslot[0] != item
        amount = [qty, itemslot[1]].min
        itemslot[1] -= amount
        qty -= amount
        items[i] = nil if itemslot[1] == 0
        next if qty > 0
        ret = true
        break
      end
      items.compact!
      return ret
    end
  
    def self.pbCanStore?(items, maxsize, maxPerSlot, item, qty)
      raise "Invalid value for qty: #{qty}" if qty < 0
      return true if qty == 0
      for i in 0...maxsize
        itemslot = items[i]
        if !itemslot
          qty -= [qty, maxPerSlot].min
          return true if qty == 0
        elsif itemslot[0] == item && itemslot[1] < maxPerSlot
          newamt = itemslot[1]
          newamt = [newamt + qty, maxPerSlot].min
          qty -= (newamt - itemslot[1])
          return true if qty == 0
        end
      end
      return false
    end
  
    def self.pbStoreItem(items, maxsize, maxPerSlot, item, qty, sorting = false)
      raise "Invalid value for qty: #{qty}" if qty < 0
      return true if qty == 0
      itm = GameData::Item.try_get(item)
      itemPocket = (itm) ? itm.pocket : 0
      for i in 0...maxsize
        itemslot = items[i]
        if !itemslot
          items[i] = [item, [qty, maxPerSlot].min]
          qty -= items[i][1]
          if itemPocket > 0 && sorting && Settings::BAG_POCKET_AUTO_SORT[itemPocket]
            items.sort! { |a, b| GameData::Item.get(a[0]).id_number <=> GameData::Item.get(b[0]).id_number }
          end
          return true if qty == 0
        elsif itemslot[0] == item && itemslot[1] < maxPerSlot
          newamt = itemslot[1]
          newamt = [newamt + qty, maxPerSlot].min
          qty -= (newamt - itemslot[1])
          itemslot[1] = newamt
          return true if qty == 0
        end
      end
      return false
    end
  end
  
  
  
  #===============================================================================
  # Shortcut methods
  #===============================================================================
  def pbQuantity(*args)
    return $PokemonBag.pbQuantity(*args)
  end
  
  def pbHasItem?(*args)
    return $PokemonBag.pbHasItem?(*args)
  end
  
  def pbCanStore?(*args)
    return $PokemonBag.pbCanStore?(*args)
  end
  
  def pbStoreItem(*args)
    return $PokemonBag.pbStoreItem(*args)
  end
  
  def pbStoreAllOrNone(*args)
    return $PokemonBag.pbStoreAllOrNone(*args)
  end
  