class PokeBattle_Battler
    #=============================================================================
    # Called when a Pokémon (self) is sent into battle or its ability changes.
    #=============================================================================
    def pbEffectsOnSwitchIn(switchIn=false)
      # Healing Wish/Lunar Dance/entry hazards
      @battle.pbOnActiveOne(self) if switchIn
      # Primal Revert upon entering battle
      @battle.pbPrimalReversion(@index) if !fainted?
      # Ending primordial weather, checking Trace
      pbContinualAbilityChecks(true)
      # Abilities that trigger upon switching in
      if (!fainted? && unstoppableAbility?) || abilityActive?
        #BattleHandlers.triggerAbilityOnSwitchIn(self.ability,self,@battle)
        pbAbilitiesOnSwitchIn
      end
      # Check for end of primordial weather
      @battle.pbEndPrimordialWeather
      # Items that trigger upon switching in (Air Balloon message)
      if switchIn && itemActive?
        BattleHandlers.triggerItemOnSwitchIn(self.item,self,@battle)
      end
      # Berry check, status-curing ability check
      pbHeldItemTriggerCheck if switchIn
      pbAbilityStatusCureCheck
    end
  
    #=============================================================================
    # Ability effects
    #=============================================================================
    def pbAbilitiesOnSwitchOut
      #BattleHandlers.triggerAbilityOnSwitchOut(self.ability,self,false)
      if hasActiveAbility?(:NATURALCURE)
        @status = :NONE
      end
      if hasActiveAbility?(:REGENERATOR)
        if [19,29,31,48].include?($fefieldeffect)
          pbRecoverHP(@totalhp/2,false,false)
        else
          pbRecoverHP(@totalhp/3,false,false)
        end
      end
      # Reset form
      @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
      # Treat self as fainted
      @hp = 0
      @fainted = true
      # Check for end of primordial weather
      @battle.pbEndPrimordialWeather
    end
  
    def pbAbilitiesOnFainting
      # Self fainted; check all other battlers to see if their abilities trigger
      @battle.pbPriority(true).each do |b|
        next if !b #|| !b.abilityActive?
        #BattleHandlers.triggerAbilityChangeOnBattlerFainting(b.ability,b,self,@battle)
        if b.hasActiveAbility?(:POWEROFALCHEMY) && b.opposes?(self) && !(ungainableAbility? ||
           [:POWEROFALCHEMY,:RECEIVER,:TRACE,:WONDERGUARD].include?(@ability_id))
          @battle.pbShowAbilitySplash(b,true)
          b.ability = GameData::Ability.try_get(@ability_id)
          b.effects[PBEffects::HolyAbilities] = @effects[PBEffects::HolyAbilities]
          @battle.pbReplaceAbilitySplash(b)
          @battle.pbDisplay(_INTL("{1}'s {2} was taken over!",pbThis,abilityName))
          @battle.pbHideAbilitySplash(b)
        end
        if b.hasActiveAbility?(:RECEIVER) && b.opposes?(self) && !(ungainableAbility? ||
           [:POWEROFALCHEMY,:RECEIVER,:TRACE,:WONDERGUARD].include?(@ability_id))
          @battle.pbShowAbilitySplash(b,true)
          b.ability = GameData::Ability.try_get(@ability_id)
          b.effects[PBEffects::HolyAbilities] = @effects[PBEffects::HolyAbilities]
          @battle.pbReplaceAbilitySplash(b)
          @battle.pbDisplay(_INTL("{1}'s {2} was taken over!",pbThis,abilityName))
          @battle.pbHideAbilitySplash(b)
        end
      end
      @battle.pbPriority(true).each do |b|
        next if !b #|| !b.abilityActive?
        #BattleHandlers.triggerAbilityOnBattlerFainting(b.ability,b,self,@battle)
        if b.hasActiveAbility?(:SOULHEART) && ![38,39].include?($fefieldeffect)
          if [3,9,31].include?($fefieldeffect)
            b.pbRaiseStatStageByAbility([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,b)
          elsif $fefieldeffect == 40
            b.pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,b)
          else
            b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,b)
          end
        end
        if b.hasActiveAbility?(:NECROMANCY) && [40,42].include?($fefieldeffect)
          b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,b)
        end
        if b.hasActiveAbility?(:PATIENCE)
          b.pbRaiseStatStageByAbility([:DEFENSE,:SPECIAL_DEFENSE],1,b)
        end
      end
    end
  
    # Used for Emergency Exit/Wimp Out.
    def pbAbilitiesOnDamageTaken(oldHP,newHP=-1,moveTypes=[])
      newHP = @hp if newHP<0
      return false if (oldHP<=@totalhp/2 || newHP>@totalhp/2) && !(hasActiveAbility?(:WIMPOUT) &&
                      ($fefieldeffect == 32 && moveTypes.include?(:DRAGON) || $fefieldeffect == 5))
      #ret = BattleHandlers.triggerAbilityOnHPDroppedBelowHalf(self.ability,self,@battle)
      if hasActiveAbility?(:EMERGENCYEXIT) && ![30,45].include?($fefieldeffect) ||
         hasActiveAbility?(:WIMPOUT) && $fefieldeffect != 31
        return false if @effects[PBEffects::SkyDrop]>=0 || inTwoTurnAttack?("0CE")   # Sky Drop
        # In wild battles
        if @battle.wildBattle?
          return false if opposes? && @battle.pbSideBattlerCount(@index)>1
          return false if !@battle.pbCanRun?(@index)
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbSEPlay("Battle flee")
          @battle.pbDisplay(_INTL("{1} fled from battle!",pbThis))
          @battle.decision = 3   # Escaped
          return true
        end
        # In trainer battles
        return false if @battle.pbAllFainted?(idxOpposingSide)
        return false if !@battle.pbCanSwitch?(@index)   # Battler can't switch out
        return false if !@battle.pbCanChooseNonActive?(@index)   # No Pokémon can switch in
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,abilityName))
        end
        @battle.pbDisplay(_INTL("{1} went back to {2}!",pbThis,@battle.pbGetOwnerName(@index)))
        if @battle.endOfRound   # Just switch out
          @battle.scene.pbRecall(@index) if !fainted?
          pbAbilitiesOnSwitchOut   # Inc. primordial weather check
          return true
        end
        newPkmn = @battle.pbGetReplacementPokemonIndex(@index)   # Owner chooses
        return false if newPkmn<0   # Shouldn't ever do this
        @battle.pbRecallAndReplace(@index,newPkmn)
        @battle.pbClearChoice(@index)   # Replacement Pokémon does nothing this round
        return true
      end
      return false   # Has not switched out
    end
  
    # Called when a Pokémon (self) enters battle, at the end of each move used,
    # and at the end of each round.
    def pbContinualAbilityChecks(onSwitchIn=false)
      # Holy Quad Abilities
      if $fefieldeffect == 29
        for b in @battle.battlers # Needs to cycle through all to account for others' abilities in further methods
          next if !b || b.fainted? || b.effects[PBEffects::HolyAbilities] != []
          abils = b.pokemon.getAbilityList
          for a in abils
            b.effects[PBEffects::HolyAbilities].push(a[0])
          end
          @effects[PBEffects::HolyAbilities] |= [] # Remove duplicates
          if b.effects[PBEffects::HolyAbilities].length > 1
            abilString = GameData::Ability.get(b.effects[PBEffects::HolyAbilities][0]).name#b.effects[PBEffects::HolyAbilities][0].name
            for i in 1...b.effects[PBEffects::HolyAbilities].length
              if b.effects[PBEffects::HolyAbilities].length > 2
                abilString += ", "
                if i == b.effects[PBEffects::HolyAbilities].length - 1
                  abilString += "and "
                end
                abilString += GameData::Ability.get(b.effects[PBEffects::HolyAbilities][i]).name
              else
                abilString += " and "+GameData::Ability.get(b.effects[PBEffects::HolyAbilities][i]).name
              end
            end
            @battle.pbDisplayPaused(_INTL("The heavens granted {1} its abilities {2}!",b.pbThis(true),abilString))
          end
        end
      else
        @effects[PBEffects::HolyAbilities] = []
      end
      # As One
      if hasActiveAbility?(:ASONE)
        if @effects[PBEffects::AsOne] == []
          abils = @pokemon.getAbilityList(GameData::Species.get_species_form(@pokemon.species,0))
          @effects[PBEffects::AsOne].push(abils[@pokemon.ability_index][0])
          @effects[PBEffects::AsOne] |= [] # Remove duplicates
          if !@pokemon.fused.nil?
            @effects[PBEffects::AsOne].push(@pokemon.fused.ability)
          # Add elsif to account for specific trainers that used fused mons because they don't use this property
          end
          if @effects[PBEffects::AsOne].length == 2
            @battle.pbDisplay(_INTL("As One copied {1} and {2}!",@effects[PBEffects::AsOne][0].name,@effects[PBEffects::AsOne][1].name))
          else
            @battle.pbDisplay(_INTL("As One copied {1}!",@effects[PBEffects::AsOne][0].name))
          end
        end
      else
        @effects[PBEffects::AsOne] = []
      end
      # Check for end of primordial weather
      @battle.pbEndPrimordialWeather
      # Trace
      if hasActiveAbility?(:TRACE) && $fefieldeffect != 5
        # NOTE: In Gen 5 only, Trace only triggers upon the Trace bearer switching
        #       in and not at any later times, even if a traceable ability turns
        #       up later. Essentials ignores this, and allows Trace to trigger
        #       whenever it can even in the old battle mechanics.
        choices = []
        @battle.eachOtherSideBattler(@index) do |b|
          next if b.ungainableAbility? || [:POWEROFALCHEMY,:RECEIVER,:TRACE].include?(b.ability_id)
          choices.push(b)
        end
        if choices.length>0
          choice = choices[@battle.pbRandom(choices.length)]
          @battle.pbShowAbilitySplash(self)
          if $fefieldeffect == 29
            abils = @effects[PBEffects::HolyAbilities]
            abils[abils.index(:TRACE)] = choice.ability
            @effects[PBEffects::HolyAbilities] |= [] # Remove duplicates
          end
          self.ability = choice.ability
          @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!",pbThis,choice.pbThis(true),choice.abilityName))
          if $fefieldeffect == 24
            pbChangeTypes(choice)
            @battle.pbDisplay(_INTL("{1} also copied {2}'s type!",pbThis,choice.pbThis(true)))
          elsif [34,42].include?($fefieldeffect)
            GameData::Stat.each_battle { |s| @stages[s.id] = choice.stages[s.id] }
            if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
              @effects[PBEffects::FocusEnergy] = choice.effects[PBEffects::FocusEnergy]
              @effects[PBEffects::LaserFocus]  = choice.effects[PBEffects::LaserFocus]
            end
            @battle.pbDisplay(_INTL("{1} also copied {2}'s stat changes!",pbThis,choice.pbThis(true)))
          end
          @battle.pbHideAbilitySplash(self)
          if !onSwitchIn
            #BattleHandlers.triggerAbilityOnSwitchIn(self.ability,self,@battle)
            pbAbilitiesOnSwitchIn
          end
        end
      end
    end
    
    def pbAbilitiesOnSwitchIn
      if $DEBUG
        echo("\n#{pbThis}'s Ability: #{abilityName} (index #{@pokemon.ability_index})")
        PBDebug.log("\n#{pbThis}'s Ability: #{abilityName}")
      end
      if hasActiveAbility?(:NEUTRALIZINGGAS) && !@battle.field.effects[PBEffects::NeutralizingGas] &&
         ![3,22,35,43].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1}'s {2} nullified all abilities!",pbThis,abilityName))
        @battle.field.effects[PBEffects::NeutralizingGas] = true
        @battle.pbHideAbilitySplash(self)
        if $fefieldeffect == 41
          for b in @battle.battlers
            next if self == b || !b.pbCanParalyze?(self,false)
            b.pbParalyze(self,_INTL("{1}'s {2} stunned {3}! It may be unable to move!",pbThis,abilityName,b.pbThis(true)))
          end
        end
      end
      if hasActiveAbility?(:MUMMY) && $fefieldeffect == 40
        for b in @battle.battlers
          if opposes?(b) && !b.unstoppableAbility? && b.ability != ability
            oldAbil = GameData::Ability.try_get(b.ability_id)
            b.ability = GameData::Ability.try_get(@ability_id)
            @battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",b.pbThis,b.abilityName,pbThis(true)))
            b.pbOnAbilityChanged(oldAbil)
          end
        end
      end
      if hasActiveAbility?(:ALPHABETIZATION) && $fefieldeffect == 37
        pbChangeForm(rand(@pokemon.getNumForms+1),_INTL("The psychic energy caused {1} to change forms!",pbThis(true)))
      end
      if hasActiveAbility?(:ELECTRICSURGE)
        if (@battle.field.effects[PBEffects::FEDuration] > 0 || $fefieldeffect == 0) && 
           ![1,35].include?($fefieldeffect)
          @battle.changeField(1,"Electricity ran across the battlefield!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 17
          @battle.changeField(1,"A burst of electric currents overtook the battlefield!",5,hasTerrainExtender?)
        elsif $fefieldeffect == 18
          @battle.changeField(17,"SYSTEM ONLINE.",0,false,true,true)
        elsif $fefieldeffect == 25
          @battle.changeCrystalBackground(3)
        elsif $fefieldeffect == 40
          @battle.changeField(18,"The field was showered in electricity!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 43
          @battle.changeField(1,"Static electricity ran throughout the clouds!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 44
          @battle.changeField(18,"The electrical appliances shorted out!",5,hasTerrainExtender?,true)
        end
      end
      if hasActiveAbility?(:GRASSYSURGE)
        if (@battle.field.effects[PBEffects::FEDuration] > 0 || $fefieldeffect == 0) && 
           ![2,35].include?($fefieldeffect)
          @battle.changeField(2,"Grass grew over the battlefield!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 12
          @battle.changeField(49,"The desert grew some shrubs!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 15
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("The forest grew some more trees!"))
          when 2
            @battle.changeField(47,"The forest grew into a jungle!",0,false,true,true)
          end
        elsif $fefieldeffect == 25
          @battle.changeCrystalBackground(2)
        elsif $fefieldeffect == 29
          @battle.changeField(31,"The field morphed into a magical fairy tale!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 40
          @battle.changeField(42,"A forest grew around the battlefield!",5,hasTerrainExtender?)
        end
      end
      if hasActiveAbility?(:MISTYSURGE)
        if (@battle.field.effects[PBEffects::FEDuration] > 0 || $fefieldeffect == 0) && 
           ![3,35].include?($fefieldeffect)
          @battle.changeField(3,"Mist swirled about the battlefield!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 10
          @battle.changeField(11,"The corrosion spread through the air!",5,hasTerrainExtender?)
        elsif $fefieldeffect == 25
          @battle.changeCrystalBackground(4)
        elsif $fefieldeffect == 26
          @battle.changeField(21,"The murk was purified!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 38
          @battle.changeField(0,"The dimension dissipated!",5,hasTerrainExtender?)
        elsif $fefieldeffect == 40
          @battle.changeField(29,"The evil spirits have been exorcised!",5,hasTerrainExtender?)
        elsif $fefieldeffect == 41
          @battle.changeField(23,"The cave's corruption was eradicated!")
        elsif $fefieldeffect == 43
          @battle.changeField(3,"The clouds thickened into a misty fog!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 44
          @battle.changeField(3,"The mist engulfed the closed area!",5,hasTerrainExtender?,true)
        end
      end
      if hasActiveAbility?(:PSYCHICSURGE)
        if (@battle.field.effects[PBEffects::FEDuration] > 0 || $fefieldeffect == 0) && 
           ![35,37].include?($fefieldeffect)
          @battle.changeField(37,"Mysterious energy spread throughout the battlefield!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 10
          $fecounter += 1
          case $fecounter
          when 1
            @battle.pbDisplay(_INTL("The corrosion began to morph!"))
          when 2
            @battle.changeField(19,"The corrosion started moving on its own!",5,hasTerrainExtender?)
          end
        elsif $fefieldeffect == 15
          @battle.changeField(42,"The forest was infused with magical energy!",5,hasTerrainExtender?,true)
        elsif $fefieldeffect == 25
          @battle.changeCrystalBackground(6)
        elsif $fefieldeffect == 40
          @battle.changeField(37,"Strange energy enveloped the field!",5,hasTerrainExtender?)
        elsif $fefieldeffect == 47
          @battle.changeField(42,"The forestry was infused with magical energy!",0,false,true)
        end
      end
      if $fefieldeffect != 44
        if hasActiveAbility?(:DELTASTREAM) && ![17,47,22].include?($fefieldeffect)
          if @battle.field.weather != :StrongWinds
            @battle.pbShowAbilitySplash(self)
            if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,abilityName))
            end
            fixedDuration = false
            fixedDuration = true if Settings::FIXED_DURATION_WEATHER_FROM_ABILITY
            @battle.pbStartWeather(self,:StrongWinds,fixedDuration,true,-1)
          end
        end
        if $fefieldeffect != 35
          if hasActiveAbility?(:DESOLATELAND)
            if @battle.field.weather != :HarshSun
              @battle.pbShowAbilitySplash(self)
              if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,abilityName))
              end
              fixedDuration = false
              fixedDuration = true if Settings::FIXED_DURATION_WEATHER_FROM_ABILITY
              @battle.pbStartWeather(self,:HarshSun,fixedDuration,true,-1)
            end
          end
          if $fefieldeffect != 22
            if hasActiveAbility?(:PRIMORDIALSEA)
              if @battle.field.weather != :HeavyRain
                @battle.pbShowAbilitySplash(self)
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,abilityName))
                end
                fixedDuration = false
                fixedDuration = true if Settings::FIXED_DURATION_WEATHER_FROM_ABILITY
                @battle.pbStartWeather(self,:HeavyRain,fixedDuration,true,-1)
              end
            end
            if hasActiveAbility?(:DRIZZLE)
              if ![:HarshSun,:HeavyRain,:StrongWinds].include?(@battle.field.weather) &&
                 @battle.field.weather != :Rain
                @battle.pbShowAbilitySplash(self)
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,abilityName))
                end
                fixedDuration = false
                fixedDuration = true if Settings::FIXED_DURATION_WEATHER_FROM_ABILITY
                @battle.pbStartWeather(self,:Rain,fixedDuration)
              end
            end
            if hasActiveAbility?(:DROUGHT) && $fefieldeffect != 21
              if ![:HarshSun,:HeavyRain,:StrongWinds].include?(@battle.field.weather) &&
                 @battle.field.weather != :Sun
                @battle.pbShowAbilitySplash(self)
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,abilityName))
                end
                fixedDuration = false
                fixedDuration = true if Settings::FIXED_DURATION_WEATHER_FROM_ABILITY
                @battle.pbStartWeather(self,:Sun,fixedDuration)
              end
            end
            if hasActiveAbility?(:SANDSTREAM) || hasActiveAbility?(:SANDSPIT) && [12,20,49].include?($fefieldeffect)
              if ![:HarshSun,:HeavyRain,:StrongWinds].include?(@battle.field.weather) &&
                 @battle.field.weather != :Sandstorm
                @battle.pbShowAbilitySplash(self)
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,abilityName))
                end
                fixedDuration = false
                fixedDuration = true if Settings::FIXED_DURATION_WEATHER_FROM_ABILITY
                @battle.pbStartWeather(self,:Sandstorm,fixedDuration)
              end
            end
            if hasActiveAbility?(:SNOWWARNING)
              if ![:HarshSun,:HeavyRain,:StrongWinds].include?(@battle.field.weather) &&
                 @battle.field.weather != :Hail
                @battle.pbShowAbilitySplash(self)
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,abilityName))
                end
                fixedDuration = false
                fixedDuration = true if Settings::FIXED_DURATION_WEATHER_FROM_ABILITY
                @battle.pbStartWeather(self,:Hail,fixedDuration)
              end
            end
          end
        end
      end
      if hasActiveAbility?(:AIRLOCK) && ![27,28,38,43].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} has {2}!",pbThis,abilityName))
        end
        if [27,28,38,43].include?($fefieldeffect)
          @battle.pbDisplay(_INTL("The weather disappeared."))
          @battle.field.weather = :None
          @battle.field.weatherDuration = 0
        else
          @battle.pbDisplay(_INTL("The effects of the weather disappeared."))
        end
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:CLOUDNINE) && ![12,43,48,49].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} has {2}!",pbThis,abilityName))
        end
        if [43,48].include?($fefieldeffect)
          @battle.pbDisplay(_INTL("The weather disappeared."))
          @battle.field.weather = :None
          @battle.field.weatherDuration = 0
        else
          @battle.pbDisplay(_INTL("The effects of the weather disappeared."))
        end
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:ANTICIPATION) && pbOwnedByPlayer? && $fefieldeffect != 24
        battlerTypes = pbTypes(true)
        type1 = battlerTypes[0]
        type2 = battlerTypes[1] || type1
        type3 = battlerTypes[2] || type2
        found = false
        @battle.eachOtherSideBattler(@index) do |b|
          b.eachMove do |m|
            next if m.statusMove?
            if type1
              moveTypes = m.types
              if Settings::MECHANICS_GENERATION >= 6 && m.function == "090"   # Hidden Power
                moveTypes = pbHiddenPower(b.pokemon)[0]
              end
              eff = Effectiveness.calculate(moveTypes,type1,type2,type3)
              next if Effectiveness.ineffective?(eff)
              next if !Effectiveness.super_effective?(eff) && m.function != "070"   # OHKO
            else
              next if m.function != "070"   # OHKO
            end
            found = true
            break
          end
          break if found
        end
        if found
          @battle.pbShowAbilitySplash(self)
          @battle.pbDisplay(_INTL("{1} shuddered with anticipation!",pbThis))
          @battle.pbHideAbilitySplash(self)
        end
      end
      if hasActiveAbility?(:FOREWARN) && $fefieldeffect != 35
        highestPower = 0
        forewarnMoves = []
        @battle.eachOtherSideBattler(@index) do |b|
          b.eachMove do |m|
            power = m.baseDamage
            power = 160 if ["070"].include?(m.function)    # OHKO
            power = 150 if ["08B"].include?(m.function)    # Eruption
            # Counter, Mirror Coat, Metal Burst
            power = 120 if ["071","072","073"].include?(m.function)
            # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
            # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
            # Natural Gift, Trump Card, Flail, Grass Knot
            power = 80 if ["06A","06B","06D","06E","06F",
                           "089","08A","08C","08D","090",
                           "096","097","098","09A"].include?(m.function)
            next if power<highestPower
            forewarnMoves = [] if power>highestPower
            forewarnMoves.push(m)
            highestPower = power
          end
        end
        if forewarnMoves.length>0
          @battle.pbShowAbilitySplash(self)
          forewarnMove = forewarnMoves[rand(forewarnMoves.length)]
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} was alerted to {2}!",pbThis,forewarnMove.name))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} alerted it to {3}!",pbThis,abilityName,forewarnMove.name))
          end
          # Opposing side has only 1 mon (we know who has the move)
          if @battle.pbSideSize(@index + 1) == 1 && !@battle.battlers[1].pokemon.moveMemory.include?(forewarnMove)
            @battle.battlers[1].pokemon.moveMemory.push(forewarnMove)
          end
          @battle.pbHideAbilitySplash(self)
        end
      end
      if hasActiveAbility?(:DARKAURA) && ![3,9,29,48].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating a dark aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:FAIRYAURA) && ![11,32,38,40].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating a fairy aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:EARTHENAURA) && ![9,17,21,26,31,35,38,39,43,44].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating an earthen aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:JUNGLETOTEM) && ![10,12,17,21,22,26,38,39,44].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating a natural aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:VITALICAURA) && ![12,17,48,49].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating a vitalic aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:AQUABOOST) && ![7,12,46].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating an aquatic aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:ETERNALLIGHT) && ![38,40].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating a bright aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:TACTICS)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating an intelligent aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:DEATHWALTZ) && $fefieldeffect != 29
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating a necrotic aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:AURABREAK)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:COMATOSE,false,true) && $fefieldeffect != 1 || hasActiveAbility?(:INSOMNIA) &&
         [4,34].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is drowsing!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:DOWNLOAD) && ![35,38,39].include?($fefieldeffect)
        if $fefieldeffect == 24
          stat = @battle.generateRandomStat
        else
          oDef = oSpDef = 0
          @battle.eachOtherSideBattler(@index) do |b|
            oDef   += b.defense
            oSpDef += b.spdef
          end
          stat = (oDef<oSpDef) ? :ATTACK : :SPECIAL_ATTACK
        end
        increment = ($fefieldeffect == 17) ? 2 : 1
        pbRaiseStatStageByAbility(stat,increment,self)
      end
      if hasActiveAbility?(:FRISK) && pbOwnedByPlayer? && $fefieldeffect != 30
        foes = []
        @battle.eachOtherSideBattler(@index) do |b|
          foes.push(b) if b.item
        end
        if foes.length>0
          @battle.pbShowAbilitySplash(self)
          foe = foes[rand(foes.length)]
          if $fefieldeffect == 6 && !self.item && !(foe.unlosableItem?(foe.item) || 
             unlosableItem?(foe.item) || foe.hasStickyHold?)
            self.item = foe.item
            # Permanently steal the item from wild Pokémon
            if @battle.wildBattle? && foe.opposes? && foe.initialItem == foe.item && 
               !initialItem
              setInitialItem(b.item)
              b.pbRemoveItem
            else
              b.pbRemoveItem(false)
            end
            @battle.pbDisplay(_INTL("{1} frisked {2} and stole its {3}!",pbThis,foe.pbThis(true),foe.itemName))
            pbHeldItemTriggerCheck
          else
            if Settings::MECHANICS_GENERATION >= 6
              foes.each do |b|
                @battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",pbThis,b.pbThis(true),b.itemName))
              end
            else
              foe = foes[rand(foes.length)]
              @battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",pbThis,foe.itemName))
            end
          end
          @battle.pbHideAbilitySplash(self)
        end
      end
      if hasActiveAbility?(:IMPOSTER) && !@effects[PBEffects::Transform]
        choice = pbDirectOpposing
        if !choice.fainted? && !(choice.effects[PBEffects::Transform] || choice.effects[PBEffects::Illusion] ||
           choice.effects[PBEffects::Substitute]>0 || choice.effects[PBEffects::SkyDrop]>=0 ||
           choice.semiInvulnerable?)
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          @battle.pbAnimation(:TRANSFORM,self,choice)
          @battle.scene.pbChangePokemon(self,choice.pokemon)
          pbTransform(choice)
        end
      end
      if hasActiveAbility?(:INTIMIDATE) && ![9,48].include?($fefieldeffect) || $fefieldeffect == 6 && 
         hasActiveAbility?(:SCARECROW)
        @battle.pbShowAbilitySplash(self)
        @battle.eachOtherSideBattler(@index) do |b|
          next if !b.near?(self)
          if [32,39,40,45].include?($fefieldeffect)
            b.pbLowerStatStageEntryAbility(:ATTACK,2,self)
          else
            b.pbLowerStatStageEntryAbility(:ATTACK,1,self)
          end
          b.pbItemOnIntimidatedCheck
        end
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?([:FLASHFIRE,:ILLUMINATE,:TURBOBLAZE,:ETERNALLIGHT]) && $fefieldeffect == 4
        @battle.pbDisplay(_INTL("{1}'s {2} blinded the opponents!",pbThis,abilityName))
        eachNearOpposing do |b|
          b.pbLowerStatStage(:ACCURACY,1,self)
        end
      end
      if hasActiveAbility?([:DANCER,:QUIP]) && $fefieldeffect == 5
        @battle.pbDisplay(_INTL("{1}'s {2} distracted the opponents!",pbThis,abilityName))
        eachNearOpposing do |b|
          b.pbLowerStatStage(:ACCURACY,1,self)
        end
      end
      if hasActiveAbility?(:WHITESMOKE) && $fefieldeffect == 7
        @battle.pbDisplay(_INTL("{1}'s {2} surrounded the opponents in smoke!",pbThis,abilityName))
        eachNearOpposing do |b|
          b.pbLowerStatStage(:ACCURACY,1,self)
        end
      end
      if hasActiveAbility?(:SHACKLE)
        case $fefieldeffect
        when 6
          @battle.pbDisplay(_INTL("{1} shackled the opponents!",abilityName))
          eachNearOpposing do |b|
            b.pbLowerStatStage(:SPEED,1,self)
          end
        when 14
          @battle.pbDisplay(_INTL("{1} shackled the opponents!",abilityName))
          eachNearOpposing do |b|
            b.pbLowerStatStage(:ATTACK,1,self)
          end
        end
      end
      if hasActiveAbility?(:AURABREAK) && $fefieldeffect == 34
        eachNearOpposing do |b|
          b.pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,self)
        end
      end
      if hasActiveAbility?(:DAZZLING) && [3,6,31,48].include?($fefieldeffect)
        @battle.eachOtherSideBattler(@index) do |b|
          next if !b.pbCanAttract?(self,false)
          b.pbAttract(self)
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} fall in love!",pbThis,abilityName,foe.pbThis(true)))
        end
      end
      if hasActiveAbility?(:EMOTION)
        eachNearOpposing do |b|
          next if !b.pbCanConfuse?(self,false)
          b.pbConfuse(_INTL("{1}'s {2} made {3} become confused!",pbThis,abilityName,foe.pbThis(true)))
        end
      end
      if hasActiveAbility?(:MOLDBREAKER) && ![3,31].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} breaks the mold!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:PRESSURE) && ![20,48].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is exerting its pressure!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:SLOWSTART) && ![1,17,18,29].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        @effects[PBEffects::SlowStart] = 5
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} can't get it going!",pbThis))
        else
          @battle.pbDisplay(_INTL("{1} can't get it going because of its {2}!",pbThis,abilityName))
        end
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:TERAVOLT) && !($fefieldeffect == 8 && grounded?)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating a bursting aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:TURBOBLAZE) && ![22,39,46].include?($fefieldeffect) && 
         !([21,26].include?($fefieldeffect) && grounded?)
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is radiating a blazing aura!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:UNNERVE) && $fefieldeffect != 48
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!",pbOpposingTeam))
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:INTREPIDSWORD)
        if $fefieldeffect == 31
          pbRaiseStatStageByAbility(:ATTACK,2,self)
        else
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        end
      end
      if hasActiveAbility?(:DAUNTLESSSHIELD)
        if [14,31].include?($fefieldeffect)
          pbRaiseStatStageByAbility(:DEFENSE,2,self)
        else
          pbRaiseStatStageByAbility(:DEFENSE,1,self)
        end
      end
      if hasActiveAbility?(:SCREENCLEANER) && !([8,26].include?($fefieldeffect) && 
         grounded?)
        @battle.pbShowAbilitySplash(self)
        if pbOwnSide.effects[PBEffects::AuroraVeil]>0
          pbOwnSide.effects[PBEffects::AuroraVeil] = 0
          @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",pbTeam))
        end
        if pbOwnSide.effects[PBEffects::LightScreen]>0
          pbOwnSide.effects[PBEffects::LightScreen] = 0
          @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",pbTeam))
        end
        if pbOwnSide.effects[PBEffects::Reflect]>0
          pbOwnSide.effects[PBEffects::Reflect] = 0
          @battle.pbDisplay(_INTL("{1}'s Reflect wore off!",pbTeam))
        end
        if pbOpposingSide.effects[PBEffects::AuroraVeil]>0
          pbOpposingSide.effects[PBEffects::AuroraVeil] = 0
          @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",pbOpposingTeam))
        end
        if pbOpposingSide.effects[PBEffects::LightScreen]>0
          pbOpposingSide.effects[PBEffects::LightScreen] = 0
          @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",pbOpposingTeam))
        end
        if pbOwnSide.effects[PBEffects::Reflect]>0
          pbOpposingSide.effects[PBEffects::Reflect] = 0
          @battle.pbDisplay(_INTL("{1}'s Reflect wore off!",pbOpposingTeam))
        end
        if [30,44,46].include?($fefieldeffect)
          if pbOwnSide.effects[PBEffects::LuckyChant]>0
            pbOwnSide.effects[PBEffects::LuckyChant]=0 
            @battle.pbDisplay(_INTL("{1}'s Lucky Chant wore off!",pbTeam))
          end
          if pbOwnSide.effects[PBEffects::Mist]>0
            pbOwnSide.effects[PBEffects::Mist]=0 
            @battle.pbDisplay(_INTL("{1}'s Mist wore off!",pbTeam))
          end
          if pbOwnSide.effects[PBEffects::Safeguard]>0
            pbOwnSide.effects[PBEffects::Safeguard]=0 
            @battle.pbDisplay(_INTL("{1}'s Safeguard wore off!",pbTeam))
          end
          if pbOwnSide.effects[PBEffects::Spikes]>0
            pbOwnSide.effects[PBEffects::Spikes]=0 
            @battle.pbDisplay(_INTL("{1}'s Spikes disappeared!",pbTeam))
          end
          if pbOwnSide.effects[PBEffects::StealthRock]
            pbOwnSide.effects[PBEffects::StealthRock]=false
            @battle.pbDisplay(_INTL("{1}'s Stealth Rocks disappeared!",pbTeam))
          end
          if pbOwnSide.effects[PBEffects::StickyWeb]
            pbOwnSide.effects[PBEffects::StickyWeb]=false
            @battle.pbDisplay(_INTL("{1}'s Sticky Web disappeared!",pbTeam))
          end
          if pbOwnSide.effects[PBEffects::Tailwind]>0
            pbOwnSide.effects[PBEffects::Tailwind]=0 
            @battle.pbDisplay(_INTL("{1}'s Tailwind wore off!",pbTeam))
          end
          if pbOwnSide.effects[PBEffects::ToxicSpikes]>0
            pbOwnSide.effects[PBEffects::ToxicSpikes]=0 
            @battle.pbDisplay(_INTL("{1}'s Toxic Spikes disappeared!",pbTeam))
          end
          if pbOpposingSide.effects[PBEffects::LuckyChant]>0
            pbOpposingSide.effects[PBEffects::LuckyChant]=0
            @battle.pbDisplay(_INTL("{1}'s Lucky Chant wore off!",pbOpposingTeam))
          end
          if pbOpposingSide.effects[PBEffects::Mist]>0
            pbOpposingSide.effects[PBEffects::Mist]=0
            @battle.pbDisplay(_INTL("{1}'s Mist wore off!",pbOpposingTeam))
          end
          if pbOpposingSide.effects[PBEffects::Safeguard]>0
            pbOpposingSide.effects[PBEffects::Safeguard]=0
            @battle.pbDisplay(_INTL("{1}'s Safeguard wore off!",pbOpposingTeam))
          end
          if pbOpposingSide.effects[PBEffects::Spikes]>0
            pbOpposingSide.effects[PBEffects::Spikes]=0
            @battle.pbDisplay(_INTL("{1}'s Spikes disappeared!",pbOpposingTeam))
          end
          if pbOpposingSide.effects[PBEffects::StealthRock]
            pbOpposingSide.effects[PBEffects::StealthRock]=false
            @battle.pbDisplay(_INTL("{1}'s Stealth Rocks disappeared!",pbOpposingTeam))
          end
          if pbOpposingSide.effects[PBEffects::StickyWeb]
            pbOpposingSide.effects[PBEffects::StickyWeb]=false
            @battle.pbDisplay(_INTL("{1}'s Sticky Web disappeared!",pbOpposingTeam))
          end
          if pbOpposingSide.effects[PBEffects::Tailwind]>0
            pbOpposingSide.effects[PBEffects::Tailwind]=0
            @battle.pbDisplay(_INTL("{1}'s Tailwind wore off!",pbOpposingTeam))
          end
          if pbOpposingSide.effects[PBEffects::ToxicSpikes]>0
            pbOpposingSide.effects[PBEffects::ToxicSpikes]=0
            @battle.pbDisplay(_INTL("{1}'s Toxic Spikes disappeared!",pbOpposingTeam))
          end
        end
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:PASTELVEIL) && ![4,18].include?($fefieldeffect) && !([8,26].include?($fefieldeffect) &&
         grounded?)
        eachAlly do |b|
          next if b.status != :POISON
          @battle.pbShowAbilitySplash(self)
          b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} cured its {3}'s poison!",pbThis,abilityName,b.pbThis(true)))
          end
          @battle.pbHideAbilitySplash(self)
        end
      end
      if hasActiveAbility?(:CURIOUSMEDICINE) && $fefieldeffect != 29
        failed = true
        eachAlly do |b|
          b.pbCheckAndInflictRandomStatus(self) if $fefieldeffect == 19
          b.pbCureStatus if [31,42].include?($fefieldeffect)
          next if !b.hasAlteredStatStages?
          b.pbResetStatStages
          failed = false
        end
        if !failed
          @battle.pbShowAbilitySplash(self)
          @battle.pbDisplay(_INTL("{1}'s {2} eliminated all allies' stat changes!",pbThis,abilityName))
          @battle.pbHideAbilitySplash(self)
        end
      end
      if hasActiveAbility?(:CONFIDENCE) && ![37,38].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        eachAlly do |b|
          b.pbRaiseStatStageByCause([:ATTACK,:SPECIAL_ATTACK],1,self,abilityName)
        end
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:FRIGHTEN) && ![9,29,48].include?($fefieldeffect)
        @battle.pbShowAbilitySplash(self)
        eachNearOpposing do |b|
          if [4,32,38,39,40].include?($fefieldeffect)
            b.pbLowerStatStageEntryAbility(:SPEED,2,self)
          else
            b.pbLowerStatStageEntryAbility(:SPEED,1,self)
          end
          b.pbItemOnIntimidatedCheck
        end
        @battle.pbHideAbilitySplash(self)
      end
      if hasActiveAbility?(:SIMILARITY) && $fefieldeffect != 37 || hasActiveAbility?(:SYNCHRONIZE) &&
         $fefieldeffect == 6
        if $fefieldeffect == 5
          eachOwnSideBattler do |b|
            pbRaiseStatStageByAbility(b.highestStat,1,self)
          end
        elsif $fefieldeffect == 30
          @battle.eachBattler do |b|
            next if !sharesType?(b)
            pbRaiseStatStageByAbility(b.highestStat,2,self)
          end
        else
          eachOtherBattler do |b|
            next if !sharesType?(b)
            pbRaiseStatStageByAbility(b.highestStat,1,self)
          end
        end
      end
      if hasActiveAbility?(:SHACKLE)
        if $fefieldeffect == 6
          eachNearOpposing do |b|
            b.pbLowerStatStageByCause(:SPEED,1,self,abilityName)
          end
        elsif $fefieldeffect == 14
          eachNearOpposing do |b|
            b.pbLowerStatStageByCause(:ATTACK,1,self,abilityName)
          end
        end
      end
      if hasActiveAbility?(:SPYGEAR)
        shuffleSpyGear
      end
      if hasActiveAbility?(:ALPHABETIZATION)
        if checkAlphabetizationForm(1)
          pbRaiseCritRatio(3)
          @battle.pbDisplay(_INTL("{1}'s {2} (Bear) maximized its critical-hit ratio!",pbThis,abilityName))
        end
        if checkAlphabetizationForm(3)
          pbRaiseStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE],3,self,abilityName+" (Direct)")
          @effects[PBEffects::FollowMe] = 1
          eachAlly do |b|
            next if b.effects[PBEffects::FollowMe]<@effects[PBEffects::FollowMe]
            @effects[PBEffects::FollowMe] = b.effects[PBEffects::FollowMe]+1
          end
          @battle.pbDisplay(_INTL("{1} became the center of attention!",pbThis))
        end
        if checkAlphabetizationForm(7) && @battle.pbSideSize(@index) > 1
          @battle.pbDisplay(_INTL("{1}'s {2} (Help) boosts the damage of its allies!",pbThis,abilityName))   
        end
        if checkAlphabetizationForm(8)
          maxStat = 0
          eachBattler do |b|
            next if !opposes?(b) && b != self
            for s in [b.attack,b.defense,b.spatk,b.spdef,b.speed]
              if s>maxStat
                maxStat=s
              end
            end
          end
          @attack = maxStat
          @defense = maxStat
          @spatk = maxStat
          @spdef = maxStat
          @speed = maxStat
          @battle.pbDisplay(_INTL("{1}'s {2} (Increase) copied the best stat of its opponents!",pbThis,abilityName))
        end
        if checkAlphabetizationForm(11)
          worked=false
          eachNearOpposing do |b|
            if b.pbCanAttract(self,false,true)
              b.pbAttract(self)
              worked=true
            end
          end
          if worked
            @battle.pbDisplay(_INTL("{1}'s {2} (Laugh) infatuated the opposing team!",pbThis,abilityName))
          end
        end
        if checkAlphabetizationForm(14)
          copyBattler = pbDirectOpposing(true)
          if !copyBattler.fainted?
            @attack = 2 * copyBattler.attack
            @defense = 2 * copyBattler.defense
            @spatk = 2 * copyBattler.spatk
            @spdef = 2 * copyBattler.spdef
            @speed = 2 * copyBattler.speed
            @battle.pbDisplay(_INTL("{1}'s {2} (Observe) copied double the stats of {3}!",pbThis,abilityName,copyBattler.pbThis(true)))
          end
        end
        if checkAlphabetizationForm(21)
          pbRaiseStatStageByCause(:EVASION,12,self,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} (Vanish) maximized its Evasion!",pbThis,abilityName))
        end
        if checkAlphabetizationForm(24)
          pbRaiseStatStageByCause([:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],4,self,abilityName+" (Yield)")
        end
        if checkAlphabetizationForm(25)
          pbRaiseStatStageByCause(:SPEED,12,self,nil)
          pbRaiseCritRatio(3)
          @battle.pbDisplay(_INTL("{1}'s {2} (Zoom) maximized its Speed and critical-hit ratio!",pbThis,abilityName))
        end
      end
      if hasActiveAbility?(:ELECTRICFIELD) && !@effects[PBEffects::Ingrain] && !@effects[PBEffects::SmackDown] &&
         @effects[PBEffects::MagnetRise] == 0
        @effects[PBEffects::MagnetRise] = 5
        @battle.pbDisplay(_INTL("{1} levitated with electromagnetism!",pbThis))
      end
      case $fefieldeffect
      # Electric Terrain Entry
      when 1
        if hasActiveAbility?([:STATIC,:HUSTLE,:VITALSPIRIT,:MOTORDRIVE,:RATTLED,:TERAVOLT])
          pbRaiseStatStageByAbility(:SPEED,1,self)
        elsif hasActiveAbility?(:WATERBUBBLE) && grounded?
          pbInflictTypeScalingFixedDamage(:ELECTRIC,@totalhp/8,_INTL("{1} was zapped by the electricity!",pbThis))
        end
      # Grassy Terrain Entry
      when 2
        if hasActiveAbility?(:GRASSPELT)
          pbRaiseStatStageByAbility(:DEFENSE,1,self)
        end
      # Misty Terrain Entry
      when 3
        if hasActiveAbility?(:WATERCOMPACTION)
          pbRaiseStatStageByAbility(:DEFENSE,2,self)
        elsif hasActiveAbility?([:AROMAVEIL,:SWEETVEIL])
          pbRaiseStatStageByAbility([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,self)
        elsif hasActiveAbility?([:WATERBUBBLE,:LUMINOUSSCALES,:PASTELVEIL])
          pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
        elsif hasActiveAbility?(:STEAMENGINE)
          pbRaiseStatStageByAbility(:SPEED,6,self)
        end
        if hasActiveItem?(:FULLINCENSE)
          pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,nil,itemName)
        elsif hasActiveItem?(:LAXINCENSE)
          pbRaiseStatStageByCause(:EVASION,1,nil,itemName)
        elsif hasActiveItem?(:LUCKINCENSE)
          pbRaiseCritRatio(1,nil,_INTL("{1}'s {2} boosted its critical-hit ratio!",pbThis,itemName))
        elsif hasActiveItem?(:ODDINCENSE)
          pbRaiseStatStageByCause(@battle.generateRandomStat,1,nil,itemName)
        elsif hasActiveItem?(:PUREINCENSE)
          pbRaiseStatStageByCause(:ACCURACY,1,nil,itemName)
        elsif hasActiveItem?(:ROCKINCENSE)
          pbRaiseStatStageByCause(:DEFENSE,1,nil,itemName)
        elsif hasActiveItem?(:ROSEINCENSE)
          pbRaiseStatStageByCause(:ATTACK,1,nil,itemName)
        elsif hasActiveItem?(:SEAINCENSE)
          pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,itemName)
        elsif hasActiveItem?(:WAVEINCENSE)
          pbRaiseStatStageByCause(:SPEED,1,nil,itemName)
        end
      # Dark Crystal Cavern Entry
      when 4
        if hasActiveAbility?([:INVISIBLEWALL,:MIRRORARMOR])
          pbRaiseStatStageByAbility(:EVASION,1,self)
        elsif hasActiveAbility?(:GRIMNEIGH)
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        end
      # Chess Board Entry
      when 5
        if hasActiveAbility?(:BATTLEARMOR)
          if pbRaiseStatStageByCause(:SPEED,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} entered like a knight ready for battle, raising its Speed!",pbThis))
          end
        elsif hasActiveAbility?([:OWNTEMPO,:LEADERSHIP])
          pbRaiseStatStageByAbility(:SPEED,1,self)
        elsif hasActiveAbility?(:NOGUARD)
          pbLowerStatStageByAbility([:DEFENSE,:SPECIAL_DEFENSE],1,self)
        elsif hasActiveAbility?(:STALL)
          @battle.pbDisplay(_INTL("{1} employs a stalling strategy!",pbThis))
          pbRaiseStatStage([:DEFENSE,:SPECIAL_DEFENSE],1,nil,true)
        elsif hasActiveAbility?(:RUNAWAY)
          @battle.pbDisplay(_INTL("{1} was ridiculed for running away like a sore loser!",pbThis))
          pbLowerStatStage(:ATTACK,1,nil,true)
          pbRaiseStatStage(:SPEED,1,nil,true)
        elsif hasActiveAbility?([:SCRAPPY,:RECKLESS,:GORILLATACTICS])
          if pbLowerStatStageByCause(:ACCURACY,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s reckless habits decreased its Accuracy!",pbThis))
          end
        elsif hasActiveAbility?(:CONFIDENCE)
          if pbLowerStatStageByCause(:ACCURACY,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s overconfidence decreased its Accuracy!",pbThis))
          end
        elsif hasActiveAbility?([:DEFIANT,:STAKEOUT,:OVERLORD])
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        elsif hasActiveAbility?(:WEAKARMOR)
          pbLowerStatStageByAbility(:DEFENSE,1,self)
        elsif hasActiveAbility?([:COMPETITIVE,:NEUROFORCE])
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        elsif hasActiveAbility?(:DISGUISE)
          if pbRaiseStatStageByCause(:EVASION,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} distracts the opposing team with a decoy, raising its Evasion!",pbThis))
          end
        elsif hasActiveAbility?(:CAUTIOUS)
          @battle.pbDisplay(_INTL("{1} employs a cautious strategy!",pbThis))
          pbRaiseStatStage(:DEFENSE,1,nil,true)
          pbLowerStatStage(:ATTACK,1,nil,true)
        elsif hasActiveAbility?([:CONTRARY,:DEFIANT])
          if $fecounter < 6 # White
            $fecounter+=6
            fieldColor = "Black"
          else # Black
            $fecounter-=6
            fieldColor = "White"
          end
          @battle.changeFieldBG
          @battle.pbDisplay(_INTL("{1}'s {2} changed the field to {3}'s turn!",pbThis,abilityName,fieldColor))
        elsif hasActiveAbility?(:QUEENLYMAJESTY)
          if $fecounter < 6 # White
            $fecounter=2 # Queen
          else # Black
            $fecounter=8 # Queen
          end
          @battle.changeFieldBG
          @battle.pbDisplay(_INTL("{1}'s {2} changed the field to the Queen's turn!",pbThis,abilityName,fieldColor))
        end
        if hasActiveItem?(:FLOATSTONE)
          pbRaiseStatStageByCause(:SPEED,1,nil,itemName)
        end
      # Performance Stage Entry
      when 6
        if hasActiveAbility?([:GUTS,:CONFIDENCE,:MOTIVATION])
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} stands with confidence in front of the crowd, raising its Sp. Atk!",pbThis))
          end
        elsif hasActiveAbility?([:VITALSPIRIT,:QUIP,:DANCER])
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} pumps up the crowd, raising its Sp. Atk!",pbThis))
          end
        elsif hasActiveAbility?([:VICTORYSTAR,:MAGICIAN,:LEADERSHIP,:MAGICWAND,:JUGGLING,
           :PERFORMER])
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} is the star of the show, raising its Sp. Atk!",pbThis))
          end
        elsif hasActiveAbility?(:SIMPLE)
          if pbLowerStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} bores the crowd, harshly lowering its Sp. Atk.",pbThis))
          end
        elsif hasActiveAbility?([:SKILLLINK,:CAUTIOUS,:LIBERO,:BALLFETCH,:DUALWIELD,:FLAMESPIRAL,
              :SPEEDSLICE])
          if pbRaiseStatStageByCause(:ACCURACY,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} exemplifies its skill and precision, raising its Accuracy!",pbThis,abilityName))
          end
        elsif hasActiveAbility?([:KLUTZ,:RECKLESS])
          if pbLowerStatStageByCause(:ACCURACY,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} makes it unprepared for the show, decreasing its Accuracy!",pbThis,abilityName))
          end
        elsif hasActiveAbility?(:WIMPOUT)
          if pbLowerStatStageByCause(:SPEED,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s stage fright lowered its Speed.",pbThis))
          end
        end
      # Volcanic Field Entry
      when 7
        if hasActiveAbility?(:TURBOBLAZE)
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        elsif hasActiveAbility?(:ICEFACE) && self.form!=1
          pbChangeForm(1,_INTL("The heat melted {1}'s face!",pbThis(true)))
        elsif hasActiveAbility?(:STEAMENGINE)
          pbRaiseStatStageByAbility(:SPEED,6,self)
        end
        if hasActiveItem?(:FLAMEORB)
          pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,itemName)
        end
      # Rainbow Field Entry
      when 9
        if hasActiveAbility?([:MAGICGUARD,:DIVINE])
          if pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("The majestical aura boosted {1}'s Sp. Def!",pbThis(true)))
          end
        elsif hasActiveAbility?([:LUMINOUSSCALES,:MIRRORARMOR])
          @battle.pbDisplay(_INTL("{1}'s {2} flared up in the luminescence!",pbThis,abilityName))
          pbRaiseStatStage([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,nil,true)
        end
      # Corrosive Mist Field Entry
      when 11
        if hasActiveAbility?(:WATERCOMPACTION)
          pbRaiseStatStageByAbility(:DEFENSE,2,self)
        end
        if hasActiveItem?(:TOXICORB)
          pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,nil,itemName)
        end
      # Desert Field Entry
      when 12
        if hasActiveAbility?(:ICEFACE) && self.form!=1
          pbChangeForm(1,_INTL("The heat melted {1}'s face!",pbThis(true)))
        elsif hasActiveAbility?(:SANDSHIELD) && grounded?
          if pbRaiseStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE],1,nil,nil)
            @battle.pbDisplay(_INTL("The sand boosted {1}'s Defense and Sp. Def!",pbThis(true)))
          end
        elsif hasActiveAbility?(:BEARDEDMAGNETISM) && grounded?
          if pbRaiseStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} attracted sand grains, boosting its Defense!",pbThis,abilityName))
          end
        end
      # Icy Cave Entry
      when 13
        if hasActiveAbility?(:DANCER)
          if pbRaiseStatStageByCause(:SPEED,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} dances with elegance across the ice, boosting its Speed!",pbThis))
          end
          @battle.pbDisplay(_INTL("{1} boosted its Critical-hit rate!",pbThis))
        end
      # Rocky Field Entry
      when 14
        if pbOpposingSide.effects[PBEffects::Spikes]<3
          if hasActiveAbility?(:IRONBARBS)
            @battle.pbAnimation(:SPIKES,self,nil,1)
            pbOpposingSide.effects[PBEffects::Spikes]+=1
            @battle.pbDisplay(_INTL("Spikes were scattered all around {1}'s feet!",pbOpposingTeam(true)))
          end
        end
      # Forest Field Entry
      when 15
        if hasActiveAbility?(:RUNAWAY)
          if pbRaiseStatStageByCause(:EVASION,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} ran and hid in the trees, boosting its Evasion!",pbThis))
          end
        elsif hasActiveAbility?(:HYPERCUTTER)
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        elsif hasActiveAbility?(:TOUGHBARK)
          pbRaiseStatStageByAbility(:DEFENSE,2,self)
        elsif hasActiveAbility?(:GORILLATACTICS)
          pbRaiseStatStageByAbility(:SPEED,1,self)
        elsif hasActiveAbility?(:SEASONALHEART)
          case @form
          when 0 # Spring
            pbRaiseStatStageByAbility(:ATTACK,1,self)
          when 1 # Summer
            pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
          when 2 # Autumn
            pbRaiseStatStageByAbility(:SPEED,1,self)
          when 3 # Winter
            pbRaiseStatStageByAbility(:DEFENSE,1,self)
          end
        end
      # Volcanic Top Field Entry
      when 16
        if hasActiveAbility?(:ICEFACE) && self.form!=1
          pbChangeForm(1,_INTL("The heat melted {1}'s face!",pbThis(true)))
        end
      # Factory Field Entry
      when 17
        if hasActiveAbility?([:MAGNETPULL,:BEARDEDMAGNETISM])
          @battle.pbDisplay(_INTL("The magnetic field resonated with {1}'s {2}!",pbThis(true),abilityName))
          pbRaiseStatStage([:ATTACK,:SPECIAL_ATTACK],1,nil,true)
        elsif hasActiveAbility?(:KEENEYE)
          pbRaiseStatStageByAbility(:ACCURACY,1,self)
        elsif hasActiveAbility?(:DUALWIELD)
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        end
      # Short-Circuit Field Entry
      when 18
        if hasActiveAbility?(:TERAVOLT)
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        end
        if hasActiveItem?(:ABSORBBULB)
          @battle.pbCommonAnimation("UseItem",self)
          pbRaiseStatStageByCause(:ATTACK,1,self,itemName)
          pbHeldItemTriggered(@item)
        end
      # Wasteland Entry
      when 19
        if hasActiveAbility?([:MAGICIAN,:MAGICWAND])
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("The infused magical energy boosted {1}'s Sp. Atk!",pbThis(true)))
          end
        elsif hasActiveAbility?(:PROTEAN)
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        end
        if hasActiveItem?(:TOXICORB)
          pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,itemName)
        end
      # Ashen Beach Entry
      when 20
        if hasActiveAbility?(:EARLYBIRD)
          @battle.pbDisplay(_INTL("{1} is up bright and early for training!",pbThis))
          pbRaiseStatStage([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,nil,true)
        elsif hasActiveAbility?(:ANTICIPATION)
          pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
        elsif hasActiveAbility?(:BEARDEDMAGNETISM) && grounded?
          if pbRaiseStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} attracted sand grains, boosting its Defense!",pbThis,abilityName))
          end
        end
      # Water Surface Entry
      when 21
        if grounded?
          if hasActiveAbility?(:STEAMENGINE)
            pbRaiseStatStageByAbility(:SPEED,6,self)
          elsif hasActiveAbility?(:SPONGE)
            pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
          end
          if hasActiveItem?(:ABSORBBULB)
            @battle.pbCommonAnimation("UseItem",self)
            pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,self,itemName)
            pbHeldItemTriggered(@item)
          end
        end
      # Underwater Entry
      when 22
        if hasActiveAbility?(:SHELLARMOR)
          if pbRaiseStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("The shells on the seafloor boosted {1}'s Defense!",pbThis(true)))
          end
        elsif hasActiveAbility?(:SPONGE)
          pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,2,self)
        end
        if hasActiveItem?(:ABSORBBULB)
          @battle.pbCommonAnimation("UseItem",self)
          pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,self,itemName)
          pbHeldItemTriggered(@item)
        end
      # Glitch Field Entry
      when 24
        if hasActiveAbility?([:SLOWSTART,:BATTERY])
          pbRaiseStatStageByAbility(@battle.generateRandomStat,2,self)
        end
      # Crystal Cavern Entry
      when 25
        if hasActiveAbility?(:MAGICGUARD)
          if pbRaiseStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("The sparkling crystals boosted {1}'s Defense!",pbThis(true)))
          end
        elsif hasActiveAbility?(:MAGICBOUNCE)
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} reflected the light throughout the cavern, raising its Sp. Atk!",pbThis,abilityName))
          end
        elsif hasActiveAbility?(:PROTEAN)
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        elsif hasActiveAbility?(:QUEENLYMAJESTY)
          @battle.pbDisplay(_INTL("{1} couldn't help but gather a bunch of gems!",pbThis))
          pbRaiseStatStage(:SPECIAL_DEFENSE,2,nil,true)
          pbLowerStatStage(:SPEED,1,nil,true)
        elsif hasActiveAbility?(:LUMINOUSSCALES)
          if pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} shined alongside the crystals, raising its Sp. Def!",pbThis,abilityName))
          end
        elsif hasActiveAbility?(:PASTELVEIL)
          pbRaiseStatStageByAbility(:EVASION,1,self)
        end
      # Murkwater Surface
      when 26
        if hasActiveAbility?(:CORROSION)
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("The dirty water boosted {1}'s Sp. Atk!",pbThis(true)))
          end
        end
        if grounded?
          if hasActiveAbility?(:SPONGE)
            pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
            if pbCanPoison?(nil,false)
              pbPoison
            end
          end
          if hasActiveItem?(:ABSORBBULB)
            @battle.pbCommonAnimation("UseItem",self)
            pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,self,itemName)
            if pbCanPoison?(nil,false)
              pbPoison
            end
            pbHeldItemTriggered(@item)
          end
        end
      # Mountain Entry
      when 27
        if hasActiveAbility?(:AIRLOCK) && @battle.field.weather != :None
          @battle.field.weather = :None
          @battle.field.weatherDuration = 0
          @battle.pbDisplay(_INTL("{1}'s {2} removed all weather effects!",pbThis,abilityName))
        elsif hasActiveAbility?(:STAMINA)
          if pbRaiseStatStageByCause(:SPEED,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} climbs the mountain with ease, raising its Speed!",pbThis))
          end
        end
      # Snowy Mountain Entry
      when 28
        if hasActiveAbility?(:AIRLOCK) && @battle.field.weather != :None
          @battle.field.weather = :None
          @battle.field.weatherDuration = 0
          @battle.pbDisplay(_INTL("{1}'s {2} removed all weather effects!",pbThis,abilityName))
        elsif hasActiveAbility?(:STAMINA)
          if pbRaiseStatStageByCause(:SPEED,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} climbs the mountain with ease, raising its Speed!",pbThis))
          end
        elsif hasActiveAbility?(:ICESCALES)
          pbRaiseStatStageByAbility([:DEFENSE,:SPECIAL_DEFENSE],1,self)
        end
      # Holy Field Entry
      when 29 # Remember to separate ones with same effects
        if hasActiveAbility?(:FOREWARN)
          pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
        end
        if hasActiveAbility?(:TELEPATHY)
          pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
        end
        if hasActiveAbility?(:SOULHEART)
          pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
        end
        if hasActiveAbility?(:IDEALISM)
          pbRaiseStatStageByAbility([:ATTACK,:SPECIAL_DEFENSE],1,self)
        end
        if hasActiveAbility?(:UNAWARE) && pbCanParalyze?(self,false)
          pbParalyze
          @battle.pbDisplay(_INTL("{1} was paralyzed for not acknowledging the holy presence!",pbThis))
        end
        if hasActiveAbility?(:LUMINOUSSCALES)
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        end
        if hasActiveAbility?(:DIVINE)
          pbRaiseStatStageByAbility([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,self)
        end
        if hasActiveAbility?(:ATTENTIVE)
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} follows the prayers closely, raising its Sp. Atk!",pbThis))
          end
        end
        if hasActiveAbility?(:TRUTHSEEKER)
          if pbRaiseStatStageByCause([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,nil,nil)
            @battle.pbDisplay(_INTL("{1} seeks the truth through prayer, raising its Sp. Atk and Sp. Def!",pbThis))
          end
        end
        if hasActiveAbility?(:LEADERSHIP)
          if pbRaiseStatStageByCause(:SPEED,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} leads the prayer confidently, raising its Speed!",pbThis))
          end
        end
      # Mirror Arena Entry
      when 30
        if hasActiveAbility?([:SNOWCLOAK,:SANDVEIL,:MAGICBOUNCE,:COLORCHANGE,:BATTLEARMOR,
                              :CLEARBODY,:ILLUSION,:WONDERSKIN,:DISGUISE,:FULLMETALBODY,
                              :PRISMARMOR,:INVISIBLEWALL,:LUMINOUSSCALES,:ICESCALES,
                              :ETERNALLIGHT,:SHIMMERINGHAZE])
          pbRaiseStatStageByCause(:EVASION,1,nil,"Ability")
        elsif hasActiveAbility?(:MAGNETPULL)
          @battle.pbDisplay(_INTL("The metallic surroundings discombobulated {1}!",pbThis(true)))
          if pbCanConfuse?(nil,true)
            pbConfuse
            @battle.pbDisplay(_INTL("{1} became confused.",pbThis,abilityName))
          end
          pbRaiseStatStage(:EVASION,1,nil,true)
        elsif hasActiveAbility?([:COMPOUNDEYES,:INFILTRATOR,:ATTENTIVE])
          pbRaiseStatStageByAbility(:ACCURACY,1,self)
        elsif hasActiveAbility?(:TRUTHSEEKER)
          if pbRaiseStatStageByCause(:ACCURACY,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} seeks the one true image, boosting its Accuracy!",pbThis))
          end
        elsif hasActiveAbility?([:TINTEDLENS,:TELEPATHY])
          pbRaiseStatStageByAbility(:ACCURACY,2,self)
        elsif hasActiveAbility?(:THICKFAT)
          @battle.pbDisplay(_INTL("The mirrors made {1} self-conscious due to its obesity!",pbThis(true)))
          pbLowerStatStage([:ATTACK,:SPECIAL_ATTACK],1,nil,true)
        elsif hasActiveAbility?([:HEAVYMETAL,:MIRRORARMOR])
          @battle.pbDisplay(_INTL("{1}'s {2} was reinforced by the mirrors!",pbThis,abilityName))
          pbRaiseStatStage([:DEFENSE,:SPECIAL_DEFENSE,:EVASION],1,nil,true)
        elsif hasActiveAbility?(:LIGHTMETAL)
          @battle.pbDisplay(_INTL("{1}'s {2} was reflected by the mirrors!",pbThis,abilityName))
          pbRaiseStatStage([:SPEED,:EVASION],1,nil,true)
        elsif hasActiveAbility?([:DAZZLING,:QUEENLYMAJESTY,:CONFIDENCE])
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} stood out even more in the mirrors, boosting its Sp. Atk!",pbThis))
          end
        elsif hasActiveAbility?(:STEELYSPIRIT)
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        end
        if hasActiveItem?([:BRIGHTPOWDER,:LAXINCENSE])
          pbRaiseStatStageByCause(:EVASION,1,nil,"Item")
        end
      # Fairy Tale Field Entry
      when 31
        if hasActiveAbility?([:BATTLEARMOR,:SHELLARMOR])
          if pbRaiseStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s shining armor boosted its Defense!",pbThis))
          end
        elsif hasActiveAbility?(:POWEROFALCHEMY)
          @battle.pbDisplay(_INTL("{1} brewed a magical potion!",pbThis))
          pbRaiseStatStage([:DEFENSE,:SPECIAL_DEFENSE],1,nil,true)
        elsif hasActiveAbility?([:MAGICGUARD,:MAGICBOUNCE])
          if pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s magical power boosted its Sp. Def!",pbThis))
          end
        elsif hasActiveAbility?(:SWEETVEIL)
          pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
        elsif hasActiveAbility?([:MAGICIAN,:DIVINE,:MAGICWAND,:MYSTICALGEM])
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s magical power boosted its Sp. Atk!",pbThis))
          end
        elsif hasActiveAbility?([:HYPERCUTTER,:RIVALRY,:JUSTIFIED,:DUALWIELD])
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        elsif hasActiveAbility?(:ANTICIPATION)
          if pbRaiseStatStageByCause(:SPEED,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} anticipates the ending to this tale, raising its Speed!",pbThis))
          end
        elsif hasActiveAbility?(:VANGUARD)
          if pbRaiseStatStageByCause(:SPEED,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} pushes itself to the front, raising its Speed!",pbThis))
          end
        elsif hasActiveAbility?([:CONFIDENCE,:MOTIVATION,:LEADERSHIP,:REGALITY])
          @battle.pbDisplay(_INTL("{1} stands proudly as the hero in this tale!",pbThis))
          pbRaiseStatStage([:SPECIAL_ATTACK,:SPEED],1,nil,true)
        elsif hasActiveAbility?(:RUNAWAY)
          agender=@gender
          increment=0
          for b in @battle.battlers
            next if b == self || b.fainted?
            bgender=b.gender
            increment+=1 if !(agender == 2 || bgender == 2 || agender == bgender)
          end
          if increment>0
            if increment == 1
              @battle.pbDisplay(_INTL("{1} ran away with its true love!",pbThis))
            else
              @battle.pbDisplay(_INTL("{1} ran away with its true lovers!",pbThis))
            end
            pbRaiseStatStage([:ATTACK,:SPECIAL_ATTACK],increment,nil,true)
          end
        end
      # Dragon's Den Entry
      when 32
        if hasActiveAbility?(:MAGMAARMOR)
          pbRaiseStatStageByAbility([:DEFENSE,:SPECIAL_DEFENSE],1,self)
        elsif hasActiveAbility?([:BATTLEARMOR,:SHELLARMOR])
          if pbRaiseStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} came prepared with hefty armor, raising its Defense!",pbThis))
          end
        elsif hasActiveAbility?(:CAUTIOUS)
          if pbRaiseStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} approaches with caution, raising its Sp. Atk!",pbThis))
          end
        elsif hasActiveAbility?(:WEAKARMOR)
          pbLowerStatStageByAbility(:DEFENSE,1,self)
        elsif hasActiveAbility?([:DEFIANT,:STRONGWILL,:PREDATION])
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        elsif hasActiveAbility?([:COMPETITIVE,:CONFIDENCE])
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        elsif hasActiveAbility?(:TACTICS)
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} came with a battle plan, raising its Sp. Atk!",pbThis))
          end
        elsif hasActiveAbility?(:STAMINA) && @hp > 1
          @effects[PBEffects::Endure] = true
          @battle.pbDisplay(_INTL("{1}'s {2} prepares it to withstand any attack it faces this turn!",pbThis,abilityName))
        end
      # Flower Garden Field Entry
      when 33
        if hasActiveAbility?([:FLOWERGIFT,:FLOWERVEIL,:DROUGHT,:DRIZZLE,:GRASSPELT,
           :DRENCH,:RIPEN,:GRASSYSURGE])
          if @battle.changeFlowerGardenStage(1,false)
            @battle.pbDisplay(_INTL("{1}'s {2} grew the garden by 1 stage!",pbThis,abilityName))
          end
        elsif hasActiveAbility?([:BLIGHT,:CONTAMINATE])
          if @battle.changeFlowerGardenStage(-1,false)
            @battle.pbDisplay(_INTL("{1}'s {2} caused harm to the garden, cutting its stage by 1!",pbThis,abilityName))
          end
        end
      # Starlight Arena Entry
      when 34
        if hasActiveAbility?([:ILLUMINATE,:LUMINOUSSCALES,:MIRRORARMOR])
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,2,nil,nil)
            @battle.pbDisplay(_INTL("{1} flared up with starlight, sharply boosting its Sp. Atk!",pbThis))
          end
        elsif hasActiveAbility?(:SUNDEVOURER)
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        elsif hasActiveAbility?(:MOONCALLER)
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        end
        if shiny?
          s=@battle.generateRandomStat(false)
          if pbRaiseStatStageByCause(s,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} shined bright in the starlight, boosting its {2}!",pbThis,GameData::Stat.get(s).name))
          end
        end
        case @pokemon.nature_id
        when :ADAMANT,:HARDY
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Aries) boosts its damage from physical moves!",pbThis))
        when :BOLD,:DOCILE
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Taurus) boosts its Defense!",pbThis))
        when :HASTY,:LAX
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Gemini) divides its damaging attacks into two!",pbThis))
        when :CALM,:CAREFUL
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Cancer) boosts its Sp. Def!",pbThis))
        when :BRAVE,:RASH
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Leo) prepares it to boost its highest stat when knocking out a Pokémon!",pbThis))
        when :MODEST,:GENTLE
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Virgo) boosts its damage from special moves!",pbThis))
        when :MILD,:BASHFUL
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Libra) protects it from stat reduction!",pbThis))
        when :NAUGHTY,:SASSY
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Scorpio) prepares it to inflict Heal Block on its targets!",pbThis))
        when :JOLLY,:QUIRKY
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Sagittarius) boosts its critical hit ratio!",pbThis))
        when :RELAXED,:SERIOUS
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Capricorn) prepares it to raise its Defense or Sp. Def!",pbThis))
        when :LONELY,:QUIET
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Aquarius) prepares it to raise its Attack or Sp. Atk!",pbThis))
        when :TIMID,:NAIVE
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Pisces) prepares it to recover damage dealt!",pbThis))
        when :IMPISH
          @battle.pbDisplay(_INTL("{1}'s astrological sign (Ophiuchus) prepares it to curse its targets!",pbThis))
        end
      # Ultra Space Entry
      when 35
        if hasActiveAbility?(:AIRLOCK)
          pbRaiseStatStageByAbility(:SPEED,1,self)
        elsif hasActiveAbility?(:MOLDBREAKER)
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} leads it as a pioneer in this new space, raising its Sp. Atk!",pbThis,abilityName))
          end
        end
      # Inverse Field Entry
      when 36
        if hasActiveAbility?(:DEFIANT)
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        end
      # Psychic Terrain Entry
      when 37
        if hasActiveAbility?([:ANTICIPATION,:FOREWARN])
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,self)
        elsif hasActiveAbility?(:NEUROFORCE)
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        elsif hasActiveAbility?(:INVISIBLEWALL)
          if pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("The psychic energy resonated with {1}'s {2}, raising its Sp. Def!",pbThis,abilityName))
          end
        end
      # Dimensional Field Entry
      when 38
        if hasActiveAbility?(:RATTLED)
          pbRaiseStatStageByAbility(:SPEED,1,self)
        elsif hasActiveAbility?(:AIRLOCK) && @battle.field.weather != :None
          @battle.field.weather = :None
          @battle.field.weatherDuration = 0
          @battle.pbDisplay(_INTL("{1}'s {2} removed all weather effects!",pbThis,abilityName))
        end
      # Frozen Dimensional Field Entry
      when 39
        if hasActiveAbility?(:RATTLED)
          pbRaiseStatStageByCause(:SPEED,1,nil)
        elsif hasActiveAbility?([:DIVINE,:CHILLINGNEIGH])
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        end
      # Haunted Field Entry
      when 40
        if hasActiveAbility?(:RATTLED)
          pbRaiseStatStageByAbility(:SPEED,1,self)
        elsif hasActiveAbility?(:FOREWARN)
          pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
        elsif hasActiveAbility?([:MAGICIAN,:REFORM])
          if pbRaiseStatStageByCause(:EVASION,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} disappeared into thin air, raising its Evasion!",pbThis))
          end
        elsif hasActiveAbility?(:SCARECROW)
          eachNearOpposing do |b|
            b.effects[PBEffects::HauntedScared] = @index
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} scared of it!",pbThis,abilityName,b.pbThis(true)))
          end
        end
      # Bewitched Woods Entry
      when 42
        if hasActiveAbility?(:RUNAWAY)
          if pbRaiseStatStageByCause(:EVASION,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} ran and hid in the trees, boosting its Evasion!",pbThis))
          end
        elsif hasActiveAbility?([:INVISIBLEWALL,:LUMINOUSSCALES,:PASTELVEIL,:SPYGEAR])
          pbRaiseStatStageByAbility(:EVASION,1,self)
        elsif hasActiveAbility?(:MAGICGUARD)
          if pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("The magical surroundings boosted {1}'s Sp. Def!",pbThis(true)))
          end
        elsif hasActiveAbility?(:MAGICIAN)
          if pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("The magical surroundings boosted {1}'s Sp. Atk!",pbThis(true)))
          end
        elsif hasActiveAbility?(:POWEROFALCHEMY)
          pbRaiseStatStageByAbility([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,self)
        elsif hasActiveAbility?(:CAUTIOUS)
          @battle.pbDisplay(_INTL("{1} treads with extreme caution in the forest!",pbThis))
          pbRaiseStatStage(:DEFENSE,2,nil,true)
          pbLowerStatStage(:SPEED,1,nil,true)
        elsif hasActiveAbility?(:RIPEN)
          pbRaiseStatStageByAbility(@battle.generateRandomStat,2,self)
        elsif hasActiveAbility?([:CURSEDBODY,:CURIOUSMEDICINE,:HEALER,:MAGICBOUNCE,:MAGICGUARD,
              :MAGICIAN,:PERISHBODY,:PIXILATE,:DARKAURA,:ANIMATE,:FAIRYAURA,:POWEROFALCHEMY,
              :WANDERINGSPIRIT,:NECROMANCY,:HYPNOTICAURA,:DEATHWALTZ,:MAGICWAND,:MYSTICALGEM,
              :ILLUSION,:VOODOO]) && canBewitchedMark?
          @effects[PBEffects::BewitchedMark] = true
          @battle.pbDisplay(_INTL("{1}'s ability got it accused of witchcraft!",pbThis))
        elsif hasActiveAbility?(:SCARECROW)
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        end
      # Sky Field Entry
      when 43
        if hasActiveAbility?(:BIGPECKS)
          pbRaiseStatStageByAbility([:ATTACK,:DEFENSE],1,self)
        elsif hasActiveAbility?([:LEVITATE,:PROPELLERTAIL])
          pbRaiseStatStageByAbility(:SPEED,1,self)
        elsif hasActiveAbility?([:CLOUDNINE,:AIRLOCK]) && @battle.field.weather != :None
          @battle.field.weather = :None
          @battle.field.weatherDuration = 0
          @battle.pbDisplay(_INTL("{1}'s {2} removed all weather effects!",pbThis,abilityName))
        end
        if hasActiveItem?(:FLOATSTONE)
          pbRaiseStatStageByCause(:SPEED,1,nil,itemName)
        end
      # Indoors Entry
      when 44
        if hasActiveAbility?(:RUNAWAY)
          if pbRaiseStatStageByCause(:EVASION,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} ran and hid behind some furniture, boosting its Evasion!",pbThis))
          end
        end
      # Boxing Ring Entry
      when 45
        if hasActiveAbility?([:KEENEYE,:PERFORMER])
          pbRaiseStatStageByAbility([:ACCURACY,:EVASION],1,self)
        elsif hasActiveAbility?([:HUSTLE])
          pbRaiseStatStageByAbility(:SPEED,1,self)
        elsif hasActiveAbility?(:NOGUARD)
          pbLowerStatStageByAbility(:DEFENSE,1,self)
        elsif hasActiveAbility?([:ANTICIPATION,:ATTENTIVE])
          if pbRaiseStatStageByCause(:EVASION,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} anticipates the opponent's next move, boosting its Evasion!",pbThis))
          end
        elsif hasActiveAbility?([:SCRAPPY,:UNNERVE,:CONFIDENCE,:STALWART,:PREDATION])
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        elsif hasActiveAbility?(:WIMPOUT)
          if pbLowerStatStageByCause(:ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} cowers in fear, lowering its Attack!",pbThis))
          end
        elsif hasActiveAbility?(:CAUTIOUS)
          if pbLowerStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} holds back some of its power, lowering its Attack!",pbThis))
          end
        end
      # Subzero Field Entry
      when 46
        if hasActiveAbility?(:DANCER)
          if pbRaiseStatStageByCause(:SPEED,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} dances with elegance across the ice, boosting its Speed!",pbThis))
          end
          @battle.pbDisplay(_INTL("{1} boosted its Critical-hit rate!",pbThis))
        elsif hasActiveAbility?(:ICESCALES)
          pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,self)
        end
      # Jungle Entry
      when 47
        if hasActiveAbility?(:COLORCHANGE)
          pbRaiseStatStageByAbility(:EVASION,1,self)
        elsif hasActiveAbility?(:HYPERCUTTER)
          pbRaiseStatStageByAbility(:ATTACK,1,self)
        elsif hasActiveAbility?([:OVERLORD,:JUNGLETOTEM,:GORILLATACTICS])
          if pbLowerStatStageByCause(:ATTACK,1,nil,nil)
            @battle.pbDisplay(_INTL("{1} asserts itself as the king of the jungle, boosting its Attack!",pbThis))
          end
        end
      # Beach Entry
      when 48
        if hasActiveAbility?(:CLOUDNINE) && @battle.field.weather != :None
          @battle.field.weather = :None
          @battle.field.weatherDuration = 0
          @battle.pbDisplay(_INTL("{1}'s {2} removed all weather effects!",pbThis,abilityName))
        elsif hasActiveAbility?(:SHELLARMOR)
          if pbRaiseStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("The shells on the beach boosted {1}'s Defense!",pbThis(true)))
          end
        elsif hasActiveAbility?(:SLOWSTART)
          @battle.pbDisplay(_INTL("{1} relaxes and recuperates!",pbThis))
          pbRaiseStatStage([:DEFENSE,:SPECIAL_DEFENSE],1,nil,true)
        elsif hasActiveAbility?([:LIBERO,:BALLFETCH])
          pbRaiseStatStageByAbility(:SPEED,1,self)
        elsif hasActiveAbility?(:TRIAGE)
          eachAlly do |b|
            if b.pbRecoverHP((b.totalhp/4).round) > 0
              @battle.pbDisplay(_INTL("{1} healed some of {2}'s HP!",abilityName,b.pbThis(true)))
            end
          end
        elsif hasActiveAbility?(:BEARDEDMAGNETISM) && grounded?
          if pbRaiseStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} attracted sand grains, boosting its Defense!",pbThis,abilityName))
          end
        end
      # Xeric Shrubland Entry
      when 49
        if hasActiveAbility?(:ICEFACE) && self.form!=1
          pbChangeForm(1,_INTL("The heat melted {1}'s face!",pbThis(true)))
        elsif hasActiveAbility?(:BEARDEDMAGNETISM) && grounded?
          if pbRaiseStatStageByCause(:DEFENSE,1,nil,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} attracted sand grains, boosting its Defense!",pbThis,abilityName))
          end
        end
      end
    end
  
    #=============================================================================
    # Ability curing
    #=============================================================================
    # Cures status conditions, confusion and infatuation.
    def pbAbilityStatusCureCheck
      if abilityActive?
        #BattleHandlers.triggerStatusCureAbility(self.ability,self)
        if @status == :POISON && hasActiveAbility?([:IMMUNITY,:PASTELVEIL])
          @battle.pbShowAbilitySplash(self)
          pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        elsif @status == :SLEEP && (hasActiveAbility?(:INSOMNIA) || hasActiveAbility?(:VITALSPIRIT) &&
              ![12,40,48].include?($fefieldeffect) || hasActiveAbility?(:INNERFOCUS) && $fefieldeffect == 48)
          @battle.pbShowAbilitySplash(self)
          pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} woke it up!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        elsif @status == :PARALYSIS && hasActiveAbility?(:LIMBER)
          @battle.pbShowAbilitySplash(self)
          pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        elsif @status == :FROZEN && hasActiveAbility?(:MAGMAARMOR) && ![22,39,46].include?($fefieldeffect) &&
              !([8,21,26].include?($fefieldeffect) && grounded?)
          @battle.pbShowAbilitySplash(self)
          pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        elsif @status == :BURN && hasActiveAbility?([:WATERVEIL,:WATERBUBBLE]) &&
              ![12,49].include?($fefieldeffect)
          @battle.pbShowAbilitySplash(self)
          pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        elsif (@effects[PBEffects::Attract]>=0 || @effects[PBEffects::Taunt] > 0) &&
              (hasActiveAbility?(:OBLIVIOUS) || hasActiveAbility?(:SOUNDPROOF) && $fefieldeffect == 6)
          @battle.pbShowAbilitySplash(self)
          if @effects[PBEffects::Attract]>=0
            pbCureAttract
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1} got over its infatuation.",pbThis))
            else
              @battle.pbDisplay(_INTL("{1}'s {2} cured its infatuation status!",pbThis,abilityName))
            end
          end
          if @effects[PBEffects::Taunt]>0
            @effects[PBEffects::Taunt] = 0
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1}'s Taunt wore off!",pbThis))
            else
              @battle.pbDisplay(_INTL("{1}'s {2} made its taunt wear off!",pbThis,abilityName))
            end
          end
          @battle.pbHideAbilitySplash(self)
        elsif @effects[PBEffects::Confusion]>0 && hasActiveAbility?(:OWNTEMPO)
          @battle.pbShowAbilitySplash(self)
          pbCureConfusion
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} snapped out of its confusion.",pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
      end
    end
  
    #=============================================================================
    # Ability change
    #=============================================================================
    def pbOnAbilityChanged(oldAbil)
      if @effects[PBEffects::Illusion] && oldAbil == :ILLUSION
        @effects[PBEffects::Illusion] = nil
        if !@effects[PBEffects::Transform]
          @battle.scene.pbChangePokemon(self, @pokemon)
          @battle.pbDisplay(_INTL("{1}'s {2} wore off!", pbThis, GameData::Ability.get(oldAbil).name))
          @battle.pbSetSeen(self)
        end
      end
      @effects[PBEffects::GastroAcid] = false if unstoppableAbility?
      @effects[PBEffects::SlowStart]  = 0 if self.ability != :SLOWSTART
      # Revert form if Flower Gift/Forecast was lost
      pbCheckFormOnWeatherChange
      pbCheckFormOnTerrainChange
      # Check for end of primordial weather
      @battle.pbEndPrimordialWeather
    end
  
    #=============================================================================
    # Held item consuming/removing
    #=============================================================================
    def canConsumeBerry?
      return false if @battle.pbCheckOpposingAbility(:UNNERVE,@index) && $fefieldeffect != 48
      return true
    end
  
    def canConsumePinchBerry?(check_gluttony=true,currentHP=@hp)
      return false if !canConsumeBerry?
      return true if currentHP <= @totalhp / 4
      return true if currentHP <= @totalhp / 2 && (!check_gluttony || hasActiveAbility?(:GLUTTONY) && 
                     $fefieldeffect != 12)
      return false
    end
  
    # permanent is whether the item is lost even after battle. Is false for Knock
    # Off.
    def pbRemoveItem(permanent = true)
      @effects[PBEffects::ChoiceBand] = nil
      activateUnburden if self.item
      setInitialItem(nil) if permanent && self.item == self.initialItem
      self.item = nil
    end
  
    def pbConsumeItem(recoverable=true,symbiosis=true,belch=true)
      PBDebug.log("[Item consumed] #{pbThis} consumed its held #{itemName}")
      if recoverable
        setRecycleItem(@item_id)
        @effects[PBEffects::PickupItem] = @item_id
        @effects[PBEffects::PickupUse]  = @battle.nextPickupUse
      end
      setBelched if belch && self.item.is_berry?
      pbRemoveItem
      pbSymbiosis if symbiosis
    end
  
    def pbSymbiosis
      return if fainted?
      return if !self.item
      @battle.pbPriority(true).each do |b|
        next if b.opposes?
        next if !b.hasActiveAbility?(:SYMBIOSIS)
        next if !b.item || b.unlosableItem?(b.item)
        next if unlosableItem?(b.item)
        @battle.pbShowAbilitySplash(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} shared its {2} with {3}!",
             b.pbThis,b.itemName,pbThis(true)))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} let it share its {3} with {4}!",
             b.pbThis,b.abilityName,b.itemName,pbThis(true)))
        end
        self.item = b.item
        b.item = nil
        b.activateUnburden
        @battle.pbHideAbilitySplash(b)
        pbHeldItemTriggerCheck
        if [2,8,15,19,31,42,47].include?($fefieldeffect)
          if b.pbRecoverHP((b.totalhp/3).round,true)>0
            @battle.pbDisplay(_INTL("Some of {1}'s health was restored.",b.pbThis(true)))
          end
          if pbRecoverHP((@totalhp/3).round,true)>0
            @battle.pbDisplay(_INTL("Some of {1}'s health was restored.",pbThis(true)))
          end
        elsif $fefieldeffect == 33 && $fecounter >= 1
          quotient = 5-$fecounter
          if b.canHeal?
            b.pbRecoverHP((b.totalhp/quotient).round,true)
            @battle.pbDisplay(_INTL("Some of {1}'s health was restored.",b.pbThis(true)))
          end
          if canHeal?
            pbRecoverHP((@totalhp/quotient).round,true)
            @battle.pbDisplay(_INTL("Some of {1}'s health was restored.",pbThis(true)))
          end
        end
        break
      end
    end
  
    # item_to_use is an item ID or GameData::Item object. own_item is whether the
    # item is held by self. fling is for Fling only.
    def pbHeldItemTriggered(item_to_use, own_item = true, fling = false)
      if GameData::Item.get(item_to_use).is_berry?
        if canHeal?
          # Cheek Pouch
          if hasActiveAbility?(:CHEEKPOUCH)
            @battle.pbShowAbilitySplash(self)
            if $fefieldeffect == 33 && $fecounter >= 3
              pbRecoverHP(@totalhp / 2)
            else
              pbRecoverHP(@totalhp / 3)
            end
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1}'s HP was restored.", pbThis))
            else
              @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.", pbThis, abilityName))
            end
            if $fefieldeffect == 42
              pbRaiseStatStage(@battle.generateRandomStat,1,nil,true)
            end
            @battle.pbHideAbilitySplash(self)
          end
          # Desert Berry HP Restoration
          if $fefieldeffect == 12
            if pbRecoverHP(@totalhp/4)>0
              @battle.pbDisplay(_INTL("{1} restored some of its energy!",pbThis))
            end
          end
        end
        # Murkwater Surface Berry Poisoning
        if $fefieldeffect == 26 && pbCanPoison?(nil,false)
          pbPoison
        end
        # Gluttony Boxing Ring
        if hasActiveAbility?(:GLUTTONY) && $fefieldeffect == 45
          pbRaiseStatStageByAbility([:DEFENSE,:SPECIAL_DEFENSE],1,self)
        end
        # Selective Palate
        if hasActiveAbility?(:SELECTIVEPALATE) && (likesBerryFlavor?(item_to_use) ||
           $fefieldeffect == 2 || $fefieldeffect == 33 && $fecounter >= 3) && !([8,26].include?($fefieldeffect) &&
           grounded?) && ($fefieldeffect != 42 || dislikesBerryFlavor?(item_to_use))
          pbRaiseStatStageByAbility([:ATTACK,:SPEED],2,self)
        end
        # Berry Galore
        if hasActiveAbility?(:BERRYGALORE)
          pbRaiseStatStageByAbility([:DEFENSE,:SPECIAL_DEFENSE],1,self)
        end
      end
      pbConsumeItem if own_item
      pbSymbiosis if !own_item && !fling   # Bug Bite/Pluck users trigger Symbiosis
    end
    
    def activateUnburden
      @effects[PBEffects::Unburden] = true
      if hasActiveAbility?(:UNBURDEN)
        if $fefieldeffect == 6
          pbRaiseStatStageByAbility([:ATTACK,:SPECIAL_ATTACK],1,self)
        elsif [12,48].include?($fefieldeffect)
          if pbRecoverHP((@totalhp/4).round)>0
            @battle.pbDisplay(_INTL("Some of {1}'s energy was restored.",pbThis(true)))
          end
        elsif $fefieldeffect == 20
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        elsif $fefieldeffect == 45
          pbLowerStatStageByAbility([:DEFENSE,:SPECIAL_DEFENSE],1,self)
        end
      end
    end
  
    #=============================================================================
    # Held item trigger checks
    #=============================================================================
    # NOTE: A Pokémon using Bug Bite/Pluck, and a Pokémon having an item thrown at
    #       it via Fling, will gain the effect of the item even if the Pokémon is
    #       affected by item-negating effects.
    # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
    # fling is for Fling only.
    def pbHeldItemTriggerCheck(item_to_use = nil, fling = false)
      return if fainted?
      return if !item_to_use && !itemActive?
      pbItemHPHealCheck(item_to_use, fling)
      pbItemStatusCureCheck(item_to_use, fling)
      pbItemEndOfMoveCheck(item_to_use, fling)
      # For Enigma Berry, Kee Berry and Maranga Berry, which have their effects
      # when forcibly consumed by Pluck/Fling.
      if item_to_use
        itm = item_to_use || self.item
        if BattleHandlers.triggerTargetItemOnHitPositiveBerry(itm, self, @battle, true)
          pbHeldItemTriggered(itm, false, fling)
        end
      end
    end
  
    # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
    # fling is for Fling only.
    def pbItemHPHealCheck(item_to_use = nil, fling = false)
      return if !item_to_use && !itemActive?
      itm = item_to_use || self.item
      if BattleHandlers.triggerHPHealItem(itm, self, @battle, !item_to_use.nil?)
        pbHeldItemTriggered(itm, item_to_use.nil?, fling)
      elsif !item_to_use
        pbItemTerrainStatBoostCheck
      end
    end
  
    # Cures status conditions, confusion, infatuation and the other effects cured
    # by Mental Herb.
    # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
    # fling is for Fling only.
    def pbItemStatusCureCheck(item_to_use = nil, fling = false)
      return if fainted?
      return if !item_to_use && !itemActive?
      itm = item_to_use || self.item
      if BattleHandlers.triggerStatusCureItem(itm, self, @battle, !item_to_use.nil?)
        pbHeldItemTriggered(itm, item_to_use.nil?, fling)
      end
    end
  
    # Called at the end of using a move.
    # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
    # fling is for Fling only.
    def pbItemEndOfMoveCheck(item_to_use = nil, fling = false)
      return if fainted?
      return if !item_to_use && !itemActive?
      itm = item_to_use || self.item
      if BattleHandlers.triggerEndOfMoveItem(itm, self, @battle, !item_to_use.nil?)
        pbHeldItemTriggered(itm, item_to_use.nil?, fling)
      elsif BattleHandlers.triggerEndOfMoveStatRestoreItem(itm, self, @battle, !item_to_use.nil?)
        pbHeldItemTriggered(itm, item_to_use.nil?, fling)
      end
    end
  
    # Used for White Herb (restore lowered stats). Only called by Moody and Sticky
    # Web, as all other stat reduction happens because of/during move usage and
    # this handler is also called at the end of each move's usage.
    # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
    # fling is for Fling only.
    def pbItemStatRestoreCheck(item_to_use = nil, fling = false)
      return if fainted?
      return if !item_to_use && !itemActive?
      itm = item_to_use || self.item
      if BattleHandlers.triggerEndOfMoveStatRestoreItem(itm, self, @battle, !item_to_use.nil?)
        pbHeldItemTriggered(itm, item_to_use.nil?, fling)
      end
    end
  
    # Called when the battle terrain changes and when a Pokémon loses HP.
    def pbItemTerrainStatBoostCheck
      return if !itemActive?
      if BattleHandlers.triggerTerrainStatBoostItem(self.item, self, @battle)
        pbHeldItemTriggered(self.item)
      end
    end
  
    # Used for Adrenaline Orb. Called when Intimidate is triggered (even if
    # Intimidate has no effect on the Pokémon).
    def pbItemOnIntimidatedCheck
      return if !itemActive?
      if BattleHandlers.triggerItemOnIntimidated(self.item, self, @battle)
        pbHeldItemTriggered(self.item)
      end
    end
  end
  