class PokeBattle_Battle
    #=============================================================================
    # Decrement effect counters
    #=============================================================================
    def pbEORCountDownBattlerEffect(priority,effect,maintainFEDuration)
      priority.each do |b|
        next if b.fainted? || b.effects[effect]==0
        b.effects[effect] -= 1
        @field.effects[PBEffects::FEDuration] = 1 if maintainFEDuration
        yield b if block_given? && b.effects[effect]==0
      end
    end
  
    def pbEORCountDownSideEffect(side,effect,msg,maintainFEDuration)
      if @sides[side].effects[effect]>0
        @sides[side].effects[effect] -= 1
        @field.effects[PBEffects::FEDuration] = 1 if maintainFEDuration
        pbDisplay(msg) if @sides[side].effects[effect]==0
      end
    end
  
    def pbEORCountDownFieldEffect(effect,msg,maintainFEDuration)
      if @field.effects[effect]>0
        @field.effects[effect] -= 1
        @field.effects[PBEffects::FEDuration] = 1 if maintainFEDuration
        if @field.effects[effect]==0
          pbDisplay(msg)
          if effect==PBEffects::MagicRoom
            pbPriority(true).each { |b| b.pbItemTerrainStatBoostCheck }
          end
        end
      end
    end
  
    #=============================================================================
    # End Of Round weather
    #=============================================================================
    def pbEORWeather(priority)
      # NOTE: Primordial weather doesn't need to be checked here, because if it
      #       could wear off here, it will have worn off already.
      # Count down weather duration
      if $fefieldeffect == 12 && pbWeather != :Rain
        $fecounter = 0
      elsif $fefieldeffect == 27 && pbWeather != :Hail
        $fecounter = 0
      end
      @field.weatherDuration -= 1 if @field.weatherDuration>0
      # Weather wears off
      if @field.weatherDuration==0
        case @field.weather
        when :Sun
          pbDisplay(_INTL("The sunlight faded."))
        when :Rain
          pbDisplay(_INTL("The rain stopped."))
        when :Sandstorm
          pbDisplay(_INTL("The sandstorm subsided."))
        when :Hail
          pbDisplay(_INTL("The hail stopped."))
        when :ShadowSky
          pbDisplay(_INTL("The shadow sky faded."))
        when :Fog
          pbDisplay(_INTL("The fog disappeared."))
        when :HarshSun
          pbDisplay(_INTL("The harsh sunlight faded!"))
        when :HeavyRain
          pbDisplay(_INTL("The heavy rain has lifted!"))
        when :StrongWinds
          pbDisplay(_INTL("The strong winds have dissipated!"))
        end
        @field.weather = :None
        # Check for form changes caused by the weather changing
        eachBattler { |b| b.pbCheckFormOnWeatherChange }
        # Start up the default weather
        pbStartWeather(nil,@field.defaultWeather) if @field.defaultWeather != :None
        return if @field.weather == :None
      end
      # Weather continues
      case @field.weather
      when :Sun
        pbCommonAnimation("Sunny")
        #pbDisplay(_INTL("The sunlight is strong."))
        if $fefieldeffect == 25 && $febackup == 4 || $fefieldeffect == 0 && $febackup == 34
          @field.effects[PBEffects::FEDuration] += 1
        end
      when :Rain
        pbCommonAnimation("Rain")
        #pbDisplay(_INTL("Rain continues to fall."))
        if $fefieldeffect == 23 && $febackup == 7 || $fefieldeffect == 0 && $febackup == 34
          @field.effects[PBEffects::FEDuration] += 1
        elsif $fefieldeffect == 12
          $fecounter+=1
          if $fecounter == 3
            changeField(49,"The desert grew some shrubs!",0,true)
          end
        end
      when :Sandstorm
        pbCommonAnimation("Sandstorm")
        pbDisplay(_INTL("The sandstorm is raging."))
        if $fefieldeffect == 0 && $febackup == 9 || $fefieldeffect == 0 && $febackup == 34
          @field.effects[PBEffects::FEDuration] += 1
        end
      when :Hail
        pbCommonAnimation("Hail")
        pbDisplay(_INTL("The hail is crashing down."))
        if $fefieldeffect == 0 && $febackup == 9 || $fefieldeffect == 0 && $febackup == 34
          @field.effects[PBEffects::FEDuration] += 1
        elsif $fefieldeffect == 27
          $fecounter+=1
          if $fecounter == 3
            changeField(28,"The mountain was covered in snow!",0,true)
          end
        end
      when :HarshSun
        pbCommonAnimation("Sunny")
        pbDisplay(_INTL("The sunlight is extremely harsh."))
        if $fefieldeffect == 25 && $febackup == 4 || $fefieldeffect == 0 && $febackup == 8 || 
           $fefieldeffect == 12 && ($febackup == 20 || $febackup == 48 || $febackup == 49) || 
           $fefieldeffect == 48 && $febackup == 21 || $fefieldeffect == 21 && $febackup == 22
          @field.effects[PBEffects::FEDuration] += 1
        end
      when :HeavyRain
        pbCommonAnimation("Rain")
        pbDisplay(_INTL("It is raining heavily."))
        if $fefieldeffect == 23 && ($febackup == 7 || $febackup == 32) || $fefieldeffect == 28 &&
           $febackup == 16 || $fefieldeffect == 21 && ($febackup == 20 || $febackup == 48)
          @field.effects[PBEffects::FEDuration] += 1
        end
      when :StrongWinds
        pbCommonAnimation("Wind")
        #pbDisplay(_INTL("The wind is strong."))
        if $fefieldeffect == 0 && ($febackup == 3 || $febackup == 11) || $fefieldeffect == 48 && 
           $febackup == 20
          @field.effects[PBEffects::FEDuration] += 1
        end
      when :ShadowSky
        pbDisplay(_INTL("The shadow sky continues."))
      end
      # Effects due to weather
      priority.each do |b|
        # Weather-related abilities
        #BattleHandlers.triggerEORWeatherAbility(b.ability,curWeather,b,self)
        if !b.hasUtilityUmbrella?
          if b.hasActiveAbility?(:DRYSKIN)
            hpGain = 0
            if [:Sun,:HarshSun].include?(pbWeather)
              hpGain -= b.totalhp/8 if b.takesIndirectDamage?
            elsif [:Rain,:HeavyRain].include?(pbWeather) && b.canHeal?
              hpGain += b.totalhp/8
            end
            if [11,41].include?($fefieldeffect) && !b.pbHasType?(:STEEL)
              if !b.pbHasType?(:POISON)
                hpGain -= b.totalhp/8 if b.takesIndirectDamage?
              elsif b.canHeal?
                hpGain += b.totalhp/8
              end
            elsif [12,48,49].include?($fefieldeffect)
              hpGain -= b.totalhp/8 if b.takesIndirectDamage?
            elsif $fefieldeffect == 3
              hpGain += b.totalhp/16
            elsif $fefieldeffect == 8 && b.grounded?
              hpGain += b.totalhp/8
            end
            if hpGain > 0
              b.pbRecoverHP(hpGain)
              pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
            elsif hpGain < 0
              if b.pbReduceHP(hpGain*-1) > 0
                pbDisplay(_INTL("{1}'s {2} was hurt by the environment!",b.pbThis,b.abilityName))
                b.pbItemHPHealCheck
              end
            end
          end
          if b.hasActiveAbility?(:SOLARPOWER)
            hpGain = 0
            if [:Sun,:HarshSun].include?(pbWeather)
              hpGain -= b.totalhp/8 if b.takesIndirectDamage?
            end
            if [12,49].include?($fefieldeffect)
              hpGain -= b.totalhp/8 if b.takesIndirectDamage?
            end
            if b.pbReduceHP(hpGain*-1) > 0
              pbDisplay(_INTL("{1} was hurt by the sunlight!",b.pbThis))
              b.pbItemHPHealCheck
            end
          end
          if b.hasActiveAbility?(:RAINDISH) && ![13,46].include?($fefieldeffect)
            hpGain = 0
            if [:Rain,:HeavyRain].include?(pbWeather) && b.canHeal?
              hpGain += b.totalhp/16
            end
            if [3,22].include?($fefieldeffect) || $fefieldeffect == 21 && b.grounded?
              hpGain += b.totalhp/16 if b.canHeal?
            elsif $fefieldeffect == 26 && b.grounded?
              if b.pbHasType?(:POISON) && b.canHeal?
                hpGain += b.totalhp/16
              elsif !b.pbHasType?(:STEEL)
                hpGain -= b.totalhp/16 if b.takesIndirectDamage?
              end
            end
            if hpGain > 0
              b.pbRecoverHP(hpGain)
              pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
            elsif hpGain < 0
              if b.pbReduceHP(hpGain*-1) > 0
                pbDisplay(_INTL("{1}'s {2} absorbed dirty water!",b.pbThis,b.abilityName))
                b.pbItemHPHealCheck
              end
            end
          end
          if b.canHeal?
            if b.hasActiveAbility?(:SUNSHADE) && $fefieldeffect != 38
              hpGain = 0
              if [:Sun,:HarshSun].include?(pbWeather)
                hpGain += b.totalhp/16
              end
              if [12,48,49].include?($fefieldeffect)
                hpGain += b.totalhp/16
              end
              b.pbRecoverHP(hpGain)
              pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
            end
            if b.hasActiveAbility?(:SANDBATH) && !([8,21,26].include?($fefieldeffect) && 
               b.grounded?)
              hpGain = 0
              if pbWeather == :Sandstorm
                hpGain += b.totalhp/16
              end
              if [12,20,48,49].include?($fefieldeffect)
                hpGain += b.totalhp/16
              end
              b.pbRecoverHP(hpGain)
              pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
            end
          end
        end
        if b.hasActiveAbility?(:ICEBODY) && b.canHeal?
          hpGain = 0
          if pbWeather == :Hail
            hpGain += b.totalhp/16
          end
          if [13,28,39,46].include?($fefieldeffect)
            hpGain += b.totalhp/16
          end
          if hpGain > 0
            b.pbRecoverHP(hpGain)
            pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
          end
        end
        b.pbFaint if b.fainted?
        # Weather damage
        case pbWeather
        when :Sandstorm
          next if !b.takesSandstormDamage?
          pbDisplay(_INTL("{1} is buffeted by the sandstorm!",b.pbThis))
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/16,false)
          b.pbItemHPHealCheck
          b.pbFaint if b.fainted?
        when :Hail
          next if !b.takesHailDamage?
          pbDisplay(_INTL("{1} is buffeted by the hail!",b.pbThis))
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/16,false)
          b.pbItemHPHealCheck
          b.pbFaint if b.fainted?
        when :ShadowSky
          next if !b.takesShadowSkyDamage?
          pbDisplay(_INTL("{1} is hurt by the shadow sky!",b.pbThis))
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/16,false)
          b.pbItemHPHealCheck
          b.pbFaint if b.fainted?
        end
      end
    end
  
    #=============================================================================
    # End Of Round Field Effects
    #=============================================================================
    def pbEORFieldEffect(priority)
      # Count down field duration
      if @field.effects[PBEffects::FEDuration]>0
        @field.effects[PBEffects::FEDuration]-=1
        @field.effects[PBEffects::FEDuration]+=1 if pbCheckGlobalAbility(:AMBIENTCONNECTION)
        if @field.effects[PBEffects::FEDuration]==0
          changeField($febackup,"The terrain returned to normal.")
        end
      end
      @field.effects[PBEffects::PrevFECounter] = $fecounter
      rotateChessField
    end
  
    #=============================================================================
    # End Of Round shift distant battlers to middle positions
    #=============================================================================
    def pbEORShiftDistantBattlers
      # Move battlers around if none are near to each other
      # NOTE: This code assumes each side has a maximum of 3 battlers on it, and
      #       is not generalised to larger side sizes.
      if !singleBattle?
        swaps = []   # Each element is an array of two battler indices to swap
        for side in 0...2
          next if pbSideSize(side)==1   # Only battlers on sides of size 2+ need to move
          # Check if any battler on this side is near any battler on the other side
          anyNear = false
          eachSameSideBattler(side) do |b|
            eachOtherSideBattler(b) do |otherB|
              next if !nearBattlers?(otherB.index,b.index)
              anyNear = true
              break
            end
            break if anyNear
          end
          break if anyNear
          # No battlers on this side are near any battlers on the other side; try
          # to move them
          # NOTE: If we get to here (assuming both sides are of size 3 or less),
          #       there is definitely only 1 able battler on this side, so we
          #       don't need to worry about multiple battlers trying to move into
          #       the same position. If you add support for a side of size 4+,
          #       this code will need revising to account for that, as well as to
          #       add more complex code to ensure battlers will end up near each
          #       other.
          eachSameSideBattler(side) do |b|
            # Get the position to move to
            pos = -1
            case pbSideSize(side)
            when 2 then pos = [2,3,0,1][b.index]   # The unoccupied position
            when 3 then pos = (side==0) ? 2 : 3    # The centre position
            end
            next if pos<0
            # Can't move if the same trainer doesn't control both positions
            idxOwner = pbGetOwnerIndexFromBattlerIndex(b.index)
            next if pbGetOwnerIndexFromBattlerIndex(pos)!=idxOwner
            swaps.push([b.index,pos])
          end
        end
        # Move battlers around
        swaps.each do |pair|
          next if pbSideSize(pair[0])==2 && swaps.length>1
          next if !pbSwapBattlers(pair[0],pair[1])
          case pbSideSize(side)
          when 2
            pbDisplay(_INTL("{1} moved across!",@battlers[pair[1]].pbThis))
          when 3
            pbDisplay(_INTL("{1} moved to the center!",@battlers[pair[1]].pbThis))
          end
        end
      end
    end
  
    #=============================================================================
    # End Of Round phase
    #=============================================================================
    def pbEndOfRoundPhase
      PBDebug.log("")
      PBDebug.log("[End of round]")
      @endOfRound = true
      @scene.pbBeginEndOfRoundPhase
      pbCalculatePriority           # recalculate speeds
      priority = pbPriority(true)   # in order of fastest -> slowest speeds only
      # Weather
      pbEORWeather(priority)
      # Future Sight/Doom Desire
      @positions.each_with_index do |pos,idxPos|
        next if !pos || pos.effects[PBEffects::FutureSightCounter]==0
        pos.effects[PBEffects::FutureSightCounter] -= 1
        next if pos.effects[PBEffects::FutureSightCounter]>0
        next if !@battlers[idxPos] || @battlers[idxPos].fainted?   # No target
        moveUser = nil
        eachBattler do |b|
          next if b.opposes?(pos.effects[PBEffects::FutureSightUserIndex])
          next if b.pokemonIndex!=pos.effects[PBEffects::FutureSightUserPartyIndex]
          moveUser = b
          break
        end
        next if moveUser && moveUser.index==idxPos   # Target is the user
        if !moveUser   # User isn't in battle, get it from the party
          party = pbParty(pos.effects[PBEffects::FutureSightUserIndex])
          pkmn = party[pos.effects[PBEffects::FutureSightUserPartyIndex]]
          if pkmn && pkmn.able?
            moveUser = PokeBattle_Battler.new(self,pos.effects[PBEffects::FutureSightUserIndex])
            moveUser.pbInitDummyPokemon(pkmn,pos.effects[PBEffects::FutureSightUserPartyIndex])
          end
        end
        next if !moveUser   # User is fainted
        move = pos.effects[PBEffects::FutureSightMove]
        pbDisplay(_INTL("{1} took the {2} attack!",@battlers[idxPos].pbThis,
           GameData::Move.get(move).name))
        # NOTE: Future Sight failing against the target here doesn't count towards
        #       Stomping Tantrum.
        userLastMoveFailed = moveUser.lastMoveFailed
        @futureSight = true
        moveUser.pbUseMoveSimple(move,idxPos)
        @futureSight = false
        moveUser.lastMoveFailed = userLastMoveFailed
        @battlers[idxPos].pbFaint if @battlers[idxPos].fainted?
        pos.effects[PBEffects::FutureSightCounter]        = 0
        pos.effects[PBEffects::FutureSightMove]           = nil
        pos.effects[PBEffects::FutureSightUserIndex]      = -1
        pos.effects[PBEffects::FutureSightUserPartyIndex] = -1
      end
      # Wish
      @positions.each_with_index do |pos,idxPos|
        next if !pos || pos.effects[PBEffects::Wish]==0
        pos.effects[PBEffects::Wish] -= 1
        next if pos.effects[PBEffects::Wish]>0
        next if !@battlers[idxPos] || !@battlers[idxPos].canHeal?
        wishMaker = pbThisEx(idxPos,pos.effects[PBEffects::WishMaker])
        @battlers[idxPos].pbRecoverHP(pos.effects[PBEffects::WishAmount])
        pbDisplay(_INTL("{1}'s wish came true!",wishMaker))
      end
      # Sea of Fire damage (Fire Pledge + Grass Pledge combination)
      curWeather = pbWeather
      for side in 0...2
        next if sides[side].effects[PBEffects::SeaOfFire]==0
        next if [:Rain, :HeavyRain].include?(curWeather)
        pbCommonAnimation("SeaOfFire") if side==0
        pbCommonAnimation("SeaOfFireOpp") if side==1
        priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:FIRE)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/8,false)
          pbDisplay(_INTL("{1} is hurt by the sea of fire!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
      end
      # Field Effects
      case $fefieldeffect # Effects that happen to field
      when 12 # Desert
        if pbRandom(5) == 0 && pbWeather == :None
          pbStartWeather(nil,:Sun,true)
        end
      when 27 # Mountain
        if pbRandom(5) == 0 && pbWeather == :None
          pbStartWeather(nil,:StrongWinds,true)
        end
      when 28 # Snowy Mountain
        if pbRandom(5) == 0 && pbWeather == :None
          pbStartWeather(nil,:Hail,true)
        end
      when 47 # Jungle
        if pbRandom(5) == 0 && pbWeather == :None
          pbStartWeather(nil,:Rain,true)
        end
      when 49 # Xeric Shrubland
        if pbRandom(5) == 0 && pbWeather == :None
          pbStartWeather(nil,:Sandstorm,true)
        end
      end
      priority.each do |b|
        next if b.fainted?
        oldHP = b.hp
        case $fefieldeffect # Effects that happen to battlers
        when 1 # Electric Terrain
          if b.grounded?
            if b.hasActiveAbility?(:VOLTABSORB) && b.canHeal?
              b.pbRecoverHP(b.totalhp/16)
              pbDisplay(_INTL("{1} absorbed stray electricity!",b.pbThis))
            end
            if !b.hasActiveItem?(:HEAVYDUTYBOOTS)
              if !b.pbHasType?(:ELECTRIC) && b.hasActiveAbility?(:WATERVEIL)
                b.pbInflictTypeScalingFixedDamage(:ELECTRIC,b.totalhp/8,_INTL("{1} was zapped by the stray electricity!",b.pbThis))
              end
              if b.turnCount > 0 && !b.frozen?
                if b.pbRaiseStatStageByCause(:SPEED,1,nil,nil)
                  pbDisplay(_INTL("The energetic atmosphere boosted {1}'s Speed!",b.pbThis(true)))
                  if b.hasActiveAbility?([:STATIC,:HUSTLE,:VITALSPIRIT,:MOTORDRIVE,:RATTLED,:TERAVOLT])
                    b.pbRaiseStatStageByAbility(:SPEED,1,b)
                  end
                end
              end
            end
          end
        when 2 # Grassy Terrain
          if b.canHeal?
            if b.grounded? && !b.hasActiveAbility?(:OVERCOAT) && !b.hasActiveItem?(:HEAVYDUTYBOOTS)
              b.pbRecoverHP(b.totalhp/16)
              pbDisplay(_INTL("The grassy terrain restored some of {1}'s HP.",b.pbThis(true)))
            end
            if b.hasActiveAbility?(:HONEYGATHER)
              b.pbRecoverHP(b.totalhp/16)
              pbDisplay(_INTL("{1}'s {2} restored some of its HP!",b.pbThis,b.abilityName))
            end
          end
          if b.hasActiveAbility?(:NATURALCURE)
            b.pbCureStatus
          end
        when 3 # Misty Terrain
          if b.hasActiveAbility?([:WATERVEIL,:SPONGE]) && b.canHeal?
            b.pbRecoverHP(b.totalhp/16)
            pbDisplay(_INTL("{1}'s {2} restored some of its HP!",b.pbThis,b.abilityName))
          end
        when 5 # Chess Board
          if b.hasActiveAbility?(:STALL) && b.canHeal?
            b.pbRecoverHP(b.totalhp/16)
            pbDisplay(_INTL("{1}'s {2} restored some of its HP!",b.pbThis,b.abilityName))
          end
          if b.hasActiveAbility?(:OBLIVIOUS) && b.turnCount > 0
            b.pbLowerStatStageByAbility(:SPEED,1,b)
          end
        when 7 # Volcanic Field
          if b.hasActiveAbility?(:FLASHFIRE)
            b.activateFlashFire
          end
          if b.takesVolcanicFieldDamage?
            quotient = 8
            quotient /= 2 if b.hasActiveAbility?([:LEAFGUARD,:ICEBODY,:FLUFFY,:GRASSPELT,:FURCOAT,:TOUGHBARK,:COTTONDOWN])
            b.pbInflictTypeScalingFixedDamage(:FIRE,b.totalhp/quotient,_INTL("{1} was burned by the field!",b.pbThis))
          end
        when 8 # Swamp Field
          if b.grounded?
            if b.affectedBySwamp?
              if b.pbLowerStatStageByCause(:SPEED,1,nil,nil)
                pbDisplay(_INTL("{1}'s Speed sank...",b.pbThis))
                if b.hasActiveAbility?([:BATTLEARMOR,:TANGLEDFEET,:HEAVYMETAL])
                  if b.pbLowerStatStageByCause(:SPEED,1,nil,nil)
                    pbDisplay(_INTL("{1}'s cumbersome {2} caused its Speed to sink further.",b.pbThis,b.abilityName))
                  end
                end
                if b.effects[PBEffects::TrappingMove] == :SANDTOMB
                  if b.pbLowerStatStageByCause(:SPEED,1,nil,nil)
                    pbDisplay(_INTL("{1}'s Speed sank further in the quicksand...",b.pbThis))
                  end
                end
                if b.asleep?
                  if b.pbLowerStatStageByCause(:SPEED,1,nil,nil)
                    pbDisplay(_INTL("{1}'s Speed sank further while asleep...",b.pbThis))
                  end
                end
              elsif b.stages[:SPEED] == -6 && !b.pbHasType?(:WATER) && !b.pbHasType?(:GROUND) && 
                    !b.pbHasType?(:POISON)
                if b.pbReduceHP(b.totalhp,true,true,true,true)
                  pbDisplay(_INTL("{1} was completely engulfed by the swamp!",b.pbThis))
                end
              end
            end
            if b.status == :BURN
              b.pbCureStatus
            end
            if b.hasActiveAbility?(:WATERCOMPACTION)
              b.pbRaiseStatStageByAbility(:DEFENSE,2,b)
            end
          end
        when 9 # Rainbow Field
          b.effects[PBEffects::NewTypeRoll] = true
          if b.asleep? && b.canHeal?
            b.pbRecoverHP(b.totalhp/16)
            pbDisplay(_INTL("{1} recovered health in its peaceful sleep!",b.pbThis))
          end
          if b.hasActiveAbility?([:CLOUDNINE,:PASTELVEIL])
            b.pbRaiseStatStageByAbility(generateRandomStat,1,b)
          end
        when 10 # Corrosive Field
          if b.hasActiveAbility?(:GRASSPELT) && b.takesCorrosiveFieldDamage?
            b.pbInflictTypeScalingFixedDamage(:POISON,b.totalhp/8,_INTL("{1}'s {2} was corroded!",b.pbThis,b.abilityName))
          end
          if b.hasActiveAbility?(:FLYTRAP)
            b.eachNearOpposing do |a|
              if a.pbHasType?(:BUG)
                a.pbReduceHP(a.totalhp/8)
                pbDisplay(_INTL("{1} dissolved a bit while trapped by {2}!",a.pbThis,b.pbThis(true)))
              end
            end
          end
        when 11 # Corrosive Mist Field
          if b.affectedByCorrosiveMist?
            if b.hasActiveAbility?([:WATERVEIL,:WATERABSORB,:RAINDISH,:WATERBUBBLE])
              b.pbPoison(nil,_INTL("{1} was badly poisoned by the corrosive mist!",b.pbThis),true)
            else
              b.pbPoison(nil,_INTL("{1} was poisoned by the corrosive mist!",b.pbThis))
            end
          end
          if b.hasActiveAbility?([:POISONHEAL,:AIRFILTRATION]) && b.canHeal?
            b.pbRecoverHP(b.totalhp/8)
            pbDisplay(_INTL("{1} was healed by the corrosive mist!",b.pbThis))
          end
          if b.hasActiveAbility?(:SPONGE)
            if !b.pbHasType?(:POISON)
              b.pbReduceHP(b.totalhp/8)
              pbDisplay(_INTL("{1} absorbed corrosive mist!",b.pbThis))
            elsif canHeal?
              b.pbRecoverHP(b.totalhp/8)
              pbDisplay(_INTL("{1} absorbed corrosive mist!",b.pbThis))
            end
          end
          if b.hasActiveAbility?([:MAGMAARMOR,:FLAMEBODY,:TURBOBLAZE,:STEAMENGINE,:FLASHFIRE])
            b.activateFlashFire
          end
          if pbCheckGlobalAbility(:NEUTRALIZINGGAS) && !b.hasActiveAbility?(:NEUTRALIZINGGAS)
            if b.LowerStatStageByCause(:ACCURACY,1,nil,nil)
              pbDisplay(_INTL("{1}'s Accuracy was decreased from the Neutralizing Gas!",b.pbThis))
            end
          end
        when 12 # Desert Field
          if b.hasActiveAbility?([:HUSTLE,:OVERCOAT,:FURCOAT])
            if b.pbLowerStatStageByCause(:SPEED,1,b,nil)
              pbDisplay(_INTL("The heat quickly drains {1}'s energy, lowering its Speed!",b.pbThis(true)))
            end
          end
        when 13 # Icy Cave
          if b.hasActiveAbility?(:ICEFACE,false,true) && b.form == 1 && pbRandom(2) == 0
            b.pbChangeForm(0,_INTL("{1} transformed!",b.pbThis))
          end
        when 15 # Forest Field
          if b.canHeal?
            if b.hasActiveAbility?(:SAPSIPPER)
              b.pbRecoverHP(b.totalhp/16)
              pbDisplay(_INTL("{1} drank tree sap to recover!",b.pbThis))
            end
            if b.hasActiveAbility?(:HONEYGATHER)
              b.pbRecoverHP(b.totalhp/16)
              pbDisplay(_INTL("{1}'s {2} restored some of its HP!",b.pbThis,b.abilityName))
            end
          end
          if b.hasActiveAbility?(:NATURALCURE)
            b.pbCureStatus
          end
        when 16 # Volcano Top Field
          if @field.effects[PBEffects::VolTopEruption]
            if !b.pbHasType?(:FIRE) && !b.hasActiveAbility?([:MAGMAARMOR,:FLASHFIRE,
               :FLAREBOOST,:BLAZE,:FLAMEBODY,:SOLIDROCK,:STURDY,:BATTLEARMOR,:SHELLARMOR,
               :WATERBUBBLE,:WONDERGUARD,:PRISMARMOR,:HEATPROOF,:TURBOBLAZE]) && !b.effects[PBEffects::AquaRing] &&
               !b.pbOwnSide.effects[PBEffects::WideGuard]
              quotient = 8
              if pbCheckGlobalAbility([:PRESSURE,:AFTERMATH])
                quotient /= 2
              end
              b.pbInflictTypeScalingFixedDamage(:FIRE,b.totalhp/quotient,_INTL("{1} is hurt by the eruption!",b.pbThis))
            end
            if b.hasActiveAbility?(:MAGMAARMOR)
              b.pbRaiseStatStageByAbility([:DEFENSE,:SPECIAL_DEFENSE],1,b)
            end
            if b.hasActiveAbility?([:FLAREBOOST,:TURBOBLAZE])
              b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,b)
            end
            if b.hasActiveAbility?(:STEAMENGINE)
              b.pbRaiseStatStageByAbility(:SPEED,6,b)
            end
            if b.hasActiveAbility?(:FLASHFIRE)
              b.activateFlashFire
            end
            if b.status == :SLEEP && !b.hasActiveAbility?(:SOUNDPROOF) # Don't use ".asleep?"
              b.pbCureStatus(false)
              pbDisplay(_INTL("The eruption woke up {1}!",b.pbThis(true)))
            end
            if b.effects[PBEffects::LeechSeed] >= 0
              b.effects[PBEffects::LeechSeed] = -1
              pbDisplay(_INTL("{1}'s Leech Seed burned away in the eruption!",b.pbThis))
            end
            if b.pbOwnSide.effects[PBEffects::Spikes] > 0
              b.pbOwnSide.effects[PBEffects::Spikes] = 0
              pbDisplay(_INTL("{1}'s Spikes were scattered during the eruption!",b.pbTeam))
            end
            if b.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
              b.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
              pbDisplay(_INTL("{1}'s Toxic Spikes were scattered during the eruption!",b.pbTeam))
            end
            if b.pbOwnSide.effects[PBEffects::StealthRock]
              b.pbOwnSide.effects[PBEffects::StealthRock] = false
              pbDisplay(_INTL("{1}'s Stealth Rocks were scattered during the eruption!",b.pbTeam))
            end
            if b.pbOwnSide.effects[PBEffects::StickyWeb]
              b.pbOwnSide.effects[PBEffects::StickyWeb] = false
              pbDisplay(_INTL("{1}'s Sticky Web burned away during the eruption!",b.pbTeam))
            end
          end
        when 18 # Short-Circuit Field
          if b.hasActiveAbility?(:VOLTABSORB) && b.canHeal?
            b.pbRecoverHP(b.totalhp/16)
            pbDisplay(_INTL("{1} absorbed stray electricity!",b.pbThis))
          end
          if !b.pbHasType?(:ELECTRIC) && b.hasActiveAbility?(:WATERVEIL)
            b.pbInflictTypeScalingFixedDamage(:ELECTRIC,b.totalhp/8,_INTL("{1} was zapped by the stray electricity!",b.pbThis))
          end
          if b.affectedByShortCircuit?
            if pbRandom(4) == 0 || b.hasActiveAbility?([:WATERVEIL,:WATERBUBBLE])
              b.pbParalyze(nil,_INTL("{1} was paralyzed by a stray wire!",b.pbThis))
            end
          end
        when 19 # Wasteland
          if b.hasActiveAbility?(:POISONHEAL) && b.canHeal? && b.grounded? && !b.hasActiveItem?(:HEAVYDUTYBOOTS)
            b.pbRecoverHP(b.totalhp/8)
            pbDisplay(_INTL("{1} was healed by the toxic waste!",b.pbThis))
          end
          if b.effects[PBEffects::WasteAnger] >= 3 && !b.pbHasType?(:POISON) && b.grounded? &&
             !b.hasActiveAbility?([:POISONHEAL,:GOOEY,:QUICKFEET])
            b.pbReduceHP(b.hp,true,true,true,true)
            pbDisplay(_INTL("{1} was swallowed up by the waste!",b.pbThis))
          end
        when 20 # Ashen Beach
          if pbCheckGlobalAbility(:WHITESMOKE) && !b.hasActiveAbility?(:WHITESMOKE)
            if b.pbLowerStatStageByCause(:ACCURACY,1,nil,nil)
              pbDisplay(_INTL("{1}'s Accuracy was decreased from the White Smoke!",b.pbThis))
            end
          end
          if pbCheckGlobalAbility(:NEUTRALIZINGGAS) && !b.hasActiveAbility?(:NEUTRALIZINGGAS)
            if b.pbLowerStatStageByCause(:ACCURACY,1,nil,nil)
              pbDisplay(_INTL("{1}'s Accuracy was decreased from the Neutralizing Gas!",b.pbThis))
            end
          end
        when 21 # Water Surface
          if b.grounded?
            if b.hasActiveAbility?([:WATERABSORB,:FILTER,:DRYSKIN]) && b.canHeal?
              b.pbRecoverHP(b.totalhp/16)
              pbDisplay(_INTL("{1} absorbed some of the water!",b.pbThis))
            end
            if !b.pbHasType?(:ELECTRIC) && pbCheckGlobalAbility(:STATIC)
              b.pbInflictTypeScalingFixedDamage(:ELECTRIC,b.totalhp/8,_INTL("{1} was electrocuted by the static electricity!",b.pbThis))
            end
            if b.hasActiveAbility?(:WATERCOMPACTION)
              b.pbRaiseStatStageByAbility(:DEFENSE,2,b)
            end
          end
        when 22 # Underwater
          if b.hasActiveAbility?([:WATERABSORB,:FILTER,:DRYSKIN]) && b.canHeal?
            b.pbRecoverHP(b.totalhp/8)
            pbDisplay(_INTL("{1} absorbed some of the water!",b.pbThis))
          end
          if b.takesUnderwaterFieldDamage?
            quotient = 8
            if b.hasActiveAbility?([:FLAMEBODY,:MAGMAARMOR])
              quotient /= 2
            end
            if pbCheckGlobalAbility(:PRESSURE)
              quotient /= 2
            end
            b.pbInflictTypeScalingFixedDamage(:WATER,b.totalhp/quotient,_INTL("{1} struggled in the water!",b.pbThis))
          end
          if !b.pbHasType?(:ELECTRIC) && pbCheckGlobalAbility(:STATIC)
            b.pbInflictTypeScalingFixedDamage(:ELECTRIC,b.totalhp/8,_INTL("{1} was electrocuted by the static electricity!",b.pbThis))
          end
          if b.hasActiveAbility?(:WATERCOMPACTION)
            b.pbRaiseStatStageByAbility(:DEFENSE,2,b)
          end
        when 26 # Murkwater Surface
          if b.affectedByMurkwaterSurface? && b.turnCount > 0
            if b.pbLowerStatStageByCause(:SPECIAL_DEFENSE,1,nil,nil)
              pbDisplay(_INTL("The toxic water eroded away at {1}'s Sp. Def.",b.pbThis(true)))
              if b.hasActiveAbility?([:FLAMEBODY,:MAGMAARMOR,:DRYSKIN,:WATERABSORB,:FLOWERVEIL,:FLOWERGIFT])
                if b.pbLowerStatStageByCause(:SPECIAL_DEFENSE,1,nil,nil)
                  pbDisplay(_INTL("{1}'s {2} caused its Sp. Def to erode away even further!",b.pbThis,b.abilityName))
                end
              end
              if b.effects[PBEffects::TwoTurnAttack] == :DIVE
                if b.pbLowerStatStageByCause(:SPECIAL_DEFENSE,1,nil,nil)
                  pbDisplay(_INTL("{1}'s Sp. Def eroded away even further while underwater.",b.pbThis))
                end
              end
              if b.effects[PBEffects::TrappingMove] == :WHIRLPOOL
                if b.pbLowerStatStageByCause(:SPECIAL_DEFENSE,1,nil,nil)
                  pbDisplay(_INTL("{1}'s Sp. Def eroded away even further while enveloped in the whirlpool.",b.pbThis))
                end
              end
            elsif b.stages[:SPECIAL_DEFENSE] == -6
              if b.pbReduceHP(b.totalhp,true,true,true,true)
                pbDisplay(_INTL("{1} eroded away completely!",b.pbThis))
              end
            end
          end
          if b.grounded?
            if (b.hasActiveAbility?(:POISONHEAL) || b.pbHasType?(:POISON) && b.hasActiveAbility?(:WATERABSORB)) &&
               b.canHeal?
              b.pbRecoverHP(b.totalhp/8)
              pbDisplay(_INTL("{1} was healed by the toxic water!",b.pbThis))
            end
            if b.hasActiveAbility?(:WATERCOMPACTION)
              b.pbRaiseStatStageByAbility(:DEFENSE,2,b)
            end
          end
        when 27 # Mountain
          if b.hasActiveAbility?(:AIRFILTRATION) && b.canHeal? && pbWeather == :StrongWinds
            b.pbRecoverHP(b.totalhp/8)
            pbDisplay(_INTL("{1}'s {2} filtered the strong winds into health!",b.pbThis,b.abilityName))
          end
        when 28 # Snowy Mountain
          if b.hasActiveAbility?(:ICEFACE,false,true) && b.form == 1 && pbRandom(2) == 0
            b.pbChangeForm(0,_INTL("{1} transformed!",b.pbThis))
          end
          if b.hasActiveAbility?(:AIRFILTRATION) && b.canHeal? && pbWeather == :StrongWinds
            b.pbRecoverHP(b.totalhp/8)
            pbDisplay(_INTL("{1}'s {2} filtered the strong winds into health!",b.pbThis,b.abilityName))
          end
        when 31 # Fairy Tale Field
          if b.hasActiveAbility?(:NATURALCURE)
            b.pbCureStatus
          end
          if b.hasActiveAbility?(:GUTS) && b.pbHasAnyStatus? && b.canHeal?
            b.pbRecoverHP(b.totalhp/8)
            pbDisplay(_INTL("{1} powers through its struggle!",b.pbThis))
          end
        when 33 # Flower Garden Field
          if $fecounter == 4
            if b.hasActiveAbility?(:SAPSIPPER) && b.canHeal?
              b.pbRecoverHP(b.totalhp/16)
              pbDisplay(_INTL("{1} drank plant nectar to recover!",b.pbThis))
            end
          end
          if b.hasActiveAbility?(:HONEYGATHER) && b.canHeal?
            case $fecounter
            when 2
              b.pbRecoverHP(b.totalhp/16)
              pbDisplay(_INTL("{1}'s {2} restored some of its HP!",b.pbThis,b.abilityName))
            when 3,4
              b.pbRecoverHP(b.totalhp/8)
              pbDisplay(_INTL("{1}'s {2} restored some of its HP!",b.pbThis,b.abilityName))
            end
          end
          if $fecounter >= 2
            if b.hasActiveAbility?(:NATURALCURE)
              b.pbCureStatus
            end
          end
        when 35 # New World
          b.effects[PBEffects::NewTypeRoll] = true
        when 38 # Dimensional Field
          if b.effects[PBEffects::HealBlock] > 0
            if b.pbReduceHP(b.totalhp/16) > 0
              pbDisplay(_INTL("{1} was damaged by the Heal Block!",b.pbThis))
            end
          end
        when 39 # Frozen Dimensional Field
          if b.hasActiveAbility?(:ICEFACE,false,true) && b.form == 1 && pbRandom(2) == 0
            b.pbChangeForm(0,_INTL("{1} transformed!",b.pbThis))
          end
        when 40 # Haunted Field
          if b.asleep?
            if b.pbReduceHP(b.totalhp/16) > 0
              pbDisplay(_INTL("{1}'s dream is corrupted by the evil spirits!",b.pbThis))
            end
          end
        when 41 # Corrupted Cave
          if b.hasActiveAbility?(:POISONHEAL)
            b.pbRecoverHP(b.totalhp/8)
            pbDisplay(_INTL("{1} was healed by the toxic waste!",b.pbThis))
          end
          if b.takesCorruptedCaveDamage?
            if b.hasActiveAbility?([:GRASSPELT,:LEAFGUARD,:FLOWERVEIL,:FLOWERGIFT])
              b.pbInflictTypeScalingFixedDamage(:POISON,b.totalhp/4,_INTL("{1} was damaged by the chemicals",b.pbThis))
            else
              b.pbInflictTypeScalingFixedDamage(:POISON,b.totalhp/8,_INTL("{1} was damaged by the chemicals",b.pbThis))
            end
          end
        when 42 # Bewitched Woods
          if b.grounded? && b.pbHasType?(:GRASS) && b.canHeal?
            b.pbRecoverHP(b.totalhp/16)
            pbDisplay(_INTL("{1} was healed by the magical forestry.",b.pbThis))
          end
          if b.hasActiveAbility?(:NATURALCURE)
            b.pbCureStatus
          end
          if b.hasActiveAbility?(:SAPSIPPER)
            if pbRandom(2) == 0
              if b.canHeal?
                b.pbRecoverHP(b.totalhp/16)
                pbDisplay(_INTL("{1} drank magical tree sap to recover!",b.pbThis))
              end
            elsif b.pbReduceHP(b.totalhp/16) > 0
              pbDisplay(_INTL("{1} drank foul tree sap to lose health!",b.pbThis))
            end
          end
          if b.asleep?
            if b.pbReduceHP(b.totalhp/16) > 0
              pbDisplay(_INTL("{1}'s dream is corrupted by the evil in the woods!",b.pbThis))
            end
          end
        when 43 # Sky Field
          if pbCheckGlobalAbility(:CLOUDNINE) && !b.hasActiveAbility?(:CLOUDNINE)
            if b.pbLowerStatStageByCause(:ACCURACY,1,nil,nil)
              pbDisplay(_INTL("Cloud Nine caused {1}'s Accuracy to fall!",b.pbThis(true)))
            end
          end
        when 44 # Indoors
          if b.hasActiveAbility?(:COMATOSE) && b.canHeal?
            b.pbRecoverHP(b.totalhp/16)
            pbDisplay(_INTL("{1}'s {2} restored some of its HP.",b.pbThis,b.abilityName))
          end
        when 46 # Subzero Field
          if b.pbCanFreeze?(nil,false) && !b.hasActiveAbility?([:FLAMEBODY,:FLASHFIRE,:FURCOAT,:OVERCOAT]) && 
             !b.pbHasType?(:FIRE) && !b.hasActiveItem?([:CHOICESCARF,:SILKSCARF,:HEAVYDUTYBOOTS])
            isFrozen = pbRandom(4)
            if isFrozen == 0 || isFrozen == 1 && b.hasActiveAbility?(:WATERVEIL)
              b.pbFreeze(_INTL("{1} was frozen by the extreme cold!",b.pbThis))
            end
          end
          if b.hasActiveAbility?(:ICEFACE,false,true) && b.form == 1 && pbRandom(2) == 0
            b.pbChangeForm(0,_INTL("{1} transformed!",b.pbThis))
          end
        when 48 # Beach
          if b.hasActiveAbility?(:COMATOSE) && b.canHeal?
            b.pbRecoverHP(b.totalhp/16)
            pbDisplay(_INTL("{1}'s {2} restored some of its HP.",b.pbThis,b.abilityName))
          end
          if (!b.pbHasAnyStatus? || b.asleep?) && b.turnCount > 0
            if b.pbRaiseStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE],1,nil,nil)
              pbDisplay(_INTL("The relaxing atmosphere boosted {1}'s Defense and Sp. Def!",b.pbThis(true)))
            end
            if b.asleep? && b.pbRaiseStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE],1,nil,nil)
              pbDisplay(_INTL("{1} takes full advantage of the relaxation, further boosting its Defense and Sp. Def!",b.pbThis))
            end
          end
        end
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
      # Wasteland Hazard Interaction
      if $fefieldeffect == 19
        for s in @sides
          if s.effects[PBEffects::StealthRock]
            pbDisplay(_INTL("The waste swallowed up the pointed stones!"))
            pbDisplay(_INTL("...Rocks spewed out from the ground below!"))
            priority.each do |b|
              next if b.fainted? || b.pbOwnSide != s
              b.pbInflictTypeScalingFixedDamage(:ROCK,b.totalhp/4)
              b.pbItemHPHealCheck
              b.pbFaint if b.fainted?
            end
            s.effects[PBEffects::StealthRock] = false
          end
          if s.effects[PBEffects::Spikes] > 0
            pbDisplay(_INTL("The waste swallowed up the spikes!"))
            pbDisplay(_INTL("...Spikes shot out from the ground below!"))
            priority.each do |b|
              next if b.fainted? || b.pbOwnSide != s
              b.pbReduceHP(b.totalhp/3)
              b.pbItemHPHealCheck
              b.pbFaint if b.fainted?
            end
            s.effects[PBEffects::Spikes] = 0
          end
          if s.effects[PBEffects::ToxicSpikes] > 0
            pbDisplay(_INTL("The waste swallowed up the toxic spikes!"))
            pbDisplay(_INTL("...Toxic spikes shot out from the ground below!"))
            priority.each do |b|
              next if b.fainted? || b.pbOwnSide != s || b.pbHasType?(:POISON) || b.pbHasType?(:STEEL)
              b.pbReduceHP(b.totalhp/8)
              if b.pbCanPoison?(nil,false)
                b.pbPoison(nil,nil,true)
              end
              b.pbItemHPHealCheck
              b.pbFaint if b.fainted?
            end
            s.effects[PBEffects::ToxicSpikes] = 0
          end
          if s.effects[PBEffects::StickyWeb]
            pbDisplay(_INTL("The waste swallowed up the sticky web!"))
            pbDisplay(_INTL("...Sticky string spewed out from the ground below!"))
            priority.each do |b|
              next if b.fainted? || b.pbOwnSide != s
              b.pbReduceStat(:SPEED,4,nil)
            end
            s.effects[PBEffects::StickyWeb] = false
          end
        end
      end
      # Status-curing effects/abilities and HP-healing items
      priority.each do |b|
        next if b.fainted?
        #BattleHandlers.triggerEORHealingAbility(b.ability,b,self) if b.abilityActive?
        if b.hasActiveAbility?(:HEALER) && $fefieldeffect != 38
          b.eachAlly do |a|
            next if a.status == :NONE || pbRandom(100) >= 30 && ![3,9,29].include?($fefieldeffect)
            pbShowAbilitySplash(b)
            oldStatus = a.status
            a.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
            if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              case oldStatus
              when :SLEEP
                pbDisplay(_INTL("{1}'s {2} woke its partner up!",b.pbThis,b.abilityName))
              when :POISON
                pbDisplay(_INTL("{1}'s {2} cured its partner's poison!",b.pbThis,b.abilityName))
              when :BURN
                pbDisplay(_INTL("{1}'s {2} healed its partner's burn!",b.pbThis,b.abilityName))
              when :PARALYSIS
                pbDisplay(_INTL("{1}'s {2} cured its partner's paralysis!",b.pbThis,b.abilityName))
              when :FROZEN
                pbDisplay(_INTL("{1}'s {2} defrosted its partner!",b.pbThis,b.abilityName))
              end
            end
            pbHideAbilitySplash(b)
          end
        end
        if b.status != :NONE
          if b.hasActiveAbility?(:HYDRATION) && ([:Rain, :HeavyRain].include?(pbWeather) &&
             !b.hasUtilityUmbrella? || [8,21,26].include?($fefieldeffect) && b.grounded? ||
             $fefieldeffect == 22) && $fefieldeffect != 16 || b.hasActiveAbility?(:WATERVEIL) &&
             ($fefieldeffect == 22 || $fefieldeffect == 21 && b.grounded?)
            pbShowAbilitySplash(b)
            oldStatus = b.status
            b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
            if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              case oldStatus
              when :SLEEP
                pbDisplay(_INTL("{1}'s {2} woke it up!",b.pbThis,b.abilityName))
              when :POISON
                pbDisplay(_INTL("{1}'s {2} cured its poison!",b.pbThis,b.abilityName))
              when :BURN
                pbDisplay(_INTL("{1}'s {2} healed its burn!",b.pbThis,b.abilityName))
              when :PARALYSIS
                pbDisplay(_INTL("{1}'s {2} cured its paralysis!",b.pbThis,b.abilityName))
              when :FROZEN
                pbDisplay(_INTL("{1}'s {2} defrosted it!",b.pbThis,b.abilityName))
              end
            end
            pbHideAbilitySplash(b)
          end
          r = pbRandom(100)
          if b.hasActiveAbility?(:SHEDSKIN) && (r<30 || r<60 && [12,49].include?($fefieldeffect))
            pbShowAbilitySplash(b)
            oldStatus = b.status
            b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
            if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              case oldStatus
              when :SLEEP
                pbDisplay(_INTL("{1}'s {2} woke it up!",b.pbThis,b.abilityName))
              when :POISON
                pbDisplay(_INTL("{1}'s {2} cured its poison!",b.pbThis,b.abilityName))
              when :BURN
                pbDisplay(_INTL("{1}'s {2} healed its burn!",b.pbThis,b.abilityName))
              when :PARALYSIS
                pbDisplay(_INTL("{1}'s {2} cured its paralysis!",b.pbThis,b.abilityName))
              when :FROZEN
                pbDisplay(_INTL("{1}'s {2} defrosted it!",b.pbThis,b.abilityName))
              end
            end
            pbHideAbilitySplash(b)
          end
        end
        # Black Sludge, Leftovers
        BattleHandlers.triggerEORHealingItem(b.item,b,self) if b.itemActive?
      end
      # Aqua Ring
      priority.each do |b|
        next if !b.effects[PBEffects::AquaRing]
        if $fefieldeffect == 11 && !b.pbHasType?(:POISON) && !b.pbHasType?(:STEEL)
          if b.pbReduceHP(b.totalhp/16) > 0
            pbDisplay(_INTL("{1}'s Aqua Ring absorbed poison!",b.pbThis))
          end
        else
          next if !b.canHeal?
          hpGain = b.totalhp/16
          hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
          hpGain *= 2 if [3,8,21,22,49].include?($fefieldeffect)
          b.pbRecoverHP(hpGain)
          pbDisplay(_INTL("Aqua Ring restored {1}'s HP!",b.pbThis(true)))
        end
      end
      # Ingrain
      priority.each do |b|
        next if !b.effects[PBEffects::Ingrain]
        if [8,41].include?($fefieldeffect) && !b.pbHasType?(:POISON) && !b.pbHasType?(:STEEL)
          if b.pbReduceHP(b.totalhp/16) > 0
            pbDisplay(_INTL("{1} absorbed foul nutrients with its roots!",b.pbThis))
          end
        elsif $fefieldeffect == 10 && !b.pbHasType?(:POISON)
          if b.pbReduceHP(b.totalhp/8) > 0
            pbDisplay(_INTL("{1} absorbed corrosion with its roots!",b.pbThis))
          end
        else
          next if !b.canHeal?
          hpGain = b.totalhp/16
          hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
          if $fefieldeffect == 33 && $fecounter > 2
            hpGain *= 3
          elsif [2,15,19,42,47,49].include?($fefieldeffect) || $fefieldeffect == 33 && 
                $fecounter > 0
            hpGain *= 2
          end
          b.pbRecoverHP(hpGain)
          pbDisplay(_INTL("{1} absorbed nutrients with its roots!",b.pbThis))
        end
      end
      # Leech Seed
      priority.each do |b|
        next if b.effects[PBEffects::LeechSeed]<0
        next if !b.takesIndirectDamage?
        recipient = @battlers[b.effects[PBEffects::LeechSeed]]
        next if !recipient || recipient.fainted?
        oldHP = b.hp
        oldHPRecipient = recipient.hp
        pbCommonAnimation("LeechSeed",recipient,b)
        hpLoss = b.pbReduceHP(b.totalhp/8)
        if $fefieldeffect == 33 && $fecounter >= 3
          hpLoss *= 3
        elsif [2,19,33,42,47,49].include?($fefieldeffect)
          hpLoss *= 2
        end
        recipient.pbRecoverHPFromDrain(hpLoss,b,_INTL("{1}'s health is sapped by Leech Seed!",b.pbThis))
        recipient.pbAbilitiesOnDamageTaken(oldHPRecipient) if recipient.hp<oldHPRecipient
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
        recipient.pbFaint if recipient.fainted?
      end
      # Damage from Hyper Mode (Shadow Pokémon)
      priority.each do |b|
        next if !b.inHyperMode? || @choices[b.index][0]!=:UseMove
        hpLoss = b.totalhp/24
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(hpLoss,false)
        pbDisplay(_INTL("The Hyper Mode attack hurts {1}!",b.pbThis(true)))
        b.pbFaint if b.fainted?
      end
      # Symbiont
      symbionts = []
      priority.each do |b|
        if b.hasActiveAbility?(:SYMBIONT) && b.canHeal?
          symbionts.push(b)
        end
      end
      # Damage from poisoning
      priority.each do |b|
        next if b.fainted?
        next if b.status != :POISON
        if b.statusCount>0
          b.effects[PBEffects::Toxic] += 1
          b.effects[PBEffects::Toxic] = 15 if b.effects[PBEffects::Toxic]>15
        end
        if b.hasActiveAbility?(:POISONHEAL)
          if b.canHeal?
            anim_name = GameData::Status.get(:POISON).animation
            pbCommonAnimation(anim_name, b) if anim_name
            b.pbRecoverHP(b.totalhp/8)
            pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
          end
        elsif b.takesIndirectDamage?
          oldHP = b.hp
          if b.statusCount == 0
            if $fefieldeffect == 24
              dmg = b.totalhp/16
            else
              dmg = b.totalhp/8
            end
          else
            dmg = b.totalhp*b.effects[PBEffects::Toxic]/16
          end
          dmg *= 2 if $fefieldeffect == 10
          b.pbContinueStatus { dmg = b.pbReduceHP(dmg,false) }
          for a in symbionts
            a.pbRecoverHPFromDrain(dmg,b)
          end
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
      end
      # Damage from burn
      priority.each do |b|
        next if b.status != :BURN || !b.takesIndirectDamage? || $fefieldeffect == 13
        oldHP = b.hp
        dmg = (Settings::MECHANICS_GENERATION >= 7) ? b.totalhp/16 : b.totalhp/8
        dmg = (dmg/2.0).round if b.hasActiveAbility?(:HEATPROOF)
        dmg = (dmg/2.0).round if $fefieldeffect == 46
        b.pbContinueStatus { b.pbReduceHP(dmg,false) }
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
      # Damage from sleep (Nightmare)
      priority.each do |b|
        b.effects[PBEffects::Nightmare] = false if !b.asleep?
        next if !b.effects[PBEffects::Nightmare] || !b.takesIndirectDamage?
        oldHP = b.hp
        if $fefieldeffect == 40
          b.pbReduceHP(b.totalhp/3)
        else
          b.pbReduceHP(b.totalhp/4)
        end
        pbDisplay(_INTL("{1} is locked in a nightmare!",b.pbThis))
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
      # Curse
      priority.each do |b|
        next if !b.effects[PBEffects::Curse]
        if $fefieldeffect == 29
          b.effects[PBEffects::Curse] = false
          pbDisplay(_INTL("{1}'s curse was lifted!",b.pbThis))
          next
        end
        next if !b.takesIndirectDamage?
        oldHP = b.hp
        b.pbReduceHP(b.totalhp/4)
        pbDisplay(_INTL("{1} is afflicted by the curse!",b.pbThis))
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
      # Octolock
      priority.each do |b|
        next if !b.effects[PBEffects::Octolock]
          octouser = @battlers[b.effects[PBEffects::OctolockUser]]
        pbCommonAnimation("Octolock",b)
        if b.pbCanLowerStatStage?(:DEFENSE,octouser,self)
          b.pbLowerStatStage(:DEFENSE,1,octouser,true,false,true)
        end
        if b.pbCanLowerStatStage?(:SPECIAL_DEFENSE,octouser,self)
          b.pbLowerStatStage(:SPECIAL_DEFENSE,1,octouser,true,false,true)
        end
      end
      # Trapping attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
      priority.each do |b|
        next if b.fainted? || b.effects[PBEffects::Trapping] == 0
        trapMove = nil
        for m in @battlers[b.effects[PBEffects::TrappingUser]].moves
          if m.id == b.effects[PBEffects::TrappingMove]
            trapMove = m
            break
          end
        end
        b.effects[PBEffects::Trapping] -= 1
        moveName = GameData::Move.get(b.effects[PBEffects::TrappingMove]).name
        if b.effects[PBEffects::Trapping]==0 || $fefieldeffect == 24 && trapMove &&
           trapMove.pp == 0
          pbDisplay(_INTL("{1} was freed from {2}!",b.pbThis,moveName))
        else
          case b.effects[PBEffects::TrappingMove]
          when :BIND        then pbCommonAnimation("Bind", b)
          when :CLAMP       then pbCommonAnimation("Clamp", b)
          when :FIRESPIN    then pbCommonAnimation("FireSpin", b)
          when :INFESTATION then pbCommonAnimation("Infestation", b)
          when :MAGMASTORM  then pbCommonAnimation("MagmaStorm", b)
          when :SANDTOMB    then pbCommonAnimation("SandTomb", b)
          when :SNAPTRAP    then pbCommonAnimation("SnapTrap",b)
          when :THUNDERCAGE then pbCommonAnimation("ThunderCage",b)
          when :WHIRLPOOL   then pbCommonAnimation("Whirlpool",b)
          when :WRAP        then pbCommonAnimation("Wrap", b)
          else                   pbCommonAnimation("Wrap", b)
          end
          if b.takesIndirectDamage?
            oldHP = b.hp
            if $fefieldeffect == 24
              hpLoss = b.totalhp/16
              b.effects[PBEffects::TrappingUser].pbReducePPOther(trapMove)
            else
              hpLoss = b.totalhp/8
            end
            if @battlers[b.effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
              hpLoss = hpLoss*4/3 # b.totalhp/6, b.totalhp/12
            end
            if @battlers[b.effects[PBEffects::TrappingUser]].hasActiveAbility?(:DISSOLUTION) &&
               ![3,22].include?($fefieldeffect)
              if [8,11].include?($fefieldeffect) || [10,26].include?($fefieldeffect) && 
                 @battlers[b.effects[PBEffects::TrappingUser]].grounded?
                hpLoss = hpLoss*3
              else
                hpLoss = hpLoss*2
              end
            end
            if [7,11,32].include?($fefieldeffect) && b.effects[PBEffects::TrappingMove] == :FIRESPIN ||
               $fefieldeffect == 7 && b.effects[PBEffects::TrappingMove] == :MAGMASTORM ||
               $fefieldeffect == 12 && b.effects[PBEffects::TrappingMove] == :SANDTOMB || 
               [21,22].include?($fefieldeffect) && b.effects[PBEffects::TrappingMove] == :WHIRLPOOL ||
               $fefieldeffect == 22 && b.effects[PBEffects::TrappingMove] == :CLAMP ||
               [2,15,47].include?($fefieldeffect) && [:INFESTATION,:SNAPTRAP].include?(b.effects[PBEffects::TrappingMove]) ||
               $fefieldeffect == 47 && b.effects[PBEffects::TrappingMove] == :BIND
              hpLoss = hpLoss*4/3
            elsif $fefieldeffect == 33 && b.effects[PBEffects::TrappingMove] == :INFESTATION
              case $fecounter
              when 2
                hpLoss = hpLoss*4/3
              when 3
                hpLoss = hpLoss*2
              when 4
                hpLoss = hpLoss*8/3
              end
            end
            @scene.pbDamageAnimation(b)
            b.pbReduceHP(hpLoss,false)
            pbDisplay(_INTL("{1} is hurt by {2}!",b.pbThis,moveName))
            b.pbItemHPHealCheck
            b.pbAbilitiesOnDamageTaken(oldHP)
            b.pbFaint if b.fainted?
            if $fefieldeffect == 20 && b.effects[PBEffects::TrappingMove] == :SANDTOMB
              b.pbLowerStatStage(:ACCURACY,1,b.effects[PBEffects::TrappingUser])
            end
          end
        end
      end
      # Splinters
      priority.each do |b|
        next if b.fainted? || b.effects[PBEffects::Splinter] == 0
        b.effects[PBEffects::Splinter] -= 1
        if b.takesIndirectDamage?
          oldHP = b.hp
          b.pbReduceHP(b.totalhp/8)
          pbDisplay(_INTL("{1} is hurt by its splinters!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
      end
      # Taunt
      fieldDependent = false
      pbEORCountDownBattlerEffect(priority,PBEffects::Taunt,fieldDependent) { |battler|
        pbDisplay(_INTL("{1}'s taunt wore off!",battler.pbThis))
      }
      # Encore
      priority.each do |b|
        next if b.fainted? || b.effects[PBEffects::Encore]==0
        idxEncoreMove = b.pbEncoredMoveIndex
        if idxEncoreMove>=0
          b.effects[PBEffects::Encore] -= 1
          if b.effects[PBEffects::Encore]==0 || b.moves[idxEncoreMove].pp==0
            b.effects[PBEffects::Encore] = 0
            pbDisplay(_INTL("{1}'s encore ended!",b.pbThis))
          end
        else
          PBDebug.log("[End of effect] #{b.pbThis}'s encore ended (encored move no longer known)")
          b.effects[PBEffects::Encore]     = 0
          b.effects[PBEffects::EncoreMove] = nil
        end
      end
      # Disable/Cursed Body
      fieldDependent = false
      pbEORCountDownBattlerEffect(priority,PBEffects::Disable,fieldDependent) { |battler|
        battler.effects[PBEffects::DisableMove] = nil
        pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis))
      }
      # Magnet Rise
      fieldDependent = false
      pbEORCountDownBattlerEffect(priority,PBEffects::MagnetRise,fieldDependent) { |battler|
        pbDisplay(_INTL("{1}'s electromagnetism wore off!",battler.pbThis))
      }
      # Telekinesis
      fieldDependent = $fefieldeffect == 42 && $febackup == 15
      pbEORCountDownBattlerEffect(priority,PBEffects::Telekinesis,fieldDependent) { |battler|
        pbDisplay(_INTL("{1} was freed from the telekinesis!",battler.pbThis))
      }
      # Heal Block
      fieldDependent = false
      pbEORCountDownBattlerEffect(priority,PBEffects::HealBlock,fieldDependent) { |battler|
        pbDisplay(_INTL("{1}'s Heal Block wore off!",battler.pbThis))
      }
      # Embargo
      fieldDependent = false
      pbEORCountDownBattlerEffect(priority,PBEffects::Embargo,fieldDependent) { |battler|
        pbDisplay(_INTL("{1} can use items again!",battler.pbThis))
        battler.pbItemTerrainStatBoostCheck
      }
      # Yawn
      fieldDependent = false
      pbEORCountDownBattlerEffect(priority,PBEffects::Yawn,fieldDependent) { |battler|
        if battler.pbCanSleepYawn?
          PBDebug.log("[Lingering effect] #{battler.pbThis} fell asleep because of Yawn")
          battler.pbSleep
        end
      }
      # Perish Song
      perishSongUsers = []
      priority.each do |b|
        next if b.fainted? || b.effects[PBEffects::PerishSong]==0
        b.effects[PBEffects::PerishSong] -= 1
        pbDisplay(_INTL("{1}'s perish count fell to {2}!",b.pbThis,b.effects[PBEffects::PerishSong]))
        if b.effects[PBEffects::PerishSong]==0
          perishSongUsers.push(b.effects[PBEffects::PerishSongUser])
          b.pbReduceHP(b.hp)
        end
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      end
      if perishSongUsers.length>0
        # If all remaining Pokemon fainted by a Perish Song triggered by a single side
        if (perishSongUsers.find_all { |idxBattler| opposes?(idxBattler) }.length==perishSongUsers.length) ||
           (perishSongUsers.find_all { |idxBattler| !opposes?(idxBattler) }.length==perishSongUsers.length)
          pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
        end
      end
      # Check for end of battle
      if @decision>0
        pbGainExp
        return
      end
      for side in 0...2
        # Reflect
        fieldDependent = false
        pbEORCountDownSideEffect(side,PBEffects::Reflect,_INTL("{1}'s Reflect wore off!",@battlers[side].pbTeam),fieldDependent)
        # Light Screen
        fieldDependent = false
        pbEORCountDownSideEffect(side,PBEffects::LightScreen,_INTL("{1}'s Light Screen wore off!",@battlers[side].pbTeam),fieldDependent)
        # Safeguard
        fieldDependent = $fefieldeffect == 15 && $febackup == 42
        pbEORCountDownSideEffect(side,PBEffects::Safeguard,_INTL("{1} is no longer protected by Safeguard!",@battlers[side].pbTeam),fieldDependent)
        # Mist
        fieldDependent = false
        pbEORCountDownSideEffect(side,PBEffects::Mist,_INTL("{1} is no longer protected by mist!",@battlers[side].pbTeam),fieldDependent)
        # Tailwind
        fieldDependent = $fefieldeffect == 0 && ($febackup == 3 || $febackup == 11) || 
                         $fefieldeffect == 48 && $febackup == 20
        pbEORCountDownSideEffect(side,PBEffects::Tailwind,_INTL("{1}'s Tailwind petered out!",@battlers[side].pbTeam),fieldDependent)
        # Lucky Chant
        fieldDependent = false
        pbEORCountDownSideEffect(side,PBEffects::LuckyChant,_INTL("{1}'s Lucky Chant wore off!",@battlers[side].pbTeam),fieldDependent)
        # Pledge Rainbow
        fieldDependent = false
        pbEORCountDownSideEffect(side,PBEffects::Rainbow,_INTL("The rainbow on {1}'s side disappeared!",@battlers[side].pbTeam(true)),fieldDependent)
        # Pledge Sea of Fire
        fieldDependent = false
        pbEORCountDownSideEffect(side,PBEffects::SeaOfFire,_INTL("The sea of fire around {1} disappeared!",@battlers[side].pbTeam(true)),fieldDependent)
        # Pledge Swamp
        fieldDependent = false
        pbEORCountDownSideEffect(side,PBEffects::Swamp,_INTL("The swamp around {1} disappeared!",@battlers[side].pbTeam(true)),fieldDependent)
        # Aurora Veil
        fieldDependent = false
        pbEORCountDownSideEffect(side,PBEffects::AuroraVeil,_INTL("{1}'s Aurora Veil wore off!",@battlers[side].pbTeam(true)),fieldDependent)
      end
      # Trick Room
      fieldDependent = false
      pbEORCountDownFieldEffect(PBEffects::TrickRoom,_INTL("The twisted dimensions returned to normal!"),fieldDependent)
      # Gravity
      fieldDependent = $fefieldeffect == 0 && ($febackup == 3 || $febackup == 11) || 
                       $fefieldeffect == 22 && $febackup == 21 || $fefieldeffect == 27 &&
                       $febackup == 43
      pbEORCountDownFieldEffect(PBEffects::Gravity,_INTL("Gravity returned to normal!"),fieldDependent)
      # Water Sport
      fieldDependent = $fefieldeffect == 23 && $febackup == 7
      pbEORCountDownFieldEffect(PBEffects::WaterSportField,_INTL("The effects of Water Sport have faded."),fieldDependent)
      # Mud Sport
      fieldDependent = $fefieldeffect == 0 && $febackup == 1 || $fefieldeffect == 23 && 
                       $febackup == 7
      pbEORCountDownFieldEffect(PBEffects::MudSportField,_INTL("The effects of Mud Sport have faded."),fieldDependent)
      # Wonder Room
      fieldDependent = false
      pbEORCountDownFieldEffect(PBEffects::WonderRoom,_INTL("Wonder Room wore off, and Defense and Sp. Def stats returned to normal!"),fieldDependent)
      # Magic Room
      fieldDependent = $fefieldeffect == 42 && $febackup == 15
      pbEORCountDownFieldEffect(PBEffects::MagicRoom,_INTL("Magic Room wore off, and held items' effects returned to normal!"),fieldDependent)
      priority.each do |b|
        next if b.fainted?
        # Hyper Mode (Shadow Pokémon)
        if b.inHyperMode?
          if pbRandom(100)<10
            b.pokemon.hyper_mode = false
            b.pokemon.adjustHeart(-50)
            pbDisplay(_INTL("{1} came to its senses!",b.pbThis))
          else
            pbDisplay(_INTL("{1} is in Hyper Mode!",b.pbThis))
          end
        end
        # Uproar
        if b.effects[PBEffects::Uproar]>0
          b.effects[PBEffects::Uproar] -= 1
          if b.effects[PBEffects::Uproar]==0
            pbDisplay(_INTL("{1} calmed down.",b.pbThis))
          else
            pbDisplay(_INTL("{1} is making an uproar!",b.pbThis))
          end
        end
        # Slow Start's end message
        if b.effects[PBEffects::SlowStart]>0
          b.effects[PBEffects::SlowStart] -= 1
          if b.effects[PBEffects::SlowStart]==0
            pbDisplay(_INTL("{1} finally got its act together!",b.pbThis))
          end
        end
        #BattleHandlers.triggerEOREffectAbility(b.ability,b,self) if b.abilityActive?
        # Bad Dreams
        if b.hasActiveAbility?(:BADDREAMS) && ![9,29].include?($fefieldeffect)
          eachOtherSideBattler(b.index) do |o|
            next if !o.near?(b) || !o.asleep? && ![31,38,40].include?($fefieldeffect)
            pbShowAbilitySplash(b)
            next if !o.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
            oldHP = o.hp
            if $fefieldeffect == 42
              o.pbReduceHP(o.totalhp/4)
            else
              o.pbReduceHP(o.totalhp/8)
            end
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              pbDisplay(_INTL("{1} is tormented!",o.pbThis))
            else
              pbDisplay(_INTL("{1} is tormented by {2}'s {3}!",o.pbThis,b.pbThis(true),b.abilityName))
            end
            pbHideAbilitySplash(b)
            o.pbItemHPHealCheck
            o.pbAbilitiesOnDamageTaken(oldHP)
            o.pbFaint if o.fainted?
          end
        end
        # Moody
        if b.hasActiveAbility?(:MOODY) || b.hasActiveAbility?(:HUSTLE) && $fefieldeffect == 17
          randomUp = []
          randomDown = []
          GameData::Stat.each_main_battle do |s|
            randomUp.push(s.id) if b.pbCanRaiseStatStage?(s.id,b)
            randomDown.push(s.id) if b.pbCanLowerStatStage?(s.id,b)
          end
          if randomUp.length > 0 && randomDown.length > 0
            pbShowAbilitySplash(b)
            if randomUp.length>0
              r = rand(randomUp.length)
              if [37,39].include?($fefieldeffect)
                b.pbRaiseStatStageByAbility(randomUp[r],3,b,false)
              else
                b.pbRaiseStatStageByAbility(randomUp[r],2,b,false)
              end
              randomDown.delete(randomUp[r])
            end
            if randomDown.length>0 && ![31,44].include?($fefieldeffect)
              r = rand(randomDown.length)
              if [37,39].include?($fefieldeffect)
                b.pbLowerStatStageByAbility(randomDown[r],2,b,false)
              else
                b.pbLowerStatStageByAbility(randomDown[r],1,b,false)
              end
            end
            pbHideAbilitySplash(b)
            b.pbItemStatRestoreCheck if randomDown.length>0
          end
        end
        # Speed Boost
        if b.hasActiveAbility?(:SPEEDBOOST) && b.turnCount>0 && $fefieldeffect != 44 &&
           !(!b.pbHasType?(:WATER) && ($fefieldeffect == 22 || [21,26].include?($fefieldeffect) &&
           b.grounded?))
          b.pbRaiseStatStageByAbility(:SPEED,1,b)
        end
        # Hunger Switch
        if b.hasActiveAbility?(:HUNGERSWITCH) && b.pokemon.getNumForms >= 1 && !(b.form == 1 && 
           [12,49].include?($fefieldeffect)) && !(b.form == 0 && ([15,42,47].include?($fefieldeffect) || 
           $fefieldeffect == 33 && $fecounter == 4))
          pbShowAbilitySplash(b)
          newForm = (b.form == 0) ? 1 : 0
          b.pbChangeForm(newForm,_INTL("{1} transformed!",b.pbThis))
          pbHideAbilitySplash(b)
        end
        # Paining Paralysis
        if b.hasActiveAbility?(:PAININGPARALYSIS) && ![9,48].include?($fefieldeffect)
          eachOtherSideBattler(b.index) do |o|
            next if !o.near?(b) || !(o.paralyzed? || $fefieldeffect == 18)
            next if !o.takesIndirectDamage?(false)
            oldHP = o.hp
            if $fefieldeffect == 1
              o.pbReduceHP(o.totalhp/4)
            else
              o.pbReduceHP(o.totalhp/8)
            end
            pbDisplay(_INTL("{1} writhes in pain from {2}'s {3}!",o.pbThis,b.pbThis(true),b.abilityName))
            pbHideAbilitySplash(b)
            o.pbItemHPHealCheck
            o.pbAbilitiesOnDamageTaken(oldHP)
            o.pbFaint if o.fainted?
          end
        end
        # Snap Freeze
        if b.hasActiveAbility?(:SNAPFREEZE) && $fefieldeffect != 16
          eachOtherSideBattler(b.index) do |o|
            next if !o.near?(b) || !o.frozen?
            next if !o.takesIndirectDamage?(false)
            oldHP = o.hp
            if [13,28,32,39,46].include?($fefieldeffect)
              o.pbReduceHP(o.totalhp/3)
            else
              o.pbReduceHP(o.totalhp/4)
            end
            pbDisplay(_INTL("{1} splits apart from {2}'s {3}!",o.pbThis,b.pbThis(true),b.abilityName))
            pbHideAbilitySplash(b)
            o.pbItemHPHealCheck
            o.pbAbilitiesOnDamageTaken(oldHP)
            o.pbFaint if o.fainted?
          end
        end
        # Deep Sleep
        if b.hasActiveAbility?(:DEEPSLEEP) && ![6,38,39,40].include?($fefieldeffect) &&
           b.canHeal?
          if [2,42,48].include?($fefieldeffect)
            b.pbRecoverHP(b.totalhp/4)
          else
            b.pbRecoverHP(b.totalhp/8)
          end
          pbDisplay(_INTL("{1}'s {2} restored its HP a little!",b.pbThis,b.abilityName))
        end
        # Life Force
        if b.hasActiveAbility?(:LIFEFORCE) && ![12,38,40].include?($fefieldeffect) &&
           !b.pbHasAnyStatus?
          if $fefieldeffect == 8
            if b.pbReduceHP(b.totalhp/16) > 0
              pbDisplay(_INTL("{1}'s {2} was sapped by the swamp!",b.pbThis,b.abilityName))
            end
          elsif b.canHeal?
            if [19,29,31,42].include?($fefieldeffect)
              b.pbRecoverHP(b.totalhp/8)
            else
              b.pbRecoverHP(b.totalhp/16)
            end
            pbDisplay(_INTL("{1}'s {2} restored its HP a little!",b.pbThis,b.abilityName))
          end
        end
        # Medic
        if b.hasActiveAbility?(:MEDIC) && $fefieldeffect != 11
          b.eachNearAlly do |a|
            next if !a.canHeal?
            if [9,29].include?($fefieldeffect)
              a.pbRecoverHP(b.totalhp/4)
            else
              a.pbRecoverHP(b.totalhp/8)
            end
            pbDisplay(_INTL("{1}'s {2} restored HP to {3} a little!",b.pbThis,b.abilityName,a.pbThis(true)))
            if $fefieldeffect == 42
              a.pbCureStatus
            end
          end
        end
        # Soothing Aroma
        if b.hasActiveAbility?(:SOOTHINGAROMA) && ![8,11,22,26].include?($fefieldeffect)
          eachBattler do |a|
            next if !a.pbHasType?(:GRASS)
            if ($fefieldeffect == 2 || $fefieldeffect == 33 && $fecounter >= 3) &&
               a.pbHasAnyStatus?
              a.pbCureStatus
            end
            next if !a.canHeal?
            if [3,48].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
              a.pbRecoverHP(a.totalhp/8)
            else
              a.pbRecoverHP(a.totalhp/16)
            end
            pbDisplay(_INTL("{1}'s {2} restored {3}'s HP a little!",b.pbThis,b.abilityName,a.pbThis(true)))
          end
        end
        # Spy Gear
        if b.hasActiveAbility?(:SPYGEAR)
          b.shuffleSpyGear
        end
        # Seed Revitalization
        if b.hasActiveAbility?(:SEEDREVITALIZATION) && !b.effects[PBEffects::SeedRevitalization] &&
           ![10,11,41].include?($fefieldeffect) && !($fefieldeffect == 26 && b.grounded?)
          b.eachNearAlly do |a|
            next if !a.pbHasAnyStatus?
            b.effects[PBEffects::SeedRevitalization] = true
            a.pbCureStatus(false)
            pbDisplay(_INTL("{1}'s {2} cured {3}'s status condition!",b.pbThis,b.abilityName,a.pbThis(true)))
            if a.canHeal?
              a.pbRecoverHP(a.totalhp)
              pbDisplay(_INTL("{1}'s HP was restored!",a.pbThis))
            end
            if $fefieldeffect == 33
              changeFlowerGardenStage(1)
            elsif $fefieldeffect == 42
              a.pbRaiseStatStageByAbility(generateRandomStat,1,b)
            end
          end
          if [2,15,47].include?($fefieldeffect) && b.pbHasAnyStatus?
            b.effects[PBEffects::SeedRevitalization] = true
            b.pbCureStatus(false)
            pbDisplay(_INTL("{1}'s {2} cured its status condition!",b.pbThis,b.abilityName))
            if b.canHeal?
              b.pbRecoverHP(b.totalhp)
              pbDisplay(_INTL("{1}'s HP was restored!",b.pbThis))
            end
          end
        end
        # Alphabetization
        if b.hasActiveAbility?(:ALPHABETIZATION)
          if b.checkAlphabetizationForm(10) && b.recycleItem
            item = b.recycleItem
            b.item = item
            b.setInitialItem(item) if wildBattle? && !b.initialItem
            b.setRecycleItem(nil)
            b.effects[PBEffects::PickupItem] = nil
            b.effects[PBEffects::PickupUse]  = 0
            itemName = GameData::Item.get(item).name
            pbDisplay(_INTL("{1}'s {2} (Keep) brought back its {3}!",b.pbThis,b.abilityName,itemName))
            b.pbHeldItemTriggerCheck
          end
          if b.checkAlphabetizationForm(11)
            worked=false
            b.eachNearOpposing do |o|
              if o.pbCanAttract(b,false,true)
                o.pbAttract(b)
                worked=true
              end
            end
            if worked
              pbDisplay(_INTL("{1}'s {2} (Laugh) infatuated the opposing team!",b.pbThis,b.abilityName))
            end
          end
          if b.checkAlphabetizationForm(16)
            if b.turnCount>0
              b.pbRaiseStatStageByCause(:EVASION,1,b,b.abilityName+" (Quicken)")
            end
          end
          if b.checkAlphabetizationForm(26)
            for s in [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION]
              statIncrease = pbRandom(7) - b.stages[s]
              if statIncrease > 0
                b.pbRaiseStatStageByCause(s,statIncrease,b,b.abilityName+" (?????)")
              elsif statIncrease < 0
                b.pbLowerStatStageByCause(s,statIncrease*-1,b,b.abilityName+" (?????)")
              end
            end
          end
        end
        # Charging Sacs
        if b.hasActiveAbility?(:CHARGINGSACS) && b.turnCount>0
          if rand(2) == 0
            if b.pbRaiseStatStageByAbility(:ATTACK,1,b)
              if b.statStageAtMax?(:ATTACK) && b.pbCanConfuseSelf?(false)
                b.pbConfuse
              end
            end
          else
            if b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,b)
              if b.statStageAtMax?(:SPECIAL_ATTACK) && b.pbCanConfuseSelf?(false)
                b.pbConfuse
              end
            end
          end
        end
        # Electric Love
        if b.effects[PBEffects::Attract] >= 0 && @battlers[b.effects[PBEffects::Attract]].hasActiveAbility?(:ELECTRICLOVE)
          b.pbLowerStatStageByAbility(:SPEED,1,@battlers[b.effects[PBEffects::Attract]])
        end
        # Parfum Charmant
        if b.hasActiveAbility?(:PARFUMCHARMANT) && ![8,22,26].include?($fefieldeffect)
          b.eachNearOpposing do |a|
            if $fefieldeffect == 3 || $fefieldeffect == 33 && $fecounter >= 2
              a.pbLowerStatStageByAbility(:EVASION,2,b)
            else
              a.pbLowerStatStageByAbility(:EVASION,1,b)
            end
            if $fefieldeffect == 33 && $fecounter == 4 && a.pbCanAttract?(b,false)
              a.pbAttract(user,_INTL("{1}'s {2} made {3} fall in love!",b.pbThis,b.abilityName,a.pbThis(true)))
            end
          end
        end
        # Flame Orb, Sticky Barb, Toxic Orb
        BattleHandlers.triggerEOREffectItem(b.item,b,self) if b.itemActive?
        #BattleHandlers.triggerEORGainItemAbility(b.ability,b,self) if b.abilityActive?
        if !b.item
          if b.recycleItem && GameData::Item.get(b.recycleItem).is_berry?
            # Harvest
            if b.hasActiveAbility?(:HARVEST) && ([:Sun,:HarshSun].include?(pbWeather) &&
               !b.hasUtilityUmbrella? || [2,47].include?($fefieldeffect) || $fefieldeffect == 33 &&
               $fecounter >= 3 || pbRandom(100) < 50) && ![7,11,12,49].include?($fefieldeffect)
              pbShowAbilitySplash(b)
              b.item = b.recycleItem
              b.setRecycleItem(nil)
              b.setInitialItem(b.item) if !b.initialItem
              pbDisplay(_INTL("{1} harvested one {2}!",b.pbThis,b.itemName))
              pbHideAbilitySplash(b)
              b.pbHeldItemTriggerCheck
            # Berry Galore
            elsif b.hasActiveAbility?(:BERRYGALORE) && pbRandom(100) < 75
              pbShowAbilitySplash(b)
              b.item = b.recycleItem
              b.setRecycleItem(nil)
              b.setInitialItem(b.item) if !b.initialItem
              pbDisplay(_INTL("{1} found another {2}!",b.pbThis,b.itemName))
              pbHideAbilitySplash(b)
              b.pbHeldItemTriggerCheck
            end
          end
          # Pickup
          if b.hasActiveAbility?(:PICKUP) && b.item != nil
            foundItem = nil
            if $fefieldeffect == 6 && pbRandom(3) == 0
              foundItem = :AIRBALLOON
            elsif $fefieldeffect == 8 && pbRandom(3) == 0
              foundItem = :ABSORBBULB
            elsif $fefieldeffect == 17 && pbRandom(3) == 0
              foundItem = :CELLBATTERY
            elsif $fefieldeffect == 33 && pbRandom(3) == 0
              case $fecounter
              when 2
                foundItem = :MENTALHERB
              when 3
                foundItem = :POWERHERB
              when 4
                foundItem = :WHITEHERB
              end
            elsif $fefieldeffect == 45 && pbRandom(3) == 0
              foundItem = :FOCUSSASH
            elsif $fefieldeffect == 25 && pbRandom(3) == 0
              case rand(18)
              when 0
                foundItem = :GRASSGEM
              when 1
                foundItem = :FIREGEM
              when 2
                foundItem = :WATERGEM
              when 3
                foundItem = :NORMALGEM
              when 4
                foundItem = :POISONGEM
              when 5
                foundItem = :BUGGEM
              when 6
                foundItem = :ROCKGEM
              when 7
                foundItem = :GROUNDGEM
              when 8
                foundItem = :FIGHTINGGEM
              when 9
                foundItem = :ELECTRICGEM
              when 10
                foundItem = :GHOSTGEM
              when 11
                foundItem = :DARKGEM
              when 12
                foundItem = :STEELGEM
              when 13
                foundItem = :FAIRYGEM
              when 14
                foundItem = :PSYCHICGEM
              when 15
                foundItem = :ICEGEM
              when 16
                foundItem = :DRAGONGEM
              when 17
                foundItem = :FLYINGGEM
              end
              if b.pokemon.itemInitial==0
                b.pokemon.itemInitial=b.item
              end
              pbDisplay(_INTL("{1} found one {2}!",b.pbThis,PBItems.getName(b.item)))
            elsif $fefieldeffect == 42 && pbRandom(3) == 0
              r = rand(67)
              if r<64
                r += 389
              else
                r += 530
              end
              item_keys = GameData::Item::DATA.keys
              foundItem = item_keys[r]
            elsif $fefieldeffect == 28 && pbRandom(3) == 0
              foundItem = :SNOWBALL
            elsif $fefieldeffect == 19
              # Common items to find (9 items from this list are added to the pool)
              pickupList = pbDynamicItemList(:POTION1,:ANTIDOTE1,:SUPERPOTION1,:GREATBALL1,
              :REPEL,:ESCAPEROPE,:FULLHEAL1,:HYPERPOTION1,:ULTRABALL,:REVIVE1,:RARECANDY,
              :SUNSTONE,:MOONSTONE,:HEARTSCALE,:FULLRESTORE1,:MAXREVIVE1,:PPUP,:MAXELIXIR1)
              # Rare items to find (2 items from this list are added to the pool)
              pickupListRare = pbDynamicItemList(:HYPERPOTION1,:NUGGET,:KINGSROCK,
              :FULLRESTORE1,:ETHER1,:IRONBALL,:DESTINYKNOT,:ELIXIR1,:DESTINYKNOT,:LEFTOVERS,
              :DESTINYKNOT)
              if pickupList.length >= 18 && pickupListRare.length >= 11
                # Generate a pool of items depending on the Pokémon's level
                items = []
                pkmnLevel = [100,b.level].min
                itemStartIndex = (pkmnLevel-1)/10
                itemStartIndex = 0 if itemStartIndex<0
                for i in 0...9
                  items.push(pickupList[itemStartIndex+i])
                end
                for i in 0...2
                  items.push(pickupListRare[itemStartIndex+i])
                end
                # Probabilities of choosing each item in turn from the pool
                chances = [30,10,10,10,10,10,10,4,4,1,1]   # Needs to be 11 numbers
                chanceSum = 0
                chances.each { |c| chanceSum += c }
                # Randomly choose an item from the pool to give to the Pokémon
                rnd = rand(chanceSum)
                cumul = 0
                chances.each_with_index do |c,i|
                  cumul += c
                  next if rnd>=cumul
                  foundItem = items[i]
                  break
                end
              end
            elsif $fefieldeffect == 44 && pbRandom(3) == 0
              foundItem = :ROOMSERVICE
            else
              fromBattler = nil; use = 0
              eachBattler do |a|
                next if a.index == b.index
                next if a.effects[PBEffects::PickupUse] <= use
                foundItem   = a.effects[PBEffects::PickupItem]
                fromBattler = a
                use         = a.effects[PBEffects::PickupUse]
              end
            end
            if foundItem
              pbShowAbilitySplash(b)
              b.item = foundItem
              if fromBattler
                fromBattler.effects[PBEffects::PickupItem] = nil
                fromBattler.effects[PBEffects::PickupUse]  = 0
                fromBattler.setRecycleItem(nil) if fromBattler.recycleItem == foundItem
              end
              if wildBattle? && !b.initialItem && (!fromBattler || fromBattler.initialItem == foundItem)
                b.setInitialItem(foundItem)
                fromBattler.setInitialItem(nil) if fromBattler
              end
              pbDisplay(_INTL("{1} found one {2}!",b.pbThis,b.itemName))
              pbHideAbilitySplash(b)
              b.pbHeldItemTriggerCheck
            end
          end
          if b.hasActiveAbility?(:BALLFETCH) && b.effects[PBEffects::BallFetch]
            b.item = b.effects[PBEffects::BallFetch]
            b.effects[PBEffects::BallFetch] = nil
            pbShowAbilitySplash(b)
            pbDisplay(_INTL("{1} found a {2}!",b.pbThis,GameData::Item.get(b.item).name))
            pbHideAbilitySplash(b)
          end
        end
      end
      # Field Effect
      pbEORFieldEffect(priority) # Has to be after all counters because FEDuration can depend on those
      pbGainExp
      return if @decision>0
      # Form checks
      priority.each { |b| b.pbCheckForm(true) }
      # Switch Pokémon in if possible
      pbEORSwitch
      return if @decision>0
      # In battles with at least one side of size 3+, move battlers around if none
      # are near to any foes
      pbEORShiftDistantBattlers
      # Try to make Trace work, check for end of primordial weather
      priority.each { |b| b.pbContinualAbilityChecks }
      # Reset/count down battler-specific effects (no messages)
      eachBattler do |b|
        b.effects[PBEffects::BanefulBunker]    = false
        b.effects[PBEffects::Charge]           -= 1 if b.effects[PBEffects::Charge]>0
        b.effects[PBEffects::Counter]          = -1
        b.effects[PBEffects::CounterTarget]    = -1
        b.effects[PBEffects::Electrify]        = false
        b.effects[PBEffects::Endure]           = false
        b.effects[PBEffects::FirstPledge]      = 0
        b.effects[PBEffects::Flinch]           = false
        b.effects[PBEffects::FocusPunch]       = false
        b.effects[PBEffects::FollowMe]         = 0
        b.effects[PBEffects::HelpingHand]      = false
        b.effects[PBEffects::HyperBeam]        -= 1 if b.effects[PBEffects::HyperBeam]>0
        b.effects[PBEffects::KingsShield]      = false
        b.effects[PBEffects::LaserFocus]       -= 1 if b.effects[PBEffects::LaserFocus]>0
        if b.effects[PBEffects::LockOn]>0   # Also Mind Reader
          b.effects[PBEffects::LockOn]         -= 1
          b.effects[PBEffects::LockOnPos]      = -1 if b.effects[PBEffects::LockOn]==0
        end
        b.effects[PBEffects::MagicBounce]      = false
        b.effects[PBEffects::MagicCoat]        = false
        b.effects[PBEffects::MirrorCoat]       = -1
        b.effects[PBEffects::MirrorCoatTarget] = -1
        b.effects[PBEffects::Powder]           = false
        b.effects[PBEffects::Prankster]        = false
        b.effects[PBEffects::PriorityAbility]  = false
        b.effects[PBEffects::PriorityItem]     = false
        b.effects[PBEffects::Protect]          = false
        b.effects[PBEffects::RagePowder]       = false
        b.effects[PBEffects::Roost]            = false
        b.effects[PBEffects::Snatch]           = 0
        b.effects[PBEffects::SpikyShield]      = false
        b.effects[PBEffects::Spotlight]        = 0
        b.effects[PBEffects::ThroatChop]       -= 1 if b.effects[PBEffects::ThroatChop]>0
        b.effects[PBEffects::BurningJealousy]  = false
        b.effects[PBEffects::LashOut]          = false
        b.effects[PBEffects::Obstruct]         = false
        b.effects[PBEffects::SwitchedAlly]     = -1
        b.lastHPLost                           = 0
        b.lastHPLostFromFoe                    = 0
        b.tookDamage                           = false
        b.tookPhysicalHit                      = false
        b.lastRoundMoveFailed                  = b.lastMoveFailed
        b.lastAttacker.clear
        b.lastFoeAttacker.clear
      end
      # Reset/count down side-specific effects (no messages)
      for side in 0...2
        @sides[side].effects[PBEffects::CraftyShield]         = false
        if !@sides[side].effects[PBEffects::EchoedVoiceUsed]
          @sides[side].effects[PBEffects::EchoedVoiceCounter] = 0
        end
        @sides[side].effects[PBEffects::EchoedVoiceUsed]      = false
        @sides[side].effects[PBEffects::MatBlock]             = false
        @sides[side].effects[PBEffects::QuickGuard]           = false
        @sides[side].effects[PBEffects::Round]                = false
        @sides[side].effects[PBEffects::WideGuard]            = false
      end
      # Reset/count down field-specific effects (no messages)
      @field.effects[PBEffects::IonDeluge]   = false
      @field.effects[PBEffects::FairyLock]   -= 1 if @field.effects[PBEffects::FairyLock]>0
      @field.effects[PBEffects::FusionBolt]  = false
      @field.effects[PBEffects::FusionFlare] = false
      @field.effects[PBEffects::VolTopEruption] = false
      # Neutralizing Gas
      pbCheckNeutralizingGas
      @endOfRound = false
    end
    
    def pbCheckNeutralizingGas(battler=nil)
      return if !@field.effects[PBEffects::NeutralizingGas]
      return if battler && (battler.hasActiveAbility?(:NEUTRALIZINGGAS,false,true) ||
          battler.effects[PBEffects::GastroAcid])
      hasabil=false
      eachBattler {|b|
        next if !b || b.fainted?
        next if battler && b.index == battler.index
        # if specified, the battler will switch out, so don't consider it.
        # neutralizing gas can be blocked with gastro acid, ending the effect.
        if b.hasActiveAbility?(:NEUTRALIZINGGAS,false,true) && !b.effects[PBEffects::GastroAcid]
          hasabil=true; break
        end
      }
      if !hasabil
        @field.effects[PBEffects::NeutralizingGas] = false
        pbPriority(true).each { |b|
          next if battler && b.index == battler.index
          b.pbEffectsOnSwitchIn
        }
      end
    end
  end
  