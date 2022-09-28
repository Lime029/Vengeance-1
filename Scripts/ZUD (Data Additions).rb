#===============================================================================
# Item handlers.
#===============================================================================

#-------------------------------------------------------------------------------
# Z-Crystals - Equips a holdable crystal upon use.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:NORMALIUMZ,proc { |item,pkmn,scene|
    crystalname = GameData::Item.get(item).name
    zcomp       = pkmn.compat_zmove?(pkmn.moves, item)
    next false if pkmn.egg? && scene.pbDisplay(_INTL("Eggs can't hold items."))
    next false if pkmn.shadowPokemon? && scene.pbDisplay(_INTL("Shadow Pokémon can't use Z-Moves."))
    next false if pkmn.item==item && scene.pbDisplay(_INTL("{1} is already holding {2}.",pkmn.name,crystalname))
    next false if !zcomp && !scene.pbConfirm(_INTL("This Pokémon currently can't use this crystal's Z-Power. Is that OK?"))
    scene.pbDisplay(_INTL("The {1} will be given to the Pokémon so that the Pokémon can use its Z-Power!",crystalname))
    if pkmn.item
      itemname = GameData::Item.get(pkmn.item).name
      scene.pbDisplay(_INTL("{1} is already holding a {2}.\1",pkmn.name,itemname))
      if scene.pbConfirm(_INTL("Would you like to switch the two items?"))
        if !$PokemonBag.pbCanStore?(pkmn.item)
          scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
          next false
        else
          $PokemonBag.pbStoreItem(pkmn.item)
          scene.pbDisplay(_INTL("You took the Pokémon's {1} and gave it the {2}.",itemname,crystalname))
        end
      else
        next false
      end
    end
    pkmn.item = item
    pbSEPlay("Pkmn move learnt")
    scene.pbDisplay(_INTL("Your Pokémon is now holding {1}!",crystalname))
    next true
  })
  
  ItemHandlers::UseOnPokemon.copy(:NORMALIUMZ,  :FIRIUMZ,     :WATERIUMZ,  :ELECTRIUMZ,   :GRASSIUMZ,
                                  :ICIUMZ,      :FIGHTINIUMZ, :POISONIUMZ, :GROUNDIUMZ,   :FLYINIUMZ,  
                                  :PSYCHIUMZ,   :BUGINIUMZ,   :ROCKIUMZ,   :GHOSTIUMZ,    :DRAGONIUMZ,
                                  :DARKINIUMZ,  :STEELIUMZ,   :FAIRIUMZ,   :ALORAICHIUMZ, :DECIDIUMZ,
                                  :INCINIUMZ,   :PRIMARIUMZ,  :EEVIUMZ,    :PIKANIUMZ,    :SNORLIUMZ, 
                                  :MEWNIUMZ,    :TAPUNIUMZ,   :MARSHADIUMZ,:PIKASHUNIUMZ, :KOMMONIUMZ,
                                  :LYCANIUMZ,   :MIMIKIUMZ,   :LUNALIUMZ,  :SOLGANIUMZ,   :ULTRANECROZIUMZ)
                                  
  # Z-Crystal properties.
  module GameData
    class Item
      def is_z_crystal?; return @type == 14; end
        
      def is_important?
        return true if is_key_item? || is_HM? || is_TM? || is_z_crystal?
        return false
      end
      
      alias _ZUD_unlosable? unlosable?
      def unlosable?(*args)
        return true if is_z_crystal?
        _ZUD_unlosable?(*args)
      end
    end
  end
  
  # Prevents Z-Crystals from duplicating in the bag.
  class PokemonBag
    alias _ZUD_pbStoreItem pbStoreItem
    def pbStoreItem(*args)
      if pbHasItem?(args[0]) && GameData::Item.get(args[0]).is_z_crystal?
        args[1] = 0 
      end
      _ZUD_pbStoreItem(*args)
    end
  end
  
  #===============================================================================
  # New Pokemon properties.
  #===============================================================================
  class Pokemon
    #-----------------------------------------------------------------------------
    # Power Move compatibility checks.
    #-----------------------------------------------------------------------------  
    def compat_zmove?(param, equipping=nil)
      return false if egg? || shadowPokemon?
      item = (equipping) ? equipping : self.item
      return GameData::PowerMove.z_compat?(param, item, self.species_data.id)
    end
    
    #-----------------------------------------------------------------------------
    # Returns the ID of a Power Move compatible with the inputted parameters.
    #-----------------------------------------------------------------------------
    def get_zmove(param, itemOverride=nil)
      if itemOverride
        return GameData::PowerMove.zmove_from(param, itemOverride, species_data.id)
      else
        return nil if !compat_zmove?(param) 
        return GameData::PowerMove.zmove_from(param, self.item, species_data.id)
      end
    end
    
    #-----------------------------------------------------------------------------
    # Ultra Burst
    #-----------------------------------------------------------------------------
    def hasUltra?
      v = MultipleForms.call("getUltraForm", self)
      return !v.nil?
    end  
  
    def ultra?
      v = MultipleForms.call("getUltraForm", self)
      return !v.nil? && v == @form
    end
  
    def makeUltra
      v = MultipleForms.call("getUltraForm", self)
      self.form = v if !v.nil?
    end
  
    def makeUnUltra
      v = MultipleForms.call("getUnUltraForm", self)
      if !v.nil?;   self.form = v;
      elsif ultra?; self.form = 0;
      end
    end
    
    def ultraName
      v=MultipleForms.call("getUltraName", self)
      return (v.nil?) ? "" : v
    end
  end
  
  #===============================================================================
  # Form handlers for Ultra Necrozma & Eternamax Eternatus.
  #===============================================================================
  # Ultra Necrozma
  MultipleForms.register(:NECROZMA,{
    "getUltraForm" => proc { |pkmn|
       next 3 if pkmn.hasItem?(:ULTRANECROZIUMZ) && pkmn.form > 0
       next
    },
    "getUltraName" => proc { |pkmn|
       next _INTL("Ultra Necrozma") if pkmn.form > 2
       next
    },
    "getUnUltraForm" => proc { |pkmn|
       #next 1 if pkmn.hasMove?(:SUNSTEELSTRIKE)
       #next 2 if pkmn.hasMove?(:MOONGEISTBEAM)
       next pkmn.startForm
    },
    "onSetForm" => proc { |pkmn, form, oldForm|
      next if form > 2 || oldForm > 2
      form_moves = [
         :SUNSTEELSTRIKE,
         :MOONGEISTBEAM
      ]
      if form == 0
        move_index = -1
        pkmn.moves.each_with_index do |move, i|
          next if !form_moves.any? { |m| m == move.id }
          move_index = i
          break
        end
        if move_index >= 0
          move_name = pkmn.moves[move_index].name
          pkmn.forget_move_at_index(move_index)
          pbMessage(_INTL("{1} forgot {2}...", pkmn.name, move_name))
          pbLearnMove(:CONFUSION) if pkmn.numMoves == 0
        end
      else
        new_move_id = form_moves[form - 1]
        pbLearnMove(pkmn, new_move_id, true)
      end
    }
  })
  
  #===============================================================================
  # PokeBattle_Move additions
  #===============================================================================
  class PokeBattle_Move
    attr_accessor :name, :flags
    attr_accessor :zmove_sel        # Used when the player triggers a Z-Move.
    attr_reader   :short_name       # Used for shortening names of Z-Moves/Max Moves.
    attr_reader   :specialUseZMove  # Used for Z-Move display messages in battle.
    
    alias _ZUD_initialize initialize
    def initialize(battle, move)
      _ZUD_initialize(battle,move)
      @short_name       = @name
      @zmove_sel        = false
      @specialUseZMove  = false
    end
    
    #-----------------------------------------------------------------------------
    # The display messages when using a Z-Move in battle.
    #-----------------------------------------------------------------------------
    alias _ZUD_pbDisplayUseMessage pbDisplayUseMessage
    def pbDisplayUseMessage(user)
      if zMove? && !@specialUseZMove
          @battle.pbCommonAnimation("ZPower",user,nil)
        @battle.pbDisplay(_INTL("{1} surrounded itself with its Z-Power!",user.pbThis)) if !statusMove?
        PokeBattle_ZMove.from_status_move(@battle, @id, user) if statusMove?
        @battle.pbDisplayBrief(_INTL("{1} unleashed its full force Z-Move!",user.pbThis))
      end 
      _ZUD_pbDisplayUseMessage(user)
    end 
  end
  
  #-------------------------------------------------------------------------------
  # Checks a PokeBattle_Move to determine if it's a particular Power Move.
  #-------------------------------------------------------------------------------
  class PokeBattle_Move
    def zMove?;     return @flags[/z/];        end
    def powerMove?; return zMove?; end
  end
    
  #-------------------------------------------------------------------------------
  # Checks a Pokemon::Move to determine if it's a particular Power Move.
  #-------------------------------------------------------------------------------
  class Pokemon
    class Move
      def zMove?;     return GameData::Move.get(@id).zMove?;     end
      def powerMove?; return GameData::Move.get(@id).powerMove?; end
    end
  end
  
  #-------------------------------------------------------------------------------
  # Checks a GameData::Move to determine if it's a Power Move.
  #-------------------------------------------------------------------------------
  module GameData
    class Move
      def zMove?;     return self.flags[/z/];    end
      def powerMove?; return zMove?; end
    end
  end
  
  #===============================================================================
  # The "Power Move" class, which handles all Z-Moves & Max Moves.
  #===============================================================================
  module GameData
    class PowerMove
      attr_reader :id
      attr_reader :id_number
      attr_reader :power_type   # Z-Move || Z-Move Ex || Z-Status Move
      attr_reader :req_criteria # Array of criteria for this Power Move
      attr_reader :status_atk   # [[Moves], Stage]
      attr_reader :status_def   # [[Moves], Stage]
      attr_reader :status_spatk # [[Moves], Stage]
      attr_reader :status_spdef # [[Moves], Stage]
      attr_reader :status_speed # [[Moves], Stage]
      attr_reader :status_acc   # [[Moves], Stage]
      attr_reader :status_eva   # [[Moves], Stage]
      attr_reader :status_omni  # [[Moves], Stage]
      attr_reader :status_heal  # [[Moves], Stage]
      attr_reader :status_crit  # [Moves]
      attr_reader :status_reset # [Moves]
      attr_reader :status_focus # [Moves]
      
      ZMOVE    = 0
      ZMOVEEX  = 1
      ZSTATUS  = 2
  
      DATA = {}
      DATA_FILENAME = "ZUD_PowerMoves.dat"
  
      SCHEMA = {
        #-------------------------------------------------------------------------
        # Power Moves
        #-------------------------------------------------------------------------
        "ZMove"           => [0, "eee",  :Move, :Item, :Type],
        "ZMoveEx"         => [0, "eeee", :Move, :Item, :Move, :Species],
        #-------------------------------------------------------------------------
        # Status Z-Moves
        #-------------------------------------------------------------------------
        "AtkBoost1"       => [0,  "*e",  :Move],
        "AtkBoost2"       => [0,  "*e",  :Move],
        "AtkBoost3"       => [0,  "*e",  :Move],
        
        "DefBoost1"       => [0,  "*e",  :Move],
        "DefBoost2"       => [0,  "*e",  :Move], # Not used by any existing moves.
        "DefBoost3"       => [0,  "*e",  :Move], # Not used by any existing moves.
        
        "SpAtkBoost1"     => [0,  "*e",  :Move],
        "SpAtkBoost2"     => [0,  "*e",  :Move],
        "SpAtkBoost3"     => [0,  "*e",  :Move], # Not used by any existing moves.
        
        "SpDefBoost1"     => [0,  "*e",  :Move],
        "SpDefBoost2"     => [0,  "*e",  :Move],
        "SpDefBoost3"     => [0,  "*e",  :Move], # Not used by any existing moves.
        
        "SpeedBoost1"     => [0,  "*e",  :Move],
        "SpeedBoost2"     => [0,  "*e",  :Move],
        "SpeedBoost3"     => [0,  "*e",  :Move], # Not used by any existing moves.
        
        "AccBoost1"       => [0,  "*e",  :Move],
        "AccBoost2"       => [0,  "*e",  :Move], # Not used by any existing moves.
        "AccBoost3"       => [0,  "*e",  :Move], # Not used by any existing moves.
        
        "EvaBoost1"       => [0,  "*e",  :Move],
        "EvaBoost2"       => [0,  "*e",  :Move], # Not used by any existing moves.
        "EvaBoost3"       => [0,  "*e",  :Move], # Not used by any existing moves.
        
        "OmniBoost1"      => [0,  "*e",  :Move],
        "OmniBoost2"      => [0,  "*e",  :Move], # Not used by any existing moves.
        "OmniBoost3"      => [0,  "*e",  :Move], # Not used by any existing moves.
        
        "HealUser"        => [0,  "*e",  :Move],
        "HealSwitch"      => [0,  "*e",  :Move],
        
        "CritBoost"       => [0,  "*e",  :Move],
        "ResetStats"      => [0,  "*e",  :Move],
        "FocusOnUser"     => [0,  "*e",  :Move],
        #-------------------------------------------------------------------------
        # Other data
        #-------------------------------------------------------------------------
        "DexData"         => [0, "efss", :Species] # Saved in GameData::Species, not here.
      }
  
      extend ClassMethods
      include InstanceMethods
  
      def initialize(hash)
        @id             = hash[:id]
        @id_number      = hash[:id_number]
        @power_type     = hash[:compat_type]
        @req_criteria   = hash[:req_criteria]
        @status_atk     = hash[:status_atk]
        @status_def     = hash[:status_def]
        @status_spatk   = hash[:status_spatk]
        @status_spdef   = hash[:status_spdef]
        @status_speed   = hash[:status_speed]
        @status_acc     = hash[:status_acc]
        @status_eva     = hash[:status_eva]
        @status_omni    = hash[:status_omni]
        @status_heal    = hash[:status_heal]
        @status_crit    = hash[:status_crit]
        @status_reset   = hash[:status_reset]
        @status_focus   = hash[:status_focus]
      end
      
      #---------------------------------------------------------------------------
      # Utilities for getting Power Move compatibility data.
      #---------------------------------------------------------------------------
      def zMove?;       return true if @power_type==ZMOVE;    end
      def zMoveEx?;     return true if @power_type==ZMOVEEX;  end
      def zStatus?;     return true if @power_type==ZSTATUS;  end
      def any_ZMove?;   return true if zMove?   || zMoveEx?;  end
      
      def power_move;   return (!zStatus?) ? @req_criteria[0] : nil; end
      def reqItem;      return @req_criteria[1] if any_ZMove?; end
      def reqMove;      return @req_criteria[2] if zMoveEx?;   end
      
      def reqType
        return @req_criteria[2] if zMove?
      end
      
      def reqSpecies
        return @req_criteria[3] if zMoveEx?
      end
      
      #---------------------------------------------------------------------------
      # Returns total number of Power Moves, or number of specific Power Moves.
      #---------------------------------------------------------------------------
      def self.get_count(power_type=0)
        num = 0
        self.each do |m|
          if (power_type==1 && m.any_ZMove?) # Gets only Z-Move count (excludes Status Z-Moves).
            num += 1
          elsif power_type==0
            num += 1
          end
        end
        return num
      end
      #---------------------------------------------------------------------------
      # Returns a list of all species with an exclusive Z-Move(1) form.
      #---------------------------------------------------------------------------
      def self.species_list(mode=0)
        species_list = []
        self.each do |m|
          break if mode==0
          next if mode==1 && !m.zMoveEx?
          species_list.push(m.reqSpecies)
        end
        return species_list
      end
      #---------------------------------------------------------------------------
      # Returns a required Z-Crystal based on the inputted Type.
      #---------------------------------------------------------------------------
      def self.item_from(type)
        self.each do |m|
          next if !m.zMove?
          if type==m.reqType; return m.reqItem; end
        end
      end
      #---------------------------------------------------------------------------
      # Returns true when all inputted parameters are compatible.
      #---------------------------------------------------------------------------
      # Z-Moves
      def self.z_compat?(param, item, species)
        return true if self.zmove_from(param, item, species)
        return false
      end
      #---------------------------------------------------------------------------
      # Returns a Z-Move based on the inputted parameters.
      # Parameters can be any of the following (or an array containing the following):
      # PokeBattle_ZMove, PokeBattle_Move, Pokemon::Move, GameData::Move, GameData::Type
      #---------------------------------------------------------------------------
      def self.zmove_from(param, item, species)
        ret = nil
        self.each do |m|
          next if !m.any_ZMove?
          next if m.zMoveEx? && species!=m.reqSpecies
          if item == m.reqItem
            if param.is_a?(Array)
              for i in param
                if i.id == m.reqMove || i.type == m.reqType
                  ret = m.power_move
                end
              end
            else
              if param.is_a?(PokeBattle_ZMove)
                ret = m.power_move
              elsif param.is_a?(PokeBattle_Move)
                ret = m.power_move if param.id   == m.reqMove
                ret = m.power_move if param.type == m.reqType
              elsif param.is_a?(Pokemon::Move)
                ret = m.power_move if param.id   == m.reqMove
                ret = m.power_move if param.type == m.reqType
              elsif GameData::Move.exists?(param)
                ret = m.power_move if param == m.reqMove
                ret = m.power_move if GameData::Move.get(param).type == m.reqType
              elsif GameData::Type.exists?(param)
                ret = m.power_move if param == m.reqType
              end
            end
          end
        end
        return ret
      end
      #---------------------------------------------------------------------------
      # Returns true if inputted move would boost user's stats as a Z-Move. (Status)
      #---------------------------------------------------------------------------
      def self.stat_booster?(move)
        self.each do |z|
          next if !z.zStatus?
          if (z.status_atk[0]   && z.status_atk[0].include?(move))   || 
             (z.status_def[0]   && z.status_def[0].include?(move))   ||
             (z.status_spatk[0] && z.status_spatk[0].include?(move)) || 
             (z.status_spdef[0] && z.status_spdef[0].include?(move)) ||
             (z.status_speed[0] && z.status_speed[0].include?(move)) || 
             (z.status_acc[0]   && z.status_acc[0].include?(move))   ||
             (z.status_eva[0]   && z.status_eva[0].include?(move))   || 
             (z.status_omni[0]  && z.status_omni[0].include?(move))
            return true
          end
        end
        return false
      end
      #---------------------------------------------------------------------------
      # Returns a stat & stage boost of a Z-Move based on the inputted move. (Status)
      #---------------------------------------------------------------------------
      def self.stat_with_stage(move)
        stats = []
        stage = 0
        self.each do |z|
          next if !z.zStatus?
          if    z.status_atk[0]   && z.status_atk[0].include?(move);   stats, stage = [:ATTACK],          z.status_atk[1];
          elsif z.status_def[0]   && z.status_def[0].include?(move);   stats, stage = [:DEFENSE],         z.status_def[1];
          elsif z.status_spatk[0] && z.status_spatk[0].include?(move); stats, stage = [:SPECIAL_ATTACK],  z.status_spatk[1];
          elsif z.status_spdef[0] && z.status_spdef[0].include?(move); stats, stage = [:SPECIAL_DEFENSE], z.status_spdef[1];
          elsif z.status_speed[0] && z.status_speed[0].include?(move); stats, stage = [:SPEED],           z.status_speed[1];
          elsif z.status_acc[0]   && z.status_acc[0].include?(move);   stats, stage = [:ACCURACY],        z.status_acc[1];
          elsif z.status_eva[0]   && z.status_eva[0].include?(move);   stats, stage = [:EVASION],         z.status_eva[1];
          elsif z.status_omni[0]  && z.status_omni[0].include?(move)
            stats, stage  = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED], z.status_omni[1]
          end
        end
        return stats, stage
      end
      #---------------------------------------------------------------------------
      # Returns true if inputted move would heal the user as a Z-Move. (Status)
      #---------------------------------------------------------------------------
      def self.heals_self?(move)
        self.each do |z|
          next if !z.zStatus?
          return true if z.status_heal[0] && z.status_heal[0].include?(move) && z.status_heal[1]==1
        end
        return false
      end
      #---------------------------------------------------------------------------
      # Returns true if inputted move would heal a switch-in as a Z-Move. (Status)
      #---------------------------------------------------------------------------
      def self.heals_switch?(move)
        self.each do |z|
          next if !z.zStatus?
          return true if z.status_heal[0] && z.status_heal[0].include?(move) && z.status_heal[1]==2
        end
        return false
      end    
      #---------------------------------------------------------------------------
      # Returns true if inputted move increases critical hit as a Z-Move. (Status)
      #---------------------------------------------------------------------------
      def self.boosts_crit?(move)
        self.each do |z|
          next if !z.zStatus?
          return true if z.status_crit && z.status_crit.include?(move)
        end
        return false
      end
      #---------------------------------------------------------------------------
      # Returns true if inputted move resets user's stats as a Z-Move. (Status)
      #---------------------------------------------------------------------------
      def self.resets_stats?(move)
        self.each do |z|
          next if !z.zStatus?
          return true if z.status_reset && z.status_reset.include?(move)
        end
        return false
      end
      #---------------------------------------------------------------------------
      # Returns true if inputted move draws in moves as a Z-Move. (Status)
      #---------------------------------------------------------------------------
      def self.focus_user?(move)
        self.each do |z|
          next if !z.zStatus?
          return true if z.status_focus && z.status_focus.include?(move)
        end
        return false
      end
    end
  end