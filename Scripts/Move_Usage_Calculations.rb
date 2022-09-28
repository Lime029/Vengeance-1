class PokeBattle_Move
    #=============================================================================
    # Move's type calculation
    #=============================================================================
    def pbBaseTypes(user)
      ret = @types
      if ret
        #ret = BattleHandlers.triggerMoveBaseTypeModifierAbility(user.ability,user,self,ret)
        if @types.include?(:NORMAL)
          if user.hasActiveAbility?(:AERILATE) && ![7,13,22,23,41,44].include?($fefieldeffect)
            if i = @types.index(:NORMAL)
              @types[i] = :FLYING
            else
              @types.push(:FLYING)
            end
            if [27,28,43].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:GALVANIZE)
            if i = @types.index(:NORMAL)
              @types[i] = :ELECTRIC
            else
              @types.push(:ELECTRIC)
            end
            if [1,17].include?($fefieldeffect)
              @powerBoost *= 1.5
            elsif $fefieldeffect == 18
              @powerBoost *= 2
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:PIXILATE) && ![38,40].include?($fefieldeffect)
            if i = @types.index(:NORMAL)
              @types[i] = :FAIRY
            else
              @types.push(:FAIRY)
            end
            if [3,9,24,31,42].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:REFRIGERATE) && ![7,12,16,48,49].include?($fefieldeffect)
            if i = @types.index(:NORMAL)
              @types[i] = :ICE
            else
              @types.push(:ICE)
            end
            if [13,28,39,46].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:CULTIVATE) && ![7,10,11,12,26,35,38,39,46].include?($fefieldeffect)
            if i = @types.index(:NORMAL)
              @types[i] = :GRASS
            else
              @types.push(:GRASS)
            end
            if $fefieldeffect == 33 && $fecounter >= 3
              @powerBoost *= 2
            elsif [2,15,42,47].include?($fefieldeffect) || $fefieldeffect == 33 && 
                  $fecounter >= 1
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:DRENCH) && ![12,49].include?($fefieldeffect)
            if i = @types.index(:NORMAL)
              @types[i] = :WATER
            else
              @types.push(:WATER)
            end
            if [3,21,22,26].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:CRYSTALLIZE) && $fefieldeffect != 7 && !($fefieldeffect == 10 &&
             user.grounded?)
            if i = @types.index(:NORMAL)
              @types[i] = :ROCK
            else
              @types.push(:ROCK)
            end
            if [4,13,14,25].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:CONTAMINATE) && ![3,9,29].include?($fefieldeffect)
            if i = @types.index(:NORMAL)
              @types[i] = :POISON
            else
              @types.push(:POISON)
            end
            if [10,11,19,26,41].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:IMMOLATE) && !([8,21,26].include?($fefieldeffect) &&
             user.grounded?) && ![22,39,46].include?($fefieldeffect)
            if i = @types.index(:NORMAL)
              @types[i] = :FIRE
            else
              @types.push(:FIRE)
            end
            if [7,16].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:BRUTALIZE) && ![3,9,31].include?($fefieldeffect)
            if i = @types.index(:NORMAL)
              @types[i] = :FIGHTING
            else
              @types.push(:FIGHTING)
            end
            if $fefieldeffect == 45
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:POLLINATE) && ![7,10,11,22].include?($fefieldeffect)
            if i = @types.index(:NORMAL)
              @types[i] = :BUG
            else
              @types.push(:BUG)
            end
            if $fefieldeffect == 2 || $fefieldeffect == 33 && $fecounter >= 2
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:EARTHINIZE) && ![9,35,38,39,43].include?($fefieldeffect)
            if i = @types.index(:NORMAL)
              @types[i] = :GROUND
            else
              @types.push(:GROUND)
            end
            if [2,12,23].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:ELECTROPLATE)
            if i = @types.index(:NORMAL)
              @types[i] = :STEEL
            else
              @types.push(:STEEL)
            end
            if [1,17,22].include?($fefieldeffect) || [21,26].include?($fefieldeffect) && 
               user.grounded?
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:DRACONIZE) && $fefieldeffect != 3
            if i = @types.index(:NORMAL)
              @types[i] = :DRAGON
            else
              @types.push(:DRAGON)
            end
            if [29,32].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:TERRORIZE)
            if i = @types.index(:NORMAL)
              @types[i] = :DARK
            else
              @types.push(:DARK)
            end
            if [38,39].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:REINCARNATE) && $fefieldeffect != 29
            if i = @types.index(:NORMAL)
              @types[i] = :GHOST
            else
              @types.push(:GHOST)
            end
            if [31,40].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:ANIMATE) && $fefieldeffect != 39
            if $fefieldeffect == 40
              if i = @types.index(:NORMAL)
                @types[i] = :GHOST
              else
                @types.push(:GHOST)
              end
            else
              if i = @types.index(:NORMAL)
                @types[i] = :PSYCHIC
              else
                @types.push(:PSYCHIC)
              end
            end
            if [5,6,19,42].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:SEASONALHEART) && ![35,38,39].include?($fefieldeffect)
            sType = :NORMAL
            case user.form
            when 0 # Spring
              sType = :BUG
            when 1 # Summer
              sType = :FIRE
            when 2 # Autumn
              sType = :FLYING
            when 3 # Winter
              sType = :ICE
            end
            if i = @types.index(:NORMAL)
              @types[i] = sType
            else
              @types.push(sType)
            end
          end
        end
        if soundMove?(user)
          if user.hasActiveAbility?(:LIQUIDVOICE)
            @types = [:WATER]
            if $fefieldeffect == 48
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:FROZENVOICE) && ![12,49].include?($fefieldeffect)
            if [7,16].include?($fefieldeffect)
              @types = [:WATER]
            else
              @types = [:ICE]
            end
            if $fefieldeffect == 13
              @powerBoost *= 1.5
            elsif $fefieldeffect == 39
              @powerBoost *= 2
            else
              @powerBoost *= 1.2
            end
          end
          if user.hasActiveAbility?(:STUMPDRUMMER)
            @types = [:GRASS]
            if [15,42,47].include?($fefieldeffect)
              @powerBoost *= 1.5
            else
              @powerBoost *= 1.2
            end
          end
        end
        if piercingMove? && user.hasActiveAbility?(:STINGER)
          @types = [:POISON]
        end
        if user.hasActiveAbility?(:FLAMINGFEET) && kickingMove? && ![8,21,26].include?($fefieldeffect) &&
           user.grounded? && $fefieldeffect != 22
          @types = [:FIRE]
          if [7,16].include?($fefieldeffect)
            @powerBoost *= 1.5
          else
            @powerBoost *= 1.2
          end
        end
        if user.hasActiveAbility?(:NORMALIZE) && ![31,37].include?($fefieldeffect)
          @types = [:NORMAL]
          if [29,44].include?($fefieldeffect)
            @powerBoost *= 2
          else
            @powerBoost *= 1.2
          end
        end
      end
      return ret
    end
    
    def pbCalcTypes(user)
      @powerBoost = 1
      ret = pbBaseTypes(user)
      if @function == "144" # Flying Press
        ret.push(:FLYING)
      end
      if ret && GameData::Type.exists?(:ELECTRIC)
        if @battle.field.effects[PBEffects::IonDeluge]
          if $fefieldeffect == 1
            ret = [:ELECTRIC]
          elsif ret.include?(:NORMAL)
            ret[ret.index(:NORMAL)] = :ELECTRIC
          end
          @powerBoost = 1
        end
        if user.effects[PBEffects::Electrify]
          ret = [:ELECTRIC]
          @powerBoost = 1
        end
      end
      ret |= [] # Remove duplicates
      case $fefieldeffect
      when 1 # Electric Terrain
        if [:EXPLOSION,:SELFDESTRUCT,:SURF,:HURRICANE,:BUBBLE,:ENERGYBALL,:PSYSHOCK,
           :VENOSHOCK,:THUNDEROUSKICK,:TURBODRIVE,:TSUNAMI].include?(@id)
          ret.push(:ELECTRIC)
        end
      when 3 # Misty Terrain
        if ret.include?(:WATER) || windMove?
          ret.push(:FAIRY)
        end
      when 4 # Dark Crystal Cavern
        if ret.include?(:GHOST)
          ret.push(:DARK)
        end
      when 5 # Chess Board
        if chessMove?(user)
          ret.push(:ROCK)
          ret.push(:PSYCHIC)
        end
      when 7 # Volcanic Field
        if @id == :ROCKCLIMB
          ret[0] = :ROCK
        end
        if [:THOUSANDARROWS,:SMOG,:EARTHQUAKE,:MUDSLAP,:DIG,:MAGNITUDE,:MUDSHOT,:EARTHPOWER,
           :AVALANCHE,:VITALTHROW,:MUDBOMB,:FIERYWRATH,:STORMTHROW,:LOWSWEEP,:CIRCLETHROW,
           :LANDSWRATH,:POLLENPUFF,:SUNSTEELSTRIKE,:TECTONICRAGE,:SAVAGESPINOUT,:CONTINENTALCRUSH,
           :SEARINGSUNRAZESMASH,:INFERNALPARADE].include?(@id) || ret.include?(:ROCK) ||
           ret.include?(:GRASS)
          ret.push(:FIRE)
        end
      when 8 # Swamp
        if [:SMACKDOWN,:SLUDGEWAVE].include?(@id) || ret.include?(:GROUND)
          ret.push(:WATER)
        end
        if [:MUDDYWATER,:BRINE].include?(@id)
          ret.push(:GROUND)
        end
      when 9 # Rainbow Field
        if [:SILVERWIND,:DRAGONPULSE,:MYSTICALFIRE,:TRIATTACK,:SACREDFIRE,:FIREPLEDGE,
           :WATERPULSE,:GRASSPLEDGE,:AURORABEAM,:JUDGMENT,:COMETPUNCH,:SECRETPOWER,
           :WEATHERBALL,:MISTBALL,:ZENHEADBUTT,:SPARKLINGARIA,:LIGHTOFRUIN,:PRISMATICLASER,
           :MULTIATTACK,:ICEBEAM,:BUBBLEBEAM,:SOLARBEAM,:SKYATTACK,:BUBBLE,:LUSTERPURGE,
           :SIGNALBEAM,:MAGICALLEAF,:POWERGEM,:MIRRORSHOT,:FLASHCANNON,:CHARGEBEAM,
           :FREEZESHOCK,:ICEBURN,:FUSIONFLARE,:FUSIONBOLT,:DAZZLINGGLEAM,:MOONGEISTBEAM,
           :PHOTONGEYSER,:MIRRORLAUNCH,:LUMINOUSBLADE,:MISTSLASH,:TWINKLETACKLE].include?(@id) || 
           ret.include?(:NORMAL) && specialMove? || isHiddenPower?
          if user.hasActiveAbility?(:SKILLLINK)
            ret = [:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,:ROCK,:BUG,:GHOST,:STEEL,
                   :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,:ICE,:DRAGON,:DARK,:FAIRY] # Every Type
          else
            ret.push(@battle.generateRandomType)
          end
        end
      when 10 # Corrosive Field
        if [:SMACKDOWN,:MUDDYWATER,:WHIRLPOOL,:ROCKSLIDE,:AVALANCHE,:LOWSWEEP,:STEAMROLLER].include?(@id) ||
           ret.include?(:GRASS) && user.grounded? || ret.include?(:GROUND)
          ret.push(:POISON)
        end
      when 11 # Corrosive Mist Field
        if ret.include?(:WATER) || windMove? || [:ABSORB,:MEGADRAIN,:ENERGYBALL,:GIGADRAIN,
           :MISTBALL,:APPLEACID,:STRANGESTEAM].include?(@id)
          ret.push(:POISON)
        end
      when 12 # Desert Field
        if ret.include?(:ICE)
          ret[ret.index(:ICE)] = :WATER
        end
        if ret.include?(:ROCK) || windMove? || @id == :WHIRLPOOL
          ret.push(:GROUND)
        end
      when 13 # Icy Cave
        if ret.include?(:ROCK)
          ret.push(:ICE)
        end
      when 14 # Rocky Field
        if [:ROCKCLIMB,:EARTHQUAKE,:MAGNITUDE,:STRENGTH,:BULLDOZE,:DIG,:EARTHPOWER,
           :PRECIPICEBLADES].include?(@id)
          ret.push(:ROCK)
        end
      when 15 # Forest
        if slashingMove?
          ret.push(:GRASS)
        end
      when 16 # Volcanic Top Field
        if ret.include?(:ICE)
          ret.push(:WATER)
        end
        if [:EXPLOSION,:SELFDESTRUCT,:MAGNETBOMB,:EGGBOMG,:DIVE,:SMOG,:DIG,:PRECIPICEBLADES,
           :STONEEDGE,:FIERYWRATH,:INFERNALPARADE].include?(@id)
          ret.push(:FIRE)
        end
      when 17 # Factory Field
        if user.hasActiveAbility?(:IRONFIST) && punchingMove?
          ret.push(:STEEL)
        end
        if [:SURF,:MUDDYWATER,:TSUNAMI,:HYDROVORTEX].include?(@id)
          ret.push(:ELECTRIC)
        end
      when 18 # Short-Circuit Field
        if @id == :EXTREMESPEED
          ret[0] = :GHOST
        end
        if [:SURF,:MUDDYWATER,:MAGNETBOMB,:GYROBALL,:FREEZESHOCK,:GEARGRIND,:EXTREMESPEED,
           :SIGNALBEAM,:POWERGEM,:ENERGYBALL,:PSYSHOCK,:VENOSHOCK,:DRAGONENERGY,:THUNDEROUSKICK].include?(@id) ||
           user.hasActiveAbility?(:STEELWORKER) && ret.include?(:STEEL)
          ret.push(:ELECTRIC)
        end
      when 19 # Wasteland
        if [:MUDBOMB,:MUDSLAP,:MUDSHOT,:OCTAZOOKA,:ABSORB,:ASTONISH,:FLING,:SHADOWSNEAK,
           :GRASSKNOT,:STOREDPOWER,:POLTERGEIST].include?(@id) || ret.include?(:PSYCHIC) ||
           isHiddenPower?
          ret.push(:POISON)
        end
      when 20 # Ashen Beach
        if @id == :STRENGTH
          ret[0] = :FIGHTING
          ret.push(:PSYCHIC)
        end
      when 21 # Water Surface
        if [:MEGADRAIN,:GIGADRAIN,:MUDSLAP,:MUDSHOT,:MUDBOMB,:MISTBALL].include?(@id)
          ret.push(:WATER)
        end
      when 22 # Underwater
        if ret.include?(:FIRE) && physicalMove?
          ret[ret.index(:FIRE)] = :NORMAL
        end
        if [:MEGADRAIN,:GIGADRAIN,:MUDSLAP,:MUDSHOT,:MUDBOMB,:MISTBALL].include?(@id)
          ret.push(:WATER)
        end
      when 23 # Cave
        if @id == :ROCKCLIMB
          ret[0] = :ROCK
        end
      when 24 # Glitch
        for i in 0...ret.length
          if [:DARK,:STEEL,:FAIRY].include?(ret[i])
            ret[i] = :QMARKS
          end
        end
      when 25 # Crystal Cavern
        if [:JUDGMENT,:MULTIATTACK,:PRISMATICLASER,:TRIATTACK,:AURORABEAM].include?(@id) ||
           user.effects[PBEffects::NeverMiss] || ret.include?(:ROCK) || isHiddenPower?
          if user.hasActiveAbility?(:SKILLLINK)
            ret.push(:FIRE,:WATER,:GRASS,:ELECTRIC,:FAIRY,:GHOST,:PSYCHIC) # Crystal Types
          else
            ret.push(@battle.crystalType)
          end
        end
      when 26 # Murkwater Surface
        if [:MUDSLAP,:MUDBOMB,:MUDSHOT,:THOUSANDWAVES,:SMACKDOWN,:MUDDYWATER,:SLUDGEWAVE].include?(@id)
          ret.push(:WATER)
          ret.push(:POISON)
        end
        if user.grounded? && ret.include?(:WATER)
          ret.push(:POISON)
        end
      when 27 # Mountain
        if @id == :ROCKCLIMB
          ret[0] = :ROCK
        end
        if [:STEELWING,:ESPERWING].include?(@id)
          ret.push(:FLYING)
        end
      when 28 # Snowy Mountain
        if @id == :ROCKCLIMB
          ret[0] = :ROCK
        end
        if [:STEELWING,:ESPERWING].include?(@id)
          ret.push(:FLYING)
        end
        if ret.include?(:ROCK) || windMove?
          ret.push(:ICE)
        end
      when 31 # Fairy Tale Field
        if slashingMove?
          ret[0] = :STEEL
        end
        if [:BLUEFLARE,:FIREBLAST,:FLAMETHROWER,:FUSIONFLARE,:SACREDFIRE].include?(@id)
          ret.push(:DRAGON)
        end
      when 32 # Dragon's Den
        if soundMove?(user) || ret.include?(:FIRE) || ret.include?(:ICE) || ret.include?(:ELECTRIC)
          ret.push(:DRAGON)
        end
        if [:TRIATTACK,:FUSIONFLARE,:FUSIONBOLT].include?(@id)
          ret = [:DRAGON,:FIRE,:ELECTRIC,:ICE]
        elsif @id == :FREEZESHOCK
          ret.push(:ELECTRIC)
        elsif @id == :ICEBURN
          ret.push(:FIRE)
        elsif @id == :DRAGONFLEET
          ret.push(:FIRE)
          ret.push(:ELECTRIC)
          ret.push(:ICE)
        end
      when 34 # Starlight Arena
        if [:SOLARBEAM,:SOLARBLADE].include?(@id)
          ret[0] = :FIRE
        elsif @id == :DOOMDESIRE
          ret.push(:FIRE)
        elsif [:SKYATTACK,:SUPERSONICSKYSTRIKE].include?(@id)
          ret.push(:DARK)
        end
        if ret.include?(:DARK)
          ret.push(:FAIRY)
        end
      when 35 # Ultra Space
        if isHiddenPower?
          ret[0] = @battle.generateRandomType
        elsif @id == :VACUUMWAVE
          ret[0] = :DARK
        elsif @id == :ENERGYBALL
          ret[0] = :PSYCHIC
        end
      when 37 # Psychic Terrain
        if [:STRENGTH,:ANCIENTPOWER,:ENERGYBALL,:SMARTSTRIKE,:MINDBLOWN,:DRAGONENERGY].include?(@id)
          ret.push(:PSYCHIC)
        end
      when 38 # Dimensional Field
        if @id == :OBLIVIONWING
          ret.push(:DARK)
        end
      when 39 # Frozen Dimensional Field
        if [:SURF,:DARKPULSE,:MUDDYWATER,:BUBBLE,:BUBBLEBEAM,:EARTHQUAKE,:DIG,:EARTHPOWER,
           :LANDSWRATH,:FREEZINGGLARE,:TSUNAMI].include?(@id)
          ret.push(:ICE)
        end
      when 40 # Haunted Field
        if ret.include?(:FIRE)
          ret.push(:GHOST)
        end
      when 41 # Corrupted Cave
        if ret.include?(:ROCK) || ret.include?(:GRASS) || [:MUDSHOT,:MUDBOMB,:MUDSLAP].include?(@id)
          ret.push(:POISON)
        end
        if [:GUNKSHOT,:SLUDGEWAVE].include?(@id)
          ret.push(:ROCK)
        end
      when 43 # Sky Field
        if @id == :DIVE
          ret[0] = :FLYING
        end
        if windMove? || [:SKYUPPERCUT,:STEELWING,:BOLTBEAK,:CRIMSONDIVE,:ESPERWING].include?(@id)
          ret.push(:FLYING)
        end
      when 45 # Boxing Ring
        if ret.include?(:NORMAL) && pbContactMove?(user)
          ret[ret.index(:NORMAL)] = :FIGHTING
        end
      when 46 # Subzero
        if ret.include?(:WATER) && ![:SCALD,:STEAMERUPTION].include?(@id) && ![:Sun,:HarshSun].include?(@battle.pbWeather)
          ret[ret.index(:WATER)] = :ICE
        end
        if ret.include?(:GROUND)
          ret.push(:ICE)
        end
      when 47 # Jungle
        if [:BIND,:CONSTRICT].include?(@id)
          ret[0] = :GRASS
        end
      when 48 # Beach
        if @id == :STRENGTH
          ret[0] = :FIGHTING
          ret.push(:PSYCHIC)
        end
        if [:MUDSHOT,:MUDSLAP,:MUDBOMB].include?(@id)
          ret.push(:WATER)
        end
        if @id == :MUDDYWATER
          ret.push(:GROUND)
        end
      when 49 # Xeric Shrubland
        if ret.include?(:ROCK) || windMove?
          ret.push(:GROUND)
        end
        if ret.include?(:ICE)
          ret.push(:WATER)
        end
      end
      if user.hasActiveAbility?(:ARMCANNON) && punchingMove?
        ret.push(:FIRE)
      end
      if user.hasActiveAbility?(:SPEEDLAUNCHER) && pulseMove?
        if $fefieldeffect == 21 && user.grounded? || $fefieldeffect == 22
          ret.push(:WATER)
        elsif $fefieldeffect == 26 && user.grounded?
          ret.push(:WATER)
          ret.push(:POISON)
        end
      end
      ret |= [] # Remove duplicates
      return ret
    end
  
    #=============================================================================
    # Type effectiveness calculation
    #=============================================================================
    def pbCalcTypeModSingle(moveTypes,defType,user,target)
      finalRet = 1
      for t in moveTypes
        # If the modifier depends on each type of the move
        ret = Effectiveness.calculate_one(t,defType)/2.0
        case $fefieldeffect
        when 10 # Corrosive Field
          ret = 2 if defType == :STEEL && t == :POISON
        when 12 # Desert
          ret = 0 if defType == :GROUND && t == :WATER
        when 22 # Underwater
          ret = 1 if defType == :WATER && t == :WATER
          ret = 1 if target.hasActiveAbility?(:MULTISCALE) && defType == :WATER && 
                     [:GRASS,:ELECTRIC].include?(t)
        when 24 # Glitch Field
          ret = 0 if defType == :PSYCHIC && t == :GHOST
          ret = 2 if defType == :BUG && t == :POISON
          ret = 2 if defType == :POISON && t == :BUG
          ret = 1 if defType == :FIRE && t == :ICE
        when 29 # Holy Field
          ret = 2 if [:DARK,:GHOST].include?(defType) && t == :NORMAL
        when 31 # Fairy Tale Field
          ret = 2 if defType == :DRAGON && t == :STEEL
        when 32 # Dragon's Den
          ret = 1 if target.hasActiveAbility?(:MULTISCALE) && defType == :DRAGON &&
                     [:FAIRY,:ICE].include?(t) # Exclude Dragon because it's not a weakness on this field
          ret = 0.5 if [:DRAGON,:FAIRY].include?(defType) && t == :DRAGON
        when 33 # Flower Garden Field
          if $fecounter > 0
            ret *= 2 if defType == :GRASS && slashingMove?
          end
        when 34 # Starlight Arena
          ret = 1 if defType == :DARK && t == :PSYCHIC
          ret = 1 if defType == :PSYCHIC && t == :DARK
        when 40 # Haunted Field
          ret = 2 if defType == :NORMAL && t == :GHOST
          ret = 1 if defType == :GHOST && t == :DARK
        when 42 # Bewitched Woods
          ret = 2 if [:STEEL,:POISON].include?(defType) && [:GRASS,:FAIRY].include?(t)
          ret = 1 if [:GRASS,:FAIRY].include?(defType) && t == :POISON
        when 45 # Boxing Ring
          ret = 2 if [:PSYCHIC,:BUG].include?(defType) && t == :FIGHTING
          ret = 0.5 if defType == :FIGHTING && t == :PSYCHIC
        when 46 # Subzero Field
          ret = 2 if defType == :WATER && t == :ICE
        when 49 # Xeric Shrubland
          ret = 0 if defType == :GRASS && t == :GROUND
          ret = 0 if defType == :GROUND && t == :WATER
        end
        # Ring Target
        if target.hasActiveItem?(:RINGTARGET)
          ret = 1 if Effectiveness.ineffective_type?(t,defType)
        end
        # Foresight
        if user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]
          ret = 1 if defType == :GHOST && Effectiveness.ineffective_type?(t,defType)
        end
        # Miracle Eye
        if target.effects[PBEffects::MiracleEye]
          ret = 1 if defType == :DARK && Effectiveness.ineffective_type?(t,defType)
        end
        # Delta Stream's weather
        if @battle.pbWeather == :StrongWinds
          ret = 1 if defType == :FLYING && Effectiveness.super_effective_type?(t,defType)
        end
        # Grounded Flying-type Pokémon become susceptible to Ground moves
        if target.grounded?
          ret = 1 if defType == :FLYING && t == :GROUND
        end
        # Sun Devourer
        if user.hasActiveAbility?(:SUNDEVOURER) && $fefieldeffect != 38
          ret *= 4 if defType == :FIRE && t == :STEEL
        end
        # Idealism
        if target.hasActiveAbility?(:IDEALISM)
          if $fefieldeffect == 31
            ret = 1 if Effectiveness.super_effective_type?(t,defType)
          else
            ret = 1 if defType == :DRAGON
          end
        end
        # Truth Seeker
        if user.hasActiveAbility?(:TRUTHSEEKER)
          ret = 1 if t == :DRAGON
        end
        # Rampant Fury
        if user.hasActiveAbility?(:RAMPANTFURY) && user.pbHasType?(t)
          ret = 2 if ret < 1
        end
        # Seasonal Heart
        if user.hasActiveAbility?(:SEASONALHEART) && ![35,38,39].include?($fefieldeffect)
          case user.form
          when 0 # Spring
            if t == :BUG
              ret = 0.5
            end
          when 1 # Summer
            if t == :FIRE
              ret = 0.5
            end
          when 2 # Autumn
            if t == :FLYING
              ret = 0.5
            end
          when 3 # Winter
            if t == :ICE
              ret = 0.5
            end
          end
        end
        finalRet *= ret
      end
      # If the modifier doesn't depend on each type of the move
      # Flytrap
      if user.hasActiveAbility?(:FLYTRAP) && defType == :BUG && bitingMove? && $fefieldeffect != 22
        finalRet *= 2
      end
      # Unyielding Fang
      if user.hasActiveAbility?(:UNYIELDINGFANG)
        finalRet = 2 if ([:ROCK,:STEEL].include?(defType) || defType == :ICE && $fefieldeffect == 13) && 
                        bitingMove?
      end
      # Type Inversion
      if $fefieldeffect == 5 && ($fecounter%6 == 2 || @battle.field.effects[PBEffects::PrevFECounter]%6 == 2 && # Queen (Doubles)
         user.hasActiveAbility?(:SKILLLINK)) && !@battle.singleBattle? || $fefieldeffect == 36 &&
         !user.hasActiveAbility?([:SIMPLE,:UNAWARE,:AURABREAK,:INFILTRATOR]) && !target.hasActiveAbility?([:SIMPLE,
         :UNAWARE,:AURABREAK]) || $fefieldeffect == 9 && (user.hasActiveAbility?(:PALINDROME) ||
         target.hasActiveAbility?(:PALINDROME))
        if finalRet == 0
          finalRet = target.totalhp # Guaranteed KO
        else
          finalRet = 1.0/finalRet # Inverts effectiveness
        end
      end
      return finalRet*2
    end
  
    def pbCalcTypeMod(moveTypes,user,target)
      return Effectiveness::NORMAL_EFFECTIVE if !moveTypes
      return Effectiveness::NORMAL_EFFECTIVE if moveTypes.include?(:GROUND) &&
         target.pbHasType?(:FLYING) && target.hasActiveItem?(:IRONBALL)
      # Determine types
      tTypes = target.pbTypes(true)
      tTypes.push(:DARK) if !tTypes.include?(:DARK) && target.hasActiveAbility?(:TWILIGHTSILK)
      # Get effectivenesses
      typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
      if moveTypes.include?(:SHADOW)
        if target.shadowPokemon?
          typeMods[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
        else
          typeMods[0] = Effectiveness::SUPER_EFFECTIVE_ONE
        end
      else
        tTypes.each_with_index do |type,i|
          typeMods[i] = pbCalcTypeModSingle(moveTypes,type,user,target)
        end
      end
      # Multiply all effectivenesses together
      ret = 1
      typeMods.each { |m| ret *= m }
      # Tar Shot
      if target.effects[PBEffects::TarShot] && moveTypes.include?(:FIRE)
        ret *= 2
      end
      # Fairy Tale Field - Last Resort/Paladin
      if $fefieldeffect == 31
        if @id == :LASTRESORT
          ret *= 2
        end
        if user.effects[PBEffects::FairyTaleRoles].include?(6) && (target.pbHasType?(:DARK) ||
           target.pbHasType?(:DRAGON) || target.pbHasType?(:GHOST) || target.pbHasType?(:POISON))
          ret *= 2
        end
      # Bewitched Woods - Mark of the Devil
      elsif $fefieldeffect == 42 && target.effects[PBEffects::BewitchedMark] && moveTypes.include?(:FIRE)
        ret *= 2
      end
      return ret
    end
  
    #=============================================================================
    # Accuracy check
    #=============================================================================
    def pbBaseAccuracy(user,target,types=@calcTypes)
      case $fefieldeffect
      when 1 # Electric Terrain
        if [:THUNDER,:ELECTROWEB,:THUNDERWAVE].include?(@id)
          return 100
        elsif @id == :ZAPCANNON
          return 80
        end
      when 2 # Grassy Field
        if [:GRASSWHISTLE,:INFERNO].include?(@id)
          return 100
        end
      when 3 # Misty Field
        if @id == :SWEETKISS
          return 100
        elsif @id == :SANDATTACK
          return 70
        end
      when 4 # Dark Crystal Cavern
        if @id == :DARKVOID
          return 80
        end
      when 5 # Chess Board
        if [:OUTRAGE,:FRUSTRATION,:RAGE,:DRAGONRAGE,:LASHOUT].include?(@id)
          return 80
        end
      when 6 # Big Top
        if @id == :SING
          return 100
        end
      when 7 # Volcanic Field
        if [:WILLOWISP,:BLASTBURN,:BLUEFLARE,:FIRESPIN,:MAGMASTORM,:OVERHEAT,:SACREDFIRE,:ETERNALFLAME].include?(@id)
          return 100
        elsif @id == :INFERNO
          return 80
        elsif @id == :BLIZZARD
          return 50
        end
      when 8 # Swamp Field
        if [:SLEEPPOWDER,:PHEROMONESIGNAL].include?(@id)
          return 100
        elsif @id == :THUNDERWAVE
          return 50
        end
      when 9 # Rainbow Field
        if [:LOVELYKISS,:SWEETKISS].include?(@id)
          return 100
        end
      when 10 # Corrosive Field
        if [:POISONPOWDER,:TOXIC].include?(@id)
          return 100
        elsif @id == :GRASSWHISTLE
          return 40
        end
      when 11 # Corrosive Mist Field
        if [:TOXIC,:POISONGAS].include?(@id)
          return 100
        end
      when 12 # Desert Field
        if @id == :THUNDERWAVE
          return 100
        elsif [:THUNDER,:HURRICANE].include?(@id)
          return 50
        end
      when 15 # Forest Field
        if @id == :PHEROMONESIGNAL
          return 100
        end
      when 17 # Factory Field
        if @id == :SUPERSONIC
          return 100
        end
      when 18 # Short-Circuit Field
        if @id == :ZAPCANNON
          return 100
        end
      when 19 # Wasteland
        if @id == :GUNKSHOT
          return 100
        end
      when 21 # Water Surface
        if target.grounded? && types.include?(:ELECTRIC)
          return 0
        end
        if @id == :HURRICANE
          return 100
        end
      when 22 # Underwater
        if types.include?(:ELECTRIC)
          return 0
        end
        if @id == :SUPERSONIC
          return 100
        end
      when 23 # Cave
        if [:SUPERSONIC,:POISONGAS,:ROCKBLAST,:ROCKSLIDE,:ROCKTHROW,:ROCKTOMB,:ROCKWRECKER,
           :STONEEDGE].include?(@id)
          return 100
        end
      when 24 # Glitch Field
        if @id == :BLIZZARD
          return 90
        end
      when 26 # Murkwater Surface
        if @id == :TOXIC
          return 100
        end
      when 29 # Holy Field
        if @id == :SING
          return 100
        end
      when 30 # Mirror Arena
        if [:MIRRORSHOT,:MIRRORLAUNCH].include?(@id)
          return 0
        end
      when 31 # Fairy Tale Field
        if [:LOVELYKISS,:SWEETKISS].include?(@id)
          return 100
        end
      when 33 # Flower Garden
        if $fecounter >= 3 && [:SLEEPPOWDER,:STUNSPORE,:POISONPOWDER].include?(@id) ||
           $fecounter >= 1 && @id == :GRASSWHISTLE || $fecounter >= 2 && @id == :PHEROMONESIGNAL
          return 100
        end
      when 34 # Starlight Arena
        if @id == :DARKVOID
          return 80
        end
      when 35 # Ultra Space
        if @id == :DARKVOID
          return 100
        end
      when 37 # Psychic Terrain
        if @id == :HYPNOSIS
          return 90
        end
      when 38 # Dimensional Field
        if [:DARKPULSE,:DARKVOID,:NIGHTDAZE,:NIGHTSLASH].include?(@id)
          return 0
        end
      when 39 # Frozen Dimensional Field
        if [:SING,:BLIZZARD].include?(@id)
          return 100
        end
      when 40 # Haunted
        if [:WILLOWISP,:SWAGGER].include?(@id)
          return 100
        elsif @id == :HYPNOSIS
          return 80
        end
      when 41 # Corrupted Cave
        if @id == :TOXIC
          return 100
        end
      when 42 # Bewitched Woods
        if [:POISONPOWDER,:SLEEPPOWDER,:GRASSWHISTLE,:STUNSPORE,:LOVELYKISS,:WILLOWISP].include?(@id)
          return 95
        end
      when 44 # Indoors
        if [:SMOG,:POISONGAS].include?(@id)
          return 100
        end
      when 45 # Boxing Ring
        if [:POISONGAS,:FLY,:JUMPKICK,:HIGHJUMPKICK,:SKYATTACK,:SKYUPPERCUT,:BOUNCE,
           :DRAGONRUSH,:FLYINGPRESS,:CRIMSONDIVE].include?(@id)
          return 100
        end
      when 46 # Subzero Field
        if @id == :BLIZZARD
          return 100
        end
      when 47 # Jungle
        if @id == :GRASSWHISTLE
          return 80
        elsif [:POISONPOWDER,:SLEEPPOWDER,:STUNSPORE,:PHEROMONESIGNAL].include?(@id)
          return 100
        end
      when 49 # Xeric Shrubland
        if [:THUNDERWAVE,:STUNSPORE,:SLEEPPOWDER,:POISONPOWDER].include?(@id)
          return 100
        elsif @id == :THUNDER
          return 50
        end
      end
      return @accuracy
    end
  
    # Accuracy calculations for one-hit KO moves and "always hit" moves are
    # handled elsewhere.
    def pbAccuracyCheck(user,target)
      # "Always hit" effects and "always hit" accuracy
      return true if target.effects[PBEffects::Telekinesis]>0
      return true if target.effects[PBEffects::Minimize] && tramplesMinimize?(1)
      baseAcc = pbBaseAccuracy(user,target)
      return true if baseAcc==0
      # Calculate all multiplier effects
      modifiers = {}
      modifiers[:base_accuracy]  = baseAcc
      modifiers[:accuracy_stage] = user.stages[:ACCURACY]
      modifiers[:evasion_stage]  = target.stages[:EVASION]
      modifiers[:accuracy_multiplier] = 1.0
      modifiers[:evasion_multiplier]  = 1.0
      pbCalcAccuracyModifiers(user,target,modifiers,@calcTypes,@battle.moldBreaker)
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
      if user.effects[PBEffects::MicleBerry]
        user.effects[PBEffects::MicleBerry] = false
        modifiers[:accuracy_multiplier] *= 1.2
      end
      # Check if move can't miss
      return true if modifiers[:base_accuracy] == 0
      # Calculation
      accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
      evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
      stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
      stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
      accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
      evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
      accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
      evasion  = (evasion  * modifiers[:evasion_multiplier]).round
      evasion = 1 if evasion < 1
      # Calculation
      ret = @battle.pbRandom(100) < modifiers[:base_accuracy] * accuracy / evasion
      user.effects[PBEffects::BlunderPolicy] = true if !ret
      return ret
    end
    
    # Accuracy modifiers that can be calculated in advance
    def pbCalcAccuracyModifiers(user,target,modifiers,types,moldBreaker,aiCalculations=false)
      # Ability effects that alter accuracy calculation
      #BattleHandlers.triggerAccuracyCalcUserAbility(user.ability,modifiers,user,target,self,@calcTypes)
      if user.hasActiveAbility?(:KEENEYE)
        modifiers[:evasion_stage] = 0 if modifiers[:evasion_stage] > 0
      end
      if user.hasActiveAbility?(:COMPOUNDEYES)
        modifiers[:accuracy_multiplier] *= 1.3
      end
      if $fefieldeffect == 44
        if pbContactMove?(user) && !types.include?(:NORMAL)
          modifiers[:accuracy_multiplier] *= 0.9
        end
        if recoilMove? || [:THRASH,:OUTRAGE].include?(@id)
          modifiers[:accuracy_multiplier] *= 2.0/3
        end
      end
      if user.hasActiveAbility?(:HUSTLE)
        if $fefieldeffect == 5
          modifiers[:accuracy_multiplier] *= 0.7
        elsif physicalMove?
          if [13,46].include?($fefieldeffect)
            modifiers[:accuracy_multiplier] *= 0.7
          else
            modifiers[:accuracy_multiplier] *= 0.8
          end
        end
      end
      if user.hasActiveAbility?(:NOGUARD) && $fefieldeffect != 14
        modifiers[:base_accuracy] = 0
      end
      if user.hasActiveAbility?(:INNERFOCUS) && $fefieldeffect == 48
        modifiers[:base_accuracy] = 0
      end
      if user.hasActiveAbility?(:UNSEENFIST) && $fefieldeffect == 4
        modifiers[:base_accuracy] = 0
      end
      if user.hasActiveAbility?(:ILLUMINATE) && [18,42].include?($fefieldeffect)
        modifiers[:base_accuracy] = 0
      end
      if user.hasActiveAbility?(:KEENEYE) && ($fefieldeffect == 15 && user.airborne? ||
         $fefieldeffect == 40 && user.pbHasType?(:GHOST))
        modifiers[:base_accuracy] = 0
      end
      if $fefieldeffect == 20 && focusMove?
        modifiers[:base_accuracy] = 0
      end
      if user.hasActiveAbility?(:SPYGEAR) && user.effects[PBEffects::SpyGear] == 2 # Nictitating Precision
        modifiers[:base_accuracy] = 0
      end
      if user.hasActiveAbility?(:ALPHABETIZATION) && user.checkAlphabetizationForm(5)
        modifiers[:base_accuracy] = 0
      end
      if user.hasActiveAbility?(:UNAWARE) && $fefieldeffect != 1
        modifiers[:evasion_stage] = 0 if damagingMove?
      end
      if user.hasActiveAbility?(:VICTORYSTAR) && ![22,23].include?($fefieldeffect)
        modifiers[:accuracy_multiplier] *= 1.1
      end
      if user.hasActiveAbility?(:INNERFOCUS) && [5,6].include?($fefieldeffect)
        modifiers[:evasion_stage] = 0 if modifiers[:evasion_stage] > 0
      end
      if user.hasActiveAbility?([:OWNTEMPO,:INNERFOCUS,:TELEPATHY,:PUREPOWER,:SANDVEIL,
         :STEADFAST,:STRONGWILL,:VITALICAURA,:MOTIVATION,:ATTENTIVE,:STALWART,:SANDSHIELD]) && 
         $fefieldeffect == 20 && !@battle.pbCheckOpposingAbility([:UNNERVE,:AURABREAK],user.index)
        modifiers[:evasion_stage] = 0
      end
      if user.hasActiveAbility?(:OWNTEMPO) && $fefieldeffect == 30
        modifiers[:evasion_stage] = 0 if modifiers[:evasion_stage] > 0
      end
      if user.hasActiveAbility?(:LONGREACH) && [14,15,42,44,47].include?($fefieldeffect)
        modifiers[:accuracy_multiplier] *= 0.9
      end
      if user.hasActiveAbility?(:SNIPER) && [14,15,42,47].include?($fefieldeffect)
        modifiers[:accuracy_multiplier] *= 0.9
      end
      if user.hasActiveAbility?(:HOMINGCANNON) && beamMove?
        modifiers[:base_accuracy] = 0
      end
      if user.hasActiveAbility?(:SHIFU) && kickingMove?
        modifiers[:base_accuracy] = 0
      end
      user.eachAlly do |b|
        #BattleHandlers.triggerAccuracyCalcUserAllyAbility(b.ability,modifiers,user,target,self,@calcTypes)
        if b.hasActiveAbility?(:VICTORYSTAR) && ![22,23].include?($fefieldeffect)
          modifiers[:accuracy_multiplier] *= 1.1
        end
      end
      if user.hasActiveAbility?(:UNSEENARCHER) && (user.hp == user.totalhp || user.hp >= user.totalhp/2 &&
         [4,15,18,40].include?($fefieldeffect)) && ![12,30].include?($fefieldeffect)
        modifiers[:base_accuracy] = 0
      end
      if user.hasActiveAbility?(:TANGLEDFEET) && $fefieldeffect == 13 && user.effects[PBEffects::Confusion] > 0
        modifiers[:accuracy_multiplier] /= 2
      end
      if user.effects[PBEffects::Confusion] > 0 && ($fefieldeffect == 13 && contactMove? ||
         $fefieldeffect == 30)
        modifiers[:accuracy_multiplier] /= 2
      end
      if user.hasActiveAbility?(:GRACEFULMELODY) && soundMove?(user)
        modifiers[:base_accuracy] = 0
        modifiers[:evasion_stage] *= -1
      end
      if !moldBreaker
        #BattleHandlers.triggerAccuracyCalcTargetAbility(target.ability,modifiers,user,target,self,@calcTypes)
        if target.hasActiveAbility?(:LIGHTNINGROD) && types.include?(:ELECTRIC) && 
           ![15,22,42,47].include?($fefieldeffect)
          modifiers[:base_accuracy] = 0
        end
        if target.hasActiveAbility?(:NOGUARD) && $fefieldeffect != 14
          modifiers[:base_accuracy] = 0
        end
        if target.hasActiveAbility?(:ILLUMINATE) && [18,42].include?($fefieldeffect)
          modifiers[:base_accuracy] = 0
        end
        if target.hasActiveAbility?(:SANDVEIL) && ($fefieldeffect != 8 || target.pbHasType?(:WATER) || 
           target.airborne?) && !([21,26].include?($fefieldeffect) && target.grounded?)
          if @battle.pbWeather == :Sandstorm
            modifiers[:evasion_multiplier] *= 1.25
          end
          if [12,20,48,49].include?($fefieldeffect)
            modifiers[:evasion_multiplier] *= 1.25
          end
        end
        if target.hasActiveAbility?(:SNOWCLOAK) && ![7,16].include?($fefieldeffect)
          if @battle.pbWeather == :Hail
            modifiers[:evasion_multiplier] *= 1.25
          end
          if [13,28,39,46].include?($fefieldeffect)
            modifiers[:evasion_multiplier] *= 1.25
          end
        end
        if target.hasActiveAbility?(:STORMDRAIN) && types.include?(:WATER)
          modifiers[:base_accuracy] = 0
        end
        if target.hasActiveAbility?(:UNAWARE) && damagingMove? && $fefieldeffect != 1
          modifiers[:accuracy_stage] = 0
        end
        if target.hasActiveAbility?(:WONDERSKIN) && statusMove? && user.opposes?(target)
          modifiers[:base_accuracy] /= 2
        end
        if target.hasActiveAbility?(:INNERFOCUS) && $fefieldeffect == 5
          modifiers[:accuracy_stage] = 0
        end
        if target.hasActiveAbility?(:MIRRORARMOR) && $fefieldeffect == 25
          modifiers[:evasion_multiplier] *= 1.5
        end
        if target.hasActiveAbility?(:SHIMMERINGHAZE) && $fefieldeffect != 22
          if [:Sun,:HarshSun].include?(@battle.pbWeather)
            modifiers[:evasion_multiplier] *= 1.25
          end
          if [3,7,12,16,49].include?($fefieldeffect)
            modifiers[:evasion_multiplier] *= 1.25
          end
        end
        if target.hasActiveAbility?(:BEARDEDMAGNETISM) && types.include?(:GROUND)
          modifiers[:base_accuracy] = 0
        end
        if target.hasActiveAbility?(:QUICKFEET) && $fefieldeffect == 45 && target.pbHasAnyStatus?
          modifiers[:evasion_multiplier] *= 1.5
        end
        if target.hasActiveAbility?(:UNSEENARCHER) && (target.hp == target.totalhp ||
           [4,15,18,40,47].include?($fefieldeffect) && target.hp >= target.totalhp/2 ||
           $fefieldeffect == 42) && ![12,30].include?($fefieldeffect)
          modifiers[:evasion_multiplier] *= 2
        end
        if target.hasActiveAbility?(:TANGLEDFEET) && $fefieldeffect != 43
          if target.effects[PBEffects::Confusion] > 0
            modifiers[:accuracy_multiplier] /= 2
          end
          if [6,30,37,47].include?($fefieldeffect)
            modifiers[:accuracy_multiplier] /= 2
          end
        end
      end
      # Item effects that alter accuracy calculation
      if user.itemActive?
        if !(aiCalculations && user.hasActiveItem?(:ZOOMLENS))
          BattleHandlers.triggerAccuracyCalcUserItem(user.item,modifiers,user,target,self,types)
        end
      end
      if target.itemActive?
        BattleHandlers.triggerAccuracyCalcTargetItem(target.item,modifiers,user,target,self,types)
      end
      # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to
      # specific values
      if @battle.field.effects[PBEffects::Gravity] > 0
        modifiers[:accuracy_multiplier] *= 5 / 3.0
      end
      if pbTarget(user).num_targets > 1
        modifiers[:evasion_stage] = 0 if modifiers[:evasion_stage] > 0
        modifiers[:evasion_multiplier] = 1 if modifiers[:evasion_multiplier] > 1
      end
      modifiers[:accuracy_multiplier] *= 0.6 if @battle.pbWeather == :Fog
    end
  
    #=============================================================================
    # Critical hit check
    #=============================================================================
    # Return values:
    #   -1: Never a critical hit.
    #    0: Calculate normally.
    #    1: Always a critical hit.
    def pbCritialOverride(user,target); return 0; end
  
    # Returns whether the move will be a critical hit.
    def pbIsCritical?(user,target)
      # Set up the critical hit ratios
      ratios = (Settings::NEW_CRITICAL_HIT_RATE_MECHANICS) ? [24,8,2,1] : [16,8,4,3,2]
      c = @battle.battleAI.criticalHitRate(self,user,target,@battle.moldBreaker)
      return false if c < 0
      # Other effects
      c = 3 if @accuracy == 0 && target.stages[:EVASION] > 0
      c = ratios.length-1 if c>=ratios.length
      if c == 3 || $fefieldeffect == 5 && chessMove?(user) # Guaranteed Crit
        user.effects[PBEffects::SneakAttack] = false
      end
      # Calculation
      return @battle.pbRandom(ratios[c]) == 0
    end
  
    #=============================================================================
    # Damage calculation
    #=============================================================================
    def pbBaseDamage(baseDmg,user,target);              return baseDmg;    end
    def pbBaseDamageMultiplier(damageMult,user,target); return damageMult; end
    def pbModifyDamage(damageMult,user,target);         return damageMult; end
  
    def pbGetAttackStats(user,target)
      if user.hasActiveAbility?(:STARLIGHTARMOR)
        statValue = user.spdef
        stageValue = user.stages[:SPECIAL_DEFENSE]+6
      else
        if specialMove? && !((user.hasActiveAbility?(:PALINDROME) || target.hasActiveAbility?(:PALINDROME)) &&
           $fefieldeffect != 30) || punchingMove? && user.hasActiveAbility?(:ARMCANNON) || 
           physicalMove? && (user.hasActiveAbility?(:PALINDROME) || target.hasActiveAbility?(:PALINDROME)) &&
           $fefieldeffect != 30 || user.effects[PBEffects::PowerTrance] || piercingMove? &&
           user.hasActiveAbility?(:STINGER)
          if $fefieldeffect == 24
            statValue = [user.spatk,user.spdef].max
            stageValue = [user.stages[:SPECIAL_ATTACK],user.stages[:SPECIAL_DEFENSE]].max+6
          else
            statValue = user.spatk
            stageValue = user.stages[:SPECIAL_ATTACK]+6
          end
        else
          statValue = user.attack
          stageValue = user.stages[:ATTACK]+6
        end
      end
      if $fefieldeffect == 36 && (user.hasActiveAbility?(:PALINDROME) || target.hasActiveAbility?(:PALINDROME))
        stageValue = 12 - stageValue
      end
      return statValue, stageValue
    end
  
    def pbGetDefenseStats(user,target)
      if specialMove? && !((user.hasActiveAbility?(:PALINDROME) || target.hasActiveAbility?(:PALINDROME)) &&
         $fefieldeffect != 30) || punchingMove? && user.hasActiveAbility?(:ARMCANNON) ||
         physicalMove? && (user.hasActiveAbility?(:PALINDROME) || target.hasActiveAbility?(:PALINDROME)) &&
         $fefieldeffect != 30 || piercingMove? && user.hasActiveAbility?(:STINGER)
        if $fefieldeffect == 24
          statValue = [target.spatk,target.spdef].max
          stageValue = [target.stages[:SPECIAL_ATTACK],target.stages[:SPECIAL_DEFENSE]].max+6
        else
          statValue = target.spdef
          stageValue = target.stages[:SPECIAL_DEFENSE]+6
        end
      else
        statValue = target.defense
        stageValue = target.stages[:DEFENSE]+6
      end
      if $fefieldeffect == 36 && (user.hasActiveAbility?(:PALINDROME) || target.hasActiveAbility?(:PALINDROME))
        stageValue = 12 - stageValue
      end
      return statValue, stageValue
    end
  
    def pbCalcDamage(user,target,numTargets=1)
      return if statusMove?
      if target.damageState.disguise || target.damageState.iceface
        target.damageState.calcDamage = 1
        return
      end
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      # Get the move's type
      types = @calcTypes   # nil is treated as physical
      # Conversion 2 + Factory Field
      if target.effects[PBEffects::Conversion2Factory] && damagingMove?
        validTypes = []
        GameData::Type.each do |t|
          next if t.pseudo_type || target.pbHasType?(t.id) || !Effectiveness.resistant_type?(types,t.id)
          validTypes.push(t.id)
        end
        if validTypes.length > 0
          newType = validTypes[@battle.pbRandom(validTypes.length)]
          target.pbChangeTypes(newType)
          typeName = GameData::Type.get(newType).name
          @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
        end
      end
      # Calculate whether this hit deals critical damage
      target.damageState.critical = pbIsCritical?(user,target)
      user.effects[PBEffects::SneakAttack] = false if !target.damageState.critical
      # Calcuate base power of move
      baseDmg = pbBaseDamage(@baseDamage,user,target)
      # Calculate user's attack stat
      atk, atkStage = pbGetAttackStats(user,target)
      if atkStage > 6
        if target.hasActiveAbility?(:BIGPECKS) && physicalMove? || target.hasActiveAbility?(:INNERFOCUS) &&
           $fefieldeffect == 5
          atkStage = 6
        end
        if target.hasActiveAbility?(:DIVINE) && specialMove?
          atkStage = 6
        end
      end
      if !(target.hasActiveAbility?(:UNAWARE) && $fefieldeffect != 1 || target.hasActiveAbility?(:INNERFOCUS) &&
         $fefieldeffect == 5) || @battle.moldBreaker
        atkStage = 6 if target.damageState.critical && atkStage<6
        atk = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
      end
      # Calculate target's defense stat
      defense, defStage = pbGetDefenseStats(user,target)
      if defStage > 6
        if target.hasActiveAbility?(:HYPERCUTTER) && physicalMove? || target.hasActiveAbility?(:EMPYREAN) &&
           specialMove?
          defStage = 6
        end
      end
      if user.hasActiveAbility?(:GRACEFULMELODY) && soundMove?(user)
        defStage = 12 - defStage
      end
      if !(user.hasActiveAbility?(:UNAWARE) && $fefieldeffect != 1 || user.hasActiveAbility?(:INNERFOCUS) &&
         $fefieldeffect == 5)
        defStage = 6 if target.damageState.critical && defStage>6
        defense = (defense.to_f*stageMul[defStage]/stageDiv[defStage]).floor
      end
      # Calculate all multiplier effects
      multipliers = {
        :base_damage_multiplier  => 1.0,
        :attack_multiplier       => 1.0,
        :defense_multiplier      => 1.0,
        :final_damage_multiplier => 1.0
      }
      pbCalcDamageMultipliers(user,target,numTargets,types,baseDmg,multipliers)
      # Main damage calculation
      baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
      atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
      defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
      damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
      damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
      user.effects[PBEffects::Performer] += damage-target.damageState.initialHP if damage > target.damageState.initialHP
      target.damageState.calcDamage = damage
    end
  
    # Global ability multipliers that can be calculated in advance
    def pbCalcGlobalAbilityMultipliers(user,target,types,multipliers)
      auraMult = 1
      if @battle.pbCheckGlobalAbility(:DARKAURA) && types.include?(:DARK) && ![3,9,29,48].include?($fefieldeffect)
        if [4,38].include?($fefieldeffect)
          auraMult *= 1.5
        else
          auraMult *= 4.0/3
        end
      end
      if @battle.pbCheckGlobalAbility(:FAIRYAURA) && types.include?(:FAIRY) && ![11,32,38,40].include?($fefieldeffect)
        if [3,31,34,42].include?($fefieldeffect)
          auraMult *= 1.5
        else
          auraMult *= 4.0/3
        end
      end
      if @battle.pbCheckGlobalAbility(:EARTHENAURA) && types.include?(:GROUND) && 
         ![9,17,21,26,31,35,38,39,43,44].include?($fefieldeffect)
        if [2,12,14,23,33,49].include?($fefieldeffect)
          auraMult *= 1.5
        else
          auraMult *= 4.0/3
        end
      end
      if @battle.pbCheckGlobalAbility(:JUNGLETOTEM) && types.include?(:GRASS) && ![10,12,17,21,22,26,38,39,44].include?($fefieldeffect)
        if [15,42,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter == 4
          auraMult *= 1.5
        else
          auraMult *= 4.0/3
        end
      end
      if @battle.pbCheckGlobalAbility(:VITALICAURA) && types.include?(:FIGHTING) && 
         ![12,17,48,49].include?($fefieldeffect)
        if [6,45].include?($fefieldeffect)
          auraMult *= 1.5
        else
          auraMult *= 4.0/3
        end
      end
      if @battle.pbCheckGlobalAbility(:AQUABOOST) && types.include?(:WATER) && ![7,12,46].include?($fefieldeffect)
        if [21,22,26,48].include?($fefieldeffect)
          auraMult *= 1.5
        else
          auraMult *= 4.0/3
        end
      end
      if @battle.pbCheckGlobalAbility(:ETERNALLIGHT) && types.include?(:ELECTRIC) && 
         ![38,40].include?($fefieldeffect)
        if [9,29,34].include?($fefieldeffect)
          auraMult *= 1.5
        else
          auraMult *= 4.0/3
        end
      end
      if @battle.pbCheckGlobalAbility(:TACTICS) && types.include?(:PSYCHIC)
        if $fefieldeffect == 5
          auraMult *= 1.5
        else
          auraMult *= 4.0/3
        end
      end
      if @battle.pbCheckGlobalAbility(:DEATHWALTZ) && types.include?(:GHOST) && $fefieldeffect != 29
        if $fefieldeffect == 40
          auraMult *= 1.5
        else
          auraMult *= 4.0/3
        end
      end
      if @battle.pbCheckGlobalAbility(:QUEENSDOMAIN)
        for b in @battle.pbCheckGlobalAbility(:QUEENSDOMAIN)
          if target.sharesType?(b) && !user.sharesType?(b)
            multipliers[:final_damage_multiplier] *= 0.5
          end
        end
      end
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 1/auraMult
      else
        multipliers[:base_damage_multiplier] *= auraMult
      end
      if @battle.pbCheckGlobalAbility(:BRUTALITY) && user.pbHasAnyStatus?
        multipliers[:base_damage_multiplier] *= 0.75
      end
    end
    
    def pbCalcUserAbilityMultipliers(user,target,types,multipliers,baseDmg)
      if user.hasActiveAbility?(:IRONFIST) && punchingMove?
        if $fefieldeffect == 45
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.2
        end
      end
      if user.hasActiveAbility?(:MEGALAUNCHER) && pulseMove?
        if $fefieldeffect == 43
          multipliers[:base_damage_multiplier] *= 2
        else
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:RECKLESS) && recoilMove?
        if $fefieldeffect == 45
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.2
        end
      end
      if bitingMove?
        if user.hasActiveAbility?(:STRONGJAW)
          if $fefieldeffect == 45
            multipliers[:base_damage_multiplier] *= 2
          else
            multipliers[:base_damage_multiplier] *= 1.5
          end
        end
        if user.hasActiveAbility?(:UNYIELDINGFANG) && $fefieldeffect == 45
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:TOUGHCLAWS) && contactMove?
        if $fefieldeffect == 45
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 4 / 3.0
        end
      end
      if user.hasActiveAbility?(:PUNKROCK) && soundMove?(user) && ![29,39].include?($fefieldeffect)
        if [1,6].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:RIVALRY)
        if user.gender!=2 && target.gender!=2
          if user.gender==target.gender || $fefieldeffect == 5
            if $fefieldeffect == 45
              multipliers[:base_damage_multiplier] *= 1.5
            else
              multipliers[:base_damage_multiplier] *= 1.25
            end
          else
            if $fefieldeffect == 45
              multipliers[:base_damage_multiplier] *= 0.75
            else
              multipliers[:base_damage_multiplier] *= 2.0/3
            end
          end
        end
      end
      if user.hasActiveAbility?(:SHEERFORCE) && @addlEffect > 0
        if $fefieldeffect == 45
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:STEELWORKER) && types.include?(:STEEL) && $fefieldeffect != 7 &&
         !($fefieldeffect == 10 && user.grounded?)
        if $fefieldeffect == 17
          multipliers[:base_damage_multiplier] *= 2
        else
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:STEELYSPIRIT) && types.include?(:STEEL) && $fefieldeffect != 7 &&
         !($fefieldeffect == 10 && user.grounded?)
        if $fefieldeffect == 17
          multipliers[:base_damage_multiplier] *= 2
        else
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:DRAGONSMAW) && types.include?(:DRAGON)
        if [32,45].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 2
        else
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:TRANSISTOR) && types.include?(:ELECTRIC) && $fefieldeffect != 18 &&
         !($fefieldeffect == 8 && user.grounded?)
        if [1,17].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 2
        else
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:TECHNICIAN) && user.index != target.index && @id != :STRUGGLE
        if baseDmg <= 60
          if [18,44].include?($fefieldeffect)
            multipliers[:base_damage_multiplier] *= 2
          else
            multipliers[:base_damage_multiplier] *= 1.5
          end
        elsif $fefieldeffect == 17 && baseDmg <= 80
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:WATERBUBBLE) && types.include?(:WATER) && ![7,12,49].include?($fefieldeffect)
        multipliers[:base_damage_multiplier] *= 2
      end
      if user.hasActiveAbility?(:STALWART) && $fefieldeffect == 29
        multipliers[:final_damage_multiplier] *= 2
      end
      if user.hasActiveAbility?(:PUREPOWER) && $fefieldeffect == 29 && (types.include?(:NORMAL) ||
         types.include?(:PSYCHIC) || types.include?(:FAIRY))
        multipliers[:final_damage_multiplier] *= 2
      end
      if user.hasActiveAbility?(:MAGMAARMOR) && $fefieldeffect == 2 && types.include?(:FIRE) &&
         user.grounded?
        multipliers[:final_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:LONGREACH) && [16,27,28].include?($fefieldeffect)
        multipliers[:final_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?([:QUEENLYMAJESTY,:STRONGWILL]) && $fefieldeffect == 31
        multipliers[:final_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?([:SKILLLINK,:PROPELLERTAIL]) && $fefieldeffect == 17 &&
         user.index != target.index && baseDmg <= 40
        multipliers[:base_damage_multiplier] *= 1.5
      end
      if $fefieldeffect == 45 && pbContactMove?(user)
        quotient = (user.pokemon.height/target.pokemon.height)
        quotient = 1.5 if quotient > 1.5
        quotient = 0.75 if quotient < 0.75
        quotient = 1.5 if user.hasActiveAbility?(:HUGEPOWER)
        multipliers[:base_damage_multiplier] *= quotient
      end
      if user.hasActiveAbility?(:DANCER) && $fefieldeffect == 30 && danceMove?
        multipliers[:final_damage_multiplier] *= 1.3
      end
      if user.hasActiveAbility?(:TRIAGE) && healingMove?
        if [3,9].include?($fefieldeffect)
          multipliers[:final_damage_multiplier] *= 1.3
        elsif $fefieldeffect == 29
          multipliers[:final_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:ROCKHEAD) && [14,23].include?($fefieldeffect) && 
         recoilMove?
        multipliers[:final_damage_multiplier] *= 1.3
      end
      if user.hasActiveAbility?(:EARLYBIRD) && [15,47].include?($fefieldeffect) && 
         soundMove?(user)
        multipliers[:final_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:FLAMEBODY) && $fefieldeffect == 15 && types.include?(:FIRE)
        multipliers[:final_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:FORECAST) && user.form > 0 && [9,43].include?($fefieldeffect)
        multipliers[:final_damage_multiplier] *= 2
      end
      if user.hasActiveAbility?(:SERENEGRACE) && @addlEffect > 0 && $fefieldeffect == 3
        multipliers[:final_damage_multiplier] *= 1.2
      end
      if user.hasActiveAbility?(:BATTERY) && specialMove? && $fefieldeffect == 18
        multipliers[:final_damage_multiplier] *= 1.3
      end
      if user.hasActiveAbility?(:CORROSION) && ($fefieldeffect == 41 && types.include?(:POISON) ||
         [10,11].include?($fefieldeffect))
        multipliers[:attack_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:THRUST) && pbContactMove?(user) && ($fefieldeffect == 45 || 
         $fefieldeffect == 5 && $fecounter%6 == 3) # Knight
        multipliers[:base_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:LASTBULLETS)
        multiplier = (1-1.0*@pp/total_pp)/2
        multiplier *= 2 if $fefieldeffect == 32
        multipliers[:final_damage_multiplier] *= 1 + multiplier
      end
      if user.hasActiveAbility?(:UNRULY) && ![20,48].include?($fefieldeffect)
        if [39,45,47].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:MOONCALLER) && types.include?(:FAIRY) && $fefieldeffect != 38
        multipliers[:base_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:ALPHABETIZATION)
        if user.checkAlphabetizationForm(1)
          multipliers[:final_damage_multiplier] *= 2
        elsif user.checkAlphabetizationForm(2) && target.hp < target.totalhp
          multipliers[:attack_multiplier] *= 2
        end
      end
      if user.hasActiveAbility?(:ICEBERGTITAN) && types.include?(:ICE) && ![7,12,16,49].include?($fefieldeffect)
        if [28,39,46].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:SANDFORCE) && (types.include?(:ROCK) || types.include?(:GROUND) || 
         types.include?(:STEEL)) && !([8,21,26].include?($fefieldeffect) && user.grounded?)
        if @battle.pbWeather == :Sandstorm
          multipliers[:base_damage_multiplier] *= 1.3
        end
        if [12,20,48,49].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:FROSTBLESSING) && types.include?(:ICE)
        if @battle.pbWeather == :Hail
          multipliers[:base_damage_multiplier] *= 1.5
        end
        if [13,28,39,46].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:SERPENTINEINTERVENTION) && types.include?(:DRAGON)
        if [:Sun,:HarshSun,:Rain,:HeavyRain].include?(@battle.pbWeather) || $fefieldeffect == 43 &&
           @battle.pbWeather == :StrongWinds
          multipliers[:base_damage_multiplier] *= 1.3
        end
        if [29,35].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:MARACAMOVEMENT) && danceMove? && $fefieldeffect != 22
        multipliers[:base_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:ROCKPEAKTITAN) && types.include?(:ROCK)
        multipliers[:base_damage_multiplier] *= 1.3
      end
      if user.hasActiveAbility?(:IRONTITAN) && types.include?(:STEEL)
        multipliers[:base_damage_multiplier] *= 1.3
      end
      if user.hasActiveAbility?(:COLOSSALTITAN) && types.include?(:NORMAL)
        multipliers[:base_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:ELECTRONTITAN) && types.include?(:ELECTRIC)
        multipliers[:base_damage_multiplier] *= 1.3
      end
      if user.hasActiveAbility?(:DRAGONORBTITAN) && types.include?(:DRAGON)
        multipliers[:base_damage_multiplier] *= 1.3
      end
      if user.hasActiveAbility?(:WAVERIDER) && types.include?(:WATER)
        if [:Rain,:HeavyRain].include?(@battle.pbWeather)
          multipliers[:base_damage_multiplier] *= 1.3
        end
        if [20,48].include?($fefieldeffect) || [21,26].include?($fefieldeffect) && 
           user.grounded?
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:SEASONALHEART) && ![35,38,39].include?($fefieldeffect)
        sType = :NORMAL
        case user.form
        when 0 # Spring
          sType = :BUG
        when 1 # Summer
          sType = :FIRE
        when 2 # Autumn
          sType = :FLYING
        when 3 # Winter
          sType = :ICE
        end
        if types.include?(sType)
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if $fefieldeffect == 33 && user.hasActiveAbility?(:SCARECROW) && target.pbHasType?(:FLYING)
        multipliers[:base_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:ANALYTIC) && (@battle.choices[target.index][0]!=:UseMove &&
         @battle.choices[target.index][0]!=:Shift || target.movedThisRound?)
        if [17,44].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:BLAZE) && types.include?(:FIRE) && (user.hp <= user.totalhp / 3 ||
         $fefieldeffect == 7) && ![22,35,39].include?($fefieldeffect) && !([8,21,26].include?($fefieldeffect) && 
         user.grounded?)
        if $fefieldeffect == 16
          multipliers[:attack_multiplier] *= 2
        else
          multipliers[:attack_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:OVERGROW) && ![12,44,46].include?($fefieldeffect)
        if $fefieldeffect == 10 # Doesn't work with Grass
          if types.include?(:POISON) && user.hp <= user.totalhp / 3
            multipliers[:attack_multiplier] *= 1.5
          end
        elsif types.include?(:GRASS)
          if $fefieldeffect == 33
            case $fecounter
            when 1
              multipliers[:attack_multiplier] *= 1.5 if user.hp <= user.totalhp*2/3
            when 2,3
              multipliers[:attack_multiplier] *= 1.5
            when 4,5
              multipliers[:attack_multiplier] *= 2
            end
          elsif $fefieldeffect == 22
            multipliers[:attack_multiplier] *= 2
          elsif [2,15,42,47].include?($fefieldeffect) || user.hp <= user.totalhp / 3
            multipliers[:attack_multiplier] *= 1.5
          end
        elsif types.include?(:POISON) && $fefieldeffect == 19 && user.hp <= user.totalhp / 3
          multipliers[:attack_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:SWARM) && types.include?(:BUG)
        if $fefieldeffect == 33
          case $fecounter
          when 0,1
            multipliers[:attack_multiplier] *= 1.5
          else
            multipliers[:attack_multiplier] *= 2
          end
        elsif user.hp <= user.totalhp / 3 || [15,47].include?($fefieldeffect)
          if $fefieldeffect == 44
            multipliers[:attack_multiplier] *= 2
          else
            multipliers[:attack_multiplier] *= 1.5
          end
        end
      end
      if user.hasActiveAbility?(:TORRENT) && ![7,12].include?($fefieldeffect)
        if types.include?(:WATER)
          if user.hp <= user.totalhp / 3 || [21,22,26].include?($fefieldeffect)
            if [3,8].include?($fefieldeffect)
              multipliers[:attack_multiplier] *= 2
            else
              multipliers[:attack_multiplier] *= 1.5
            end
          end
        elsif types.include?(:POISON) && $fefieldeffect == 26
          multipliers[:attack_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:FLAREBOOST) && specialMove? && ![22,39,46].include?($fefieldeffect) &&
         !($fefieldeffect == 21 && user.grounded?)
        if user.burned?
          multipliers[:base_damage_multiplier] *= 1.5
        end
        if $fefieldeffect == 7
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:TOXICBOOST) && physicalMove?
        if user.poisoned?
          multipliers[:base_damage_multiplier] *= 1.5
        end
        if [10,19,26,41].include?($fefieldeffect) && user.grounded? || $fefieldeffect == 11
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.effects[PBEffects::FlashFire] && types.include?(:FIRE) && $fefieldeffect != 39
        if $fefieldeffect == 16
          multipliers[:attack_multiplier] *= 2
        else
          multipliers[:attack_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:ALARM) && soundMove?(user) && user.hp <= user.totalhp / 3 &&
         $fefieldeffect != 22
        if $fefieldeffect == 17
          multipliers[:attack_multiplier] *= 2.5
        else
          multipliers[:attack_multiplier] *= 2
        end
      end
      if user.hasActiveAbility?(:AWAKEN) && types.include?(:PSYCHIC) && ![31,40,42,48].include?($fefieldeffect)
        if user.hp <= user.totalhp / 3 || [1,20,37].include?($fefieldeffect)
          if [32,34].include?($fefieldeffect)
            multipliers[:attack_multiplier] *= 2
          else
            multipliers[:attack_multiplier] *= 1.5
          end
        end
      end
      if user.hasActiveAbility?(:BLIGHT) && types.include?(:POISON) && ![3,9,29].include?($fefieldeffect)
        if user.hp <= user.totalhp / 3 || [10,11,19].include?($fefieldeffect)
          if [2,33].include?($fefieldeffect)
            multipliers[:attack_multiplier] *= 2
          else
            multipliers[:attack_multiplier] *= 1.5
          end
        end
      end
      if user.hasActiveAbility?(:CRUSHER) && user.hp > target.hp
        if [17,45].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:DWINDLINGFLAME) && types.include?(:FIRE)
        tier = 1
        if user.hp == user.totalhp
          tier = 3
        elsif user.hp > user.totalhp*2/3
          tier = 2
        elsif user.hp < user.totalhp/3
          tier = 0
        end
        if [3,13,39,46].include?($fefieldeffect) || $fefieldeffect == 8 && user.grounded?
          tier -= 1
        elsif $fefieldeffect == 7
          tier = 3
        elsif $fefieldeffect == 16
          tier += 1
        elsif [21,26].include?($fefieldeffect) && user.grounded? || $fefieldeffect == 22
          tier = 0
        end
        if tier > 3
          multipliers[:attack_multiplier] *= 2
        elsif tier == 3
          multipliers[:attack_multiplier] *= 1.5
        elsif tier == 2
          multipliers[:attack_multiplier] *= 1.2
        elsif tier == 0
          multipliers[:attack_multiplier] *= 0.5
        else # tier < 0
          multipliers[:attack_multiplier] *= 0.3
        end # Tier 1 (1/3 to 2/3 HP) is normal damage
      end
      if user.hasActiveAbility?(:REGALITY)
        if user.hp <= target.hp || $fefieldeffect == 5
          multipliers[:attack_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:BLASTER) && bombMove?
        multipliers[:base_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:BLADE) && slashingMove?
        multipliers[:base_damage_multiplier] *= 1.2
      end
    end
    
    # User ally ability multipliers that can be calculated in advance
    def pbCalcUserAllyAbilityMultipliers(user,target,types,multipliers)
      user.eachAlly do |b|
        #BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,user,target,self,multipliers,baseDmg,types)
        # User Ally Ability
        if b.hasActiveAbility?(:BATTERY) && specialMove? && $fefieldeffect != 41 &&
           !($fefieldeffect == 10 && b.grounded?)
          if [1,17,25].include?($fefieldeffect)
            multipliers[:final_damage_multiplier] *= 1.5
          else
            multipliers[:final_damage_multiplier] *= 1.3
          end
        end
        if b.hasActiveAbility?(:POWERSPOT) && ![35,38,39].include?($fefieldeffect)
          if [9,29,34,42].include?($fefieldeffect)
            multipliers[:final_damage_multiplier] *= 1.5
          else
            multipliers[:final_damage_multiplier] *= 1.3
          end
        end
        if b.hasActiveAbility?(:STEELYSPIRIT) && $fefieldeffect != 7 &&
           !($fefieldeffect == 10 && b.grounded?) && types.include?(:STEEL)
          if $fefieldeffect == 17
            multipliers[:base_damage_multiplier] *= 2
          else
            multipliers[:base_damage_multiplier] *= 1.5
          end
        end
        if b.hasActiveAbility?(:INSPIRE) && $fefieldeffect != 40
          if $fefieldeffect == 29
            if specialMove?
              multipliers[:final_damage_multiplier] *= 1.3
            end
          elsif physicalMove? || $fefieldeffect == 31
            if [6,9,17,20].include?($fefieldeffect)
              multipliers[:final_damage_multiplier] *= 1.5
            else
              multipliers[:final_damage_multiplier] *= 1.3
            end
          end
        end
        if b.hasActiveAbility?(:ALPHABETIZATION) && b.checkAlphabetizationForm(7)
          multipliers[:attack_multiplier] *= 2
        end
        if b.hasActiveAbility?(:PACKMENTALITY) && b.sharesType?(user,true)
          multipliers[:base_damage_multiplier] *= 1.2
        end
      end
    end
    
    # Target ability multipliers that can be calculated in advance
    def pbCalcTargetAbilityMultipliers(user,target,types,multipliers)
      if target.hasActiveAbility?(:DRYSKIN) && types.include?(:FIRE)
        multipliers[:base_damage_multiplier] *= 1.25
      end
      if target.hasActiveAbility?(:FLUFFY) && !([8,21,26].include?($fefieldeffect) && 
         target.grounded?) && $fefieldeffect != 22
        multipliers[:final_damage_multiplier] *= 2 if types.include?(:FIRE)
        multipliers[:final_damage_multiplier] /= 2 if contactMove?
      end
      if target.hasActiveAbility?(:ICESCALES) && (specialMove? || $fefieldeffect == 13) &&
         ![7,16].include?($fefieldeffect)
        if $fefieldeffect == 39
          multipliers[:final_damage_multiplier] /= 3
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
      if target.hasActiveAbility?(:HEATPROOF) && types.include?(:FIRE)
        multipliers[:base_damage_multiplier] /= 2
      end
      if target.hasActiveAbility?(:THICKFAT) && (types.include?(:FIRE) || types.include?(:ICE))
        multipliers[:base_damage_multiplier] /= 2
      end
      if target.hasActiveAbility?(:WATERBUBBLE) && types.include?(:FIRE) && 
         ![7,12,49].include?($fefieldeffect)
        multipliers[:final_damage_multiplier] /= 2
      end
      if target.hasActiveAbility?(:PUNKROCK) && soundMove?(user) && ![29,39].include?($fefieldeffect)
        multipliers[:final_damage_multiplier] /= 2
      end
      if target.hasActiveAbility?(:FLOWERVEIL) && $fefieldeffect == 33 && $fecounter >= 2
        multipliers[:final_damage_multiplier] *= 0.5
      end
      if target.hasActiveAbility?(:INVISIBLEWALL) && !($fefieldeffect == 8 && target.grounded?)
        multipliers[:final_damage_multiplier] *= 0.5
      end
      if target.hasActiveAbility?(:TOUGHBARK) && (types.include?(:ICE) || types.include?(:FLYING) ||
         types.include?(:POISON)) && !($fefieldeffect == 10 && target.grounded?)
        multipliers[:base_damage_multiplier] /= 2
        if $fefieldeffect == 42
          multipliers[:defense_multiplier] *= 1.5
        elsif $fefieldeffect == 47 && physicalMove?
          multipliers[:defense_multiplier] *= 2
        end
      end
      if target.hasActiveAbility?(:UNRULY) && ![20,48].include?($fefieldeffect)
        if [39,45,47].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if target.hasActiveAbility?(:ALPHABETIZATION) && target.checkAlphabetizationForm(1)
        multipliers[:final_damage_multiplier] *= 0.5
      end
      if target.hasActiveAbility?(:DRAGONORBTITAN)
        multipliers[:base_damage_multiplier] *= 0.8
      end
      if target.hasActiveAbility?(:BONEARMOR) && physicalMove?
        multipliers[:final_damage_multiplier] *= 0.8
      end
      if target.hasActiveAbility?(:MULTISCALE) && (target.hp == target.totalhp || 
         $fefieldeffect == 31)
        multipliers[:final_damage_multiplier] /= 2
      end
      if target.hasActiveAbility?(:TACTICALPLUMAGE) && (types.include?(:ICE) || windMove?)
        multipliers[:base_damage_multiplier] /= 2
      end
    end
    
    # Target ally ability multipliers that can be calculated in advance
    def pbCalcTargetAllyAbilityMultipliers(user,target,types,multipliers)
      target.eachAlly do |b|
        if b.hasActiveAbility?(:FRIENDGUARD)
          if $fefieldeffect == 31
            multipliers[:final_damage_multiplier] *= 0.5
          else
            multipliers[:final_damage_multiplier] *= 0.75
          end
        end
        if b.hasActiveAbility?(:FLOWERVEIL) && $fefieldeffect == 33 && (target.pbHasType?(:GRASS) ||
           $fecounter >= 3) && $fecounter >= 2
          multipliers[:final_damage_multiplier] *= 0.5
        end
        if b.hasActiveAbility?(:PACKMENTALITY) && b.sharesType?(target,true)
          multipliers[:base_damage_multiplier] *= 0.8
        end
      end
    end
    
    # Non-ignorable target ability multipliers that can be calculated in advance
    def pbCalcTargetAbilityNonIgnorableMultipliers(user,target,types,multipliers)
      if target.hasActiveAbility?(:SHADOWSHIELD) && ![12,29,48].include?($fefieldeffect)
        if target.hp == target.totalhp || [18,38,40].include?($fefieldeffect)
          if $fefieldeffect == 42
            multipliers[:final_damage_multiplier] /= 2
          else
            multipliers[:final_damage_multiplier] /= 4
          end
        end
        if [4,34,35,38].include?($fefieldeffect)
          multipliers[:defense_multiplier] *= 2
        end
      end
    end
    
    # General multipliers that can be calculated in advance
    def pbCalcGeneralMultipliers(user,target,types,multipliers,moldBreaker)
      # Other
      if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
        if $fefieldeffect == 31
          multipliers[:base_damage_multiplier] *= 2
        else
          multipliers[:base_damage_multiplier] *= 1.5
        end
      end
      if user.effects[PBEffects::Charge]>0 && types.include?(:ELECTRIC)
        multipliers[:base_damage_multiplier] *= 2
      end
      if user.effects[PBEffects::VictoryDance]
        multipliers[:base_damage_multiplier] *= 1.5
      end
      if physicalMove?
        multipliers[:attack_multiplier] *= user.pbAttackMult(moldBreaker)
        multipliers[:defense_multiplier] *= target.pbDefenseMult(moldBreaker)
      else
        multipliers[:attack_multiplier] *= user.pbSpAtkMult(moldBreaker)
        multipliers[:defense_multiplier] *= target.pbSpDefMult(moldBreaker)
      end
      # Mud Sport
      if types.include?(:ELECTRIC)
        @battle.eachBattler do |b|
          next if !b.effects[PBEffects::MudSport]
          multipliers[:base_damage_multiplier] /= 3
          break
        end
        if @battle.field.effects[PBEffects::MudSportField]>0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
      # Water Sport
      if types.include?(:FIRE)
        @battle.eachBattler do |b|
          next if !b.effects[PBEffects::WaterSport]
          multipliers[:base_damage_multiplier] /= 3
          break
        end
        if @battle.field.effects[PBEffects::WaterSportField]>0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
      # Badge multipliers
      if @battle.internalBattle
        if user.pbOwnedByPlayer?
          if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_ATTACK
            multipliers[:attack_multiplier] *= 1.1
          elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPATK
            multipliers[:attack_multiplier] *= 1.1
          end
        end
        if target.pbOwnedByPlayer?
          if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
            multipliers[:defense_multiplier] *= 1.1
          elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
            multipliers[:defense_multiplier] *= 1.1
          end
        end
      end
      # Weather
      case @battle.pbWeather
      when :Sun, :HarshSun
        if types.include?(:FIRE)
          multipliers[:final_damage_multiplier] *= 1.5 if !target.hasUtilityUmbrella?
        end
        if types.include?(:WATER)
          multipliers[:final_damage_multiplier] /= 2 if !target.hasUtilityUmbrella?
        end
      when :Rain, :HeavyRain
        if types.include?(:FIRE)
          multipliers[:final_damage_multiplier] /= 2 if !target.hasUtilityUmbrella?
        end
        if types.include?(:WATER)
          multipliers[:final_damage_multiplier] *= 1.5 if !target.hasUtilityUmbrella?
        end
      when :Sandstorm
        if target.pbHasType?(:ROCK) && specialMove?
          multipliers[:defense_multiplier] *= 1.5
        end
      end
      # STAB
      stab=false
      if types
        for t in types
          if user.pbHasType?(t) || t == :DARK && user.hasActiveAbility?(:TWILIGHTSILK)
            stab=true
            break
          end
        end
      end
      if stab
        if user.hasActiveAbility?(:ADAPTABILITY)
          if [12,46,49].include?($fefieldeffect)
            multipliers[:final_damage_multiplier] *= 2.5
          else
            multipliers[:final_damage_multiplier] *= 2
          end
        elsif $fefieldeffect != 35
          multipliers[:final_damage_multiplier] *= 1.5
        end
      end
      # Burn
      if user.status == :BURN && physicalMove? && damageReducedByBurn? && !user.hasActiveAbility?(:GUTS)
        multipliers[:final_damage_multiplier] /= 2
      end
      # Minimize
      if target.effects[PBEffects::Minimize] && tramplesMinimize?(2)
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    
    # Field Effect multipliers that can be calculated in advance
    def pbCalcFieldMultipliers(user,target,types,multipliers,showMessages)
      case $fefieldeffect
      when 1 # Electric Terrain
        if [:EXPLOSION,:SELFDESTRUCT,:ENERGYBALL,:PSYSHOCK,:VENOSHOCK,:THUNDEROUSKICK,
           :TURBODRIVE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The attack was hyper-charged with electricity!")) if showMessages
        elsif [:HURRICANE,:SURF,:BUBBLE,:TSUNAMI].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The attack picked up electricity!")) if showMessages
        elsif id == :MAGNETBOMB
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The Electric Terrain increased the velocity of the attack!")) if showMessages
        end
        if types[0] == :ELECTRIC
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The electricity charged the attack!")) if showMessages
        elsif types[0] == :GROUND
          multipliers[:base_damage_multiplier] *= 0.8
          @battle.pbDisplay(_INTL("The electricity snuffed out the attack!")) if showMessages
        end
      when 2 # Grassy Terrain
        if [:MUDDYWATER,:SURF,:EARTHQUAKE,:MAGNITUDE,:BULLDOZE,:DIG,:TSUNAMI,:STEAMROLLER].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.8
          @battle.pbDisplay(_INTL("The grass softened the attack...")) if showMessages
        elsif [:CUT,:SLASH,:FURYCUTTER,:ROYALBLADES,:NIGHTSLASH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The attack sliced right through the blades of grass!")) if showMessages
        elsif [:SILVERWIND,:FAIRYWIND,:DAZZLINGGLEAM,:SPARKLINGARIA].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The gleaming blades of grass strengthened the attack!")) if showMessages
        elsif [:NATURALGIFT,:EARTHPOWER,:GRASSKNOT].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The fertile ground strengthened the attack!")) if showMessages
        elsif [:POLLENPUFF,:FLEURCANNON].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The flowers strengthened the attack!")) if showMessages
        end
        if types[0] == :GRASS && user.grounded?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The grass strengthened the attack!")) if showMessages
        elsif types[0] == :FIRE && target.grounded?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The grass below {1} caught flame!",target.pbThis(true))) if showMessages
        end
      when 3 # Misty Terrain
        if [:MISTBALL,:STEAMERUPTION,:BUBBLE,:BUBBLEBEAM,:OCTAZOOKA,:STRANGESTEAM,
           :MISTSLASH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The mist amplified the attack!")) if showMessages
        elsif [:ABSORB,:MEGADRAIN,:GIGADRAIN,:SWIFT,:FAIRYWIND,:SPARKLINGARIA,:OCEANICOPERETTA].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The mist was infused with the attack!")) if showMessages
        elsif [:SHADOWBALL,:SANDTOMB,:NIGHTSLASH,:OMINOUSWIND,:DRAGONASCENT,:SCORCHINGSANDS,
              :DESPAIRRAY,:BITTERMALICE,:INFERNALPARADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The mist softened the attack...")) if showMessages
        end
        if specialMove? && target.pbHasType?(:FAIRY)
          multipliers[:defense_multiplier] *= 1.5
        end
        if specialMove? && [:DRAGON,:DARK].include?(types[0])
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The mist's energy weakened the attack!")) if showMessages
        elsif types[0] == :FAIRY
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The mist's energy strengthened the attack!")) if showMessages
        elsif types[0] == :FIRE
          multipliers[:base_damage_multiplier] *= 0.7
          @battle.pbDisplay(_INTL("The mist weakened the attack!")) if showMessages
        end  
      when 4 # Dark Crystal Cavern
        if [:DARKPULSE,:NIGHTDAZE,:NIGHTSLASH,:SHADOWBALL,:SHADOWPUNCH,:SHADOWCLAW,
           :SHADOWSNEAK,:SHADOWFORCE,:SHADOWBONE,:OMINOUSWIND,:DARKESTLARIAT,:ABSORBVITALITY,
           :BLACKHOLEECLIPSE,:MENACINGMOONRAZEMAELSTROM].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The darkness strengthened the attack!")) if showMessages
        elsif [:AURORABEAM,:SIGNALBEAM,:FLASHCANNON,:LUSTERPURGE,:DAZZLINGGLEAM,:MIRRORSHOT,
              :POWERGEM,:MOONGEISTBEAM,:STONEEDGE,:CHARGEBEAM,:DIAMONDSTORM,:LIGHTOFRUIN,
              :PHOTONGEYSER,:GOLDRUSH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The crystals' luster strengthened the attack!")) if showMessages
        elsif @id == :PRISMATICLASER
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The crystals split the attack!")) if showMessages
        elsif @id == :LIGHTTHATBURNSTHESKY
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The crystals are devoid of light...")) if showMessages
        end      
      when 5 # Chess Board
        if [:FEINT,:FEINTATTACK,:FAKEOUT,:DIG,:QUICKATTACK,:ASTONISH,:SHADOWSNEAK,
           :SMARTSTRIKE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("En passant!")) if showMessages
        elsif [:ROCKSMASH,:METEORMASH,:BRICKBREAK,:ROCKWRECKER,:CRUSHGRIP].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("A chess piece was destroyed!")) if showMessages
        end
        if target.opposes?(user)
          if $fecounter%6 == 4 || @battle.field.effects[PBEffects::PrevFECounter]%6 == 4 &&
             user.hasActiveAbility?(:SKILLLINK) # Bishop
            if target == user.pbDirectOpposing
              multipliers[:base_damage_multiplier] *= 0.5
              @battle.pbDisplay(_INTL("The bishop can't attack straight ahead...")) if showMessages
            else
              multipliers[:base_damage_multiplier] *= 1.5
              @battle.pbDisplay(_INTL("The bishop powers up diagonal attacks!")) if showMessages
            end
          end
          if $fecounter%6 == 5 || @battle.field.effects[PBEffects::PrevFECounter]%6 == 5 &&
             user.hasActiveAbility?(:SKILLLINK) # Rook
            if target == user.pbDirectOpposing
              multipliers[:base_damage_multiplier] *= 1.5
              @battle.pbDisplay(_INTL("The rook powers up attacks straight ahead!")) if showMessages
            else
              multipliers[:base_damage_multiplier] *= 0.5
              @battle.pbDisplay(_INTL("The rook can't attack diagonally...")) if showMessages
            end
          end
        end
        if chessMove?(user)
          multipliers[:base_damage_multiplier] *= 1.5
          if target.hasActiveAbility?([:ADAPTABILITY,:ANTICIPATION,:SYNCHRONIZE,:TELEPATHY,
             :ATTENTIVE])
            multipliers[:base_damage_multiplier] *= 0.5
          end
          if target.hasActiveAbility?([:OBLIVIOUS,:KLUTZ,:UNAWARE,:SIMPLE,:COMATOSE]) || 
             target.effects[PBEffects::Confusion]>0 || target.effects[PBEffects::Attract]>-1
            multipliers[:base_damage_multiplier] *= 2
          end
          @battle.pbDisplay(_INTL("The chess piece slammed forward!")) if showMessages
          if user.hasActiveAbility?(:JUSTIFIED)
            user.pbRaiseStatStageByAbility(:ATTACK,1,user)
          end
        elsif damagingMove? && (@type == :NORMAL && $fecounter >= 6 || @type == :DARK && 
              $fecounter < 6)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The chess piece won't budge!")) if showMessages
          if user.hasActiveAbility?(:JUSTIFIED)
            user.pbLowerStatStageByAbility(:ATTACK,1,user)
          end
        end
      when 6 # Performance Stage
        if [:PAYDAY,:PRESENT].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("And a little extra for you, darling!")) if showMessages
        elsif [:FLY,:ACROBATICS,:HIGHJUMPKICK,:SKYUPPERCUT,:AERIALACE,:BRAVEBIRD,:FLYINGPRESS,
              :DRAGONASCENT,:GALEBLADE,:SUPERSONICSKYSTRIKE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("An extravagant aerial finish!")) if showMessages
        elsif @id == :FIRSTIMPRESSION
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("And what an entrance it was!")) if showMessages
        elsif [:FLAMETHROWER,:VITALTHROW,:SNIPESHOT,:PYROBALL,:CRIMSONDIVE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("A dangerous act performed to perfection!")) if showMessages
        elsif [:AURORABEAM,:SWIFT,:SEEDFLARE,:FLAMEBURST,:HEARTSTAMP,:BLUEFLARE,:MYSTICALFIRE,
              :SPARKLINGARIA,:TRIPLEAXEL,:OCEANICOPERETTA,:INFERNALPARADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("With stunning beauty!")) if showMessages
        end
        if soundMove?(user)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Loud and clear!")) if showMessages
        end
        if danceMove?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("What grace!")) if showMessages
        end
      when 7 # Volcanic Field
        if @id == :SMOG
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The flames ignited the attack!")) if showMessages
        elsif [:SMACKDOWN,:THOUSANDARROWS,:ROCKSLIDE,:VITALTHROW,:AVALANCHE,:STORMTHROW,
              :LOWSWEEP,:CIRCLETHROW,:CONTINENTALCRUSH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.7
          @battle.pbDisplay(_INTL("{1} was knocked into the magma!",target.pbThis)) if showMessages
        elsif [:MUDSLAP,:MUDSHOT,:MUDBOMB].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("{1} scooped up some magma in the mud!",user.pbThis)) if showMessages
        elsif [:EARTHQUAKE,:DIG,:MAGNITUDE,:EARTHPOWER,:ERUPTION,:LAVAPLUME,:LANDSWRATH,
              :TECTONICRAGE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("Magma from beneath the floor seeped into the attack!")) if showMessages
        end
        if types[0] == :FIRE || [:SUNSTEELSTRIKE,:SCORCHINGSANDS,:FIERYWRATH,:SEARINGSUNRAZESMASH,
           :INFERNALPARADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The intense heat amplified the attack!")) if showMessages
        elsif types[0] == :GRASS || [:POLLENPUFF,:SAVAGESPINOUT].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The flames burnt up the attack!")) if showMessages
        elsif types[0] == :ICE && @id != :ICEBURN
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The intense heat softened the attack...")) if showMessages
        elsif types[0] == :WATER && ![:SCALD,:STEAMERUPTION].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.7
          @battle.pbDisplay(_INTL("The intense heat evaporated the attack...")) if showMessages
        end
      when 8 # Swamp Field
        if [:MUDBOMB,:MUDSHOT,:MUDSLAP,:MUDDYWATER,:SLUDGEWAVE,:SMACKDOWN,:GUNKSHOT,
           :BRINE,:SLUDGE,:SLUDGEBOMB,:BELCH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The murk strengthened the attack!")) if showMessages
        elsif [:VINEWHIP,:ABSORB,:MEGADRAIN,:LEECHLIFE,:GIGADRAIN,:POWERWHIP,:CRISISVINE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The swamp life strengthened the attack!")) if showMessages
        elsif @id == :BUGBUZZ
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The low din of buzzing around the swamp strengthened the attack!")) if showMessages
        elsif @id == :SMELLINGSALTS
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The strong swamp stench infused with the attack!")) if showMessages
        elsif [:EARTHQUAKE,:BULLDOZE,:MAGNITUDE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The murky ground weakened the attack!")) if showMessages
        end
        if types[0] == :GROUND && target.grounded?
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The poison infected the nearby murk!")) if showMessages
        elsif types[0] == :WATER && user.grounded?
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The swamp surged the attack!")) if showMessages
        elsif types[0] == :FIRE && target.grounded?
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The murk covering {1} doused the attack!",target.pbThis(true))) if showMessages
        elsif types[0] == :ELECTRIC && target.grounded?
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The murk covering {1} absorbed the attack!",target.pbThis(true))) if showMessages
        end
      when 9 # Rainbow Field
        if [:SILVERWIND,:MYSTICALFIRE,:DRAGONPULSE,:TRIATTACK,:SACREDFIRE,:JUDGMENT,
           :SECRETPOWER,:MISTBALL,:ZENHEADBUTT,:LIGHTOFRUIN,:MULTIATTACK,:COMETPUNCH,
           :ICEBEAM,:BUBBLEBEAM,:SOLARBEAM,:SKYATTACK,:BUBBLE,:LUSTERPURGE,:SIGNALBEAM,
           :MAGICALLEAF,:POWERGEM,:MIRRORSHOT,:CHARGEBEAM,:FREEZESHOCK,:ICEBURN,:FUSIONFLARE,
           :FUSIONBOLT,:DAZZLINGGLEAM,:MOONGEISTBEAM,:PHOTONGEYSER,:MIRRORLAUNCH,:MISTSLASH,
           :TWINKLETACKLE].include?(@id) || isHiddenPower?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The rainbow charged the attack!")) if showMessages
        elsif [:FIREPLEDGE,:WATERPLEDGE,:GRASSPLEDGE,:AURORABEAM,:WEATHERBALL,:PRISMATICLASER,
              :SPARKLINGARIA,:FLASHCANNON,:LUMINOUSBLADE,:OCEANICOPERETTA].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The rainbow's energy resonated with the attack!")) if showMessages
        elsif [:DARKPULSE,:SHADOWBALL,:NIGHTDAZE,:FRUSTRATION,:SHADOWPUNCH,:SHADOWCLAW,
              :SHADOWSNEAK,:SHADOWFORCE,:DARKESTLARIAT,:SHADOWBONE,:DESPAIRRAY,:BLACKHOLEECLIPSE,
              :NEVERENDINGNIGHTMARE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The rainbow softened the attack...")) if showMessages
        end
        if types[0] == :NORMAL && specialMove?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The rainbow energized the attack!")) if showMessages
        elsif types[0] == :DARK
          multipliers[:base_damage_multiplier] *= 0.7
          @battle.pbDisplay(_INTL("The bright rainbow weakened the attack!")) if showMessages
        elsif types[0] == :FAIRY
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The rainbow's energy strengthened the attack!")) if showMessages
        end
      when 10 # Corrosive Field
        if [:MUDSLAP,:MUDSHOT,:MUDBOMB,:MUDDYWATER,:WHIRLPOOL,:LIGHTOFRUIN].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The corrosion morphed the attack!")) if showMessages
        elsif [:SMACKDOWN,:THOUSANDARROWS,:GRASSKNOT,:TAKEDOWN,:ROCKSLIDE,:AVALANCHE,
              :FRENZYPLANT,:LOWSWEEP,:BULLDOZE,:STEAMROLLER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("{1} was knocked into the searing corrosion!",target.pbThis)) if showMessages
        elsif [:ACID,:ACIDSPRAY,:APPLEACID].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The acid burned right through {1}!",target.pbThis(true))) if showMessages
        end
        if healingMove?
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The corrosion weakened the attack!")) if showMessages
        end
        if types[0] == :POISON && target.grounded?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The corrosion strengthened the attack!")) if showMessages
        end
      when 11 # Corrosive Mist Field
        if [:BUBBLEBEAM,:ACIDSPRAY,:BUBBLE,:SMOG,:CLEARSMOG,:SPARKLINGARIA,:MISTBALL,
           :APPLEACID,:STRANGESTEAM,:MISTSLASH,:ACIDDOWNPOUR,:OCEANICOPERETTA].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The poisonous gas strengthened the attack!")) if showMessages
        end
        if types[0] == :FIRE
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The flames caused a combustion!")) if showMessages
        elsif types[0] == :POISON && specialMove?
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The toxicity morphed the attack!")) if showMessages
        end
      when 12 # Desert Field
        if [:DIG,:SANDTOMB,:SCORCHINGSANDS].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The sand strengthened the attack!")) if showMessages
        elsif [:NEEDLEARM,:PINMISSILE,:POISONSTING,:TWINEEDLE,:SPIKECANNON,:SUDDENSTING,
              :BARBBARRAGE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("Bristles from nearby cacti strengthened the attack!")) if showMessages
        elsif [:HEATWAVE,:OVERHEAT,:SEARINGSUNRAZESMASH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The hot desert air strengthened the attack!")) if showMessages
        elsif [:BONECLUB,:BONERUSH,:BONEMERANG,:ANCIENTPOWER,:POWERGEM,:RELICSONG,
              :DIAMONDSTORM,:GOLDRUSH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("Archaeology boosted the attack!")) if showMessages
        elsif [:BRAVEBIRD,:FLY,:DRAGONASCENT].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("Soaring through the open skies!")) if showMessages
        elsif [:BLIZZARD,:POWDERSNOW,:ENERGYBALL,:STEAMROLLER].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The desert weakened the attack...")) if showMessages
        end
        if healingMove?
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("It drained {1}'s minimal energy!",target.pbThis(true))) if showMessages
        end
        if specialMove? && target.pbHasType?(:GROUND)
          multipliers[:defense_multiplier] *= 1.5
        end
        if types[0] == :WATER && ![:SCALD,:STEAMERUPTION].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The heat and aridity softened the attack...")) if showMessages
        elsif types[0] == :ELECTRIC && physicalMove?
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The dry air strengthened the static electricity!")) if showMessages
        elsif types[0] == :GROUND
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The sand surrounded the attack!")) if showMessages
        end
      when 13 # Icy Cave
        if [:SCALD,:STEAMERUPTION,:FIERYWRATH].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The cold softened the attack...")) if showMessages
        elsif [:AURORABEAM,:SIGNALBEAM,:FLASHCANNON,:LUSTERPURGE,:DAZZLINGGLEAM,:TECHNOBLAST,
              :PRISMATICLASER,:MIRRORSHOT,:PHOTONGEYSER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The reflected light was blinding!")) if showMessages
        elsif [:ICICLESPEAR,:BARRAGE,:SPIKECANNON,:TWINEEDLE,:ICESHARD,:ICICLECRASH,
              :GLACIALLANCE,:POLARSPEAR,:BARBBARRAGE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The sharp icicles pierced with the attack!")) if showMessages
        elsif [:FLY,:BOUNCE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("...But {1} didn't get as much momentum.",user.pbThis(true))) if showMessages
        end
        if windMove?
          multipliers[:base_damage_multiplier] *= 0.7
          @battle.pbDisplay(_INTL("The cave choked out the air!")) if showMessages
        end
        if types[0] == :FIRE
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The attack was cooled down!")) if showMessages
        elsif types[0] == :ICE
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The cold strengthened the attack!")) if showMessages
        elsif types[0] == :ROCK
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The icy rocks strengthened the attack!")) if showMessages
        end
      when 14 # Rocky Field
        if [:DOUBLEEDGE,:STONEEDGE,:PRECIPICEBLADES,:SPLINTEREDSTORMSHARDS,:CEASELESSEDGE,
           :STONEAXE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The jagged terrain strengthened the attack!")) if showMessages
        elsif [:ROCKSMASH,:BRICKBREAK,:METEORMASH,:ROCKWRECKER].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("SMASH'D!")) if showMessages
        elsif [:ROCKCLIMB,:STRENGTH,:MAGNITUDE,:EARTHQUAKE,:BULLDOZE,:DIG,:EARTHPOWER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The rocks combined with the attack!")) if showMessages
        end
        if types[0] == :ROCK
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The rocks strengthened the attack!")) if showMessages
        end
      when 15 # Forest Field
        if [:ATTACKORDER,:INFESTATION,:THOUSANDARROWS,:THOUSANDWAVES].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("They're coming out of the woodwork!")) if showMessages
        elsif [:ERUPTION,:LAVAPLUME,:FLAMEBURST,:SEARINGSHOT,:INCINERATE,:INFERNOOVERDRIVE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The plants fed into the blaze!")) if showMessages
        elsif [:TWINEEDLE,:LEECHLIFE,:BUGBITE,:FELLSTINGER,:SKITTERSMACK,:SUDDENSTING].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The attack was swarmed by insects!")) if showMessages
        elsif @id == :CHATTER
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Chirp chirp!")) if showMessages
        elsif [:HEADBUTT,:ZENHEADBUTT,:HEADSMASH,:IRONHEAD,:HEADCHARGE,:BEHEMOTHBASH,
              :GLACIALBASH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("{1} was slammed into a tree!",target.pbThis)) if showMessages
        elsif [:BRANCHPOKE,:WOODHAMMER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The tree branches strengthened the attack!")) if showMessages
        end
        if slashingMove?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("A tree slammed down!")) if showMessages
        end
        if types[0] == :BUG && specialMove?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The attack spreads through the forest!")) if showMessages
        elsif pbTarget(user).num_targets > 1 # Exclude Special Bug Moves
          multipliers[:base_damage_multiplier] *= 0.8
          @battle.pbDisplay(_INTL("But the trees obstructed the attack!")) if showMessages
        end
        if types[0] == :GRASS
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The forestry strengthened the attack!")) if showMessages
        end
      when 16 # Volcanic Top Field
        if [:SURF,:MUDDYWATER,:WATERSPOUT,:SPARKLINGARIA,:BUBBLE,:BUBBLEBEAM,:TSUNAMI,
           :WHIRLPOOL,:MISTSLASH,:OCEANICOPERETTA].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5 # Message dealt with in steam shoot
        elsif [:SCALD,:STEAMERUPTION,:FIERYWRATH,:SCORCHINGSANDS,:INFERNALPARADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The volcano strengthened the attack!")) if showMessages
        elsif [:ERUPTION,:MAGMASTORM,:LAVAPLUME].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The lava surged the attack!")) if showMessages
        elsif @id == :SMOG
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The attack was amplified by the volcanic ash!")) if showMessages
        elsif [:PRECIPICEBLADES,:STONEEDGE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The attack burst up from the volcano!")) if showMessages
        elsif [:ROLLINGKICK,:ICEBALL,:ROLLOUT,:ROCKCLIMB,:STEAMROLLER,:CRIMSONDIVE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The slope increased the velocity of the attack!")) if showMessages
        end
        if windMove? || @id == :CLEARSMOG
          multipliers[:base_damage_multiplier] *= 1.2 # Message dealt with in ash stirring
        end
        if types[0] == :FIRE
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The heat strengthened the attack!")) if showMessages
        elsif types[0] == :ICE
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The heat melted the attack...")) if showMessages
        elsif types[0] == :WATER
          multipliers[:base_damage_multiplier] *= 0.8
          @battle.pbDisplay(_INTL("The heat evaporated the attack...")) if showMessages
        end
      when 17 # Factory Field
        if [:GYROBALL,:GEARGRIND,:STEAMROLLER,:FLAMEWHEEL,:ROLLINGKICK,:ROLLOUT,:RAPIDSPIN,
           :ICEBALL,:AURAWHEEL,:TRIPLEAXEL].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The gears in the machines picked up speed!")) if showMessages
        elsif @id == :TECHNOBLAST
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The machinery strengthened the attack!")) if showMessages
        elsif [:SOLARBEAM,:SOLARBLADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("But the energy source is electrical...")) if showMessages
        elsif [:SIGNALBEAM,:FLASHCANNON,:PRISMATICLASER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The machines reacted to the signal!")) if showMessages
        end
        if types[0] == :ELECTRIC || [:ENERGYBALL,:COREENFORCER,:TURBODRIVE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The attack took energy from the field!")) if showMessages
        end
        if types.include?(:STEEL) && physicalMove? || [:WOODHAMMER,:ICEHAMMER,:HAMMERARM,
           :HIGHHORSEPOWER,:DRAGONHAMMER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("CLANG!")) if showMessages
        end
      when 18 # Short-Circuit Field
        if [:DAZZLINGGLEAM,:FLASHCANNON,:PHOTONGEYSER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Blinding!")) if showMessages
        elsif [:DARKPULSE,:NIGHTDAZE,:NIGHTSLASH,:SHADOWBALL,:SHADOWPUNCH,:SHADOWCLAW,
              :SHADOWSNEAK,:SHADOWFORCE,:SHADOWBONE,:DARKESTLARIAT].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The darkness strengthened the attack!")) if showMessages
        elsif [:SURF,:MUDDYWATER,:MAGNETBOMB,:GYROBALL,:GEARGRIND,:DRAGONENERGY,:SIGNALBEAM,
              :POWERGEM,:ENERGYBALL,:PSYSHOCK,:VENOSHOCK,:FREEZESHOCK,:THUNDEROUSKICK,
              :TURBODRIVE,:HYDROVORTEX].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The attack picked up electricity!")) if showMessages
        elsif @id == :LIGHTTHATBURNSTHESKY
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("{1} couldn't consume much light...",user.pbThis)) if showMessages
        end
      when 19 # Wasteland
        if [:OCTAZOOKA,:SLUDGE,:GUNKSHOT,:SLUDGEWAVE,:SLUDGEBOMB,:ABSORB,:ASTONISH,
           :FLING,:SHADOWSNEAK,:GRASSKNOT,:STOREDPOWER,:THOUSANDARROWS,:THOUSANDWAVES,
           :POLTERGEIST,:REACTIVEPOISON,:TRASHALANCHE].include?(@id) || isHiddenPower?
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The waste joined in the attack!")) if showMessages
        elsif [:SPITUP,:BELCH].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("BLEAAARGGGGH!")) if showMessages
        elsif [:VINEWHIP,:POWERWHIP,:CRISISVINE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The waste did it for the vine!")) if showMessages
        elsif [:MUDSLAP,:MUDSHOT,:MUDBOMB].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Some of the waste was scooped up in the attack!")) if showMessages
        elsif [:EARTHQUAKE,:MAGNITUDE,:BULLDOZE,:POUND,:SLAM,:STOMP,:JUMPKICK,:BODYSLAM,
              :HIGHJUMPKICK,:BOUNCE,:HAMMERARM,:DRAGONRUSH,:GIGAIMPACT,:ROCKWRECKER,
              :WOODHAMMER,:HEAVYSLAM,:FLYINGPRESS,:ICEHAMMER,:LUNGE,:DRAGONHAMMER,
              :STOMPINGTANTRUM,:DOUBLEIRONBASH,:BODYPRESS,:CRIMSONDIVE,:SUPERSONICSKYSTRIKE,
              :TECTONICRAGE,:CONTINENTALCRUSH,:CORKSCREWCRASH,:PULVERIZINGPANCAKE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.25
          if showMessages
            @battle.pbDisplay(_INTL("Wibble-wibble wobble-wobb..."))
            user.effects[PBEffects::WasteAnger]+=1
          end
        end
        if types[0] == :POISON
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The waste strengthened the attack!")) if showMessages
        end
      when 20 # Ashen Beach
        if [:MUDSLAP,:MUDSHOT,:MUDBOMB,:SANDTOMB].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("Ash mixed into the attack!")) if showMessages
        elsif focusMove?
          if user.hp == user.totalhp
            multipliers[:base_damage_multiplier] *= 1.7
            @battle.pbDisplay(_INTL("...And with full focus!")) if showMessages
          elsif user.hp >= user.totalhp/2
            multipliers[:base_damage_multiplier] *= 1.4
            @battle.pbDisplay(_INTL("...And with pure focus...!")) if showMessages
          else
            multipliers[:base_damage_multiplier] *= 1.2
            @battle.pbDisplay(_INTL("...And with focus...!")) if showMessages
          end
        elsif [:LANDSWRATH,:SANDTOMB,:SCORCHINGSANDS,:DUSTSTORM].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The sand strengthened the attack!")) if showMessages
        elsif [:SURF,:MUDDYWATER,:THOUSANDWAVES,:TSUNAMI,:STOKEDSPARKSURFER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Surf's up!")) if showMessages
        elsif [:BITE,:CRUNCH,:BEATUP,:ASSURANCE,:PUNISHMENT,:DARKPULSE,:FOULPLAY,:THROATCHOP,
              :POWERTRIP,:BRUTALSWING,:THIEF,:FALSESURRENDER,:LASHOUT,:WICKEDBLOW,
              :FIERYWRATH,:MALICIOUSMOONSAULT,:HYPERSPACEFURY].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("Control the darkness you feel within...")) if showMessages
        end
        if recoilMove? || [:OUTRAGE,:THRASH,:RAGE,:FURYATTACK,:FURYCUTTER,:FRUSTRATION,
           :REVENGE,:DOOMDESIRE,:PAYBACK,:PSYCHOCUT,:RETALIATE,:TECTONICRAGE,:SINISTERARROWRAID,
           :BITTERMALICE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("Control the anger you feel within...")) if showMessages
        end
      when 21 # Water Surface
        if [:SURF,:MUDDYWATER,:WHIRLPOOL,:DIVE,:SLUDGEWAVE,:THOUSANDWAVES,:TSUNAMI,
           :HYDROVORTEX,:STOKEDSPARKSURFER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The current strengthened the attack!")) if showMessages
        elsif @id == :FREEZEDRY && target.grounded?
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The water surrounding {1} froze up!",target.pbThis(true))) if showMessages
        end
        if types[0] == :WATER && user.grounded?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The water strengthened the attack!")) if showMessages
        elsif types[0] == :ELECTRIC && target.grounded?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The water conducted the attack!")) if showMessages
        elsif types[0] == :FIRE && target.grounded?
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The water deluged the attack...")) if showMessages
        end
      when 22 # Underwater
        if [:WATERPULSE,:AQUAJET,:SNIPESHOT].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Jet-streamed!")) if showMessages
        elsif @id == :ANCHORSHOT
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("From the depths!")) if showMessages
        elsif [:SOLARBEAM,:SUNSTEELSTRIKE,:SOLARBLADE,:LIGHTTHATBURNSTHESKY,:SEARINGSUNRAZESMASH].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.3
          @battle.pbDisplay(_INTL("But the sun barely shines down at the seafloor...")) if showMessages
        elsif @id == :FREEZEDRY && target.grounded?
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The water surrounding {1} froze up!",target.pbThis(true))) if showMessages
        end
        if physicalMove? && !types.include?(:WATER)
          multipliers[:base_damage_multiplier] *= 0.7
        end
        if types[0] == :WATER
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The water strengthened the attack!")) if showMessages
        elsif types[0] == :ELECTRIC
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The water super-conducted the attack!")) if showMessages
        elsif types[0] == :POISON && specialMove? && @id != :SLUDGEWAVE
          multipliers[:base_damage_multiplier] *= 0.7
          @battle.pbDisplay(_INTL("The water diluted the attack...")) if showMessages
        end
      when 23 # Cave
        if [:DRILLPECK,:DIG,:DRILLRUN].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("Out from the walls of the cave!")) if showMessages
        elsif [:DAZZLINGGLEAM,:PHOTONGEYSER,:LUSTERPURGE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Blinding!")) if showMessages
        elsif @id == :LIGHTTHATBURNSTHESKY
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("But there wasn't much light in the cave...")) if showMessages
        elsif [:FLY,:BOUNCE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("...But {1} didn't get as much momentum.",user.pbThis(true))) if showMessages
        end
        if windMove?
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The cave choked out the air!")) if showMessages
        end
        if soundMove?(user)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("ECHO-Echo-echo...")) if showMessages
        end
        if types[0] == :ROCK || @id == :ROCKCLIMB
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The cavern strengthened the attack!")) if showMessages
        end
      when 25 # Crystal Cavern
        if [:SIGNALBEAM,:FLASHCANNON,:LIGHTOFRUIN,:LUSTERPURGE,:DAZZLINGGLEAM,:MIRRORSHOT,
           :TECHNOBLAST,:MOONGEISTBEAM,:PHOTONGEYSER,:MIRRORLAUNCH,:LUMINOUSBLADE,
           :TWINKLETACKLE,:LIGHTTHATBURNSTHESKY].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The crystals' light strengthened the attack!")) if showMessages
        elsif [:POWERGEM,:DIAMONDSTORM,:ROCKSMASH,:GOLDRUSH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The crystals strengthened the attack!")) if showMessages
        end
        if types[0] == :ROCK || [:PRISMATICLASER,:MULTIATTACK,:JUDGMENT,:TRIATTACK,
           :AURORABEAM].include?(@id) || isHiddenPower?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The crystals charged the attack!")) if showMessages
        elsif $fecounter == 0 && types[0] == :FIRE || $fecounter == 1 && types[0] == :WATER || 
              $fecounter == 2 && types[0] == :GRASS || $fecounter == 3 && types[0] == :ELECTRIC || 
              $fecounter == 4 && types[0] == :FAIRY || $fecounter == 5 && types[0] == :GHOST ||
              $fecounter == 6 && types[0] == :PSYCHIC
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The crystals resonated with the attack!")) if showMessages
        end
      when 26 # Murkwater Surface
        if [:MUDBOMB,:MUDSLAP,:MUDSHOT,:SMACKDOWN,:BRINE,:THOUSANDWAVES,:SLUDGEWAVE,
           :MUDDYWATER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The dirty water morphed the attack!")) if showMessages
        end
        if types[0] == :WATER && user.grounded?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The water strengthened the attack!")) if showMessages
        elsif types[0] == :POISON && user.grounded?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The murk strengthened the attack!")) if showMessages
        elsif types[0] == :ELECTRIC && target.grounded?
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The water conducted the attack!")) if showMessages
        elsif types[0] == :FIRE && target.grounded?
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The water doused the attack!")) if showMessages
        end
      when 27 # Mountain
        if [:VITALTHROW,:CIRCLETHROW,:STORMTHROW,:SKYDROP,:SMACKDOWN].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("{1} was hurled off the mountain!",target.pbThis)) if showMessages
        elsif [:THUNDER,:AVALANCHE,:ERUPTION].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The mountain strengthened the attack!")) if showMessages
        elsif [:HIGHJUMPKICK,:ROLLOUT,:ROLLINGKICK,:ICEBALL,:ROCKSLIDE,:AVALANCHE,
              :ROCKCLIMB,:PRECIPICEBLADES,:GRAVAPPLE,:CRIMSONDIVE,:TRASHALANCHE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The steep slope strengthened the attack!")) if showMessages
        end
        if windMove? && @battle.pbWeather == :StrongWinds
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The strong winds strengthened the attack!")) if showMessages
        end
        if types[0] == :ROCK
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The rocks strengthened the attack!")) if showMessages
        elsif types[0] == :FLYING || [:STEELWING,:SKYUPPERCUT,:ESPERWING].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The open air strengthened the attack!")) if showMessages
        end
      when 28 # Snowy Mountain
        if [:VITALTHROW,:CIRCLETHROW,:STORMTHROW,:SKYDROP,:SMACKDOWN].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("{1} was hurled off the mountain!",target.pbThis)) if showMessages
        elsif windMove?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The frigid wind strengthened the attack!")) if showMessages
        elsif [:HIGHJUMPKICK,:ROLLOUT,:ROLLINGKICK,:ICEBALL,:ROCKSLIDE,:AVALANCHE,
              :ROCKCLIMB,:PRECIPICEBLADES,:GRAVAPPLE,:CRIMSONDIVE,:TRASHALANCHE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The steep slope strengthened the attack!")) if showMessages
        elsif [:SCALD,:STEAMERUPTION].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The cold softened the attack...")) if showMessages
        end
        if windMove? && @battle.pbWeather == :StrongWinds
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The strong winds strengthened the attack!")) if showMessages
        end
        if [:ROCK,:ICE].include?(types[0])
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The cold and snow strengthened the attack!")) if showMessages
        elsif types[0] == :FLYING || [:STEELWING,:SKYUPPERCUT,:ESPERWING].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The open air strengthened the attack!")) if showMessages
        elsif types[0] == :FIRE || [:SCALD,:STEAMERUPTION].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The cold softened the attack...")) if showMessages
        end
      when 29 # Holy Field
        if [:BITE,:CRUNCH,:BEATUP,:ASSURANCE,:DARKPULSE,:FOULPLAY,:THROATCHOP,:POWERTRIP,
           :BRUTALSWING,:THIEF,:FALSESURRENDER,:LASHOUT,:WICKEDBLOW,:FIERYWRATH,:MALICIOUSMOONSAULT,
           :HYPERSPACEFURY].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("Control the darkness you feel within...")) if showMessages
        elsif [:FLASHCANNON,:LUSTERPURGE,:PRISMATICLASER,:SOLARBEAM,:SOLARBLADE,:DAZZLINGGLEAM,
              :LIGHTOFRUIN,:PHOTONGEYSER,:LIGHTTHATBURNSTHESKY,:GENESISSUPERNOVA].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The holy light resonated with the attack!")) if showMessages
        elsif [:PUNISHMENT,:DOOMDESIRE,:JUDGMENT,:WOODHAMMER,:HAMMERARM,:ICEHAMMER,
              :DRAGONHAMMER].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("Bear witness to the lord's verdict!")) if showMessages
        elsif [:ROUND,:ECHOEDVOICE,:RELICSONG].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("A powerful hymn for all to hear!")) if showMessages
        end
        if [:DARK,:GHOST].include?(types[0]) && specialMove? || [:OBLIVIONWING,:SPIRITBREAK].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The attack was cleansed!")) if showMessages
        elsif [:FAIRY,:NORMAL].include?(types[0]) && specialMove? || [:MYSTICALFIRE,
              :MAGICALLEAF,:ANCIENTPOWER,:SACREDFIRE,:AURASPHERE,:FIREPLEDGE,:WATERPLEDGE,
              :GRASSPLEDGE,:SACREDSWORD,:AURAWHEEL].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The holy presence strengthened the attack!")) if showMessages
        elsif [:PSYCHIC,:DRAGON].include?(types[0]) || @id == :DRAGONASCENT
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The imminent power resonated with the attack!")) if showMessages
        end
        if recoilMove? && physicalMove? || [:OUTRAGE,:THRASH,:RAGE,:FURYATTACK,:FURYCUTTER,
           :FRUSTRATION,:REVENGE,:DOOMDESIRE,:PAYBACK,:PSYCHOCUT,:RETALIATE,:TECTONICRAGE,
           :SINISTERARROWRAID,:BURNINGJEALOUSY,:BITTERMALICE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("Control the anger you feel within...")) if showMessages
        end
      when 30 # Mirror Arena
        if [:MIRRORSHOT,:MIRRORLAUNCH].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The mirrors amplified the attack!")) if showMessages
        elsif [:FLASHCANNON,:LUSTERPURGE,:PRISMATICLASER,:SOLARBEAM,:DAZZLINGGLEAM,
              :LIGHTOFRUIN,:PHOTONGEYSER,:LIGHTTHATBURNSTHESKY,:GENESISSUPERNOVA,:LUMINOUSBLADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The reflected light was blinding!")) if showMessages
        end
        if beamMove? && user.effects[PBEffects::NeverMiss]
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The beam was focused from the reflection!")) if showMessages
        end
        if types[0] == :STEEL
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The mirrors strengthened the attack!")) if showMessages
        end
      when 31 # Fairy Tale Field
        if [:DRAININGKISS,:HEARTSTAMP].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("True love never hurt so badly!")) if showMessages
        elsif [:MAGICALLEAF,:MYSTICALFIRE,:ANCIENTPOWER,:RELICSONG,:SPARKLINGARIA,
              :MOONGEISTBEAM,:FLEURCANNON,:MENACINGMOONRAZEMAELSTROM,:SACREDFIRE,:DOOMDESIRE,
              :OMINOUSWIND,:SACREDSWORD,:ORIGINPULSE,:NEVERENDINGNIGHTMARE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The magical energy strengthened the attack!")) if showMessages
        elsif [:REVENGE,:RETALIATE,:PAYBACK,:BURNINGJEALOUSY].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("On a path of vengeance!")) if showMessages
        elsif @id == :DESPAIRRAY
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("A tragic ending!")) if showMessages
        end
        if slashingMove?
          if user.effects[PBEffects::FairyTaleRoles].include?(4)
            multipliers[:base_damage_multiplier] *= 1.2
            @battle.pbDisplay(_INTL("{1}'s Fighter role powered up the attack!",user.pbThis)) if showMessages
          end
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The blade cuts true!")) if showMessages
        end
        if (punchingMove? || kickingMove?) && user.effects[PBEffects::FairyTaleRoles].include?(5) &&
           !user.hasRaisedStatStages?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("{1}'s Monk role powered up the attack!",user.pbThis)) if showMessages
        end
        if !user.near?(target) && user.effects[PBEffects::FairyTaleRoles].include?(7)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("{1}'s Ranger role powered up the attack!",user.pbThis)) if showMessages
        end
        if (types.include?(user.type1) || types.include?(user.type2) || types.include?(user.effects[PBEffects::Type3])) && 
           user.effects[PBEffects::FairyTaleRoles].include?(9)
          multipliers[:base_damage_multiplier] *= 1.1
          @battle.pbDisplay(_INTL("{1}'s Sorcerer role powered up the attack!",user.pbThis)) if showMessages
        end
        if types[0] == :STEEL && physicalMove? || @id == :BRAVEBIRD
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("For justice!")) if showMessages
        elsif types[0] == :FAIRY || [:ETERNABEAM,:INFINITEFORCE,:ETERNALFLAME].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Forever after!")) if showMessages
        end
        if user.pbHasType?(:DRAGON)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The legendary beast's attack gained strength!")) if showMessages
        end
      when 32 # Dragon's Den
        if @id == :MEGAKICK
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Trial of the Dragon!")) if showMessages
        elsif @id == :PAYDAY # Message in move effect
          multipliers[:base_damage_multiplier] *= 2
        elsif [:TRIATTACK,:FUSIONFLARE,:FUSIONBOLT].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("Infused with the elemental powers!")) if showMessages
        end
        if soundMove?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The draconic roar reverberates throughout the cave!")) if showMessages
        end
        if types[0] == :FIRE || @id == :FIERYWRATH
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The draconic fire presence amplified the attack!")) if showMessages
        elsif types[0] == :ICE || @id == :FREEZINGGLARE
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The draconic ice presence amplified the attack!")) if showMessages
        elsif types[0] == :ELECTRIC || @id == :THUNDEROUSKICK
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The draconic lightning presence amplified the attack!")) if showMessages
        elsif types[0] == :ROCK || @id == :ROCKCLIMB
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The cave strengthened the attack!")) if showMessages
        end
        if types[0] == :DRAGON || [:DRAGONASCENT,:ANCIENTPOWER,:BEHEMOTHBASH,:BEHEMOTHBLADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The beastly presence boosted the attack!")) if showMessages
        end
      when 33 # Flower Garden
        if [:PETALBLIZZARD,:PETALDANCE,:FLEURCANNON,:FAIRYWIND,:SILVERWIND,:REVELATIONDANCE].include?(@id)
          if $fecounter == 2
            multipliers[:base_damage_multiplier] *= 1.2
            @battle.pbDisplay(_INTL("The fresh scent of flowers boosted the attack!")) if showMessages
          elsif $fecounter > 2
            multipliers[:base_damage_multiplier] *= 1.5
            @battle.pbDisplay(_INTL("The vibrant aroma of flowers boosted the attack!")) if showMessages
          end
        elsif [:DIG,:EARTHPOWER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The fertile soil strengthened the attack!")) if showMessages
        end
        if slashingMove? && $fecounter >= 1
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("{1} was cut down to size!",target.pbThis)) if showMessages
        end
        if types[0] == :GRASS
          case $fecounter
          when 1
            multipliers[:base_damage_multiplier] *= 1.2
            @battle.pbDisplay(_INTL("The primed garden boosted the attack!")) if showMessages
          when 2
            multipliers[:base_damage_multiplier] *= 1.5
            @battle.pbDisplay(_INTL("The budding flowers boosted the attack!")) if showMessages             
          when 3
            multipliers[:base_damage_multiplier] *= 2
            @battle.pbDisplay(_INTL("The blooming flowers boosted the attack!")) if showMessages
          when 4
            multipliers[:base_damage_multiplier] *= 3
            @battle.pbDisplay(_INTL("The thriving flowers boosted the attack!")) if showMessages
          end
        elsif types[0] == :FIRE
          case $fecounter
          when 2
            multipliers[:base_damage_multiplier] *= 1.3
            @battle.pbDisplay(_INTL("The budding flowers ignited!")) if showMessages
          when 3,4
            multipliers[:base_damage_multiplier] *= 1.5
            @battle.pbDisplay(_INTL("The flowers caught flame!")) if showMessages
          end
        elsif types[0] == :BUG
          case $fecounter
          when 0,1
            multipliers[:base_damage_multiplier] *= 1.2
            @battle.pbDisplay(_INTL("The attack infested the fertile dirt!")) if showMessages
          when 2
            multipliers[:base_damage_multiplier] *= 1.3
            @battle.pbDisplay(_INTL("The attack infested the garden!")) if showMessages
          else
            multipliers[:base_damage_multiplier] *= 1.5
            @battle.pbDisplay(_INTL("The attack infested the flowers!")) if showMessages
          end
        end
        if target.pbHasType?(:GRASS)
          case $fecounter
          when 2
            multipliers[:final_damage_multiplier] *= 0.75
          when 3
            multipliers[:final_damage_multiplier] *= 2.0/3
          when 4
            multipliers[:final_damage_multiplier] *= 0.5
          end
        end
      when 34 # Starlight Arena
        if [:FLASHCANNON,:LUSTERPURGE,:DAZZLINGGLEAM,:SOLARBEAM,:SUNSTEELSTRIKE,:SEARINGSUNRAZESMASH,
           :LIGHTOFRUIN,:PHOTONGEYSER,:LIGHTTHATBURNSTHESKY].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Solar energy surged the attack!")) if showMessages
        elsif [:MOONBLAST,:MOONGEISTBEAM,:MENACINGMOONRAZEMAELSTROM,:MALICIOUSMOONSAULT].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Lunar energy surged the attack!")) if showMessages
        elsif [:DRACOMETEOR,:METEORMASH,:COMETPUNCH,:SPACIALREND,:HYPERSPACEHOLE,:HYPERSPACEFURY,
              :BLACKHOLEECLIPSE,:SWIFT,:TWINKLETACKLE,:AURORABEAM,:DRAGONASCENT,:GENESISSUPERNOVA,
              :METEORASSAULT,:METEORBEAM].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          if @id == :TWINKLETACKLE
            @battle.pbDisplay(_INTL("Twinkle, twinkle, little star...")) if showMessages
          end
          @battle.pbDisplay(_INTL("The spacial energy boosted the attack!")) if showMessages
        elsif @id == :DOOMDESIRE
          multipliers[:base_damage_multiplier] *= 4
          @battle.pbDisplay(_INTL("A star came crashing down!")) if showMessages
        elsif isHiddenPower?
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("{1}'s astrological sign resonated with the attack!",user.pbThis)) if showMessages
        end
        if types[0] == :DARK || [:SKYATTACK,:SUPERSONICSKYSTRIKE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The night sky boosted the attack!")) if showMessages
        elsif types[0] == :PSYCHIC || [:ASTRALBARRAGE,:INFERNALPARADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The astral energy boosted the attack!")) if showMessages
        elsif types[0] == :FAIRY
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("Starlight supercharged the attack!")) if showMessages
        end
        if [:ADAMANT,:HARDY].include?(user.pokemon.nature_id) && physicalMove? ||
           [:MODEST,:GENTLE].include?(user.pokemon.nature_id) && specialMove?
          multipliers[:base_damage_multiplier] *= 1.2
        elsif [:BOLD,:DOCILE].include?(user.pokemon.nature_id) && physicalMove? ||
              [:CALM,:CAREFUL].include?(user.pokemon.nature_id) && specialMove?
          multipliers[:defense_multiplier] *= 1.2
        elsif [:HASTY,:LAX].include?(user.pokemon.nature_id)
          multipliers[:base_damage_multiplier] *= 0.5
        end
      when 35 # Ultra Space
        if [:AURORABEAM,:SIGNALBEAM,:FLASHCANNON,:DAZZLINGGLEAM,:MIRRORSHOT,:LUSTERPURGE,
           :MOONBLAST,:PHOTONGEYSER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The light shone through the infinite darkness!")) if showMessages
        elsif [:EARTHPOWER,:DRACOMETEOR,:METEORMASH,:COMETPUNCH,:ANCIENTPOWER,:SPLINTEREDSTORMSHARDS,
              :METEORBEAM,:METEORASSAULT,:METEORTEMPEST].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The space matter strengthened the attack!")) if showMessages
        elsif @id == :LIGHTTHATBURNSTHESKY
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("There wasn't much light to gather...")) if showMessages
        end
        if [:PSYSTRIKE,:AEROBLAST,:SACREDFIRE,:MISTBALL,:LUSTERPURGE,:ORIGINPULSE,
           :PRECIPICEBLADES,:DRAGONASCENT,:PSYCHOBOOST,:ROAROFTIME,:JUDGMENT,:SEEDFLARE,
           :SHADOWFORCE,:VCREATE,:SECRETSWORD,:SACREDSWORD,:RELICSONG,:FUSIONBOLT,
           :FUSIONFLARE,:ICEBURN,:FREEZESHOCK,:BOLTSTRIKE,:BLUEFLARE,:OBLIVIONWING,
           :LANDSWRATH,:THOUSANDARROWS,:THOUSANDWAVES,:DIAMONDSTORM,:COREENFORCER,
           :FLEURCANNON,:PRISMATICLASER,:SUNSTEELSTRIKE,:SPECTRALTHIEF,:MOONGEISTBEAM,
           :MULTIATTACK,:GENESISSUPERNOVA,:SEARINGSUNRAZESMASH,:MENACINGMOONRAZEMAELSTROM,
           :SOULSTEALING7STARSTRIKE,:SWIFT,:ENERGYBALL,:LUSTERPURGE,:PHOTONGEYSER,
           :LIGHTTHATBURNSTHESKY].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The ethereal energy strengthened the attack!")) if showMessages
        elsif [:VACUUMWAVE,:SPACIALREND,:HYPERSPACEHOLE,:HYPERSPACEFURY,:SHATTEREDPSYCHE].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The void strengthened the attack!")) if showMessages
        elsif @id == :BLACKHOLEECLIPSE
          multipliers[:base_damage_multiplier] *= 4
          @battle.pbDisplay(_INTL("The void swallowed up {1}!",target.pbThis(true))) if showMessages
        end
        if types[0] == :DARK || @id == :INFINITEFORCE
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Infinity boosted the attack!")) if showMessages
        end
      when 37 # Psychic Terrain
        if [:STRENGTH,:ANCIENTPOWER,:ENERGYBALL,:SMARTSTRIKE,:MINDBLOWN,:DRAGONENERGY].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The psychic energy infused the attack!")) if showMessages
        end
        if types[0] == :PSYCHIC || [:HEX,:MAGICALLEAF,:MYSTICALFIRE,:AURASPHERE,:SECRETSWORD,
           :AURAWHEEL,:STRANGESTEAM].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The psychic aura strengthened the attack!")) if showMessages
        elsif types[0] == :DARK
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The psychic aura consumed the darkness!")) if showMessages
        end
      when 38 # Dimensional Field
        if [:HYPERSPACEHOLE,:HYPERSPACECFURY,:SPACIALREND].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The dimension strengthened the attack!")) if showMessages
        elsif [:LIGHTTHATBURNSTHESKY,:SOLARBEAM,:SOLARBLADE,:LUSTERPURGE,:FLASHCANNON,
              :DAZZLINGGLEAM,:LIGHTOFRUIN,:TWINKLETACKLE,:PRISMATICLASER,:PHOTONGEYSER].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.3
          @battle.pbDisplay(_INTL("But the dimension is engulfed in darkness...")) if showMessages
        elsif [:DARKPULSE,:NIGHTDAZE,:BLACKHOLEECLIPSE,:NIGHTSLASH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The void strengthened the attack!")) if showMessages
        end
        if types[0] == :FAIRY
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The darkness depleted the attack!")) if showMessages
        elsif types[0] == :GHOST
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The dreary aura powered up the attack!")) if showMessages
        elsif types.include?(:DARK)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The darkness is here...")) if showMessages
        end
      when 39 # Frozen Dimensional
        if [:SURF,:MUDDYWATER,:DARKPULSE,:BUBBLE,:BUBBLEBEAM,:EARTHQUAKE,:DIG,:EARTHPOWER,
           :LANDSWRATH,:FREEZINGGLARE,:TSUNAMI].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The ice warped the attack!")) if showMessages
        elsif [:SINISTERARROWRAID,:DOOMDESIRE,:ASSURANCE,:PUNISHMENT,:FOULPLAY,:OBLIVIONWING,
              :LIGHTOFRUIN,:SAVAGESPINOUT,:DEVASTATINGDRAKE,:CATASTROPIKA,:MALICIOUSMOONSAULT,
              :SPECTRALTHIEF,:SOULSTEALING7STARSTRIKE,:MENACINGMOONRAZEMAELSTROM,:WICKEDBLOW,
              :FIERYWRATH,:DRACONICDISASTER,:THIEF,:SOULTHIEF].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The evil presence strengthened the attack!")) if showMessages
        elsif [:LETSSNUGGLEFOREVER,:COVET,:RETURN,:HEARTSTAMP].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("Friendship is weakness...")) if showMessages
        elsif [:STOREDPOWER,:POWERTRIP].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The built up anger fueled the attack!")) if showMessages
        elsif [:HYPERVOICE,:ECHOEDVOICE,:ROUND,:CHATTER,:SPARKLINGARIA,:OCEANICOPERETTA,
              :FEROCIOUSBELLOW].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The hateful words echo throughout the dimension!")) if showMessages
        end
        if rageMove?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The anger is unhinged!")) if showMessages
        end
        if types[0] == :FIRE || @id == :FIERYWRATH
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The fire withered away...")) if showMessages
        elsif types[0] == :ICE || @id == :FREEZINGGLARE
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Cold anger resonated with the attack!")) if showMessages
        elsif types[0] == :DARK
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The darkness is here...")) if showMessages
        end
      when 40 # Haunted
        if [:BONECLUB,:BONERUSH,:BONEMERANG,:SHADOWBONE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The deathly atmosphere strengthened the attack!")) if showMessages
        elsif [:PLAYROUGH,:FOULPLAY,:NEVERENDINGNIGHTMARE,:SINISTERARROWRAID,:LETSSNUGGLEFOREVER].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The spirits joined in to play!")) if showMessages
        end
        if types[0] == :GHOST
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The spirits strengthened the attack!")) if showMessages
        elsif types[0] == :FAIRY
          multipliers[:base_damage_multiplier] *= 0.7 || [:SACREDFIRE,:SACREDSWORD].include?(@id)
          @battle.pbDisplay(_INTL("The evil aura depleted the attack!")) if showMessages
        elsif types[0] == :FIRE
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("Will-o'-wisps joined the attack!")) if showMessages
        end
      when 41 # Corrupted Cave
        if [:FLY,:BOUNCE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("...But {1} didn't get as much momentum.",user.pbThis(true))) if showMessages
        end
        if types[0] == :POISON
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The chemicals strengthened the attack.")) if showMessages
        elsif types[0] == :GRASS
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The corruption morphed the attack!")) if showMessages
        elsif types[0] == :ROCK || [:MUDSHOT,:MUDBOMB,:MUDSLAP].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The chemicals surged the attack!")) if showMessages
        end
        if windMove?
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The cave choked out the air!")) if showMessages
        end
      when 42 # Bewitched Woods
        if [:MAGICALLEAF,:MYSTICALFIRE,:EERIESPELL,:SIGNALBEAM,:EXTRASENSORY,:DOOMDESIRE,
           :AURASPHERE,:POWERGEM,:FREEZINGGLARE,:INFERNALPARADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The magic aura amplified the attack!")) if showMessages
        elsif [:DARKPULSE,:NIGHTDAZE,:MOONBLAST].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The forest is cursed with nightfall!")) if showMessages
        end
        if target.effects[PBEffects::BewitchedMark]
          if types.include?(:FIRE)
            @battle.pbDisplay(_INTL("Burn the witch at the stake!")) if showMessages
          end
          if types.include?(:WATER)
            @battle.pbDisplay(_INTL("Drown the witch!")) if showMessages
          end
        end
        if user.effects[PBEffects::BewitchedMark] && (specialMove? || witchMove?)
          multipliers[:attack_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The power of witchcraft boosted {1}'s power!",user.pbThis(true))) if showMessages
        end
        if types[0] == :FAIRY
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The pixie aura amplified the attack!")) if showMessages
        elsif types[0] == :GRASS
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Flourish!")) if showMessages
        elsif [:DARK,:GHOST].include?(types[0])
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The ominous aura strengthened the attack!")) if showMessages
        end
      when 43 # Sky Field
        if @id == :LIGHTTHATBURNSTHESKY
          multipliers[:base_damage_multiplier] *= 3
          @battle.pbDisplay(_INTL("The harsh light scorched the sky like never before!")) if showMessages
        elsif windMove?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The open air strengthened the attack!")) if showMessages
        elsif [:MISTBALL,:STRANGESTEAM,:MISTYEXPLOSION].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The clouds strengthened the attack!")) if showMessages
        end
        if types[0] == :FLYING || [:SKYUPPERCUT,:FLYINGPRESS,:STEELWING,:BOLTBEAK,
           :ESPERWING].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The open skies strengthened the attack!")) if showMessages
        elsif types[0] == :ELECTRIC
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("Static electricity in the clouds strengthened the attack!")) if showMessages
        end
      when 44 # Indoors
        if [:STRENGTH,:SLAM,:STORMTHROW,:CIRCLETHROW,:VITALTHROW].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("A piece of furniture was hurled at {1}!",target.pbThis(true))) if showMessages
        elsif windMove? || [:SKYUPPERCUT,:AERIALACE,:ACROBATICS,:BLIZZARD,:FLY,:THUNDERBOLT,
              :THUNDER,:HEATWAVE,:WEATHERBALL,:BOUNCE,:FLYINGPRESS,:SOLARBEAM,:SOLARBLADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The closed area weakened the attack!")) if showMessages
        elsif @id == :ASTONISH
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("Surprise from behind the furniture!")) if showMessages
        end
        if types[0] == :NORMAL
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Simplicity at its finest!")) if showMessages
        elsif types[0] == :BUG
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The attack infests throughout the building!")) if showMessages
        end
      when 45 # Boxing Ring
        if punchingMove? || types[0] == :FIGHTING || [:BONECLUB,:CRABHAMMER,:BEATUP,
           :GYROBALL,:SMACKDOWN,:HEAVYSLAM,:STEAMROLLER,:PLAYROUGH,:DARKESTLARIAT,
           :THROATCHOP,:SHADOWBONE,:LIQUIDATION,:CORKSCREWCRASH,:TWINKLETACKLE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Knockout!")) if showMessages
        elsif [:RAGE,:THRASH,:SKULLBASH,:OUTRAGE,:ROLLOUT,:FURYCUTTER,:BREAKNECKBLITZ,
              :MALICIOUSMOONSAULT,:FURYATTACK,:FRUSTRATION,:ALLOUTPUMMELING,:SAVAGESPINOUT,
              :LASHOUT,:WICKEDBLOW].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Rash tactics are more effective!")) if showMessages
        elsif @id == :LETSSNUGGLEFOREVER
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("Caught off guard!")) if showMessages
        elsif [:SKYATTACK,:SKYUPPERCUT,:HIGHJUMPKICK,:JUMPKICK,:FLY,:AERIALACE,:BOUNCE,
           :DRAGONRUSH,:BRAVEBIRD,:SKYDROP,:ACROBATICS,:FLYINGPRESS,:DRAGONASCENT,
           :SUPERSONICSKYSTRIKE,:PULVERIZINGPANCAKE,:CRIMSONDIVE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("With extreme aerial agility!")) if showMessages
        end
        if recoilMove?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Reckless tactics are more effective!")) if showMessages
        end
        if types[0] == :DARK
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("Dirty tactics are more effective!")) if showMessages
        end
      when 46 # Subzero Field
        if beamMove?
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The attack reflected off the ice!")) if showMessages
        elsif [:EARTHQUAKE,:HAMMERARM,:ROCKWRECKER,:STONEEDGE,:EARTHPOWER,:TECTONICRAGE,
              :PULVERIZINGPANCAKE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The ice shattered beneath {1}!",target.pbThis(true))) if showMessages
        end
        if thawsUser?
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("The heat is too much to cool down, scorching {1}'s shivering appendages!",target.pbThis(true))) if showMessages
        elsif types[0] == :FIRE
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("No heat exists here!")) if showMessages
        end
        if physicalMove? && target.pbHasType?(:ICE)
          multipliers[:defense_multiplier] *= 1.5
        end
        if types.include?(:ICE)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Down to absolute zero!")) if showMessages
        end
      when 47 # Jungle
        if windMove?
          multipliers[:base_damage_multiplier] *= 0.7
          @battle.pbDisplay(_INTL("...But the dense jungle slows airflow.")) if showMessages
        end
        if [:VINEWHIP,:POWERWHIP,:CRISISVINE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Swinging in at full force!")) if showMessages
        elsif [:CONSTRICT,:BIND].include?(@id)
          multipliers[:base_damage_multiplier] *= 8
          @battle.pbDisplay(_INTL("The vines throughout the jungle tremendously helped with the constricting!")) if showMessages
        elsif [:SIGNALBEAM,:BUGBUZZ,:STRUGGLEBUG,:DRUMBEATING].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The signal was passed on!")) if showMessages
        elsif [:ATTACKORDER,:INFESTATION].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The attack was swarmed by nearby insects!")) if showMessages
        elsif [:CHATTER,:ROUND,:ECHOEDVOICE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Chirp chirp!")) if showMessages
        elsif [:BRANCHPOKE,:WOODHAMMER,:TROPICALSHAKE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The tree branches strengthened the attack!")) if showMessages
        elsif [:FLING,:SMACKDOWN,:ROCKTHROW,:GUNKSHOT,:MUDSHOT].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("Thrown like a wild animal!")) if showMessages
        end
        if types[0] == :BUG || [:POISONSTING,:ELECTROWEB].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("Insects from throughout the jungle strengthened the attack!")) if showMessages
        elsif types[0] == :GRASS
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The plant life nearby strengthened the attack!")) if showMessages
        elsif types[0] == :GROUND
          multipliers[:base_damage_multiplier] *= 0.7
          @battle.pbDisplay(_INTL("The tangling vines obstructed the attack...")) if showMessages
        end
      when 48 # Beach
        if @id == :STRENGTH
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("...And with pure focus!")) if showMessages
        elsif [:RAZORSHELL,:CLAMP,:SHELLSIDEARM].include?(@id)
          multipliers[:base_damage_multiplier] *= 2
          @battle.pbDisplay(_INTL("{1} used the biggest shell it could find!",user.pbThis)) if showMessages
        elsif [:LANDSWRATH,:SANDTOMB].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The sand strengthened the attack!")) if showMessages
        elsif @id == :CRABHAMMER
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The crabs nearby provided support!")) if showMessages
        elsif [:ZENHEADBUTT,:STOREDPOWER,:AURASPHERE,:FOCUSBLAST].include?(@id) ||
              isHiddenPower?
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The peaceful atmosphere strengthened the attack!")) if showMessages
        elsif @id == :HEATWAVE
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The open sands and direct sunlight augmented the attack!")) if showMessages
        elsif [:MUDSLAP,:MUDSHOT,:MUDBOMB].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("The mixture of water and sand strengthened the attack!")) if showMessages
        elsif [:SPARKLINGARIA,:OCEANICOPERETTA].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.3
          @battle.pbDisplay(_INTL("A performance for all to enjoy!")) if showMessages
        elsif @id == :PSYCHIC
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The calm atmosphere strengthened the attack!")) if showMessages
        elsif [:RAGE,:OUTRAGE,:FRUSTRATION,:FOULPLAY,:RETALIATE,:STOMPINGTANTRUM,:REVENGE,
              :TECTONICRAGE].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The relaxing atmosphere weakened the attack!")) if showMessages
        elsif [:ROLLOUT,:ICEBALL].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("The coarse surface decreased the velocity of the attack!")) if showMessages
        end
        if windMove?
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The ocean breeze strengthened the attack!")) if showMessages
        end
      when 49 # Xeric Shrubland
        if [:ABSORB,:MEGADRAIN,:GIGADRAIN,:POISONSTING,:TWINEEDLE,:PINMISSILE,:NEEDLEARM,
           :SPIKECANNON,:SUDDENSTING,:BARBBARRAGE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The cacti strengthened the attack!")) if showMessages
        elsif [:HEATWAVE,:OVERHEAT,:SEARINGSUNRAZESMASH,:SOLARBEAM,:SOLARBLADE].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The hot desert air strengthened the attack!")) if showMessages
        elsif [:DIG,:SANDTOMB,:SCORCHINGSANDS,:LANDSWRATH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("The sand surged the attack!")) if showMessages
        elsif [:BONECLUB,:BONEMERANG,:BONERUSH,:SHELLTRAP,:DIAMONDSTORM,:POWERGEM,
              :ANCIENTPOWER,:RELICSONG,:GOLDRUSH].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("Archaeology boosted the attack!")) if showMessages
        elsif [:BRAVEBIRD,:FLY,:DRAGONASCENT].include?(@id)
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("Soaring through the open skies!")) if showMessages
        end
        if types[0] == :GRASS
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The shrubbery strengthened to the attack!")) if showMessages
        elsif types[0] == :WATER && specialMove? && ![:SCALD,:STEAMERUPTION].include?(@id)
          multipliers[:base_damage_multiplier] *= 0.7
          @battle.pbDisplay(_INTL("The hot, dry air depleted the attack.")) if showMessages
        elsif types[0] == :ELECTRIC && physicalMove?
          multipliers[:base_damage_multiplier] *= 1.2
          @battle.pbDisplay(_INTL("The dry air strengthened the static electricity!")) if showMessages
        end
      end
    end
    
    def pbCalcDamageMultipliers(user,target,numTargets,types,baseDmg,multipliers)
      # Global Ability
      pbCalcGlobalAbilityMultipliers(user,target,types,multipliers)
      if @battle.pbCheckGlobalAbility(:VANGUARD) && $fefieldeffect != 37
        if $fefieldeffect == 36
          userLast = true
          user.eachOtherBattler do |b|
            if !b.movedThisRound?
              userLast = false
              break
            end
          end
          if userLast
            multipliers[:base_damage_multiplier] *= 1.5
          end
        else
          userFirst = true
          user.eachOtherBattler do |b|
            if b.movedThisRound?
              userFirst = false
              break
            end
          end
          if userFirst
            multipliers[:base_damage_multiplier] *= 1.5
          end
        end
      end
      # User Ability
      pbCalcUserAbilityMultipliers(user,target,types,multipliers,baseDmg)
      multipliers[:base_damage_multiplier] *= @powerBoost
      if target.damageState.critical
        if user.hasActiveAbility?(:SNIPER)
          if [22,27,28,43].include?($fefieldeffect)
            multipliers[:final_damage_multiplier] *= 2
          else
            multipliers[:final_damage_multiplier] *= 1.5
          end
        end
        if user.hasActiveAbility?(:CRITICALSTALK) && physicalMove?
          multipliers[:attack_multiplier] *= 2
        end
      end
      if user.hasActiveAbility?(:NEUROFORCE) && Effectiveness.super_effective?(target.damageState.typeMod) &&
         $fefieldeffect != 45
        multipliers[:final_damage_multiplier] *= 1.25
      end
      if user.hasActiveAbility?(:STAKEOUT) && (@battle.choices[target.index][0] == :SwitchOut ||
         target.turnCount <= 1 && [4,14,40].include?($fefieldeffect)) && ![30,37].include?($fefieldeffect)
        if $fefieldeffect == 42
          multipliers[:base_damage_multiplier] *= 3
        else
          multipliers[:base_damage_multiplier] *= 2
        end
      end
      if user.hasActiveAbility?(:TINTEDLENS) && Effectiveness.resistant?(target.damageState.typeMod) &&
         ![4,18].include?($fefieldeffect)
        multipliers[:final_damage_multiplier] *= 2
      end
      if user.hasActiveAbility?(:SNEAKATTACK) && target.damageState.critical && $fefieldeffect == 40
        multipliers[:final_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:ALPHABETIZATION)
        if user.checkAlphabetizationForm(17) && target.tookDamage
          multipliers[:attack_multiplier] *= 4
        end
      end
      if user.hasActiveAbility?(:SHIFU)
        if kickingMove? && @id == user.lastMoveUsed
          multipliers[:base_damage_multiplier] *= 1 + 0.1*user.effects[PBEffects::Shifu]
          user.effects[PBEffects::Shifu] += 1 if user.effects[PBEffects::Shifu] < 4
        else
          user.effects[PBEffects::Shifu] = 0
        end
      end
      if !@battle.moldBreaker
        # NOTE: It's odd that the user's Mold Breaker prevents its partner's
        #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
        #       how it works.
        # User Ally Ability
        pbCalcUserAllyAbilityMultipliers(user,target,types,multipliers)
        # Target Ability
        pbCalcTargetAbilityMultipliers(user,target,types,multipliers)
        if target.hasActiveAbility?(:FILTER) && Effectiveness.super_effective?(target.damageState.typeMod)
          if $fefieldeffect == 44
            multipliers[:final_damage_multiplier] *= 0.5
          else
            multipliers[:final_damage_multiplier] *= 0.75
          end
        end
        if target.hasActiveAbility?(:SOLIDROCK) && Effectiveness.super_effective?(target.damageState.typeMod) &&
           ![7,35].include?($fefieldeffect)
          if [4,14,23,25,27,41].include?($fefieldeffect)
            multipliers[:final_damage_multiplier] *= 0.5
          else
            multipliers[:final_damage_multiplier] *= 0.75
          end
        end
        if target.hasActiveAbility?(:TINTEDLENS) && Effectiveness.super_effective?(target.damageState.typeMod) &&
           $fefieldeffect == 34
          multipliers[:final_damage_multiplier] *= 0.5
        end
        # Target Ally Ability
        pbCalcTargetAllyAbilityMultipliers(user,target,types,multipliers)
      end
      #BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,user,target,self,multipliers,baseDmg,types)
      # Target Ability (Non-Ignorable)
      if target.hasActiveAbility?(:PRISMARMOR) && !($fefieldeffect == 26 && target.grounded?)
        if Effectiveness.super_effective?(target.damageState.typeMod)
          multipliers[:final_damage_multiplier] *= 0.75
        end
        if [4,9,25].include?($fefieldeffect)
          multipliers[:defense_multiplier] *= 2
        end
      end
      # Items
      if user.itemActive?
        BattleHandlers.triggerDamageCalcUserItem(user.item,user,target,self,multipliers,baseDmg,types)
      end
      if target.itemActive?
        BattleHandlers.triggerDamageCalcTargetItem(target.item,user,target,self,multipliers,baseDmg,types)
      end
      # General
      pbCalcGeneralMultipliers(user,target,types,multipliers,@battle.moldBreaker)
      # Parental Bond
      if user.effects[PBEffects::ParentalBond]==1 && user.hasActiveAbility?(:PARENTALBOND)
        if [29,31].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] /= 2
        else
          multipliers[:base_damage_multiplier] /= 4
        end
      end
      # Me First
      if user.effects[PBEffects::MeFirst]
        multipliers[:base_damage_multiplier] *= 1.5
      end
      # Field Effects
      showMessages = ($feshutup == 0)
      pbCalcFieldMultipliers(user,target,types,multipliers,showMessages)
      case $fefieldeffect
      when 6 # Performance Stage
        if types.include?(:FIGHTING) && physicalMove? || [:STRENGTH,:WOODHAMMER,:DUALCHOP,
           :HEATCRASH,:SKYDROP,:ICICLECRASH,:BODYSLAM,:STOMP,:GIGAIMPACT,:POUND,:SMACKDOWN,
           :IRONTAIL,:KNOCKOFF,:CRABHAMMER,:DRAGONRUSH,:BOUNCE,:SLAM,:HEAVYSLAM,:HIGHHORSEPOWER,
           :ICEHAMMER,:DRAGONHAMMER,:BRUTALSWING,:STOMPINGTANTRUM,:SUCKERPUNCH,:ROCKSLIDE,
           :AVALANCHE,:THROATCHOP,:LUNGE,:SUNSTEELSTRIKE,:BEHEMOTHBASH,:GRAVAPPLE,
           :CONTINENTALCRUSH,:CORKSCREWCRASH,:SUBZEROSLAMMER,:PULVERIZINGPANCAKE,:SEARINGSUNRAZESMASH].include?(@id)
          if @battle.field.effects[PBEffects::StrikeValue] == 0
            @battle.pbDisplay(_INTL("WHAMMO!")) if showMessages
            if user.hasActiveAbility?([:HUGEPOWER,:GUTS,:PUREPOWER,:SHEERFORCE,:STEADFAST,
               :IRONFIST,:SUPERLUCK,:COMPETITIVE,:GORILLATACTICS])
              @battle.field.effects[PBEffects::StrikeValue] = 9 + @battle.pbRandom(7)
            else
              @battle.field.effects[PBEffects::StrikeValue] = 1 + @battle.pbRandom(15)
            end
            @battle.field.effects[PBEffects::StrikeValue] += user.stages[:ATTACK]
          end
          if @battle.field.effects[PBEffects::StrikeValue] >= 15
            @battle.pbDisplay(_INTL("...OVER 9000!!!")) if showMessages
            multipliers[:base_damage_multiplier] *= 3
          elsif @battle.field.effects[PBEffects::StrikeValue] >= 13
            @battle.pbDisplay(_INTL("...POWERFUL!")) if showMessages
            multipliers[:base_damage_multiplier] *= 2
          elsif @battle.field.effects[PBEffects::StrikeValue] >= 9
            @battle.pbDisplay(_INTL("...NICE!")) if showMessages
            multipliers[:base_damage_multiplier] *= 1.5
          elsif @battle.field.effects[PBEffects::StrikeValue] >= 3
            @battle.pbDisplay(_INTL("...OK!")) if showMessages
          else
            @battle.pbDisplay(_INTL("...WEAK!")) if showMessages
            multipliers[:base_damage_multiplier] *= 0.5
          end
        end
      when 13 # Icy Cave
        if user.effects[PBEffects::NeverMiss] # Message sort of played earlier
          multipliers[:base_damage_multiplier] *= 1.5
        end
      when 18 # Short-Circuit Field
        if types.include?(:ELECTRIC)
          @battle.field.effects[PBEffects::StrikeValue] = (@battle.field.effects[PBEffects::StrikeValue] + 1) % 6
          @battle.field.effects[PBEffects::StrikeValue] = 4 if [:THUNDERSHOCK,:SPARK,:ELECTROBALL,
                                                               :VOLTSWITCH,:CHAINLIGHTNING].include?(@id)
          case @battle.field.effects[PBEffects::StrikeValue]
          when 0
            @battle.pbDisplay(_INTL("Bzzt.")) if showMessages
            multipliers[:base_damage_multiplier] *= 0.8
          when 2
            @battle.pbDisplay(_INTL("Bzap!")) if showMessages
            multipliers[:base_damage_multiplier] *= 1.2
          when 3
            @battle.pbDisplay(_INTL("Bzzapp!")) if showMessages
            multipliers[:base_damage_multiplier] *= 1.5
          when 4
            @battle.pbDisplay(_INTL("BZZZAPP!")) if showMessages
            multipliers[:base_damage_multiplier] *= 2
          when 5
            @battle.pbDisplay(_INTL("Bzt...")) if showMessages
            multipliers[:base_damage_multiplier] *= 0.5
          end # when 1, x1
        end
      when 40 # Haunted Field
        if user.effects[PBEffects::HauntedScared] == target.index
          multipliers[:base_damage_multiplier] *= 0.5
          @battle.pbDisplay(_INTL("{1}'s fear of {2} decreased its damage against it!",user.pbThis,target.pbThis(true))) if showMessages
          user.effects[PBEffects::HauntedScared] = -1
          @battle.pbDisplay(_INTL("{1} got over its fear of {2}!",user.pbThis,target.pbThis(true))) if showMessages
        end
        if target.effects[PBEffects::HauntedScared] == user.index
          multipliers[:base_damage_multiplier] *= 1.5
          @battle.pbDisplay(_INTL("{1}'s fear of {2} increased its damage taken!",target.pbThis,user.pbThis(true))) if showMessages
        end
      when 48 # Beach
        if [:SURF,:SLUDGEWAVE,:MUDDYWATER,:THOUSANDWAVES,:STOKEDSPARKSURFER,:SHOCKWAVE].include?(@id)
          if @battle.field.effects[PBEffects::StrikeValue] == 0
            @battle.field.effects[PBEffects::StrikeValue] = 1 + @battle.pbRandom(15)
            @battle.pbDisplay(_INTL("{1} rode in a wave!",user.pbThis)) if showMessages
            if user.hasActiveAbility?([:COMPETITIVE,:DANCER,:LIMBER,:SCHOOLING,:SERENEGRACE,
               :SURGESURFER,:OWNTEMPO,:SWIFTSWIM,:WAVERIDER])
              @battle.field.effects[PBEffects::StrikeValue] = 9 + @battle.pbRandom(7)
            end
            @battle.field.effects[PBEffects::StrikeValue] += user.stages[:ACCURACY]
          end
          if @battle.field.effects[PBEffects::StrikeValue] >= 15
            @battle.pbDisplay(_INTL("Rode a tidal wave with extreme grace and precision!")) if showMessages
            multipliers[:base_damage_multiplier] *= 3
          elsif @battle.field.effects[PBEffects::StrikeValue] >=13
            @battle.pbDisplay(_INTL("Excellent precision on a large wave!")) if showMessages
            multipliers[:base_damage_multiplier] *= 2
          elsif @battle.field.effects[PBEffects::StrikeValue] >=9
            @battle.pbDisplay(_INTL("An average wave, but with good form!")) if showMessages
            multipliers[:base_damage_multiplier] *= 1.5
          elsif @battle.field.effects[PBEffects::StrikeValue] >=3
            @battle.pbDisplay(_INTL("The technique and wave were average.")) if showMessages
          else
            @battle.pbDisplay(_INTL("Should've chosen a bigger wave to ride...")) if showMessages
            multipliers[:base_damage_multiplier] *= 0.5
          end
        end
      end
      $feshutup += 1
      # Critical hits
      if target.damageState.critical
        if $fefieldeffect == 24
          multipliers[:final_damage_multiplier] *= (2.0*user.level+5.0)/(user.level+5.0)
        else
          multipliers[:final_damage_multiplier] *= 1.5
        end
      end
      # Random variance
      if !self.is_a?(PokeBattle_Confusion)
        random = 85+@battle.pbRandom(16)
        multipliers[:final_damage_multiplier] *= random / 100.0
      end
      # Recalculate the type modifier for Dragon Darts else it does 1 damage on its
      # second hit on a different target
      if @function == "17C" && @battle.pbSideSize(target.index)>1
        typeMod = self.pbCalcTypeMod(self.calcTypes,user,target)
        target.damageState.typeMod = typeMod
      end
      # Type effectiveness
      multipliers[:final_damage_multiplier] *= target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
      # Aurora Veil, Reflect, Light Screen
      if !ignoresReflect?(user) && !target.damageState.critical
        if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
          if @battle.pbSideBattlerCount(target)>1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
          else
            multipliers[:final_damage_multiplier] /= 2
          end
        elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
          if @battle.pbSideBattlerCount(target)>1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
          else
            multipliers[:final_damage_multiplier] /= 2
          end
        elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
          if @battle.pbSideBattlerCount(target) > 1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
          else
            multipliers[:final_damage_multiplier] /= 2
          end
        end
      end
      # Multi-targeting attacks
      if numTargets>1
        multipliers[:final_damage_multiplier] *= 0.75
      end
      # Move-specific base damage modifiers
      multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
      # Move-specific final damage modifiers
      multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
    end
  
    #=============================================================================
    # Additional effect chance
    #=============================================================================
    # Doesn't account for Sheer Force or Shield Dust
    def pbAdditionalEffectChance(user,target=nil,effectChance=0)
      #return 0 if target.hasShieldDust? && !@battle.moldBreaker
      return 0 if target && $fefieldeffect == 29 && (target.pbHasType?(:DARK) || target.pbHasType?(:GHOST))
      ret = (effectChance>0) ? effectChance : @addlEffect
      if $fefieldeffect == 40 && [:OMINOUSWIND,:LICK].include?(@id)
        ret *= 4
      elsif user.hasActiveAbility?(:SERENEGRACE) && $fefieldeffect != 40 && !([8,14,26].include?($fefieldeffect) && 
            user.grounded?)
        if [9,48].include?($fefieldeffect) || [27,28,43].include?($fefieldeffect) && user.airborne?
          ret *= 2.5
        else
          ret *= 2
        end
      elsif $fefieldeffect == 9
        ret *= 2
      elsif [13,46].include?($fefieldeffect) && ["00C","00D"].include?(@function)
        ret *= 2
      elsif $fefieldeffect == 29 && (user.pbHasType?(:FAIRY) || user.pbHasType?(:NORMAL) || 
            user.pbHasType?(:PSYCHIC))
        ret *= 2
      elsif [1,18].include?($fefieldeffect) && ["007","008"].include?(@function)
        ret *= 2
      elsif $fefieldeffect == 7 && [:SCALD,:STEAMERUPTION,:ICEBURN].include?(@id)
        ret *= 2
      elsif [19,26,44].include?($fefieldeffect) && flinchingMove?
        ret *= 2
      elsif $fefieldeffect == 40 && @id == :ASTONISH
      end
      ret = 100 if $DEBUG && Input.press?(Input::CTRL)
      ret = 100 if $fefieldeffect == 30 && @id == :MIRRORSHOT
      ret = 100 if $fefieldeffect == 4 && user.effects[PBEffects::NeverMiss]
      ret = 100 if [5,37].include?($fefieldeffect) && @id == :CONFUSION
      ret = 100 if user.hasActiveAbility?(:HOMINGCANNON) && beamMove?
      return ret
    end
  
    # NOTE: Flinching caused by a move's effect is applied in that move's code,
    #       not here.
    def pbFlinchChance(user,target)
      return 0 if flinchingMove?
      return 0 if target.hasShieldDust? && !@battle.moldBreaker
      ret = 0
      if user.hasActiveAbility?(:SNEAKATTACK,true) && user.effects[PBEffects::SneakAttack] &&
         !($fefieldeffect == 8 || user.grounded?) && ![30,43].include?($fefieldeffect)
        ret = 100
      elsif user.hasActiveAbility?(:ALPHABETIZATION) && user.checkAlphabetizationForm(27) &&
            !Effectiveness.not_very_effective?(target.damageState.typeMod)
        ret = 100
      elsif user.hasActiveAbility?(:STENCH,true) && ![22,27,28,43].include?($fefieldeffect) &&
         !($fefieldeffect == 33 && $fecounter >= 3)
        ret = 10
        ret *= 2 if $fefieldeffect == 8
      elsif user.hasActiveAbility?(:PICKPOCKET) && $fefieldeffect == 48
        ret = 10
      elsif user.hasActiveAbility?(:UNSEENFIST) && $fefieldeffect == 45
        ret = 10
      elsif punchingMove? && $fefieldeffect == 14
        ret = 10
      elsif @id == :DIG && $fefieldeffect == 23
        ret = 10
      elsif user.hasActiveItem?(:KINGSROCK,true)
        if $fefieldeffect == 5 && $fecounter%6 == 1 # King
          ret = 100
        elsif $fefieldeffect == 31
          ret = 20
        else
          ret = 10
        end
      elsif user.hasActiveItem?(:RAZORFANG,true)
        ret = 10
      end
      ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) || [19,26,44].include?($fefieldeffect)
      return ret
    end
  
    #=============================================================================
    # Priority Calculation
    #=============================================================================
    # Returns a value by which to offset priority of a move
    def pbChangePriority(user)
      return 0
    end
  end
  