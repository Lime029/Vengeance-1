class PokeBattle_Battler
    # Fundamental to this object
    attr_reader   :battle
    attr_accessor :index
    # The Pokémon and its properties
    attr_reader   :pokemon
    attr_accessor :pokemonIndex
    attr_accessor :species
    attr_accessor :type1
    attr_accessor :type2
    attr_accessor :ability_id
    attr_accessor :item_id
    attr_accessor :moves
    attr_accessor :gender
    attr_accessor :iv
    attr_accessor :attack
    attr_accessor :spatk
    attr_accessor :speed
    attr_accessor :stages
    attr_reader   :totalhp
    attr_reader   :fainted    # Boolean to mark whether self has fainted properly
    attr_accessor :captured   # Boolean to mark whether self was captured
    attr_reader   :dummy
    attr_accessor :effects
    # Things the battler has done in battle
    attr_accessor :turnCount
    attr_accessor :participants
    attr_accessor :lastAttacker
    attr_accessor :lastFoeAttacker
    attr_accessor :lastHPLost
    attr_accessor :lastHPLostFromFoe
    attr_accessor :lastMoveUsed # The ID of this battler's last move used
    attr_accessor :lastMoveUsedType
    attr_accessor :lastRegularMoveUsed
    attr_accessor :lastRegularMoveTarget   # For Instruct
    attr_accessor :lastRoundMoved
    attr_accessor :lastMoveFailed        # For Stomping Tantrum
    attr_accessor :lastRoundMoveFailed   # For Stomping Tantrum
    attr_accessor :movesUsed
    attr_accessor :currentMove   # ID of multi-turn move currently being used
    attr_accessor :tookDamage    # Boolean for whether self took damage this round
    attr_accessor :tookPhysicalHit
    attr_accessor :damageState
    attr_accessor :initialHP     # Set at the start of each move's usage
    # AI Attributes
    attr_accessor :moveChoice   # {:callMove, :realMove, :targets, :damages, :moveIndex, :targetIndex, :user, :score}
    attr_accessor :switchChoice # This Pokemon's switch choice party index
    attr_accessor :itemChoice   # This Pokemon's item choice
  
    #=============================================================================
    # Complex accessors
    #=============================================================================
    attr_reader :level
  
    def level=(value)
      @level = value
      @pokemon.level = value if @pokemon
    end
  
    attr_reader :form
  
    def form=(value)
      @form = value
      @pokemon.form = value if @pokemon
    end
  
    def ability(nameUse=false)
      return GameData::Ability.try_get(:ABILITY) if $fefieldeffect == 29 && nameUse
      return GameData::Ability.try_get(@ability_id)
    end
  
    def ability=(value)
      new_ability = GameData::Ability.try_get(value)
      @ability_id = (new_ability) ? new_ability.id : nil
    end
  
    def item
      return GameData::Item.try_get(@item_id)
    end
  
    def item=(value)
      new_item = GameData::Item.try_get(value)
      @item_id = (new_item) ? new_item.id : nil
      @pokemon.item = @item_id if @pokemon
    end
  
    def defense
      return @spdef if @battle.field.effects[PBEffects::WonderRoom]>0
      return @defense
    end
  
    attr_writer :defense
  
    def spdef
      return @defense if @battle.field.effects[PBEffects::WonderRoom]>0
      return @spdef
    end
  
    attr_writer :spdef
  
    attr_reader :hp
  
    def hp=(value)
      @hp = value.to_i
      @pokemon.hp = value.to_i if @pokemon
    end
  
    def fainted?; return @hp<=0; end
    alias isFainted? fainted?
  
    attr_reader :status
  
    def status=(value)
      @effects[PBEffects::Truant] = false if @status == :SLEEP && value != :SLEEP
      @effects[PBEffects::Toxic]  = 0 if value != :POISON
      @status = value
      @pokemon.status = value if @pokemon
      self.statusCount = 0 if value != :POISON && value != :SLEEP
      @battle.scene.pbRefreshOne(@index)
    end
  
    attr_reader :statusCount
  
    def statusCount=(value)
      @statusCount = value
      @pokemon.statusCount = value if @pokemon
      @battle.scene.pbRefreshOne(@index)
    end
  
    attr_reader :critical_hits
  
    def critical_hits=(value)
      @critical_hits = value
      @pokemon.critical_hits = value if @pokemon
    end
  
    attr_reader :damage_done
  
    def damage_done=(value)
      @damage_done = value
      @pokemon.damage_done = value if @pokemon
    end
  
    #=============================================================================
    # Properties from Pokémon
    #=============================================================================
    def happiness;    return @pokemon ? @pokemon.happiness : 0;    end
    def nature;       return @pokemon ? @pokemon.nature : 0;       end
    def pokerusStage; return @pokemon ? @pokemon.pokerusStage : 0; end
  
    #=============================================================================
    # Mega Evolution, Primal Reversion, Shadow Pokémon
    #=============================================================================
    def hasMega?
      return false if @effects[PBEffects::Transform]
      return @pokemon && @pokemon.hasMegaForm?
    end
  
    def mega?; return @pokemon && @pokemon.mega?; end
    alias isMega? mega?
  
    def hasPrimal?
      return false if @effects[PBEffects::Transform]
      return @pokemon && @pokemon.hasPrimalForm?
    end
  
    def primal?; return @pokemon && @pokemon.primal?; end
    alias isPrimal? primal?
  
    def shadowPokemon?; return false; end
    alias isShadow? shadowPokemon?
  
    def inHyperMode?; return false; end
  
    #=============================================================================
    # Display-only properties
    #=============================================================================
    def name
      return @effects[PBEffects::Illusion].name if @effects[PBEffects::Illusion]
      return @name
    end
  
    attr_writer :name
  
    def displayPokemon
      return @effects[PBEffects::Illusion] if @effects[PBEffects::Illusion]
      return self.pokemon
    end
  
    def displaySpecies
      return @effects[PBEffects::Illusion].species if @effects[PBEffects::Illusion]
      return self.species
    end
  
    def displayGender
      return @effects[PBEffects::Illusion].gender if @effects[PBEffects::Illusion]
      return self.gender
    end
  
    def displayForm
      return @effects[PBEffects::Illusion].form if @effects[PBEffects::Illusion]
      return self.form
    end
  
    def shiny?
      return @effects[PBEffects::Illusion].shiny? if @effects[PBEffects::Illusion]
      return @pokemon && @pokemon.shiny?
    end
    alias isShiny? shiny?
  
    def owned?
      return false if !@battle.wildBattle?
      return $Trainer.owned?(displaySpecies)
    end
    alias owned owned?
  
    def abilityName
      abil = self.ability(true)
      return (abil) ? abil.name : ""
    end
  
    def itemName
      itm = self.item
      return (itm) ? itm.name : ""
    end
  
    def pbThis(lowerCase=false)
      if opposes?
        if @battle.trainerBattle?
          return lowerCase ? _INTL("the opposing {1}",name) : _INTL("The opposing {1}",name)
        else
          return lowerCase ? _INTL("the wild {1}",name) : _INTL("The wild {1}",name)
        end
      elsif !pbOwnedByPlayer?
        return lowerCase ? _INTL("the ally {1}",name) : _INTL("The ally {1}",name)
      end
      return name
    end
  
    def pbTeam(lowerCase=false)
      if opposes?
        return lowerCase ? _INTL("the opposing team") : _INTL("The opposing team")
      end
      return lowerCase ? _INTL("your team") : _INTL("Your team")
    end
  
    def pbOpposingTeam(lowerCase=false)
      if opposes?
        return lowerCase ? _INTL("your team") : _INTL("Your team")
      end
      return lowerCase ? _INTL("the opposing team") : _INTL("The opposing team")
    end
  
    #=============================================================================
    # Calculated properties
    #=============================================================================
    def pbSpeed
      return 1 if fainted?
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @stages[:SPEED] + 6
      speed = @speed*stageMul[stage]/stageDiv[stage]
      speedMult = 1.0
      # Ability effects that alter calculated Speed
      #speedMult = BattleHandlers.triggerSpeedCalcAbility(self.ability,self,speedMult)
      if hasActiveAbility?(:CHLOROPHYLL)
        speedMult *= 2 if [:Sun,:HarshSun].include?(@battle.pbWeather) && !hasUtilityUmbrella?
        speedMult *= 2 if $fefieldeffect == 33 && $fecounter >= 3 || [2,49].include?($fefieldeffect)
      end
      if hasActiveAbility?(:SANDRUSH) && !([8,21,26].include?($fefieldeffect) && grounded?)
        speedMult *= 2 if @battle.pbWeather == :Sandstorm
        speedMult *= 2 if [12,20,48,49].include?($fefieldeffect)
      end
      if hasActiveAbility?(:SLUSHRUSH)
        speedMult *= 2 if @battle.pbWeather == :Hail
        speedMult *= 2 if [13,28,39,46].include?($fefieldeffect)
      end
      if hasActiveAbility?(:SWIFTSWIM)
        speedMult *= 2 if [:Rain,:HeavyRain].include?(@battle.pbWeather) && !hasUtilityUmbrella?
        speedMult *= 2 if $fefieldeffect == 22 || [21,26].include?($fefieldeffect) && grounded?
      end
      if hasActiveAbility?(:SURGESURFER)
        speedMult *= 2 if [1,18,21,26,48].include?($fefieldeffect)
      end
      if hasActiveAbility?(:QUICKFEET) && ![8,12,41,43].include?($fefieldeffect)
        speedMult *= 1.5 if pbHasAnyStatus?
        speedMult *= 1.5 if $fefieldeffect == 1 || $fefieldeffect == 7 && takesVolcanicFieldDamage? || 
                            $fefieldeffect == 10 && takesCorrosiveFieldDamage? ||
                            $fefieldeffect == 26 && affectedByMurkwaterSurface? ||
                            $fefieldeffect == 22 && takesUnderwaterFieldDamage? ||
                            $fefieldeffect == 41 && takesCorruptedCaveDamage?
      end
      if hasActiveAbility?(:UNBURDEN) && !($fefieldeffect == 43 && !pbHasType?(:FLYING))
        speedMult *= 2 if @effects[PBEffects::Unburden] && !@item
      end
      if hasActiveAbility?(:SLOWSTART) && ![1,17,18,29].include?($fefieldeffect)
        speedMult /= 2 if @effects[PBEffects::SlowStart]>0
      end
      if hasActiveAbility?(:LEVITATE)
        speedMult *= 2 if $fefieldeffect == 5
        speedMult /= 2 if [15,47].include?($fefieldeffect)
      end
      if hasActiveAbility?(:LIMBER)
        speedMult *= 2 if $fefieldeffect == 6
      end
      if hasActiveAbility?(:SERENEGRACE)
        speedMult *= 2 if $fefieldeffect == 6
      end
      if hasActiveAbility?(:GALEWINGS)
        speedMult *= 2 if $fefieldeffect == 6
      end
      if hasActiveAbility?(:LIGHTMETAL)
        speedMult *= 2 if $fefieldeffect == 17
      end
      if hasActiveAbility?(:PROPELLERTAIL)
        speedMult *= 2 if [21,26].include?($fefieldeffect) && grounded? || $fefieldeffect == 22
      end
      if hasActiveAbility?(:TELEPATHY)
        speedMult *= 2 if $fefieldeffect == 37
      end
      if hasActiveAbility?(:PREDATION) && $fefieldeffect != 9
        weakOpp = false
        allStrongOpp = true
        eachNearOpposing do |b|
          weakOpp = true if b.hp < b.totalhp/4 || [45,47].include?($fefieldeffect) &&
                            b.hp < b.totalhp/2
          allStrongOpp = false if b.hp < b.totalhp/2
        end
        if weakOpp
          speedMult *= 2
        elsif allStrongOpp && $fefieldeffect != 42
          speedMult /= 2
        end
      end
      if hasActiveAbility?(:REGALITY)
        eachNearOpposing do |b|
          if @hp <= b.hp || $fefieldeffect == 5
            speedMult *= 4.0/3
          end
        end
      end
      if hasActiveAbility?(:ELECTRONTITAN)
        speedMult *= 1.1
      end
      if $fefieldeffect == 12
        eachAlly do |b|
          if b.hasActiveAbility?(:INSPIRE)
            speedMult *= 1.3
          end
        end
      end
      # Item effects that alter calculated Speed
      if itemActive?
        speedMult = BattleHandlers.triggerSpeedCalcItem(self.item,self,speedMult)
      end
      # Other effects
      speedMult *= 0.8 if $fefieldeffect == 21 && !pbHasType?(:WATER) && !hasActiveAbility?([:SWIFTSWIM,:PROPELLERTAIL]) &&
                          grounded?
      speedMult /= 2 if $fefieldeffect == 22 && !pbHasType?(:WATER) && !hasActiveAbility?([:SWIFTSWIM,:PROPELLERTAIL])
      speedMult /= 2 if $fefieldeffect == 26 && !pbHasType?(:WATER) && !pbHasType?(:WATER) && 
                        !hasActiveAbility?([:SWIFTSWIM,:PROPELLERTAIL]) && grounded?
      speedMult *= 2 if pbOwnSide.effects[PBEffects::Tailwind]>0
      speedMult /= 2 if pbOwnSide.effects[PBEffects::Swamp]>0
      # Paralysis
      if status == :PARALYSIS && !hasActiveAbility?(:QUICKFEET)
        speedMult /= ($fefieldeffect != 24) ? 2 : 4
      end
      # Badge multiplier
      if @battle.internalBattle && pbOwnedByPlayer? &&
         @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPEED
        speedMult *= 1.1
      end
      # Calculation
      return [(speed*speedMult).round,1].max
    end
  
    def pbWeight
      ret = (@pokemon) ? @pokemon.weight : 500
      ret += @effects[PBEffects::WeightChange]
      ret = 1 if ret<1
      if abilityActive? && !@battle.moldBreaker
        #ret = BattleHandlers.triggerWeightCalcAbility(self.ability,self,ret)
        if hasActiveAbility?(:HEAVYMETAL)
          ret *= 2
        end
        if hasActiveAbility?(:LIGHTMETAL)
          ret = [ret/2,1].max
        end
      end
      if itemActive?
        ret = BattleHandlers.triggerWeightCalcItem(self.item,self,ret)
      end
      return [ret,1].max
    end
  
    #=============================================================================
    # Queries about what the battler has
    #=============================================================================
    def plainStats
      ret = {}
      ret[:ATTACK]          = self.attack
      ret[:DEFENSE]         = self.defense
      ret[:SPECIAL_ATTACK]  = self.spatk
      ret[:SPECIAL_DEFENSE] = self.spdef
      ret[:SPEED]           = self.speed
      return ret
    end
  
    def isSpecies?(species)
      return @pokemon && @pokemon.isSpecies?(species)
    end
  
    # Returns the active types of this Pokémon. The array should not include the
    # same type more than once, and should not include any invalid type numbers
    # (e.g. -1).
    def pbTypes(withType3=false)
      ret = [@type1]
      ret.push(@type2) if @type2!=@type1
      # Burn Up erases the Fire-type.
      ret.delete(:FIRE) if @effects[PBEffects::BurnUp] && $fefieldeffect != 7
      # Roost erases the Flying-type. If there are no types left, adds the Normal-
      # type.
      if @effects[PBEffects::Roost]
        ret.delete(:FLYING)
        ret.push(:NORMAL) if ret.length == 0
      end
      # Glitch Field treats Fairy, Dark, and Steel as no type
      if $fefieldeffect == 24
        ret.delete(:FAIRY)
        ret.delete(:STEEL)
        ret.delete(:DARK)
        ret.push(:QMARKS) if ret.length == 0
      end
      # Add the third type specially.
      if withType3 && @effects[PBEffects::Type3]
        ret.push(@effects[PBEffects::Type3]) if !ret.include?(@effects[PBEffects::Type3])
      end
      return ret
    end
  
    def pbHasType?(type)
      return false if !type
      activeTypes = pbTypes(true)
      return activeTypes.include?(GameData::Type.get(type).id)
    end
  
    # Returns true if the target has another type besides the specified one (if it has the specified one at all)
    def pbHasOtherType?(type)
      return false if !type
      activeTypes = pbTypes(true)
      activeTypes.delete(GameData::Type.get(type).id)
      return activeTypes.length > 0
    end
  
    # NOTE: Do not create any held item which affects whether a Pokémon's ability
    #       is active. The ability Klutz affects whether a Pokémon's item is
    #       active, and the code for the two combined would cause an infinite loop
    #       (regardless of whether any Pokémon actualy has either the ability or
    #       the item - the code existing is enough to cause the loop).
    def abilityActive?(ignoreFainted=false)
      return false if fainted? && !ignoreFainted
      return false if @battle.field.effects[PBEffects::NeutralizingGas]
      return false if @effects[PBEffects::GastroAcid]
      return true
    end
  
    def hasActiveAbility?(check_ability,ignore_fainted=false,ignore_negation=false)
      return false if !abilityActive?(ignore_fainted) && !ignore_negation
      if check_ability.is_a?(Array)
        check_ability.each do |a|
          return true if hasActiveAbility?(a)
        end
        return false
      end
      if @effects[PBEffects::AsOne].include?(check_ability)
        return true
      end
      if @effects[PBEffects::HolyAbilities] != []
        return @effects[PBEffects::HolyAbilities].include?(check_ability)
      end
      return self.ability == check_ability
    end
    alias hasActiveAbility? hasActiveAbility?
  
    # Applies to both losing self's ability (i.e. being replaced by another) and
    # having self's ability be negated.
    def unstoppableAbility?(abil = nil)
      abil = @ability_id if !abil
      abil = GameData::Ability.try_get(abil)
      return false if !abil
      ability_blacklist = [
        # Form-changing abilities
        :BATTLEBOND,
        :DISGUISE,
  #      :FLOWERGIFT,                                        # This can be stopped
  #      :FORECAST,                                          # This can be stopped
        :MULTITYPE,
        :POWERCONSTRUCT,
        :SCHOOLING,
        :SHIELDSDOWN,
        :STANCECHANGE,
        :ZENMODE,
        :ICEFACE,
        # Abilities intended to be inherent properties of a certain species
        :COMATOSE,
        :RKSSYSTEM,
        :GULPMISSILE,
        :ASONE
      ]
      return ability_blacklist.include?(abil.id)
    end
  
    # Applies to gaining the ability.
    def ungainableAbility?(abil = nil)
      abil = @ability_id if !abil
      abil = GameData::Ability.try_get(abil)
      return false if !abil
      ability_blacklist = [
        # Form-changing abilities
        :BATTLEBOND,
        :DISGUISE,
        :FLOWERGIFT,
        :FORECAST,
        :MULTITYPE,
        :POWERCONSTRUCT,
        :SCHOOLING,
        :SHIELDSDOWN,
        :STANCECHANGE,
        :ZENMODE,
        # Appearance-changing abilities
        :ILLUSION,
        :IMPOSTER,
        # Abilities intended to be inherent properties of a certain species
        :COMATOSE,
        :RKSSYSTEM,
        :ASONE,
        :NEUTRALIZINGGAS,
        :HUNGERSWITCH
      ]
      return ability_blacklist.include?(abil.id)
    end
  
    def itemActive?(ignoreFainted=false)
      return false if fainted? && !ignoreFainted
      return false if @effects[PBEffects::Embargo]>0
      return false if @battle.field.effects[PBEffects::MagicRoom]>0
      return false if hasActiveAbility?(:KLUTZ,ignoreFainted)
      eachOpposing do |b|
        break if ![6,32].include?($fefieldeffect)
        return false if b.hasActiveAbility?(:UNNERVE)
      end
      return true
    end
  
    def hasActiveItem?(check_item, ignore_fainted = false)
      return false if !itemActive?(ignore_fainted)
      return check_item.include?(@item_id) if check_item.is_a?(Array)
      return self.item == check_item
    end
    alias hasWorkingItem hasActiveItem?
  
    # Returns whether the specified item will be unlosable for this Pokémon.
    def unlosableItem?(check_item)
      return false if !check_item
      return true if GameData::Item.get(check_item).is_mail?
      return false if @effects[PBEffects::Transform]
      # Items that change a Pokémon's form
      if mega?   # Check if item was needed for this Mega Evolution
        return true if @pokemon.species_data.mega_stone == check_item
      else   # Check if item could cause a Mega Evolution
        GameData::Species.each do |data|
          next if data.species != @species || data.unmega_form != @form
          return true if data.mega_stone == check_item
        end
      end
      # Other unlosable items
      return GameData::Item.get(check_item).unlosable?(@species, self.ability)
    end
  
    def eachMove
      @moves.each { |m| yield m }
    end
  
    def eachMoveWithIndex
      @moves.each_with_index { |m, i| yield m, i }
    end
  
    def pbHasMoveType?(check_type)
      return false if !check_type
      check_type = GameData::Type.get(check_type).id
      eachMove { |m| return true if m.type == check_type }
      return false
    end
  
    def pbHasMoveFunction?(*arg)
      return false if !arg
      eachMove do |m|
        arg.each { |code| return true if m.function == code }
      end
      return false
    end
  
    def hasMoldBreaker?
      return hasActiveAbility?(:MOLDBREAKER) && ![3,31].include?($fefieldeffect) ||
             hasActiveAbility?(:TURBOBLAZE) && !([21,26].include?($fefieldeffect) && 
             grounded?) && ![22,39,46].include?($fefieldeffect) || hasActiveAbility?(:TERAVOLT) && 
             !($fefieldeffect == 8 && grounded?)
    end
    
    def hasSuctionCups?
      return hasActiveAbility?(:SUCTIONCUPS) || hasActiveAbility?(:STICKYHOLD) &&
             [8,19].include?($fefieldeffect) || hasActiveAbility?(:ALPHABETIZATION) &&
             checkAlphabetizationForm(10)
    end
    
    def hasStickyHold?
      return hasActiveAbility?(:STICKYHOLD) && !([12,20,48,49].include?($fefieldeffect) && 
             grounded?) || hasActiveAbility?(:ALPHABETIZATION) && checkAlphabetizationForm(10)
    end
  
    def hasShieldDust?
      return hasActiveAbility?(:SHIELDDUST) && $fefieldeffect != 22 && !([21,26].include?($fefieldeffect) &&
             grounded?)
    end
    
    def canChangeType?
      return ![:MULTITYPE, :RKSSYSTEM].include?(@ability_id)
    end
  
    def airborne?
      return false if hasActiveItem?(:IRONBALL)
      return false if @effects[PBEffects::Ingrain]
      return false if @effects[PBEffects::SmackDown]
      return false if @battle.field.effects[PBEffects::Gravity] > 0
      return false if [7,13,23,41].include?($fefieldeffect)
      return true if pbHasType?(:FLYING)
      return true if hasActiveAbility?(:LEVITATE) && !@battle.moldBreaker
      return true if hasActiveItem?(:AIRBALLOON)
      return true if @effects[PBEffects::MagnetRise] > 0
      return true if @effects[PBEffects::Telekinesis] > 0
      return true if hasActiveAbility?(:SPYGEAR) && @effects[PBEffects::SpyGear] == 1 # Winged Membrane
      return true if hasActiveItem?(:FLOATSTONE) && [4,25].include?($fefieldeffect)
      return false
    end
  
    def affectedByTerrain?
      return false if airborne?
      return false if semiInvulnerable?
      return true
    end
    
    def takesIndirectDamage?(showMsg=false)
      return false if fainted?
      if hasActiveAbility?(:MAGICGUARD) || hasActiveAbility?(:WONDERGUARD) && $fefieldeffect == 31
        if showMsg
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} is unaffected!",pbThis))
          else
            @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return false
      end
      return true
    end
  
    def takesSandstormDamage?
      return false if !takesIndirectDamage?
      return false if pbHasType?(:GROUND) || pbHasType?(:ROCK) || pbHasType?(:STEEL)
      return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
      return false if hasActiveAbility?([:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDVEIL])
      return false if hasActiveItem?(:SAFETYGOGGLES)
      return true
    end
  
    def takesHailDamage?
      return false if !takesIndirectDamage?
      return false if pbHasType?(:ICE)
      return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
      return false if hasActiveAbility?([:OVERCOAT,:ICEBODY,:SNOWCLOAK,:FROSTBLESSING])
      return false if hasActiveItem?(:SAFETYGOGGLES)
      return true
    end
  
    def takesShadowSkyDamage?
      return false if fainted?
      return false if shadowPokemon?
      return true
    end
  
    def affectedByEntryHazards?
      return !(hasActiveItem?(:HEAVYDUTYBOOTS) || hasActiveAbility?([:OVERCOAT,:BONEARMOR]))
    end
  
    def affectedByPowder?(showMsg=false)
      return false if fainted?
      if pbHasType?(:GRASS) && Settings::MORE_TYPE_EFFECTS
        @battle.pbDisplay(_INTL("{1} is unaffected!",pbThis)) if showMsg
        return false
      end
      if Settings::MECHANICS_GENERATION >= 6
        if hasActiveAbility?(:OVERCOAT) && !@battle.moldBreaker
          if showMsg
            @battle.pbShowAbilitySplash(self)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1} is unaffected!",pbThis))
            else
              @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",pbThis,abilityName))
            end
            @battle.pbHideAbilitySplash(self)
          end
          return false
        end
        if hasActiveItem?(:SAFETYGOGGLES)
          if showMsg
            @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",pbThis,itemName))
          end
          return false
        end
      end
      return true
    end
  
    def canHeal?(selfHP=@hp)
      return false if fainted? || selfHP >= @totalhp
      return false if @effects[PBEffects::HealBlock]>0
      return false if $fefieldeffect == 10
      return true
    end
  
    def canTakeHealingWish?
      # Also works with Lunar Dance.
      return canHeal? || pbHasAnyStatus?
    end
  
    def affectedByContactEffect?(showMsg=false)
      return false if fainted?
      if hasActiveItem?(:PROTECTIVEPADS)
        @battle.pbDisplay(_INTL("{1} protected itself with the {2}!",pbThis,itemName)) if showMsg
        return false
      end
      return true
    end
  
    def movedThisRound?
      return @lastRoundMoved && @lastRoundMoved==@battle.turnCount
    end
  
    def usingMultiTurnAttack?
      return true if @effects[PBEffects::TwoTurnAttack]
      return true if @effects[PBEffects::HyperBeam]>0
      return true if @effects[PBEffects::Rollout]>0
      return true if @effects[PBEffects::Outrage]>0
      return true if @effects[PBEffects::Uproar]>0
      return true if @effects[PBEffects::Bide]>0
      if $fefieldeffect == 24
        return true if @effects[PBEffects::Rage]
        eachOtherBattler do |b|
          return true if b.effects[PBEffects::TrappingUser] == @index
        end
      end
      return false
    end
  
    def inTwoTurnAttack?(*arg)
      return false if !@effects[PBEffects::TwoTurnAttack]
      ttaFunction = GameData::Move.get(@effects[PBEffects::TwoTurnAttack]).function_code
      arg.each { |a| return true if a==ttaFunction }
      return false
    end
  
    def semiInvulnerable?
      return inTwoTurnAttack?("0C9","0CA","0CB","0CC","0CD","0CE","14D")
    end
  
    def pbEncoredMoveIndex
      return -1 if @effects[PBEffects::Encore]==0 || !@effects[PBEffects::EncoreMove]
      ret = -1
      eachMoveWithIndex do |m,i|
        next if m.id!=@effects[PBEffects::EncoreMove]
        ret = i
        break
      end
      return ret
    end
  
    def initialItem
      return @battle.initialItems[@index&1][@pokemonIndex]
    end
  
    def setInitialItem(newItem)
      @battle.initialItems[@index&1][@pokemonIndex] = newItem
    end
  
    def recycleItem
      return @battle.recycleItems[@index&1][@pokemonIndex]
    end
  
    def setRecycleItem(newItem)
      @battle.recycleItems[@index&1][@pokemonIndex] = newItem
    end
  
    def belched?
      return @battle.belch[@index&1][@pokemonIndex]
    end
  
    def setBelched
      @battle.belch[@index&1][@pokemonIndex] = true
    end
    
    def aromaVeilProtected?
      return true if hasActiveAbility?(:AROMAVEIL)
      eachAlly do |b|
        return true if b.hasActiveAbility?(:AROMAVEIL)
      end
      return false
    end
  
    #=============================================================================
    # Methods relating to this battler's position on the battlefield
    #=============================================================================
    # Returns whether the given position belongs to the opposing Pokémon's side.
    def opposes?(i=0)
      i = i.index if i.respond_to?("index")
      return (@index&1)!=(i&1)
    end
  
    # Returns whether the given position/battler is near to self.
    def near?(i)
      i = i.index if i.respond_to?("index")
      return @battle.nearBattlers?(@index,i)
    end
  
    # Returns whether self is owned by the player.
    def pbOwnedByPlayer?
      return @battle.pbOwnedByPlayer?(@index)
    end
  
    # Returns 0 if self is on the player's side, or 1 if self is on the opposing
    # side.
    def idxOwnSide
      return @index&1
    end
  
    # Returns 1 if self is on the player's side, or 0 if self is on the opposing
    # side.
    def idxOpposingSide
      return (@index&1)^1
    end
  
    # Returns the data structure for this battler's side.
    def pbOwnSide
      return @battle.sides[idxOwnSide]
    end
  
    # Returns the data structure for the opposing Pokémon's side.
    def pbOpposingSide
      return @battle.sides[idxOpposingSide]
    end
  
    # Yields each unfainted ally Pokémon.
    def eachAlly
      @battle.battlers.each do |b|
        yield b if b && !b.fainted? && !b.opposes?(@index) && b.index!=@index
      end
    end
  
    # Yields each unfainted opposing Pokémon.
    def eachOpposing
      @battle.battlers.each { |b| yield b if b && !b.fainted? && b.opposes?(@index) }
    end
  
    # Returns the battler that is most directly opposite to self. unfaintedOnly is
    # whether it should prefer to return a non-fainted battler.
    def pbDirectOpposing(unfaintedOnly=false)
      @battle.pbGetOpposingIndicesInOrder(@index).each do |i|
        next if !@battle.battlers[i]
        break if unfaintedOnly && @battle.battlers[i].fainted?
        return @battle.battlers[i]
      end
      # Wanted an unfainted battler but couldn't find one; make do with a fainted
      # battler
      @battle.pbGetOpposingIndicesInOrder(@index).each do |i|
        return @battle.battlers[i] if @battle.battlers[i]
      end
      return @battle.battlers[(@index^1)]
    end
  
    def pbSwapOwnSideEffect(effect)
      effect  = getConst(PBEffects,effect) if effect.is_a?(Symbol)
      ownside = pbOwnSide
      oppside = pbOpposingSide
      toSwap  = ownside.effects[effect]
      ownside.effects[effect] = oppside.effects[effect]
      oppside.effects[effect] = toSwap
    end
  # BEGIN
    #=============================================================================
    # Custom Miscellaneous Methods
    #=============================================================================
    def takesFieldDamage?
      return false if semiInvulnerable? || hasActiveAbility?(:INVISIBLEWALL) || @effects[PBEffects::Protect] || 
                      pbOwnSide.effects[PBEffects::WideGuard] || @effects[PBEffects::KingsShield] || 
                      @effects[PBEffects::SpikyShield] || @effects[PBEffects::BanefulBunker] ||
                      @effects[PBEffects::Obstruct] || pbOwnSide.effects[PBEffects::MatBlock]
      return true
    end
    
    def reducesFieldFullKO?
      return hasActiveAbility?(:STURDY) || @effects[PBEffects::Endure]
    end
    
    def activateFlashFire
      if !@effects[PBEffects::FlashFire]
        @effects[PBEffects::FlashFire]=true
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Fire power!",pbThis,abilityName))
      end
    end
    
    # Input also overrides Heavy-Duty Boots (Pokemon cannot be airborne on this field)
    def takesVolcanicFieldDamage?(ignoreAirborne=false)
      return !pbHasType?(:FIRE) && !@effects[PBEffects::AquaRing] && !hasActiveAbility?([:FLAREBOOST,
             :WATERVEIL,:FLASHFIRE,:HEATPROOF,:FLAMEBODY,:WATERBUBBLE]) && !(hasActiveAbility?(:DISGUISE,false,true) && 
             @form == 0 && @pokemon.getNumForms >= 1) && (!hasActiveItem?(:HEAVYDUTYBOOTS) || 
             ignoreAirborne)
    end
  
    def takesCorrosiveFieldDamage?(ignoreAirborne=false)
      return !pbHasType?(:POISON) && !hasActiveAbility?([:POISONHEAL,:IMMUNITY,:WONDERGUARD,
             :TOXICBOOST,:PASTELVEIL,:OVERCOAT]) && !(hasActiveAbility?(:DISGUISE,false,true) && 
             @form == 0 && @pokemon.getNumForms >= 1) && (grounded? || ignoreAirborne) &&
             !hasActiveItem?(:HEAVYDUTYBOOTS)
    end
    
    def affectedByMurkwaterSurface?
      return !pbHasType?(:STEEL) && !pbHasType?(:POISON) && !hasActiveAbility?([:POISONHEAL,
             :WONDERGUARD,:TOXICBOOST,:THICKFAT,:STICKYHOLD,:IMMUNITY,:FILTER,:TOUGHBARK,
             :OVERCOAT]) && grounded?
    end
           
    def canBewitchedMark?
      return !@effects[PBEffects::BewitchedMark] && !hasActiveAbility?([:DISGUISE,
             :JUSTIFIED,:QUEENLYMAJESTY,:SOULHEART,:DIVINE])
    end
    
    def takesUnderwaterFieldDamage?
      return weakToType?(:WATER) && !hasActiveAbility?(:SWIFTSWIM) || hasActiveAbility?([:FLAMEBODY,:MAGMAARMOR])
    end
    
    def fallsIntoVolcano?
      return !pbHasType?(:FIRE) && !hasActiveAbility?([:MAGMAARMOR,:FLASHFIRE,:FLAREBOOST,
             :BLAZE,:FLAMEBODY,:SOLIDROCK,:STURDY,:BATTLEARMOR,:SHELLARMOR,:WATERBUBBLE,
             :PRISMARMOR,:HEATPROOF,:WONDERGUARD]) && !@effects[PBEffects::AquaRing] &&
             grounded? && !hasActiveItem?(:FLOATSTONE)
    end
  
    def takesCorruptedCaveDamage?
      return !pbHasType?(:POISON) && !pbHasType?(:ROCK) && !pbHasType?(:STEEL) &&
             !hasActiveAbility?([:WONDERGUARD,:IMMUNITY,:LIQUIDOOZE,:TOUGHBARK]) && 
             !(hasActiveAbility?(:DISGUISE) && @damageState.disguise) && !hasActiveItem?(:HEAVYDUTYBOOTS)
    end
    
    def affectedBySwamp?
      return @turnCount > 0 && !hasActiveAbility?([:QUICKFEET,:SUCTIONCUPS,:WATERVEIL,:SWIFTSWIM]) &&
             @battle.pbWeather != :Sun && !hasActiveItem?(:HEAVYDUTYBOOTS)
    end
    
    def affectedByCorrosiveMist?
      return pbCanPoison?(nil,false) && !hasActiveAbility?([:LIQUIDOOZE,:AIRLOCK,:FILTER])
    end
    
    def affectedByShortCircuit?
      return pbCanParalyze?(nil,false) && !hasActiveAbility?([:BATTERY,:ELECTRICSURGE,
             :FULLMETALBODY,:GALVANIZE,:LIGHTNINGROD,:MOTORDRIVE,:PLUS,:MINUS,:STATIC,
             :TERAVOLT,:TRANSISTOR,:ELECTROPLATE]) && grounded? && !pbHasType?(:STEEL)
    end
    
    def weakToType?(t)
      return Effectiveness.super_effective_type?(t,@type1,@type2,@effects[PBEffects::Type3])
    end
  
    # Field Transformations/Interruptions
    def checkFieldTransformations(move)
      case $fefieldeffect
      when 1 # Electric Terrain
        if move.id == :MUDSPORT
          @battle.changeField(0,"The electricity dissipated!",1) # Duration handled elsewhere
        elsif move.id == :MUDDYWATER
          @battle.changeField(0,"The mud absorbed the electricity!",5,hasTerrainExtender?)
        elsif move.id == :MUDBOMB
          @battle.changeField(0,"The mud absorbed the electricity!",3,hasTerrainExtender?)
        end
      when 2 # Grassy Terrain
        if [:SLUDGEWAVE,:ACIDDOWNPOUR].include?(move.id)
          @battle.changeField(10,"The grassy terrain was corroded!",5,hasTerrainExtender?,true)
        elsif [:ERUPTION,:LAVAPLUME,:FLAMEBURST,:INCINERATE,:SEARINGSHOT,:FIREPLEDGE,
               :BURNUP,:MAGMASTORM,:INFERNOOVERDRIVE,:INFERNO].include?(move.id)
          @battle.changeField(0,"The grass was burned up!")
        elsif move.id == :ROTOTILLER
          @battle.changeField(33,"The fertile land was tilled into a garden!",0,false,true)
        end
      when 3 # Misty Terrain
        if move.windMove? || [:DEFOG,:CLEARSMOG].include?(move.id)
          @battle.changeField(0,"The mist was blown away!",5,hasTerrainExtender?)
        elsif move.id == :GRAVITY
          @battle.changeField(0,"The mist collected on the ground!",1) # Duration handled elsewhere
        elsif move.id == :TAILWIND
          @battle.changeField(0,"The mist was blown away!",1) # Duration handled elsewhere
        elsif [:CORROSIVEGAS,:SMOG,:POISONGAS,:ACIDSPRAY].include?(move.id)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("Poison spread through the mist!"))
          when 2
            @battle.changeField(11,"The mist was corroded!",0,false,true)
          end
        elsif move.id == :ACIDDOWNPOUR
          @battle.changeField(11,"The mist was corroded!",0,false,true)
        end
      when 4 # Dark Crystal Cavern
        if move.id == :SUNNYDAY
          @battle.changeField(25,"The sun lit up the crystal cavern!",1,false,true) # Duration handled elsewhere
        elsif [:EARTHQUAKE,:BULLDOZE,:MAGNITUDE,:SELFDESTRUCT,:EXPLOSION,:ROCKWRECKER,
              :STEELROLLER,:ALLOUTPUMMELING,:TECTONICRAGE,:CONTINENTALCRUSH].include?(move.id)
          @battle.changeField(23,"The dark crystals were shattered!",0,false,true,true)
        elsif [:CHARGEBEAM,:WILDCHARGE].include?(move.id)
          @battle.changeField(25,"The dark crystals were filled with energy!",5,hasTerrainExtender?,true)
        end
      when 5 # Chess Board
        if [:STOMPINGTANTRUM,:TECTONICRAGE].include?(move.id)
          @battle.changeField(0,"The board was destroyed!")
        elsif [:REVERSAL,:TRICK,:SWITCHEROO,:SKILLSWAP,:GUARDSWAP,:HEARTSWAP,:ALLYSWITCH,
              :SPEEDSWAP,:FLIPTURN,:TRICKROOM,:COURTCHANGE].include?(move.id)
          if $fecounter < 6 # White
            $fecounter+=6
            fieldColor = "Black"
          else # Black
            $fecounter-=6
            fieldColor = "White"
          end
          @battle.changeFieldBG
          @battle.pbDisplay(_INTL("{1} changed the field to {2}'s turn!",pbThis,fieldColor))
        elsif move.chessMove?(self) || hasActiveAbility?(:MAGICIAN) && @battle.pbRandom(2) == 0
          @battle.rotateChessField
        end
      when 6 # Performance Stage
        if [:STEAMROLLER,:BULLDOZE,:ROCKWRECKER].include?(move.id)
          @battle.changeField(44,"The stage was destroyed!",0,false,true)
        elsif [:TAUNT,:TORMENT,:SWAGGER].include?(move.id)
          @battle.changeField(45,"The performers turned against each other, ready to fight!",5,hasTerrainExtender?,true)
        end
      when 7 # Volcanic Field
        if move.id == :WATERSPORT
          @battle.changeField(23,"The water snuffed out the flames!",1) # Duration handled elsewhere
        elsif move.id == :RAINDANCE
          @battle.changeField(23,"The water extinguished the flames!",1) # Duration handled elsewhere
        elsif move.id == :MUDSPORT
          @battle.changeField(23,"The mud snuffed out the flames!",1) # Duration handled elsewhere
        elsif move.id == :DIG && @effects[PBEffects::TwoTurnAttack] # Charging turn
          if hasActiveAbility?(:FLASHFIRE)
            activateFlashFire
          elsif takesVolcanicFieldDamage?(true)
            quotient = 4
            quotient /= 2 if hasActiveAbility?([:LEAFGUARD,:ICEBODY,:FLUFFY,:GRASSPELT,:FURCOAT,:TOUGHBARK,:COTTONDOWN])
            pbInflictTypeScalingFixedDamage(:FIRE,@totalhp/quotient,_INTL("{1} dug into the magma!",pbThis))
          end
        elsif [:SLUDGEWAVE,:ACIDDOWNPOUR].include?(move.id)
          @battle.changeField(41,"The grime covered the magma!",5,hasTerrainExtender?)
        elsif [:SURF,:MUDDYWATER,:WATERSPOUT,:WATERPLEDGE,:TSUNAMI,:HYDROVORTEX].include?(move.id)
          @battle.changeField(23,"The water extinguished the flames!",5,hasTerrainExtender?)
        elsif move.id == :GLACIATE
          @battle.changeField(23,"The magma solidified!",5,hasTerrainExtender?)
        elsif move.id == :CONTINENTALCRUSH
          @battle.changeField(23,"The fire was smothered!",5,hasTerrainExtender?,true)
        elsif [:DRAGONFLEET,:DEVASTATINGDRAKE].include?(move.id)
          @battle.changeField(32,"Dragons inhabited the terrain!",0)
        end
      when 8 # Swamp
        if [:DIG,:DIVE].include?(move.id) && @effects[PBEffects::TwoTurnAttack] # Charging turn
          if pbReduceHP(@totalhp,true,true,true,true)
            @battle.pbDisplay(_INTL("The swamp devoured {1}!",pbThis(true)))
          end
        elsif move.id == :HEATWAVE
          @battle.changeField(0,"The swamp dried up!",5,hasTerrainExtender?)
        end
      when 9 # Rainbow Field
        if [:HAIL,:SANDSTORM].include?(move.id)
          @battle.changeField(0,"The weather blocked out the rainbow!",1) # Duration handled elsewhere
        elsif move.id == :DEFOG
          @battle.changeField(0,"The rainbow cleared!")
        elsif move.id == :LIGHTTHATBURNSTHESKY
          @battle.changeField(0,"The rainbow's light was consumed!",5)
        end
      when 10 # Corrosive Field
        if move.id == :GEOMANCY
          @battle.changeField(2,"The field was purified!")
        elsif [:MAGICCOAT,:PSYCHICTERRAIN,:PSYCHIC,:MAGICPOWDER,:SHATTEREDPSYCHE].include?(move.id)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("The corrosion began to morph!"))
          when 2
            @battle.changeField(19,"The corrosion started moving on its own!",5,hasTerrainExtender?)
          end
        elsif [:MISTYTERRAIN,:CORROSIVEGAS,:MISTGUARD,:POISONGAS].include?(move.id)
          @battle.changeField(11,"The corrosion spread through the air!",5,hasTerrainExtender?)
        elsif [:DIG,:DIVE].include?(move.id) && @effects[PBEffects::TwoTurnAttack] &&
              takesCorrosiveFieldDamage?(true)
          pbInflictTypeScalingFixedDamage(:POISON,@totalhp/2,_INTL("{1} was seared by the corrosion!",pbThis))
        elsif [:SEEDFLARE,:PURIFY,:NATURESMADNESS].include?(move.id)
          @battle.changeField(2,"The field was purified!")
        end
      when 11 # Corrosive Mist Field
        if move.id == :TAILWIND
          @battle.changeField(0,"The toxic mist was blown away!",1) # Duration handled elsewhere
        elsif move.id == :GRAVITY
          @battle.changeField(10,"The toxic mist collected on the ground!",1) # Duration handled elsewhere
        elsif [:LAVAPLUME,:FLAMEBURST,:SEARINGSHOT,:SELFDESTRUCT,:EXPLOSION,:ERUPTION,
              :FIREPLEDGE,:BLASTBURN,:OVERHEAT,:MAGMASTORM,:FUSIONFLARE,:BURNUP,:INFERNOOVERDRIVE].include?(move.id)
          if !@battle.dampBattler?
            @battle.eachBattler do |b|
              next if !b.takesFieldDamage?
              if b.hasActiveAbility?(:FLASHFIRE)
                b.activateFlashFire
                next
              end
              if b.reducesFieldFullKO?
                fieldDamage = b.hp - 1
              else
                fieldDamage = b.hp
              end
              if b.pbHasType?(:FIRE)
                fieldDamage /= 2
              end
              b.pbReduceHP(fieldDamage)
            end
            @battle.changeField(0,"The corrosive mist combusted!",0,false,true,true)
          else
            @battle.pbDisplay(_INTL("The dampness prevented a complete explosion!"))
          end
        elsif [:HURRICANE,:WHIRLWIND,:DEFOG,:CLEARSMOG].include?(move.id)
          @battle.changeField(0,"The corrosive mist was blown away!",5,hasTerrainExtender?)
        elsif [:PURIFY,:SEEDFLARE].include?(move.id)
          @battle.changeField(3,"The corrosive mist was purified!",5,hasTerrainExtender?)
        end
      when 12 # Desert
        if [:GROWTH,:ROTOTILLER,:GRASSYTERRAIN,:GEOMANCY].include?(move.id)
          @battle.changeField(49,"The desert grew some shrubs!",5,hasTerrainExtender?,true)
        end
      when 13 # Icy Cave
        if [:THRASH,:EARTHQUAKE,:MAGNITUDE,:EXPLOSION,:SELFDESTRUCT,:ICICLESPEAR,:SKYUPPERCUT,
           :HAMMERARM,:ROCKWRECKER,:WOODHAMMER,:SMACKDOWN,:BULLDOZE,:ICICLECRASH,:ICEHAMMER,
           :DRAGONHAMMER,:DOUBLEIRONBASH,:SUBZEROSLAMMER].include?(move.id)
          @battle.eachBattler do |b|
            next if !b.takesFieldDamage?
            numIcicles = 0
            for i in 0...3
              if @battle.pbRandom(3) == 0
                numIcicles += 1
                b.pbInflictTypeScalingFixedDamage(:ICE,b.totalhp/10)
              end
            end
            if numIcicles > 0
              @battle.pbDisplay(_INTL("{1} icicle(s) came crashing down on {2}!",numIcicles,b.pbThis(true)))
            end
          end
        elsif [:HEATWAVE,:ERUPTION,:SEARINGSHOT,:FIREPLEDGE,:LAVAPLUME,:OVEREHEAT,
              :BLASTBURN,:MAGMASTORM,:INFERNOOVERDRIVE].include?(move.id)
          @battle.changeField(23,"The ice melted away!",5,hasTerrainExtender?)
        end
      when 14 # Rocky Field
        if [:STEAMROLLER,:STEELROLLER].include?(move.id)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("The terrain begins to flatten!"))
          when 2
            @battle.changeField(0,"The terrain was leveled!")
          end
        end
      when 15 # Forest Field
        if [:GROWTH,:GRASSYTERRAIN].include?(move.id)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("The forest grew some more trees!"))
          when 2
            @battle.changeField(47,"The forest grew into a jungle!",0,false,true,true)
          end
        elsif [:MAGICCOAT,:PSYCHICTERRAIN,:PSYCHIC,:HYPNOSIS,:NIGHTSHADE,:PSYWAVE,
              :FORESTSCURSE,:HEX,:MAGICPOWDER,:POLTERGEIST,:EERIESPELL,:NEVERENDINGNIGHTMARE,
              :TRICKORTREAT].include?(move.id)
          @battle.changeField(42,"The forest was infused with magical energy!",5,hasTerrainExtender?,true)
        elsif [:MAGICROOM,:TELEKINESIS].include?(move.id)
          @battle.changeField(42,"The forest was infused with magical energy!",1) # Duration handled elsewhere
        end
      when 16 # Volcanic Top Field
        if [:SURF,:MUDDYWATER,:WATERSPOUT,:SPARKLINGARIA,:SCALD,:STEAMERUPTION,:WATERSPORT,
           :LIFEDEW,:BUBBLEBEAM,:BUBBLE,:WHIRLPOOL,:TSUNAMI,:MISTSLASH,:OCEANICOPERETTA].include?(move.id)
          @battle.pbDisplay(_INTL("Steam shot up from the attack!"))
          @battle.eachBattler do |b|
            next if b.semiInvulnerable? || b.effects[PBEffects::SkyDrop] >= 0
            b.pbLowerStatStage(:ACCURACY,1)
          end
        elsif move.windMove?
          @battle.pbDisplay(_INTL("The attack stirred up the ash in the air!"))
          @battle.eachBattler do |b|
            next if b.semiInvulnerable? || b.effects[PBEffects::SkyDrop] >= 0 || !b.takesSandstormDamage?
            b.pbLowerStatStage(:ACCURACY,1)
          end
        elsif [:FLY,:BOUNCE].include?(move.id)
          @battle.changeField(43,"The battle was taken to the skies!",0,false,true)
        elsif move.id == :DIG
          @battle.changeField(7,"Dug into the volcano!",0,false,true,true)
        elsif [:BLIZZARD,:GLACIATE,:SHEERCOLD,:SUBZEROSLAMMER].include?(move.id)
          @battle.changeField(27,"The volcano cooled down!",5,hasTerrainExtender?)
        elsif [:BULLDOZE,:EARTHQUAKE,:MAGNITUDE,:ERUPTION,:PRECIPICEBLADES,:LAVAPLUME,
              :FISSURE,:TECTONICRAGE].include?(move.id)
          if !@battle.dampBattler?
            @battle.field.effects[PBEffects::VolTopEruption] = true
            @battle.pbDisplay(_INTL("The volcano erupted!"))
          end
        end
      when 17 # Factory Field
        if [:EXPLOSION,:SELFDESTRUCT,:MAGNITUDE,:EARTHQUAKE,:FISSURE,:BULLDOZE,:TECTONICRAGE].include?(move.id)
          @battle.changeField(18,"The machinery was broken!",0,false,true,true)
        elsif [:SURF,:MUDDYWATER,:TSUNAMI,:IONDELUGE,:DISCHARGE,:HYDROVORTEX,:GIGAVOLTHAVOC,
              :TENMILLIONVOLTTHUNDERBOLT].include?(move.id)
          @battle.changeField(18,"The machinery shorted out!",0,false,true,true)
        elsif [:HEATWAVE,:OVERHEAT].include?(move.id)
          @battle.changeField(18,"The machinery overheated and ceased to function!",0,false,true,true)
        elsif move.id == :ELECTRICTERRAIN
          @battle.changeField(1,"A burst of electric currents overtook the battlefield!",5,hasTerrainExtender?)
        end
      when 18 # Short-Circuit Field
        if [:IONDELUGE,:CHARGE,:ELECTRICTERRAIN,:OVERCLOCK,:PARABOLICCHARGE,:WILDCHARGE,
           :CHARGEBEAM,:AURAWHEEL,:OVERDRIVE,:TURBODRIVE,:DISCHARGE,:GIGAVOLTHAVOC].include?(move.id)
          @battle.changeField(17,"SYSTEM ONLINE.",0,false,true,true)
        end
      when 19 # Wasteland
        if move.id == :GEOMANCY
          @battle.changeField(37,"The murk was eradicated!",5,hasTerrainExtender?,true)
        end
      when 20 # Ashen Beach
        if move.id == :TAILWIND
          @battle.changeField(48,"The ash blew away!",1,false,true) # Duration handled elsewhere
        elsif !(@battle.pbWeather == :Rain || @battle.field.effects[PBEffects::Gravity]>0) && 
              (move.windMove? || [:LEAFTORNADO,:FIRESPIN,:WHIRLPOOL,:RAPIDSPIN,:GYROBALL,
              :DUSTSTORM,:HYDROVORTEX].include?(move.id))
          @battle.pbDisplay(_INTL("The attack stirred up the ash on the ground!"))
          @battle.eachBattler do |b|
            next if b.semiInvulnerable? || b.effects[PBEffects::SkyDrop] >= 0 || !b.takesSandstormDamage?
            b.pbLowerStatStage(:ACCURACY,1)
          end
        elsif [:MAGNITUDE,:EARTHQUAKE].include?(move.id)
          @battle.changeField(48,"The disturbance in the ground shuffled the ash below the sand!",5,hasTerrainExtender?)
        end
      when 21 # Water Surface
        if move.id == :GRAVITY
          @battle.changeField(22,"The battle sank into the depths!",1,false,true) # Duration handled elsewhere
        elsif move.id == :SHOREUP
          @battle.changeField(48,"Land ho!",0,false,true,true)
        elsif [:DIVE,:ANCHORSHOT].include?(move.id)
          @battle.changeField(22,"The battle was pulled underwater!",0,false,true,true)
        elsif [:BLIZZARD,:GLACIATE,:SHEERCOLD].include?(move.id)
          @battle.changeField(46,"The water froze over!",5,hasTerrainExtender?,true)
        elsif move.id == :SLUDGEWAVE
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("Poison spread through the water!"))
          when 2
            @battle.changeField(26,"The water was polluted!",5,hasTerrainExtender?,true)
          end
        elsif move.id == :ACIDDOWNPOUR
          @battle.changeField(26,"The water was polluted!",5,hasTerrainExtender?,true)
        end
      when 22 # Underwater
        if move.id == :SHOREUP
          @battle.changeField(48,"Land ho!",0,true,true)
        elsif [:DIVE,:SKYDROP,:FLY,:BOUNCE,:SEISMICTOSS].include?(move.id)
          @battle.changeField(21,"The battle resurfaced!",0,false,true,true)
        elsif move.id == :SLUDGEWAVE
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("Poison spread through the water!"))
          when 2
            @battle.changeField(26,"The water was polluted, and the grime sank beneath the Pokémon!",5,hasTerrainExtender?,true)
          end
        elsif move.id == :ACIDDOWNPOUR
          @battle.changeField(26,"The water was polluted, and the grime sank beneath the Pokémon!",5,hasTerrainExtender?,true)
        end
      when 23 # Cave
        if [:EARTHQUAKE,:MAGNITUDE,:BULLDOZE,:FISSURE,:EXPLOSION,:SELFDESTRUCT,:ROCKSLIDE,
           :TECTONICRAGE,:CONTINENTALCRUSH].include?(move.id)
          $fecounter+=1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("Bits of rock fell from the crumbling ceiling!"))
          when 2
            @battle.eachBattler do |b|
              next if !b.takesFieldDamage? || b.hasActiveAbility?([:BULLETPROOF,:ROCKHEAD,:DAUNTLESSSHIELD])
              if b.reducesFieldFullKO?
                fieldDamage = b.hp - 1
              else
                fieldDamage = b.hp
              end
              if b.hasActiveAbility?([:SOLIDROCK,:MIRRORARMOR])
                fieldDamage /= 3
              end
              if b.hasActiveAbility?([:SHELLARMOR,:BATTLEARMOR])
                fieldDamage /= 2
              end
              b.pbReduceHP(fieldDamage)
            end
            @battle.changeField(14,"The quake collapsed the ceiling!",0,false,true,true)
          end
        elsif [:POWERGEM,:DIAMONDSTORM].include?(move.id)
          @battle.changeField(25,"The cave was littered with crystals!",0,false,true,true)
        elsif [:ERUPTION,:LAVAPLUME].include?(move.id)
          @battle.changeField(7,"Magma emerges through the floor!",0,false,true,true)
        elsif [:SLUDGEWAVE,:ACIDDOWNPOUR].include?(move.id)
          @battle.changeField(41,"The cave was corrupted!",0,false,true)
        elsif [:BLIZZARD,:GLACIATE,:SHEERCOLD,:SUBZEROSLAMMER].include?(move.id)
          @battle.changeField(13,"The cave froze up!",5,hasTerrainExtender?,true)
        elsif [:DRAGONRAGE,:DRAGONFLEET,:DRAGONENERGY].include?(move.id)
          @battle.changeField(32,"The cave became home to a dragon!",5,hasTerrainExtender?,true)
        end
      when 24 # Glitch Field
        if move.id == :REFRESH
          @battle.changeField(0,"Systems refreshed!",0,false,true,true)
        end
      when 25 # Crystal Cavern
        if move.id == :GRASSYTERRAIN
          @battle.changeCrystalBackground(2)
        elsif move.id == :MISTYTERRAIN
          @battle.changeCrystalBackground(4)
        elsif move.id == :ELECTRICTERRAIN
          @battle.changeCrystalBackground(3)
        elsif move.id == :PSYCHICTERRAIN
          @battle.changeCrystalBackground(6)
        elsif [:DARKPULSE,:DARKVOID,:NIGHTDAZE,:NIGHTSHADE].include?(move.id)
          @battle.changeField(4,"The crystal's light was warped by the darkness!",5,hasTerrainExtender?,true)
        elsif [:BULLDOZE,:EARTHQUAKE,:MAGNITUDE,:EXPLOSION,:SELFDESTRUCT,:ROCKWRECKER,
              :STEELROLLER,:ALLOUTPUMMELING,:TECTONICRAGE,:CONTINENTALCRUSH].include?(move.id)
          @battle.changeField(23,"The crystals were shattered!",0,false,true,true)
        elsif move.id == :LIGHTTHATBURNSTHESKY
          @battle.changeField(4,"All the crystals' light was consumed!",0,false,true)
        end
      when 26 # Murkwater Surface
        if [:WHIRLPOOL,:BLADEMAELSTROM,:HYDROVORTEX].include?(move.id)
          @battle.changeField(21,"The maelstrom flushed out the poison!",5,hasTerrainExtender?,true)
        elsif [:SEEDFLARE,:PURIFY,:MISTYTERRAIN].include?(move.id)
          @battle.changeField(21,"The murk was purified!",5,hasTerrainExtender?,true)
        elsif [:BLIZZARD,:GLACIATE].include?(move.id)
          @battle.changeField(46,"The toxic water froze over!",5,hasTerrainExtender?,true)
        end
      when 27 # Mountain
        if [:FLY,:BOUNCE].include?(move.id)
          @battle.changeField(43,"The battle was taken to the skies!",0,false,true,true)
        elsif [:BLIZZARD,:SHEERCOLD,:GLACIATE].include?(move.id)
          @battle.changeField(28,"The mountain was covered in snow!",5,hasTerrainExtender?,true)
        elsif move.id == :ERUPTION || move.id == :LAVAPLUME
          @battle.changeField(16,"The mountain erupted!",0,false,true,true)
        elsif move.id == :DIG
          @battle.changeField(23,"Dug into the mountain!",0,false,true,true)
        elsif move.id == :SUBZEROSLAMMER
          @battle.changeField(28,"The mountain froze over!",5,hasTerrainExtender?,true)
        end
      when 28 # Snowy Mountain
        if [:FLY,:BOUNCE].include?(move.id)
          @battle.changeField(43,"The battle was taken to the skies!",0,false,true,true)
        elsif [:HEATWAVE,:SEARINGSHOT,:FLAMEBURST,:FIREPLEDGE,:INFERNOOVERDRIVE].include?(move.id)
          @battle.changeField(27,"The snow melted away!",hasTerrainExtender?,5)
        elsif [:ERUPTION,:LAVAPLUME].include?(move.id)
          @battle.changeField(16,"The mountain erupted!",0,false,true,true)
        elsif move.id == :DIG
          @battle.changeField(13,"Dug into the mountain!",0,false,true,true)
        end
      when 29 # Holy
        if [:CURSE,:PHANTOMFORCE,:TRICKORTREAT,:SHADOWFORCE,:NEVERENDINGNIGHTMARE].include?(move.id)
          @battle.changeField(40,"Evil spirits gathered!",5,hasTerrainExtender?)
        elsif [:LIGHTTHATBURNSTHESKY,:DARKVOID].include?(move.id)
          @battle.changeField(0,"The holy light was consumed!",5,hasTerrainExtender?)
        elsif move.id == :GLACIATE
          @battle.changeField(39,"The holy land froze over!",0,false,true)
        elsif move.id == :GRASSYTERRAIN
          @battle.changeField(31,"The field morphed into a magical fairy tale!",5,hasTerrainExtender?,true)
        end
      when 30 # Mirror Arena
        if [:EARTHQUAKE,:BULLDOZE,:BOOMBURST,:HYPERVOICE,:MAGNITUDE,:TECTONICRAGE,
           :SONICBOOM,:SELFDESTRUCT,:EXPLOSION,:STEELROLLER,:CONTINENTALCRUSH,:SHATTEREDPSYCHE,
           :SPLINTEREDSTORMSHARDS].include?(move.id)
          @battle.eachBattler do |b|
            next if !b.takesFieldDamage? || b.hasActiveAbility?([:SHELLARMOR,:BATTLEARMOR,
                    :BULLETPROOF,:PRISMARMOR,:DAUNTLESSSHIELD,:MIRRORARMOR])
            b.pbInflictTypeScalingFixedDamage(:STEEL,b.totalhp/2)
          end
          @battle.changeField(0,"The mirror arena shattered!",0,false,true,true)
        end
      when 32 # Dragon's Den
        if move.id == :CONTINENTALCRUSH
          @battle.changeField(23,"The draconic presence was crushed!",0,false,true,true)
        end
      when 33 # Flower Garden Field
        if [:GROWTH,:FLOWERSHIELD,:RAINDANCE,:SUNNYDAY,:ROTOTILLER,:BLOOMDOOM,:WATERSPORT,
           :SOAK,:GRASSPLEDGE,:GRASSYTERRAIN,:GEOMANCY,:POLLENPUFF,:GUARDIANOFALOLA,
           :LIFEDEW].include?(move.id)
          @battle.changeFlowerGardenStage(1)
        elsif [:HEATWAVE,:ERUPTION,:SEARINGSHOT,:FLAMEBURST,:LAVAPLUME,:BLASTBURN,
              :INCINERATE,:BURNUP].include?(move.id) && @battle.field.effects[PBEffects::WaterSportField] == 0 && 
              ![:Rain,:HeavyRain].include?(@battle.pbWeather)
          @battle.changeFlowerGardenStage(-1)
        elsif move.slashingMove? || [:ACID,:ACIDSPRAY,:POISONGAS,:BLIZZARD,:SLUDGEWAVE,
              :SUBZEROSLAMMER,:CORROSIVEGAS].include?(move.id)
          @battle.changeFlowerGardenStage(-1)
        elsif $fecounter > 0
          if move.id == :ACIDDOWNPOUR
            @battle.pbDisplay(_INTL("The plants were disintegrated!"))
            @battle.changeFlowerGardenStage(-5)
          elsif move.id == :INFERNOOVERDRIVE
            @battle.pbDisplay(_INTL("The garden was burnt to the ground!"))
            @battle.changeFlowerGardenStage(-5)
          end
        end
      when 34 # Starlight Arena
        if move.id == :LIGHTTHATBURNSTHESKY
          @battle.changeField(0,"The cosmic light was consumed!",5,hasTerrainExtender?)
        end
      when 35 # Ultra Space
        if move.id == :GEOMANCY
          @battle.changeField(34,"The world was regenerated!")
        elsif [:HYPERSPACEHOLE,:TELEPORT].include?(move.id)
          @battle.changeField(@battle.generateRandomField(true),"Into a new dimension!",5,hasTerrainExtender?)
        end
      when 38 # Dimensional Field
        if [:DIG,:DIVE,:FLY,:BOUNCE].include?(move.id) && @effects[PBEffects::TwoTurnAttack]
          @battle.pbDisplay(_INTL("The dimension engulfed {1}!",pbThis(true)))
          pbReduceHP(@totalhp,true,true,true,true)
        elsif [:BLIZZARD,:GLACIATE,:SHEERCOLD,:SUBZEROSLAMMER].include?(move.id)
          @battle.changeField(39,"The dimension froze up!",5,hasTerrainExtender?,true)
        elsif move.id == :MISTYTERRAIN
          @battle.changeField(0,"The dimension dissipated!",5,hasTerrainExtender?)
        end
      when 39 # Frozen Dimensional Field
        if [:HEATWAVE,:OVERHEAT,:FUSIONFLARE,:INFERNOOVERDRIVE].include?(move.id)
          @battle.changeField(38,"The ice melted away!",5,hasTerrainExtender?)
        elsif move.id == :DARKVOID
          @battle.changeField(38,"The dimension plunged into darkness!",5,hasTerrainExtender?)
        end
      when 40 # Haunted Field
        if [:JUDGMENT,:SACREDFIRE,:ORIGINPULSE,:FLASH,:DAZZLINGGLEAM,:PURIFY,:SEEDFLARE,
           :MISTYTERRAIN].include?(move.id)
          @battle.changeField(29,"The evil spirits have been exorcised!",5,hasTerrainExtender?)
        elsif [:IONDELUGE,:ELECTRICTERRAIN].include?(move.id)
          @battle.changeField(18,"The field was showered in electricity!",5,hasTerrainExtender?,true)
        elsif [:GRASSYTERRAIN,:BLOOMDOOM].include?(move.id)
          @battle.changeField(42,"A forest grew around the battlefield!",5,hasTerrainExtender?)
        elsif move.id == :PSYCHICTERRAIN
          @battle.changeField(37,"Strange energy enveloped the field!",5,hasTerrainExtender?)
        end
      when 41 # Corrupted Cave
        if [:SEEDFLARE,:PURIFY,:MISTYTERRAIN,:GEOMANCY].include?(move.id)
          @battle.changeField(23,"The cave's corruption was eradicated!")
        elsif [:ERUPTION,:LAVAPLUME].include?(move.id)
          @battle.changeField(7,"Magma emerges through the floor!",0,false,true,true)
        elsif [:BLIZZARD,:GLACIATE,:SHEERCOLD,:SUBZEROSLAMMER].include?(move.id)
          @battle.changeField(13,"The cave froze up!",5,hasTerrainExtender?,true)
        elsif [:EARTHQUAKE,:BULLDOZE,:TECTONICRAGE].include?(move.id)
          @battle.changeField(23,"The debris covered up the corruption!",5,hasTerrainExtender?)
        end
      when 42 # Bewitched Woods
        if [:HEALINGWISH,:PURIFY,:HEALPULSE,:FLORALHEALING].include?(move.id)
          @battle.changeField(15,"The forest was cleansed!",5,hasTerrainExtender?)
        elsif move.id == :SAFEGUARD
          @battle.changeField(15,"The forest was cleansed!",1) # Duration managed elsewhere
        end
      when 43 # Sky Field
        if [:INGRAIN,:SMACKDOWN,:THOUSANDARROWS].include?(move.id)
          @battle.changeField(27,"The battle has been brought down to the mountains!",0,false,true)
        elsif @id == :GRAVITY
          @battle.changeField(15,"The battle has been brought down to the mountains!",1) # Duration managed elsewhere
        elsif [:AURORABEAM,:PRISMATICLASER,:AURORAVEIL].include?(move.id)
          @battle.changeField(9,"A rainbow formed in the sky!",5,hasTerrainExtender?,true)
        elsif [:MIST,:MISTYTERRAIN,:STRANGESTEAM,:MISTGUARD].include?(move.id)
          @battle.changeField(3,"The clouds thickened into a misty fog!",5,hasTerrainExtender?,true)
        elsif [:DISCHARGE,:ELECTRICTERRAIN,:IONDELUGE].include?(move.id)
          @battle.changeField(1,"Static electricity ran throughout the clouds!",5,hasTerrainExtender?,true)
        end
      when 44 # Indoors
        if [:EARTHQUAKE,:FISSURE,:BULLDOZE,:JUMPKICK,:EXPLOSION,:SELFDESTRUCT,:THRASH,
           :DOUBLEEDGE,:EGGBOMB,:MAGNITUDE,:ERUPTION,:ROCKWRECKER,:HEADSMASH,:STEAMROLLER,
           :LANDSWRATH,:FLAREBLITZ,:TECTONICRAGE,:CONTINENTALCRUSH,:CORKSCREWCRASH,
           :BLACKHOLEECLIPSE,:CATASTROPIKA,:PULVERIZINGPANCAKE,:SPLINTEREDSTORMSHARDS,
           :BEHEMOTHBASH,:STEELROLLER,:DRACONICDISASTER].include?(move.id)
          @battle.pbDisplay(_INTL("A small part of the building crumbled!"))
          @battle.eachBattler do |b|
            if @battle.pbRandom(2) == 0
              next if !b.takesFieldDamage? || b.hasActiveAbility?([:SHELLARMOR,:BATTLEARMOR,:BULLETPROOF])
              if b.pbReduceHP(b.totalhp/3) > 0
                @battle.pbDisplay(_INTL("{1} was hit by a piece of falling rubble!",b.pbThis(true)))
              end
            end
          end
        elsif [:MIST,:MISTYTERRAIN,:AROMATICMIST].include?(move.id)
          @battle.changeField(3,"The mist engulfed the closed area!",5,hasTerrainExtender?,true)
        elsif move.id == :DECORATE
          @battle.changeField(6,"The area was decorated to resemble a performance stage!",0,false,true)
        elsif [:SMOG,:POISONGAS,:SMOKESCREEN,:HAZE,:CORROSIVEGAS].include?(move.id)
          if $fecounter == 0
            @battle.pbDisplay(_INTL("Toxic gas begins to fill the room..."))
          else
            @battle.changeField(11,"Corrosive mist engulfed the closed area!",5,hasTerrainExtender?,true)
          end
        elsif move.id == :ELECTRICTERRAIN
          @battle.changeField(18,"The electrical appliances shorted out!",5,hasTerrainExtender?,true)
        end
      when 46 # Subzero Field
        if [:OVERHEAT,:HEATWAVE,:INFERNOOVERDRIVE].include?(move.id)
          @battle.changeField(21,"The snow melted away...",5,hasTerrainExtender?)
        elsif move.id == :DIG
          @battle.changeField(13,"Down to the icy underdepths!",0,false,true,true)
        end
      when 47 # Jungle
        if move.slashingMove?
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("The attack lacerated the bark of some nearby trees!"))
          when 2
            @battle.changeField(15,"And down they went in one fell swoop!",0,false,true,true)
          end
        elsif [:FORESTSCURSE,:PSYCHICTERRAIN,:NEVERENDINGNIGHTMARE].include?(move.id)
          @battle.changeField(42,"The forestry was infused with magical energy!",0,false,true)
        end
      when 48 # Beach
        if [:LAVAPLUME,:ERUPTION].include?(move.id)
          @battle.changeField(20,"Ash and soot covered the beach!",0,false,true,true)
        elsif [:WHIRLPOOL,:DIVE].include?(move.id)
          @battle.changeField(21,"Going out to sea!",0,false,true,true)
        end
      when 49 # Xeric Shrubland
        if move.id == :SHOREUP
          @battle.changeField(48,"Finally found some water!",0,false,true)
        end
        if move.slashingMove? || [:INFERNO,:INFERNOOVERDRIVE].include?(move.id)
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("The shrubs began to disappear!"))
          when 2
            @battle.changeField(12,"No shrubs remain!",0,false,true,true)
          end
        end
      end
    end
  
    def pbRaiseCritRatio(increment,user=nil,message=nil)
      user.effects[PBEffects::CriticalBoost] += increment
      case increment
      when 1
        prefix = ""
      when 2
        prefix = " sharply"
      else
        prefix = " drastically"
      end
      if message.nil?
        if user.nil?
          @battle.pbDisplay(_INTL("{1}'s critical-hit ratio increased{2}!",pbThis,prefix))
        elsif user == self
          @battle.pbDisplay(_INTL("{1}{2} boosted its critical-hit ratio!",pbThis,prefix))
        else
          @battle.pbDisplay(_INTL("{1}{2} boosted {3}'s critical-hit ratio!",user.pbThis,prefix,pbThis(true)))
        end
      else
        @battle.pbDisplay(message)
      end
    end
    
    def highestStat
      bStats = plainStats
      highestStatValue = 0
      highestStats = []
      bStats.each_value { |value| highestStatValue = value if highestStatValue < value }
      GameData::Stat.each_main_battle do |s|
        if bStats[s.id] == highestStatValue
          highestStats.push(s.id)
        end
      end
      return highestStats[rand(highestStats.length)] # Random Highest Stat
    end
    
    def chooseSwitchOut(showMessages=false,switchMessage=nil)
      return if user.fainted?
      if !@battle.pbCanChooseNonActive?(user.index)
        @battle.pbDisplay(_INTL("There is nobody to which {1} can switch!",pbThis(true))) if showMessages
        return
      end
      if switchMessage.nil?
        switchMessage = _INTL("{1} went back to {2}!",pbThis,@battle.pbGetOwnerName(@index))
      end
      @battle.pbDisplay(switchMessage)
      @battle.pbPursuit(@index)
      return if fainted?
      newPkmn = @battle.pbGetReplacementPokemonIndex(@index)
      return if newPkmn<0
      @battle.pbRecallAndReplace(@index,newPkmn)
      @battle.pbClearChoice(@index) # Replacement Pokémon does nothing this round
      @battle.moldBreaker = false
      pbEffectsOnSwitchIn(true)
    end
    
    def forceSwitchOut(forcer,showMessages=false,switchMessage=nil)
      if hasSuctionCups? && !@battle.moldBreaker
        @battle.pbDisplay(_INTL("{1} anchors itself with {2}!",pbThis,abilityName)) if showMessages
        return
      end
      if @effects[PBEffects::Ingrain]
        @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",pbThis)) if showMessages
        return
      end
      if !@battle.canRun
        @battle.pbDisplay(_INTL("{1} can't switch {2} out!",pbThis,forcer.pbThis(true))) if showMessages
        return
      end
      if @battle.wildBattle? && @level > forcer.level
        @battle.pbDisplay(_INTL("{1} can't switch {2} out!",pbThis,forcer.pbThis(true))) if showMessages
        return
      end
      if @battle.trainerBattle?
        canSwitch = false
        @battle.eachInTeamFromBattlerIndex(@index) do |_pkmn,i|
          next if !@battle.pbCanSwitchLax?(@index,i)
          canSwitch = true
          break
        end
        if !canSwitch
          @battle.pbDisplay(_INTL("There is nobody to which {1} can switch!",pbThis(true))) if showMessages
          return
        end
      end
      if @battle.wildBattle?
        @battle.decision = 3 # Escaped from battle
      elsif !forcer.fainted? && !fainted?
        newPkmn = @battle.pbGetReplacementPokemonIndex(@index,true) # Random
        @battle.pbRecallAndReplace(@index,newPkmn,true)
        if switchMessage.nil?
          switchMessage = _INTL("{1} was dragged out!",pbThis)
        end
        @battle.pbDisplay(switchMessage)
        @battle.pbClearChoice(@index) # Replacement Pokémon does nothing this round
        pbEffectsOnSwitchIn(true)
      end
    end
    
    def sharesType?(battler,includeType3=false)
      for t in pbTypes(includeType3)
        if battler.pbHasType?(t)
          return true
        end
      end
      return false
    end
    
    def shuffleSpyGear
      if $fefieldeffect == 30
        @effects[PBEffects::SpyGear] = 0
      else
        @effects[PBEffects::SpyGear] = rand(3)+1
        case @effects[PBEffects::SpyGear]
        when 1
          @battle.pbDisplay(_INTL("{1}'s {2} activated its Winged Membrane.",pbThis,abilityName))
        when 2
          @battle.pbDisplay(_INTL("{1}'s {2} activated its Nictitating Precision.",pbThis,abilityName))
        when 3
          @battle.pbDisplay(_INTL("{1}'s {2} activated its Hidden Knife.",pbThis,abilityName))
        end
      end
    end
  
    def checkAlphabetizationForm(formNumber)
      return false if $fefieldeffect == 38 # Because disabled
      if $fefieldeffect == 29
        @battle.eachBattler do |b|
          next if !b.hasActiveAbility?(:ALPHABETIZATION)
          return true if b.form == formNumber
        end
        return false
      end
      return @form == formNumber
    end
    
    def likesBerryFlavor?(itemID=nil)
      if itemID.nil?
        itemID = @item_id
      end
      case @pokemon.nature_id
      when :ADAMANT,:BRAVE,:NAUGHTY,:LONELY # Spicy
        return [:ENIGMABERRY,:SPELONBERRY,:LIECHIBERRY,:PETAYABERRY,:LANSATBERRY,:STARFBERRY,
               :KEEBERRY,:BABIRIBERRY,:TAMATOBERRY,:TANGABERRY,:FIGYBERRY,:OCCABERRY,
               :CHOPLEBERRY,:CHERIBERRY,:LEPPABERRY,:ORANBERRY,:PERSIMBERRY,:LUMBERRY,
               :RAZZBERRY,:PINAPBERRY,:POMEGBERRY,:QUALOTBERRY,:HONDEWBERRY,:NOMELBERRY,
               :BELUEBERRY,:RINDOBERRY,:SHUCABERRY,:CHARTIBERRY,:APICOTBERRY,:ROWAPBERRY,
               :MARANGABERRY].include?(itemID)
      when :MODEST,:QUIET,:RASH,:MILD # Dry
        return [:MICLEBERRY,:KEEBERRY,:APICOTBERRY,:PAMTREBERRY,:GANLONBERRY,:CHILANBERRY,
               :CHARTIBERRY,:CORNNBERRY,:WIKIBERRY,:PASSHOBERRY,:KEBIABERRY,:ENIGMABERRY,
               :SPELONBERRY,:LIECHIBERRY,:LANSATBERRY,:STARFBERRY,:BABIRIBERRY,:TAMATOBERRY,
               :ORANBERRY,:PERSIMBERRY,:LUMBERRY,:RAZZBERRY,:HONDEWBERRY,:MARANGABERRY,
               :CHESTOBERRY,:SITRUSBERRY,:BLUKBERRY,:KELPSYBERRY,:GREPABERRY,:YACHEBERRY,
               :COBABERRY,:KASIBBERRY].include?(itemID)
      when :TIMID,:JOLLY,:NAIVE,:HASTY # Sweet
        return [:CUSTAPBERRY,:LIECHIBERRY,:LANSATBERRY,:STARFBERRY,:MARANGABERRY,:WATMELBERRY,
               :SALACBERRY,:ROSELIBERRY,:KASIBBERRY,:MAGOSTBERRY,:SHUCABERRY,:MAGOBERRY,
               :WACANBERRY,:MICLEBERRY,:KEEBERRY,:PAMTREBERRY,:GANLONBERRY,:CHILANBERRY,
               :CORNNBERRY,:PERSIMBERRY,:LUMBERRY,:SITRUSBERRY,:BLUKBERRY,:OCCABERRY,
               :GREPABERRY,:LEPPABERRY,:POMEGBERRY,:QUALOTBERRY,:PECHABERRY,:NANABBERRY,
               :PAYAPABERRY,:HABANBERRY].include?(itemID)
      when :CALM,:CAREFUL,:SASSY,:GENTLE # Bitter
        return [:JABOCABERRY,:MARANGABERRY,:GANLONBERRY,:PETAYABERRY,:DURINBERRY,:HABANBERRY,
               :RABUTABERRY,:COBABERRY,:RINDOBERRY,:AGUAVBERRY,:CUSTAPBERRY,:LANSATBERRY,
               :STARFBERRY,:WATMELBERRY,:SALACBERRY,:ROSELIBERRY,:MAGOSTBERRY,:KEEBERRY,
               :LUMBERRY,:SITRUSBERRY,:LEPPABERRY,:POMEGBERRY,:NANABBERRY,:PASSHOBERRY,
               :ORANBERRY,:HONDEWBERRY,:KELPSYBERRY,:CHOPLEBERRY,:RAWSTBERRY,:WEPEARBERRY,
               :COLBURBERRY].include?(itemID)
      when :BOLD,:IMPISH,:RELAXED,:LAX # Sour
        return [:ROWAPBERRY,:LANSATBERRY,:STARFBERRY,:SALACBERRY,:APICOTBERRY,:BELUEBERRY,
               :COLBURBERRY,:NOMELBERRY,:PAYAPABERRY,:YACHEBERRY,:IAPAPABERRY,:JABOCABERRY,
               :MARANGABERRY,:PETAYABERRY,:DURINBERRY,:RABUTABERRY,:KEEBERRY,:SITRUSBERRY,
               :LEPPABERRY,:ORANBERRY,:KELPSYBERRY,:WEPEARBERRY,:WACANBERRY,:PERSIMBERRY,
               :GREPABERRY,:QUALOTBERRY,:KEBIABERRY,:TANGABERRY,:PINAPBERRY,:ASPEARBERRY].include?(itemID)
      end
      return false
    end
    
    def dislikesBerryFlavor?(itemID=nil)
      if itemID.nil?
        itemID = @item_id
      end
      case @pokemon.nature_id
      when :MODEST,:TIMID,:CALM,:BOLD # Spicy
        return [:ENIGMABERRY,:SPELONBERRY,:LIECHIBERRY,:PETAYABERRY,:LANSATBERRY,:STARFBERRY,
               :KEEBERRY,:BABIRIBERRY,:TAMATOBERRY,:TANGABERRY,:FIGYBERRY,:OCCABERRY,
               :CHOPLEBERRY,:CHERIBERRY,:LEPPABERRY,:ORANBERRY,:PERSIMBERRY,:LUMBERRY,
               :RAZZBERRY,:PINAPBERRY,:POMEGBERRY,:QUALOTBERRY,:HONDEWBERRY,:NOMELBERRY,
               :BELUEBERRY,:RINDOBERRY,:SHUCABERRY,:CHARTIBERRY,:APICOTBERRY,:ROWAPBERRY,
               :MARANGABERRY].include?(itemID)
      when :ADAMANT,:JOLLY,:CAREFUL,:IMPISH # Dry
        return [:MICLEBERRY,:KEEBERRY,:APICOTBERRY,:PAMTREBERRY,:GANLONBERRY,:CHILANBERRY,
               :CHARTIBERRY,:CORNNBERRY,:WIKIBERRY,:PASSHOBERRY,:KEBIABERRY,:ENIGMABERRY,
               :SPELONBERRY,:LIECHIBERRY,:LANSATBERRY,:STARFBERRY,:BABIRIBERRY,:TAMATOBERRY,
               :ORANBERRY,:PERSIMBERRY,:LUMBERRY,:RAZZBERRY,:HONDEWBERRY,:MARANGABERRY,
               :CHESTOBERRY,:SITRUSBERRY,:BLUKBERRY,:KELPSYBERRY,:GREPABERRY,:YACHEBERRY,
               :COBABERRY,:KASIBBERRY].include?(itemID)
      when :BRAVE,:QUIET,:SASSY,:RELAXED # Sweet
        return [:CUSTAPBERRY,:LIECHIBERRY,:LANSATBERRY,:STARFBERRY,:MARANGABERRY,:WATMELBERRY,
               :SALACBERRY,:ROSELIBERRY,:KASIBBERRY,:MAGOSTBERRY,:SHUCABERRY,:MAGOBERRY,
               :WACANBERRY,:MICLEBERRY,:KEEBERRY,:PAMTREBERRY,:GANLONBERRY,:CHILANBERRY,
               :CORNNBERRY,:PERSIMBERRY,:LUMBERRY,:SITRUSBERRY,:BLUKBERRY,:OCCABERRY,
               :GREPABERRY,:LEPPABERRY,:POMEGBERRY,:QUALOTBERRY,:PECHABERRY,:NANABBERRY,
               :PAYAPABERRY,:HABANBERRY].include?(itemID)
      when :NAUGHTY,:RASH,:NAIVE,:LAX # Bitter
        return [:JABOCABERRY,:MARANGABERRY,:GANLONBERRY,:PETAYABERRY,:DURINBERRY,:HABANBERRY,
               :RABUTABERRY,:COBABERRY,:RINDOBERRY,:AGUAVBERRY,:CUSTAPBERRY,:LANSATBERRY,
               :STARFBERRY,:WATMELBERRY,:SALACBERRY,:ROSELIBERRY,:MAGOSTBERRY,:KEEBERRY,
               :LUMBERRY,:SITRUSBERRY,:LEPPABERRY,:POMEGBERRY,:NANABBERRY,:PASSHOBERRY,
               :ORANBERRY,:HONDEWBERRY,:KELPSYBERRY,:CHOPLEBERRY,:RAWSTBERRY,:WEPEARBERRY,
               :COLBURBERRY].include?(itemID)
      when :LONELY,:MILD,:HASTY,:GENTLE # Sour
        return [:ROWAPBERRY,:LANSATBERRY,:STARFBERRY,:SALACBERRY,:APICOTBERRY,:BELUEBERRY,
               :COLBURBERRY,:NOMELBERRY,:PAYAPABERRY,:YACHEBERRY,:IAPAPABERRY,:JABOCABERRY,
               :MARANGABERRY,:PETAYABERRY,:DURINBERRY,:RABUTABERRY,:KEEBERRY,:SITRUSBERRY,
               :LEPPABERRY,:ORANBERRY,:KELPSYBERRY,:WEPEARBERRY,:WACANBERRY,:PERSIMBERRY,
               :GREPABERRY,:QUALOTBERRY,:KEBIABERRY,:TANGABERRY,:PINAPBERRY,:ASPEARBERRY].include?(itemID)
      end
      return false
    end
    
    #=============================================================================
    # Methods used only for AI
    #=============================================================================
    #-----------------------------------------------------------------------------
    # Other Pokemon info
    #-----------------------------------------------------------------------------
    # Yields each unfainted near opposing Pokémon.
    def eachNearOpposing
      @battle.battlers.each { |b| yield b if b && !b.fainted? && b.opposes?(@index) && b.near?(@index) }
    end
  
    # Yields each unfainted near ally Pokémon.
    def eachNearAlly
      @battle.battlers.each do |b|
        yield b if b && !b.fainted? && !b.opposes?(@index) && b.index != @index && 
                   b.near?(@index)
      end
    end
    
    # Yields each unfainted allied Pokémon (including this Pokémon)
    def eachOwnSideBattler
      @battle.battlers.each do |b|
        yield b if b && !b.fainted? && !b.opposes?(@index)
      end
    end
    
    # Yields each other unfainted Pokemon
    def eachOtherBattler
      @battle.battlers.each do |b|
        yield b if b && !b.fainted? && b.index != @index
      end
    end
    
    # Yields each unfainted near Pokémon.
    def eachNearBattler
      @battle.battlers.each { |b| yield b if b && !b.fainted? && b.near?(@index) }
    end
    
    # Returns the number of unfainted opponents
    def numOpposing
      sum = 0
      eachOpposing do |b|
        sum += 1
      end
      return sum
    end
    
    # Returns the number of nearby unfainted opponents
    def numNearOpposing
      sum = 0
      eachNearOpposing do |b|
        sum += 1
      end
      return sum
    end
    
    # Returns the number of unfainted Pokemon in this battler's party
    def unfaintedPartyCount
      count = 0
      @battle.eachInTeamFromBattlerIndex(@index) do |pkmn,i|
        if !pkmn.fainted?
          count += 1
        end
      end
      return count
    end
  
    #-----------------------------------------------------------------------------
    # Item info
    #-----------------------------------------------------------------------------
    def hasUtilityUmbrella?
      return hasActiveItem?(:UTILITYUMBRELLA)
    end
  
    def hasTerrainExtender?
      return hasActiveItem?(:TERRAINEXTENDER)
    end
    
    #-----------------------------------------------------------------------------
    # General info
    #-----------------------------------------------------------------------------
    def grounded?
      return !airborne?
    end
  
    def healPrevention?
      return true if @effects[PBEffects::HealBlock]>0
      return true if $fefieldeffect == 10
      return false
    end
  
    #-----------------------------------------------------------------------------
    # Move info
    #-----------------------------------------------------------------------------
    def pbHasMove?(move_id)
      return false if !move_id
      if !move_id.is_a?(Array)
        move_id = [move_id]
      end
      for inputMove in move_id
        eachMove { |m| return true if m.id == inputMove }
      end
      return false
    end
    
    # Returns whether this battler has the given move function with at least some PP
    def hasMoveFunction?(move_id)
      return false if !move_id
      if !move_id.is_a?(Array)
        move_id = [move_id]
      end
      for inputMove in move_id
        eachMove { |m| return true if m.function == @battle.battleAI.getFunctionCode(inputMove) && m.pp > 0 }
      end
      return false
    end
    
    def findValidMoveIndex(move_id)
      return -1 if !move_id
      if !move_id.is_a?(Array)
        move_id = [move_id]
      end
      for index in 0...@moves
        for inputMove in move_id
          return index if @moves[index].id == inputMove && @moves[index].pp > 0
        end
      end
      return -1
    end
    
    # Returns whether this battler has revealed any of the given moves
    def hasRevealedMove?(move_id)
      if !move_id.is_a?(Array)
        move_id = [move_id]
      end
      for inputMove in move_id
        move_data = GameData::Move.try_get(inputMove)
        next if !move_data
        return true if @pokemon.moveMemory.any? { |m| m.id == move_data.id && m.pp > 0 }
      end
      return false
    end
    
    # Returns whether this battler has revealed any of the functions of the given moves
    def hasRevealedMoveFunction?(move_id)
      if !move_id.is_a?(Array)
        move_id = [move_id]
      end
      for inputMove in move_id
        return true if @pokemon.moveMemory.any? { |m| m.function == @battle.battleAI.getFunctionCode(inputMove) && m.pp > 0 }
      end
      return false
    end
    
    # Returns whether this battler should have any of the functions of the given moves
    def hasKnownMoveFunction?(move_id)
      if opposes?(@battle.battleAI.user)
        return hasRevealedMoveFunction?(move_id)
      else
        return hasMoveFunction?(move_id)
      end
    end
    
    def hasKnownStatusMove?
      for m in knownMoves
        if m.statusMove?
          return true if m.pp > 0
        end
      end
      return false
    end
    
    def hasKnownDamageMove?
      for m in knownMoves
        if m.damagingMove?
          return true if m.pp > 0
        end
      end
      return false
    end
    
    def hasKnownPhysicalMove?
      for m in knownMoves
        if m.physicalMove?
          return true if m.pp > 0
        end
      end
      return false
    end
    
    def hasKnownSpecialMove?
      for m in knownMoves
        if m.specialMove?
          return true if m.pp > 0
        end
      end
      return false
    end
    
    # Returns whether this Pokemon has revealed a move with the given flag
    def hasKnownMoveFlag?(flag)
      for m in knownMoves
        if m.flags =~ Regexp.new(flag) # The move has the specified flag
          return true if m.pp > 0
        end
      end
      return false
    end
    
    def hasKnownHealingMove?
      for m in knownMoves
        if m.healingMove?
          return true if m.pp > 0
        end
      end
      return false
    end
    
    # Returns whether this Pokemon has a revealed counter for Evasion boosts against the given mon
    def hasRevealedEvasionCounter?(target=nil,oppMinimize=false)
      if !target.nil?
        return true if hasRevealedMoveFunction(:FISSURE) && @level > target.level # Ignores Evasion boosts
        return true if target.effects[PBEffects::Telekinesis] > 0
        return true if target.effects[PBEffects::Foresight] > 0
        return true if target.effects[PBEffects::MiracleEye] > 0
        return true if hasActiveItem?(:ZOOMLENS) && target.fasterThan?(self)
      end
      return true if @battle.field.effects[PBEffects::Gravity] > 0
      if oppMinimize
        for m in @pokemon.moveMemory
          return true if m.tramplesMinimize? && m.pp > 0
        end
      end
      for m in @pokemon.moveMemory
        next if m.pp == 0 || !target.nil? && @battleAI.pbCheckMoveImmunity(m,self,target)
        if target.nil?
          return true if m.accuracy == 0
        else
          return true if m.pbBaseAccuracy(self,target) == 0 # Accounts for Thunder and such
        end
        return true if $fefieldeffect == 20 && m.focusMove?
        return true if m.pbTarget(user).num_targets > 1
      end
      return true if hasActiveAbility?([:KEENEYE,:COMPOUNDEYES,:HOMINGCANNON,:SHIFU])
      return true if hasActiveAbility?(:NOGUARD) && $fefieldeffect != 14
      return true if hasActiveAbility?(:INNERFOCUS) && [5,6,48].include?($fefieldeffect)
      return true if hasActiveAbility?(:ILLUMINATE) && [18,42].include?($fefieldeffect)
      return true if hasActiveAbility?(:KEENEYE) && ($fefieldeffect == 15 && airborne? ||
                     $fefieldeffect == 40 && pbHasType?(:GHOST))
      return true if hasActiveAbility?(:SPYGEAR) && @effects[PBEffects::SpyGear] == 2
      return true if hasActiveAbility?(:UNSEENARCHER) && (@hp == @totalhp || @hp >= @totalhp/2 &&
                     [4,15,18,40].include?($fefieldeffect)) && ![12,30].include?($fefieldeffect)
      return true if hasActiveAbility?(:ALPHABETIZATION) && checkAlphabetizationForm(5)
      return true if hasActiveAbility?(:UNAWARE) && $fefieldeffect != 1
      return true if hasActiveAbility?(:VICTORYSTAR) && ![22,23].include?($fefieldeffect)
      return true if hasActiveAbility?([:OWNTEMPO,:INNERFOCUS,:TELEPATHY,:PUREPOWER,:SANDVEIL,
                     :STEADFAST,:STRONGWILL,:VITALICAURA,:MOTIVATION,:ATTENTIVE,:STALWART,
                     :SANDSHIELD]) && $fefieldeffect == 20 && !@battle.pbCheckOpposingAbility([:UNNERVE,:AURABREAK],@index)
      return true if hasActiveItem?(:WIDELENS)
      return true if target.hasActiveAbility?(:NOGUARD) && $fefieldeffect != 14
      return true if target.hasActiveAbility?(:ILLUMINATE) && [18,42].include?($fefieldeffect)
      eachAlly do |b|
        return true if b.hasActiveAbility?(:VICTORYSTAR) && ![22,23].include?($fefieldeffect)
      end
      return false
    end
    
    # Returns whether this Pokemon has a counter for Evasion boosts
    def hasEvasionCounter?(target=nil,oppMinimize=false)
      if !target.nil?
        return true if hasMoveFunction?(:FISSURE) && @level > target.level # Ignores Evasion boosts
        return true if target.effects[PBEffects::Telekinesis] > 0
        return true if target.effects[PBEffects::Foresight] > 0
        return true if target.effects[PBEffects::MiracleEye] > 0
        return true if hasActiveItem?(:ZOOMLENS) && target.fasterThan?(self)
      end
      return true if @battle.field.effects[PBEffects::Gravity] > 0
      if oppMinimize
        for m in @moves
          return true if m.tramplesMinimize? && m.pp > 0
        end
      end
      for m in @moves
        next if m.pp == 0 || !target.nil? && @battleAI.pbCheckMoveImmunity(m,self,target)
        if target.nil?
          return true if m.accuracy == 0
        else
          return true if m.pbBaseAccuracy(self,target) == 0 # Accounts for Thunder and such
        end
        return true if $fefieldeffect == 20 && m.focusMove?
        return true if m.pbTarget(user).num_targets > 1
      end
      return true if hasActiveAbility?([:KEENEYE,:COMPOUNDEYES,:HOMINGCANNON,:SHIFU])
      return true if hasActiveAbility?(:NOGUARD) && $fefieldeffect != 14
      return true if hasActiveAbility?(:INNERFOCUS) && [5,6,48].include?($fefieldeffect)
      return true if hasActiveAbility?(:ILLUMINATE) && [18,42].include?($fefieldeffect)
      return true if hasActiveAbility?(:KEENEYE) && ($fefieldeffect == 15 && airborne? ||
                     $fefieldeffect == 40 && pbHasType?(:GHOST))
      return true if hasActiveAbility?(:SPYGEAR) && @effects[PBEffects::SpyGear] == 2
      return true if hasActiveAbility?(:UNSEENARCHER) && (@hp == @totalhp || @hp >= @totalhp/2 &&
                     [4,15,18,40].include?($fefieldeffect)) && ![12,30].include?($fefieldeffect)
      return true if hasActiveAbility?(:ALPHABETIZATION) && checkAlphabetizationForm(5)
      return true if hasActiveAbility?(:UNAWARE) && $fefieldeffect != 1
      return true if hasActiveAbility?(:VICTORYSTAR) && ![22,23].include?($fefieldeffect)
      return true if hasActiveAbility?([:OWNTEMPO,:INNERFOCUS,:TELEPATHY,:PUREPOWER,:SANDVEIL,
                     :STEADFAST,:STRONGWILL,:VITALICAURA,:MOTIVATION,:ATTENTIVE,:STALWART,
                     :SANDSHIELD]) && $fefieldeffect == 20 && !@battle.pbCheckOpposingAbility([:UNNERVE,:AURABREAK],@index)
      return true if hasActiveItem?(:WIDELENS)
      return true if target.hasActiveAbility?(:NOGUARD) && $fefieldeffect != 14
      return true if target.hasActiveAbility?(:ILLUMINATE) && [18,42].include?($fefieldeffect)
      eachAlly do |b|
        return true if b.hasActiveAbility?(:VICTORYSTAR) && ![22,23].include?($fefieldeffect)
      end
      return false
    end
    
    def revealedAllMoves?
      return @pokemon.moveMemory.length == @moves.length
    end
    
    # Returns an array containing this battler's revealed moves as well as its expected
    # STAB pseudomoves as applicable
    def pbExpectedMoves
      ret = @pokemon.moveMemory
      if ret.length == 4 # All moves revealed
        return ret
      end
      type1stab = false # Whether the Pokemon has a STAB move for its first type
      type2stab = false # Whether the Pokemon has a STAB move for its second type
      for m in ret
        types = m.pbCalcTypes(self)
        if types.include?(@type1)
          type1stab = true
        end
        if types.include?(@type2)
          type2stab = true
        end
      end
      if !type1stab
        ret.push(PokeBattle_AI_Pseudomove.new(@battle,self,@type1))
      end
      if !type2stab
        ret.push(PokeBattle_AI_Pseudomove.new(@battle,self,@type2))
      end
      return ret
    end
    
    # Returns an array containing this battler's moves to the knowledge of the AI's current user
    def knownMoves
      return (opposes?(@battle.battleAI.user)) ? pbExpectedMoves : @moves
    end
    
    # Returns whether this battler has any physical moves
    def hasPhysicalMove?
      for m in @moves
        return true if m.physicalMove?
      end
      return false
    end
    
    # Returns whether this battler has any special moves
    def hasSpecialMove?
      for m in @moves
        return true if m.specialMove?
      end
      return false
    end
    
    # Returns whether this battler has any expected physical moves
    def hasExpectedPhysicalMove?
      for m in pbExpectedMoves
        return true if m.physicalMove?
      end
      return false
    end
    
    # Returns whether this battler has any expected special moves
    def hasExpectedSpecialMove?
      for m in pbExpectedMoves
        return true if m.specialMove?
      end
      return false
    end
    
    #-----------------------------------------------------------------------------
    # Stat info
    #-----------------------------------------------------------------------------
    def pbAttackMult(moldBreaker)
      ret = 1.0
      # Abilities
      if hasActiveAbility?(:DEFEATIST) && (@hp <= @totalhp / 2 || [12,16].include?($fefieldeffect)) &&
         ![1,9,31].include?($fefieldeffect)
        ret /= 2
      end
      if hasActiveAbility?(:FLOWERGIFT) && ![10,11].include?($fefieldeffect)
        if [:Sun, :HarshSun].include?(@battle.pbWeather) && !hasUtilityUmbrella?
          ret *= 1.5
        end
        if [2,42].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
          ret *= 1.5
        end
      end
      if hasActiveAbility?(:GUTS)
        if pbHasAnyStatus?
          if [20,45].include?($fefieldeffect)
            ret *= 2
          else
            ret *= 1.5
          end
        end
        if $fefieldeffect == 7 && takesVolcanicFieldDamage? || $fefieldeffect == 10 &&
           takesCorrosiveFieldDamage? || $fefieldeffect == 26 && affectedByMurkwaterSurface? ||
           $fefieldeffect == 22 && takesUnderwaterFieldDamage? || $fefieldeffect == 41 &&
           takesCorruptedCaveDamage?
          ret *= 1.5
        end
      end
      if hasActiveAbility?(:HUGEPOWER)
        ret *= 2
      end
      if hasActiveAbility?(:PUREPOWER) && ![37,39].include?($fefieldeffect)
        ret *= 2
      end
      if hasActiveAbility?(:HUSTLE)
        ret *= 1.5
      end
      if hasActiveAbility?(:SLOWSTART) && @effects[PBEffects::SlowStart] > 0 && ![1,17,18,29].include?($fefieldeffect)
        ret /= 2
      end
      if hasActiveAbility?(:GORILLATACTICS) && ![12,29,44,49].include?($fefieldeffect)
        if [39,45].include?($fefieldeffect)
          ret *= 2
        else
          ret *= 1.5
        end
      end
      if $fefieldeffect == 5 && ($fecounter%6 == 2 || @battle.field.effects[PBEffects::PrevFECounter]%6 == 2 &&
         hasActiveAbility?(:SKILLLINK)) && @battle.singleBattle? # Queen (Singles)
        ret *= 1.5
      end
      if hasActiveAbility?(:HEAVYMETAL) && $fefieldeffect == 17
        ret *= 2
      end
      if hasActiveAbility?(:VICTORYSTAR) && [34,35].include?($fefieldeffect)
        ret *= 1.5
      end
      if hasActiveAbility?(:PURELETHALITY) && (@effects[PBEffects::Unburden] && !@item || 
         [10,11,39].include?($fefieldeffect)) && ![3,9,29,48].include?($fefieldeffect)
        ret *= 2
      end
      if hasActiveAbility?(:SPACIALCONNECTION) && ![4,7,13,22,23,25,32,41].include?($fefieldeffect)
        eachOtherBattler do |b|
          if b.pbHasType?(:PSYCHIC) || b.pbHasType?(:FAIRY) || b.pbHasType?(:ROCK) &&
             [16,27,28].include?($fefieldeffect)
            if $fefieldeffect == 35
              ret *= 1.5
            elsif [9,43].include?($fefieldeffect)
              ret *= 1.3
            else
              ret *= 1.2
            end
          end
        end
        if $fefieldeffect == 34 && (pbHasType?(:PSYCHIC) || pbHasType?(:FAIRY))
          ret *= 1.2
        end
      end
      if hasActiveAbility?(:BALANCEDCHARGES)
        if @pokemon.baseStats[:SPECIAL_ATTACK] > @pokemon.baseStats[:SPECIAL_DEFENSE] # Plusle
          eachOtherBattler do |b|
            next if !(b.hasActiveAbility?(:BALANCEDCHARGES) && b.pokemon.baseStats[:SPECIAL_DEFENSE] > b.pokemon.baseStats[:SPECIAL_ATTACK]) # Minun
            ret *= 1.2
          end
        elsif @pokemon.baseStats[:SPECIAL_DEFENSE] > @pokemon.baseStats[:SPECIAL_ATTACK] # Minun
          eachOtherBattler do |b|
            next if !(b.hasActiveAbility?(:BALANCEDCHARGES) && b.pokemon.baseStats[:SPECIAL_ATTACK] > b.pokemon.baseStats[:SPECIAL_DEFENSE]) # Plusle
            ret *= 1.2
          end
        end
      end
      if !moldBreaker
        # Allied Abilities
        eachAlly do |b|
          if b.hasActiveAbility?(:FLOWERGIFT) && ![10,11].include?($fefieldeffect)
            if [:Sun, :HarshSun].include?(@battle.pbWeather) && !b.hasUtilityUmbrella?
              ret *= 1.5
            end
            if [2,42].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
              ret *= 1.5
            end
          end
          if b.hasActiveAbility?(:VICTORYSTAR) && [34,35].include?($fefieldeffect)
            ret *= 1.5
          end
        end
        # Other Battler Abilities
        eachOtherBattler do |b|
          if b.hasActiveAbility?(:LEADERSHIP) && sharesType?(b)
            if $fefieldeffect == 32
              ret *= 1.5
            else
              ret *= 1.3
            end
          end
        end
      end
      return ret
    end
    
    # Returns the battler's effective Attack stat based on all general attributes
    # (Doesn't take into account everything; just to get a better idea than raw Attack)
    def pbAttack(moldBreaker)
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @stages[:ATTACK] + 6
      mult = pbAttackMult(moldBreaker)
      # Items
      if hasActiveItem?([:CHOICEBAND,:CHOICEDUMPLING])
        mult *= 1.5
      elsif hasActiveItem?(:THICKCLUB) && (isSpecies?(:CUBONE) || isSpecies?(:MAROWAK))
        mult *= 2
      elsif hasActiveItem?(:ASSAULTVEST) && $fefieldeffect == 45
        mult *= 1.5
      end
      return [(@attack*stageMul[stage]*mult/stageDiv[stage]).floor,1].max
    end
    
    def pbSpAtkMult(moldBreaker)
      ret = 1.0
      # Abilities
      if hasActiveAbility?(:DEFEATIST) && (@hp <= @totalhp / 2 || [12,16].include?($fefieldeffect)) &&
         ![1,9,31].include?($fefieldeffect)
        ret /= 2
      end
      if hasActiveAbility?(:GUTS) && $fefieldeffect == 12
        if pbHasAnyStatus?
          ret *= 1.5
        end
      end
      if hasActiveAbility?(:PUREPOWER) && $fefieldeffect == 37
        ret *= 2
      end
      if hasActiveAbility?(:HUSTLE) && $fefieldeffect == 5
        ret *= 1.5
      end
      if hasActiveAbility?(:MINUS) && $fefieldeffect != 35
        eachAlly do |b|
          next if !b.hasActiveAbility?([:MINUS, :PLUS])
          ret *= 1.5
        end
        if [1,18].include?($fefieldeffect)
          ret *= 1.5
        end
      end
      if hasActiveAbility?(:PLUS) && $fefieldeffect != 35
        eachAlly do |b|
          next if !b.hasActiveAbility?([:MINUS, :PLUS])
          ret *= 1.5
        end
        if [1,4].include?($fefieldeffect)
          ret *= 1.5
        end
      end
      if hasActiveAbility?(:SOLARPOWER) && ![18,23,39,41,42,46,47].include?($fefieldeffect)
        if [:Sun,:HarshSun].include?(@battle.pbWeather) && !hasUtilityUmbrella?
          ret *= 1.5
        end
        if [9,12,48,49].include?($fefieldeffect)
          ret *= 1.5
        end
      end
      if $fefieldeffect == 5 && ($fecounter%6 == 2 || @battle.field.effects[PBEffects::PrevFECounter]%6 == 2 &&
         hasActiveAbility?(:SKILLLINK)) && @battle.singleBattle? # Queen (Singles)
        ret *= 1.5
      end
      if hasActiveAbility?(:PRIMORDIALSEA) && $fefieldeffect == 22
        ret *= 2
      end
      if hasActiveAbility?(:VICTORYSTAR) && [34,35].include?($fefieldeffect)
        ret *= 1.5
      end
      if hasActiveAbility?(:SPACIALCONNECTION) && ![4,7,13,22,23,25,32,41].include?($fefieldeffect)
        eachOtherBattler do |b|
          if b.pbHasType?(:PSYCHIC) || b.pbHasType?(:FAIRY) || b.pbHasType?(:ROCK) &&
             [16,27,28].include?($fefieldeffect)
            if $fefieldeffect == 35
              ret *= 1.5
            elsif [9,43].include?($fefieldeffect)
              ret *= 1.3
            else
              ret *= 1.2
            end
          end
        end
        if $fefieldeffect == 34 && (pbHasType?(:PSYCHIC) || pbHasType?(:FAIRY))
          ret *= 1.2
        end
      end
      if hasActiveAbility?(:BALANCEDCHARGES)
        if @pokemon.baseStats[:SPECIAL_ATTACK] > @pokemon.baseStats[:SPECIAL_DEFENSE] # Plusle
          eachOtherBattler do |b|
            next if !(b.hasActiveAbility?(:BALANCEDCHARGES) && b.pokemon.baseStats[:SPECIAL_DEFENSE] > b.pokemon.baseStats[:SPECIAL_ATTACK]) # Minun
            ret *= 1.2
          end
        elsif @pokemon.baseStats[:SPECIAL_DEFENSE] > @pokemon.baseStats[:SPECIAL_ATTACK] # Minun
          eachOtherBattler do |b|
            next if !(b.hasActiveAbility?(:BALANCEDCHARGES) && b.pokemon.baseStats[:SPECIAL_ATTACK] > b.pokemon.baseStats[:SPECIAL_DEFENSE]) # Plusle
            ret *= 1.2
          end
        end
      end
      # Allied Abilities
      if !moldBreaker
        eachAlly do |b|
          if b.hasActiveAbility?(:VICTORYSTAR) && [34,35].include?($fefieldeffect)
            ret *= 1.5
          end
        end
      end
      return ret
    end
    
    # Returns the battler's effective Sp. Atk stat based on all general attributes
    # (Doesn't take into account everything; just to get a better idea than raw Sp. Atk)
    def pbSpAtk(moldBreaker)
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @stages[:SPECIAL_ATTACK] + 6
      mult = pbSpAtkMult(moldBreaker)
      # Items
      if hasActiveItem?([:CHOICESPECS,:CHOICEDUMPLING])
        mult *= 1.5
      elsif hasActiveItem?(:DEEPSEATOOTH) && isSpecies?(:CLAMPERL)
        if $fefieldeffect == 22
          mult *= 3
        else
          mult *= 2
        end
      elsif hasActiveItem?(:SOULDEW) && (isSpecies?(:LATIAS) || isSpecies?(:LATIOS)) &&
            $fefieldeffect == 29
        mult *= 1.5
      elsif hasActiveItem?([:FLAMEORB,:TOXICORB]) && $fefieldeffect == 42
        mult *= 1.3
      end
      return [(@spatk*stageMul[stage]*mult/stageDiv[stage]).floor,1].max
    end
    
    def pbDefenseMult(moldBreaker)
      ret = 1.0
      # Abilities
      if !moldBreaker
        if hasActiveAbility?(:FURCOAT)
          ret *= 2
        end
        if hasActiveAbility?(:GRASSPELT) && ([2,15,42,47].include?($fefieldeffect) ||
           $fefieldeffect == 33 && $fecounter >= 1)
          ret *= 1.5
        end
        if hasActiveAbility?(:MARVELSCALE)
          if pbHasAnyStatus?
            if $fefieldeffect == 21 && grounded? || [22,30].include?($fefieldeffect)
              ret *= 2
            else
              ret *= 1.5
            end
          end
          if [3,9,25,31,32,34,48].include?($fefieldeffect)
            ret *= 1.5
          end
        end
        if hasActiveAbility?([:THICKFAT,:OVERCOAT]) && $fefieldeffect == 45
          ret *= 2
        end
        if hasActiveAbility?(:FULLMETALBODY) && $fefieldeffect == 17
          ret *= 2
        end
        if hasActiveAbility?(:BULLETPROOF) && $fefieldeffect == 14
          ret *= 2
        end
        if hasActiveAbility?(:ROCKPEAKTITAN)
          ret *= 1.2
        end
        if hasActiveAbility?(:IRONTITAN)
          ret *= 1.1
        end
        if hasActiveAbility?(:BALANCEDCHARGES)
          if @pokemon.baseStats[:SPECIAL_ATTACK] > @pokemon.baseStats[:SPECIAL_DEFENSE] # Plusle
            eachOtherBattler do |b|
              next if !(b.hasActiveAbility?(:BALANCEDCHARGES) && b.pokemon.baseStats[:SPECIAL_DEFENSE] > b.pokemon.baseStats[:SPECIAL_ATTACK]) # Minun
              ret *= 1.2
            end
          elsif @pokemon.baseStats[:SPECIAL_DEFENSE] > @pokemon.baseStats[:SPECIAL_ATTACK] # Minun
            eachOtherBattler do |b|
              next if !(b.hasActiveAbility?(:BALANCEDCHARGES) && b.pokemon.baseStats[:SPECIAL_ATTACK] > b.pokemon.baseStats[:SPECIAL_DEFENSE]) # Plusle
              ret *= 1.2
            end
          end
        end
        if hasActiveAbility?(:ELECTRICFIELD) && @effects[PBEffects::MagnetRise] > 0
          ret *= 1.3
        end
        # Other Battler Abilities
        eachOtherBattler do |b|
          if b.hasActiveAbility?(:LEADERSHIP) && sharesType?(b) && $fefieldeffect != 39
            if $fefieldeffect == 32
              ret *= 1.5
            else
              ret *= 1.3
            end
          end
        end
      end
      return ret
    end
    
    def pbDefense(moldBreaker)
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @stages[:DEFENSE] + 6
      mult = pbDefenseMult(moldBreaker)
      # Abilities (Non-Ignorable)
      if hasActiveAbility?(:PRISMARMOR) && [4,9,25].include?($fefieldeffect)
        mult *= 2
      end
      if hasActiveAbility?(:SHADOWSHIELD) && [4,34,35,38].include?($fefieldeffect)
        mult *= 2
      end
      return [(@defense*stageMul[stage]*mult/stageDiv[stage]).floor,1].max
    end
    
    def pbSpDefMult(moldBreaker)
      ret = 1.0
      # Abilities
      if !moldBreaker
        if hasActiveAbility?(:FLOWERGIFT) && ![10,11].include?($fefieldeffect)
          if [:Sun, :HarshSun].include?(@battle.pbWeather) && !hasUtilityUmbrella?
            ret *= 1.5
          end
          if [2,42].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
            ret *= 1.5
          end
        end
        if hasActiveAbility?(:ICEBERGTITAN) && ![7,12,16,49].include?($fefieldeffect)
          if [13,39,46].include?($fefieldeffect)
            ret *= 1.5
          else
            ret *= 1.2
          end
        end
        if hasActiveAbility?(:IRONTITAN)
          ret *= 1.1
        end
        if hasActiveAbility?(:BALANCEDCHARGES)
          if @pokemon.baseStats[:SPECIAL_ATTACK] > @pokemon.baseStats[:SPECIAL_DEFENSE] # Plusle
            eachOtherBattler do |b|
              next if !(b.hasActiveAbility?(:BALANCEDCHARGES) && b.pokemon.baseStats[:SPECIAL_DEFENSE] > b.pokemon.baseStats[:SPECIAL_ATTACK]) # Minun
              ret *= 1.2
            end
          elsif @pokemon.baseStats[:SPECIAL_DEFENSE] > @pokemon.baseStats[:SPECIAL_ATTACK] # Minun
            eachOtherBattler do |b|
              next if !(b.hasActiveAbility?(:BALANCEDCHARGES) && b.pokemon.baseStats[:SPECIAL_ATTACK] > b.pokemon.baseStats[:SPECIAL_DEFENSE]) # Plusle
              ret *= 1.2
            end
          end
        end
        if hasActiveAbility?(:ELECTRICFIELD) && @effects[PBEffects::MagnetRise] > 0
          ret *= 1.3
        end
        # Allied Abilities
        eachAlly do |b|
          if b.hasActiveAbility?(:FLOWERGIFT) && ![10,11].include?($fefieldeffect)
            if [:Sun, :HarshSun].include?(@battle.pbWeather) && !b.hasUtilityUmbrella?
              ret *= 1.5
            end
            if [2,42].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
              ret *= 1.5
            end
          end
        end
      end
      return ret
    end
    
    def pbSpDef(moldBreaker)
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @stages[:SPECIAL_DEFENSE] + 6
      mult = pbSpDefMult(moldBreaker)
      # Abilities (Non-Ignorable)
      if hasActiveAbility?(:PRISMARMOR) && [4,9,25].include?($fefieldeffect)
        mult *= 2
      end
      if hasActiveAbility?(:SHADOWSHIELD) && [4,34,35,38].include?($fefieldeffect)
        mult *= 2
      end
      return [(@spdef*stageMul[stage]*mult/stageDiv[stage]).floor,1].max
    end
    
    def fasterThan?(otherMon)
      selfAlteration = 0
      otherAlteration = 0
      if hasActiveItem?(:CUSTAPBERRY) && pbCanConsumePinchBerry? || hasActiveAbility?(:STALL) &&
         $fefieldeffect == 45 || hasActiveAbility?(:QUEENLYMAJESTY) && ($fefieldeffect == 5 || 
         $fefieldeffect == 33 && $fecounter == 4) || hasActiveAbility?(:VANGUARD) && 
         ($fefieldeffect == 5 && $fecounter%6 == 0) # Pawn
        selfAlteration = 1
      elsif hasActiveAbility?(:STALL) && $fefieldeffect != 1 || hasActiveItem?([:LAGGINGTAIL,:FULLINCENSE])
        selfAlteration = -1
      end
      if otherMon.hasActiveItem?(:CUSTAPBERRY) && otherMon.canConsumePinchBerry? || 
         otherMon.hasActiveAbility?(:STALL) && $fefieldeffect == 45 || otherMon.hasActiveAbility?(:QUEENLYMAJESTY) && 
         ($fefieldeffect == 5 || $fefieldeffect == 33 && $fecounter == 4) || otherMon.hasActiveAbility?(:VANGUARD) && 
         ($fefieldeffect == 5 && $fecounter%6 == 0) # Pawn
        otherAlteration = 1
      elsif otherMon.hasActiveAbility?(:STALL) && $fefieldeffect != 1 || otherMon.hasActiveItem?([:LAGGINGTAIL,:FULLINCENSE])
        otherAlteration = -1
      end
      if selfAlteration == otherAlteration
        ret = pbSpeed > otherMon.pbSpeed
        ret = !ret if @battle.field.effects[PBEffects::TrickRoom] > 0
        return ret
      else
        return selfAlteration > otherAlteration
      end
    end
    
    def fasterThanAllOpposing?
      eachOpposing do |b|
        return false if !isFasterThan(b)
      end
      return true
    end
    
    def fasterThanAnyOpposing?
      eachOpposing do |b|
        return true if isFasterThan(b)
      end
      return false
    end
    
    # Returns a ratio of presumed attacking capability to special attacking capability against the given mon
    def physicalAttackerRatio(target)
      presumedRatio = pbAttack(false) / (pbAttack(false)+pbSpAtk(false)) # Guessed ratio based on unrevealed moves (don't consider target)
      knownRatio = 0 # Partial ratio based on revealed moves
      highestPhysical = 0 # Highest damage of a physical move this Pokemon has against target
      highestSpecial = 0 # Highest damage of a special move this Pokemon has against target
      for m in knownMoves
        damage = @battle.battleAI.pbRoughDamage(m,m,self,target)
        if m.physicalMove?
          if damage > highestPhysical
            highestPhysical = damage
          end
        elsif m.specialMove?
          if damage > highestSpecial
            highestSpecial = damage
          end
        end
      end
      if highestPhysical == highestSpecial # Avoid divide by 0 error
        knownRatio = 0.5 # Equally physical and special
      else
        knownRatio = 1.0 * highestPhysical / (highestPhysical+highestSpecial)
      end
      # Weigh ratio to account for higher assumed frequency of good moves
      knownRatio = @battle.battleAI.convertedRatio(knownRatio)
      # Weigh ratio to account for higher assumed choice of moves corresponding with higher stat
      presumedRatio = @battle.battleAI.convertedRatio(knownRatio)
      numRevealed = @pokemon.moveMemory.length
      # Combine ratios to form an overall ratio
      return knownRatio * numRevealed/4 + presumedRatio * (4-numRevealed)/4
    end
    
    # Returns a ratio of presumed special attacking capability to attacking capability against the given mon
    def specialAttackerRatio(target)
      return 1 - physicalAttackerRatio(target)
    end
    
    # Returns whether this battler will move before the other battler (taking into account both of their moves)
    def movesBefore?(selfMove,otherMon,otherMove)
      return @battle.battleAI.pbCompareMoveOrder(selfMove,self,otherMove,otherMon) < 0 # this battler moves before other battler
    end
    
    # Returns whether this battler will move after the other battler (taking into account both of their moves)
    def movesAfter?(selfMove,otherMon,otherMove)
      return @battle.battleAI.pbCompareMoveOrder(selfMove,self,otherMove,otherMon) > 0 # this battler moves after other battler
    end
    
    # Returns whether this battler should move before the other battler uses the specified move
    def shouldMoveBefore?(otherMon,otherMove)
      if !opposes?(@battle.battleAI.user) && !@moveChoice.nil?
        return movesBefore?(@moveChoice[:realMove],otherMon,otherMove)
      end
      priority = @battle.battleAI.pbMovePriority(otherMove,otherMon)
      return priority < 0 || fasterThan?(otherMon) && priority == 0
    end
    
    # Returns whether this battler should move after the other battler uses the specified move
    def shouldMoveAfter?(otherMon,otherMove)
      if !opposes?(@battle.battleAI.user) && !@moveChoice.nil?
        return movesAfter?(@moveChoice[:realMove],otherMon,otherMove)
      end
      priority = @battle.battleAI.pbMovePriority(otherMove,otherMon)
      return priority > 0 || otherMon.fasterThan?(self) && priority == 0
    end
    
    # Returns whether this battler should move first when using the given move
    def movesFirst?(move)
      pseudo = PokeBattle_AI_Pseudomove.new(@battle,self,:QMARKS) # Only used for priority calculation
      order = [] # Stores arrays of user and move
      eachOtherBattler do |b|
        added = false
        if b.opposes?(@battle.battleAI.user) || b.moveChoice.nil?
          bMove = pseudo # Guess/Unknown
        else
          bMove = b.moveChoice[:realMove]
        end
        for i in 0...order.length
          if !b.movesAfter?(bMove,order[i][0],order[i][1])
            order.insert(i,[b,bMove])
            added = true
            break
          end
        end
        if !added
          order.push([b,bMove])
        end
      end
      # Find where this battler would go
      for i in 0...order.length
        if !movesAfter?(move,order[i][0],order[i][1])
          if i == 0
            return true
          else
            return false
          end
        end
      end
      return false # User moves last
    end
    
    # Returns whether this battler should move last when using the given move
    def movesLast?(move)
      pseudo = PokeBattle_AI_Pseudomove.new(@battle,self,:QMARKS) # Only used for priority calculation
      order = [] # Stores arrays of user and move
      eachOtherBattler do |b|
        added = false
        if b.opposes?(@battle.battleAI.user) || b.moveChoice.nil?
          bMove = pseudo # Guess/Unknown
        else
          bMove = b.moveChoice[:realMove]
        end
        for i in 0...order.length
          if !b.movesAfter?(bMove,order[i][0],order[i][1])
            order.insert(i,[b,bMove])
            added = true
            break
          end
        end
        if !added
          order.push([b,bMove])
        end
      end
      # Find where this battler would go
      for i in 0...order.length
        if !movesAfter?(move,order[i][0],order[i][1])
          return false
        end
      end
      return true # User moves last
    end
    
    # Returns how much health this battler will have at the end of this round (negative if loss)
    def residualHP(currentHP=@hp)
      expectedHP = currentHP
      if @battle.field.weatherDuration > 1
        if !hasUtilityUmbrella?
          if hasActiveAbility?(:DRYSKIN)
            hpGain = 0
            if [:Sun,:HarshSun].include?(@battle.pbWeather)
              hpGain -= @totalhp/8 if takesIndirectDamage?
            elsif [:Rain,:HeavyRain].include?(@battle.pbWeather) && canHeal?
              hpGain += @totalhp/8
            end
            if [11,41].include?($fefieldeffect) && !pbHasType?(:STEEL)
              if !pbHasType?(:POISON)
                hpGain -= @totalhp/8 if takesIndirectDamage?
              elsif canHeal?
                hpGain += @totalhp/8
              end
            elsif [12,48,49].include?($fefieldeffect)
              hpGain -= @totalhp/8 if takesIndirectDamage?
            elsif $fefieldeffect == 3
              hpGain += @totalhp/16
            elsif $fefieldeffect == 8 && grounded?
              hpGain += @totalhp/8
            end
            expectedHP += hpGain
            return 0 if expectedHP <= 0
            expectedHP = @totalhp if expectedHP > @totalhp
          end
          if hasActiveAbility?(:SOLARPOWER)
            hpLoss = 0
            if [:Sun,:HarshSun].include?(@battle.pbWeather)
              hpLoss += @totalhp/8 if takesIndirectDamage?
            end
            if [12,49].include?($fefieldeffect)
              hpLoss += @totalhp/8 if takesIndirectDamage?
            end
            expectedHP -= hpLoss
            return 0 if expectedHP <= 0
          end
          if hasActiveAbility?(:RAINDISH) && ![13,46].include?($fefieldeffect)
            hpGain = 0
            if [:Rain,:HeavyRain].include?(@battle.pbWeather) && canHeal?
              hpGain += @totalhp/16
            end
            if [3,22].include?($fefieldeffect) || $fefieldeffect == 21 && grounded?
              hpGain += @totalhp/16 if canHeal?
            elsif $fefieldeffect == 26 && grounded?
              if pbHasType?(:POISON) && canHeal?
                hpGain += @totalhp/16
              elsif !pbHasType?(:STEEL)
                hpGain -= @totalhp/16 if takesIndirectDamage?
              end
            end
            expectedHP += hpGain
            return 0 if expectedHP <= 0
            expectedHP = @totalhp if expectedHP > @totalhp
          end
          if canHeal?
            if hasActiveAbility?(:SUNSHADE) && $fefieldeffect != 38
              hpGain = 0
              if [:Sun,:HarshSun].include?(@battle.pbWeather)
                hpGain += @totalhp/16
              end
              if [12,48,49].include?($fefieldeffect)
                hpGain += @totalhp/16
              end
              expectedHP += hpGain
              expectedHP = @totalhp if expectedHP > @totalhp
            end
            if hasActiveAbility?(:SANDBATH) && !([8,21,26].include?($fefieldeffect) && 
               grounded?)
              hpGain = 0
              if @battle.pbWeather == :Sandstorm
                hpGain += @totalhp/16
              end
              if [12,20,48,49].include?($fefieldeffect)
                hpGain += @totalhp/16
              end
              expectedHP += hpGain
              expectedHP = @totalhp if expectedHP > @totalhp
            end
          end
        end
        if hasActiveAbility?(:ICEBODY) && canHeal?
          hpGain = 0
          if @battle.pbWeather == :Hail
            hpGain += @totalhp/16
          end
          if [13,28,39,46].include?($fefieldeffect)
            hpGain += @totalhp/16
          end
          expectedHP += hpGain
          expectedHP = @totalhp if expectedHP > @totalhp
        end
        case @battle.pbWeather
        when :Sandstorm
          if takesSandstormDamage?
            expectedHP -= @totalhp/16
          end
        when :Hail
          if takesHailDamage?
            expectedHP -= @totalhp/16
          end
        when :ShadowSky
          if takesShadowSkyDamage?
            expectedHP -= @totalhp/16
          end
        end
        return 0 if expectedHP <= 0
      end
      if @battle.positions[@index].effects[PBEffects::FutureSightCounter] == 1
        expectedHP -= @totalhp * 0.2 # Arbitrary percentage of HP taken (underestimation)
      end
      return 0 if expectedHP <= 0
      if @battle.positions[@index].effects[PBEffects::Wish] == 1
        expectedHP += @battle.positions[@index].effects[PBEffects::WishAmount]
      end
      expectedHP = @totalhp if expectedHP > @totalhp
      case $fefieldeffect
      when 1 # Electric Terrain
        if grounded?
          if hasActiveAbility?(:VOLTABSORB) && canHeal?
            expectedHP += @totalhp/16
          end
          expectedHP = @totalhp if expectedHP > @totalhp
          if !hasActiveItem?(:HEAVYDUTYBOOTS) && takesIndirectDamage?
            if !pbHasType?(:ELECTRIC) && hasActiveAbility?(:WATERVEIL)
              expectedHP -= getTypeScalingFixedDamage(:ELECTRIC,@totalhp/8)
            end
          end
        end
      when 2 # Grassy Terrain
        if canHeal?
          if grounded? && !hasActiveAbility?(:OVERCOAT) && !hasActiveItem?(:HEAVYDUTYBOOTS)
            expectedHP += @totalhp/16
          end
          if hasActiveAbility?(:HONEYGATHER)
            expectedHP += @totalhp/16
          end
        end
      when 3 # Misty Terrain
        if hasActiveAbility?([:WATERVEIL,:SPONGE]) && canHeal?
          expectedHP += @totalhp/16
        end
      when 5 # Chess Board
        if hasActiveAbility?(:STALL) && canHeal?
          expectedHP += @totalhp/16
        end
      when 7 # Volcanic Field
        if takesVolcanicFieldDamage? && takesIndirectDamage?
          quotient = 8
          quotient /= 2 if hasActiveAbility?([:LEAFGUARD,:ICEBODY,:FLUFFY,:GRASSPELT,:FURCOAT,:TOUGHBARK,:COTTONDOWN])
          expectedHP -= getTypeScalingFixedDamage(:FIRE,@totalhp/quotient)
        end
      when 8 # Swamp Field
        if grounded?
          if @turnCount > 0 && !hasActiveAbility?([:QUICKFEET,:SUCTIONCUPS,:WATERVEIL,:SWIFTSWIM]) &&
             @battle.pbWeather != :Sun && !hasActiveItem?(:HEAVYDUTYBOOTS)
            if @stages[:SPEED] == -6 && !pbHasType?(:WATER) && !pbHasType?(:GROUND) && 
               !pbHasType?(:POISON)
              return 0 # Sure KO
            end
          end
        end
      when 9 # Rainbow Field
        if asleep? && canHeal?
          expectedHP += @totalhp/16
        end
      when 10 # Corrosive Field
        if hasActiveAbility?(:GRASSPELT) && takesCorrosiveFieldDamage? && takesIndirectDamage?
          expectedHP -= getTypeScalingFixedDamage(:POISON,@totalhp/8)
        end
      when 11 # Corrosive Mist Field
        if hasActiveAbility?(:POISONHEAL) && canHeal?
          expectedHP += @totalhp/8
        end
        expectedHP = @totalhp if expectedHP > @totalhp
        if hasActiveAbility?(:SPONGE)
          if !pbHasType?(:POISON)
            expectedHP -= @totalhp/8 if takesIndirectDamage?
          elsif canHeal?
            expectedHP += @totalhp/8
          end
        end
      when 15 # Forest Field
        if canHeal?
          if hasActiveAbility?(:SAPSIPPER)
            expectedHP += @totalhp/16
          end
          if hasActiveAbility?(:HONEYGATHER)
            expectedHP += @totalhp/16
          end
        end
      when 16 # Volcano Top Field
        if @battle.battleAI.volTopEruption? && takesIndirectDamage?
          if !pbHasType?(:FIRE) && !hasActiveAbility?([:MAGMAARMOR,:FLASHFIRE,:FLAREBOOST,
             :BLAZE,:FLAMEBODY,:SOLIDROCK,:STURDY,:BATTLEARMOR,:SHELLARMOR,:WATERBUBBLE,
             :WONDERGUARD,:PRISMARMOR,:HEATPROOF,:TURBOBLAZE]) && !@effects[PBEffects::AquaRing] &&
             !pbOwnSide.effects[PBEffects::WideGuard]
            quotient = 4
            if @battle.pbCheckGlobalAbility([:PRESSURE,:AFTERMATH])
              quotient /= 2
            end
            expectedHP -= getTypeScalingFixedDamage(:FIRE,@totalhp/quotient)
          end
        end
      when 18 # Short-Circuit Field
        if hasActiveAbility?(:VOLTABSORB) && canHeal?
          expectedHP += @totalhp/16
        end
        expectedHP = @totalhp if expectedHP > @totalhp
        if !pbHasType?(:ELECTRIC) && hasActiveAbility?(:WATERVEIL) && takesIndirectDamage?
          expectedHP -= getTypeScalingFixedDamage(:FIRE,@totalhp/8)
        end
      when 19 # Wasteland
        if hasActiveAbility?(:POISONHEAL) && canHeal? && grounded? && !hasActiveItem?(:HEAVYDUTYBOOTS)
          expectedHP += @totalhp/8
        end
        if @effects[PBEffects::WasteAnger] >= 3 && !pbHasType?(:POISON) && grounded? &&
           !hasActiveAbility?([:POISONHEAL,:GOOEY,:QUICKFEET])
          return 0 # Sure KO
        end
      when 21 # Water Surface
        if grounded?
          if hasActiveAbility?([:WATERABSORB,:FILTER,:DRYSKIN]) && canHeal?
            expectedHP += @totalhp/16
          end
          expectedHP = @totalhp if expectedHP > @totalhp
          if !pbHasType?(:ELECTRIC) && @battle.pbCheckGlobalAbility(:STATIC) && takesIndirectDamage?
            expectedHP -= getTypeScalingFixedDamage(:ELECTRIC,@totalhp/8)
          end
        end
      when 22 # Underwater
        if hasActiveAbility?([:WATERABSORB,:FILTER,:DRYSKIN]) && canHeal?
          expectedHP += @totalhp/8
        end
        expectedHP = @totalhp if expectedHP > @totalhp
        if takesUnderwaterFieldDamage? && takesIndirectDamage?
          quotient = 8
          if hasActiveAbility?([:FLAMEBODY,:MAGMAARMOR])
            quotient /= 2
          end
          if @battle.pbCheckGlobalAbility(:PRESSURE)
            quotient /= 2
          end
          expectedHP -= getTypeScalingFixedDamage(:WATER,@totalhp/quotient)
        end
        if !pbHasType?(:ELECTRIC) && @battle.pbCheckGlobalAbility(:STATIC) && takesIndirectDamage?
          expectedHP -= getTypeScalingFixedDamage(:ELECTRIC,@totalhp/8)
        end
      when 26 # Murkwater Surface
        if affectedByMurkwaterSurface? && @turnCount > 0
          if @stages[:SPECIAL_DEFENSE] == -6
            return 0 # Sure KO
          end
        end
        if grounded?
          if (hasActiveAbility?(:POISONHEAL) || pbHasType?(:POISON) && hasActiveAbility?(:WATERABSORB)) &&
             canHeal?
            expectedHP += @totalhp/8
          end
        end
      when 31 # Fairy Tale Field
        if hasActiveAbility?(:GUTS) && pbHasAnyStatus? && canHeal?
          expectedHP += @totalhp/8
        end
      when 33 # Flower Garden Field
        if $fecounter == 4
          if hasActiveAbility?(:SAPSIPPER) && canHeal?
            expectedHP += @totalhp/16
          end
        end
        if hasActiveAbility?(:HONEYGATHER) && canHeal?
          case $fecounter
          when 2
            expectedHP += @totalhp/16
          when 3,4
            expectedHP += @totalhp/8
          end
        end
      when 38 # Dimensional Field
        if @effects[PBEffects::HealBlock] > 0 && takesIndirectDamage?
          expectedHP -= @totalhp/16
        end
      when 40 # Haunted Field
        if asleep? && takesIndirectDamage?
          expectedHP -= @totalhp/16
        end
      when 41 # Corrupted Cave
        if hasActiveAbility?(:POISONHEAL)
          expectedHP += @totalhp/8
        end
        expectedHP = @totalhp if expectedHP > @totalhp
        if takesCorruptedCaveDamage? && takesIndirectDamage?
          if hasActiveAbility?([:GRASSPELT,:LEAFGUARD,:FLOWERVEIL,:FLOWERGIFT])
            expectedHP -= getTypeScalingFixedDamage(:POISON,@totalhp/4)
          else
            expectedHP -= getTypeScalingFixedDamage(:POISON,@totalhp/8)
          end
        end
      when 42 # Bewitched Woods
        if grounded? && pbHasType?(:GRASS) && canHeal?
          expectedHP += @totalhp/16
        end
        expectedHP = @totalhp if expectedHP > @totalhp
        # Sap Sipper 50% chance to hurt or heal, so cancels out to 0
        if asleep? && takesIndirectDamage?
          expectedHP -= @totalhp/16
        end
      when 44 # Indoors
        if hasActiveAbility?(:COMATOSE) && canHeal?
          expectedHP += @totalhp/16
        end
      when 48 # Beach
        if hasActiveAbility?(:COMATOSE) && canHeal?
          expectedHP += @totalhp/16
        end
      end
      return 0 if expectedHP <= 0
      expectedHP = @totalhp if expectedHP > @totalhp
      # To Do - Wasteland Entry Hazards
      if hasActiveItem?(:BLACKSLUDGE)
        if pbHasType?(:POISON)
          if canHeal?
            if [19,26,41].include?($fefieldeffect)
              expectedHP += @totalhp/8
            else
              expectedHP += @totalhp/16
            end
            expectedHP = @totalhp if expectedHP > @totalhp
          end
        elsif takesIndirectDamage?
          if [19,26,41].include?($fefieldeffect)
            expectedHP -= @totalhp/4
          else
            expectedHP -= @totalhp/8
          end
          return 0 if expectedHP <= 0
        end
      end
      if hasActiveItem?(:LEFTOVERS) && canHeal? && $fefieldeffect != 22
        if $fefieldeffect == 12
          expectedHP += @totalhp/8
        else
          expectedHP += @totalhp/16
        end
        expectedHP = @totalhp if expectedHP > @totalhp
      end
      if @effects[PBEffects::AquaRing]
        if $fefieldeffect == 11 && !pbHasType?(:POISON) && !pbHasType?(:STEEL) &&
           takesIndirectDamage?
          expectedHP -= @totalhp/16
          return 0 if expectedHP <= 0
        elsif canHeal?
          hpGain = @totalhp/16
          hpGain = (hpGain*1.3).floor if hasActiveItem?(:BIGROOT)
          hpGain *= 2 if [3,8,21,22,49].include?($fefieldeffect)
          expectedHP += hpGain
          expectedHP = @totalhp if expectedHP > @totalhp
        end
      end
      if @effects[PBEffects::Ingrain]
        if [8,41].include?($fefieldeffect) && !pbHasType?(:POISON) && !pbHasType?(:STEEL)
          if takesIndirectDamage?
            expectedHP -= @totalhp/16
            return 0 if expectedHP <= 0
          end
        elsif $fefieldeffect == 10 && !pbHasType?(:POISON)
          if takesIndirectDamage?
            expectedHP -= @totalhp/8
            return 0 if expectedHP <= 0
          end
        elsif canHeal?
          hpGain = @totalhp/16
          hpGain = (hpGain*1.3).floor if hasActiveItem?(:BIGROOT)
          if $fefieldeffect == 33 && $fecounter > 2
            hpGain *= 3
          elsif [2,15,19,42,47,49].include?($fefieldeffect) || $fefieldeffect == 33 && 
                $fecounter > 0
            hpGain *= 2
          end
          expectedHP += hpGain
          expectedHP = @totalhp if expectedHP > @totalhp
        end
      end
      # Check if HP lost by Leech Seed
      if @effects[PBEffects::LeechSeed] >= 0 && takesIndirectDamage?
        expectedHP -= @totalhp/8 # Amount lost never changes
        return 0 if expectedHP <= 0
      end
      # Check if HP gained by Leech Seed
      @battle.pbPriority(true).each do |b|
        next if b.effects[PBEffects::LeechSeed] != @index
        next if !b.takesIndirectDamage?
        hpGain = [b.totalhp/8,b.hp].min
        if $fefieldeffect == 33 && $fecounter >= 3
          hpGain *= 3
        elsif [2,19,33,42,47,49].include?($fefieldeffect)
          hpGain *= 2
        end
        expectedHP += getHPRecoveryFromDrain(hpGain,b)
        return 0 if expectedHP <= 0
        expectedHP = @totalhp if expectedHP > @totalhp
      end
      if @status == :POISON
        if hasActiveAbility?(:POISONHEAL)
          if canHeal?
            expectedHP += @totalhp/8
            expectedHP = @totalhp if expectedHP > @totalhp
          end
        elsif takesIndirectDamage?
          if @statusCount == 0
            if $fefieldeffect == 24
              dmg = @totalhp/16
            else
              dmg = @totalhp/8
            end
          else
            dmg = @totalhp*@effects[PBEffects::Toxic]/16
          end
          dmg *= 2 if $fefieldeffect == 10
          expectedHP -= dmg
          return 0 if expectedHP <= 0
        end
      end
      if @status == :BURN && takesIndirectDamage? && $fefieldeffect != 13
        dmg = @totalhp/16
        dmg = (dmg/2.0).round if hasActiveAbility?(:HEATPROOF)
        dmg = (dmg/2.0).round if $fefieldeffect == 46
        expectedHP -= dmg
        return 0 if expectedHP <= 0
      end
      if @effects[PBEffects::Nightmare] && asleep? && takesIndirectDamage? && @statusCount > 1 # Not going to wake up
        if $fefieldeffect == 40
          expectedHP -= @totalhp/3
        else
          expectedHP -= @totalhp/4
        end
      end
      if @effects[PBEffects::Curse] && $fefieldeffect != 29 && takesIndirectDamage?
        expectedHP -= @totalhp/4
      end
      if @effects[PBEffects::Trapping] > 1
        trapMove = nil
        for m in @battle.battlers[@effects[PBEffects::TrappingUser]].moves
          if m.id == @effects[PBEffects::TrappingMove]
            trapMove = m
            break
          end
        end
        if !($fefieldeffect == 24 && trapMove && trapMove.pp == 0)
          if takesIndirectDamage?
            if $fefieldeffect == 24
              hpLoss = @totalhp/16
            else
              hpLoss = @totalhp/8
            end
            if @battle.battlers[@effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
              hpLoss = hpLoss*4/3 # b.totalhp/6, b.totalhp/12
            end
            if @battle.battlers[@effects[PBEffects::TrappingUser]].hasActiveAbility?(:DISSOLUTION) &&
               ![3,22].include?($fefieldeffect)
              if [8,11].include?($fefieldeffect) || [10,26].include?($fefieldeffect) && 
                 @battle.battlers[@effects[PBEffects::TrappingUser]].grounded?
                hpLoss = hpLoss*3
              else
                hpLoss = hpLoss*2
              end
            end
            if [7,11,32].include?($fefieldeffect) && @effects[PBEffects::TrappingMove] == :FIRESPIN ||
               $fefieldeffect == 7 && @effects[PBEffects::TrappingMove] == :MAGMASTORM ||
               $fefieldeffect == 12 && @effects[PBEffects::TrappingMove] == :SANDTOMB || 
               [21,22].include?($fefieldeffect) && @effects[PBEffects::TrappingMove] == :WHIRLPOOL ||
               $fefieldeffect == 22 && @effects[PBEffects::TrappingMove] == :CLAMP ||
               [2,15,47].include?($fefieldeffect) && [:INFESTATION,:SNAPTRAP].include?(@effects[PBEffects::TrappingMove]) ||
               $fefieldeffect == 47 && @effects[PBEffects::TrappingMove] == :BIND
              hpLoss = hpLoss*4/3
            elsif $fefieldeffect == 33 && @effects[PBEffects::TrappingMove] == :INFESTATION
              case $fecounter
              when 2
                hpLoss = hpLoss*4/3
              when 3
                hpLoss = hpLoss*2
              when 4
                hpLoss = hpLoss*8/3
              end
            end
            expectedHP -= hpLoss
          end
        end
      end
      if @effects[PBEffects::Splinter] > 0 && takesIndirectDamage?
        expectedHP -= @totalhp/8
      end
      if (asleep? && ![9,29].include?($fefieldeffect) || [31,38,40].include?($fefieldeffect)) &&
         takesIndirectDamage?
        eachNearOpposing do |o|
          if o.hasActiveAbility?(:BADDREAMS)
            if $fefieldeffect == 42
              expectedHP -= @totalhp/4
            else
              expectedHP -= @totalhp/8
            end
          end
        end
      end
      if (paralyzed? && ![9,48].include?($fefieldeffect) || $fefieldeffect == 18) &&
         takesIndirectDamage?
        eachNearOpposing do |o|
          if o.hasActiveAbility?(:PAININGPARALYSIS)
            if $fefieldeffect == 1
              expectedHP -= @totalhp/4
            else
              expectedHP -= @totalhp/8
            end
          end
        end
      end
      if frozen? && $fefieldeffect != 16 && takesIndirectDamage?
        eachNearOpposing do |o|
          if o.hasActiveAbility?(:SNAPFREEZE)
            if [13,28,32,39,46].include?($fefieldeffect)
              expectedHP -= @totalhp/3
            else
              expectedHP -= @totalhp/4
            end
          end
        end
      end
      return 0 if expectedHP <= 0
      if hasActiveAbility?(:DEEPSLEEP) && ![6,38,39,40].include?($fefieldeffect) &&
         canHeal?
        if [2,42,48].include?($fefieldeffect)
          expectedHP += @totalhp/4
        else
          expectedHP += @totalhp/8
        end
      end
      expectedHP = @totalhp if expectedHP > @totalhp
      if hasActiveAbility?(:LIFEFORCE) && ![12,38,40].include?($fefieldeffect) &&
         !pbHasAnyStatus?
        if $fefieldeffect == 8
          expectedHP -= @totalhp/16 if takesIndirectDamage?
          return 0 if expectedHP <= 0
        elsif canHeal?
          if [19,29,31,42].include?($fefieldeffect)
            expectedHP += @totalhp/8
          else
            expectedHP += @totalhp/16
          end
          expectedHP = @totalhp if expectedHP > @totalhp
        end
      end
      if canHeal? && $fefieldeffect != 11
        eachNearAlly do |a|
          if a.hasActiveAbility?(:MEDIC)
            if [9,29].include?($fefieldeffect)
              expectedHP += a.totalhp/4
            else
              expectedHP += a.totalhp/8
            end
          end
        end
      end
      if pbHasType?(:GRASS) && ![8,11,22,26].include?($fefieldeffect) && canHeal?
        @battle.eachBattler do |b|
          if b.hasActiveAbility?(:SOOTHINGAROMA)
            if [3,48].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
              expectedHP += @totalhp/8
            else
              expectedHP += @totalhp/16
            end
          end
        end
      end
      if pbHasAnyStatus? && ![10,11,41].include?($fefieldeffect) && !($fefieldeffect == 26 &&
         grounded?) && canHeal?
        eachNearAlly do |a|
          if a.hasActiveAbility?(:SEEDREVITALIZATION) && !a.effects[PBEffects::SeedRevitalization]
            expectedHP += @totalhp
          end
        end
        if [2,15,47].include?($fefieldeffect) && hasActiveAbility?(:SEEDREVITALIZATION)
          expectedHP += @totalhp
        end
      end
      expectedHP = @totalhp if expectedHP > @totalhp
      if hasActiveItem?(:STICKYBARB) && takesIndirectDamage?
        expectedHP -= @totalhp/8
      end
      return 0 if expectedHP < 0
      return expectedHP
    end
    
    # Returns the expected amount of type-scaling fixed damage (against this battler)
    def getTypeScalingFixedDamage(type,damage)
      bTypes = pbTypes(true)
      eff = Effectiveness.calculate(type,bTypes[0],bTypes[1],bTypes[2])
      if Effectiveness.ineffective?(eff)
        return 0
      else
        eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
        return (damage*eff).round
      end
    end
    
    # Returns the amount of HP to be recovered through draining
    def getHPRecoveryFromDrain(amt,target)
      amt *= 2 if [19,42].include?($fefieldeffect)
      if target.hasActiveAbility?(:LIQUIDOOZE) && $fefieldeffect != 12
        if takesIndirectDamage?
          amt *= -1
          amt *= 2 if [8,19,26,41].include?($fefieldeffect)
        else
          return 0
        end
      else
        if canHeal?
          if hasActiveItem?(:BIGROOT)
            if [8,47].include?($fefieldeffect)
              amt = (amt*1.5).floor
            else
              amt = (amt*1.3).floor
            end
          end
        else
          return 0
        end
      end
      return amt
    end
    
    # Returns this battler's expected highest damage against the given target
    # Can be used in getMoveScore method (but not pbRoughDamage) because it doesn't call itself
    def highestExpectedDamage(target,fullInfo=false,excludeVariableFixed=false,requireTargetable=true)
      maxMove = nil
      maxDamage = 0
      for m in knownMoves
        next if excludeVariableFixed && @battle.battleAI.getVariableFixedFunctions.include?(m.function)
        target_data = m.pbTarget(self)
        if @battle.pbMoveCanTarget?(@index,target.index,target_data) || !requireTargetable
          types = m.pbCalcTypes(self)
          typeMod = m.pbCalcTypeMod(types,self,target) /  Effectiveness::NORMAL_EFFECTIVE
          dmgGuess = m.baseDamage * typeMod
          # STAB
          if types
            for t in types
              if pbHasType?(t) || t == :DARK && hasActiveAbility?(:TWILIGHTSILK)
                if hasActiveAbility?(:ADAPTABILITY)
                  if [12,46,49].include?($fefieldeffect)
                    dmgGuess *= 2.5
                  else
                    dmgGuess *= 2
                  end
                elsif $fefieldeffect != 35
                  dmgGuess *= 1.5
                end
                break
              end
            end
          end
          if dmgGuess > maxDamage
            maxMove = m
            maxDamage = dmgGuess
          end
        end
      end
      if maxDamage > 0
        maxDamage = @battle.battleAI.pbRoughDamage(maxMove,maxMove,self,target,@hp,target.hp)
      end
      return fullInfo ? [maxDamage,maxMove] : maxDamage
    end
    
    # Returns a ratio of this battler's defensive capability to its nearby opponents' offensive capability
    def wallRatio
      ratio = 0
      selfDef = pbDefense(false)
      selfSpDef = pbSpDef(false)
      eachNearOpposing do |b|
        bAtk = b.pbAttack(false)
        bSpAtk = b.pbSpAtk(false)
        if bAtk > bSpAtk
          ratio += 1.0 * bAtk / selfDef
        else
          ratio += 1.0 * bSpAtk / selfSpDef
        end
      end
      return ratio / numNearOpposing
    end
  end
  